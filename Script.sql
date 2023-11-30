-- Script asociado a la Actividad 5.3

-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS compania_aerea_inm;

-- Conexión a las base de datos.
use compania_aerea_inm;

/* Borrado de todas las tablas */
DROP TABLE IF EXISTS T_PASAJERO_VUELO;
DROP TABLE IF EXISTS T_TELEFONO_PASAJERO;
DROP TABLE IF EXISTS T_PASAJERO;
DROP TABLE IF EXISTS T_TRIPULANTE_VUELO;
DROP TABLE IF EXISTS T_VUELO;
DROP TABLE IF EXISTS AVION;
DROP TABLE IF EXISTS T_TRIPULANTE;
DROP TABLE IF EXISTS T_TELEFONO_TRABAJADOR;
DROP TABLE IF EXISTS T_TRABAJADOR;
DROP TABLE IF EXISTS T_CATEGORIA;

-- Creación de tablas
-- TABLA T_PASAJERO
CREATE TABLE IF NOT EXISTS T_PASAJERO(
  DNI CHAR(9) NOT NULL PRIMARY KEY,
  Nombre VARCHAR(50) NOT NULL,
  Apellidos VARCHAR(150) NOT NULL
);

-- TABLA T_TELEFONO_PASAJERO
CREATE TABLE IF NOT EXISTS T_TELEFONO_PASAJERO(
  DNI CHAR(9) NOT NULL,
  Telefono INT NOT NULL,
  PRIMARY KEY (DNI, Telefono),
  CONSTRAINT FK_TELPASAJERO_PASAJERO
    FOREIGN KEY (DNI) REFERENCES T_PASAJERO(DNI)
);

-- TABLA AVION
CREATE TABLE IF NOT EXISTS T_AVION(
  Matricula VARCHAR(10) NOT NULL PRIMARY KEY,
  Fabricante VARCHAR(250) NOT NULL,
  Modelo VARCHAR(250) NOT NULL,
  Capacidad INT NOT NULL,
  Autonomia INT NOT NULL
);

-- TABLA T_VUELO
CREATE TABLE IF NOT EXISTS T_VUELO(
  IdVuelo INT NOT NULL PRIMARY KEY,
  FechaInicio DATE,
  AeropuertoOrigen VARCHAR(50) NOT NULL,
  AeropuertoDestino VARCHAR(50) NOT NULL,
  Matricula VARCHAR(10) NOT NULL ,
  CONSTRAINT FK_VUELO_AVION
    FOREIGN KEY (Matricula) REFERENCES T_AVION(Matricula)
);

-- TABLA T_PASAJERO_VUELO
CREATE TABLE IF NOT EXISTS T_PASAJERO_VUELO(
  DNI CHAR(9) NOT NULL,
  IdVuelo INT NOT NULL,
  Clase ENUM ('Business', 'Primera', 'Turista'),
  Asiento SMALLINT NOT NULL,
  PRIMARY KEY (DNI, IdVuelo),
  CONSTRAINT FK_PASAJEROVUELO_PASAJERO
    FOREIGN KEY (DNI) REFERENCES T_PASAJERO (DNI),
  CONSTRAINT FKPASAJEROVUELO_VUELO
    FOREIGN KEY (IdVuelo) REFERENCES T_VUELO(IdVuelo)
);

-- TABLA T_CATEGORIA
CREATE TABLE IF NOT EXISTS T_CATEGORIA(
  IdCategoria INT NOT NULL PRIMARY KEY,
  Nombre VARCHAR(50) NOT NULL
);

-- TABLA T_TRABAJADOR
CREATE TABLE IF NOT EXISTS T_TRABAJADOR(
  IdTrabajador INT NOT NULL PRIMARY KEY,
  Nombre VARCHAR(50) NOT NULL,
  Apellido1 VARCHAR(100) NOT NULL,
  Apellido2 VARCHAR(100) NULL,
  IdCategoria INT NOT NULL,
  CONSTRAINT FK_TRABAJADOR_CATEGORIA
     FOREIGN KEY (IdCategoria) REFERENCES T_CATEGORIA(IdCategoria)
);

-- TABLA T_TELEFONO_TRABAJADOR
CREATE TABLE IF NOT EXISTS T_TELEFONO_TRABAJADOR(
  IdTrabajador INT NOT NULL,
  Telefono INT NOT NULL,
  PRIMARY KEY (IdTrabajador, Telefono),
  CONSTRAINT FK_TELTRABAJADOR_TRABAJADOR
    FOREIGN KEY (IdTrabajador) REFERENCES T_TRABAJADOR(IdTrabajador)
);



