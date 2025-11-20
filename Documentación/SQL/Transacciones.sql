DELIMITER $$

CREATE PROCEDURE creditos.aprobar_solicitud_completa(
    IN p_solicitud_id INT,
    IN p_usuario VARCHAR(100)
)
BEGIN
    -- VARIABLES (todas deben ir juntas arriba)
    DECLARE v_cliente_id INT;
    DECLARE v_producto_id INT;
    DECLARE v_monto DECIMAL(15,2);
    DECLARE v_cuotas INT;
    DECLARE v_tasa DECIMAL(5,2);
    DECLARE v_credito_id INT;
    DECLARE v_fecha_inicio DATE;
    DECLARE v_periodo_dias INT DEFAULT 30;

    DECLARE i INT DEFAULT 1;
    DECLARE v_monto_cuota DECIMAL(15,2);

    -- Handler de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error al aprobar la solicitud; se hizo ROLLBACK';
    END;

    START TRANSACTION;

    -- Obtener datos de la solicitud
    SELECT cliente_id, producto_id, monto, cuotas
    INTO v_cliente_id, v_producto_id, v_monto, v_cuotas
    FROM creditos.Solicitud
    WHERE id = p_solicitud_id
    FOR UPDATE;

    IF v_cliente_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solicitud no encontrada';
    END IF;

    -- Leer tasa
    SELECT tasa
    INTO v_tasa
    FROM creditos.Hist_Tasas
    WHERE producto_id = v_producto_id
    ORDER BY fecha_desde DESC
    LIMIT 1;

    IF v_tasa IS NULL THEN
        SET v_tasa = 0.0;
    END IF;

    SET v_fecha_inicio = CURDATE();

    -- Insertar crédito
    INSERT INTO creditos.Credito (
        solicitud_id, cliente_id, producto_id, monto_ot, monto_restante,
        cuotas, tasa, fecha_inicio, fecha_fin, estado, habilitado,
        fecha_alta, usuario_alta
    )
    VALUES (
        p_solicitud_id, v_cliente_id, v_producto_id, v_monto, v_monto,
        v_cuotas, v_tasa, v_fecha_inicio,
        DATE_ADD(v_fecha_inicio, INTERVAL v_cuotas * v_periodo_dias DAY),
        'vigente', 1, NOW(), p_usuario
    );

    SET v_credito_id = LAST_INSERT_ID();

    -- Monto por cuota
    SET v_monto_cuota = ROUND(v_monto / v_cuotas, 2);

    -- Generar cuotas
    WHILE i <= v_cuotas DO
        INSERT INTO creditos.Cuota (
            credito_id, nro_cuota, monto_total, monto_pagado,
            fecha_venc, estado, habilitado, fecha_alta, usuario_alta
        )
        VALUES (
            v_credito_id, i, v_monto_cuota, 0.00,
            DATE_ADD(v_fecha_inicio, INTERVAL (i - 1) * v_periodo_dias DAY),
            'pendiente', 1, NOW(), p_usuario
        );

        SET i = i + 1;
    END WHILE;

    -- Marcar solicitud como aprobada
    UPDATE creditos.Solicitud
    SET estado = 'aprobado',
        credito_id = v_credito_id,
        fecha_mod = NOW(),
        usuario_mod = p_usuario
    WHERE id = p_solicitud_id;

    COMMIT;
END$$

CREATE PROCEDURE creditos.procesar_lote_pagos()
BEGIN
    -- Variables
    DECLARE v_cuota_id INT;
    DECLARE v_monto_pago DECIMAL(15,2);
    DECLARE v_metodo INT;
    DECLARE v_usuario VARCHAR(100);

    DECLARE done INT DEFAULT 0;

    -- Variables auxiliares del SELECT
    DECLARE m_total DECIMAL(15,2);
    DECLARE m_pagado DECIMAL(15,2);
    DECLARE credito_aux INT;

    -- Cursor
    DECLARE cur CURSOR FOR
        SELECT cuota_id, monto, metodo_pago_id, usuario
        FROM creditos.tmp_pagos_lote;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error en procesamiento de lote; se hizo ROLLBACK';
    END;

    START TRANSACTION;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_cuota_id, v_monto_pago, v_metodo, v_usuario;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Bloquear cuota
        SELECT monto_total, monto_pagado, credito_id
        INTO m_total, m_pagado, credito_aux
        FROM creditos.Cuota
        WHERE id = v_cuota_id
        FOR UPDATE;

        IF m_total IS NULL THEN
            ITERATE read_loop;
        END IF;

        -- Registrar pago
        INSERT INTO creditos.Pago (
            cuota_id, monto, metodo_pago_id,
            fecha_alta, habilitado, fecha_registro, usuario_alta
        )
        VALUES (
            v_cuota_id, v_monto_pago, v_metodo,
            NOW(), 1, NOW(), v_usuario
        );

        -- Actualizar cuota
        UPDATE creditos.Cuota
        SET monto_pagado = monto_pagado + v_monto_pago,
            fecha_mod = NOW(),
            usuario_mod = v_usuario
        WHERE id = v_cuota_id;

        -- Marcar pagada si corresponde
        UPDATE creditos.Cuota
        SET estado = 'pagada'
        WHERE id = v_cuota_id
        AND monto_pagado >= monto_total;

        -- Actualizar crédito
        UPDATE creditos.Credito
        SET monto_restante = monto_restante - v_monto_pago,
            fecha_mod = NOW(),
            usuario_mod = v_usuario
        WHERE id = credito_aux;

    END LOOP;

    CLOSE cur;

    -- Vaciar tabla temporal
    DELETE FROM creditos.tmp_pagos_lote;

    COMMIT;
END$$

DELIMITER ;
