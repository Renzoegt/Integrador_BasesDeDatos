USE creditos;

-- Creación de la tabla cargo solo si no existe
CREATE TABLE IF NOT EXISTS cargo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);

-- Inserción de datos en la tabla cargo
INSERT INTO cargo (nombre)
VALUES ('Atención al cliente'),
       ('Analista crediticio'),
       ('Ejecutivo de créditos'),
       ('Gerente de sucursal'),
       ('Auditor interno'),
       ('Analista de riesgo');

-- Creación de la tabla metodo_pago solo si no existe
CREATE TABLE IF NOT EXISTS metodo_pago (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);

-- Inserción de datos en la tabla metodo_pago
INSERT INTO metodo_pago (nombre)
VALUES ('Efectivo'),
       ('Transferencia bancaria'),
       ('Tarjeta de débito'),
       ('Tarjeta de crédito'),
       ('Cheque');

-- Creación de la tabla requisitos_prod solo si no existe
CREATE TABLE IF NOT EXISTS requisitos_prod (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cuenta BOOLEAN NOT NULL,
    hist_positivo BOOLEAN NOT NULL,
    tiene_garante BOOLEAN NOT NULL
);

-- Inserción de datos en la tabla requisitos_prod
INSERT INTO requisitos_prod (cuenta, hist_positivo, tiene_garante)
VALUES (FALSE, TRUE, TRUE),
       (FALSE, TRUE, FALSE),
       (TRUE, TRUE, TRUE);

-- Creación de la tabla producto_finan solo si no existe
CREATE TABLE IF NOT EXISTS producto_finan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    limite_cred INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    tasa_base INT NOT NULL,
    requisitos_prod_id INT NOT NULL,
    FOREIGN KEY (requisitos_prod_id) REFERENCES requisitos_prod(id)
);

-- Inserción de datos en la tabla producto_finan
INSERT INTO producto_finan (limite_cred, nombre, tasa_base, requisitos_prod_id)
VALUES (2500000, 'Préstamo Personal', 55, 1),
       (25000000, 'Préstamo Hipotecario', 15, 3),
       (30000000, 'Préstamo Empresarial', 30, 3),
       (10000000, 'Tarjeta Corporativa', 45, 2);

-- Creación de la tabla situacion_econ solo si no existe
CREATE TABLE IF NOT EXISTS situacion_econ (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ingreso_min INT NOT NULL,
    ingreso_max INT NOT NULL
);

-- Inserción de datos en la tabla situacion_econ
INSERT INTO situacion_econ (nombre, ingreso_min, ingreso_max)
VALUES ('Crítica', 0, 80000),
       ('Mala', 80001, 150000),
       ('Regular', 150001, 300000),
       ('Buena', 300001, 600000),
       ('Muy buena', 600001, 1200000),
       ('Excelente', 1200000, 999999999);

-- Creación de la tabla tipo_doc solo si no existe
CREATE TABLE IF NOT EXISTS tipo_doc (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);

-- Inserción de datos en la tabla tipo_doc
INSERT INTO tipo_doc (nombre)
VALUES ('DNI'),
       ('Pasaporte'),
       ('CUIT/CUIL'),
       ('Documento Extranjero');

-- Creación de la tabla campania_prom solo si no existe
CREATE TABLE IF NOT EXISTS campania_prom (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tasa_prom DECIMAL(5,2) NOT NULL,
    vigencia DATE NOT NULL
);

-- Inserción de datos en la tabla campania_prom
INSERT INTO campania_prom (tasa_prom, vigencia)
VALUES (18.50, '2026-03-31'),
       (14.75, '2026-05-15'),
       (9.9, '2026-09-30'),
       (0, '2026-04-30');

-- Creación de la tabla persona solo si no existe
CREATE TABLE IF NOT EXISTS persona (
    id INT AUTO_INCREMENT PRIMARY KEY,
    documento VARCHAR(20) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    tipo_doc_id INT NOT NULL,
    FOREIGN KEY (tipo_doc_id) REFERENCES tipo_doc(id)
);

