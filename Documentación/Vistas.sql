
USE creditos;
-- Vista para gestionar clientes (información completa necesaria para atención)
CREATE OR REPLACE VIEW vista_clientes_sucursal AS
SELECT 
    c.cliente_id,
    c.nombre,
    c.apellido,
    c.documento,
    td.nombre AS tipo_documento,
    c.telefono,
    c.email,
    c.direccion,
    c.es_juridica,
    se.nombre AS situacion_economica,
    c.ingresos_dec,
    c.fecha_alta,
    c.habilitado
FROM Cliente c
LEFT JOIN Tipo_Doc td ON c.tipo_doc_id = td.tipo_doc_id
LEFT JOIN Situacion_Econ se ON c.sit_econ_id = se.situacion_econ_id
WHERE c.habilitado = TRUE;

-- Vista para consultar productos financieros disponibles
CREATE OR REPLACE VIEW vista_productos_disponibles AS
SELECT 
    pf.producto_finan_id,
    pf.nombre,
    pf.limite_cred,
    pf.tasa_base,
    rp.cuenta AS requiere_cuenta,
    rp.hist_positivo AS requiere_historial_positivo,
    rp.tiene_garante AS requiere_garante,
    pf.fecha_alta
FROM Producto_Finan pf
INNER JOIN Requisitos_Prod rp ON pf.requisitos_prod_id = rp.requisitos_prod_id
WHERE pf.habilitado = TRUE;

-- Vista para gestionar solicitudes de la sucursal
CREATE OR REPLACE VIEW vista_solicitudes_sucursal AS
SELECT 
    s.solicitud_id,
    s.fecha_alta AS fecha_solicitud,
    c.nombre AS cliente_nombre,
    c.apellido AS cliente_apellido,
    c.documento AS cliente_documento,
    pf.nombre AS producto_solicitado,
    s.monto,
    s.motivo,
    s.estado,
    GROUP_CONCAT(
        CONCAT(g.nombre, ' ', g.apellido, ' (', g.relacion_cliente, ')')
        SEPARATOR ', '
    ) AS garantes
FROM Solicitud s
INNER JOIN Cliente c ON s.cliente_id = c.cliente_id
INNER JOIN Producto_Finan pf ON s.producto_finan_id = pf.producto_finan_id
LEFT JOIN Solicitud_Garante sg ON s.solicitud_id = sg.solicitud_id
LEFT JOIN Garante g ON sg.garante_id = g.garante_id AND g.habilitado = TRUE
WHERE s.habilitado = TRUE
GROUP BY s.solicitud_id;

-- Vista para gestionar garantes
CREATE OR REPLACE VIEW vista_garantes_activos AS
SELECT 
    g.garante_id,
    g.nombre,
    g.apellido,
    g.documento,
    td.nombre AS tipo_documento,
    g.telefono,
    g.email,
    g.relacion_cliente,
    g.fecha_alta
FROM Garante g
LEFT JOIN Tipo_Doc td ON g.tipo_doc_id = td.tipo_doc_id
WHERE g.habilitado = TRUE;

-- Vista completa para análisis de solicitudes pendientes
CREATE OR REPLACE VIEW vista_solicitudes_analisis AS
SELECT 
    s.solicitud_id,
    s.fecha_alta AS fecha_solicitud,
    c.cliente_id,
    c.nombre AS cliente_nombre,
    c.apellido AS cliente_apellido,
    c.documento AS cliente_documento,
    se.nombre AS situacion_economica,
    c.ingresos_dec,
    pf.nombre AS producto_solicitado,
    pf.limite_cred,
    s.monto AS monto_solicitado,
    s.motivo,
    s.estado,
    COUNT(DISTINCT sg.garante_id) AS cantidad_garantes,
    er.puntaje_riesgo,
    er.estado AS estado_evaluacion,
    er.fecha_alta AS fecha_evaluacion
FROM Solicitud s
INNER JOIN Cliente c ON s.cliente_id = c.cliente_id
INNER JOIN Situacion_Econ se ON c.sit_econ_id = se.situacion_econ_id
INNER JOIN Producto_Finan pf ON s.producto_finan_id = pf.producto_finan_id
LEFT JOIN Solicitud_Garante sg ON s.solicitud_id = sg.solicitud_id
LEFT JOIN Evaluacion_Riesgo er ON s.solicitud_id = er.solicitud_id
WHERE s.habilitado = TRUE
GROUP BY s.solicitud_id;

