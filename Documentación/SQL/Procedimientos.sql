USE creditos;

DELIMITER $$

CREATE FUNCTION fn_calcular_pena( -- Cálculo de pena por mora
    p_monto DECIMAL(13,2),
    p_dias_demora INT
) RETURNS DECIMAL(13,2)
    DETERMINISTIC -- Significa que siempre devuelve las mismas salidas frente a las mismas entrads
BEGIN
    DECLARE tasa_diaria DECIMAL(10,6);
    DECLARE v_pena DECIMAL(13,2);

    IF p_monto IS NULL OR p_dias_demora IS NULL OR p_dias_demora <= 0 THEN
        RETURN 0.00;
    END IF;

    SET tasa_diaria = 0.01; -- Varía según la situación de la empresa
    SET v_pena = ROUND(p_monto * tasa_diaria * GREATEST(p_dias_demora, 0), 2);

    RETURN v_pena;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION fn_get_sit_econ( -- Obtener la situacion económica basandose en los ingresos declarados
    p_ingreso INT
) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE v_id INT;

    SELECT s.situacion_econ_id
    INTO v_id
    FROM situacion_econ s
    WHERE p_ingreso BETWEEN s.ingreso_min AND s.ingreso_max
    LIMIT 1; -- Forzamos solamente una tupla

    RETURN v_id;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_create_campania( -- Procedimiento para crear nuevas campañas
    IN p_tasa_prom DECIMAL(4,2),
    IN p_vigencia DATE,
    IN p_habilitado BOOLEAN,
    IN p_usuario_alta VARCHAR(30),
    OUT out_campania_id INT
)
BEGIN
    INSERT INTO campania_prom (tasa_prom, vigencia, habilitado, usuario_alta)
    VALUES (p_tasa_prom, p_vigencia, p_habilitado, p_usuario_alta);

    SET out_campania_id = LAST_INSERT_ID();
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_campania_producto_link( -- Procedimiento para vincular una campaña con un producto automáticamente
    IN p_campania_prom_id INT,
    IN p_producto_finan_id INT
)
BEGIN
    DECLARE v_count INT;

    -- Validar campaña existe
    SELECT COUNT(*) INTO v_count FROM campania_prom WHERE campania_prom_id = p_campania_prom_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Campania no encontrada';
    END IF;

    -- Validar producto existe
    SELECT COUNT(*) INTO v_count FROM producto_finan WHERE producto_finan_id = p_producto_finan_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto financiero no encontrado';
    END IF;

    -- Evitar vinculación duplicada
    SELECT COUNT(*) INTO v_count
    FROM campania_producto cp
    WHERE cp.campania_prom_id = p_campania_prom_id
      AND cp.producto_finan_id = p_producto_finan_id;

    IF v_count = 0 THEN
        INSERT INTO campania_producto (campania_prom_id, producto_finan_id)
        VALUES (p_campania_prom_id, p_producto_finan_id);
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_registrar_pago( -- Procedimiento para registrar pagos facilmente con validaciones de datos
    IN p_cuota_id INT,
    IN p_monto_pago DECIMAL(13,2),
    IN p_metodo_pago_id INT,
    IN p_dias_demora INT,
    IN p_usuario_alta VARCHAR(30),
    OUT out_pago_id INT
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_monto_cuota DECIMAL(13,2);
    DECLARE v_pena DECIMAL(13,2);

    -- Validar cuota existe y obtener monto_total
    SELECT COUNT(*), monto_total INTO v_count, v_monto_cuota
    FROM cuota
    WHERE cuota_id = p_cuota_id
    GROUP BY monto_total;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cuota no encontrada';
    END IF;

    -- Validar método de pago existe
    SELECT COUNT(*) INTO v_count FROM metodo_pago WHERE metodo_pago_id = p_metodo_pago_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Metodo de pago no encontrado';
    END IF;

    -- Calcular pena usando la función (si corresponde)
    SET v_pena = fn_calcular_pena(p_monto_pago, p_dias_demora);

    -- Insertar pago
    INSERT INTO pago (cuota_id, dias_demora, pena_mora, monto_pago, metodo_pago_id, usuario_alta)
    VALUES (p_cuota_id, p_dias_demora, v_pena, p_monto_pago, p_metodo_pago_id, p_usuario_alta);

    SET out_pago_id = LAST_INSERT_ID();

    -- Si el pago cubre la cuota, marcarla como pagada
    IF p_monto_pago >= v_monto_cuota THEN -- En lugar de utilizar un trigger, actualizamos el valor del estado en este procedimiento
        UPDATE Cuota
        SET estado = 'pagado'
        WHERE cuota_id = p_cuota_id;
    END IF;

END$$

DELIMITER ;