-- Inserción de datos en la tabla persona
INSERT INTO persona (documento, nombre, apellido, fecha_nacimiento, tipo_doc_id)
VALUES 
('12345678', 'Juan', 'Pérez', '1985-05-20', 1),
('87654321', 'Ana', 'Gómez', '1990-10-15', 2),
('45678912', 'Carlos', 'López', '1978-03-22', 1),
('78912345', 'María', 'Rodríguez', '1995-07-30', 3),
('32165498', 'Luis', 'Martínez', '1980-12-11', 1),
('65498732', 'Laura', 'Fernández', '1988-04-25', 2),
('98765432', 'Pedro', 'García', '1975-09-10', 1),
('12378945', 'Sofía', 'Hernández', '1992-06-18', 3),
('45612378', 'Diego', 'Torres', '1983-03-05', 1),
('78945612', 'Valeria', 'Giménez', '1997-11-22', 2),
('11111111', 'Nombre1', 'Apellido1', '1990-01-01', 1),
('22222222', 'Nombre2', 'Apellido2', '1991-02-02', 2),
('33333333', 'Nombre3', 'Apellido3', '1992-03-03', 3),
('44444444', 'Nombre4', 'Apellido4', '1993-04-04', 1),
('55555555', 'Nombre5', 'Apellido5', '1994-05-05', 2),
('66666666', 'Nombre6', 'Apellido6', '1995-06-06', 3),
('77777777', 'Nombre7', 'Apellido7', '1996-07-07', 1),
('88888888', 'Nombre8', 'Apellido8', '1997-08-08', 2),
('99999999', 'Nombre9', 'Apellido9', '1998-09-09', 3),
('10101010', 'Nombre10', 'Apellido10', '1999-10-10', 1),
('11121314', 'Nombre11', 'Apellido11', '2000-11-11', 2),
('12131415', 'Nombre12', 'Apellido12', '2001-12-12', 3),
('13141516', 'Nombre13', 'Apellido13', '2002-01-13', 1),
('14161718', 'Nombre14', 'Apellido14', '2003-02-14', 2),
('15181920', 'Nombre15', 'Apellido15', '2004-03-15', 3),
('16192021', 'Nombre16', 'Apellido16', '2005-04-16', 1),
('17102122', 'Nombre17', 'Apellido17', '2006-05-17', 2),
('18112223', 'Nombre18', 'Apellido18', '2007-06-18', 3),
('19223324', 'Nombre19', 'Apellido19', '2008-07-19', 1),
('20234425', 'Nombre20', 'Apellido20', '2009-08-20', 2),
('21242526', 'Nombre21', 'Apellido21', '2010-09-21', 3),
('22253627', 'Nombre22', 'Apellido22', '2011-10-22', 1),
('23263728', 'Nombre23', 'Apellido23', '2012-11-23', 2),
('24273829', 'Nombre24', 'Apellido24', '2013-12-24', 3),
('25283930', 'Nombre25', 'Apellido25', '2014-01-25', 1),
('26294031', 'Nombre26', 'Apellido26', '2015-02-26', 2),
('27204132', 'Nombre27', 'Apellido27', '2016-03-27', 3),
('28214233', 'Nombre28', 'Apellido28', '2017-04-28', 1),
('29224334', 'Nombre29', 'Apellido29', '2018-05-29', 2),
('30334435', 'Nombre30', 'Apellido30', '2019-06-30', 3),
('31344536', 'Nombre31', 'Apellido31', '2020-07-01', 1),
('32354637', 'Nombre32', 'Apellido32', '2021-08-02', 2),
('33364738', 'Nombre33', 'Apellido33', '2022-09-03', 3),
('34374839', 'Nombre34', 'Apellido34', '2023-10-04', 1),
('35384940', 'Nombre35', 'Apellido35', '2024-11-05', 2),
('36395041', 'Nombre36', 'Apellido36', '2025-12-06', 3),
('37405142', 'Nombre37', 'Apellido37', '2026-01-07', 1),
('38415243', 'Nombre38', 'Apellido38', '2027-02-08', 2),
('39425344', 'Nombre39', 'Apellido39', '2028-03-09', 3),
('40435445', 'Nombre40', 'Apellido40', '2029-04-10', 1),
('41445546', 'Nombre41', 'Apellido41', '2030-05-11', 2),
('42455647', 'Nombre42', 'Apellido42', '2031-06-12', 3),
('43465748', 'Nombre43', 'Apellido43', '2032-07-13', 1),
('44475849', 'Nombre44', 'Apellido44', '2033-08-14', 2),
('45485950', 'Nombre45', 'Apellido45', '2034-09-15', 3),
('46495051', 'Nombre46', 'Apellido46', '2035-10-16', 1),
('47505152', 'Nombre47', 'Apellido47', '2036-11-17', 2),
('48515253', 'Nombre48', 'Apellido48', '2037-12-18', 3),
('49525354', 'Nombre49', 'Apellido49', '2038-01-19', 1),
('50535455', 'Nombre50', 'Apellido50', '2039-02-20', 2),
('51545556', 'Nombre51', 'Apellido51', '2040-03-21', 3),
('52555657', 'Nombre52', 'Apellido52', '2041-04-22', 1),
('53565758', 'Nombre53', 'Apellido53', '2042-05-23', 2),
('54575859', 'Nombre54', 'Apellido54', '2043-06-24', 3),
('55585960', 'Nombre55', 'Apellido55', '2044-07-25', 1),
('56596061', 'Nombre56', 'Apellido56', '2045-08-26', 2),
('57606162', 'Nombre57', 'Apellido57', '2046-09-27', 3),
('58616263', 'Nombre58', 'Apellido58', '2047-10-28', 1),
('59626364', 'Nombre59', 'Apellido59', '2048-11-29', 2),
('60636465', 'Nombre60', 'Apellido60', '2049-12-30', 3);