-- Vista para análisis de comportamiento de clientes
CREATE OR REPLACE VIEW vista_historial_cliente AS
SELECT 
    c.cliente_id,
    c.nombre,
    c.apellido,
    c.documento,
    COUNT(DISTINCT s.solicitud_id) AS total_solicitudes,
    COUNT(DISTINCT CASE WHEN s.estado = 'aprobado' THEN s.solicitud_id END) AS solicitudes_aprobadas,
    COUNT(DISTINCT cr.credito_id) AS creditos_activos,
    SUM(CASE WHEN s.estado = 'aprobado' THEN s.monto ELSE 0 END) AS monto_total_aprobado,
    AVG(er.puntaje_riesgo) AS promedio_puntaje_riesgo,
    MAX(es.nivel_endeudamiento) AS ultimo_nivel_endeudamiento,
    MAX(es.comportamiento_pago) AS ultimo_comportamiento_pago,
    MAX(es.fecha_alta) AS fecha_ultima_evaluacion
FROM Cliente c
LEFT JOIN Solicitud s ON c.cliente_id = s.cliente_id AND s.habilitado = TRUE
LEFT JOIN Credito cr ON s.credito_id = cr.credito_id AND cr.habilitado = TRUE
LEFT JOIN Evaluacion_Riesgo er ON s.solicitud_id = er.solicitud_id AND er.habilitado = TRUE
LEFT JOIN Evaluacion_Seg es ON c.cliente_id = es.cliente_id AND es.habilitado = TRUE
WHERE c.habilitado = TRUE
GROUP BY c.cliente_id;

-- Vista para seguimiento de créditos activos
CREATE OR REPLACE VIEW vista_creditos_seguimiento AS
SELECT 
    cr.credito_id,
    c.cliente_id,
    c.nombre AS cliente_nombre,
    c.apellido AS cliente_apellido,
    s.solicitud_id,
    cr.monto_ot AS monto_otorgado,
    cr.tasa_int,
    cr.fecha_alta AS fecha_inicio,
    cr.fecha_fin,
    cr.plazo_dias,
    COUNT(cu.cuota_id) AS total_cuotas,
    COUNT(CASE WHEN cu.estado = 'pagado' THEN cu.cuota_id END) AS cuotas_pagadas,
    COUNT(CASE WHEN cu.estado = 'pendiente' AND cu.fecha_venc < CURDATE() THEN cu.cuota_id END) AS cuotas_vencidas,
    SUM(CASE WHEN p.dias_demora > 0 THEN p.dias_demora ELSE 0 END) AS total_dias_mora,
    SUM(CASE WHEN p.pena_mora > 0 THEN p.pena_mora ELSE 0 END) AS total_penalizaciones
FROM Credito cr
INNER JOIN Solicitud s ON cr.credito_id = s.credito_id
INNER JOIN Cliente c ON s.cliente_id = c.cliente_id
LEFT JOIN Cuota cu ON cr.credito_id = cu.credito_id
LEFT JOIN Pago p ON cu.cuota_id = p.cuota_id
WHERE cr.habilitado = TRUE
GROUP BY cr.credito_id;

-- Vista para clientes con comportamiento riesgoso
CREATE OR REPLACE VIEW vista_clientes_alto_riesgo AS
SELECT 
    c.cliente_id,
    c.nombre,
    c.apellido,
    c.documento,
    se.nombre AS situacion_economica,
    es.nivel_endeudamiento,
    es.comportamiento_pago,
    COUNT(CASE WHEN cu.estado = 'pendiente' AND cu.fecha_venc < CURDATE() THEN cu.cuota_id END) AS cuotas_vencidas,
    SUM(CASE WHEN p.pena_mora > 0 THEN p.pena_mora ELSE 0 END) AS total_moras,
    AVG(er.puntaje_riesgo) AS promedio_riesgo
FROM Cliente c
INNER JOIN Situacion_Econ se ON c.sit_econ_id = se.situacion_econ_id
LEFT JOIN Evaluacion_Seg es ON c.cliente_id = es.cliente_id AND es.habilitado = TRUE
LEFT JOIN Solicitud s ON c.cliente_id = s.cliente_id AND s.habilitado = TRUE
LEFT JOIN Credito cr ON s.credito_id = cr.credito_id AND cr.habilitado = TRUE
LEFT JOIN Evaluacion_Riesgo er ON s.solicitud_id = er.solicitud_id AND er.habilitado = TRUE
LEFT JOIN Cuota cu ON cr.credito_id = cu.credito_id AND cu.habilitado = TRUE
LEFT JOIN Pago p ON cu.cuota_id = p.cuota_id AND p.habilitado = TRUE
WHERE c.habilitado = TRUE
GROUP BY c.cliente_id
HAVING cuotas_vencidas > 0 OR total_moras > 0 OR promedio_riesgo < 60;


