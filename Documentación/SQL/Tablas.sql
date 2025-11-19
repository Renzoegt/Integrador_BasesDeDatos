CREATE DATABASE creditos;

USE creditos;

CREATE TABLE `Persona` (
  `persona_id` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(30),
  `apellido` varchar(30),
  `documento` integer,
  `direccion` varchar(255),
  `tipo_doc_id` integer,
  `telefono` varchar(20),
  `email` varchar(40),
  `es_juridica` boolean,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Tipo_Doc` (
  `tipo_doc_id` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(255),
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Empleado` (
  `empleado_id` integer PRIMARY KEY AUTO_INCREMENT,
  `sucursal_id` integer,
  `cargo_id` integer,
  `persona_id` integer UNIQUE
);

CREATE TABLE `Cargo` (
  `cargo_id` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(20),
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Cliente` (
  `cliente_id` integer PRIMARY KEY AUTO_INCREMENT,
  `sit_econ_id` integer,
  `ingresos_dec` integer,
  `persona_id` integer UNIQUE,
  CONSTRAINT `check_ingresos_dec` CHECK (ingresos_dec >= 0)
);

CREATE TABLE `Situacion_Econ` (
  `situacion_econ_id` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(20),
  `ingreso_min` integer,
  `ingreso_max` integer,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Garante` (
  `garante_id` integer PRIMARY KEY AUTO_INCREMENT,
  `relacion_cliente` varchar(255),
  `persona_id` integer UNIQUE
);

CREATE TABLE `Sucursal` (
  `sucursal_id` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(20),
  `email` varchar(40),
  `telefono` varchar(20),
  `direccion` varchar(255),
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Solicitud` (
  `solicitud_id` integer PRIMARY KEY AUTO_INCREMENT,
  `motivo` varchar(50),
  `monto` integer,
  `estado` varchar(20),
  `cliente_id` integer,
  `producto_finan_id` integer,
  `credito_id` integer,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30),
  CONSTRAINT `check_estado` CHECK (estado IN ('aprobado', 'rechazado', 'revision'))
);

CREATE TABLE `Solicitud_Garante` (
  `solicitud_garante_id` integer PRIMARY KEY AUTO_INCREMENT,
  `solicitud_id` integer,
  `garante_id` integer
);

CREATE TABLE `Producto_Finan` (
  `producto_finan_id` integer PRIMARY KEY AUTO_INCREMENT,
  `limite_cred` integer,
  `nombre` varchar(20),
  `tasa_base` decimal(4,2),
  `requisitos_prod_id` integer,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Hist_Tasas` (
  `hist_tasas_id` integer PRIMARY KEY AUTO_INCREMENT,
  `producto_finan_id` integer,
  `tasa_vigente` decimal(4,2),
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Requisitos_Prod` (
  `requisitos_prod_id` integer PRIMARY KEY AUTO_INCREMENT,
  `cuenta` boolean,
  `hist_positivo` boolean,
  `tiene_garante` boolean,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Credito` (
  `credito_id` integer PRIMARY KEY AUTO_INCREMENT,
  `monto_ot` integer,
  `tasa_int` decimal(4,2),
  `fecha_fin` date,
  `plazo_dias` integer,
  `credito_refinanciado_id` integer,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Evaluacion_Riesgo` (
  `evaluacion_riesgo_id` integer PRIMARY KEY AUTO_INCREMENT,
  `puntaje_riesgo` integer,
  `estado` varchar(20),
  `solicitud_id` integer,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Evaluacion_Seg` (
  `evaluacion_seg_id` integer PRIMARY KEY AUTO_INCREMENT,
  `comportamiento_pago` varchar(20),
  `nivel_endeudamiento` integer,
  `cliente_id` integer,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Cuota` (
  `cuota_id` integer PRIMARY KEY AUTO_INCREMENT,
  `credito_id` integer,
  `nro_cuota` integer,
  `monto_total` integer,
  `estado` varchar(20),
  `fecha_venc` date,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30),
  CONSTRAINT `check_estado` CHECK (estado IN ('pendiente', 'pagado'))
);

CREATE TABLE `Pago` (
  `pago_id` integer PRIMARY KEY AUTO_INCREMENT,
  `cuota_id` integer,
  `dias_demora` integer,
  `pena_mora` decimal(9,2),
  `monto_pago` decimal(9,2),
  `metodo_pago_id` integer,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Metodo_Pago` (
  `metodo_pago_id` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(30),
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Campania_Prom` (
  `campania_prom_id` integer PRIMARY KEY AUTO_INCREMENT,
  `tasa_prom` decimal(4,2),
  `vigencia` date,
  `habilitado` boolean DEFAULT TRUE,
  `fecha_alta` date DEFAULT CURDATE(),
  `fecha_baja` date,
  `fecha_mod` date,
  `usuario_alta` varchar(30),
  `usuario_mod` varchar(30)
);

CREATE TABLE `Campania_Cliente` (
  `campania_cliente_id` integer PRIMARY KEY AUTO_INCREMENT,
  `campana_prom_id` integer,
  `cliente_id` integer
);

CREATE TABLE `Campania_Producto` (
  `campania_producto_id` integer PRIMARY KEY AUTO_INCREMENT,
  `campania_prom_id` integer,
  `producto_finan_id` integer
);

ALTER TABLE `Persona` ADD FOREIGN KEY (`tipo_doc_id`) REFERENCES `Tipo_Doc` (`tipo_doc_id`);

ALTER TABLE `Empleado` ADD FOREIGN KEY (`sucursal_id`) REFERENCES `Sucursal` (`sucursal_id`);

ALTER TABLE `Empleado` ADD FOREIGN KEY (`cargo_id`) REFERENCES `Cargo` (`cargo_id`);

ALTER TABLE `Empleado` ADD FOREIGN KEY (`persona_id`) REFERENCES `Persona` (`persona_id`);

ALTER TABLE `Cliente` ADD FOREIGN KEY (`sit_econ_id`) REFERENCES `Situacion_Econ` (`situacion_econ_id`);

ALTER TABLE `Cliente` ADD FOREIGN KEY (`persona_id`) REFERENCES `Persona` (`persona_id`);

ALTER TABLE `Garante` ADD FOREIGN KEY (`persona_id`) REFERENCES `Persona` (`persona_id`);

ALTER TABLE `Solicitud` ADD FOREIGN KEY (`cliente_id`) REFERENCES `Cliente` (`cliente_id`);

ALTER TABLE `Solicitud` ADD FOREIGN KEY (`producto_finan_id`) REFERENCES `Producto_Finan` (`producto_finan_id`);

ALTER TABLE `Solicitud` ADD FOREIGN KEY (`credito_id`) REFERENCES `Credito` (`credito_id`);

ALTER TABLE `Solicitud_Garante` ADD FOREIGN KEY (`solicitud_id`) REFERENCES `Solicitud` (`solicitud_id`);

ALTER TABLE `Solicitud_Garante` ADD FOREIGN KEY (`garante_id`) REFERENCES `Garante` (`garante_id`);

ALTER TABLE `Producto_Finan` ADD FOREIGN KEY (`requisitos_prod_id`) REFERENCES `Requisitos_Prod` (`requisitos_prod_id`);

ALTER TABLE `Hist_Tasas` ADD FOREIGN KEY (`producto_finan_id`) REFERENCES `Producto_Finan` (`producto_finan_id`);

ALTER TABLE `Credito` ADD FOREIGN KEY (`credito_refinanciado_id`) REFERENCES `Credito` (`credito_id`);

ALTER TABLE `Evaluacion_Riesgo` ADD FOREIGN KEY (`solicitud_id`) REFERENCES `Solicitud` (`solicitud_id`);

ALTER TABLE `Evaluacion_Seg` ADD FOREIGN KEY (`cliente_id`) REFERENCES `Cliente` (`cliente_id`);

ALTER TABLE `Cuota` ADD FOREIGN KEY (`credito_id`) REFERENCES `Credito` (`credito_id`);

ALTER TABLE `Pago` ADD FOREIGN KEY (`cuota_id`) REFERENCES `Cuota` (`cuota_id`);

ALTER TABLE `Pago` ADD FOREIGN KEY (`metodo_pago_id`) REFERENCES `Metodo_Pago` (`metodo_pago_id`);

ALTER TABLE `Campania_Cliente` ADD FOREIGN KEY (`campana_prom_id`) REFERENCES `Campania_Prom` (`campania_prom_id`);

ALTER TABLE `Campania_Cliente` ADD FOREIGN KEY (`cliente_id`) REFERENCES `Cliente` (`cliente_id`);

ALTER TABLE `Campania_Producto` ADD FOREIGN KEY (`campania_prom_id`) REFERENCES `Campania_Prom` (`campania_prom_id`);

ALTER TABLE `Campania_Producto` ADD FOREIGN KEY (`producto_finan_id`) REFERENCES `Producto_Finan` (`producto_finan_id`);
