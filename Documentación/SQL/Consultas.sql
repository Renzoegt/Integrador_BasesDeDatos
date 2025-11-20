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

-- 11 Subconsulta (Muestra cantidad de créditos aprobados) 
SELECT c.cliente_id, c.nombre, c.apellido, (
    SELECT COUNT(*) FROM Solicitud s
    WHERE s.cliente_id = c.cliente_id
      AND s.estado = 'aprobado'
      AND s.credito_id IS NOT NULL
  ) AS cantidad_creditos_aprobados FROM Cliente c;

-- 12 Subconsulta (Clientes que solicitaron créditos por encima del promedio) CORREGIDO
SELECT c.cliente_id, c.nombre,
    c.apellido,
    s.monto
FROM Solicitud s
JOIN Cliente c ON s.cliente_id = c.cliente_id
WHERE s.monto >
      (SELECT AVG(monto) FROM Solicitud);

-- 13 CTE (cuantas solicitudes tiene cada cliente) CORREGIDO
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