-- Vista de resumen general del sistema
CREATE OR REPLACE VIEW vista_dashboard_general AS
SELECT 
    (SELECT COUNT(*) FROM Cliente WHERE habilitado = TRUE) AS total_clientes_activos,
    (SELECT COUNT(*) FROM Solicitud WHERE habilitado = TRUE) AS total_solicitudes,
    (SELECT COUNT(*) FROM Solicitud WHERE estado = 'revision' AND habilitado = TRUE) AS solicitudes_en_revision,
    (SELECT COUNT(*) FROM Credito WHERE habilitado = TRUE) AS creditos_activos,
    (SELECT SUM(monto_ot) FROM Credito WHERE habilitado = TRUE) AS monto_total_prestado,
    (SELECT COUNT(*) FROM Cuota WHERE estado = 'pendiente' AND fecha_venc < CURDATE()) AS cuotas_vencidas,
    (SELECT SUM(pena_mora) FROM Pago WHERE pena_mora > 0) AS total_penalizaciones_cobradas,
    (SELECT COUNT(*) FROM Empleado WHERE habilitado = TRUE) AS empleados_activos,
    (SELECT COUNT(*) FROM Sucursal WHERE habilitado = TRUE) AS sucursales_activas;

-- Vista de rendimiento por producto financiero
CREATE OR REPLACE VIEW vista_rendimiento_productos AS
SELECT 
    pf.producto_finan_id,
    pf.nombre AS producto,
    pf.limite_cred,
    pf.tasa_base,
    COUNT(DISTINCT s.solicitud_id) AS total_solicitudes,
    COUNT(DISTINCT CASE WHEN s.estado = 'aprobado' THEN s.solicitud_id END) AS solicitudes_aprobadas,
    COUNT(DISTINCT cr.credito_id) AS creditos_otorgados,
    SUM(CASE WHEN s.estado = 'aprobado' THEN cr.monto_ot ELSE 0 END) AS monto_total_otorgado,
    AVG(cr.tasa_int) AS tasa_promedio_aplicada,
    COUNT(DISTINCT ht.hist_tasas_id) AS cambios_tasa
FROM Producto_Finan pf
LEFT JOIN Solicitud s ON pf.producto_finan_id = s.producto_finan_id AND s.habilitado = TRUE
LEFT JOIN Credito cr ON s.credito_id = cr.credito_id AND cr.habilitado = TRUE
LEFT JOIN Hist_Tasas ht ON pf.producto_finan_id = ht.producto_finan_id AND ht.habilitado = TRUE
WHERE pf.habilitado = TRUE
GROUP BY pf.producto_finan_id;

-- Vista de performance de sucursales
CREATE OR REPLACE VIEW vista_rendimiento_sucursales AS
SELECT 
    su.sucursal_id,
    su.nombre AS sucursal,
    su.direccion,
    COUNT(DISTINCT e.empleado_id) AS total_empleados,
    COUNT(DISTINCT s.solicitud_id) AS total_solicitudes_gestionadas,
    COUNT(DISTINCT CASE WHEN s.estado = 'aprobado' THEN s.solicitud_id END) AS solicitudes_aprobadas,
    SUM(CASE WHEN s.estado = 'aprobado' THEN cr.monto_ot ELSE 0 END) AS monto_total_gestionado,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.estado = 'aprobado' THEN s.solicitud_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT s.solicitud_id), 0), 
        2
    ) AS tasa_aprobacion_porcentaje
FROM Sucursal su
LEFT JOIN Empleado e ON su.sucursal_id = e.sucursal_id AND e.habilitado = TRUE
LEFT JOIN Solicitud s ON s.habilitado = TRUE
LEFT JOIN Credito cr ON s.credito_id = cr.credito_id AND cr.habilitado = TRUE
WHERE su.habilitado = TRUE
GROUP BY su.sucursal_id;

