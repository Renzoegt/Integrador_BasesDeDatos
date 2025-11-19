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
VALUES (2500000, 'Préstamo Personal', 55, 1),
       (25000000, 'Préstamo Hipotecario', 15, 3),
       (30000000, 'Préstamo Empresarial', 30, 3),
       (10000000, 'Tarjeta Corporativa', 45, 2);

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

INSERT INTO campania_prom (tasa_prom, vigencia)
VALUES (18.50, '2026-03-31'),
       (14.75, '2026-05-15'),
       (9.9, '2026-09-30'),
       (0, '2026-04-30');