-- TABLA T_TRIPULANTE
CREATE TABLE IF NOT EXISTS T_TRIPULANTE (
  IdTripulante INT NOT NULL PRIMARY KEY,
  FechaInicio DATE NOT NULL,
  IdTrabajador INT NOT NULL UNIQUE,
  CONSTRAINT FK_TRIPULANTE_TRABAJADOR
    FOREIGN KEY(IdTrabajador) REFERENCES T_TRABAJADOR(IdTrabajador)
);

-- TABLA T_TRIPULANTE_VUELO
CREATE TABLE IF NOT EXISTS T_TRIPULANTE_VUELO(
  IdTripulante INT NOT NULL,
  IdVuelo INT NOT NULL,
  Puesto VARCHAR(50) NOT NULL,
  PRIMARY KEY(idTripulante, IdVuelo),
  CONSTRAINT FK_TRIPULANTEVUELO_TRIPULANTE
    FOREIGN KEY (IdTripulante) REFERENCES T_TRIPULANTE (IdTripulante),
  CONSTRAINT FK_TRIPULANTEVUELO_VUELO
    FOREIGN KEY (IdVuelo) REFERENCES T_VUELO(IdVuelo)
);


-- Cambios asociados a la actividad 5.4
-- La base de datos tendrá como como “conjunto de caracteres” utf8mb4 y utf8mb4_unicode_ci  como “cotejamiento”. 
ALTER DATABASE compania_aerea_inm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- Se desea que la información sobre la capacidad del avión sea un campo numérico sin signo y con valor máximo de 450
ALTER TABLE T_AVION MODIFY COLUMN Capacidad SMALLINT UNSIGNED NOT NULL;
ALTER TABLE T_AVION ADD CONSTRAINT CHK_Capacidad CHECK(Capacidad<=480);


/*
 Se desea que la información sobre la autonomía de vuelo sean un campo numérico sin signo, 
con un valor máximo de 48 horas. Además, se desea el campo autonomía de vuelo que sea opcional.
*/
ALTER TABLE T_AVION MODIFY Autonomia TINYINT UNSIGNED NULL;
ALTER TABLE T_AVION ADD CONSTRAINT CHK_Autonomia CHECK(Autonomia <=48);


-- De los trabajadores se desea conocer los apellidos, siendo el segundo de ellos opcional.
-- No hay que hacer nada. Así está en la activididad 5.3


-- Se validará que el la columna asociado al asiento que ocupa el pasajero sea mayor que 0 (usando la restricción CHECK).
ALTER TABLE T_PASAJERO_VUELO ADD CONSTRAINT CHK_Asiento CHECK(Asiento>0); 

/*
Del tipo de la clase del asiento que ocupa el pasajero (turista, primera o business), 
se quiere almacenar información del identificador del Tipo;
 este identificador será un campo numérico autoincremental. 
*/
-- 1º Crear Tabla T_CLASE
CREATE TABLE IF NOT EXISTS T_CLASE(
  IdClase TINYINT UNSIGNED NOT NULL, -- Identificador con valores positivos (pocos valores)
  Nombre VARCHAR(250) NOT NULL,
  PRIMARY KEY(IdClase)
);
-- 2º Crear una columna IdClase en la tabla T_PASAJERO_VUELO
ALTER TABLE T_PASAJERO_VUELO ADD COLUMN IdClase TINYINT UNSIGNED NOT NULL;
-- 3º Se Crear una restricción de tipo FOREIGN KEY sobre T_CLASE
ALTER TABLE T_PASAJERO_VUELO ADD CONSTRAINT FK_PASAJEROVUELO_CLASE
  FOREIGN KEY (IdClase) REFERENCES T_CLASE (IdClase);
-- 4º Se elimina la columna Clase
ALTER TABLE T_PASAJERO_VUELO DROP COLUMN Clase;


-- Se cambiará el nombre de la tabla asociada a la entidad AVION al nombre T_AEROPLANO.
-- Renombrar la tabla T_AVION
ALTER TABLE T_AVION RENAME T_AEROPLANO;
-- Renombrar en T_VUELO la FK asociada a AVION (Matricula). Renombrar = Borar (FK_VUELO_AVION) + Crear (FK_VUELO_AEROPLANO)
ALTER TABLE T_VUELO DROP CONSTRAINT FK_VUELO_AVION;
ALTER TABLE T_VUELO ADD CONSTRAINT FK_VUELO_AEROPLANO
  FOREIGN KEY (Matricula) REFERENCES T_AEROPLANO (Matricula);

/* Pruebas restricciones
INSERT INTO T_AEROPLANO VALUES('000012R', 'AIRBUS', 'Airbus A318', '550', '480');
INSERT INTO T_VUELO VALUES (1, NULL, 'Madrid', 'Barcelona', '000012R');
INSERT INTO T_PASAJERO VALUES ('13256354K', 'Adela', 'Sánchez Romina');
INSERT INTO T_CLASE (1, 'Business');
INSERT INTO T_PASAJERO_VUELO VALUES ('13256354K', 1, -6, 1);
*/