-- Vista de campañas activas y su efectividad
CREATE OR REPLACE VIEW vista_efectividad_campanias AS
SELECT 
    cp.campania_prom_id,
    cp.tasa_prom,
    cp.vigencia,
    COUNT(DISTINCT cc.cliente_id) AS clientes_alcanzados,
    COUNT(DISTINCT cprod.producto_finan_id) AS productos_promocionados,
    COUNT(DISTINCT s.solicitud_id) AS solicitudes_generadas,
    SUM(CASE WHEN s.estado = 'aprobado' THEN cr.monto_ot ELSE 0 END) AS monto_total_generado
FROM Campania_Prom cp
LEFT JOIN Campania_Cliente cc ON cp.campania_prom_id = cc.campana_prom_id
LEFT JOIN Campania_Producto cprod ON cp.campania_prom_id = cprod.campania_prom_id
LEFT JOIN Solicitud s ON cc.cliente_id = s.cliente_id 
    AND s.fecha_alta BETWEEN cp.fecha_alta AND cp.vigencia
    AND s.habilitado = TRUE
LEFT JOIN Credito cr ON s.credito_id = cr.credito_id AND cr.habilitado = TRUE
WHERE cp.habilitado = TRUE AND cp.vigencia >= CURDATE()
GROUP BY cp.campania_prom_id;

-- Vista de estado de cobranzas
CREATE OR REPLACE VIEW vista_estado_cobranzas AS
SELECT 
    YEAR(cu.fecha_venc) AS anio,
    MONTH(cu.fecha_venc) AS mes,
    COUNT(cu.cuota_id) AS total_cuotas,
    COUNT(CASE WHEN cu.estado = 'pagado' THEN cu.cuota_id END) AS cuotas_pagadas,
    COUNT(CASE WHEN cu.estado = 'pendiente' THEN cu.cuota_id END) AS cuotas_pendientes,
    COUNT(CASE WHEN cu.estado = 'pendiente' AND cu.fecha_venc < CURDATE() THEN cu.cuota_id END) AS cuotas_vencidas,
    SUM(cu.monto_total) AS monto_total_esperado,
    SUM(CASE WHEN p.pago_id IS NOT NULL THEN p.monto_pago ELSE 0 END) AS monto_cobrado,
    SUM(CASE WHEN p.pena_mora > 0 THEN p.pena_mora ELSE 0 END) AS penalizaciones_cobradas,
    AVG(CASE WHEN p.dias_demora > 0 THEN p.dias_demora ELSE 0 END) AS promedio_dias_demora
FROM Cuota cu
LEFT JOIN Pago p ON cu.cuota_id = p.cuota_id AND p.habilitado = TRUE
WHERE cu.habilitado = TRUE
GROUP BY YEAR(cu.fecha_venc), MONTH(cu.fecha_venc)
ORDER BY anio DESC, mes DESC;

-- Permisos para EMPLEADO DE SUCURSAL
GRANT SELECT ON creditos.vista_clientes_sucursal TO 'empleado_sucursal'@'%';
GRANT SELECT ON creditos.vista_productos_disponibles TO 'empleado_sucursal'@'%';
GRANT SELECT ON creditos.vista_solicitudes_sucursal TO 'empleado_sucursal'@'%';
GRANT SELECT ON creditos.vista_garantes_activos TO 'empleado_sucursal'@'%';

-- Permisos para ANALISTA DE RIESGO
GRANT SELECT ON creditos.vista_solicitudes_analisis TO 'analista_riesgo'@'%';
GRANT SELECT ON creditos.vista_historial_cliente TO 'analista_riesgo'@'%';
GRANT SELECT ON creditos.vista_creditos_seguimiento TO 'analista_riesgo'@'%';
GRANT SELECT ON creditos.vista_clientes_alto_riesgo TO 'analista_riesgo'@'%';

-- Permisos para ADMINISTRADOR (acceso a todas las vistas)
GRANT SELECT ON creditos.vista_dashboard_general TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_rendimiento_productos TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_rendimiento_sucursales TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_efectividad_campanias TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_estado_cobranzas TO 'administrador'@'%';

-- El administrador también tiene acceso a las vistas de los otros usuarios
GRANT SELECT ON creditos.vista_clientes_sucursal TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_productos_disponibles TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_solicitudes_sucursal TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_garantes_activos TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_solicitudes_analisis TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_historial_cliente TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_creditos_seguimiento TO 'administrador'@'%';
GRANT SELECT ON creditos.vista_clientes_alto_riesgo TO 'administrador'@'%';