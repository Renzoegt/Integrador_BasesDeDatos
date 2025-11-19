USE creditos;

INSERT INTO cargo (nombre)
VALUES ('Atención al cliente'),
       ('Analista crediticio'),
       ('Ejecutivo de créditos'),
       ('Gerente de sucursal'),
       ('Auditor interno'),
       ('Analista de riesgo');

INSERT INTO metodo_pago (nombre)
VALUES ('Efectivo'),
       ('Transferencia bancaria'),
       ('Tarjeta de débito'),
       ('Tarjeta de crédito'),
       ('Cheque');

INSERT INTO requisitos_prod (cuenta, hist_positivo, tiene_garante)
VALUES (FALSE, TRUE, TRUE),
       (FALSE, TRUE, FALSE),
       (TRUE, TRUE, TRUE);

INSERT INTO producto_finan (limite_cred, nombre, tasa_base, requisitos_prod_id)
VALUES (2500000, 'Préstamo Personal', 0.55, 1),
       (25000000, 'Préstamo Hipotecario', 0.15, 3),
       (30000000, 'Préstamo Empresarial', 0.3, 3),
       (10000000, 'Tarjeta Corporativa', 0.45, 2);

INSERT INTO situacion_econ (nombre, ingreso_min, ingreso_max)
VALUES ('Crítica', 0, 80000),
       ('Mala', 80001, 150000),
       ('Regular', 150001, 300000),
       ('Buena', 300001, 600000),
       ('Muy buena', 600001, 1200000),
       ('Excelente', 1200000, 999999999);

INSERT INTO tipo_doc (nombre)
VALUES ('DNI'),
       ('Pasaporte'),
       ('CUIT/CUIL'),
       ('Documento Extranjero');