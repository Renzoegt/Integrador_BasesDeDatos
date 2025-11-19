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

-- Este índice permite encontrar los datos de una persona introduciendo su número de documento. El impacto que genera es que acelera la identificación de personas por DNI evitando recorrer toda la tabla.
CREATE INDEX idx_persona_documento
ON Persona (documento);


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
