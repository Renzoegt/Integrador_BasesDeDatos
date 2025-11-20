-- Los tres usuarios creados fueron un administrador, un empleado de la sucursal y el analista de riesgo, que es el que se encuentra en el área de evaluación crediticia.
CREATE USER 'administrador'@'%' IDENTIFIED BY '@Admin1234';
CREATE USER 'empleado_sucursal'@'%' IDENTIFIED BY '@Empleado1234';
CREATE USER 'analista_riesgo'@'%' IDENTIFIED BY '@Analista1234';

-- Al administrador le asignamos todos los permisos para que pueda gestionar de forma completa la base de datos.
GRANT ALL PRIVILEGES ON creditos.* TO 'administrador'@'%';

-- Al empleado de la sucursal, el cual es el encargado de atender a los clientes, debe tener acceso a los clientes, a la solicitud de crédito, de vincular o verificar el garante del cliente y los productos financieros ofrecidos.
GRANT SELECT, INSERT, UPDATE
ON creditos.Cliente
TO 'empleado_sucursal'@'%';

GRANT SELECT, INSERT
ON creditos.Solicitud
TO 'empleado_sucursal'@'%';

GRANT SELECT, INSERT, UPDATE
ON creditos.Solicitud_Garante
TO 'empleado_sucursal'@'%';

GRANT SELECT
ON creditos.Producto_Finan
TO 'empleado_sucursal'@'%';

-- El analista de riesgo tiene la función de analizar las solicitudes de crédito, asignar un puntaje de riesgo y realizar evaluaciones de seguimiento del comportamiento financiero del cliente. Por ende, se le otorgan permisos de lectura y escritura sobre la información necesaria para cumplir con estas tareas.
GRANT SELECT, UPDATE
ON creditos.Solicitud
TO 'analista_riesgo'@'%';

GRANT SELECT
ON creditos.Solicitud_Garante
TO 'analista_riesgo'@'%';

GRANT SELECT, INSERT
ON creditos.Evaluacion_Riesgo
TO 'analista_riesgo'@'%';

GRANT SELECT, INSERT
ON creditos.Evaluacion_Seg
TO 'analista_riesgo'@'%';

GRANT SELECT
ON creditos.Cliente
TO 'analista_riesgo'@'%';

GRANT SELECT
ON creditos.Credito
TO 'analista_riesgo'@'%';

-- En mariaDB no se utiliza "FLUSH PRIVILEGES;" para aplicar los permisos a los usuarios.

-- Este índice permite encontrar los datos de un cliente introduciendo su número de documento. El impacto que genera es que acelera la identificación de personas por DNI evitando recorrer toda la tabla.
CREATE INDEX idx_persona_documento
ON Cliente (documento);


-- Este índice permite buscar rápidamente todas las solicitudes asociadas a un cliente. Su impacto es que facilita generar reportes, revisar historial de solicitudes y el análisis riesgo (que analiza la actividad crediticia por cliente).
CREATE INDEX idx_solicitud_cliente
ON Solicitud (cliente_id);


-- Este índice se encarga de filtrar clientes por situación económica. Su impacto se centra principalmente en el área de análisis de riesgo y para reportes estadísticos, donde se evalúa el perfil económico de los clientes.
CREATE INDEX idx_cliente_situacion
ON Cliente (sit_econ_id);


-- Este índice Permite buscar cuotas que están cerca de vencer, vencidas o dentro de un determinado rango de tiempo. Su impacto se centra en recargos por tardanza, generación de avisos de vencimiento, etc.
CREATE INDEX idx_cuota_fecha_venc
ON Cuota (fecha_venc);


-- Índice permite filtrar por método de pago y fecha. Su impacto es que facilita realizar informes contables, estadísticas de uso de medios de pago y análisis de cobranzas.
CREATE INDEX idx_pago_metodo_fecha
ON Pago (metodo_pago_id, fecha_alta);

-- 1: Lista nombre, email y tipo de documento
SELECT 
    c.nombre AS nombre,
    c.email AS correo,
    c.documento AS numero_documento
FROM Cliente c
WHERE c.email IS NOT NULL
ORDER BY c.nombre ASC;

-- 2: Filtro avanzado con ingresos, fecha y email válido usando funciones
SELECT 
    c.*, 
    YEAR(c.fecha_alta) AS anio_alta,
    IFNULL(c.telefono, 'Sin teléfono') AS telefono_normalizado