-- Creación de la tabla cliente solo si no existe
CREATE TABLE IF NOT EXISTS cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sit_econ_id INT NOT NULL,
    ingresos_dec INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    documento VARCHAR(20) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    tipo_doc_id INT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    es_juridica BOOLEAN NOT NULL,
    FOREIGN KEY (sit_econ_id) REFERENCES situacion_econ(id),
    FOREIGN KEY (tipo_doc_id) REFERENCES tipo_doc(id)
);

-- Inserción de datos en la tabla cliente (bloques más pequeños)
INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(1, 50000, 'Juan', 'Pérez', '12345678', 'Calle Falsa 123', 1, '123456789', 'juan.perez@example.com', FALSE),
(2, 120000, 'Ana', 'Gómez', '87654321', 'Avenida Siempreviva 456', 2, '987654321', 'ana.gomez@example.com', FALSE);

INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(3, 250000, 'Carlos', 'López', '45678912', 'Boulevard Central 789', 1, '456789123', 'carlos.lopez@example.com', FALSE),
(4, 400000, 'María', 'Rodríguez', '78912345', 'Plaza Mayor 321', 3, '789123456', 'maria.rodriguez@example.com', FALSE);

INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(5, 600000, 'Luis', 'Martínez', '32165498', 'Calle Principal 654', 1, '321654987', 'luis.martinez@example.com', FALSE),
(6, 800000, 'Laura', 'Fernández', '65498732', 'Avenida Norte 987', 2, '654987321', 'laura.fernandez@example.com', FALSE),
(7, 1000000, 'Pedro', 'García', '98765432', 'Calle Sur 111', 1, '987654321', 'pedro.garcia@example.com', FALSE);

INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(1, 55000, 'Juan', 'Pérez', '22334455', 'Calle Falsa 456', 1, '123456780', 'juan.perez2@example.com', FALSE),
(2, 130000, 'Ana', 'Gómez', '33445566', 'Avenida Siempreviva 789', 2, '987654322', 'ana.gomez2@example.com', FALSE),
(3, 260000, 'Carlos', 'López', '44556677', 'Boulevard Central 890', 1, '456789124', 'carlos.lopez2@example.com', FALSE),
(4, 410000, 'María', 'Rodríguez', '55667788', 'Plaza Mayor 432', 3, '789123457', 'maria.rodriguez2@example.com', FALSE),
(5, 610000, 'Luis', 'Martínez', '66778899', 'Calle Principal 765', 1, '321654988', 'luis.martinez2@example.com', FALSE),
(6, 810000, 'Laura', 'Fernández', '77889900', 'Avenida Norte 098', 2, '654987322', 'laura.fernandez2@example.com', FALSE),
(7, 1100000, 'Pedro', 'García', '88990011', 'Calle Sur 222', 1, '987654322', 'pedro.garcia2@example.com', FALSE);

INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(1, 60000, 'Juan', 'Pérez', '33445566', 'Calle Falsa 789', 1, '123456781', 'juan.perez3@example.com', FALSE),
(2, 140000, 'Ana', 'Gómez', '44556677', 'Avenida Siempreviva 012', 2, '987654323', 'ana.gomez3@example.com', FALSE),
(3, 270000, 'Carlos', 'López', '55667788', 'Boulevard Central 901', 1, '456789125', 'carlos.lopez3@example.com', FALSE),
(4, 420000, 'María', 'Rodríguez', '66778899', 'Plaza Mayor 543', 3, '789123458', 'maria.rodriguez3@example.com', FALSE),
(5, 620000, 'Luis', 'Martínez', '77889900', 'Calle Principal 876', 1, '321654989', 'luis.martinez3@example.com', FALSE),
(6, 820000, 'Laura', 'Fernández', '88990011', 'Avenida Norte 109', 2, '654987323', 'laura.fernandez3@example.com', FALSE),
(7, 1200000, 'Pedro', 'García', '99001122', 'Calle Sur 333', 1, '987654323', 'pedro.garcia3@example.com', FALSE);

INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(1, 65000, 'Juan', 'Pérez', '44556677', 'Calle Falsa 012', 1, '123456782', 'juan.perez4@example.com', FALSE),
(2, 150000, 'Ana', 'Gómez', '55667788', 'Avenida Siempreviva 123', 2, '987654324', 'ana.gomez4@example.com', FALSE),
(3, 280000, 'Carlos', 'López', '66778899', 'Boulevard Central 012', 1, '456789126', 'carlos.lopez4@example.com', FALSE),
(4, 430000, 'María', 'Rodríguez', '77889900', 'Plaza Mayor 654', 3, '789123459', 'maria.rodriguez4@example.com', FALSE),
(5, 630000, 'Luis', 'Martínez', '88990011', 'Calle Principal 109', 1, '321654990', 'luis.martinez4@example.com', FALSE),
(6, 830000, 'Laura', 'Fernández', '99001122', 'Avenida Norte 210', 2, '654987324', 'laura.fernandez4@example.com', FALSE),
(7, 1300000, 'Pedro', 'García', '10112233', 'Calle Sur 444', 1, '987654324', 'pedro.garcia4@example.com', FALSE);

INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(1, 70000, 'Juan', 'Pérez', '55667788', 'Calle Falsa 123', 1, '123456783', 'juan.perez5@example.com', FALSE),
(2, 160000, 'Ana', 'Gómez', '66778899', 'Avenida Siempreviva 234', 2, '987654325', 'ana.gomez5@example.com', FALSE),
(3, 290000, 'Carlos', 'López', '77889900', 'Boulevard Central 123', 1, '456789127', 'carlos.lopez5@example.com', FALSE),
(4, 440000, 'María', 'Rodríguez', '88990011', 'Plaza Mayor 765', 3, '789123460', 'maria.rodriguez5@example.com', FALSE),
(5, 640000, 'Luis', 'Martínez', '99001122', 'Calle Principal 098', 1, '321654991', 'luis.martinez5@example.com', FALSE),
(6, 840000, 'Laura', 'Fernández', '10112233', 'Avenida Norte 321', 2, '654987325', 'laura.fernandez5@example.com', FALSE),
(7, 1400000, 'Pedro', 'García', '11223344', 'Calle Sur 555', 1, '987654325', 'pedro.garcia5@example.com', FALSE);

INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(1, 75000, 'Juan', 'Pérez', '66778899', 'Calle Falsa 234', 1, '123456784', 'juan.perez6@example.com', FALSE),
(2, 170000, 'Ana', 'Gómez', '77889900', 'Avenida Siempreviva 345', 2, '987654326', 'ana.gomez6@example.com', FALSE),
(3, 300000, 'Carlos', 'López', '88990011', 'Boulevard Central 234', 1, '456789128', 'carlos.lopez6@example.com', FALSE),
(4, 450000, 'María', 'Rodríguez', '99001122', 'Plaza Mayor 876', 3, '789123461', 'maria.rodriguez6@example.com', FALSE),
(5, 650000, 'Luis', 'Martínez', '10112233', 'Calle Principal 109', 1, '321654992', 'luis.martinez6@example.com', FALSE),
(6, 850000, 'Laura', 'Fernández', '11223344', 'Avenida Norte 432', 2, '654987326', 'laura.fernandez6@example.com', FALSE),
(7, 1500000, 'Pedro', 'García', '22334455', 'Calle Sur 666', 1, '987654326', 'pedro.garcia6@example.com', FALSE);

INSERT INTO cliente (sit_econ_id, ingresos_dec, nombre, apellido, documento, direccion, tipo_doc_id, telefono, email, es_juridica)
VALUES 
(1, 80000, 'Juan', 'Pérez', '77889900', 'Calle Falsa 345', 1, '123456785', 'juan.perez7@example.com', FALSE),
(2, 180000, 'Ana', 'Gómez', '88990011', 'Avenida Siempreviva 456', 2, '987654327', 'ana.gomez7@example.com', FALSE),
(3, 310000, 'Carlos', 'López', '99001122', 'Boulevard Central 345', 1, '456789129', 'carlos.lopez7@example.com', FALSE),
(4, 460000, 'María', 'Rodríguez', '10112233', 'Plaza Mayor 987', 3, '789123462', 'maria.rodriguez7@example.com', FALSE),
(5, 660000, 'Luis', 'Martínez', '11223344', 'Calle Principal 210', 1, '321654993', 'luis.martinez7@example.com', FALSE),
(6, 860000, 'Laura', 'Fernández', '22334455', 'Avenida Norte 543', 2, '654987327', 'laura.fernandez7@example.com', FALSE),
(7, 1, 'Juan', 'Pérez', '12345678', 'Calle Falsa 123', 1, '123456789', 'juan.perez@example.com', FALSE),
(7, 2, 'Ana', 'Gómez', '87654321', 'Avenida Siempreviva 456', 2, '987654321', 'ana.gomez@example.com', FALSE),
(7, 3, 'Carlos', 'López', '45678912', 'Boulevard Central 789', 1, '456789123', 'carlos.lopez@example.com', FALSE),
(7, 4, 'María', 'Rodríguez', '78912345', 'Plaza Mayor 321', 3, '789123456', 'maria.rodriguez@example.com', FALSE),
(7, 5, 'Luis', 'Martínez', '32165498', 'Calle Principal 654', 1, '321654987', 'luis.martinez@example.com', FALSE),
(7, 6, 'Laura', 'Fernández', '65498732', 'Avenida Norte 987', 2, '654987321', 'laura.fernandez@example.com', FALSE);