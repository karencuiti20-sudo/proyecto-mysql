CREATE DATABASE computa;
USE computa;

-- ===========================================
-- TABLA USUARIOS
-- ===========================================
CREATE TABLE Usuarios (
    id_usuario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ci INT NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasenia VARCHAR(255) NOT NULL,      -- hash, no texto plano
    foto_perfil BLOB,
    estado VARCHAR(50) NOT NULL DEFAULT 'Activo'
);

-- ===========================================
-- TABLA TELEFONO
-- ===========================================
CREATE TABLE Telefono (
    id_telefono INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL,
    fk_id_usuario INT NOT NULL,
    CONSTRAINT fk_telefono_usuario
        FOREIGN KEY (fk_id_usuario) REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

-- ===========================================
-- TABLAS DE ROLES (cada una es 1 a 1 con Usuarios)
-- ===========================================
CREATE TABLE Estudiantes (
    id_estudiante INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fk_id_usuario INT NOT NULL UNIQUE,
    CONSTRAINT fk_usuarios_estudiantes
        FOREIGN KEY (fk_id_usuario) REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

CREATE TABLE Docentes (
    id_docentes INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fk_id_usuario INT NOT NULL UNIQUE,
    CONSTRAINT fk_usuarios_docentes
        FOREIGN KEY (fk_id_usuario) REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

CREATE TABLE Funcionarios (
    id_funcionario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fk_id_usuario INT NOT NULL UNIQUE,
    CONSTRAINT fk_usuarios_funcionarios
        FOREIGN KEY (fk_id_usuario) REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

-- ===========================================
-- TABLA CURSOS
-- ===========================================
CREATE TABLE Cursos (
    id_cursos INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(1000),
    tipo_cursos VARCHAR(50) NOT NULL
);

-- ===========================================
-- TABLA EQUIPOS
-- ===========================================
CREATE TABLE Equipos (
    id_pc INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    observaciones VARCHAR(100),
    estado VARCHAR(50) NOT NULL DEFAULT 'Disponible',
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    inventario VARCHAR(50) NOT NULL UNIQUE
);

DESCRIBE Prestamos;
-- ===========================================
-- TABLA PRESTAMOS
-- ===========================================
CREATE TABLE Prestamos (
    id_prestamo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    observaciones VARCHAR(100),
    estado VARCHAR(50) NOT NULL,
    fecha_prevista TIMESTAMP NOT NULL,
    fecha_prestamo_devolucion TIMESTAMP NULL DEFAULT NULL   -- NULL hasta que se devuelve
);

-- ===========================================
-- TABLA REPORTES
-- ===========================================
CREATE TABLE Reportes (
    id_reporte INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fecha_generacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) NOT NULL,
    descripcion VARCHAR(250) NOT NULL,
    tipo_reportes VARCHAR(50) NOT NULL
);

-- ===========================================
-- TABLAS INTERMEDIAS (relaciones muchos a muchos)
-- ===========================================
CREATE TABLE Prestamos_usuarios (
    fk_id_prestamo INT NOT NULL,
    fk_id_usuario INT NOT NULL,
    PRIMARY KEY (fk_id_usuario, fk_id_prestamo),
    CONSTRAINT prestamo_usuario
        FOREIGN KEY (fk_id_prestamo) REFERENCES Prestamos(id_prestamo),
    CONSTRAINT usuario_prestamo
        FOREIGN KEY (fk_id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Prestamos_equipos (
    fk_id_prestamo INT NOT NULL,
    fk_id_pc INT NOT NULL,
    PRIMARY KEY (fk_id_pc, fk_id_prestamo),
    CONSTRAINT prestamo_equipo
        FOREIGN KEY (fk_id_prestamo) REFERENCES Prestamos(id_prestamo),
    CONSTRAINT equipo_prestamo
        FOREIGN KEY (fk_id_pc) REFERENCES Equipos(id_pc)
);

CREATE TABLE Prestamos_reportes (
    fk_id_prestamo INT NOT NULL,
    fk_id_reporte INT NOT NULL,
    PRIMARY KEY (fk_id_reporte, fk_id_prestamo),
    CONSTRAINT prestamo_reporte
        FOREIGN KEY (fk_id_prestamo) REFERENCES Prestamos(id_prestamo),
    CONSTRAINT reporte_prestamo
        FOREIGN KEY (fk_id_reporte) REFERENCES Reportes(id_reporte)
);

CREATE TABLE Docentes_cursos (
    fk_id_docentes INT NOT NULL,
    fk_id_cursos INT NOT NULL,
    PRIMARY KEY (fk_id_cursos, fk_id_docentes),
    CONSTRAINT docentes_cursos
        FOREIGN KEY (fk_id_docentes) REFERENCES Docentes(id_docentes),
    CONSTRAINT cursos_docentes
        FOREIGN KEY (fk_id_cursos) REFERENCES Cursos(id_cursos)
);

CREATE TABLE Estudiantes_cursos (
    fk_id_estudiante INT NOT NULL,
    fk_id_cursos INT NOT NULL,
    PRIMARY KEY (fk_id_cursos, fk_id_estudiante),
    CONSTRAINT estudiantes_cursos
        FOREIGN KEY (fk_id_estudiante) REFERENCES Estudiantes(id_estudiante),
    CONSTRAINT cursos_estudiantes
        FOREIGN KEY (fk_id_cursos) REFERENCES Cursos(id_cursos)
);

-- ===========================================
-- RESTRICCIONES CHECK
-- ===========================================
ALTER TABLE Usuarios
    ADD CONSTRAINT verificar_nombre
    CHECK (CHAR_LENGTH(nombre) >= 3 AND CHAR_LENGTH(nombre) <= 16);

ALTER TABLE Usuarios
    ADD CONSTRAINT verificar_apellido
    CHECK (CHAR_LENGTH(apellido) >= 3 AND CHAR_LENGTH(apellido) <= 16);

ALTER TABLE Usuarios
    ADD CONSTRAINT verificar_ci
    CHECK (CHAR_LENGTH(ci) >= 8);

ALTER TABLE Usuarios
    ADD CONSTRAINT verificar_estado_usuario
    CHECK (estado IN ('Activo', 'Inactivo'));

ALTER TABLE Telefono
    ADD CONSTRAINT verificar_telefono
    CHECK (CHAR_LENGTH(numero) >= 8 AND CHAR_LENGTH(numero) <= 9);

ALTER TABLE Equipos
    ADD CONSTRAINT verificar_estado_equipo
    CHECK (estado IN ('Disponible', 'Prestado', 'Mantenimiento'));

-- ===========================================
-- 9. HARDWARE (Arduino / sensores)
-- ===========================================
ALTER TABLE Equipos
    ADD COLUMN presente_en_rack BOOLEAN NOT NULL DEFAULT TRUE;

CREATE TABLE Alertas (
    id_alerta INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fk_id_pc INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,                       -- extraccion_no_autorizada / falta_devolucion
    fecha_alerta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atendida BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_alerta_equipo
        FOREIGN KEY (fk_id_pc) REFERENCES Equipos(id_pc),
    CONSTRAINT verificar_tipo_alerta
        CHECK (tipo IN ('extraccion_no_autorizada', 'falta_devolucion'))
);

-- ===========================================
-- DATOS DE PRUEBA (contraseñas guardadas como hash bcrypt)
-- ===========================================
INSERT INTO Usuarios (ci, nombre, apellido, usuario, contrasenia, foto_perfil, estado) VALUES
('56462815', 'Heidy', 'Rocha', 'Heidy2 Rocha', '223456789', NULL, 'Activo'),
('53031538', 'Bruno', 'Hernandez', 'Bruno2 Hernandez', '287654821', NULL, 'Activo');

INSERT INTO equipos (observaciones, estado, modelo,marca, inventario) VALUES
('Equipo completo con cargador','prestado','ProBook','HP','PC-2025-002');

INSERT INTO prestamos (observaciones, estado, fecha_prevista, fecha_prestamo_devolucion) VALUES 
('Equipo cargado', 'prestado', '2025-11-20', '2025-11-20');

ALTER TABLE productos ADD
COLUMN imagen VARCHAR(255) NULL;




CREATE TABLE usuarios (
id INT AUTO_INCREMENT PRIMARY KEY,
email VARCHAR(100) NOT NULL UNIQUE,
password_hash VARCHAR(255) NOT NULL,
rol ENUM('admin', 'editor', 'usuario') NOT NULL DEFAULT 'usuario',
intentos_fallidos INT NOT NULL DEFAULT 0,
bloqueado_hasta DATETIME NULL,
creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
USE computa;

-- Tabla donde se guardan las sesiones por token.
-- Se guarda el HASH del token (sha256), nunca el token en sí.
CREATE TABLE Sesiones (
    token_hash CHAR(64) NOT NULL PRIMARY KEY,
    fk_id_usuario INT NOT NULL,
    expira_en DATETIME NOT NULL,
    CONSTRAINT fk_sesion_usuario
        FOREIGN KEY (fk_id_usuario) REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

select * from usuarios;

-- 2) Contraseña real (hash bcrypt de: Clave1234) para los usuarios de prueba
UPDATE Usuarios SET contrasenia = '$2y$10$bIcvyRfz.Pk1A3/5K7PCsOKo0rUWDj9APRmL121.zlXPW7Cfxdq56' WHERE usuario IN ('Heidy2 Rocha', 'Bruno2 Hernandez');
 
-- 3) Roles: sin una fila en Funcionarios/Docentes/Estudiantes el login da 403
--    Funcionarios = administrador | Docentes = encargado | Estudiantes = usuario
INSERT IGNORE INTO Funcionarios (fk_id_usuario) SELECT id_usuario FROM Usuarios WHERE usuario = 'Heidy2 Rocha';
INSERT IGNORE INTO Docentes     (fk_id_usuario) SELECT id_usuario FROM Usuarios WHERE usuario = 'Bruno2 Hernandez';
 
-- 4) Para comprobar:
SELECT u.id_usuario, u.usuario, u.estado,
       (SELECT COUNT(*) FROM Funcionarios f WHERE f.fk_id_usuario = u.id_usuario) AS es_admin,
       (SELECT COUNT(*) FROM Docentes d WHERE d.fk_id_usuario = u.id_usuario) AS es_encargado 
	FROM Usuarios u;


-- usuario común (rol "usuario")
INSERT INTO Estudiantes (fk_id_usuario) VALUES (43);




-- ===========================================
-- describe
-- ===========================================
DESCRIBE prestamos;


SHOW TABLES;




DESCRIBE prestamos_usuarios;
DESCRIBE prestamos_equipos;



DESCRIBE equipos;


INSERT INTO equipos (inventario, marca, modelo) VALUES
('PC-2025-011', 'HP', 'ProBook'),
('PC-2025-012', 'HP', 'ProBook'),
('PC-2025-013', 'Lenovo', 'ThinkPad');


INSERT INTO equipos (inventario, marca, modelo, presente_en_rack) VALUES
('PC-2025-014', 'Dell', 'Latitude', 0);


SELECT inventario, marca, modelo FROM equipos;

SELECT inventario, estado FROM equipos WHERE inventario = 'PC-2025-002';


SELECT inventario, estado FROM equipos;

SELECT DISTINCT estado FROM equipos;



ALTER TABLE equipos
MODIFY estado ENUM('Disponible','Prestado','Mantenimiento') NOT NULL DEFAULT 'Disponible';

DESCRIBE equipos;


SELECT id_usuario, usuario FROM usuarios WHERE usuario = 'mario.p';



DESCRIBE cursos;

-- usuario común (funcionario) =========== asignarle rol a  Mario Piriz como estudiante =============
INSERT INTO funcionarios (fk_id_usuario) VALUES (32);
SELECT id_usuario, usuario, estado FROM usuarios WHERE usuario = 'mario.p';



SELECT id_usuario, usuario FROM usuarios WHERE usuario = 'Tiziana.Bonilla';


-- usuario común (rol "usuario")
INSERT INTO Estudiantes (fk_id_usuario) VALUES (43);


SELECT id_usuario, usuario, estado FROM usuarios WHERE usuario = 'Tiziana.Bonilla';

-- usuario común (estudiante) =========== asignarle rol a Tiziana Bonilla como estudiante =============
INSERT INTO estudiantes (fk_id_usuario) VALUES (44);

SELECT * FROM funcionarios WHERE fk_id_usuario = 44;


-- usuario común (estudiante) =========== asignarle rol a  Karen Cuitiño como estudiante =============
INSERT INTO estudiantes (fk_id_usuario) VALUES (26);
SELECT * FROM funcionarios WHERE fk_id_usuario = 26;


select * from usuarios;


-- 1) Foto de perfil: pasa de BLOB (64 KB) a MEDIUMBLOB (16 MB)
ALTER TABLE Usuarios MODIFY foto_perfil MEDIUMBLOB NULL;
 
-- 2) Imagen del equipo: columna nueva
ALTER TABLE Equipos ADD COLUMN imagen MEDIUMBLOB NULL;
 
-- Para comprobar:
DESCRIBE Usuarios;
DESCRIBE Equipos;
 
 
 
 DESCRIBE equipos;
 
 SELECT id_usuario, ci, usuario, estado, LEFT(contrasenia, 20) AS inicio_hash, LENGTH(contrasenia) AS largo
FROM Usuarios
WHERE usuario LIKE '%Bruno%' OR ci = 53031538;





-- usuario común (estudiante) =========== asignarle rol a  Karen Cuitiño como estudiante =============
INSERT INTO estudiantes (fk_id_usuario) VALUES (16);
SELECT * FROM funcionarios WHERE fk_id_usuario = 16;







DELETE FROM Docentes
WHERE fk_id_usuario = (SELECT id_usuario FROM Usuarios WHERE usuario = 'Bruno2 Hernandez');



-- comprobar
SELECT u.usuario,
       (SELECT COUNT(*) FROM Funcionarios f WHERE f.fk_id_usuario = u.id_usuario) AS es_admin,
       (SELECT COUNT(*) FROM Docentes d WHERE d.fk_id_usuario = u.id_usuario) AS es_encargado,
       (SELECT COUNT(*) FROM Estudiantes e WHERE e.fk_id_usuario = u.id_usuario) AS es_usuario
FROM Usuarios u WHERE u.usuario = 'Bruno2 Hernandez';


select * from cursos;



ALTER TABLE prestamos
  ADD COLUMN id_cursos INT NULL,
  ADD CONSTRAINT fk_prestamo_curso
    FOREIGN KEY (id_cursos) REFERENCES cursos(id_cursos)
    ON DELETE SET NULL;
    
    
    
    
    -- Curso / grupo de cada préstamo (como la columna "Teléfono / Grupo" de la hoja en papel).
-- Es NULL en los préstamos que ya existen; los nuevos lo traen siempre.
ALTER TABLE Prestamos ADD COLUMN fk_id_cursos INT NULL;
 
ALTER TABLE Prestamos
    ADD CONSTRAINT fk_prestamo_curso
    FOREIGN KEY (fk_id_cursos) REFERENCES Cursos(id_cursos);
 
-- Para comprobar:
DESCRIBE Prestamos;
 select * from usuarios;