FROM Cliente c
WHERE c.ingresos_dec BETWEEN 60000 AND 150000
    AND c.habilitado = TRUE
    AND c.email LIKE '%@%'
    AND (c.fecha_baja IS NULL OR YEAR(c.fecha_baja) >= 2024);


-- 3: Top 3 clientes con mayor tasa de interés aplicada
SELECT 
    c.nombre,                                                     
    c.apellido,                                                   
    s.solicitud_id,                                               
    p.nombre AS producto,                                         
    p.tasa_base AS tasa_interes                                   
FROM Cliente c
JOIN Solicitud s ON c.cliente_id = s.cliente_id                  
JOIN Producto_Finan p ON p.producto_finan_id = s.producto_finan_id 
ORDER BY p.tasa_base DESC                                         
LIMIT 3;                                                          


-- 4: Solicitudes aprobadas, con cálculo de monto final aplicando tasa base
SELECT 
    c.nombre,                                                     
    c.apellido,                                                  
    s.solicitud_id,
    s.monto,
    s.estado,
    p.nombre AS producto,                                        
    p.tasa_base,
    ROUND(s.monto * (1 + p.tasa_base / 100), 2) AS monto_con_interes 
FROM Cliente c
JOIN Solicitud s ON c.cliente_id = s.cliente_id
JOIN Producto_Finan p ON p.producto_finan_id = s.producto_finan_id
WHERE s.estado = 'aprobado'                                      
    AND s.monto > (SELECT AVG(monto) FROM Solicitud);              


-- 5: Unión de clientes y garantes, con validación de emails y clasificación por tipo
SELECT 
    c.nombre,
    c.apellido,
    c.documento,
    'CLIENTE' AS tipo_persona,
    IF(c.email LIKE '%@%', c.email, 'email_invalido') AS email_validado 
FROM Cliente c
WHERE c.habilitado = TRUE
    AND c.documento IS NOT NULL

UNION

SELECT 
    g.nombre,
    g.apellido,
    g.documento,
    'GARANTE' AS tipo_persona,
    IF(g.email LIKE '%@%', g.email, 'email_invalido')
FROM Garante g
WHERE g.habilitado = TRUE
ORDER BY apellido ASC;                                           


-- 6: Clientes que han utilizado un método de pago específico
SELECT 
    c.nombre,
    c.apellido,
    c.documento,
    mp.nombre AS metodo_pago
FROM Cliente c
JOIN Solicitud s ON s.cliente_id = c.cliente_id
JOIN Credito cr ON cr.credito_id = s.credito_id
JOIN Cuota cu ON cu.credito_id = cr.credito_id
JOIN Pago p ON p.cuota_id = cu.cuota_id
JOIN Metodo_Pago mp ON mp.metodo_pago_id = p.metodo_pago_id
WHERE mp.nombre = 'efectivo';

-- 7: Clientes que NO son garantes y además ganan más del promedio
SELECT 
    c.nombre, 
    c.apellido, 
    c.documento
FROM Cliente c
WHERE c.documento NOT IN (
        SELECT documento
        FROM Garante
    )
    AND c.ingresos_dec > (SELECT AVG(ingresos_dec) FROM Cliente);  


-- 8: Clientes con mayor puntaje de riesgo según evaluación
SELECT 
    c.nombre,                                                   
    c.apellido,                                                  
    c.documento,                                                 
    er.puntaje_riesgo                                            
FROM Cliente c
JOIN Solicitud s ON s.cliente_id = c.cliente_id                  
JOIN Evaluacion_Riesgo er ON er.solicitud_id = s.solicitud_id    
WHERE er.puntaje_riesgo IS NOT NULL                          
ORDER BY er.puntaje_riesgo DESC;                                 

-- 9: Clientes con tipo DNI, validando también que no tengan fecha_baja
SELECT nombre, apellido, documento
FROM Cliente
WHERE tipo_doc_id = (
        SELECT tipo_doc_id
        FROM Tipo_Doc
        WHERE nombre = 'DNI'
    )
    AND fecha_baja IS NULL;                                        


-- 10: Ingreso promedio por tipo de documento, filtrando por ingresos mínimos
SELECT 
    td.nombre AS tipo_documento,
    AVG(sub.ingresos_dec) AS ingreso_promedio,
    COUNT(*) AS cantidad_clientes
