USE creditos;

-- Verificación de cantidad de registros por tabla
SELECT 'cargo' as tabla, COUNT(*) as cantidad FROM cargo
UNION ALL
SELECT 'metodo_pago', COUNT(*) FROM metodo_pago
UNION ALL
SELECT 'requisitos_prod', COUNT(*) FROM requisitos_prod
UNION ALL
SELECT 'producto_finan', COUNT(*) FROM producto_finan
UNION ALL
SELECT 'situacion_econ', COUNT(*) FROM situacion_econ
UNION ALL
SELECT 'tipo_doc', COUNT(*) FROM tipo_doc
UNION ALL
SELECT 'campania_prom', COUNT(*) FROM campania_prom
UNION ALL
SELECT 'persona', COUNT(*) FROM persona
UNION ALL
SELECT 'cliente', COUNT(*) FROM cliente;