FROM (
        SELECT tipo_doc_id, ingresos_dec
        FROM Cliente
        WHERE ingresos_dec > 80000
    ) AS sub
JOIN Tipo_Doc td ON td.tipo_doc_id = sub.tipo_doc_id
GROUP BY td.nombre
HAVING ingreso_promedio > 90000;

-- 11 Subconsulta (Muestra cantidad de créditos aprobados) 

SELECT c.cliente_id, c.nombre, c.apellido, (
    SELECT COUNT(*) FROM Solicitud s
    WHERE s.cliente_id = c.cliente_id
    AND s.estado = 'aprobado'
    AND s.credito_id IS NOT NULL
    ) AS cantidad_creditos_aprobados FROM Cliente c;

-- 12 Subconsulta (Clientes que solicitaron créditos por encima del promedio) 

SELECT c.cliente_id, c.nombre,
    c.apellido,
    s.monto
FROM Solicitud s
JOIN Cliente c ON s.cliente_id = c.cliente_id
WHERE s.monto >
    (SELECT AVG(monto) FROM Solicitud);

-- 13 CTE (cuantas solicitudes tiene cada cliente) 

WITH CantSolicitudes AS (
    SELECT 
        cliente_id,
        COUNT(*) AS total_solicitudes
    FROM Solicitud
    GROUP BY cliente_id
)

SELECT 
    c.cliente_id,
    c.nombre,
    c.apellido,
    cs.total_solicitudes
FROM CantSolicitudes cs
JOIN Cliente c ON cs.cliente_id = c.cliente_id
ORDER BY cs.total_solicitudes DESC;

-- 14 CTE (Obtiene todas las cuotas vencidas y luego en la consulta principal mostrarlas ordenadas.)

WITH cuotas_vencidas AS (
    SELECT cuota_id, credito_id, nro_cuota, monto_total, fecha_venc
    FROM cuota
    WHERE fecha_venc < CURDATE()
)
SELECT *
FROM cuotas_vencidas
ORDER BY fecha_venc DESC;

-- 15 HAVING + GROUP BY (Clientes que tienen más de 2 créditos activos y cuya suma total prestada supera $200.000)

SELECT 
    cl.cliente_id,
    cl.nombre,
    cl.apellido,
    COUNT(cr.credito_id) AS cantidad_creditos_activos,
    SUM(cr.monto_ot) AS total_prestado
FROM Credito cr
JOIN Solicitud s ON s.credito_id = cr.credito_id
JOIN Cliente cl ON cl.cliente_id = s.cliente_id
WHERE cr.habilitado = 1   
GROUP BY cl.cliente_id, cl.nombre, cl.apellido
HAVING COUNT(cr.credito_id) > 2
    AND SUM(cr.monto_ot) > 200000;

-- 16 Ventanas (Ranking de clientes con mayor monto de crédito activo)

SELECT
    cl.cliente_id,
    CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
    SUM(cr.monto_ot) AS total_creditos_activos,
    RANK() OVER (ORDER BY SUM(cr.monto_ot) DESC) AS ranking_monto
FROM Cliente cl
JOIN Solicitud s ON s.cliente_id = cl.cliente_id
JOIN Credito cr ON cr.credito_id = s.credito_id
WHERE cr.habilitado = TRUE   
AND s.habilitado = TRUE
GROUP BY cl.cliente_id, cl.nombre, cl.apellido;

-- 17 Crédito más alto del sistema considerando solo el crédito máximo de cada cliente
WITH max_por_cliente AS (
    SELECT
        cl.cliente_id,
        CONCAT(cl.nombre, ' ', cl.apellido) AS cliente,
        MAX(cr.monto_ot) AS credito_max_cliente
    FROM Cliente cl
    JOIN Solicitud s ON s.cliente_id = cl.cliente_id
    JOIN Credito cr ON cr.credito_id = s.credito_id
    WHERE cr.habilitado = TRUE
        AND s.habilitado = TRUE
    GROUP BY cl.cliente_id, cl.nombre, cl.apellido
),
ranking_creditos AS (
    SELECT
        cliente_id,
        cliente,
        credito_max_cliente,
        RANK() OVER (ORDER BY credito_max_cliente DESC) AS pos
    FROM max_por_cliente
)
SELECT *
FROM ranking_creditos
WHERE pos = 1;