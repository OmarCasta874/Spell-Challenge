-- ============================================================
-- BASE DE DATOS SPELL-CHALLENGE
-- ============================================================

DROP DATABASE IF EXISTS spell_challenge;

CREATE DATABASE spell_challenge;
USE spell_challenge;


-- ============================================================
-- TABLAS
-- ============================================================

CREATE TABLE categoria (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE nivel (
    codigo VARCHAR(2) PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE carrera (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE insignia (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    crit_obtencion VARCHAR(50) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE juego (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    mecanica VARCHAR(30) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE dificultad (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE tipo_usuario (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE usuario (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre_pila VARCHAR(30) NOT NULL,
    apellPaterno VARCHAR(30) NOT NULL,
    apellMaterno VARCHAR(30) NOT NULL,
    correo VARCHAR(50) NOT NULL,
    contraseña VARCHAR(128) NOT NULL,
    telefono VARCHAR(10) NOT NULL,
    tipo_usuario VARCHAR(10) NOT NULL,
    FOREIGN KEY (tipo_usuario) REFERENCES tipo_usuario(clave)
) ENGINE=InnoDB;


CREATE TABLE administrador (
    clave VARCHAR(10) PRIMARY KEY,
    nombre_pila VARCHAR(30) NOT NULL,
    apellPaterno VARCHAR(30) NOT NULL,
    apellMaterno VARCHAR(30) NULL,
    usuario VARCHAR(10) NOT NULL,
    FOREIGN KEY (usuario) REFERENCES usuario(codigo)
) ENGINE=InnoDB;


CREATE TABLE profesor (
    clave VARCHAR(10) PRIMARY KEY,
    nombre_pila VARCHAR(30) NOT NULL,
    apellPaterno VARCHAR(100) NOT NULL,
    apellMaterno VARCHAR(100) NULL,
    usuario VARCHAR(10) NOT NULL,
    FOREIGN KEY (usuario) REFERENCES usuario(codigo)
) ENGINE=InnoDB;


CREATE TABLE alumno (
    matricula VARCHAR(10) PRIMARY KEY,
    nombrePila VARCHAR(30) NOT NULL,
    apellPaterno VARCHAR(100) NOT NULL,
    apellMaterno VARCHAR(100) NULL,
    usuario VARCHAR(10) NOT NULL,
    nivel VARCHAR(2) NOT NULL,
    carrera VARCHAR(10) NOT NULL,
    FOREIGN KEY (usuario) REFERENCES usuario(codigo),
    FOREIGN KEY (nivel) REFERENCES nivel(codigo),
    FOREIGN KEY (carrera) REFERENCES carrera(clave)
) ENGINE=InnoDB;


CREATE TABLE ranking (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    posicion INT NOT NULL,
    periodo VARCHAR(20) NOT NULL,
    puntos INT NOT NULL,
    alumno VARCHAR(10) NOT NULL,
    FOREIGN KEY (alumno) REFERENCES alumno(matricula)
) ENGINE=InnoDB;


CREATE TABLE tipo_ranking (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    ranking VARCHAR(10) NOT NULL,
    FOREIGN KEY (ranking) REFERENCES ranking(codigo)
) ENGINE=InnoDB;


CREATE TABLE lista (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_limite DATE NULL,
    numero_letras INT NOT NULL,
    profesor VARCHAR(10) NOT NULL,
    FOREIGN KEY (profesor) REFERENCES profesor(clave)
) ENGINE=InnoDB;


CREATE TABLE palabra (
    codigo VARCHAR(10) PRIMARY KEY,
    significado VARCHAR(50) NOT NULL,
    pronunciacion VARCHAR(100) NOT NULL,
    imagen VARCHAR(100) NOT NULL,
    audio VARCHAR(100) NOT NULL,
    categoria VARCHAR(10) NOT NULL,
    nivel VARCHAR(2) NOT NULL,
    FOREIGN KEY (categoria) REFERENCES categoria(codigo),
    FOREIGN KEY (nivel) REFERENCES nivel(codigo)
) ENGINE=InnoDB;


CREATE TABLE reporte (
    codigo VARCHAR(10) PRIMARY KEY,
    fecha_genera DATE NOT NULL,
    tipo_reporte VARCHAR(30) NOT NULL,
    profesor VARCHAR(10) NOT NULL,
    FOREIGN KEY (profesor) REFERENCES profesor(clave)
) ENGINE=InnoDB;


CREATE TABLE rango (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    minimo INT NOT NULL,
    maximo INT NULL,
    alumno VARCHAR(10) NOT NULL,
    FOREIGN KEY (alumno) REFERENCES alumno(matricula)
) ENGINE=InnoDB;


CREATE TABLE grupo (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    fechaCreacion DATE NOT NULL,
    ciclo VARCHAR(100) NOT NULL,
    profesor VARCHAR(10) NOT NULL,
    FOREIGN KEY (profesor) REFERENCES profesor(clave)
) ENGINE=InnoDB;


CREATE TABLE practica_sesion (
    clave VARCHAR(10) PRIMARY KEY,
    fecha DATE NOT NULL,
    duracion TIME NOT NULL,
    porcent_aciertos FLOAT NOT NULL,
    puntos_obt FLOAT NOT NULL,
    juego VARCHAR(10) NOT NULL,
    lista VARCHAR(10) NOT NULL,
    FOREIGN KEY (juego) REFERENCES juego(clave),
    FOREIGN KEY (lista) REFERENCES lista(codigo)
) ENGINE=InnoDB;


CREATE TABLE intento_palabra (
    clave VARCHAR(10) PRIMARY KEY,
    acertado INT NOT NULL,
    tiempo_respuesta TIME NOT NULL,
    numero_intentos INT NOT NULL,
    practica_sesion VARCHAR(10) NOT NULL,
    palabra VARCHAR(10) NOT NULL,
    FOREIGN KEY (practica_sesion) REFERENCES practica_sesion(clave),
    FOREIGN KEY (palabra) REFERENCES palabra(codigo)
) ENGINE=InnoDB;


CREATE TABLE proceso_lista (
    lista VARCHAR(10) NOT NULL,
    alumno VARCHAR(10) NOT NULL,
    porcent_aciert FLOAT NOT NULL,
    lista_desbloqueada VARCHAR(10) NOT NULL,
    fecha_completado DATE NOT NULL,
    PRIMARY KEY (lista, alumno),
    FOREIGN KEY (lista) REFERENCES lista(codigo),
    FOREIGN KEY (alumno) REFERENCES alumno(matricula)
) ENGINE=InnoDB;


CREATE TABLE lista_grupo (
    lista VARCHAR(10) NOT NULL,
    grupo VARCHAR(10) NOT NULL,
    PRIMARY KEY (lista, grupo),
    FOREIGN KEY (lista) REFERENCES lista(codigo),
    FOREIGN KEY (grupo) REFERENCES grupo(codigo)
) ENGINE=InnoDB;


CREATE TABLE grupo_alumno (
    grupo VARCHAR(10) NOT NULL,
    alumno VARCHAR(10) NOT NULL,
    PRIMARY KEY (grupo, alumno),
    FOREIGN KEY (grupo) REFERENCES grupo(codigo),
    FOREIGN KEY (alumno) REFERENCES alumno(matricula)
) ENGINE=InnoDB;


CREATE TABLE alumno_insignia (
    alumno VARCHAR(10) NOT NULL,
    insignia VARCHAR(10) NOT NULL,
    fecha_obtencion DATE,
    PRIMARY KEY (alumno, insignia),
    FOREIGN KEY (alumno) REFERENCES alumno(matricula),
    FOREIGN KEY (insignia) REFERENCES insignia(clave)
) ENGINE=InnoDB;


CREATE TABLE alumno_practica (
    alumno VARCHAR(10) NOT NULL,
    practica_sesion VARCHAR(10) NOT NULL,
    PRIMARY KEY (alumno, practica_sesion),
    FOREIGN KEY (alumno) REFERENCES alumno(matricula),
    FOREIGN KEY (practica_sesion) REFERENCES practica_sesion(clave)
) ENGINE=InnoDB;


CREATE TABLE dificultad_juego (
    juego VARCHAR(10) NOT NULL,
    dificultad VARCHAR(10) NOT NULL,
    PRIMARY KEY (juego, dificultad),
    FOREIGN KEY (juego) REFERENCES juego(clave),
    FOREIGN KEY (dificultad) REFERENCES dificultad(clave)
) ENGINE=InnoDB;

CREATE TABLE lista_palabra (
    lista VARCHAR(10) NOT NULL,
    palabra VARCHAR(10) NOT NULL,
    PRIMARY KEY (lista, palabra),
    FOREIGN KEY (lista) REFERENCES lista(codigo),
    FOREIGN KEY (palabra) REFERENCES palabra(codigo)
) ENGINE=InnoDB;

CREATE TABLE puntaje (
    codigo VARCHAR(10) PRIMARY KEY,
    experiencia INT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE leccion (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    practica_sesion VARCHAR(10) NOT NULL,
    puntaje VARCHAR(10) NOT NULL,
    FOREIGN KEY (practica_sesion) REFERENCES practica_sesion(clave),
    FOREIGN KEY (puntaje) REFERENCES puntaje(codigo)
) ENGINE=InnoDB;

CREATE TABLE bitacora_profesor (
    codigo VARCHAR(10) PRIMARY KEY,
    fecha_generacion DATE NOT NULL,
    hora_generacion TIME NOT NULL,
    accion VARCHAR(255) NOT NULL,
    profesor VARCHAR(10) NOT NULL,
    FOREIGN KEY (profesor) REFERENCES profesor(clave)
) ENGINE=InnoDB;

CREATE TABLE bitacora_administrador (
    codigo VARCHAR(10) PRIMARY KEY,
    fecha_generacion DATE NOT NULL,
    hora_generacion TIME NOT NULL,
    accion VARCHAR(255) NOT NULL,
    usuario VARCHAR(10) NOT NULL,
    FOREIGN KEY (usuario) REFERENCES usuario(codigo)
) ENGINE=InnoDB;

CREATE TABLE grupo_carrera (
    grupo VARCHAR(10) NOT NULL,
    carrera VARCHAR(10) NOT NULL,
    PRIMARY KEY (grupo, carrera),
    FOREIGN KEY (grupo) REFERENCES grupo(codigo),
    FOREIGN KEY (carrera) REFERENCES carrera(clave)
) ENGINE=InnoDB;

CREATE TABLE copia_seguridad (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    datos TEXT NOT NULL,
    administrador VARCHAR(10) NOT NULL,
    FOREIGN KEY (administrador) REFERENCES administrador(clave)
) ENGINE=InnoDB;

CREATE TABLE competencia (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    profesor VARCHAR(10) NOT NULL,
    FOREIGN KEY (profesor) REFERENCES profesor(clave)
) ENGINE=InnoDB;

CREATE TABLE lista_competencia (
    lista VARCHAR(10) NOT NULL,
    competencia VARCHAR(10) NOT NULL,
    PRIMARY KEY (lista, competencia),
    FOREIGN KEY (lista) REFERENCES lista(codigo),
    FOREIGN KEY (competencia) REFERENCES competencia(codigo)
) ENGINE=InnoDB;

CREATE TABLE alumno_leccion (
    alumno VARCHAR(10) NOT NULL,
    leccion VARCHAR(10) NOT NULL,
    PRIMARY KEY (alumno, leccion),
    FOREIGN KEY (alumno) REFERENCES alumno(matricula),
    FOREIGN KEY (leccion) REFERENCES leccion(clave)
) ENGINE=InnoDB;

CREATE TABLE lista_leccion (
    lista VARCHAR(10) NOT NULL,
    leccion VARCHAR(10) NOT NULL,
    PRIMARY KEY (lista, leccion),
    FOREIGN KEY (lista) REFERENCES lista(codigo),
    FOREIGN KEY (leccion) REFERENCES leccion(clave)
) ENGINE=InnoDB;

CREATE TABLE contenido_leccion (
    codigo VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE estado_opcion (
    clave VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE opcion (
    clave VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    estado_opcion VARCHAR(5) NOT NULL,
    CONSTRAINT fk_opcion_estado
        FOREIGN KEY (estado_opcion) REFERENCES estado_opcion(clave)
) ENGINE=InnoDB;

CREATE TABLE ejercicio (
    clave VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    leccion VARCHAR(10) NOT NULL,

    CONSTRAINT fk_ejercicio_leccion
        FOREIGN KEY (leccion) REFERENCES leccion(clave)
) ENGINE=InnoDB;

CREATE TABLE ejercicio_opcion (
    ejercicio VARCHAR(5) NOT NULL,
    opcion VARCHAR(5) NOT NULL,

    PRIMARY KEY (ejercicio, opcion),

    CONSTRAINT fk_ejercicio_opcion_ejercicio
        FOREIGN KEY (ejercicio) REFERENCES ejercicio(clave),

    CONSTRAINT fk_ejercicio_opcion_opcion
        FOREIGN KEY (opcion) REFERENCES opcion(clave)
) ENGINE=InnoDB;

-- ============================================================
-- CATALOGOS
-- ============================================================

INSERT INTO categoria VALUES
('CAT01', 'Animals'),
('CAT02', 'Food'),
('CAT03', 'Colors'),
('CAT04', 'Family'),
('CAT05', 'School'),
('CAT06', 'Sports'),
('CAT07', 'Nature'),
('CAT08', 'Technology'),
('CAT09', 'Feelings'),
('CAT10', 'Vehicles');

INSERT INTO categoria VALUES
('CAT11', '6 Letters'),
('CAT12', '7 Letters'),
('CAT13', '8 Letters'),
('CAT14', '9 Letters'),
('CAT15', '10 Letters'),
('CAT16', '11 Letters'),
('CAT17', '12 Letters');


INSERT INTO nivel VALUES
('A1', 'Beginner level - basic everyday vocabulary'),
('A2', 'Basic level - frequent phrases and expressions'),
('B1', 'Intermediate level - familiar and interesting topics'),
('B2', 'Upper-intermediate level - complex and technical texts'),
('C1', 'Advanced level - flexible and effective use of the language'),
('C2', 'Proficiency level - virtually complete comprehension');


INSERT INTO carrera VALUES
('EII', 'Teaching the English Language',
 'Training focused on pedagogical methodology, didactics and advanced command of the English language to work as a teacher or facilitator of the language at different educational and business levels.'),

('PP', 'Production Processes',
 'Practical preparation to supervise, optimize and control manufacturing processes and industrial production lines under quality and sustainability standards.'),

('OLCE', 'Logistics Operations and Foreign Trade',
 'Focus on supply chain management, customs regulations, international traffic, and global freight transport management.'),

('DSM', 'Multiplatform Software Development',
 'Design, programming, implementation and management of computer applications for computers and mobile devices using current languages and technological tools.'),

('IRD', 'Digital Network Infrastructure',
 'Installation, configuration, security and administration of local and wide area networks, ensuring connectivity and data flow in organizations.');


INSERT INTO insignia VALUES
('INS01', '7-Day Streak', 'Practice 7 days straight', '7 consecutive days'),
('INS02', '50 Correct Answers', 'Accumulate 50 correct words', '50 correct words'),
('INS03', 'No Mistakes', 'Complete a list without making a mistake', 'No mistakes in a list completed'),
('INS04', 'Weekly Champion', 'First place of the week', 'Ranking weekly first place'),
('INS05', 'Listening Master', 'Master the audio games', 'No mistakes in 3 audio games'),
('INS06', 'Maximum Speed', 'Responded very quickly', '5 lessons completed in less than 1 minute'),
('INS07', '30-Day Streak', 'Practice 30 days straight', '30 days studying English'),
('INS08', '100 Correct Answers', 'Accumulate 100 correct words', '100 correct words'),
('INS09', 'Early Bird', 'Practice before 7 am', 'Doing a lesson before 7 am'),
('INS10', 'Monthly Top 3', 'Place in the top 3', 'Reach monthly ranking third place'),
('INS11', 'Silver Student', 'Place in the top 2', 'Reach weekly ranking second place');


INSERT INTO juego VALUES
('J01', 'Listen and Type',
 'Audio plays and the student types the word; on a miss, the answer is shown and the audio repeats.',
 'Listen and Type'),

('J02', 'Word Scramble',
 'The word appears scrambled and the student reorders it.',
 'Word Scramble'),

('J03', 'Hangman',
 'Classic hangman with meaning or category hints.',
 'Hangman'),

('J04', 'Memory',
 'Match word to image, or word to meaning.',
 'Memory'),

('J05', 'Typing Race',
 'Words appear and vanish quickly; the student must type them in time.',
 'Typing Race'),

('J06', 'Word Search',
 'Auto-generated word search using the list words.',
 'Word Search'),

('J07', 'Crossword',
 'Auto-generated crossword using the teacher definitions.',
 'Crossword'),

('J08', 'Missing Letters',
 'Word with gaps that the student fills in.',
 'Missing Letters'),

('J09', 'Multiple Choice',
 'Audio plays and the student picks the correct word from options.',
 'Multiple Choice'),

('J10', 'Image Challenge',
 'An image is shown and the student types the matching word.',
 'Image Challenge'),

('J11', 'Beat the Clock',
 'Answer as many words as possible in 60 seconds.',
 'Beat the Clock'),

('J12', 'Boss Battle',
 'Final challenge combining several previous mechanics.',
 'Boss Battle');


INSERT INTO dificultad VALUES
('DI01', 'Easy', 'Common, short, everyday words.'),
('DI02', 'Medium', 'Everyday words of moderate length and complexity.'),
('DI03', 'Hard', 'Longer or less common words.');


INSERT INTO tipo_usuario VALUES
('TUSR01', 'Student', 'Someone who practices English'),
('TUSR02', 'Teacher', 'Creates groups and teaches classes'),
('TUSR03', 'Administrator', 'The system administrator');


-- ============================================================
-- USUARIOS
-- ============================================================

INSERT INTO usuario VALUES
('USR0001', 'Renata', 'Ortega', 'Rivera',
 '2026100001@ut-tijuana.edu.mx',
 '$2b$12$LQv3c1yqBWVHxkd0LHAkCOQ7fXJQ8vK8pYJ8K5JxG8qY9Y2r8zJm',
 '6641002001', 'TUSR01'),

('USR0002', 'Emilio', 'Delgado', 'Duran',
 '2026100002@ut-tijuana.edu.mx',
 '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92q8q3q0j5qK6f7m8n9oP',
 '6641002002', 'TUSR01'),

('USR0003', 'Ximena', 'Rojas', 'Pineda',
 '2026100003@ut-tijuana.edu.mx',
 '$2b$12$W5h8K2pLm9Qx7Vb3Nc4RdO6tYu1Ei8Fa0Gs2Hj5Kl7Mn9Pq4Rs6Tu',
 '6641002003', 'TUSR01'),

('USR0004', 'Adrian', 'Mendoza', 'Contreras',
 '2026100004@ut-tijuana.edu.mx',
 '$2b$12$A7cD9eF2gH4jK6mN8pQ1rS3tV5xY7zB0cE2fG4hJ6kL8mN0pQ2rS',
 '6641002004', 'TUSR01'),

('USR0005', 'Camila', 'Aguilar', 'Bravo',
 '2026100005@ut-tijuana.edu.mx',
 '$2b$12$Z8xC6vB4nM2aS0dF9gH7jK5lP3qW1eR8tY6uI4oP2aS9dF7gH5j',
 '6641002005', 'TUSR01'),

('USR0006', 'Oscar', 'Silva', 'Chavez',
 '2026100006@ut-tijuana.edu.mx',
 '$2b$12$Q4wE6rT8yU0iO2pA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR4tY6u',
 '6641002006', 'TUSR01'),

('USR0007', 'Brenda', 'Campos', 'Luna',
 '2026100007@ut-tijuana.edu.mx',
 '$2b$12$H3jK5lP7qW9eR1tY3uI5oA7sD9fG1hJ3kL5zX7cV9bN1mM3qW5eR',
 '6641002007', 'TUSR01'),

('USR0008', 'Sergio', 'Vargas', 'Robles',
 '2026100008@ut-tijuana.edu.mx',
 '$2b$12$M6nB8vC0xZ2aS4dF6gH8jK0lP2qW4eR6tY8uI0oA2sD4fG6hJ8k',
 '6641002008', 'TUSR01'),

('USR0009', 'Melissa', 'Pena', 'Cano',
 '2026100009@ut-tijuana.edu.mx',
 '$2b$12$R9tY7uI5oP3aS1dF9gH7jK5lP3qW1eR9tY7uI5oP3aS1dF9gH7jK',
 '6641002009', 'TUSR01'),

('USR0010', 'Gabriel', 'Rios', 'Solis',
 '2026100010@ut-tijuana.edu.mx',
 '$2b$12$B2vN4mM6qW8eR0tY2uI4oA6sD8fG0hJ2kL4zX6cV8bN0mM2qW4eR',
 '6641002010', 'TUSR01'),

('USR0011', 'Gilda', 'Torres', 'Roman',
 'gilda.torres@beemail.com',
 '$2b$12$F5gH7jK9lP1qW3eR5tY7uI9oA1sD3fG5hJ7kL9zX1cV3bN5mM7qW',
 '6641002011', 'TUSR02'),

('USR0012', 'Blanca', 'Roman', 'Ortiz',
 'blanca.roman@beemail.com',
 '$2b$12$T8yU6iO4pA2sD0fG8hJ6kL4zX2cV0bN8mM6qW4eR2tY0uI8oA6s',
 '6641002012', 'TUSR02'),

('USR0013', 'Isaac', 'Salvatierra', 'Anguilo',
 'isaac.salvatierra@beemail.com',
 '$2b$12$C1vB3nM5aS7dF9gH1jK3lP5qW7eR9tY1uI3oA5sD7fG9hJ1kL3z',
 '6641002013', 'TUSR02'),

('USR0014', 'Ariana Lizeth', 'González', 'Osuna',
 'ariana.gonzales@beemail.com',
 '$2b$12$J4kL6zX8cV0bN2mM4qW6eR8tY0uI2oA4sD6fG8hJ0kL2zX4cV6b',
 '6641002014', 'TUSR02'),

('USR0015', 'Juan Pablo', 'Quiñones', 'Hernández',
 'juan.quinones@beemail.com',
 '$2b$12$P7qW5eR3tY1uI9oA7sD5fG3hJ1kL9zX7cV5bN3mM1qW9eR7tY5uI',
 '6641002015', 'TUSR02'),

('USR0016', 'Jesus Omar', 'Castañon', 'Castañon',
 'omar.castanon@beemail.com',
 '$2b$12$V0bN2mM4qW6eR8tY0uI2oA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR',
 '6645114953', 'TUSR03'),

('USR0017', 'Josue Alberto', 'Villegas', 'Hernández',
 'josue.villegas@beemail.com',
 '$2b$12$G9hJ7kL5zX3cV1bN9mM7qW5eR3tY1uI9oA7sD5fG3hJ1kL9zX7cV',
 '6646167119', 'TUSR03'),

('USR0018', 'Diego', 'Sánchez', 'Hernández',
 'diego.sanchez@beemail.com',
 '$2b$12$K2lP4qW6eR8tY0uI2oA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR4tY',
 '6633288842', 'TUSR03'),

('USR0019', 'Dulce Aurora', 'de la Cruz', 'Enriquez',
 'dulce.delacruz@beemail.com',
 '$2b$12$Y5uI3oA1sD9fG7hJ5kL3zX1cV9bN7mM5qW3eR1tY9uI7oA5sD3fG',
 '6642213487', 'TUSR03'),

('USR0020', 'Aline Aketzali', 'Lucido', 'Muñoz',
 'aline.lucido@beemail.com',
 '$2b$12$D8fG6hJ4kL2zX0cV8bN6mM4qW2eR0tY8uI6oA4sD2fG0hJ8kL6zX',
 '6648199271', 'TUSR03');


-- ============================================================
-- ADMINISTRADORES
-- ============================================================

INSERT INTO administrador VALUES
('AD01', 'Jesus Omar', 'Castañon', 'Castañon', 'USR0016'),
('AD02', 'Josue Alberto', 'Villegas', 'Hernández', 'USR0017'),
('AD03', 'Diego', 'Sánchez', 'Hernández', 'USR0018'),
('AD04', 'Dulce Aurora', 'de la Cruz', 'Enriquez', 'USR0019'),
('AD05', 'Aline Aketzali', 'Lucido', 'Muñoz', 'USR0020');


-- ============================================================
-- PROFESORES
-- ============================================================

INSERT INTO profesor VALUES
('PROF01', 'Gilda', 'Torres', 'Roman', 'USR0011'),
('PROF02', 'Blanca', 'Roman', 'Ortiz', 'USR0012'),
('PROF03', 'Isaac', 'Salvatierra', 'Anguilo', 'USR0013'),
('PROF04', 'Ariana Lizeth', 'González', 'Osuna', 'USR0014'),
('PROF05', 'Juan Pablo', 'Quiñones', 'Hernández', 'USR0015');


-- ============================================================
-- ALUMNOS
-- ============================================================

INSERT INTO alumno VALUES
('2026100001', 'Renata', 'Ortega', 'Rivera', 'USR0001', 'B1', 'EII'),
('2026100002', 'Emilio', 'Delgado', 'Duran', 'USR0002', 'A2', 'PP'),
('2026100003', 'Ximena', 'Rojas', 'Pineda', 'USR0003', 'B1', 'OLCE'),
('2026100004', 'Adrian', 'Mendoza', 'Contreras', 'USR0004', 'B1', 'DSM'),
('2026100005', 'Camila', 'Aguilar', 'Bravo', 'USR0005', 'C1', 'IRD'),
('2026100006', 'Oscar', 'Silva', 'Chavez', 'USR0006', 'C1', 'EII'),
('2026100007', 'Brenda', 'Campos', 'Luna', 'USR0007', 'A2', 'PP'),
('2026100008', 'Sergio', 'Vargas', 'Robles', 'USR0008', 'B2', 'OLCE'),
('2026100009', 'Melissa', 'Pena', 'Cano', 'USR0009', 'B2', 'DSM'),
('2026100010', 'Gabriel', 'Rios', 'Solis', 'USR0010', 'B1', 'IRD');


-- ============================================================
-- RANKING
-- ============================================================

INSERT INTO ranking VALUES
('RNK01', 'Ranking Semanal #1', 1, 'Semanal', 1000, '2026100001'),
('RNK02', 'Ranking Mensual #2', 2, 'Mensual', 900, '2026100002'),
('RNK03', 'Ranking Semanal #3', 3, 'Semanal', 800, '2026100003'),
('RNK04', 'Ranking Global #4', 4, 'Global', 2400, '2026100004'),
('RNK05', 'Ranking Por grupo #5', 5, 'Por grupo', 990, '2026100005'),
('RNK06', 'Ranking Por carrera #6', 6, 'Por carrera', 1075, '2026100006'),
('RNK07', 'Ranking Semanal #7', 7, 'Semanal', 675, '2026100007'),
('RNK08', 'Ranking Mensual #8', 8, 'Mensual', 350, '2026100008'),
('RNK09', 'Ranking Global #9', 9, 'Global', 800, '2026100009'),
('RNK10', 'Ranking Por grupo #10', 10, 'Por grupo', 1000, '2026100010');


-- ============================================================
-- TIPOS DE RANKING
-- ============================================================

INSERT INTO tipo_ranking VALUES
('TR01', 'Global', 'Ranking de alcance global', 'RNK01'),
('TR02', 'Por grupo', 'Ranking de alcance por grupo', 'RNK02'),
('TR03', 'Por carrera', 'Ranking de alcance por carrera', 'RNK03'),
('TR04', 'Semanal', 'Ranking de alcance semanal', 'RNK04'),
('TR05', 'Mensual', 'Ranking de alcance mensual', 'RNK05');


-- ============================================================
-- LISTAS
-- ============================================================

INSERT INTO lista VALUES
('LIS01', 'Animals', '2026-08-01', '2026-08-15', 6, 'PROF01'),
('LIS02', 'Food', '2026-08-04', '2026-08-18', 6, 'PROF02'),
('LIS03', 'Colors', '2026-08-07', '2026-08-21', 6, 'PROF03'),
('LIS04', 'Family', '2026-08-10', '2026-08-24', 6, 'PROF04'),
('LIS05', 'School', '2026-08-13', '2026-08-27', 6, 'PROF05'),
('LIS06', 'Sports', '2026-08-16', '2026-08-30', 6, 'PROF01'),
('LIS07', 'Nature', '2026-08-16', '2026-09-02', 6, 'PROF02'),
('LIS08', 'Technology', '2026-08-16', '2026-09-05', 6, 'PROF03'),
('LIS09', 'Feelings', '2026-08-16', '2026-09-08', 6, 'PROF04'),
('LIS10', 'Vehicles', '2026-08-16', '2026-09-11', 6, 'PROF05');


-- ============================================================
-- PALABRAS
-- ============================================================

INSERT INTO palabra VALUES
('PAL0001', 'apple', '/ap.el/', '', '', 'CAT02', 'A1'),
('PAL0002', 'tiger', '/tai.ger/', '', '', 'CAT01', 'A2'),
('PAL0003', 'purple', '/per.pel/', '', '', 'CAT03', 'B1'),
('PAL0004', 'mother', '/ma.der/', '', '', 'CAT04', 'B2'),
('PAL0005', 'pencil', '/pen.sel/', '', '', 'CAT05', 'C1'),
('PAL0006', 'soccer', '/sa.ker/', '', '', 'CAT06', 'C2'),
('PAL0007', 'forest', '/fo.rest/', '', '', 'CAT07', 'A1'),
('PAL0008', 'laptop', '/lap.tap/', '', '', 'CAT08', 'A2'),
('PAL0009', 'happy', '/ha.pi/', '', '', 'CAT09', 'B1'),
('PAL0010', 'bicycle', '/bai.si.kel/', '', '', 'CAT10', 'B2');

INSERT INTO palabra VALUES
-- ANIMALS
('PAL0011', 'rabbit', '/ra.bit/', '', '', 'CAT01', 'A1'),
('PAL0012', 'monkey', '/mon.ki/', '', '', 'CAT01', 'A1'),
('PAL0013', 'dolphin', '/dol.fin/', '', '', 'CAT01', 'A2'),
('PAL0014', 'elephant', '/e.le.fant/', '', '', 'CAT01', 'B1'),
('PAL0015', 'penguin', '/pen.gwin/', '', '', 'CAT01', 'B1'),

-- FOOD
('PAL0016', 'banana', '/ba.na.na/', '', '', 'CAT02', 'A1'),
('PAL0017', 'cheese', '/chiiz/', '', '', 'CAT02', 'A1'),
('PAL0018', 'chicken', '/chi.ken/', '', '', 'CAT02', 'A2'),
('PAL0019', 'sandwich', '/sand.wich/', '', '', 'CAT02', 'B1'),
('PAL0020', 'vegetable', '/vej.ta.bol/', '', '', 'CAT02', 'B2'),

-- COLORS
('PAL0021', 'red', '/red/', '', '', 'CAT03', 'A1'),
('PAL0022', 'yellow', '/ye.low/', '', '', 'CAT03', 'A1'),
('PAL0023', 'orange', '/o.ranch/', '', '', 'CAT03', 'A2'),
('PAL0024', 'green', '/grin/', '', '', 'CAT03', 'A2'),
('PAL0025', 'turquoise', '/ter.kwoiz/', '', '', 'CAT03', 'B1'),

-- FAMILY
('PAL0026', 'father', '/fa.der/', '', '', 'CAT04', 'A1'),
('PAL0027', 'sister', '/sis.ter/', '', '', 'CAT04', 'A1'),
('PAL0028', 'brother', '/bra.der/', '', '', 'CAT04', 'A1'),
('PAL0029', 'daughter', '/do.ter/', '', '', 'CAT04', 'A2'),
('PAL0030', 'grandmother', '/grand.ma.der/', '', '', 'CAT04', 'B1'),

-- SCHOOL
('PAL0031', 'book', '/buk/', '', '', 'CAT05', 'A1'),
('PAL0032', 'teacher', '/ti.cher/', '', '', 'CAT05', 'A1'),
('PAL0033', 'classroom', '/klas.rum/', '', '', 'CAT05', 'A2'),
('PAL0034', 'homework', '/hom.work/', '', '', 'CAT05', 'A2'),
('PAL0035', 'assignment', '/a.sain.ment/', '', '', 'CAT05', 'B1'),

-- SPORTS
('PAL0036', 'tennis', '/te.nis/', '', '', 'CAT06', 'A1'),
('PAL0037', 'basketball', '/bas.ket.bol/', '', '', 'CAT06', 'A1'),
('PAL0038', 'baseball', '/beis.bol/', '', '', 'CAT06', 'A2'),
('PAL0039', 'swimming', '/swi.ming/', '', '', 'CAT06', 'A2'),
('PAL0040', 'competition', '/kom.pe.ti.shon/', '', '', 'CAT06', 'B1'),

-- NATURE
('PAL0041', 'tree', '/tri/', '', '', 'CAT07', 'A1'),
('PAL0042', 'flower', '/flau.er/', '', '', 'CAT07', 'A1'),
('PAL0043', 'river', '/ri.ver/', '', '', 'CAT07', 'A2'),
('PAL0044', 'mountain', '/maun.ten/', '', '', 'CAT07', 'A2'),
('PAL0045', 'waterfall', '/wo.ter.fol/', '', '', 'CAT07', 'B1'),

-- TECHNOLOGY
('PAL0046', 'phone', '/fon/', '', '', 'CAT08', 'A1'),
('PAL0047', 'computer', '/kom.piu.ter/', '', '', 'CAT08', 'A1'),
('PAL0048', 'keyboard', '/ki.bord/', '', '', 'CAT08', 'A2'),
('PAL0049', 'software', '/soft.wer/', '', '', 'CAT08', 'B1'),
('PAL0050', 'database', '/dei.ta.beis/', '', '', 'CAT08', 'B1'),

-- FEELINGS
('PAL0051', 'sad', '/sad/', '', '', 'CAT09', 'A1'),
('PAL0052', 'angry', '/ang.gri/', '', '', 'CAT09', 'A1'),
('PAL0053', 'excited', '/ik.sai.ted/', '', '', 'CAT09', 'A2'),
('PAL0054', 'nervous', '/ner.vos/', '', '', 'CAT09', 'A2'),
('PAL0055', 'confident', '/kon.fi.dent/', '', '', 'CAT09', 'B1'),

-- VEHICLES
('PAL0056', 'car', '/kar/', '', '', 'CAT10', 'A1'),
('PAL0057', 'bus', '/bas/', '', '', 'CAT10', 'A1'),
('PAL0058', 'train', '/trein/', '', '', 'CAT10', 'A2'),
('PAL0059', 'airplane', '/er.plein/', '', '', 'CAT10', 'A2'),
('PAL0060', 'motorcycle', '/mo.tor.sai.kol/', '', '', 'CAT10', 'B1'),

--6 LETTERS (DIEGO)
INSERT INTO palabra VALUES
('PAL0061', 'Abrade', '/a-bréid/', '', '', 'CAT11', 'B1'),
('PAL0062', 'Abroad', '/a-bród/', '', '', 'CAT11', 'B1'),
('PAL0063', 'Absorb', '/ab-sórb/', '', '', 'CAT11', 'B1'),
('PAL0064', 'Accept', '/ak-sépt/', '', '', 'CAT11', 'B1'),
('PAL0065', 'Access', '/ák-ses/', '', '', 'CAT11', 'B1'),
('PAL0066', 'Accuse', '/a-kiús/', '', '', 'CAT11', 'B1'),
('PAL0067', 'Aching', '/éik-ing/', '', '', 'CAT11', 'B1'),
('PAL0068', 'Active', '/ák-tiv/', '', '', 'CAT11', 'B1'),
('PAL0069', 'Acuity', '/a-kiú-i-ti/', '', '', 'CAT11', 'B1'),
('PAL0070', 'Adhere', '/ad-jíer/', '', '', 'CAT11', 'B1'),
('PAL0071', 'Adjust', '/a-dshást/', '', '', 'CAT11', 'B1'),
('PAL0072', 'Admire', '/ad-máiar/', '', '', 'CAT11', 'B1'),
('PAL0073', 'Advice', '/ad-váis/', '', '', 'CAT11', 'B1'),
('PAL0074', 'Advise', '/ad-váis/', '', '', 'CAT11', 'B1'),
('PAL0075', 'Afford', '/a-fórd/', '', '', 'CAT11', 'B1'),
('PAL0076', 'Afraid', '/a-fréid/', '', '', 'CAT11', 'B1'),
('PAL0077', 'Ageism', '/éidsh-i-sam/', '', '', 'CAT11', 'B1'),
('PAL0078', 'Amazes', '/a-méi-sis/', '', '', 'CAT11', 'B1'),
('PAL0079', 'Amount', '/a-máunt/', '', '', 'CAT11', 'B1'),
('PAL0080', 'Annual', '/á-niu-al/', '', '', 'CAT11', 'B1'),
('PAL0081', 'Appeal', '/a-píil/', '', '', 'CAT11', 'B1'),
('PAL0082', 'Appear', '/a-píer/', '', '', 'CAT11', 'B1'),
('PAL0083', 'Arabic', '/á-ra-bik/', '', '', 'CAT11', 'B1'),
('PAL0084', 'Arrive', '/a-ráiv/', '', '', 'CAT11', 'B1'),
('PAL0085', 'Ashore', '/a-shór/', '', '', 'CAT11', 'B1'),
('PAL0086', 'Asleep', '/a-slíip/', '', '', 'CAT11', 'B1'),
('PAL0087', 'Assume', '/a-siúm/', '', '', 'CAT11', 'B1'),
('PAL0088', 'Attack', '/a-ták/', '', '', 'CAT11', 'B1'),
('PAL0089', 'Battle', '/bá-tl/', '', '', 'CAT11', 'B1'),
('PAL0090', 'Become', '/bi-kám/', '', '', 'CAT11', 'B1'),
('PAL0091', 'Behalf', '/bi-jáf/', '', '', 'CAT11', 'B1'),
('PAL0092', 'Belief', '/bi-líif/', '', '', 'CAT11', 'B1'),
('PAL0093', 'Belong', '/bi-lóng/', '', '', 'CAT11', 'B1'),
('PAL0094', 'Better', '/bé-ter/', '', '', 'CAT11', 'B1'),
('PAL0095', 'Bitter', '/bí-ter/', '', '', 'CAT11', 'B1'),
('PAL0096', 'Blazed', '/bléizd/', '', '', 'CAT11', 'B1'),
('PAL0097', 'Blight', '/bláit/', '', '', 'CAT11', 'B1'),
('PAL0098', 'Bonnet', '/bó-net/', '', '', 'CAT11', 'B1'),
('PAL0099', 'Boring', '/bó-ring/', '', '', 'CAT11', 'B1'),
('PAL0100', 'Borrow', '/bó-rou/', '', '', 'CAT11', 'B1'),
('PAL0101', 'Bounce', '/báus/', '', '', 'CAT11', 'B1'),
('PAL0102', 'Bounty', '/báun-ti/', '', '', 'CAT11', 'B1'),
('PAL0103', 'Breath', '/brez/', '', '', 'CAT11', 'B1'),
('PAL0104', 'Budget', '/bá-dtshet/', '', '', 'CAT11', 'B1'),
('PAL0105', 'Burden', '/bér-den/', '', '', 'CAT11', 'B1'),
('PAL0106', 'Bureau', '/biú-rou/', '', '', 'CAT11', 'B1'),
('PAL0107', 'Burrow', '/bá-rou/', '', '', 'CAT11', 'B1'),
('PAL0108', 'Butter', '/bá-ter/', '', '', 'CAT11', 'B1'),
('PAL0109', 'Bygone', '/bái-gon/', '', '', 'CAT11', 'B1'),
('PAL0110', 'Canvas', '/kán-vas/', '', '', 'CAT11', 'B1'),
('PAL0111', 'Cashew', '/ká-shiu/', '', '', 'CAT11', 'B1'),
('PAL0112', 'Caucus', '/kó-kas/', '', '', 'CAT11', 'B1'),
('PAL0113', 'Caught', '/kot/', '', '', 'CAT11', 'B1'),
('PAL0114', 'Chance', '/chans/', '', '', 'CAT11', 'B1'),
('PAL0115', 'Change', '/chéindsh/', '', '', 'CAT11', 'B1'),
('PAL0116', 'Charge', '/chárdsh/', '', '', 'CAT11', 'B1'),
('PAL0117', 'Choose', '/chúus/', '', '', 'CAT11', 'B1'),
('PAL0118', 'Circle', '/sér-kl/', '', '', 'CAT11', 'B1'),
('PAL0119', 'Commit', '/ko-mít/', '', '', 'CAT11', 'B1'),
('PAL0120', 'Common', '/kó-mon/', '', '', 'CAT11', 'B1'),
('PAL0121', 'Comply', '/kom-plái/', '', '', 'CAT11', 'B1'),
('PAL0122', 'Copper', '/kó-per/', '', '', 'CAT11', 'B1'),
('PAL0123', 'Cotton', '/kó-ton/', '', '', 'CAT11', 'B1'),
('PAL0124', 'County', '/káun-ti/', '', '', 'CAT11', 'B1'),
('PAL0125', 'Create', '/kri-éit/', '', '', 'CAT11', 'B1'),
('PAL0126', 'Credit', '/kré-dit/', '', '', 'CAT11', 'B1'),
('PAL0127', 'Damage', '/dá-midsh/', '', '', 'CAT11', 'B1'),
('PAL0128', 'Danger', '/déin-dsher/', '', '', 'CAT11', 'B1'),
('PAL0129', 'Decent', '/dí-sent/', '', '', 'CAT11', 'B1'),
('PAL0130', 'Decide', '/di-sáid/', '', '', 'CAT11', 'B1'),
('PAL0131', 'Defeat', '/di-fíit/', '', '', 'CAT11', 'B1'),
('PAL0132', 'Degree', '/di-gríi/', '', '', 'CAT11', 'B1'),
('PAL0133', 'Demand', '/di-mánd/', '', '', 'CAT11', 'B1'),
('PAL0134', 'Depend', '/di-pénd/', '', '', 'CAT11', 'B1'),
('PAL0135', 'Deploy', '/di-plói/', '', '', 'CAT11', 'B1'),
('PAL0136', 'Desert', '/dé-sert/', '', '', 'CAT11', 'B1'),
('PAL0137', 'Design', '/di-sáin/', '', '', 'CAT11', 'B1'),
('PAL0138', 'Desire', '/di-sáiar/', '', '', 'CAT11', 'B1'),
('PAL0139', 'Detail', '/di-téil/', '', '', 'CAT11', 'B1'),
('PAL0140', 'Device', '/di-váis/', '', '', 'CAT11', 'B1'),
('PAL0141', 'Differ', '/dí-fer/', '', '', 'CAT11', 'B1'),
('PAL0142', 'Double', '/dá-bl/', '', '', 'CAT11', 'B1'),
('PAL0143', 'Effect', '/i-fékt/', '', '', 'CAT11', 'B1'),
('PAL0144', 'Either', '/í-der/', '', '', 'CAT11', 'B1'),
('PAL0145', 'Enable', '/e-néi-bl/', '', '', 'CAT11', 'B1'),
('PAL0146', 'Engage', '/en-géidsh/', '', '', 'CAT11', 'B1'),
('PAL0147', 'Enough', '/i-náf/', '', '', 'CAT11', 'B1'),
('PAL0148', 'Ensure', '/en-shúer/', '', '', 'CAT11', 'B1'),
('PAL0149', 'Entail', '/en-téil/', '', '', 'CAT11', 'B1'),
('PAL0150', 'Entire', '/en-táiar/', '', '', 'CAT11', 'B1'),
('PAL0151', 'Equity', '/é-kui-ti/', '', '', 'CAT11', 'B1'),
('PAL0152', 'Expand', '/ek-spánd/', '', '', 'CAT11', 'B1'),
('PAL0153', 'Expect', '/ek-spékt/', '', '', 'CAT11', 'B1'),
('PAL0154', 'Expert', '/ék-spert/', '', '', 'CAT11', 'B1'),
('PAL0155', 'Extend', '/ek-sténd/', '', '', 'CAT11', 'B1'),
('PAL0156', 'Facing', '/féi-sing/', '', '', 'CAT11', 'B1'),
('PAL0157', 'Famous', '/féi-mos/', '', '', 'CAT11', 'B1'),
('PAL0158', 'Flight', '/flait/', '', '', 'CAT11', 'B1'),
('PAL0159', 'Follow', '/fó-lou/', '', '', 'CAT11', 'B1'),
('PAL0160', 'Forbid', '/for-bíd/', '', '', 'CAT11', 'B1'),
('PAL0161', 'Forget', '/for-gét/', '', '', 'CAT11', 'B1'),
('PAL0162', 'Formal', '/fór-mal/', '', '', 'CAT11', 'B1'),
('PAL0163', 'Former', '/fór-mer/', '', '', 'CAT11', 'B1'),
('PAL0164', 'Freeze', '/friis/', '', '', 'CAT11', 'B1'),
('PAL0165', 'Funnel', '/fá-nel/', '', '', 'CAT11', 'B1'),
('PAL0166', 'Galore', '/ga-lór/', '', '', 'CAT11', 'B1'),
('PAL0167', 'Gather', '/gá-der/', '', '', 'CAT11', 'B1'),
('PAL0168', 'Geared', '/glóu-bal/', '', '', 'CAT11', 'B1'),
('PAL0169', 'Growth', '/gróuz/', '', '', 'CAT11', 'B1'),
('PAL0170', 'Guilty', '/gíl-ti/', '', '', 'CAT11', 'B1'),
('PAL0171', 'Harbor', '/jár-bor/', '', '', 'CAT11', 'B1'),
('PAL0172', 'Hardly', '/shárd-li/', '', '', 'CAT11', 'B1'),
('PAL0173', 'Horror', '/jó-ror/', '', '', 'CAT11', 'B1'),
('PAL0174', 'Hybrid', '/jái-brid/', '', '', 'CAT11', 'B1'),
('PAL0175', 'Ignore', '/ig-nór/', '', '', 'CAT11', 'B1'),
('PAL0176', 'Inform', '/in-fórm/', '', '', 'CAT11', 'B1'),
('PAL0177', 'Insist', '/in-síst/', '', '', 'CAT11', 'B1'),
('PAL0178', 'Intend', '/in-ténd/', '', '', 'CAT11', 'B1'),
('PAL0179', 'Invest', '/in-vést/', '', '', 'CAT11', 'B1'),
('PAL0180', 'Island', '/ái-land/', '', '', 'CAT11', 'B1'),
('PAL0181', 'Kindle', '/kín-dl/', '', '', 'CAT11', 'B1'),
('PAL0182', 'Latter', '/lá-ter/', '', '', 'CAT11', 'B1'),
('PAL0183', 'Letter', '/lé-ter/', '', '', 'CAT11', 'B1'),
('PAL0184', 'Likely', '/láik-li/', '', '', 'CAT11', 'B1'),
('PAL0185', 'Liquid', '/lí-kuid/', '', '', 'CAT11', 'B1'),
('PAL0186', 'Listen', '/lí-sn/', '', '', 'CAT11', 'B1'),
('PAL0187', 'Little', '/lí-tl/', '', '', 'CAT11', 'B1'),
('PAL0188', 'Lonely', '/lóun-li/', '', '', 'CAT11', 'B1'),
('PAL0189', 'Lounge', '/láundsh/', '', '', 'CAT11', 'B1'),
('PAL0190', 'Luxury', '/lák-shu-ri/', '', '', 'CAT11', 'B1'),
('PAL0191', 'Manage', '/má-nidsh/', '', '', 'CAT11', 'B1'),
('PAL0192', 'Market', '/már-ket/', '', '', 'CAT11', 'B1'),
('PAL0193', 'Matter', '/má-ter/', '', '', 'CAT11', 'B1'),
('PAL0194', 'Mature', '/ma-tsiúr/', '', '', 'CAT11', 'B1'),
('PAL0195', 'Mental', '/mén-tal/', '', '', 'CAT11', 'B1'),
('PAL0196', 'Middle', '/mí-dl/', '', '', 'CAT11', 'B1'),
('PAL0197', 'Module', '/mó-diul/', '', '', 'CAT11', 'B1'),
('PAL0198', 'Monkey', '/mán-ki/', '', '', 'CAT11', 'B1'),
('PAL0199', 'Muscle', '/má-sl/', '', '', 'CAT11', 'B1'),
('PAL0200', 'Narrow', '/ná-rou/', '', '', 'CAT11', 'B1'),
('PAL0201', 'Native', '/néi-tiv/', '', '', 'CAT11', 'B1'),
('PAL0202', 'Nearly', '/níer-li/', '', '', 'CAT11', 'B1'),
('PAL0203', 'Needle', '/níi-dl/', '', '', 'CAT11', 'B1'),
('PAL0204', 'Notice', '/nóu-tis/', '', '', 'CAT11', 'B1'),
('PAL0205', 'Obtain', '/ob-téin/', '', '', 'CAT11', 'B1'),
('PAL0206', 'Office', '/ó-fis/', '', '', 'CAT11', 'B1'),
('PAL0207', 'Orange', '/ó-rindsh/', '', '', 'CAT11', 'B1'),
('PAL0208', 'Pencil', '/pén-sil/', '', '', 'CAT11', 'B1'),
('PAL0209', 'Plough', '/pláu/', '', '', 'CAT11', 'B1'),
('PAL0210', 'Pocket', '/pó-ket/', '', '', 'CAT11', 'B1'),
('PAL0211', 'Potato', '/po-téi-tou/', '', '', 'CAT11', 'B1'),
('PAL0212', 'Prefer', '/pri-fér/', '', '', 'CAT11', 'B1'),
('PAL0213', 'Prince', '/prins/', '', '', 'CAT11', 'B1'),
('PAL0214', 'Prison', '/prí-son/', '', '', 'CAT11', 'B1'),
('PAL0215', 'Proper', '/pró-per/', '', '', 'CAT11', 'B1'),
('PAL0216', 'Proven', '/prú-ven/', '', '', 'CAT11', 'B1'),
('PAL0217', 'Pursue', '/per-siú/', '', '', 'CAT11', 'B1'),
('PAL0218', 'Python', '/pái-son/', '', '', 'CAT11', 'B1'),
('PAL0219', 'Recall', '/ri-kól/', '', '', 'CAT11', 'B1'),
('PAL0220', 'Recent', '/rí-sent/', '', '', 'CAT11', 'B1'),
('PAL0221', 'Refuse', '/ri-fiús/', '', '', 'CAT11', 'B1'),
('PAL0222', 'Regime', '/re-shíim/', '', '', 'CAT11', 'B1'),
('PAL0223', 'Regret', '/ri-grét/', '', '', 'CAT11', 'B1'),
('PAL0224', 'Relate', '/ri-léit/', '', '', 'CAT11', 'B1'),
('PAL0225', 'Relief', '/ri-líif/', '', '', 'CAT11', 'B1'),
('PAL0226', 'Remain', '/ri-méin/', '', '', 'CAT11', 'B1'),
('PAL0227', 'Remote', '/ri-móut/', '', '', 'CAT11', 'B1'),
('PAL0228', 'Rescue', '/rés-kiu/', '', '', 'CAT11', 'B1'),
('PAL0229', 'Resent', '/ri-sént/', '', '', 'CAT11', 'B1'),
('PAL0230', 'Retain', '/ri-téin/', '', '', 'CAT11', 'B1'),
('PAL0231', 'Retire', '/ri-táiar/', '', '', 'CAT11', 'B1'),
('PAL0232', 'Reveal', '/ri-víil/', '', '', 'CAT11', 'B1'),
('PAL0233', 'Rhythm', '/rí-dam/', '', '', 'CAT11', 'B1'),
('PAL0234', 'Rugged', '/rá-gid/', '', '', 'CAT11', 'B1'),
('PAL0235', 'Scanty', '/skán-ti/', '', '', 'CAT11', 'B1'),
('PAL0236', 'Scared', '/skérd/', '', '', 'CAT11', 'B1'),
('PAL0237', 'Scenic', '/sí-nik/', '', '', 'CAT11', 'B1'),
('PAL0238', 'Scheme', '/skiim/', '', '', 'CAT11', 'B1'),
('PAL0239', 'School', '/skuul/', '', '', 'CAT11', 'B1'),
('PAL0240', 'Settle', '/sé-tl/', '', '', 'CAT11', 'B1'),
('PAL0241', 'Severe', '/si-víer/', '', '', 'CAT11', 'B1'),
('PAL0242', 'Should', '/shud/', '', '', 'CAT11', 'B1'),
('PAL0243', 'Shrink', '/shrink/', '', '', 'CAT11', 'B1'),
('PAL0244', 'Signal', '/síg-nal/', '', '', 'CAT11', 'B1'),
('PAL0245', 'Silver', '/síl-ver/', '', '', 'CAT11', 'B1'),
('PAL0246', 'Simmer', '/sí-mer/', '', '', 'CAT11', 'B1'),
('PAL0247', 'Simple', '/sím-pl/', '', '', 'CAT11', 'B1'),
('PAL0248', 'Slight', '/slait/', '', '', 'CAT11', 'B1'),
('PAL0249', 'Smooth', '/smuud/', '', '', 'CAT11', 'B1'),
('PAL0250', 'Sorrow', '/só-rou/', '', '', 'CAT11', 'B1'),
('PAL0251', 'Soviet', '/sóu-vi-et/', '', '', 'CAT11', 'B1'),
('PAL0252', 'Sponge', '/spóndsh/', '', '', 'CAT11', 'B1'),
('PAL0253', 'Spread', '/spred/', '', '', 'CAT11', 'B1'),
('PAL0254', 'Spring', '/spring/', '', '', 'CAT11', 'B1'),
('PAL0255', 'Square', '/skuér/', '', '', 'CAT11', 'B1'),
('PAL0256', 'Stable', '/stéi-bl/', '', '', 'CAT11', 'B1'),
('PAL0257', 'Status', '/stá-tus/', '', '', 'CAT11', 'B1'),
('PAL0258', 'Steady', '/sté-di/', '', '', 'CAT11', 'B1'),
('PAL0259', 'Stream', '/striim/', '', '', 'CAT11', 'B1'),
('PAL0260', 'Street', '/striit/', '', '', 'CAT11', 'B1'),
('PAL0261', 'Strict', '/strikt/', '', '', 'CAT11', 'B1'),
('PAL0262', 'Strike', '/straik/', '', '', 'CAT11', 'B1'),
('PAL0263', 'Struck', '/strak/', '', '', 'CAT11', 'B1'),
('PAL0264', 'Submit', '/sab-mít/', '', '', 'CAT11', 'B1'),
('PAL0265', 'Sudden', '/sá-den/', '', '', 'CAT11', 'B1'),
('PAL0266', 'Suffer', '/sá-fer/', '', '', 'CAT11', 'B1'),
('PAL0267', 'Supply', '/sa-plái/', '', '', 'CAT11', 'B1'),
('PAL0268', 'Thread', '/zred/', '', '', 'CAT11', 'B1'),
('PAL0269', 'Thrive', '/szráiv/', '', '', 'CAT11', 'B1'),
('PAL0270', 'Throat', '/zróut/', '', '', 'CAT11', 'B1'),
('PAL0271', 'Ticket', '/tí-ket/', '', '', 'CAT11', 'B1'),
('PAL0272', 'Tiptoe', '/típ-tou/', '', '', 'CAT11', 'B1'),
('PAL0273', 'Tissue', '/tí-shiu/', '', '', 'CAT11', 'B1'),
('PAL0274', 'Tongue', '/tong/', '', '', 'CAT11', 'B1'),
('PAL0275', 'Treaty', '/trí-ti/', '', '', 'CAT11', 'B1'),
('PAL0276', 'Tuning', '/tiú-ning/', '', '', 'CAT11', 'B1'),
('PAL0277', 'Tunnel', '/tá-nel/', '', '', 'CAT11', 'B1'),
('PAL0278', 'Unable', '/an-éi-bl/', '', '', 'CAT11', 'B1'),
('PAL0279', 'Unfair', '/an-fér/', '', '', 'CAT11', 'B1'),
('PAL0280', 'United', '/iu-nái-tid/', '', '', 'CAT11', 'B1'),
('PAL0281', 'Useful', '/iús-ful/', '', '', 'CAT11', 'B1'),
('PAL0282', 'Utmost', '/át-moust/', '', '', 'CAT11', 'B1'),
('PAL0283', 'Vacuum', '/vá-kium/', '', '', 'CAT11', 'B1'),
('PAL0284', 'Virtue', '/vér-tsiu/', '', '', 'CAT11', 'B1'),
('PAL0285', 'Voyage', '/vói-idsh/', '', '', 'CAT11', 'B1'),
('PAL0286', 'Wander', '/uón-der/', '', '', 'CAT11', 'B1'),
('PAL0287', 'Wealth', '/uelz/', '', '', 'CAT11', 'B1'),
('PAL0288', 'Weekly', '/uíik-li/', '', '', 'CAT11', 'B1'),
('PAL0289', 'Weight', '/ueit/', '', '', 'CAT11', 'B1'),
('PAL0290', 'Widget', '/uí-dshet/', '', '', 'CAT11', 'B1'),
('PAL0291', 'Window', '/uín-dou/', '', '', 'CAT11', 'B1'),
('PAL0292', 'Winter', '/uín-ter/', '', '', 'CAT11', 'B1');

--7 LETTERS (DIEGO)
INSERT INTO palabra VALUES
('PAL0293', 'Account', '/a-káunt/', '', '', 'CAT12', 'B1'),
('PAL0294', 'Achieve', '/a-chíiv/', '', '', 'CAT12', 'B1'),
('PAL0295', 'Acquire', '/a-kuáiar/', '', '', 'CAT12', 'B1'),
('PAL0296', 'Airline', '/ér-lain/', '', '', 'CAT12', 'B1'),
('PAL0297', 'Amazing', '/a-méi-sing/', '', '', 'CAT12', 'B1'),
('PAL0298', 'Analyst', '/á-na-list/', '', '', 'CAT12', 'B1'),
('PAL0299', 'Anguish', '/áng-guish/', '', '', 'CAT12', 'B1'),
('PAL0300', 'Another', '/a-ná-der/', '', '', 'CAT12', 'B1'),
('PAL0301', 'Anxious', '/áng-shos/', '', '', 'CAT12', 'B1'),
('PAL0302', 'Approve', '/a-prúuv/', '', '', 'CAT12', 'B1'),
('PAL0303', 'Arrange', '/a-réindsh/', '', '', 'CAT12', 'B1'),
('PAL0304', 'Arrival', '/a-rái-val/', '', '', 'CAT12', 'B1'),
('PAL0305', 'Attempt', '/a-témpt/', '', '', 'CAT12', 'B1'),
('PAL0306', 'Attract', '/a-trákt/', '', '', 'CAT12', 'B1'),
('PAL0307', 'Auction', '/ók-shen/', '', '', 'CAT12', 'B1'),
('PAL0308', 'Awkward', '/ók-uerd/', '', '', 'CAT12', 'B1'),
('PAL0309', 'Balance', '/bá-lans/', '', '', 'CAT12', 'B1'),
('PAL0310', 'Beliefs', '/bi-líifs/', '', '', 'CAT12', 'B1'),
('PAL0311', 'Believe', '/bi-líiv/', '', '', 'CAT12', 'B1'),
('PAL0312', 'Broader', '/bró-der/', '', '', 'CAT12', 'B1'),
('PAL0313', 'Brought', '/brot/', '', '', 'CAT12', 'B1'),
('PAL0314', 'Capable', '/kéi-pa-bl/', '', '', 'CAT12', 'B1'),
('PAL0315', 'Careful', '/kér-ful/', '', '', 'CAT12', 'B1'),
('PAL0316', 'Certain', '/sér-ten/', '', '', 'CAT12', 'B1'),
('PAL0317', 'Chattel', '/chá-tel/', '', '', 'CAT12', 'B1'),
('PAL0318', 'Chronic', '/kró-nik/', '', '', 'CAT12', 'B1'),
('PAL0319', 'Citizen', '/sí-ti-sen/', '', '', 'CAT12', 'B1'),
('PAL0320', 'Classic', '/klá-sik/', '', '', 'CAT12', 'B1'),
('PAL0321', 'Comfort', '/kám-fort/', '', '', 'CAT12', 'B1'),
('PAL0322', 'Company', '/kám-pa-ni/', '', '', 'CAT12', 'B1'),
('PAL0323', 'Compare', '/kom-pér/', '', '', 'CAT12', 'B1'),
('PAL0324', 'Compete', '/kom-píit/', '', '', 'CAT12', 'B1'),
('PAL0325', 'Complex', '/kóm-pleks/', '', '', 'CAT12', 'B1'),
('PAL0326', 'Concern', '/kon-sérn/', '', '', 'CAT12', 'B1'),
('PAL0327', 'Confirm', '/kon-férm/', '', '', 'CAT12', 'B1'),
('PAL0328', 'Connect', '/ko-nékt/', '', '', 'CAT12', 'B1'),
('PAL0329', 'Consent', '/kon-sént/', '', '', 'CAT12', 'B1'),
('PAL0330', 'Contain', '/kon-téin/', '', '', 'CAT12', 'B1'),
('PAL0331', 'Control', '/kon-tróul/', '', '', 'CAT12', 'B1'),
('PAL0332', 'Correct', '/ko-rékt/', '', '', 'CAT12', 'B1'),
('PAL0333', 'Country', '/kán-tri/', '', '', 'CAT12', 'B1'),
('PAL0334', 'Courage', '/ká-ridsh/', '', '', 'CAT12', 'B1'),
('PAL0335', 'Curious', '/kiú-ri-os//', '', '', 'CAT12', 'B1'),
('PAL0336', 'Current', '/ká-rent/', '', '', 'CAT12', 'B1'),
('PAL0337', 'Curtain', '/kér-ten/', '', '', 'CAT12', 'B1'),
('PAL0338', 'Cushion', '/kú-shen/', '', '', 'CAT12', 'B1'),
('PAL0339', 'Decorum', '/di-kó-ram/', '', '', 'CAT12', 'B1'),
('PAL0340', 'Deserve', '/di-sérv/', '', '', 'CAT12', 'B1'),
('PAL0341', 'Dessert', '/di-sért/', '', '', 'CAT12', 'B1'),
('PAL0342', 'Destroy', '/di-strói/', '', '', 'CAT12', 'B1'),
('PAL0343', 'Develop', '/di-vé-lop/', '', '', 'CAT12', 'B1'),
('PAL0344', 'Discuss', '/dis-kás/', '', '', 'CAT12', 'B1'),
('PAL0345', 'Disease', '/di-síis/', '', '', 'CAT12', 'B1'),
('PAL0346', 'Disgust', '/dis-gást/', '', '', 'CAT12', 'B1'),
('PAL0347', 'Dislike', '/dis-láik/', '', '', 'CAT12', 'B1'),
('PAL0348', 'Driving', '/drái-ving/', '', '', 'CAT12', 'B1'),
('PAL0349', 'Eastern', '/íis-tern/', '', '', 'CAT12', 'B1'),
('PAL0350', 'Economy', '/i-kó-no-mi/', '', '', 'CAT12', 'B1'),
('PAL0351', 'Embassy', '/ém-ba-si/', '', '', 'CAT12', 'B1'),
('PAL0352', 'Enhance', '/en-jáns/', '', '', 'CAT12', 'B1'),
('PAL0353', 'Ensnare', '/en-snér/', '', '', 'CAT12', 'B1'),
('PAL0354', 'Enzymes', '/én-saims/', '', '', 'CAT12', 'B1'),
('PAL0355', 'Evening', '/íiv-ning/', '', '', 'CAT12', 'B1'),
('PAL0356', 'Examine', '/eg-sá-min/', '', '', 'CAT12', 'B1'),
('PAL0357', 'Excited', '/ek-sái-tid/', '', '', 'CAT12', 'B1'),
('PAL0358', 'Exhibit', '/eg-sí-bit/', '', '', 'CAT12', 'B1'),
('PAL0359', 'Explain', '/ek-spléin/', '', '', 'CAT12', 'B1'),
('PAL0360', 'Explore', '/ek-splór/', '', '', 'CAT12', 'B1'),
('PAL0361', 'Express', '/ek-sprés/', '', '', 'CAT12', 'B1'),
('PAL0362', 'Feather', '/fé-der/', '', '', 'CAT12', 'B1'),
('PAL0363', 'Feature', '/fí-tsiur/', '', '', 'CAT12', 'B1'),
('PAL0364', 'Feeling', '/fíi-ling/', '', '', 'CAT12', 'B1'),
('PAL0365', 'Fellow', '/fé-lou/', '', '', 'CAT12', 'B1'),
('PAL0366', 'Fiction', '/fík-shen/', '', '', 'CAT12', 'B1'),
('PAL0367', 'Foreign', '/fó-ren/', '', '', 'CAT12', 'B1'),
('PAL0368', 'Forgive', '/for-gív/', '', '', 'CAT12', 'B1'),
('PAL0369', 'Forward', '/fór-uerd/', '', '', 'CAT12', 'B1'),
('PAL0370', 'Freeman', '/fríi-man/', '', '', 'CAT12', 'B1'),
('PAL0371', 'Friable', '/frái-a-bl/', '', '', 'CAT12', 'B1'),
('PAL0372', 'Genuine', '/dshén-iu-in/', '', '', 'CAT12', 'B1'),
('PAL0373', 'Harmony', '/jár-mo-ni/', '', '', 'CAT12', 'B1'),
('PAL0374', 'Healthy', '/jél-zi/', '', '', 'CAT12', 'B1'),
('PAL0375', 'Hearing', '/jíe-ring/', '', '', 'CAT12', 'B1'),
('PAL0376', 'Helpful', '/jélp-ful/', '', '', 'CAT12', 'B1'),
('PAL0377', 'Highway', '/jái-uei/', '', '', 'CAT12', 'B1'),
('PAL0378', 'History', '/jís-to-ri/', '', '', 'CAT12', 'B1'),
('PAL0379', 'Holiday', '/jó-li-dei/', '', '', 'CAT12', 'B1'),
('PAL0380', 'Illegal', '/i-lí-gal/', '', '', 'CAT12', 'B1'),
('PAL0381', 'Illness', '/íl-nes/', '', '', 'CAT12', 'B1'),
('PAL0382', 'Impress', '/im-prés/', '', '', 'CAT12', 'B1'),
('PAL0383', 'Improve', '/im-prúuv/', '', '', 'CAT12', 'B1'),
('PAL0384', 'Impulse', '/ím-pals/', '', '', 'CAT12', 'B1'),
('PAL0385', 'Include', '/in-klúud/', '', '', 'CAT12', 'B1'),
('PAL0386', 'Initial', '/i-ní-shal/', '', '', 'CAT12', 'B1'),
('PAL0387', 'Install', '/in-stól/', '', '', 'CAT12', 'B1'),
('PAL0388', 'Involve', '/in-vólv/', '', '', 'CAT12', 'B1'),
('PAL0389', 'Jointly', '/dshóint-li/', '', '', 'CAT12', 'B1'),
('PAL0390', 'Journey', '/dshér-ni/', '', '', 'CAT12', 'B1'),
('PAL0391', 'Justify', '/dshás-ti-fai/', '', '', 'CAT12', 'B1'),
('PAL0392', 'Kingdom', '/kíng-dom/', '', '', 'CAT12', 'B1'),
('PAL0393', 'Kitchen', '/kí-tshen/', '', '', 'CAT12', 'B1'),
('PAL0394', 'Leading', '/líi-ding/', '', '', 'CAT12', 'B1'),
('PAL0395', 'Leather', '/lé-der/', '', '', 'CAT12', 'B1'),
('PAL0396', 'Leisure', '/lé-shur/', '', '', 'CAT12', 'B1'),
('PAL0397', 'Manager', '/má-na-dsher/', '', '', 'CAT12', 'B1'),
('PAL0398', 'Massive', '/má-siv/', '', '', 'CAT12', 'B1'),
('PAL0399', 'Maximum', '/mák-si-mom/', '', '', 'CAT12', 'B1'),
('PAL0400', 'Measure', '/mé-shur/', '', '', 'CAT12', 'B1'),
('PAL0401', 'Seaweed', '/síi-uiid/', '', '', 'CAT12', 'B1'),
('PAL0402', 'Mention', '/mén-shen/', '', '', 'CAT12', 'B1'),
('PAL0403', 'Midwife', '/míd-uaif/', '', '', 'CAT12', 'B1'),
('PAL0404', 'Minimum', '/mí-ni-mom/', '', '', 'CAT12', 'B1'),
('PAL0405', 'Mission', '/mí-shen/', '', '', 'CAT12', 'B1'),
('PAL0406', 'Monthly', '/mánz-li/', '', '', 'CAT12', 'B1'),
('PAL0407', 'Neglect', '/ni-glékt/', '', '', 'CAT12', 'B1'),
('PAL0408', 'Neither', '/ní-der/', '', '', 'CAT12', 'B1'),
('PAL0409', 'Nervous', '/nér-vos/', '', '', 'CAT12', 'B1'),
('PAL0410', 'Network', '/nét-uerk/', '', '', 'CAT12', 'B1'),
('PAL0411', 'Nowhere', '/nóu-juer/', '', '', 'CAT12', 'B1'),
('PAL0412', 'Observe', '/ob-sérv/', '', '', 'CAT12', 'B1'),
('PAL0413', 'Obvious', '/ób-vi-os/', '', '', 'CAT12', 'B1'),
('PAL0414', 'Operate', '/ó-pe-reit/', '', '', 'CAT12', 'B1'),
('PAL0415', 'Outside', '/aut-sáid/', '', '', 'CAT12', 'B1'),
('PAL0416', 'Overall', '/óu-ver-ol/', '', '', 'CAT12', 'B1'),
('PAL0417', 'Parking', '/pár-king/', '', '', 'CAT12', 'B1'),
('PAL0418', 'Passage', '/pá-sidsh/', '', '', 'CAT12', 'B1'),
('PAL0419', 'Patient', '/péi-shent/', '', '', 'CAT12', 'B1'),
('PAL0420', 'Paucity', '/pó-si-ti/', '', '', 'CAT12', 'B1'),
('PAL0421', 'Payment', '/péi-ment/', '', '', 'CAT12', 'B1'),
('PAL0422', 'Perfect', '/pér-fekt/', '', '', 'CAT12', 'B1'),
('PAL0423', 'Perform', '/per-fórm/', '', '', 'CAT12', 'B1'),
('PAL0424', 'Phoneme', '/fóu-niim/', '', '', 'CAT12', 'B1'),
('PAL0425', 'Possess', '/po-sés/', '', '', 'CAT12', 'B1'),
('PAL0426', 'Powdery', '/páu-de-ri/', '', '', 'CAT12', 'B1'),
('PAL0427', 'Prepare', '/pri-pér/', '', '', 'CAT12', 'B1'),
('PAL0428', 'Pretend', '/pri-ténd/', '', '', 'CAT12', 'B1'),
('PAL0429', 'Prevent', '/pri-vént/', '', '', 'CAT12', 'B1'),
('PAL0430', 'Proceed', '/pro-síid/', '', '', 'CAT12', 'B1'),
('PAL0431', 'Process', '/pró-ses/', '', '', 'CAT12', 'B1'),
('PAL0432', 'Produce', '/pro-diús/', '', '', 'CAT12', 'B1'),
('PAL0433', 'Promise', '/pró-mis/', '', '', 'CAT12', 'B1'),
('PAL0434', 'Propose', '/pro-póus/', '', '', 'CAT12', 'B1'),
('PAL0435', 'Purpose', '/pér-pos/', '', '', 'CAT12', 'B1'),
('PAL0436', 'Qualify', '/kuó-li-fai/', '', '', 'CAT12', 'B1'),
('PAL0437', 'Quality', '/kuó-li-ti/', '', '', 'CAT12', 'B1'),
('PAL0438', 'Quarter', '/kuór-ter/', '', '', 'CAT12', 'B1'),
('PAL0439', 'Railway', '/réil-uei/', '', '', 'CAT12', 'B1'),
('PAL0440', 'Reading', '/ríi-ding/', '', '', 'CAT12', 'B1'),
('PAL0441', 'Realize', '/rí-a-lais/', '', '', 'CAT12', 'B1'),
('PAL0442', 'Receipt', '/ri-síit/', '', '', 'CAT12', 'B1'),
('PAL0443', 'Receive', '/ri-síiv/', '', '', 'CAT12', 'B1'),
('PAL0444', 'Reflect', '/ri-flékt/', '', '', 'CAT12', 'B1'),
('PAL0445', 'Relieve', '/ri-líiv/', '', '', 'CAT12', 'B1'),
('PAL0446', 'Replace', '/ri-pléis/', '', '', 'CAT12', 'B1'),
('PAL0447', 'Request', '/ri-kuést/', '', '', 'CAT12', 'B1'),
('PAL0448', 'Require', '/ri-kuáiar/', '', '', 'CAT12', 'B1'),
('PAL0449', 'Revenge', '/ri-véndsh/', '', '', 'CAT12', 'B1'),
('PAL0450', 'Routine', '/ruu-tíin/', '', '', 'CAT12', 'B1'),
('PAL0451', 'Satisfy', '/sá-tis-fai/', '', '', 'CAT12', 'B1'),
('PAL0452', 'Savings', '/séi-vings/', '', '', 'CAT12', 'B1'),
('PAL0453', 'Science', '/sái-ens/', '', '', 'CAT12', 'B1'),
('PAL0454', 'Serious', '/sí-ri-os/', '', '', 'CAT12', 'B1'),
('PAL0455', 'Servant', '/sér-vant/', '', '', 'CAT12', 'B1'),
('PAL0456', 'Society', '/so-sái-e-ti/', '', '', 'CAT12', 'B1'),
('PAL0457', 'Somehow', '/sám-jau/', '', '', 'CAT12', 'B1'),
('PAL0458', 'Specify', '/espé-si-fai/', '', '', 'CAT12', 'B1'),
('PAL0459', 'Station', '/stéi-shen/', '', '', 'CAT12', 'B1'),
('PAL0460', 'Stomach', '/stó-mak/', '', '', 'CAT12', 'B1'),
('PAL0461', 'Strange', '/stréindsh/', '', '', 'CAT12', 'B1'),
('PAL0462', 'Stretch', '/stretsh/', '', '', 'CAT12', 'B1'),
('PAL0463', 'Subject', '/sáb-dshekt/', '', '', 'CAT12', 'B1'),
('PAL0464', 'Succeed', '/sak-síid/', '', '', 'CAT12', 'B1'),
('PAL0465', 'Suggest', '/sag-dshést/', '', '', 'CAT12', 'B1'),
('PAL0466', 'Support', '/sa-pórt/', '', '', 'CAT12', 'B1'),
('PAL0467', 'Suppose', '/sa-póus/', '', '', 'CAT12', 'B1'),
('PAL0468', 'Survive', '/ser-váiv/', '', '', 'CAT12', 'B1'),
('PAL0469', 'Thought', '/zot/', '', '', 'CAT12', 'B1'),
('PAL0470', 'Thunder', '/zán-der/', '', '', 'CAT12', 'B1'),
('PAL0471', 'Triumph', '/trái-umf/', '', '', 'CAT12', 'B1'),
('PAL0472', 'Trouble', '/trá-bl/', '', '', 'CAT12', 'B1'),
('PAL0473', 'Typical', '/tí-pi-kal/', '', '', 'CAT12', 'B1'),
('PAL0474', 'Unusual', '/an-iú-shu-al/', '', '', 'CAT12', 'B1'),
('PAL0475', 'Various', '/vé-ri-os/', '', '', 'CAT12', 'B1'),
('PAL0476', 'Venture', '/vén-tsiur/', '', '', 'CAT12', 'B1'),
('PAL0477', 'Violent', '/vái-o-lent/', '', '', 'CAT12', 'B1'),
('PAL0478', 'Visible', '/ví-si-bl/', '', '', 'CAT12', 'B1'),
('PAL0479', 'Weather', '/ué-der/', '', '', 'CAT12', 'B1'),
('PAL0480', 'Western', '/ués-tern/', '', '', 'CAT12', 'B1'),
('PAL0481', 'Whistle', '/uís-l/', '', '', 'CAT12', 'B1'),
('PAL0482', 'Willing', '/uí-ling/', '', '', 'CAT12', 'B1'),
('PAL0483', 'Writing', '/rái-ting/', '', '', 'CAT12', 'B1');

--8 LETTERS (DIEGO) (hasta 650)
INSERT INTO palabra VALUES
('PAL0484', 'Accuracy', '/á-kiu-ra-si/', '', '', 'CAT13', 'B1'),
('PAL0485', 'Accurate', '/á-kiu-ret/', '', '', 'CAT13', 'B1'),
('PAL0486', 'Aeration', '/e-réi-shen/', '', '', 'CAT13', 'B1'),
('PAL0487', 'Alliance', '/a-lái-ans/', '', '', 'CAT13', 'B1'),
('PAL0488', 'Almighty', '/ol-mái-ti/', '', '', 'CAT13', 'B1'),
('PAL0489', 'Announce', '/a-náuns/', '', '', 'CAT13', 'B1'),
('PAL0490', 'Anointed', '/a-nóin-tid/', '', '', 'CAT13', 'B1'),
('PAL0491', 'Antihero', '/án-ti-jí-rou/', '', '', 'CAT13', 'B1'),
('PAL0492', 'Appendix', '/a-pén-diks/', '', '', 'CAT13', 'B1'),
('PAL0493', 'Approach', '/a-próutsh/', '', '', 'CAT13', 'B1'),
('PAL0494', 'Approval', '/a-prúu-val/', '', '', 'CAT13', 'B1'),
('PAL0495', 'Argument', '/ár-giu-ment/', '', '', 'CAT13', 'B1'),
('PAL0496', 'Astonish', '/as-tó-nish/', '', '', 'CAT13', 'B1'),
('PAL0497', 'Baritone', '/bá-ri-toun/', '', '', 'CAT13', 'B1'),
('PAL0498', 'Behavior', '/bi-héi-vior/', '', '', 'CAT13', 'B1'),
('PAL0499', 'Boundary', '/báun-da-ri/', '', '', 'CAT13', 'B1'),
('PAL0500', 'Breeding', '//bríi-ding//', '', '', 'CAT13', 'B1'),
('PAL0501', 'Building', '/bíl-ding/', '', '', 'CAT13', 'B1'),
('PAL0502', 'Business', '/bís-nes/', '', '', 'CAT13', 'B1'),
('PAL0503', 'Campaign', '/kam-péin/', '', '', 'CAT13', 'B1'),
('PAL0504', 'Carriage', '/ká-ridsh/', '', '', 'CAT13', 'B1'),
('PAL0505', 'Cautious', '/kó-shos/', '', '', 'CAT13', 'B1'),
('PAL0506', 'Chemical', '/ké-mi-kal/', '', '', 'CAT13', 'B1'),
('PAL0507', 'Churlish', '/chér-lish/', '', '', 'CAT13', 'B1'),
('PAL0508', 'Complain', '/kom-pléin/', '', '', 'CAT13', 'B1'),
('PAL0509', 'Coverage', '/ká-ve-ridsh/', '', '', 'CAT13', 'B1'),
('PAL0510', 'Creative', '/kri-éi-tiv/', '', '', 'CAT13', 'B1'),
('PAL0511', 'Cultural', '/kál-tshe-ral/', '', '', 'CAT13', 'B1'),
('PAL0512', 'Daughter', '/dó-ter/', '', '', 'CAT13', 'B1'),
('PAL0513', 'Decision', '/di-sí-shen/', '', '', 'CAT13', 'B1'),
('PAL0514', 'Deletion', '/di-lí-shen/', '', '', 'CAT13', 'B1'),
('PAL0515', 'Designer', '/di-sái-ner/', '', '', 'CAT13', 'B1'),
('PAL0516', 'Disagree', '/dis-a-gríi/', '', '', 'CAT13', 'B1'),
('PAL0517', 'Disclose', '/dis-klóus/', '', '', 'CAT13', 'B1'),
('PAL0518', 'Distinct', '/dis-tínkt/', '', '', 'CAT13', 'B1'),
('PAL0519', 'Dizzying', '/dí-si-ing/', '', '', 'CAT13', 'B1'),
('PAL0520', 'Doubtful', '/dáut-ful/', '', '', 'CAT13', 'B1'),
('PAL0521', 'Downtown', '/daun-táun/', '', '', 'CAT13', 'B1'),
('PAL0522', 'Dramatic', '/dra-má-tik/', '', '', 'CAT13', 'B1'),
('PAL0523', 'Dynamics', '/dai-ná-miks/', '', '', 'CAT13', 'B1'),
('PAL0524', 'Eligible', '/é-li-dshi-bl/', '', '', 'CAT13', 'B1'),
('PAL0525', 'Emphasis', '/ém-fa-sis/', '', '', 'CAT13', 'B1'),
('PAL0526', 'Enormous', '/i-nór-mos/', '', '', 'CAT13', 'B1'),
('PAL0527', 'Evacuees', '/i-va-kiu-íis/', '', '', 'CAT13', 'B1'),
('PAL0528', 'Exchange', '/eks-chéindsh/', '', '', 'CAT13', 'B1'),
('PAL0529', 'Exciting', '/ek-sái-ting/', '', '', 'CAT13', 'B1'),
('PAL0530', 'External', '/eks-tér-nal/', '', '', 'CAT13', 'B1'),
('PAL0531', 'Familiar', '/fa-mí-liar/', '', '', 'CAT13', 'B1'),
('PAL0532', 'Featured', '/fí-tsiurd/', '', '', 'CAT13', 'B1'),
('PAL0533', 'Firewall', '/fáiar-uol/', '', '', 'CAT13', 'B1'),
('PAL0534', 'Foothill', '/fút-jil/', '', '', 'CAT13', 'B1'),
('PAL0535', 'Foremost', '/fór-moust/', '', '', 'CAT13', 'B1'),
('PAL0536', 'Formerly', '/fór-mer-li/', '', '', 'CAT13', 'B1'),
('PAL0537', 'Frazzled', '/frá-suld/', '', '', 'CAT13', 'B1'),
('PAL0538', 'Frequent', '/frí-kuent/', '', '', 'CAT13', 'B1'),
('PAL0539', 'Friendly', '/frénd-li/', '', '', 'CAT13', 'B1'),
('PAL0540', 'Gelation', '/tshe-léi-shen/', '', '', 'CAT13', 'B1'),
('PAL0541', 'Generate', '/dshé-ne-reit/', '', '', 'CAT13', 'B1'),
('PAL0542', 'Genomics', '/dshi-nó-miks/', '', '', 'CAT13', 'B1'),
('PAL0543', 'Gentleman', '/dshén-tl-man/', '', '', 'CAT13', 'B1'),
('PAL0544', 'Governor', '/gá-ver-nor/', '', '', 'CAT13', 'B1'),
('PAL0545', 'Guidance', '/gái-dans/', '', '', 'CAT13', 'B1'),
('PAL0546', 'Hawthorn', '/jó-zorn/', '', '', 'CAT13', 'B1'),
('PAL0547', 'Heraldry', '/hé-ral-dri/', '', '', 'CAT13', 'B1'),
('PAL0548', 'Hesitate', '/jé-si-teit/', '', '', 'CAT13', 'B1'),
('PAL0549', 'Homeless', '/jóum-les/', '', '', 'CAT13', 'B1'),
('PAL0550', 'Ideation', '/ai-di-éi-shen/', '', '', 'CAT13', 'B1'),
('PAL0551', 'Identify', '/ai-dén-ti-fai/', '', '', 'CAT13', 'B1'),
('PAL0552', 'Imperial', '/im-pí-ri-al/', '', '', 'CAT13', 'B1'),
('PAL0553', 'Increase', '/in-kríis/', '', '', 'CAT13', 'B1'),
('PAL0554', 'Indebted', '/in-dé-tid/', '', '', 'CAT13', 'B1'),
('PAL0555', 'Indicate', '/ín-di-keit/', '', '', 'CAT13', 'B1'),
('PAL0556', 'Industry', '/ín-das-tri/', '', '', 'CAT13', 'B1'),
('PAL0557', 'Inherent', '/in-jé-rent/', '', '', 'CAT13', 'B1'),
('PAL0558', 'Initiate', '/i-ní-shi-eit/', '', '', 'CAT13', 'B1'),
('PAL0559', 'Involved', '/in-vólvd/', '', '', 'CAT13', 'B1'),
('PAL0560', 'Iodinate', '/ái-o-di-neit/', '', '', 'CAT13', 'B1'),
('PAL0561', 'Judgement', '/dshádsh-ment/', '', '', 'CAT13', 'B1'),
('PAL0562', 'Judicial', '/dshu-dí-shal/', '', '', 'CAT13', 'B1'),
('PAL0563', 'Language', '/láng-guidsh/', '', '', 'CAT13', 'B1'),
('PAL0564', 'Legation', '/li-géi-shen/', '', '', 'CAT13', 'B1'),
('PAL0565', 'Literary', '/lí-te-ra-ri/', '', '', 'CAT13', 'B1'),
('PAL0566', 'Maintain', '/mein-téin/', '', '', 'CAT13', 'B1'),
('PAL0567', 'Marriage', '/má-ridsh/', '', '', 'CAT13', 'B1'),
('PAL0568', 'Material', '//ma-tí-ri-al//', '', '', 'CAT13', 'B1'),
('PAL0569', 'Maximize', '/mák-si-mais/', '', '', 'CAT13', 'B1'),
('PAL0570', 'Measured', '/mé-shurd/', '', '', 'CAT13', 'B1'),
('PAL0571', 'Minstrel', '/míns-trel/', '', '', 'CAT13', 'B1'),
('PAL0572', 'Mortgage', '/mór-gidsh/', '', '', 'CAT13', 'B1'),
('PAL0573', 'Mountain', '/máun-ten/', '', '', 'CAT13', 'B1'),
('PAL0574', 'Nauseous', '/nó-shos/', '', '', 'CAT13', 'B1'),
('PAL0575', 'Negative', '/né-ga-tiv/', '', '', 'CAT13', 'B1'),
('PAL0576', 'Northern', '/nór-dern/', '', '', 'CAT13', 'B1'),
('PAL0577', 'Numerous', '/niú-me-ros/', '', '', 'CAT13', 'B1'),
('PAL0578', 'Nuzzling', '/ná-sling/', '', '', 'CAT13', 'B1'),
('PAL0579', 'Official', '/ná-sling/', '', '', 'CAT13', 'B1'),
('PAL0580', 'Official', '/o-fí-shal/', '', '', 'CAT13', 'B1'),
('PAL0581', 'Opposite', '/ó-po-sit/', '', '', 'CAT13', 'B1'),
('PAL0582', 'Organize', '/ór-ga-nais/', '', '', 'CAT13', 'B1'),
('PAL0583', 'Original', '/o-rí-dshi-nal/', '', '', 'CAT13', 'B1'),
('PAL0584', 'Ornament', '/ór-na-ment/', '', '', 'CAT13', 'B1'),
('PAL0585', 'Overcome', '/ou-ver-kám/', '', '', 'CAT13', 'B1'),
('PAL0586', 'Overhead', '/ou-ver-jéd/', '', '', 'CAT13', 'B1'),
('PAL0587', 'Overtake', '/ou-ver-téik/', '', '', 'CAT13', 'B1'),
('PAL0588', 'Parallel', '/pá-ra-lel/', '', '', 'CAT13', 'B1'),
('PAL0589', 'Patented', '/pá-ten-tid/', '', '', 'CAT13', 'B1'),
('PAL0590', 'Peaceful', '/píis-ful/', '', '', 'CAT13', 'B1'),
('PAL0591', 'Persuade', '/per-suéid/', '', '', 'CAT13', 'B1'),
('PAL0592', 'Physical', '/fí-si-kal/', '', '', 'CAT13', 'B1'),
('PAL0593', 'Pleasant', '/fí-si-kal/', '', '', 'CAT13', 'B1'),
('PAL0594', 'Pleasant', '/plé-sant/', '', '', 'CAT13', 'B1'),
('PAL0595', 'Pleasure', '/plé-shur/', '', '', 'CAT13', 'B1'),
('PAL0596', 'Portable', '/pór-ta-bl/', '', '', 'CAT13', 'B1'),
('PAL0597', 'Postpone', '/poust-póun/', '', '', 'CAT13', 'B1'),
('PAL0598', 'Powerful', '/páu-er-ful/', '', '', 'CAT13', 'B1'),
('PAL0599', 'Previous', '/prí-vi-os/', '', '', 'CAT13', 'B1'),
('PAL0600', 'Profound', '/pro-fáund/', '', '', 'CAT13', 'B1'),
('PAL0601', 'Property', '/pró-per-ti/', '', '', 'CAT13', 'B1'),
('PAL0602', 'Protocol', '/pró-to-kol/', '', '', 'CAT13', 'B1'),
('PAL0603', 'Publicly', '/páb-lik-li/', '', '', 'CAT13', 'B1'),
('PAL0604', 'Purchase', '/pér-tshes/', '', '', 'CAT13', 'B1'),
('PAL0605', 'Reaction', '/ri-ák-shen/', '', '', 'CAT13', 'B1'),
('PAL0606', 'Relation', '/ri-léi-shen/', '', '', 'CAT13', 'B1'),
('PAL0607', 'Reliable', '/ri-lái-a-bl/', '', '', 'CAT13', 'B1'),
('PAL0608', 'Reliance', '/ri-lái-ans/', '', '', 'CAT13', 'B1'),
('PAL0609', 'Religion', '/ri-lí-dshon/', '', '', 'CAT13', 'B1'),
('PAL0610', 'Remember', '/ri-mém-ber/', '', '', 'CAT13', 'B1'),
('PAL0611', 'Research', '/ri-sérsh/', '', '', 'CAT13', 'B1'),
('PAL0612', 'Rigorous', '/rí-go-ros/', '', '', 'CAT13', 'B1'),
('PAL0613', 'Roadside', '/róud-said/', '', '', 'CAT13', 'B1'),
('PAL0614', 'Scenario', '/si-ná-ri-ou/', '', '', 'CAT13', 'B1'),
('PAL0615', 'Scissors', '/sí-sors/', '', '', 'CAT13', 'B1'),
('PAL0616', 'Scornful', '/skórn-ful/', '', '', 'CAT13', 'B1'),
('PAL0617', 'Scrutiny', '/skrúu-ti-ni/', '', '', 'CAT13', 'B1'),
('PAL0618', 'Sergeant', '/sár-dshent/', '', '', 'CAT13', 'B1'),
('PAL0619', 'Sherbert', '/shér-bert/', '', '', 'CAT13', 'B1'),
('PAL0620', 'Shortage', '/shór-tidsh/', '', '', 'CAT13', 'B1'),
('PAL0621', 'Skillful', '/skíl-ful/', '', '', 'CAT13', 'B1'),
('PAL0622', 'Southern', '/sá-dern/', '', '', 'CAT13', 'B1'),
('PAL0623', 'Specific', '/spe-sí-fik/', '', '', 'CAT13', 'B1'),
('PAL0624', 'Spectrum', '/espék-trom/', '', '', 'CAT13', 'B1'),
('PAL0625', 'Spotless', '/espót-les/', '', '', 'CAT13', 'B1'),
('PAL0626', 'Standard', '/están-dard/', '', '', 'CAT13', 'B1'),
('PAL0627', 'Stocking', '/estó-king/', '', '', 'CAT13', 'B1'),
('PAL0628', 'Straight', '/estreit/', '', '', 'CAT13', 'B1'),
('PAL0629', 'Strength', '/estrenz/', '', '', 'CAT13', 'B1'),
('PAL0630', 'Struggle', '/estrá-gl/', '', '', 'CAT13', 'B1'),
('PAL0631', 'Suitable', '/siú-ta-bl/', '', '', 'CAT13', 'B1'),
('PAL0632', 'Surprise', '/ser-práis/', '', '', 'CAT13', 'B1'),
('PAL0633', 'Swimming', '/suí-ming/', '', '', 'CAT13', 'B1'),
('PAL0634', 'Syllable', '/sí-la-bl/', '', '', 'CAT13', 'B1'),
('PAL0635', 'Sympathy', '/sím-pa-zi/', '', '', 'CAT13', 'B1'),
('PAL0636', 'Taxation', '/tak-séi-shen/', '', '', 'CAT13', 'B1'),
('PAL0637', 'Thorough', '/zó-rou/', '', '', 'CAT13', 'B1'),
('PAL0638', 'Threaten', '/zré-ten/', '', '', 'CAT13', 'B1'),
('PAL0639', 'Triptych', '/tríp-tik/', '', '', 'CAT13', 'B1'),
('PAL0640', 'Trousers', '/tráu-sers/', '', '', 'CAT13', 'B1'),
('PAL0641', 'Umbrella', '/am-bré-la/', '', '', 'CAT13', 'B1'),
('PAL0642', 'Unlawful', '/an-ló-ful/', '', '', 'CAT13', 'B1'),
('PAL0643', 'Unlikely', '/an-láik-li/', '', '', 'CAT13', 'B1'),
('PAL0644', 'Upstairs', '/ap-stérs/', '', '', 'CAT13', 'B1'),
('PAL0645', 'Valuable', '/vá-liu-a-bl/', '', '', 'CAT13', 'B1'),
('PAL0646', 'Volatile', '/vó-la-tail/', '', '', 'CAT13', 'B1'),
('PAL0647', 'Wardrobe', '/uór-droub/', '', '', 'CAT13', 'B1'),
('PAL0648', 'Weakness', '/uíik-nes/', '', '', 'CAT13', 'B1'),
('PAL0649', 'Wildlife', '/uáild-laif/', '', '', 'CAT13', 'B1'),
('PAL0650', 'Withdraw', '/uis-dró/', '', '', 'CAT13', 'B1');

--9 LETTERS (OMAR)
INSERT INTO palabra VALUES
('PAL0651', 'abandoner', '/əˈbændənər/', '', '', 'CAT14', 'B1'),
('PAL0652', 'according', '/əˈkôrdiNG/', '', '', 'CAT14', 'B1'),
('PAL0653', 'afternoon', '/ˌaftərˈno͞on/', '', '', 'CAT14', 'B1'),
('PAL0654', 'agreement', '/əˈɡrēm(ə)nt/', '', '', 'CAT14', 'B1'),
('PAL0655', 'alongside', '/əˌlôNGˈsīd/', '', '', 'CAT14', 'B1'),
('PAL0656', 'amazingly', '/əˈmāziNGlē/', '', '', 'CAT14', 'B1'),
('PAL0657', 'amusement', '/əˈmyo͞ozmənt/', '', '', 'CAT14', 'B1'),
('PAL0658', 'apologize', '/əˈpäləˌjīz/', '', '', 'CAT14', 'B1'),
('PAL0659', 'apparatus', '/ˌapəˈradəs/', '', '', 'CAT14', 'B1'),
('PAL0660', 'attention', '/əˈten(t)SHən/', '', '', 'CAT14', 'B1'),
('PAL0661', 'authority', '/əˈTHôrədē/', '', '', 'CAT14', 'B1'),
('PAL0662', 'automatic', '/ˌôdəˈmadik/', '', '', 'CAT14', 'B1'),
('PAL0663', 'beautiful', '/ˈbyo͞odəfəl/', '', '', 'CAT14', 'B1'),
('PAL0664', 'beginning', '/bəˈɡiniNG/', '', '', 'CAT14', 'B1'),
('PAL0665', 'brilliant', '/ˈbrilyənt/', '', '', 'CAT14', 'B1'),
('PAL0666', 'bulldozer', '/ˈˈbo͝olˌdōzər/', '', '', 'CAT14', 'B2'),
('PAL0667', 'calculate', '/ˈkalkyəˌlāt/', '', '', 'CAT14', 'B1'),
('PAL0668', 'carpenter', '/ˈkärpən(t)ər/', '', '', 'CAT14', 'B1'),
('PAL0669', 'chapstick', '/ˈtʃæpˌstɪk/', '', '', 'CAT14', 'B1'),
('PAL0670', 'character', '/ˈker(ə)ktər/', '', '', 'CAT14', 'B1'),
('PAL0671', 'colleague', '/ˈkälēɡ/', '', '', 'CAT14', 'B1'),
('PAL0672', 'committee', '/kəˈmidē/', '', '', 'CAT14', 'B1'),
('PAL0673', 'condition', '/kənˈdiSHən/', '', '', 'CAT14', 'B1'),
('PAL0674', 'conscious', '/ˈkänSHəs/', '', '', 'CAT14', 'B1'),
('PAL0675', 'criticize', '/ˈkridəˌsīz/', '', '', 'CAT14', 'B1'),
('PAL0676', 'dangerous', '/ˈdānj(ə)rəs/', '', '', 'CAT14', 'B1'),
('PAL0677', 'desperate', '/ˈdesp(ə)rət/', '', '', 'CAT14', 'B1'),
('PAL0678', 'determine', '/dəˈtərmən/', '', '', 'CAT14', 'B1'),
('PAL0679', 'digestion', '/dəˈjesCH(ə)n/', '', '', 'CAT14', 'B1'),
('PAL0680', 'discovery', '/dəˈskəv(ə)rē/', '', '', 'CAT14', 'B1'),
('PAL0681', 'eagerness', '/ˈēɡərnəs/', '', '', 'CAT14', 'B2'),
('PAL0682', 'effective', '/əˈfektiv/', '', '', 'CAT14', 'B1'),
('PAL0683', 'emphasize', '/ˈemfəˌsīz/', '', '', 'CAT14', 'B1'),
('PAL0684', 'excellent', '/ˈeks(ə)lənt/', '', '', 'CAT14', 'B1'),
('PAL0685', 'existence', '/iɡˈzist(ə)ns/', '', '', 'CAT14', 'B1'),
('PAL0686', 'exquisite', '/ekˈskwizət/', '', '', 'CAT14', 'B1'),
('PAL0687', 'fabricate', '/ˈfabrəˌkāt/', '', '', 'CAT14', 'B1'),
('PAL0688', 'flashback', '/ˈflaSHˌbak/', '', '', 'CAT14', 'B1'),
('PAL0689', 'fortunate', '/ˈfôrCH(ə)nət/', '', '', 'CAT14', 'B1'),
('PAL0690', 'glamorous', '/ˈɡlam(ə)rəs/', '', '', 'CAT14', 'B1'),
('PAL0691', 'greatness', '/ˈɡrātnəs/', '', '', 'CAT14', 'B1'),
('PAL0692', 'highlight', '/ˈhīˌlīt/', '', '', 'CAT14', 'B1'),
('PAL0693', 'hypnotize', '/ˈhipnəˌtīz/', '', '', 'CAT14', 'B1'),
('PAL0694', 'hypocrisy', '/həˈpäkrəsē/', '', '', 'CAT14', 'B1'),
('PAL0695', 'hypocrite', '/ˈhipəˌkrit/', '', '', 'CAT14', 'B1'),
('PAL0696', 'insurance', '/inˈSHo͝orəns/', '', '', 'CAT14', 'B1'),
('PAL0697', 'invention', '/inˈvenSHən/', '', '', 'CAT14', 'B1'),
('PAL0698', 'jellybean', '/ˈdʒɛlibiːn/', '', '', 'CAT14', 'B1'),
('PAL0699', 'jellyfish', '/ˈjelēˌfiSH/', '', '', 'CAT14', 'B1'),
('PAL0700', 'judgement', '/ˈjəjmənt/', '', '', 'CAT14', 'B1'),
('PAL0701', 'juridical', '/jo͝oˈridək(ə)l/', '', '', 'CAT14', 'B1'),
('PAL0702', 'knowledge', '/ˈnäləj/', '', '', 'CAT14', 'B1'),
('PAL0703', 'laborious', '/ləˈbôrēəs/', '', '', 'CAT14', 'B1'),
('PAL0704', 'necessary', '/ˈnesəˌserē/', '', '', 'CAT14', 'B1'),
('PAL0705', 'negotiate', '/nəˈɡōSHēˌāt/', '', '', 'CAT14', 'B1'),
('PAL0706', 'obedience', '/əˈbēdēəns/', '', '', 'CAT14', 'B1'),
('PAL0707', 'occupancy', '/ˈäkyəp(ə)nsē/', '', '', 'CAT14', 'B1'),
('PAL0708', 'otherwise', '/ˈəT͟Hərˌwīz/', '', '', 'CAT14', 'B2'),
('PAL0709', 'patronage', '/ˈpatrənəj/', '', '', 'CAT14', 'B1'),
('PAL0710', 'plurality', '/plo͝oˈralədē/', '', '', 'CAT14', 'B1'),
('PAL0711', 'potential', '/pəˈten(t)SH(ə)l/', '', '', 'CAT14', 'B1'),
('PAL0712', 'practical', '/ˈpraktək(ə)l/', '', '', 'CAT14', 'B1'),
('PAL0713', 'quickness', '/ˈkwiknəs/', '', '', 'CAT14', 'B1'),
('PAL0714', 'razorback', '/ˈrāzərˌbak/', '', '', 'CAT14', 'B2'),
('PAL0715', 'recognize', '/ˈrekə(ɡ)ˌnīz/', '', '', 'CAT14', 'B1'),
('PAL0716', 'recollect', '/ˌrekəˈlek(t)/', '', '', 'CAT14', 'B1'),
('PAL0717', 'recommend', '/ˌrekəˈmend/', '', '', 'CAT14', 'B1'),
('PAL0718', 'spearmint', '/ˈspirˌmint/', '', '', 'CAT14', 'B1'),
('PAL0719', 'spiritual', '/ˈspirəCH(əw)əl/', '', '', 'CAT14', 'B1'),
('PAL0720', 'spotlight', '/ˈspätˌlīt/', '', '', 'CAT14', 'B1'),
('PAL0721', 'statement', '/ˈstātmənt/', '', '', 'CAT14', 'B1'),
('PAL0722', 'structure', '/ˈstrək(t)SHər/', '', '', 'CAT14', 'B1'),
('PAL0723', 'substance', '/ˈsəbstəns/', '', '', 'CAT14', 'B1'),
('PAL0724', 'symbolize', '/ˈsimbəˌlīz/', '', '', 'CAT14', 'B1'), 
('PAL0725', 'temporary', '/ˈtempəˌrerē/', '', '', 'CAT14', 'B1'),
('PAL0726', 'translate', '/tranzˈlāt/', '', '', 'CAT14', 'B1'),
('PAL0727', 'treatment', '/ˈtrētmənt/', '', '', 'CAT14', 'B1'),
('PAL0728', 'vaccinate', '/ˈvaksəˌnāt/', '', '', 'CAT14', 'B1'),
('PAL0729', 'victimize', '/ˈviktəˌmīz/', '', '', 'CAT14', 'B1'),
('PAL0730', 'visualize', '/ˈviZHəˌlīz/', '', '', 'CAT14', 'B1'),
('PAL0731', 'wonderful', '/ˈwəndərf(ə)l/', '', '', 'CAT14', 'B1'),
('PAL0732', 'worthless', '/ˈwərTHləs/', '', '', 'CAT14', 'B1'),
('PAL0733', 'accessory', '/əkˈses(ə)rē/', '', '', 'CAT14', 'B1'),
('PAL0734', 'advantage', '/ədˈvan(t)ij/', '', '', 'CAT14', 'B1'), 
('PAL0735', 'ambitious', '/amˈbiSHəs/', '', '', 'CAT14', 'B1'),
('PAL0736', 'amphibian', '/amˈ(p)fibēən/', '', '', 'CAT14', 'B1'),
('PAL0737', 'apologize', '/əˈpäləˌjīz/', '', '', 'CAT14', 'B1'),
('PAL0738', 'astronomy', '/əˈstränəmē/', '', '', 'CAT14', 'B1'),
('PAL0739', 'breathing', '/ˈbrēT͟HiNG/', '', '', 'CAT14', 'B1'),
('PAL0740', 'blueberry', '/ˈblo͞oˌberē/', '', '', 'CAT14', 'B1');

--10 LETTERS (OMAR) (hasta 800)
INSERT INTO palabra VALUES
('PAL0741', 'abhorrence', '/əbˈhôrəns/', '', '', 'CAT15', 'B2'),
('PAL0742', 'abnegation', '/ˌabnəˈɡāSH(ə)n/', '', '', 'CAT15', 'B2'),
('PAL0743', 'abominably', '/əˈbäm(ə)nəblē/', '', '', 'CAT15', 'B2'),
('PAL0744', 'aborigines', '/ˌæb.əˈrɪdʒ.ən.iːz/', '', '', 'CAT15', 'B2'),
('PAL0745', 'abridgment', '/əˈbrijm(ə)nt/', '', '', 'CAT15', 'B2'),
('PAL0746', 'abrogation', '/ˌabrəˈɡāSH(ə)n/', '', '', 'CAT15', 'B2'),
('PAL0747', 'absolutist', '/ˈabsəˌlo͞odəst/', '', '', 'CAT15', 'B2'),
('PAL0748', 'absorbency', '/əbˈsɔːrbənsi/', '', '', 'CAT15', 'B2'),
('PAL0749', 'acceptable', '/əkˈseptəb(ə)l/', '', '', 'CAT15', 'B2'),
('PAL0750', 'additional', '/əˈdiSHənl/', '', '', 'CAT15', 'B2'),
('PAL0751', 'adjudicate', '/əˈjo͞odəˌkāt/', '', '', 'CAT15', 'B2'),
('PAL0752', 'adjustment', '/əˈjəs(t)m(ə)nt/', '', '', 'CAT15', 'B2'),
('PAL0753', 'afterwards', '/ˈaftərwərdz/', '', '', 'CAT15', 'B2'),
('PAL0754', 'aggressive', '/əˈɡresiv/', '', '', 'CAT15', 'B2'),
('PAL0755', 'anticipate', '/anˈtisəˌpāt/', '', '', 'CAT15', 'B2'),
('PAL0756', 'appreciate', '/əˈprēSHēˌāt/', '', '', 'CAT15', 'B2'),
('PAL0757', 'authorship', '/ˈôTHərˌSHip/', '', '', 'CAT15', 'B2'),
('PAL0758', 'background', '/ˈbakˌɡround/', '', '', 'CAT15', 'B2'),
('PAL0759', 'chimpanzee', '/ˌCHimˈpanzē/', '', '', 'CAT15', 'B2'),
('PAL0760', 'commercial', '/kəˈmərSHəl/', '', '', 'CAT15', 'B2'),
('PAL0761', 'comprehend', '/ˌkämprəˈhend/', '', '', 'CAT15', 'B2'),
('PAL0762', 'conscience', '/ˈkänSHəns/', '', '', 'CAT15', 'B1'),
('PAL0763', 'depression', '/dəˈpreSH(ə)n/', '', '', 'CAT15', 'B2'),
('PAL0764', 'discussion', '/dəˈskəSHən/', '', '', 'CAT15', 'B2'),
('PAL0765', 'distribute', '/dəˈstribyo͞ot/', '', '', 'CAT15', 'B2'),
('PAL0766', 'equivalent', '/əˈkwiv(ə)lənt/', '', '', 'CAT15', 'B2'),
('PAL0767', 'experience', '/ikˈspirēəns/', '', '', 'CAT15', 'B1'),
('PAL0768', 'government', '/ˈɡəvər(n)mənt/', '', '', 'CAT15', 'B2'),
('PAL0769', 'hypnotized', '/ˈhɪpnətaɪzd/', '', '', 'CAT15', 'B2'),
('PAL0770', 'illustrate', '/ˈiləˌstrāt/', '', '', 'CAT15', 'B2'),
('PAL0771', 'immaculate', '/iˈmakyələt/', '', '', 'CAT15', 'B2'),
('PAL0772', 'impossible', '/imˈpäsəb(ə)l/', '', '', 'CAT15', 'B2'),
('PAL0773', 'impressive', '/əmˈpresiv/', '', '', 'CAT15', 'B2'),
('PAL0774', 'juxtaposed', '/ˌdʒʌkstəˈpoʊzd/', '', '', 'CAT15', 'C1'),
('PAL0775', 'kickboxing', '/ˈkɪkˌbɑːksɪŋ/', '', '', 'CAT15', 'C1'),
('PAL0776', 'literature', '/ˈlidər(ə)CHər/', '', '', 'CAT15', 'B1'),
('PAL0777', 'maleficent', '/məˈlefəsənt/', '', '', 'CAT15', 'B2'),
('PAL0778', 'manipulate', '/məˈnipyəˌlāt/', '', '', 'CAT15', 'B2'),
('PAL0779', 'motivation', '/ˌmōdəˈvāSH(ə)n/', '', '', 'CAT15', 'B2'),
('PAL0780', 'mozzarella', '/ˌmätsəˈrelə/', '', '', 'CAT15', 'B1'),
('PAL0781', 'plantation', '/planˈtāSH(ə)n/', '', '', 'CAT15', 'B1'),
('PAL0782', 'proscenium', '/prəˈsēnēəm/', '', '', 'CAT15', 'B2'),
('PAL0783', 'punishment', '/ˈpəniSHm(ə)nt/', '', '', 'CAT15', 'B1'),
('PAL0784', 'reasonable', '/ˈrēzənəb(ə)l/', '', '', 'CAT15', 'B2'),
('PAL0785', 'regardless', '/rəˈɡärdləs/', '', '', 'CAT15', 'B2'),
('PAL0786', 'remarkable', '/rəˈmärkəb(ə)l/', '', '', 'CAT15', 'B2'),
('PAL0787', 'seamstress', '/ˈsēmstrəs/', '', '', 'CAT15', 'B2'),
('PAL0788', 'specialist', '/ˈspeSH(ə)ləst/', '', '', 'CAT15', 'B1'),
('PAL0789', 'squeezable', '/ˈskwiːzəbl/', '', '', 'CAT15', 'B2'),
('PAL0790', 'successful', '/səkˈsesf(ə)l/', '', '', 'CAT15', 'B1'),
('PAL0791', 'sufficient', '/səˈfiSH(ə)nt/', '', '', 'CAT15', 'B1'),
('PAL0792', 'suggestion', '/səˈjesCHən/', '', '', 'CAT15', 'B2'),
('PAL0793', 'suspicious', '/səˈspiSHəs/', '', '', 'CAT15', 'B2'),
('PAL0794', 'texturized', '/ˈtɛkstʃəˌraɪzd/', '', '', 'CAT15', 'B2'),
('PAL0795', 'understand', '/ˌəndərˈstand/', '', '', 'CAT15', 'B1'),
('PAL0796', 'unfriendly', '/ˌənˈfren(d)lē/', '', '', 'CAT15', 'B1'),
('PAL0797', 'volleyball', '/ˈvälēˌbôl/', '', '', 'CAT15', 'B1'),
('PAL0798', 'wanderlust', '/ˈwändərˌləst/', '', '', 'CAT15', 'B2'),
('PAL0799', 'widespread', '/ˈwīdˌspred/', '', '', 'CAT15', 'B2'),
('PAL0800', 'arithmetic', '/əˈrɪθ.mə.tɪk/', '', '', 'CAT15', 'B2');



--11 LETTERS (JOSUE)
INSERT INTO palabra VALUES
('PAL0801', 'advertising', '/ˈæd.vər.taɪ.zɪŋ/', '', '', 'CAT16', 'B2'),
('PAL0802', 'anachronism', '/əˈnæk.rə.nɪ.zəm/', '', '', 'CAT16', 'B2'),
('PAL0803', 'anniversary', '/ˌæn.əˈvɜːr.sər.i/', '', '', 'CAT16', 'B2'),
('PAL0804', 'appropriate', '/əˈproʊ.pri.ət/', '', '', 'CAT16', 'B2'),
('PAL0805', 'backpacking', '/ˈbækˌpæk.ɪŋ/', '', '', 'CAT16', 'B2'),
('PAL0806', 'blasphemous', '/ˈblæs.fə.məs/', '', '', 'CAT16', 'B2'),
('PAL0807', 'celebration', '/ˌsel.əˈbreɪ.ʃən/', '', '', 'CAT16', 'B2'),
('PAL0808', 'coincidence', '/koʊˈɪn.sɪ.dəns/', '', '', 'CAT16', 'B2'),
('PAL0809', 'concordance', '/kənˈkɔːr.dəns/', '', '', 'CAT16', 'B2'),
('PAL0810', 'connotation', '/ˌkɒn.əˈteɪ.ʃən/', '', '', 'CAT16', 'B2'),
('PAL0811', 'descriptive', '/dɪˈskrɪp.tɪv/', '', '', 'CAT16', 'B2'),
('PAL0812', 'electricity', '/ɪˌlekˈtrɪs.ə.ti/', '', '', 'CAT16', 'B2'),
('PAL0813', 'environment', '/ɪnˈvaɪ.rən.mənt/', '', '', 'CAT16', 'B2'),
('PAL0814', 'fabrication', '/ˌfæb.rɪˈkeɪ.ʃən/', '', '', 'CAT16', 'B2'),
('PAL0815', 'forgettable', '/fərˈɡet.ə.bəl/', '', '', 'CAT16', 'B2'),
('PAL0816', 'forgiveness', '/fərˈɡɪv.nəs/', '', '', 'CAT16', 'B2'),
('PAL0817', 'imagination', '/ɪˌmædʒ.əˈneɪ.ʃən/', '', '', 'CAT16', 'B2'),
('PAL0818', 'inspiration', '/ˌɪn.spəˈreɪ.ʃən/', '', '', 'CAT16', 'B2'),
('PAL0819', 'intelligent', '/ɪnˈtel.ɪ.dʒənt/', '', '', 'CAT16', 'B2'),
('PAL0820', 'marshmallow', '/ˈmɑːrʃˌmæl.oʊ/', '', '', 'CAT16', 'B2'),
('PAL0821', 'personality', '/ˌpɜːr.sənˈæl.ə.ti/', '', '', 'CAT16', 'B2'),
('PAL0822', 'predominate', '/prɪˈdɒm.ɪ.neɪt/', '', '', 'CAT16', 'B2'),
('PAL0823', 'preposition', '/ˌprep.əˈzɪʃ.ən/', '', '', 'CAT16', 'B2'),
('PAL0824', 'requirement', '/rɪˈkwaɪər.mənt/', '', '', 'CAT16', 'B2'),
('PAL0825', 'selfishness', '/ˈsel.fɪʃ.nəs/', '', '', 'CAT16', 'B2'),
('PAL0826', 'serviceable', '/ˈsɜːr.vɪs.ə.bəl/', '', '', 'CAT16', 'B2'),
('PAL0827', 'shortcoming', '/ˈʃɔːrtˌkʌm.ɪŋ/', '', '', 'CAT16', 'B2'),
('PAL0828', 'standardize', '/ˈstæn.dər.daɪz/', '', '', 'CAT16', 'B2'),
('PAL0829', 'subordinate', '/səˈbɔːr.dɪ.nət/', '', '', 'CAT16', 'B2'),
('PAL0830', 'sufficiency', '/səˈfɪʃ.ən.si/', '', '', 'CAT16', 'B2'),
('PAL0831', 'supposition', '/ˌsʌp.əˈzɪʃ.ən/', '', '', 'CAT16', 'B2'),
('PAL0832', 'treacherous', '/ˈtretʃ.ər.əs/', '', '', 'CAT16', 'B2'),
('PAL0833', 'unfortunate', '/ʌnˈfɔːr.tʃə.nət/', '', '', 'CAT16', 'B2'),
('PAL0834', 'unstoppable', '/ʌnˈstɒp.ə.bəl/', '', '', 'CAT16', 'B2'),
('PAL0835', 'vaccination', '/ˌvæk.sɪˈneɪ.ʃən/', '', '', 'CAT16', 'B2'),
('PAL0836', 'windsurfing', '/ˈwɪndˌsɜːr.fɪŋ/', '', '', 'CAT16', 'B2'),
('PAL0837', 'abnormality', '/ˌæb.nɔːrˈmæl.ə.ti/', '', '', 'CAT16', 'B2'),
('PAL0838', 'arrangement', '/əˈreɪndʒ.mənt/', '', '', 'CAT16', 'B2'),
('PAL0839', 'discontinue', '/ˌdɪs.kənˈtɪn.juː/', '', '', 'CAT16', 'B2'),
('PAL0840', 'disposition', '/ˌdɪs.pəˈzɪʃ.ən/', '', '', 'CAT16', 'B2'),
('PAL0841', 'exhortation', '/ˌeɡ.zɔːrˈteɪ.ʃən/', '', '', 'CAT16', 'B2'),
('PAL0842', 'frostbitten', '/ˈfrɒstˌbɪt.ən/', '', '', 'CAT16', 'B2'),
('PAL0843', 'headquarter', '/ˈhedˌkwɔːr.tər/', '', '', 'CAT16', 'B2'),
('PAL0844', 'ignominious', '/ˌɪɡ.nəˈmɪn.i.əs/', '', '', 'CAT16', 'B2'),
('PAL0845', 'inquisitive', '/ɪnˈkwɪz.ə.tɪv/', '', '', 'CAT16', 'B2'),
('PAL0846', 'mischievous', '/ˈmɪs.tʃɪ.vəs/', '', '', 'CAT16', 'B2'),
('PAL0847', 'remembrance', '/rɪˈmem.brəns/', '', '', 'CAT16', 'B2'),
('PAL0848', 'spendthrift', '/ˈspendˌθrɪft/', '', '', 'CAT16', 'B2'),
('PAL0849', 'suspenseful', '/səˈspens.fəl/', '', '', 'CAT16', 'B2'),
('PAL0850', 'synchronize', '/ˈsɪŋ.krə.naɪz/', '', '', 'CAT16', 'B2');

--12 LETTERS (JOSUE) (hasta 900)
INSERT INTO palabra VALUES
('PAL0851', 'abolitionist', '/ˌæb.əˈlɪʃ.ən.ɪst/', '', '', 'CAT17', 'B2'),
('PAL0852', 'absoluteness', '/ˈæb.sə.luːt.nəs/', '', '', 'CAT17', 'B2'),
('PAL0853', 'absorptivity', '/ˌæb.sɔːrpˈtɪv.ə.ti/', '', '', 'CAT17', 'B2'),
('PAL0854', 'academically', '/ˌæk.əˈdem.ɪ.kli/', '', '', 'CAT17', 'B2'),
('PAL0855', 'aerodynamics', '/ˌeə.roʊ.daɪˈnæm.ɪks/', '', '', 'CAT17', 'B2'),
('PAL0856', 'alliteration', '/əˌlɪt.əˈreɪ.ʃən/', '', '', 'CAT17', 'B2'),
('PAL0857', 'amphitheater', '/ˈæm.fɪˌθiː.ə.tər/', '', '', 'CAT17', 'B2'),
('PAL0858', 'appreciation', '/əˌpriː.ʃiˈeɪ.ʃən/', '', '', 'CAT17', 'B2'),
('PAL0859', 'architecture', '/ˈɑːr.kɪ.tek.tʃər/', '', '', 'CAT17', 'B2'),
('PAL0860', 'bachelorette', '/ˌbætʃ.əl.əˈret/', '', '', 'CAT17', 'B2'),
('PAL0861', 'behaviorally', '/bɪˈheɪ.vjər.ə.li/', '', '', 'CAT17', 'B2'),
('PAL0862', 'biodiversity', '/ˌbaɪ.oʊ.daɪˈvɜːr.sə.ti/', '', '', 'CAT17', 'B2'),
('PAL0863', 'biomagnetism', '/ˌbaɪ.oʊˈmæɡ.nə.tɪ.zəm/', '', '', 'CAT17', 'B2'),
('PAL0864', 'bodybuilding', '/ˈbɒd.iˌbɪl.dɪŋ/', '', '', 'CAT17', 'B2'),
('PAL0865', 'brinkmanship', '/ˈbrɪŋk.mən.ʃɪp/', '', '', 'CAT17', 'B2'),
('PAL0866', 'butterscotch', '/ˈbʌt.ər.skɒtʃ/', '', '', 'CAT17', 'B2'),
('PAL0867', 'calligrapher', '/kəˈlɪɡ.rə.fər/', '', '', 'CAT17', 'B2'),
('PAL0868', 'capriciously', '/kəˈprɪʃ.əs.li/', '', '', 'CAT17', 'B2'),
('PAL0869', 'childishness', '/ˈtʃaɪl.dɪʃ.nəs/', '', '', 'CAT17', 'B2'),
('PAL0870', 'collaterally', '/kəˈlæt.ər.əl.i/', '', '', 'CAT17', 'B2'),
('PAL0871', 'commissioner', '/kəˈmɪʃ.ən.ər/', '', '', 'CAT17', 'B2'),
('PAL0872', 'cytogenetics', '/ˌsaɪ.toʊ.dʒəˈnet.ɪks/', '', '', 'CAT17', 'B2'),
('PAL0873', 'decipherable', '/dɪˈsaɪ.fər.ə.bəl/', '', '', 'CAT17', 'B2'),
('PAL0874', 'decommission', '/ˌdiː.kəˈmɪʃ.ən/', '', '', 'CAT17', 'B2'),
('PAL0875', 'eclectically', '/ɪˈklek.tɪ.kli/', '', '', 'CAT17', 'B2'),
('PAL0876', 'etymological', '/ˌet.ɪ.məˈlɒdʒ.ɪ.kəl/', '', '', 'CAT17', 'B2'),
('PAL0877', 'heartrending', '/ˈhɑːrtˌren.dɪŋ/', '', '', 'CAT17', 'B2'),
('PAL0878', 'hypocritical', '/ˌhɪp.əˈkrɪt.ɪ.kəl/', '', '', 'CAT17', 'B2'),
('PAL0879', 'impenetrable', '/ɪmˈpen.ɪ.trə.bəl/', '', '', 'CAT17', 'B2'),
('PAL0880', 'independence', '/ˌɪn.dɪˈpen.dəns/', '', '', 'CAT17', 'B2'),
('PAL0881', 'inflammation', '/ˌɪn.fləˈmeɪ.ʃən/', '', '', 'CAT17', 'B2'),
('PAL0882', 'infringement', '/ɪnˈfrɪndʒ.mənt/', '', '', 'CAT17', 'B2'),
('PAL0883', 'intellectual', '/ˌɪn.təlˈek.tʃu.əl/', '', '', 'CAT17', 'B2'),
('PAL0884', 'intelligence', '/ɪnˈtel.ɪ.dʒəns/', '', '', 'CAT17', 'B2'),
('PAL0885', 'intimidating', '/ɪnˈtɪm.ɪ.deɪ.tɪŋ/', '', '', 'CAT17', 'B2'),
('PAL0886', 'jurisdiction', '/ˌdʒʊr.ɪsˈdɪk.ʃən/', '', '', 'CAT17', 'B2'),
('PAL0887', 'manufacturer', '/ˌmæn.jəˈfæk.tʃər.ər/', '', '', 'CAT17', 'B2'),
('PAL0888', 'organization', '/ˌɔːr.ɡən.əˈzeɪ.ʃən/', '', '', 'CAT17', 'B2'),
('PAL0889', 'Pennsylvania', '/ˌpen.səlˈveɪ.ni.ə/', '', '', 'CAT17', 'B2'),
('PAL0890', 'presumptuous', '/prɪˈzʌmp.tʃu.əs/', '', '', 'CAT17', 'B2'),
('PAL0891', 'professional', '/prəˈfeʃ.ən.əl/', '', '', 'CAT17', 'B2'),
('PAL0892', 'recalcitrant', '/rɪˈkæl.sɪ.trənt/', '', '', 'CAT17', 'B2'),
('PAL0893', 'relationship', '/rɪˈleɪ.ʃən.ʃɪp/', '', '', 'CAT17', 'B2'),
('PAL0894', 'resurrection', '/ˌrez.əˈrek.ʃən/', '', '', 'CAT17', 'B2'),
('PAL0895', 'significance', '/sɪɡˈnɪf.ɪ.kəns/', '', '', 'CAT17', 'B2'),
('PAL0896', 'sporadically', '/spəˈræd.ɪ.kli/', '', '', 'CAT17', 'B2'),
('PAL0897', 'Thanksgiving', '/ˌθæŋksˈɡɪv.ɪŋ/', '', '', 'CAT17', 'B2'),
('PAL0898', 'unattractive', '/ˌʌn.əˈtræk.tɪv/', '', '', 'CAT17', 'B2'),
('PAL0899', 'unsteadiness', '/ʌnˈsted.i.nəs/', '', '', 'CAT17', 'B2'),
('PAL0900', 'blabbermouth', '/ˈblæb.ər.maʊθ/', '', '', 'CAT17', 'B2');


-- ============================================================
-- REPORTES
-- ============================================================

INSERT INTO reporte VALUES
('REP01', '2026-08-01', 'General Statistics', 'PROF01'),
('REP02', '2026-08-03', 'Most Missed Words', 'PROF02'),
('REP03', '2026-08-05', 'Group Progress', 'PROF03'),
('REP04', '2026-08-07', 'Group Ranking', 'PROF04'),
('REP05', '2026-08-09', 'Inactive Students', 'PROF05'),
('REP06', '2026-08-11', 'Comparison Between Lists', 'PROF01'),
('REP07', '2026-08-13', 'Weekly Evolution', 'PROF02'),
('REP08', '2026-08-15', 'Average Practice Time', 'PROF03'),
('REP09', '2026-08-17', 'Group Average', 'PROF04'),
('REP10', '2026-08-19', 'Easiest Words', 'PROF05');


-- ============================================================
-- RANGOS
-- ============================================================

INSERT INTO rango VALUES
('RAN01', 'Bronze', 0, 999, '2026100001'),
('RAN02', 'Silver', 1000, 2999, '2026100002'),
('RAN03', 'Gold', 3000, 5999, '2026100003'),
('RAN04', 'Diamond', 6000, 9999, '2026100004'),
('RAN05', 'Spelling Master', 10000, NULL, '2026100005');


-- ============================================================
-- GRUPOS
-- ============================================================

INSERT INTO grupo VALUES
('GRU01', 'Grupo A - EII', '2026-07-15', 'Aug-Dec 2026', 'PROF01'),
('GRU02', 'Grupo B - EII', '2026-07-15', 'Aug-Dec 2026', 'PROF02'),
('GRU03', 'Grupo A - PP', '2026-07-16', 'Aug-Dec 2026', 'PROF03'),
('GRU04', 'Grupo B - PP', '2026-07-16', 'Aug-Dec 2026', 'PROF04'),
('GRU05', 'Grupo A - OLCE', '2026-07-17', 'Aug-Dec 2026', 'PROF05'),
('GRU06', 'Grupo B - OLCE', '2026-07-17', 'Aug-Dec 2026', 'PROF01'),
('GRU07', 'Grupo A - DSM', '2026-07-18', 'Aug-Dec 2026', 'PROF02'),
('GRU08', 'Grupo B - DSM', '2026-07-18', 'Aug-Dec 2026', 'PROF03'),
('GRU09', 'Grupo A - IRD', '2026-07-19', 'Aug-Dec 2026', 'PROF04'),
('GRU10', 'Grupo B - IRD', '2026-07-19', 'Aug-Dec 2026', 'PROF05');


-- ============================================================
-- PRÁCTICAS / SESIONES
-- ============================================================

INSERT INTO practica_sesion VALUES
('PRA01', '2026-08-01', '00:02:00', 70, 100, 'J01', 'LIS01'),
('PRA02', '2026-08-02', '00:03:00', 72.5, 110, 'J02', 'LIS02'),
('PRA03', '2026-08-03', '00:04:00', 75, 120, 'J03', 'LIS03'),
('PRA04', '2026-08-04', '00:05:00', 77.5, 130, 'J04', 'LIS04'),
('PRA05', '2026-08-05', '00:06:00', 80, 140, 'J05', 'LIS05'),
('PRA06', '2026-08-06', '00:02:00', 82.5, 150, 'J06', 'LIS06'),
('PRA07', '2026-08-07', '00:03:00', 85, 160, 'J07', 'LIS07'),
('PRA08', '2026-08-08', '00:04:00', 87.5, 170, 'J08', 'LIS08'),
('PRA09', '2026-08-09', '00:05:00', 90, 180, 'J09', 'LIS09'),
('PRA10', '2026-08-10', '00:06:00', 92.5, 190, 'J10', 'LIS10');


-- ============================================================
-- INTENTOS DE PALABRA
-- ============================================================

INSERT INTO intento_palabra VALUES
('INT001', 0, '00:00:03', 1, 'PRA01', 'PAL0001'),
('INT002', 1, '00:00:04', 2, 'PRA02', 'PAL0002'),
('INT003', 1, '00:00:05', 3, 'PRA03', 'PAL0003'),
('INT004', 1, '00:00:06', 1, 'PRA04', 'PAL0004'),
('INT005', 0, '00:00:07', 2, 'PRA05', 'PAL0005'),
('INT006', 1, '00:00:08', 3, 'PRA06', 'PAL0006'),
('INT007', 1, '00:00:03', 1, 'PRA07', 'PAL0007'),
('INT008', 1, '00:00:04', 2, 'PRA08', 'PAL0008'),
('INT009', 0, '00:00:05', 3, 'PRA09', 'PAL0009'),
('INT010', 1, '00:00:06', 1, 'PRA10', 'PAL0010');


-- ============================================================
-- PROCESO DE LISTAS
-- ============================================================

INSERT INTO proceso_lista VALUES
('LIS01', '2026100001', 60, 'No', '2026-08-01'),
('LIS02', '2026100002', 63.7, 'No', '2026-08-04'),
('LIS03', '2026100003', 67.4, 'No', '2026-08-07'),
('LIS04', '2026100004', 71.1, 'No', '2026-08-10'),
('LIS05', '2026100005', 74.8, 'No', '2026-08-13'),
('LIS06', '2026100006', 78.5, 'No', '2026-08-16'),
('LIS07', '2026100007', 82.2, 'No', '2026-08-19'),
('LIS08', '2026100008', 85.9, 'No', '2026-08-22'),
('LIS09', '2026100009', 89.6, 'No', '2026-08-25'),
('LIS10', '2026100010', 93.3, 'Si', '2026-08-28');


-- ============================================================
-- LISTAS - GRUPOS
-- ============================================================

INSERT INTO lista_grupo VALUES
('LIS01', 'GRU02'),
('LIS02', 'GRU03'),
('LIS03', 'GRU04'),
('LIS04', 'GRU05'),
('LIS05', 'GRU06'),
('LIS06', 'GRU07'),
('LIS07', 'GRU08'),
('LIS08', 'GRU09'),
('LIS09', 'GRU10'),
('LIS10', 'GRU01');


-- ============================================================
-- GRUPOS - ALUMNOS
-- ============================================================

INSERT INTO grupo_alumno VALUES
('GRU01', '2026100001'),
('GRU02', '2026100002'),
('GRU03', '2026100003'),
('GRU04', '2026100004'),
('GRU05', '2026100005'),
('GRU06', '2026100006'),
('GRU07', '2026100007'),
('GRU08', '2026100008'),
('GRU09', '2026100009'),
('GRU10', '2026100010');


-- ============================================================
-- ALUMNOS - INSIGNIAS
-- ============================================================

INSERT INTO alumno_insignia VALUES
('2026100001', 'INS01', '2026-08-01'),
('2026100002', 'INS02', '2026-08-05'),
('2026100003', 'INS03', '2026-08-09'),
('2026100004', 'INS04', '2026-08-13'),
('2026100005', 'INS05', '2026-08-17'),
('2026100006', 'INS06', '2026-08-21'),
('2026100007', 'INS07', '2026-08-25'),
('2026100008', 'INS08', '2026-08-29'),
('2026100009', 'INS09', '2026-09-02'),
('2026100010', 'INS10', '2026-09-06');


-- ============================================================
-- ALUMNOS - PRÁCTICAS
-- ============================================================

INSERT INTO alumno_practica VALUES
('2026100001', 'PRA01'),
('2026100002', 'PRA02'),
('2026100003', 'PRA03'),
('2026100004', 'PRA04'),
('2026100005', 'PRA05'),
('2026100006', 'PRA06'),
('2026100007', 'PRA07'),
('2026100008', 'PRA08'),
('2026100009', 'PRA09'),
('2026100010', 'PRA10');


-- ============================================================
-- DIFICULTAD - JUEGO
-- ============================================================

INSERT INTO dificultad_juego VALUES
('J01', 'DI01'),
('J02', 'DI02'),
('J03', 'DI03'),
('J04', 'DI01'),
('J05', 'DI02'),
('J06', 'DI03'),
('J07', 'DI03'),
('J08', 'DI01'),
('J09', 'DI02'),
('J10', 'DI03'),
('J11', 'DI02'),
('J12', 'DI03');

INSERT INTO lista_palabra VALUES
-- ANIMALS
('LIS01', 'PAL0002'),
('LIS01', 'PAL0011'),
('LIS01', 'PAL0012'),
('LIS01', 'PAL0013'),
('LIS01', 'PAL0014'),
('LIS01', 'PAL0015'),

-- FOOD
('LIS02', 'PAL0001'),
('LIS02', 'PAL0016'),
('LIS02', 'PAL0017'),
('LIS02', 'PAL0018'),
('LIS02', 'PAL0019'),
('LIS02', 'PAL0020'),

-- COLORS
('LIS03', 'PAL0003'),
('LIS03', 'PAL0021'),
('LIS03', 'PAL0022'),
('LIS03', 'PAL0023'),
('LIS03', 'PAL0024'),
('LIS03', 'PAL0025'),

-- FAMILY
('LIS04', 'PAL0004'),
('LIS04', 'PAL0026'),
('LIS04', 'PAL0027'),
('LIS04', 'PAL0028'),
('LIS04', 'PAL0029'),
('LIS04', 'PAL0030'),

-- SCHOOL
('LIS05', 'PAL0005'),
('LIS05', 'PAL0031'),
('LIS05', 'PAL0032'),
('LIS05', 'PAL0033'),
('LIS05', 'PAL0034'),
('LIS05', 'PAL0035'),

-- SPORTS
('LIS06', 'PAL0006'),
('LIS06', 'PAL0036'),
('LIS06', 'PAL0037'),
('LIS06', 'PAL0038'),
('LIS06', 'PAL0039'),
('LIS06', 'PAL0040'),

-- NATURE
('LIS07', 'PAL0007'),
('LIS07', 'PAL0041'),
('LIS07', 'PAL0042'),
('LIS07', 'PAL0043'),
('LIS07', 'PAL0044'),
('LIS07', 'PAL0045'),

-- TECHNOLOGY
('LIS08', 'PAL0008'),
('LIS08', 'PAL0046'),
('LIS08', 'PAL0047'),
('LIS08', 'PAL0048'),
('LIS08', 'PAL0049'),
('LIS08', 'PAL0050'),

-- FEELINGS
('LIS09', 'PAL0009'),
('LIS09', 'PAL0051'),
('LIS09', 'PAL0052'),
('LIS09', 'PAL0053'),
('LIS09', 'PAL0054'),
('LIS09', 'PAL0055'),

-- VEHICLES
('LIS10', 'PAL0010'),
('LIS10', 'PAL0056'),
('LIS10', 'PAL0057'),
('LIS10', 'PAL0058'),
('LIS10', 'PAL0059'),
('LIS10', 'PAL0060');

INSERT INTO puntaje (codigo, experiencia)
VALUES ('PUN01', 20);

INSERT INTO leccion 
(clave, nombre, descripcion, practica_sesion, puntaje, contenido_leccion)
VALUES

-- PRA01
('LEC01', 'Lesson 1 - PRA01', 'First lesson of practice PRA01.', 'PRA01', 'PUN01', 'CON01'),
('LEC02', 'Lesson 2 - PRA01', 'Second lesson of practice PRA01.', 'PRA01', 'PUN01', 'CON02'),
('LEC03', 'Lesson 3 - PRA01', 'Third lesson of practice PRA01.', 'PRA01', 'PUN01', 'CON03'),
('LEC04', 'Lesson 4 - PRA01', 'Fourth lesson of practice PRA01.', 'PRA01', 'PUN01', 'CON06'),

-- PRA02
('LEC05', 'Lesson 1 - PRA02', 'First lesson of practice PRA02.', 'PRA02', 'PUN01', 'CON01'),
('LEC06', 'Lesson 2 - PRA02', 'Second lesson of practice PRA02.', 'PRA02', 'PUN01', 'CON02'),
('LEC07', 'Lesson 3 - PRA02', 'Third lesson of practice PRA02.', 'PRA02', 'PUN01', 'CON03'),
('LEC08', 'Lesson 4 - PRA02', 'Fourth lesson of practice PRA02.', 'PRA02', 'PUN01', 'CON06'),

-- PRA03
('LEC09', 'Lesson 1 - PRA03', 'First lesson of practice PRA03.', 'PRA03', 'PUN01', 'CON01'),
('LEC10', 'Lesson 2 - PRA03', 'Second lesson of practice PRA03.', 'PRA03', 'PUN01', 'CON02'),
('LEC11', 'Lesson 3 - PRA03', 'Third lesson of practice PRA03.', 'PRA03', 'PUN01', 'CON03'),
('LEC12', 'Lesson 4 - PRA03', 'Fourth lesson of practice PRA03.', 'PRA03', 'PUN01', 'CON06'),

-- PRA04
('LEC13', 'Lesson 1 - PRA04', 'First lesson of practice PRA04.', 'PRA04', 'PUN01', 'CON01'),
('LEC14', 'Lesson 2 - PRA04', 'Second lesson of practice PRA04.', 'PRA04', 'PUN01', 'CON02'),
('LEC15', 'Lesson 3 - PRA04', 'Third lesson of practice PRA04.', 'PRA04', 'PUN01', 'CON03'),
('LEC16', 'Lesson 4 - PRA04', 'Fourth lesson of practice PRA04.', 'PRA04', 'PUN01', 'CON06'),

-- PRA05
('LEC17', 'Lesson 1 - PRA05', 'First lesson of practice PRA05.', 'PRA05', 'PUN01', 'CON01'),
('LEC18', 'Lesson 2 - PRA05', 'Second lesson of practice PRA05.', 'PRA05', 'PUN01', 'CON02'),
('LEC19', 'Lesson 3 - PRA05', 'Third lesson of practice PRA05.', 'PRA05', 'PUN01', 'CON03'),
('LEC20', 'Lesson 4 - PRA05', 'Fourth lesson of practice PRA05.', 'PRA05', 'PUN01', 'CON06'),

-- PRA06
('LEC21', 'Lesson 1 - PRA06', 'First lesson of practice PRA06.', 'PRA06', 'PUN01', 'CON01'),
('LEC22', 'Lesson 2 - PRA06', 'Second lesson of practice PRA06.', 'PRA06', 'PUN01', 'CON02'),
('LEC23', 'Lesson 3 - PRA06', 'Third lesson of practice PRA06.', 'PRA06', 'PUN01', 'CON03'),
('LEC24', 'Lesson 4 - PRA06', 'Fourth lesson of practice PRA06.', 'PRA06', 'PUN01', 'CON06'),

-- PRA07
('LEC25', 'Lesson 1 - PRA07', 'First lesson of practice PRA07.', 'PRA07', 'PUN01', 'CON01'),
('LEC26', 'Lesson 2 - PRA07', 'Second lesson of practice PRA07.', 'PRA07', 'PUN01', 'CON02'),
('LEC27', 'Lesson 3 - PRA07', 'Third lesson of practice PRA07.', 'PRA07', 'PUN01', 'CON03'),
('LEC28', 'Lesson 4 - PRA07', 'Fourth lesson of practice PRA07.', 'PRA07', 'PUN01', 'CON06'),

-- PRA08
('LEC29', 'Lesson 1 - PRA08', 'First lesson of practice PRA08.', 'PRA08', 'PUN01', 'CON01'),
('LEC30', 'Lesson 2 - PRA08', 'Second lesson of practice PRA08.', 'PRA08', 'PUN01', 'CON02'),
('LEC31', 'Lesson 3 - PRA08', 'Third lesson of practice PRA08.', 'PRA08', 'PUN01', 'CON03'),
('LEC32', 'Lesson 4 - PRA08', 'Fourth lesson of practice PRA08.', 'PRA08', 'PUN01', 'CON06'),

-- PRA09
('LEC33', 'Lesson 1 - PRA09', 'First lesson of practice PRA09.', 'PRA09', 'PUN01', 'CON01'),
('LEC34', 'Lesson 2 - PRA09', 'Second lesson of practice PRA09.', 'PRA09', 'PUN01', 'CON02'),
('LEC35', 'Lesson 3 - PRA09', 'Third lesson of practice PRA09.', 'PRA09', 'PUN01', 'CON03'),
('LEC36', 'Lesson 4 - PRA09', 'Fourth lesson of practice PRA09.', 'PRA09', 'PUN01', 'CON06'),

-- PRA10
('LEC37', 'Lesson 1 - PRA10', 'First lesson of practice PRA10.', 'PRA10', 'PUN01', 'CON01'),
('LEC38', 'Lesson 2 - PRA10', 'Second lesson of practice PRA10.', 'PRA10', 'PUN01', 'CON02'),
('LEC39', 'Lesson 3 - PRA10', 'Third lesson of practice PRA10.', 'PRA10', 'PUN01', 'CON03'),
('LEC40', 'Lesson 4 - PRA10', 'Fourth lesson of practice PRA10.', 'PRA10', 'PUN01', 'CON06');

INSERT INTO bitacora_profesor VALUES
('BITP01', '2026-08-01', '09:15:00', 'Created a new word list: Animals.', 'PROF01'),
('BITP02', '2026-08-04', '10:30:00', 'Updated the Food word list.', 'PROF02'),
('BITP03', '2026-08-07', '11:45:00', 'Created a new word list: Colors.', 'PROF03'),
('BITP04', '2026-08-10', '13:20:00', 'Assigned the Family word list to a group.', 'PROF04'),
('BITP05', '2026-08-13', '14:10:00', 'Created a new word list: School.', 'PROF05');

INSERT INTO bitacora_administrador VALUES
('BITA01', '2026-08-01', '08:30:00', 'Registered a new student account.', 'USR0016'),
('BITA02', '2026-08-02', '09:45:00', 'Updated user information.', 'USR0017'),
('BITA03', '2026-08-03', '10:15:00', 'Registered a new teacher account.', 'USR0018'),
('BITA04', '2026-08-04', '12:00:00', 'Updated a career record.', 'USR0019'),
('BITA05', '2026-08-05', '13:30:00', 'Created a database backup.', 'USR0020');

INSERT INTO grupo_carrera VALUES
('GRU01', 'EII'),
('GRU02', 'EII'),
('GRU03', 'PP'),
('GRU04', 'PP'),
('GRU05', 'OLCE'),
('GRU06', 'OLCE'),
('GRU07', 'DSM'),
('GRU08', 'DSM'),
('GRU09', 'IRD'),
('GRU10', 'IRD');

INSERT INTO copia_seguridad VALUES
('COP01', 'Backup_2026_08_01', '2026-08-01', '18:00:00', 'Full database backup.', 'AD01'),
('COP02', 'Backup_2026_08_08', '2026-08-08', '18:30:00', 'Full database backup.', 'AD02'),
('COP03', 'Backup_2026_08_15', '2026-08-15', '19:00:00', 'Full database backup.', 'AD03'),
('COP04', 'Backup_2026_08_22', '2026-08-22', '19:30:00', 'Full database backup.', 'AD04'),
('COP05', 'Backup_2026_08_29', '2026-08-29', '20:00:00', 'Full database backup.', 'AD05');

INSERT INTO competencia VALUES
('COM01', 'Animals Spelling Challenge', '2026-08-15', '10:00:00', 'PROF01'),
('COM02', 'Food Spelling Challenge', '2026-08-18', '11:00:00', 'PROF02'),
('COM03', 'Colors Spelling Challenge', '2026-08-21', '12:00:00', 'PROF03'),
('COM04', 'Family Spelling Challenge', '2026-08-24', '13:00:00', 'PROF04'),
('COM05', 'School Spelling Challenge', '2026-08-27', '14:00:00', 'PROF05');

INSERT INTO lista_competencia VALUES
('LIS01', 'COM01'),
('LIS02', 'COM02'),
('LIS03', 'COM03'),
('LIS04', 'COM04'),
('LIS05', 'COM05');

INSERT INTO lista_leccion VALUES
('LIS01', 'LEC01'),
('LIS01', 'LEC02'),
('LIS01', 'LEC03'),
('LIS01', 'LEC04'),

('LIS02', 'LEC05'),
('LIS02', 'LEC06'),
('LIS02', 'LEC07'),
('LIS02', 'LEC08'),

('LIS03', 'LEC09'),
('LIS03', 'LEC10'),
('LIS03', 'LEC11'),
('LIS03', 'LEC12'),

('LIS04', 'LEC13'),
('LIS04', 'LEC14'),
('LIS04', 'LEC15'),
('LIS04', 'LEC16'),

('LIS05', 'LEC17'),
('LIS05', 'LEC18'),
('LIS05', 'LEC19'),
('LIS05', 'LEC20'),

('LIS06', 'LEC21'),
('LIS06', 'LEC22'),
('LIS06', 'LEC23'),
('LIS06', 'LEC24'),

('LIS07', 'LEC25'),
('LIS07', 'LEC26'),
('LIS07', 'LEC27'),
('LIS07', 'LEC28'),

('LIS08', 'LEC29'),
('LIS08', 'LEC30'),
('LIS08', 'LEC31'),
('LIS08', 'LEC32'),

('LIS09', 'LEC33'),
('LIS09', 'LEC34'),
('LIS09', 'LEC35'),
('LIS09', 'LEC36'),

('LIS10', 'LEC37'),
('LIS10', 'LEC38'),
('LIS10', 'LEC39'),
('LIS10', 'LEC40');

INSERT INTO alumno_leccion VALUES
('2026100001', 'LEC01'),
('2026100001', 'LEC02'),
('2026100001', 'LEC03'),
('2026100001', 'LEC04'),

('2026100002', 'LEC05'),
('2026100002', 'LEC06'),
('2026100002', 'LEC07'),
('2026100002', 'LEC08'),

('2026100003', 'LEC09'),
('2026100003', 'LEC10'),
('2026100003', 'LEC11'),
('2026100003', 'LEC12'),

('2026100004', 'LEC13'),
('2026100004', 'LEC14'),
('2026100004', 'LEC15'),
('2026100004', 'LEC16'),

('2026100005', 'LEC17'),
('2026100005', 'LEC18'),
('2026100005', 'LEC19'),
('2026100005', 'LEC20');

SELECT * FROM usuario;

SHOW TABLES LIKE 'usuario%';

SHOW TABLES LIKE '%groups%';

SHOW TABLES LIKE '%permission%';

SHOW CREATE TABLE auth_user;

SELECT correo, COUNT(*) AS cantidad
FROM usuario
GROUP BY correo
HAVING COUNT(*) > 1;

SHOW CREATE TABLE auth_group;

SHOW CREATE TABLE auth_permission;

SHOW CREATE TABLE auth_user_groups;

SHOW CREATE TABLE auth_user_user_permissions;

--MODIFICAR TABLA USUARIO EN PHPMYADMIN
ALTER TABLE usuario
ADD COLUMN last_login DATETIME(6) NULL,
ADD COLUMN is_superuser TINYINT(1) NOT NULL DEFAULT 0,
ADD COLUMN is_staff TINYINT(1) NOT NULL DEFAULT 0,
ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1;

--CREAR TABLAS EN PHPMYADMIN
CREATE TABLE usuario_groups (
    id BIGINT NOT NULL AUTO_INCREMENT,
    usuario_id VARCHAR(10) NOT NULL,
    group_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY usuario_groups_usuario_id_group_id_uniq (usuario_id, group_id),
    KEY usuario_groups_group_id_fk (group_id),
    CONSTRAINT usuario_groups_group_id_fk
        FOREIGN KEY (group_id) REFERENCES auth_group(id),
    CONSTRAINT usuario_groups_usuario_id_fk
        FOREIGN KEY (usuario_id) REFERENCES usuario(codigo)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci;

CREATE TABLE usuario_user_permissions (
    id BIGINT NOT NULL AUTO_INCREMENT,
    usuario_id VARCHAR(10) NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY usuario_user_permissions_usuario_id_permission_id_uniq
        (usuario_id, permission_id),
    KEY usuario_user_permissions_permission_id_fk (permission_id),
    CONSTRAINT usuario_user_permissions_permission_id_fk
        FOREIGN KEY (permission_id) REFERENCES auth_permission(id),
    CONSTRAINT usuario_user_permissions_usuario_id_fk
        FOREIGN KEY (usuario_id) REFERENCES usuario(codigo)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci;

--MODIFICAR TABLA DE USUARIO
ALTER TABLE usuario
ADD UNIQUE KEY usuario_correo_unique (correo);

SHOW CREATE TABLE usuario;

--CREACIÓN DE SUPERUSER
--Correo: jesus.omar@spell-challenge.usa
--Nombre pila: Jesus Omar
--ApellidoPaterno: Castañon
--ApellidoMaterno: Castañon
--Tipo usuario (TipoUsuario.clave): TUSR01
--Password: jesus1234
--Password (again): jesus1234

ALTER TABLE django_admin_log
DROP FOREIGN KEY django_admin_log_user_id_c564eba6_fk_auth_user_id;

ALTER TABLE django_admin_log
MODIFY COLUMN user_id varchar(10) NOT NULL;

ALTER TABLE django_admin_log
ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_usuario_codigo
FOREIGN KEY (user_id) REFERENCES usuario(codigo);

ALTER TABLE palabra
ADD COLUMN definicion VARCHAR(255) NULL,
ADD COLUMN ejemplo VARCHAR(255) NULL;

UPDATE palabra SET
    definicion = 'A round fruit that is usually red, green, or yellow.',
    ejemplo = 'I eat an apple every morning.'
WHERE codigo = 'PAL0001';

UPDATE palabra SET
    definicion = 'A large wild cat with orange fur and black stripes.',
    ejemplo = 'The tiger is one of the largest wild cats.'
WHERE codigo = 'PAL0002';

UPDATE palabra SET
    definicion = 'A color made by mixing red and blue.',
    ejemplo = 'Her favorite color is purple.'
WHERE codigo = 'PAL0003';

UPDATE palabra SET
    definicion = 'A female parent.',
    ejemplo = 'My mother cooks dinner every evening.'
WHERE codigo = 'PAL0004';

UPDATE palabra SET
    definicion = 'A thin writing tool with a graphite core.',
    ejemplo = 'I write my homework with a pencil.'
WHERE codigo = 'PAL0005';

UPDATE palabra SET
    definicion = 'A sport in which two teams try to score by kicking a ball into a goal.',
    ejemplo = 'We play soccer after school.'
WHERE codigo = 'PAL0006';

UPDATE palabra SET
    definicion = 'A large area covered mainly by trees and other plants.',
    ejemplo = 'We walked through the forest.'
WHERE codigo = 'PAL0007';

UPDATE palabra SET
    definicion = 'A portable computer that can be used in different places.',
    ejemplo = 'I use my laptop for school projects.'
WHERE codigo = 'PAL0008';

UPDATE palabra SET
    definicion = 'Feeling good, pleased, or satisfied.',
    ejemplo = 'She is happy because she passed the exam.'
WHERE codigo = 'PAL0009';

UPDATE palabra SET
    definicion = 'A two-wheeled vehicle that you ride by pushing pedals.',
    ejemplo = 'He rides his bicycle to school.'
WHERE codigo = 'PAL0010';

-- ANIMALS

UPDATE palabra SET
    definicion = 'A small animal with long ears that can hop.',
    ejemplo = 'The rabbit is eating a carrot.'
WHERE codigo = 'PAL0011';

UPDATE palabra SET
    definicion = 'An intelligent animal that lives mainly in trees and has a long tail.',
    ejemplo = 'The monkey is climbing the tree.'
WHERE codigo = 'PAL0012';

UPDATE palabra SET
    definicion = 'A highly intelligent sea animal that lives in groups.',
    ejemplo = 'We saw a dolphin swimming near the boat.'
WHERE codigo = 'PAL0013';

UPDATE palabra SET
    definicion = 'A very large land animal with a long trunk and large ears.',
    ejemplo = 'The elephant is drinking water.'
WHERE codigo = 'PAL0014';

UPDATE palabra SET
    definicion = 'A black and white bird that cannot fly and lives in cold regions.',
    ejemplo = 'The penguin is walking on the ice.'
WHERE codigo = 'PAL0015';

-- FOOD

UPDATE palabra SET
    definicion = 'A long curved fruit with yellow skin.',
    ejemplo = 'She ate a banana for breakfast.'
WHERE codigo = 'PAL0016';

UPDATE palabra SET
    definicion = 'A food made from milk that can be hard or soft.',
    ejemplo = 'I like cheese on my sandwich.'
WHERE codigo = 'PAL0017';

UPDATE palabra SET
    definicion = 'A type of bird that is commonly eaten as food.',
    ejemplo = 'We had chicken for dinner.'
WHERE codigo = 'PAL0018';

UPDATE palabra SET
    definicion = 'Food made with two pieces of bread and a filling between them.',
    ejemplo = 'I made a sandwich for lunch.'
WHERE codigo = 'PAL0019';

UPDATE palabra SET
    definicion = 'A plant or part of a plant that is used as food.',
    ejemplo = 'Eating vegetables is good for your health.'
WHERE codigo = 'PAL0020';

-- COLORS

UPDATE palabra SET
    definicion = 'The color of blood, strawberries, or roses.',
    ejemplo = 'The car is red.'
WHERE codigo = 'PAL0021';

UPDATE palabra SET
    definicion = 'The color of the sun and many ripe bananas.',
    ejemplo = 'She is wearing a yellow dress.'
WHERE codigo = 'PAL0022';

UPDATE palabra SET
    definicion = 'A color produced by mixing red and yellow.',
    ejemplo = 'The orange ball is on the table.'
WHERE codigo = 'PAL0023';

UPDATE palabra SET
    definicion = 'The color of grass and many leaves.',
    ejemplo = 'The grass is green.'
WHERE codigo = 'PAL0024';

UPDATE palabra SET
    definicion = 'A blue-green color.',
    ejemplo = 'She chose a turquoise shirt.'
WHERE codigo = 'PAL0025';

-- FAMILY

UPDATE palabra SET
    definicion = 'A male parent.',
    ejemplo = 'My father works at a hospital.'
WHERE codigo = 'PAL0026';

UPDATE palabra SET
    definicion = 'A girl or woman who has the same parents as you.',
    ejemplo = 'My sister is older than me.'
WHERE codigo = 'PAL0027';

UPDATE palabra SET
    definicion = 'A boy or man who has the same parents as you.',
    ejemplo = 'My brother plays soccer.'
WHERE codigo = 'PAL0028';

UPDATE palabra SET
    definicion = 'A female child of a person.',
    ejemplo = 'Their daughter is six years old.'
WHERE codigo = 'PAL0029';

UPDATE palabra SET
    definicion = 'The mother of your mother or father.',
    ejemplo = 'My grandmother makes delicious cookies.'
WHERE codigo = 'PAL0030';

-- SCHOOL

UPDATE palabra SET
    definicion = 'A set of pages with printed or written information, usually covered with a cover.',
    ejemplo = 'I am reading a book.'
WHERE codigo = 'PAL0031';

UPDATE palabra SET
    definicion = 'A person who teaches students.',
    ejemplo = 'The teacher explained the lesson.'
WHERE codigo = 'PAL0032';

UPDATE palabra SET
    definicion = 'A room where students learn at school.',
    ejemplo = 'The students are in the classroom.'
WHERE codigo = 'PAL0033';

UPDATE palabra SET
    definicion = 'Work that students must do at home for school.',
    ejemplo = 'I need to finish my homework tonight.'
WHERE codigo = 'PAL0034';

UPDATE palabra SET
    definicion = 'A piece of work that a student is asked to complete.',
    ejemplo = 'The teacher gave us a new assignment.'
WHERE codigo = 'PAL0035';

-- SPORTS

UPDATE palabra SET
    definicion = 'A sport played by hitting a ball over a net with a racket.',
    ejemplo = 'She plays tennis every Saturday.'
WHERE codigo = 'PAL0036';

UPDATE palabra SET
    definicion = 'A sport in which two teams try to score points by throwing a ball through a hoop.',
    ejemplo = 'They play basketball after class.'
WHERE codigo = 'PAL0037';

UPDATE palabra SET
    definicion = 'A sport in which players hit a ball with a bat and run around bases.',
    ejemplo = 'My brother plays baseball.'
WHERE codigo = 'PAL0038';

UPDATE palabra SET
    definicion = 'The activity or sport of moving through water by using your arms and legs.',
    ejemplo = 'Swimming is my favorite sport.'
WHERE codigo = 'PAL0039';

UPDATE palabra SET
    definicion = 'A contest in which people or teams compete against each other.',
    ejemplo = 'Our school is having a spelling competition.'
WHERE codigo = 'PAL0040';

-- NATURE

UPDATE palabra SET
    definicion = 'A tall plant with a trunk, branches, and leaves.',
    ejemplo = 'There is a big tree in the garden.'
WHERE codigo = 'PAL0041';

UPDATE palabra SET
    definicion = 'The colorful part of a plant that often has a pleasant smell.',
    ejemplo = 'This flower is very beautiful.'
WHERE codigo = 'PAL0042';

UPDATE palabra SET
    definicion = 'A natural flow of water that moves across land.',
    ejemplo = 'The river flows through the city.'
WHERE codigo = 'PAL0043';

UPDATE palabra SET
    definicion = 'A very high area of land with steep sides, often higher than a hill.',
    ejemplo = 'We climbed the mountain last summer.'
WHERE codigo = 'PAL0044';

UPDATE palabra SET
    definicion = 'A place where water falls from a high point to a lower point.',
    ejemplo = 'The waterfall is surrounded by trees.'
WHERE codigo = 'PAL0045';

-- TECHNOLOGY

UPDATE palabra SET
    definicion = 'A device used for calling and communicating with people.',
    ejemplo = 'I use my phone to call my parents.'
WHERE codigo = 'PAL0046';

UPDATE palabra SET
    definicion = 'An electronic machine that processes and stores information.',
    ejemplo = 'I use my computer to study.'
WHERE codigo = 'PAL0047';

UPDATE palabra SET
    definicion = 'A set of keys used to type letters, numbers, and symbols on a computer.',
    ejemplo = 'My keyboard has many different keys.'
WHERE codigo = 'PAL0048';

UPDATE palabra SET
    definicion = 'Programs and instructions that make a computer work.',
    ejemplo = 'The software needs to be updated.'
WHERE codigo = 'PAL0049';

UPDATE palabra SET
    definicion = 'An organized collection of information stored in a computer system.',
    ejemplo = 'The application stores the information in a database.'
WHERE codigo = 'PAL0050';

-- FEELINGS

UPDATE palabra SET
    definicion = 'Feeling unhappy or not pleased.',
    ejemplo = 'He felt sad after losing the game.'
WHERE codigo = 'PAL0051';

UPDATE palabra SET
    definicion = 'Feeling very upset or annoyed.',
    ejemplo = 'She was angry because someone broke her phone.'
WHERE codigo = 'PAL0052';

UPDATE palabra SET
    definicion = 'Feeling very happy and enthusiastic about something.',
    ejemplo = 'The students are excited about the competition.'
WHERE codigo = 'PAL0053';

UPDATE palabra SET
    definicion = 'Feeling worried or afraid about something that may happen.',
    ejemplo = 'I feel nervous before an exam.'
WHERE codigo = 'PAL0054';

UPDATE palabra SET
    definicion = 'Feeling sure about your abilities or decisions.',
    ejemplo = 'She feels confident when she speaks English.'
WHERE codigo = 'PAL0055';

-- VEHICLES

UPDATE palabra SET
    definicion = 'A road vehicle with four wheels used to carry people.',
    ejemplo = 'My family has a new car.'
WHERE codigo = 'PAL0056';

UPDATE palabra SET
    definicion = 'A large road vehicle that carries many passengers.',
    ejemplo = 'I take the bus to school.'
WHERE codigo = 'PAL0057';

UPDATE palabra SET
    definicion = 'A long vehicle that travels on railway tracks.',
    ejemplo = 'The train arrived at the station.'
WHERE codigo = 'PAL0058';

UPDATE palabra SET
    definicion = 'A vehicle with wings that flies through the air.',
    ejemplo = 'The airplane is flying over the city.'
WHERE codigo = 'PAL0059';

UPDATE palabra SET
    definicion = 'A two-wheeled vehicle powered by an engine.',
    ejemplo = 'He rides his motorcycle to work.'
WHERE codigo = 'PAL0060';

UPDATE palabra
SET
    definicion = CASE codigo
        WHEN 'PAL0061' THEN 'To rub a surface with something rough and remove part of it.'
        WHEN 'PAL0062' THEN 'In or to a foreign country.'
        WHEN 'PAL0063' THEN 'To take in or soak up a substance or energy.'
        WHEN 'PAL0064' THEN 'To agree to receive or do something.'
        WHEN 'PAL0065' THEN 'The ability or right to enter, use, or reach something.'
        WHEN 'PAL0066' THEN 'To say that someone has done something wrong or illegal.'
        WHEN 'PAL0067' THEN 'Having a continuous or painful feeling in the body.'
        WHEN 'PAL0068' THEN 'Doing things or moving rather than being still.'
        WHEN 'PAL0069' THEN 'The ability to see, hear, or understand things clearly and accurately.'
        WHEN 'PAL0070' THEN 'To stick firmly to something or follow a rule or agreement.'
        WHEN 'PAL0071' THEN 'To change something slightly to make it work better or fit better.'
        WHEN 'PAL0072' THEN 'To respect or like someone because of their qualities or achievements.'
        WHEN 'PAL0073' THEN 'An opinion about what someone should do.'
        WHEN 'PAL0074' THEN 'To tell someone what you think they should do.'
        WHEN 'PAL0075' THEN 'To have enough money or time to pay for or do something.'
        WHEN 'PAL0076' THEN 'Feeling fear or worried about something.'
        WHEN 'PAL0077' THEN 'Unfair treatment or discrimination based on a person’s age.'
        WHEN 'PAL0078' THEN 'Makes someone feel surprised, impressed, or pleased.'
        WHEN 'PAL0079' THEN 'A quantity of something.'
        WHEN 'PAL0080' THEN 'Happening once every year.'
        WHEN 'PAL0081' THEN 'A request for a decision to be changed or a situation to be considered again.'
        WHEN 'PAL0082' THEN 'To become visible or be seen.'
        WHEN 'PAL0083' THEN 'Relating to the language, culture, or people of Arab countries.'
        WHEN 'PAL0084' THEN 'To reach a place after traveling.'
        WHEN 'PAL0085' THEN 'On or toward the land from the sea.'
        WHEN 'PAL0086' THEN 'In a state of sleep.'
        WHEN 'PAL0087' THEN 'To accept something as true without proof.'
        WHEN 'PAL0088' THEN 'To use force against a person, place, or group.'
        WHEN 'PAL0089' THEN 'A fight between people, groups, or armies.'
        WHEN 'PAL0090' THEN 'To start to be or develop into something.'
        WHEN 'PAL0091' THEN 'For the benefit or advantage of someone.'
        WHEN 'PAL0092' THEN 'A feeling of trust or confidence in something or someone.'
        WHEN 'PAL0093' THEN 'To be in the right place or to be accepted as a member of a group.'
        WHEN 'PAL0094' THEN 'Of a higher quality or more desirable than another thing.'
        WHEN 'PAL0095' THEN 'Having a sharp, unpleasant taste or feeling.'
        WHEN 'PAL0096' THEN 'Burned brightly or strongly in the past.'
        WHEN 'PAL0097' THEN 'A disease or condition that causes plants to die or become damaged.'
        WHEN 'PAL0098' THEN 'A type of hat, especially one worn as part of a uniform.'
        WHEN 'PAL0099' THEN 'Not interesting or exciting.'
        WHEN 'PAL0100' THEN 'To take and use something belonging to someone else with the intention of returning it.'
        WHEN 'PAL0101' THEN 'To move quickly away from a surface after hitting it.'
        WHEN 'PAL0102' THEN 'A reward or amount of money offered for something.'
        WHEN 'PAL0103' THEN 'The air that you take into and send out of your lungs.'
        WHEN 'PAL0104' THEN 'A plan showing how much money is available and how it will be spent.'
        WHEN 'PAL0105' THEN 'A heavy responsibility or problem.'
        WHEN 'PAL0106' THEN 'An office or organization that provides a particular service.'
        WHEN 'PAL0107' THEN 'A hole or passage made by an animal under the ground.'
        WHEN 'PAL0108' THEN 'A soft yellow food made from milk and used in cooking or on bread.'
        WHEN 'PAL0109' THEN 'Belonging to or relating to a time in the past.'
        WHEN 'PAL0110' THEN 'Strong cloth used for making things such as bags, tents, or paintings.'
        WHEN 'PAL0111' THEN 'A curved nut with a hard shell and a sweet taste.'
        WHEN 'PAL0112' THEN 'A meeting or group of people, especially members of a political party.'
        WHEN 'PAL0113' THEN 'Caught or captured, or received a ball or object successfully.'
        WHEN 'PAL0114' THEN 'A possibility or occasion for something to happen.'
        WHEN 'PAL0115' THEN 'To make something different or become different.'
        WHEN 'PAL0116' THEN 'To ask someone to pay money or to officially accuse someone of a crime.'
        WHEN 'PAL0117' THEN 'To decide which thing you want from two or more possibilities.'
        WHEN 'PAL0118' THEN 'A completely round shape or a group of people or things forming a ring.'
        WHEN 'PAL0119' THEN 'To promise or decide to do something or to become involved in something.'
        WHEN 'PAL0120' THEN 'Happening often or shared by many people.'
        WHEN 'PAL0121' THEN 'To obey a rule, order, or request.'
        WHEN 'PAL0122' THEN 'A reddish-brown metal.'
        WHEN 'PAL0123' THEN 'A soft natural material used to make cloth and clothing.'
        WHEN 'PAL0124' THEN 'An administrative area of a country or state.'
        WHEN 'PAL0125' THEN 'To make or produce something new.'
        WHEN 'PAL0126' THEN 'Praise or recognition given to someone for something they have done.'
        WHEN 'PAL0127' THEN 'Physical or other harm caused to something.'
        WHEN 'PAL0128' THEN 'The possibility that something harmful or dangerous may happen.'
        WHEN 'PAL0129' THEN 'Acceptable, satisfactory, or of a reasonably good standard.'
        WHEN 'PAL0130' THEN 'To make a choice after thinking about different possibilities.'
        WHEN 'PAL0131' THEN 'To win against someone or something.'
        WHEN 'PAL0132' THEN 'A level or amount of something, or a university qualification.'
        WHEN 'PAL0133' THEN 'A strong request for something to be done or provided.'
        WHEN 'PAL0134' THEN 'To need someone or something for support or to function.'
        WHEN 'PAL0135' THEN 'To use or arrange people, equipment, or resources for a particular purpose.'
        WHEN 'PAL0136' THEN 'A large dry area of land with very little rain.'
        WHEN 'PAL0137' THEN 'A plan or drawing that shows how something will look or work.'
        WHEN 'PAL0138' THEN 'A strong wish to have or do something.'
        WHEN 'PAL0139' THEN 'A small piece of information or an individual part of something.'
        WHEN 'PAL0140' THEN 'An object or piece of equipment designed for a particular purpose.'
        WHEN 'PAL0141' THEN 'To be different from someone or something else.'
        WHEN 'PAL0142' THEN 'Twice as much or twice as many.'
        WHEN 'PAL0143' THEN 'The result or influence that an action or event has.'
        WHEN 'PAL0144' THEN 'One or the other of two choices or possibilities.'
        WHEN 'PAL0145' THEN 'To make something possible or allow someone to do something.'
        WHEN 'PAL0146' THEN 'To become involved in an activity or situation.'
        WHEN 'PAL0147' THEN 'As much or as many as needed.'
        WHEN 'PAL0148' THEN 'To make certain that something happens or is true.'
        WHEN 'PAL0149' THEN 'To involve something as a necessary part or consequence.'
        WHEN 'PAL0150' THEN 'Whole or complete.'
        WHEN 'PAL0151' THEN 'Fairness and equal treatment for different people or groups.'
        WHEN 'PAL0152' THEN 'To become larger or make something larger.'
        WHEN 'PAL0153' THEN 'To think that something will happen.'
        WHEN 'PAL0154' THEN 'A person with a high level of knowledge or skill in a particular subject.'
        WHEN 'PAL0155' THEN 'To make something longer or continue something for a longer time.'
        WHEN 'PAL0156' THEN 'Being directed toward or dealing with a particular situation.'
        WHEN 'PAL0157' THEN 'Known by many people.'
        WHEN 'PAL0158' THEN 'The act of traveling by air, or a journey by airplane.'
        WHEN 'PAL0159' THEN 'To go after or move behind someone or something.'
        WHEN 'PAL0160' THEN 'To officially tell someone that they must not do something.'
        WHEN 'PAL0161' THEN 'To fail to remember something.'
        WHEN 'PAL0162' THEN 'Suitable for official or serious situations.'
        WHEN 'PAL0163' THEN 'Having existed or happened before the present time.'
        WHEN 'PAL0164' THEN 'To turn from liquid into solid because of cold.'
        WHEN 'PAL0165' THEN 'A tube or container that is wider at one end.'
        WHEN 'PAL0166' THEN 'Existing or available in very large amounts.'
        WHEN 'PAL0167' THEN 'To bring people or things together in one place.'
        WHEN 'PAL0168' THEN 'Designed or arranged to work well for a particular purpose.'
        WHEN 'PAL0169' THEN 'The process of growing, increasing, or developing.'
        WHEN 'PAL0170' THEN 'Responsible for a crime or wrong action.'
        WHEN 'PAL0171' THEN 'A place where ships can stay safely near the land.'
        WHEN 'PAL0172' THEN 'Almost not or only to a small degree.'
        WHEN 'PAL0173' THEN 'A strong feeling of fear or something that causes extreme fear.'
        WHEN 'PAL0174' THEN 'A combination of two different systems, ideas, or types.'
        WHEN 'PAL0175' THEN 'To deliberately pay no attention to someone or something.'
        WHEN 'PAL0176' THEN 'To give someone information about something.'
        WHEN 'PAL0177' THEN 'To demand or say something firmly and repeatedly.'
        WHEN 'PAL0178' THEN 'To have a plan or purpose to do something.'
        WHEN 'PAL0179' THEN 'To put money, time, or effort into something with the expectation of a benefit.'
        WHEN 'PAL0180' THEN 'A piece of land surrounded by water.'
        WHEN 'PAL0181' THEN 'To start a fire or light something.'
        WHEN 'PAL0182' THEN 'The second of two people or things mentioned.'
        WHEN 'PAL0183' THEN 'A written or printed symbol used to represent a sound in a language.'
        WHEN 'PAL0184' THEN 'Probably or very probably.'
        WHEN 'PAL0185' THEN 'A substance that can flow and takes the shape of its container.'
        WHEN 'PAL0186' THEN 'To pay attention to a sound or someone speaking.'
        WHEN 'PAL0187' THEN 'Small in size or amount.'
        WHEN 'PAL0188' THEN 'Unhappy because you are alone or without company.'
        WHEN 'PAL0189' THEN 'A comfortable public room or area where people can relax.'
        WHEN 'PAL0190' THEN 'A condition or experience that is expensive and comfortable.'
        WHEN 'PAL0191' THEN 'To control, organize, or be responsible for something.'
        WHEN 'PAL0192' THEN 'A place or system where goods or services are bought and sold.'
        WHEN 'PAL0193' THEN 'A subject, situation, or problem that is being discussed.'
        WHEN 'PAL0194' THEN 'Fully developed or grown.'
        WHEN 'PAL0195' THEN 'Related to the mind or thoughts.'
        WHEN 'PAL0196' THEN 'The central part of something or a position between two sides.'
        WHEN 'PAL0197' THEN 'One part of a larger system or course.'
        WHEN 'PAL0198' THEN 'A small intelligent animal that is related to apes.'
        WHEN 'PAL0199' THEN 'A tissue in the body that produces movement by contracting.'
        WHEN 'PAL0200' THEN 'Having a small distance from one side to the other.'
        WHEN 'PAL0201' THEN 'Connected with the place or country where a person was born or grew up.'
        WHEN 'PAL0202' THEN 'Almost, but not completely.'
        WHEN 'PAL0203' THEN 'A thin, sharp object used for sewing.'
        WHEN 'PAL0204' THEN 'To see, hear, or become aware of something.'
        WHEN 'PAL0205' THEN 'To get or obtain something.'
        WHEN 'PAL0206' THEN 'A room or building where people work.'
        WHEN 'PAL0207' THEN 'A round citrus fruit with orange-colored skin and flesh.'
        WHEN 'PAL0208' THEN 'A writing tool with a thin graphite core inside a wooden or plastic body.'
        WHEN 'PAL0209' THEN 'A large farm tool or machine used to turn over soil.'
        WHEN 'PAL0210' THEN 'A small container or part of clothing used for carrying things.'
        WHEN 'PAL0211' THEN 'A round vegetable that grows underground.'
        WHEN 'PAL0212' THEN 'To like one thing more than another.'
        WHEN 'PAL0213' THEN 'A male member of a royal family.'
        WHEN 'PAL0214' THEN 'A place where people are kept as punishment for crimes.'
        WHEN 'PAL0215' THEN 'Correct, suitable, or appropriate.'
        WHEN 'PAL0216' THEN 'Shown to be true or correct.'
        WHEN 'PAL0217' THEN 'To try to achieve or obtain something.'
        WHEN 'PAL0218' THEN 'A programming language known for its simple and readable syntax.'
        WHEN 'PAL0219' THEN 'To remember something or ask for something to be brought back.'
        WHEN 'PAL0220' THEN 'Having happened or appeared not long ago.'
        WHEN 'PAL0221' THEN 'To say no to something or decline to accept it.'
        WHEN 'PAL0222' THEN 'A system or period of government, especially one that is strict or authoritarian.'
        WHEN 'PAL0223' THEN 'To feel sorry or disappointed about something.'
        WHEN 'PAL0224' THEN 'To be connected with or have a connection to something.'
        WHEN 'PAL0225' THEN 'A feeling of comfort after pain, worry, or difficulty has decreased.'
        WHEN 'PAL0226' THEN 'To continue to exist or stay in a particular place or condition.'
        WHEN 'PAL0227' THEN 'Far away from other people, places, or things.'
        WHEN 'PAL0228' THEN 'To save someone from danger or harm.'
        WHEN 'PAL0229' THEN 'To feel angry or upset because of something unfair or unpleasant.'
        WHEN 'PAL0230' THEN 'To keep or continue to have something.'
        WHEN 'PAL0231' THEN 'To stop working, especially because of reaching a certain age.'
        WHEN 'PAL0232' THEN 'To show something that was previously hidden or unknown.'
        WHEN 'PAL0233' THEN 'A regular pattern of beats, sounds, or movements.'
        WHEN 'PAL0234' THEN 'Rough, strong, and able to survive difficult conditions.'
        WHEN 'PAL0235' THEN 'Small in amount or not enough.'
        WHEN 'PAL0236' THEN 'Frightened or afraid.'
        WHEN 'PAL0237' THEN 'Having attractive natural views or scenery.'
        WHEN 'PAL0238' THEN 'A plan or system intended to achieve a particular purpose.'
        WHEN 'PAL0239' THEN 'A place where children or students go to learn.'
        WHEN 'PAL0240' THEN 'To become comfortable with a new situation or to reach an agreement.'
        WHEN 'PAL0241' THEN 'Very serious, severe, or extreme.'
        WHEN 'PAL0242' THEN 'Used to talk about what someone ought to do or what is expected.'
        WHEN 'PAL0243' THEN 'To become smaller or make something smaller.'
        WHEN 'PAL0244' THEN 'A sign, sound, or message that gives information or a warning.'
        WHEN 'PAL0245' THEN 'A shiny gray-white metal.'
        WHEN 'PAL0246' THEN 'To cook something slowly in liquid just below boiling point.'
        WHEN 'PAL0247' THEN 'Easy to understand, do, or use.'
        WHEN 'PAL0248' THEN 'Small in degree or amount.'
        WHEN 'PAL0249' THEN 'Having an even surface or texture without roughness.'
        WHEN 'PAL0250' THEN 'A feeling of deep sadness.'
        WHEN 'PAL0251' THEN 'Related to the former Soviet Union.'
        WHEN 'PAL0252' THEN 'A soft material with many small holes that absorbs liquid.'
        WHEN 'PAL0253' THEN 'To spread something over an area or among people.'
        WHEN 'PAL0254' THEN 'The season between winter and summer.'
        WHEN 'PAL0255' THEN 'A shape with four equal sides and four right angles.'
        WHEN 'PAL0256' THEN 'Firm, steady, and unlikely to change or fall.'
        WHEN 'PAL0257' THEN 'The current situation or position of a person or thing.'
        WHEN 'PAL0258' THEN 'Firm, regular, and not changing suddenly.'
        WHEN 'PAL0259' THEN 'A continuous flow of water or other liquid.'
        WHEN 'PAL0260' THEN 'A public road in a town or city.'
        WHEN 'PAL0261' THEN 'Strict and requiring rules to be followed exactly.'
        WHEN 'PAL0262' THEN 'To hit something or stop working suddenly, depending on context.'
        WHEN 'PAL0263' THEN 'Hit something with force or was damaged by impact.'
        WHEN 'PAL0264' THEN 'To formally send something for consideration or approval.'
        WHEN 'PAL0265' THEN 'Happening quickly and unexpectedly.'
        WHEN 'PAL0266' THEN 'To experience pain, difficulty, or an unpleasant situation.'
        WHEN 'PAL0267' THEN 'To provide something that is needed or requested.'
        WHEN 'PAL0268' THEN 'A thin strand of cotton, wool, or other material used for sewing or weaving.'
        WHEN 'PAL0269' THEN 'To grow strongly, develop successfully, or become successful.'
        WHEN 'PAL0270' THEN 'The passage in the neck through which food and air travel.'
        WHEN 'PAL0271' THEN 'A small piece of paper or electronic document that allows entry or travel.'
        WHEN 'PAL0272' THEN 'To walk quietly and carefully on the tips of your toes.'
        WHEN 'PAL0273' THEN 'Soft paper used for cleaning, wiping, or other purposes.'
        WHEN 'PAL0274' THEN 'The muscular organ in the mouth used for tasting and speaking.'
        WHEN 'PAL0275' THEN 'A formal agreement between countries or groups.'
        WHEN 'PAL0276' THEN 'The adjustment of musical instruments to the correct pitch.'
        WHEN 'PAL0277' THEN 'A long passage under or through the ground, a mountain, or another structure.'
        WHEN 'PAL0278' THEN 'Not able to do something.'
        WHEN 'PAL0279' THEN 'Not fair or not treating people equally.'
        WHEN 'PAL0280' THEN 'Joined together or made into one group.'
        WHEN 'PAL0281' THEN 'Helpful or practical for a particular purpose.'
        WHEN 'PAL0282' THEN 'The greatest possible amount or degree.'
        WHEN 'PAL0283' THEN 'A space with most or all of the air removed.'
        WHEN 'PAL0284' THEN 'A good quality or behavior that is considered morally valuable.'
        WHEN 'PAL0285' THEN 'A long journey, especially by sea.'
        WHEN 'PAL0286' THEN 'To walk around without a clear purpose or direction.'
        WHEN 'PAL0287' THEN 'A large amount of money, property, or valuable possessions.'
        WHEN 'PAL0288' THEN 'Happening or published once every week.'
        WHEN 'PAL0289' THEN 'How heavy something is.'
        WHEN 'PAL0290' THEN 'A small tool, application, or component that performs a particular function.'
        WHEN 'PAL0291' THEN 'An opening in a wall with glass that lets in light and allows people to see outside.'
        WHEN 'PAL0292' THEN 'The coldest season of the year.'
    END,
    ejemplo = CASE codigo
        WHEN 'PAL0061' THEN 'The workers abraded the surface before painting it.'
        WHEN 'PAL0062' THEN 'She traveled abroad to study English.'
        WHEN 'PAL0063' THEN 'Plants absorb water through their roots.'
        WHEN 'PAL0064' THEN 'She accepted the invitation to the competition.'
        WHEN 'PAL0065' THEN 'Students need access to the online platform.'
        WHEN 'PAL0066' THEN 'The teacher accused him of cheating.'
        WHEN 'PAL0067' THEN 'My back is aching after the long trip.'
        WHEN 'PAL0068' THEN 'She is very active and plays several sports.'
        WHEN 'PAL0069' THEN 'Good visual acuity is important for this task.'
        WHEN 'PAL0070' THEN 'The label must adhere to the surface.'
        WHEN 'PAL0071' THEN 'We need to adjust the settings.'
        WHEN 'PAL0072' THEN 'I admire her dedication to learning English.'
        WHEN 'PAL0073' THEN 'My teacher gave me useful advice.'
        WHEN 'PAL0074' THEN 'I advise you to practice every day.'
        WHEN 'PAL0075' THEN 'We cannot afford a new computer right now.'
        WHEN 'PAL0076' THEN 'The child was afraid of the dark.'
        WHEN 'PAL0077' THEN 'The organization works to reduce ageism.'
        WHEN 'PAL0078' THEN 'The results amaze everyone.'
        WHEN 'PAL0079' THEN 'A large amount of water was needed.'
        WHEN 'PAL0080' THEN 'The school publishes an annual report.'
        WHEN 'PAL0081' THEN 'The student made an appeal against the decision.'
        WHEN 'PAL0082' THEN 'A rainbow appeared after the rain.'
        WHEN 'PAL0083' THEN 'She is taking an Arabic language course.'
        WHEN 'PAL0084' THEN 'We arrived at school early.'
        WHEN 'PAL0085' THEN 'The sailors came ashore after the storm.'
        WHEN 'PAL0086' THEN 'The baby is asleep.'
        WHEN 'PAL0087' THEN 'Do not assume that everyone knows the answer.'
        WHEN 'PAL0088' THEN 'The army attacked the city.'
        WHEN 'PAL0089' THEN 'The two teams prepared for the final battle.'
        WHEN 'PAL0090' THEN 'She wants to become a teacher.'
        WHEN 'PAL0091' THEN 'He spoke on behalf of his team.'
        WHEN 'PAL0092' THEN 'Her belief in herself helped her succeed.'
        WHEN 'PAL0093' THEN 'I feel that I belong in this group.'
        WHEN 'PAL0094' THEN 'This solution is better than the previous one.'
        WHEN 'PAL0095' THEN 'The medicine has a bitter taste.'
        WHEN 'PAL0096' THEN 'The candles blazed brightly during the ceremony.'
        WHEN 'PAL0097' THEN 'The disease caused blight in the crops.'
        WHEN 'PAL0098' THEN 'The driver wore a traditional bonnet.'
        WHEN 'PAL0099' THEN 'The lecture was boring.'
        WHEN 'PAL0100' THEN 'Can I borrow your pencil?'
        WHEN 'PAL0101' THEN 'The ball bounced off the wall.'
        WHEN 'PAL0102' THEN 'The king offered a bounty for the lost treasure.'
        WHEN 'PAL0103' THEN 'Take a deep breath before you speak.'
        WHEN 'PAL0104' THEN 'The team created a budget for the project.'
        WHEN 'PAL0105' THEN 'The heavy burden made the task difficult.'
        WHEN 'PAL0106' THEN 'She works at a government bureau.'
        WHEN 'PAL0107' THEN 'The rabbit disappeared into its burrow.'
        WHEN 'PAL0108' THEN 'She spread butter on the bread.'
        WHEN 'PAL0109' THEN 'That is a story from a bygone era.'
        WHEN 'PAL0110' THEN 'The artist painted on a large canvas.'
        WHEN 'PAL0111' THEN 'She added cashews to the salad.'
        WHEN 'PAL0112' THEN 'The political caucus met before the election.'
        WHEN 'PAL0113' THEN 'The goalkeeper caught the ball.'
        WHEN 'PAL0114' THEN 'There is a chance of rain today.'
        WHEN 'PAL0115' THEN 'We need to change our plans.'
        WHEN 'PAL0116' THEN 'The hotel will charge a fee for parking.'
        WHEN 'PAL0117' THEN 'You can choose any book you like.'
        WHEN 'PAL0118' THEN 'Draw a circle around the correct answer.'
        WHEN 'PAL0119' THEN 'They committed to finishing the project.'
        WHEN 'PAL0120' THEN 'English is a common language around the world.'
        WHEN 'PAL0121' THEN 'All students must comply with the rules.'
        WHEN 'PAL0122' THEN 'The statue is made of copper.'
        WHEN 'PAL0123' THEN 'This shirt is made of cotton.'
        WHEN 'PAL0124' THEN 'The county has several small towns.'
        WHEN 'PAL0125' THEN 'Students create projects during the course.'
        WHEN 'PAL0126' THEN 'She received credit for her excellent work.'
        WHEN 'PAL0127' THEN 'The storm caused serious damage.'
        WHEN 'PAL0128' THEN 'The warning helped us avoid danger.'
        WHEN 'PAL0129' THEN 'He found a decent place to stay.'
        WHEN 'PAL0130' THEN 'You need to decide before Friday.'
        WHEN 'PAL0131' THEN 'Our team defeated the champions.'
        WHEN 'PAL0132' THEN 'She earned a degree in computer science.'
        WHEN 'PAL0133' THEN 'The company received a demand for payment.'
        WHEN 'PAL0134' THEN 'Children depend on adults for support.'
        WHEN 'PAL0135' THEN 'The company deployed new equipment.'
        WHEN 'PAL0136' THEN 'Very little rain falls in the desert.'
        WHEN 'PAL0137' THEN 'She created the design for the new website.'
        WHEN 'PAL0138' THEN 'He has a strong desire to learn.'
        WHEN 'PAL0139' THEN 'Please check every detail before submitting it.'
        WHEN 'PAL0140' THEN 'This device can measure temperature.'
        WHEN 'PAL0141' THEN 'The two products differ in price.'
        WHEN 'PAL0142' THEN 'This room is double the size of the other one.'
        WHEN 'PAL0143' THEN 'The medicine had a positive effect.'
        WHEN 'PAL0144' THEN 'You can choose either option.'
        WHEN 'PAL0145' THEN 'The app enables students to practice anywhere.'
        WHEN 'PAL0146' THEN 'Students engage in different learning activities.'
        WHEN 'PAL0147' THEN 'We have enough time to finish.'
        WHEN 'PAL0148' THEN 'Please ensure that the door is closed.'
        WHEN 'PAL0149' THEN 'The job will entail some travel.'
        WHEN 'PAL0150' THEN 'The entire class participated.'
        WHEN 'PAL0151' THEN 'The program promotes equity in education.'
        WHEN 'PAL0152' THEN 'The company plans to expand next year.'
        WHEN 'PAL0153' THEN 'I expect the competition to be challenging.'
        WHEN 'PAL0154' THEN 'We asked an expert for advice.'
        WHEN 'PAL0155' THEN 'The teacher extended the deadline.'
        WHEN 'PAL0156' THEN 'We are facing a difficult problem.'
        WHEN 'PAL0157' THEN 'She became famous after winning the competition.'
        WHEN 'PAL0158' THEN 'The flight leaves at eight o’clock.'
        WHEN 'PAL0159' THEN 'Please follow the instructions carefully.'
        WHEN 'PAL0160' THEN 'The rules forbid students from using phones.'
        WHEN 'PAL0161' THEN 'Do not forget your homework.'
        WHEN 'PAL0162' THEN 'He wore formal clothes to the event.'
        WHEN 'PAL0163' THEN 'The former teacher visited the school.'
        WHEN 'PAL0164' THEN 'Water can freeze when the temperature drops.'
        WHEN 'PAL0165' THEN 'The liquid passed through the funnel.'
        WHEN 'PAL0166' THEN 'There were flowers galore at the festival.'
        WHEN 'PAL0167' THEN 'The students gathered in the classroom.'
        WHEN 'PAL0168' THEN 'The system is geared toward helping students learn.'
        WHEN 'PAL0169' THEN 'The company experienced rapid growth.'
        WHEN 'PAL0170' THEN 'The man was found guilty of the crime.'
        WHEN 'PAL0171' THEN 'The ships returned safely to the harbor.'
        WHEN 'PAL0172' THEN 'The patient could hardly walk.'
        WHEN 'PAL0173' THEN 'The movie was full of horror.'
        WHEN 'PAL0174' THEN 'The car uses a hybrid engine.'
        WHEN 'PAL0175' THEN 'Please do not ignore the warning.'
        WHEN 'PAL0176' THEN 'The teacher informed us about the changes.'
        WHEN 'PAL0177' THEN 'She insisted on finishing the project.'
        WHEN 'PAL0178' THEN 'They intend to improve the system.'
        WHEN 'PAL0179' THEN 'Many people invest in education.'
        WHEN 'PAL0180' THEN 'We spent a week on a tropical island.'
        WHEN 'PAL0181' THEN 'They used dry wood to kindle the fire.'
        WHEN 'PAL0182' THEN 'The latter option is cheaper.'
        WHEN 'PAL0183' THEN 'Write one letter in each box.'
        WHEN 'PAL0184' THEN 'She will likely arrive soon.'
        WHEN 'PAL0185' THEN 'Water is a common liquid.'
        WHEN 'PAL0186' THEN 'Please listen to the instructions.'
        WHEN 'PAL0187' THEN 'There is a little time left.'
        WHEN 'PAL0188' THEN 'He felt lonely after moving to a new city.'
        WHEN 'PAL0189' THEN 'We waited in the airport lounge.'
        WHEN 'PAL0190' THEN 'They stayed in a luxury hotel.'
        WHEN 'PAL0191' THEN 'She manages the school computer system.'
        WHEN 'PAL0192' THEN 'The company sells its products in the local market.'
        WHEN 'PAL0193' THEN 'Climate change is an important matter.'
        WHEN 'PAL0194' THEN 'The fruit is mature and ready to eat.'
        WHEN 'PAL0195' THEN 'Mental health is important for students.'
        WHEN 'PAL0196' THEN 'The teacher stood in the middle of the room.'
        WHEN 'PAL0197' THEN 'This module explains the basic concepts.'
        WHEN 'PAL0198' THEN 'The monkey climbed the tree quickly.'
        WHEN 'PAL0199' THEN 'Regular exercise helps strengthen your muscles.'
        WHEN 'PAL0200' THEN 'The road is too narrow for two cars.'
        WHEN 'PAL0201' THEN 'English is not my native language.'
        WHEN 'PAL0202' THEN 'The project is nearly finished.'
        WHEN 'PAL0203' THEN 'She used a needle to sew the fabric.'
        WHEN 'PAL0204' THEN 'Did you notice the change in the classroom?'
        WHEN 'PAL0205' THEN 'Students can obtain information from the library.'
        WHEN 'PAL0206' THEN 'She works in an office downtown.'
        WHEN 'PAL0207' THEN 'I ate an orange after lunch.'
        WHEN 'PAL0208' THEN 'I need a pencil to write the answer.'
        WHEN 'PAL0209' THEN 'The farmer used a plough to prepare the field.'
        WHEN 'PAL0210' THEN 'He kept his keys in his pocket.'
        WHEN 'PAL0211' THEN 'We planted potatoes in the garden.'
        WHEN 'PAL0212' THEN 'I prefer tea to coffee.'
        WHEN 'PAL0213' THEN 'The prince waved to the crowd.'
        WHEN 'PAL0214' THEN 'The prisoner was taken back to prison.'
        WHEN 'PAL0215' THEN 'Please use the proper procedure.'
        WHEN 'PAL0216' THEN 'The theory has been proven by several studies.'
        WHEN 'PAL0217' THEN 'She wants to pursue a career in technology.'
        WHEN 'PAL0218' THEN 'Python is widely used for programming.'
        WHEN 'PAL0219' THEN 'I cannot recall his name.'
        WHEN 'PAL0220' THEN 'The student gave a recent example.'
        WHEN 'PAL0221' THEN 'He refused the offer.'
        WHEN 'PAL0222' THEN 'The country changed its political regime.'
        WHEN 'PAL0223' THEN 'She regrets missing the opportunity.'
        WHEN 'PAL0224' THEN 'The lesson relates to our previous topic.'
        WHEN 'PAL0225' THEN 'The medicine brought relief from the pain.'
        WHEN 'PAL0226' THEN 'Please remain seated.'
        WHEN 'PAL0227' THEN 'The students studied at a remote location.'
        WHEN 'PAL0228' THEN 'The firefighters rescued the family.'
        WHEN 'PAL0229' THEN 'He resents being treated unfairly.'
        WHEN 'PAL0230' THEN 'The company wants to retain its employees.'
        WHEN 'PAL0231' THEN 'My grandfather plans to retire next year.'
        WHEN 'PAL0232' THEN 'The investigation revealed new information.'
        WHEN 'PAL0233' THEN 'The song has a strong rhythm.'
        WHEN 'PAL0234' THEN 'The hikers walked across rugged terrain.'
        WHEN 'PAL0235' THEN 'The supplies were scanty after the storm.'
        WHEN 'PAL0236' THEN 'The child was scared of the dog.'
        WHEN 'PAL0237' THEN 'We drove along a scenic road.'
        WHEN 'PAL0238' THEN 'The company developed a new marketing scheme.'
        WHEN 'PAL0239' THEN 'The children walked to school.'
        WHEN 'PAL0240' THEN 'It took time to settle into the new routine.'
        WHEN 'PAL0241' THEN 'The patient suffered from severe pain.'
        WHEN 'PAL0242' THEN 'You should study for the exam.'
        WHEN 'PAL0243' THEN 'The sweater may shrink in hot water.'
        WHEN 'PAL0244' THEN 'The traffic signal turned red.'
        WHEN 'PAL0245' THEN 'The ring is made of silver.'
        WHEN 'PAL0246' THEN 'Let the soup simmer for ten minutes.'
        WHEN 'PAL0247' THEN 'The instructions are simple to follow.'
        WHEN 'PAL0248' THEN 'There is a slight difference between them.'
        WHEN 'PAL0249' THEN 'The surface feels smooth.'
        WHEN 'PAL0250' THEN 'The poem expresses deep sorrow.'
        WHEN 'PAL0251' THEN 'The museum has a collection of Soviet posters.'
        WHEN 'PAL0252' THEN 'Use a sponge to clean the table.'
        WHEN 'PAL0253' THEN 'The teacher spread the information among the students.'
        WHEN 'PAL0254' THEN 'Flowers begin to grow in spring.'
        WHEN 'PAL0255' THEN 'Draw a square around the correct answer.'
        WHEN 'PAL0256' THEN 'The table is stable and will not move.'
        WHEN 'PAL0257' THEN 'The student´s status changed after the exam.'
        WHEN 'PAL0258' THEN 'She made steady progress in English.'
        WHEN 'PAL0259' THEN 'The river forms a narrow stream.'
        WHEN 'PAL0260' THEN 'The school is on the main street.'
        WHEN 'PAL0261' THEN 'The teacher has strict rules.'
        WHEN 'PAL0262' THEN 'He tried to strike the ball.'
        WHEN 'PAL0263' THEN 'The car struck the wall and was badly damaged.'
        WHEN 'PAL0264' THEN 'Please submit your assignment before Friday.'
        WHEN 'PAL0265' THEN 'There was a sudden change in the weather.'
        WHEN 'PAL0266' THEN 'Many people suffer from stress.'
        WHEN 'PAL0267' THEN 'The store supplies food to local restaurants.'
        WHEN 'PAL0268' THEN 'She used a thread to repair the shirt.'
        WHEN 'PAL0269' THEN 'Plants thrive with enough sunlight and water.'
        WHEN 'PAL0270' THEN 'The doctor examined his throat.'
        WHEN 'PAL0271' THEN 'I bought a ticket for the concert.'
        WHEN 'PAL0272' THEN 'The children tiptoed into the room.'
        WHEN 'PAL0273' THEN 'Please use a tissue to clean your hands.'
        WHEN 'PAL0274' THEN 'The doctor asked me to stick out my tongue.'
        WHEN 'PAL0275' THEN 'The two countries signed a peace treaty.'
        WHEN 'PAL0276' THEN 'The musician is tuning the guitar.'
        WHEN 'PAL0277' THEN 'The train passed through the tunnel.'
        WHEN 'PAL0278' THEN 'He was unable to attend the competition.'
        WHEN 'PAL0279' THEN 'The students said the decision was unfair.'
        WHEN 'PAL0280' THEN 'The students worked together as a united team.'
        WHEN 'PAL0281' THEN 'This website is useful for learning English.'
        WHEN 'PAL0282' THEN 'She did her utmost to finish the project.'
        WHEN 'PAL0283' THEN 'The machine creates a vacuum inside the container.'
        WHEN 'PAL0284' THEN 'Honesty is an important virtue.'
        WHEN 'PAL0285' THEN 'The family went on a long voyage.'
        WHEN 'PAL0286' THEN 'We like to wander around the city.'
        WHEN 'PAL0287' THEN 'The country has great natural wealth.'
        WHEN 'PAL0288' THEN 'The teacher gives us a weekly assignment.'
        WHEN 'PAL0289' THEN 'The package has a weight of five kilograms.'
        WHEN 'PAL0290' THEN 'The website includes a useful weather widget.'
        WHEN 'PAL0291' THEN 'Please close the window before leaving.'
        WHEN 'PAL0292' THEN 'The days are shorter in winter.'
    END
WHERE codigo BETWEEN 'PAL0061' AND 'PAL0292';


UPDATE palabra SET definicion = 'A record of money kept by a bank for a person or organization.', ejemplo = 'I opened a new bank account last week.' WHERE codigo = 'PAL0293';
UPDATE palabra SET definicion = 'To successfully complete something or reach a goal.', ejemplo = 'She worked hard to achieve her goals.' WHERE codigo = 'PAL0294';
UPDATE palabra SET definicion = 'To get or obtain something, especially through effort.', ejemplo = 'He hopes to acquire new skills this year.' WHERE codigo = 'PAL0295';
UPDATE palabra SET definicion = 'A company that provides transportation by air.', ejemplo = 'The airline canceled our flight because of the storm.' WHERE codigo = 'PAL0296';
UPDATE palabra SET definicion = 'Very good, impressive, or surprising.', ejemplo = 'She gave an amazing performance.' WHERE codigo = 'PAL0297';
UPDATE palabra SET definicion = 'A person who studies information to understand a situation or problem.', ejemplo = 'The analyst examined the company data carefully.' WHERE codigo = 'PAL0298';
UPDATE palabra SET definicion = 'A strong feeling of pain, sadness, or confusion.', ejemplo = 'The loss caused him great anguish.' WHERE codigo = 'PAL0299';
UPDATE palabra SET definicion = 'One more person or thing of the same type.', ejemplo = 'Would you like another piece of cake?' WHERE codigo = 'PAL0300';
UPDATE palabra SET definicion = 'Worried or nervous about something that may happen.', ejemplo = 'She felt anxious before the exam.' WHERE codigo = 'PAL0301';
UPDATE palabra SET definicion = 'To accept or agree to something officially.', ejemplo = 'The manager approved the new plan.' WHERE codigo = 'PAL0302';
UPDATE palabra SET definicion = 'To organize or plan something.', ejemplo = 'We need to arrange a meeting for Friday.' WHERE codigo = 'PAL0303';
UPDATE palabra SET definicion = 'The act or process of arriving somewhere.', ejemplo = 'The arrival of the train was delayed.' WHERE codigo = 'PAL0304';
UPDATE palabra SET definicion = 'An effort to do or achieve something.', ejemplo = 'His first attempt was not successful.' WHERE codigo = 'PAL0305';
UPDATE palabra SET definicion = 'To attract someone or something toward you.', ejemplo = 'Bright colors attract many customers.' WHERE codigo = 'PAL0306';
UPDATE palabra SET definicion = 'A public sale in which things are sold to the person offering the most money.', ejemplo = 'She bought the painting at an auction.' WHERE codigo = 'PAL0307';
UPDATE palabra SET definicion = 'Not comfortable or easy to understand or deal with.', ejemplo = 'He felt awkward during the conversation.' WHERE codigo = 'PAL0308';
UPDATE palabra SET definicion = 'A situation in which different things are in the correct amounts or proportions.', ejemplo = 'She tries to maintain a healthy balance between work and study.' WHERE codigo = 'PAL0309';
UPDATE palabra SET definicion = 'Opinions or ideas that someone accepts as true.', ejemplo = 'His beliefs are very important to him.' WHERE codigo = 'PAL0310';
UPDATE palabra SET definicion = 'To accept that something is true or real.', ejemplo = 'I believe that she can solve the problem.' WHERE codigo = 'PAL0311';
UPDATE palabra SET definicion = 'Wider or more general than something else.', ejemplo = 'The new policy has a broader purpose.' WHERE codigo = 'PAL0312';
UPDATE palabra SET definicion = 'Past tense of bring; carried something to a place.', ejemplo = 'She brought some food for everyone.' WHERE codigo = 'PAL0313';
UPDATE palabra SET definicion = 'Having the ability or qualities needed to do something.', ejemplo = 'She is capable of solving difficult problems.' WHERE codigo = 'PAL0314';
UPDATE palabra SET definicion = 'Taking care to avoid danger, mistakes, or problems.', ejemplo = 'Be careful when you cross the street.' WHERE codigo = 'PAL0315';
UPDATE palabra SET definicion = 'Having no doubt or uncertainty about something.', ejemplo = 'I am certain that he knows the answer.' WHERE codigo = 'PAL0316';
UPDATE palabra SET definicion = 'An item of property, especially one that is not common or modern.', ejemplo = 'The museum displayed an old chattel from the nineteenth century.' WHERE codigo = 'PAL0317';
UPDATE palabra SET definicion = 'Continuing for a long time or difficult to change.', ejemplo = 'He suffers from chronic back pain.' WHERE codigo = 'PAL0318';
UPDATE palabra SET definicion = 'A person who belongs to a particular country or community.', ejemplo = 'Every citizen has certain rights and responsibilities.' WHERE codigo = 'PAL0319';
UPDATE palabra SET definicion = 'Belonging to a style or type that is considered standard or traditional.', ejemplo = 'She wore a classic black dress.' WHERE codigo = 'PAL0320';
UPDATE palabra SET definicion = 'A state of physical or emotional ease.', ejemplo = 'The hotel offers comfort and excellent service.' WHERE codigo = 'PAL0321';
UPDATE palabra SET definicion = 'A business organization that sells goods or services.', ejemplo = 'The company opened a new office downtown.' WHERE codigo = 'PAL0322';
UPDATE palabra SET definicion = 'To examine two or more things to see how they are similar or different.', ejemplo = 'We need to compare the two computers before buying one.' WHERE codigo = 'PAL0323';
UPDATE palabra SET definicion = 'To try to win or succeed against someone or something.', ejemplo = 'Several teams will compete in the tournament.' WHERE codigo = 'PAL0324';
UPDATE palabra SET definicion = 'Complicated and made of many connected parts.', ejemplo = 'The human brain is a complex organ.' WHERE codigo = 'PAL0325';
UPDATE palabra SET definicion = 'A feeling of worry about something.', ejemplo = 'There is growing concern about pollution.' WHERE codigo = 'PAL0326';
UPDATE palabra SET definicion = 'To state that something is true or correct.', ejemplo = 'Please confirm your appointment by email.' WHERE codigo = 'PAL0327';
UPDATE palabra SET definicion = 'To join or link people or things together.', ejemplo = 'The bridge connects the two towns.' WHERE codigo = 'PAL0328';
UPDATE palabra SET definicion = 'Permission or agreement to do something.', ejemplo = 'You need your parents consent before joining the trip.' WHERE codigo = 'PAL0329';
UPDATE palabra SET definicion = 'To have or include something as a part.', ejemplo = 'The course contains several practical activities.' WHERE codigo = 'PAL0330';
UPDATE palabra SET definicion = 'To manage or direct people or activities.', ejemplo = 'She controls the project schedule.' WHERE codigo = 'PAL0331';
UPDATE palabra SET definicion = 'Free from mistakes or errors.', ejemplo = 'Please make sure the information is correct.' WHERE codigo = 'PAL0332';
UPDATE palabra SET definicion = 'A nation or area with its own government.', ejemplo = 'France is a European country.' WHERE codigo = 'PAL0333';
UPDATE palabra SET definicion = 'The ability to face fear, pain, or difficulty.', ejemplo = 'It takes courage to speak in front of a large audience.' WHERE codigo = 'PAL0334';
UPDATE palabra SET definicion = 'Wanting to know or learn about something.', ejemplo = 'The curious student asked many questions.' WHERE codigo = 'PAL0335';
UPDATE palabra SET definicion = 'Happening or existing at the present time.', ejemplo = 'The current situation requires careful planning.' WHERE codigo = 'PAL0336';
UPDATE palabra SET definicion = 'A covering used to close or decorate a window or room.', ejemplo = 'She opened the curtain to let in the sunlight.' WHERE codigo = 'PAL0337';
UPDATE palabra SET definicion = 'A soft object used to support the head or body.', ejemplo = 'I put a cushion on the chair.' WHERE codigo = 'PAL0338';
UPDATE palabra SET definicion = 'Behavior or manners that are considered proper or acceptable.', ejemplo = 'Good decorum is expected during the ceremony.' WHERE codigo = 'PAL0339';
UPDATE palabra SET definicion = 'To be worthy of something or to have a right to receive it.', ejemplo = 'You deserve a reward for your hard work.' WHERE codigo = 'PAL0340';
UPDATE palabra SET definicion = 'A sweet food usually eaten at the end of a meal.', ejemplo = 'We ordered chocolate cake for dessert.' WHERE codigo = 'PAL0341';
UPDATE palabra SET definicion = 'To damage something so badly that it cannot be used.', ejemplo = 'The fire destroyed several buildings.' WHERE codigo = 'PAL0342';
UPDATE palabra SET definicion = 'To grow or change into a more advanced form.', ejemplo = 'Children develop new skills as they grow.' WHERE codigo = 'PAL0343';
UPDATE palabra SET definicion = 'To talk about something with another person or group.', ejemplo = 'We need to discuss the project tomorrow.' WHERE codigo = 'PAL0344';
UPDATE palabra SET definicion = 'An illness or medical condition.', ejemplo = 'The doctor treated the disease quickly.' WHERE codigo = 'PAL0345';
UPDATE palabra SET definicion = 'A strong feeling of dislike or opposition.', ejemplo = 'He expressed disgust at the dirty kitchen.' WHERE codigo = 'PAL0346';
UPDATE palabra SET definicion = 'To not enjoy or approve of someone or something.', ejemplo = 'I dislike waiting in long lines.' WHERE codigo = 'PAL0347';
UPDATE palabra SET definicion = 'Moving or operating a vehicle.', ejemplo = 'Driving requires attention and responsibility.' WHERE codigo = 'PAL0348';
UPDATE palabra SET definicion = 'Related to the east.', ejemplo = 'The eastern part of the country receives less rain.' WHERE codigo = 'PAL0349';
UPDATE palabra SET definicion = 'The system by which money, goods, and services are produced and used.', ejemplo = 'The economy is growing slowly this year.' WHERE codigo = 'PAL0350';
UPDATE palabra SET definicion = 'A building or office used by representatives of one country in another country.', ejemplo = 'The ambassador works at the embassy.' WHERE codigo = 'PAL0351';
UPDATE palabra SET definicion = 'To improve something or make it more attractive or effective.', ejemplo = 'The new technology will enhance the learning experience.' WHERE codigo = 'PAL0352';
UPDATE palabra SET definicion = 'To trap or capture someone or something.', ejemplo = 'The spider can ensnare insects in its web.' WHERE codigo = 'PAL0353';
UPDATE palabra SET definicion = 'Proteins that help chemical reactions happen in living organisms.', ejemplo = 'Enzymes help the body digest food.' WHERE codigo = 'PAL0354';
UPDATE palabra SET definicion = 'The part of the day between afternoon and night.', ejemplo = 'We usually exercise in the evening.' WHERE codigo = 'PAL0355';
UPDATE palabra SET definicion = 'To look at or study something carefully in order to understand it.', ejemplo = 'The teacher asked us to examine the results.' WHERE codigo = 'PAL0356';
UPDATE palabra SET definicion = 'Feeling very happy or enthusiastic about something.', ejemplo = 'The children were excited about the school trip.' WHERE codigo = 'PAL0357';
UPDATE palabra SET definicion = 'To show something publicly or make it visible.', ejemplo = 'The museum will exhibit several paintings.' WHERE codigo = 'PAL0358';
UPDATE palabra SET definicion = 'To make something clear or easy to understand.', ejemplo = 'Can you explain this grammar rule?' WHERE codigo = 'PAL0359';
UPDATE palabra SET definicion = 'To travel around or investigate a place or subject.', ejemplo = 'We want to explore the city this weekend.' WHERE codigo = 'PAL0360';
UPDATE palabra SET definicion = 'To communicate an idea or feeling clearly.', ejemplo = 'She expressed her opinion politely.' WHERE codigo = 'PAL0361';
UPDATE palabra SET definicion = 'A covering of soft hair, wool, or feathers on an animal.', ejemplo = 'The bird has a beautiful feather.' WHERE codigo = 'PAL0362';
UPDATE palabra SET definicion = 'A characteristic or important part of something.', ejemplo = 'One useful feature of the app is its simple design.' WHERE codigo = 'PAL0363';
UPDATE palabra SET definicion = 'An emotion or state of being aware of something.', ejemplo = 'She had a strange feeling that something was wrong.' WHERE codigo = 'PAL0364';
UPDATE palabra SET definicion = 'A person who is in the same situation or group as another person.', ejemplo = 'He is my fellow student.' WHERE codigo = 'PAL0365';
UPDATE palabra SET definicion = 'Writing or stories about imaginary events and characters.', ejemplo = 'She enjoys reading science fiction.' WHERE codigo = 'PAL0366';
UPDATE palabra SET definicion = 'Related to a country or culture outside your own.', ejemplo = 'The university offers several foreign language courses.' WHERE codigo = 'PAL0367';
UPDATE palabra SET definicion = 'To stop being angry with someone for something they did wrong.', ejemplo = 'I hope you can forgive me for my mistake.' WHERE codigo = 'PAL0368';
UPDATE palabra SET definicion = 'Toward the future or in the direction ahead.', ejemplo = 'We need to move forward with the project.' WHERE codigo = 'PAL0369';
UPDATE palabra SET definicion = 'A person who is free and has no master or employer, often used as a name or historical term.', ejemplo = 'The story describes Freeman as an independent man.' WHERE codigo = 'PAL0370';
UPDATE palabra SET definicion = 'Easily broken, damaged, or affected.', ejemplo = 'The old material was friable and broke easily.' WHERE codigo = 'PAL0371';
UPDATE palabra SET definicion = 'Real, sincere, and honest.', ejemplo = 'She gave a genuine apology.' WHERE codigo = 'PAL0372';
UPDATE palabra SET definicion = 'A peaceful relationship or agreement between people or groups.', ejemplo = 'The family lived together in harmony.' WHERE codigo = 'PAL0373';
UPDATE palabra SET definicion = 'In good physical or mental condition.', ejemplo = 'Regular exercise helps you stay healthy.' WHERE codigo = 'PAL0374';
UPDATE palabra SET definicion = 'The ability to hear or the act of listening to sounds.', ejemplo = 'His hearing improved after the treatment.' WHERE codigo = 'PAL0375';
UPDATE palabra SET definicion = 'Willing to help or useful to someone.', ejemplo = 'The helpful teacher explained the exercise again.' WHERE codigo = 'PAL0376';
UPDATE palabra SET definicion = 'A main road connecting cities or important places.', ejemplo = 'The highway was crowded during the holiday.' WHERE codigo = 'PAL0377';
UPDATE palabra SET definicion = 'All the events and experiences that happened in the past.', ejemplo = 'She loves studying history at school.' WHERE codigo = 'PAL0378';
UPDATE palabra SET definicion = 'A period when people do not work or attend school, often for travel or rest.', ejemplo = 'We are planning a holiday in July.' WHERE codigo = 'PAL0379';
UPDATE palabra SET definicion = 'Not allowed by law.', ejemplo = 'It is illegal to park here.' WHERE codigo = 'PAL0380';
UPDATE palabra SET definicion = 'An illness or period of poor health.', ejemplo = 'She missed school because of an illness.' WHERE codigo = 'PAL0381';
UPDATE palabra SET definicion = 'To cause someone to admire or respect you.', ejemplo = 'Her speech impressed the audience.' WHERE codigo = 'PAL0382';
UPDATE palabra SET definicion = 'To become better or make something better.', ejemplo = 'Practice can improve your pronunciation.' WHERE codigo = 'PAL0383';
UPDATE palabra SET definicion = 'A sudden strong desire or reaction that may be difficult to control.', ejemplo = 'He had an impulse to buy the expensive phone.' WHERE codigo = 'PAL0384';
UPDATE palabra SET definicion = 'To contain something as part of a whole.', ejemplo = 'The course includes practical exercises.' WHERE codigo = 'PAL0385';
UPDATE palabra SET definicion = 'Happening or existing at the beginning of something.', ejemplo = 'The initial plan was changed later.' WHERE codigo = 'PAL0386';
UPDATE palabra SET definicion = 'To put a system, program, or equipment into use.', ejemplo = 'We need to install the software first.' WHERE codigo = 'PAL0387';
UPDATE palabra SET definicion = 'To include or involve someone or something.', ejemplo = 'The project involves several students.' WHERE codigo = 'PAL0388';
UPDATE palabra SET definicion = 'Together or in cooperation with others.', ejemplo = 'The students worked jointly on the presentation.' WHERE codigo = 'PAL0389';
UPDATE palabra SET definicion = 'A trip or movement from one place to another.', ejemplo = 'Our journey took five hours.' WHERE codigo = 'PAL0390';
UPDATE palabra SET definicion = 'To show or prove that something is reasonable or right.', ejemplo = 'Can you justify your answer?' WHERE codigo = 'PAL0391';
UPDATE palabra SET definicion = 'A country or area ruled by a king or queen.', ejemplo = 'The museum tells the history of the ancient kingdom.' WHERE codigo = 'PAL0392';
UPDATE palabra SET definicion = 'A room where food is prepared and cooked.', ejemplo = 'My mother is making dinner in the kitchen.' WHERE codigo = 'PAL0393';
UPDATE palabra SET definicion = 'Going first or being more advanced than others.', ejemplo = 'She is a leading expert in the field.' WHERE codigo = 'PAL0394';
UPDATE palabra SET definicion = 'Animal skin prepared and used as material.', ejemplo = 'The jacket is made of leather.' WHERE codigo = 'PAL0395';
UPDATE palabra SET definicion = 'Free time used for relaxation or enjoyment.', ejemplo = 'She enjoys reading during her leisure time.' WHERE codigo = 'PAL0396';
UPDATE palabra SET definicion = 'A person who is responsible for controlling or organizing a business or activity.', ejemplo = 'The manager organized the meeting.' WHERE codigo = 'PAL0397';
UPDATE palabra SET definicion = 'Very large, heavy, or important.', ejemplo = 'The company made a massive investment.' WHERE codigo = 'PAL0398';
UPDATE palabra SET definicion = 'The greatest possible amount, size, or degree.', ejemplo = 'The machine can reach a maximum speed of 100 kilometers per hour.' WHERE codigo = 'PAL0399';
UPDATE palabra SET definicion = 'To find out the size, amount, or degree of something.', ejemplo = 'The scientist will measure the temperature.' WHERE codigo = 'PAL0400';
UPDATE palabra SET definicion = 'A plant that lives mainly in the sea and resembles a simple plant.', ejemplo = 'Seaweed grows near the rocky coast.' WHERE codigo = 'PAL0401';
UPDATE palabra SET definicion = 'To talk about or refer to something.', ejemplo = 'She mentioned your name during the meeting.' WHERE codigo = 'PAL0402';
UPDATE palabra SET definicion = 'A woman who helps other women give birth.', ejemplo = 'The midwife helped the mother during childbirth.' WHERE codigo = 'PAL0403';
UPDATE palabra SET definicion = 'The smallest amount or number.', ejemplo = 'The minimum age for the activity is eighteen.' WHERE codigo = 'PAL0404';
UPDATE palabra SET definicion = 'An organized group of people with a particular purpose.', ejemplo = 'The mission helps people in remote communities.' WHERE codigo = 'PAL0405';
UPDATE palabra SET definicion = 'Happening once every month.', ejemplo = 'The club publishes a monthly newsletter.' WHERE codigo = 'PAL0406';
UPDATE palabra SET definicion = 'To pay little or no attention to something.', ejemplo = 'Do not neglect your homework.' WHERE codigo = 'PAL0407';
UPDATE palabra SET definicion = 'Not one and not the other of two possibilities.', ejemplo = 'Neither answer is correct.' WHERE codigo = 'PAL0408';
UPDATE palabra SET definicion = 'Worried or afraid about something.', ejemplo = 'He felt nervous before speaking in public.' WHERE codigo = 'PAL0409';
UPDATE palabra SET definicion = 'A group of connected people, computers, or organizations.', ejemplo = 'The school has a computer network.' WHERE codigo = 'PAL0410';
UPDATE palabra SET definicion = 'Not in any place or no place.', ejemplo = 'There was nowhere to sit.' WHERE codigo = 'PAL0411';
UPDATE palabra SET definicion = 'To watch, notice, or study something carefully.', ejemplo = 'Scientists observe the animals in their natural environment.' WHERE codigo = 'PAL0412';
UPDATE palabra SET definicion = 'Easy to see, understand, or recognize.', ejemplo = 'The difference between the two colors is obvious.' WHERE codigo = 'PAL0413';
UPDATE palabra SET definicion = 'To work, function, or manage an activity.', ejemplo = 'The machine operates automatically.' WHERE codigo = 'PAL0414';
UPDATE palabra SET definicion = 'Situated outside or beyond a particular place.', ejemplo = 'The students waited outside the classroom.' WHERE codigo = 'PAL0415';
UPDATE palabra SET definicion = 'Including everything or considering the whole situation.', ejemplo = 'Overall, the project was successful.' WHERE codigo = 'PAL0416';
UPDATE palabra SET definicion = 'The act of leaving a vehicle in a particular place.', ejemplo = 'Parking is difficult near the university.' WHERE codigo = 'PAL0417';
UPDATE palabra SET definicion = 'A way through or along something; also a section of a journey.', ejemplo = 'The passage through the mountains was dangerous.' WHERE codigo = 'PAL0418';
UPDATE palabra SET definicion = 'Able to wait calmly or accept delays without becoming angry.', ejemplo = 'You need to be patient when learning a new language.' WHERE codigo = 'PAL0419';
UPDATE palabra SET definicion = 'A lack or small amount of something.', ejemplo = 'There is a paucity of information about the topic.' WHERE codigo = 'PAL0420';
UPDATE palabra SET definicion = 'Money given in exchange for a product or service.', ejemplo = 'The payment must be made before delivery.' WHERE codigo = 'PAL0421';
UPDATE palabra SET definicion = 'As good as possible or without mistakes.', ejemplo = 'She gave a perfect answer.' WHERE codigo = 'PAL0422';
UPDATE palabra SET definicion = 'To do something or carry out a task.', ejemplo = 'The students must perform the experiment carefully.' WHERE codigo = 'PAL0423';
UPDATE palabra SET definicion = 'The smallest unit of sound in a language that can change meaning.', ejemplo = 'The teacher explained how each phoneme is pronounced.' WHERE codigo = 'PAL0424';
UPDATE palabra SET definicion = 'To have or own something.', ejemplo = 'The museum possesses several valuable paintings.' WHERE codigo = 'PAL0425';
UPDATE palabra SET definicion = 'Having a soft texture and a surface covered with fine powder.', ejemplo = 'The powdery snow covered the ground.' WHERE codigo = 'PAL0426';
UPDATE palabra SET definicion = 'To get ready for something.', ejemplo = 'We need to prepare for the English exam.' WHERE codigo = 'PAL0427';
UPDATE palabra SET definicion = 'To pretend that something is true when it is not.', ejemplo = 'The children pretended to be astronauts.' WHERE codigo = 'PAL0428';
UPDATE palabra SET definicion = 'To stop something from happening.', ejemplo = 'Wearing a helmet can prevent serious injuries.' WHERE codigo = 'PAL0429';
UPDATE palabra SET definicion = 'To continue with an action or process.', ejemplo = 'Please proceed to the next exercise.' WHERE codigo = 'PAL0430';
UPDATE palabra SET definicion = 'A series of actions or changes that happen over time.', ejemplo = 'Learning a language is a gradual process.' WHERE codigo = 'PAL0431';
UPDATE palabra SET definicion = 'To make or create something.', ejemplo = 'The factory produces electronic equipment.' WHERE codigo = 'PAL0432';
UPDATE palabra SET definicion = 'To say that you will do or give something.', ejemplo = 'He promised to help me with my homework.' WHERE codigo = 'PAL0433';
UPDATE palabra SET definicion = 'To suggest or present an idea for consideration.', ejemplo = 'She proposed a new solution to the problem.' WHERE codigo = 'PAL0434';
UPDATE palabra SET definicion = 'The reason or intention for doing something.', ejemplo = 'The purpose of this activity is to practice spelling.' WHERE codigo = 'PAL0435';
UPDATE palabra SET definicion = 'To meet the necessary conditions or requirements.', ejemplo = 'Students must qualify for the competition.' WHERE codigo = 'PAL0436';
UPDATE palabra SET definicion = 'How good or useful something is.', ejemplo = 'The teacher checked the quality of the students work.' WHERE codigo = 'PAL0437';
UPDATE palabra SET definicion = 'One of four equal parts of something.', ejemplo = 'She ate a quarter of the cake.' WHERE codigo = 'PAL0438';
UPDATE palabra SET definicion = 'A system of tracks and trains used for transportation.', ejemplo = 'The railway connects several cities.' WHERE codigo = 'PAL0439';
UPDATE palabra SET definicion = 'The activity of looking at or understanding written words.', ejemplo = 'Reading every day can improve your vocabulary.' WHERE codigo = 'PAL0440';
UPDATE palabra SET definicion = 'To understand or become aware of something.', ejemplo = 'She realized that she had forgotten her notebook.' WHERE codigo = 'PAL0441';
UPDATE palabra SET definicion = 'A written or electronic document showing that something was received or purchased.', ejemplo = 'Keep the receipt in case you need to return the product.' WHERE codigo = 'PAL0442';
UPDATE palabra SET definicion = 'To get something that you have been given or sent.', ejemplo = 'Did you receive my email?' WHERE codigo = 'PAL0443';
UPDATE palabra SET definicion = 'To think carefully about something again.', ejemplo = 'He reflected on his mistakes after the exam.' WHERE codigo = 'PAL0444';
UPDATE palabra SET definicion = 'To make someone feel less worried or to reduce pain or difficulty.', ejemplo = 'The medicine helped relieve her pain.' WHERE codigo = 'PAL0445';
UPDATE palabra SET definicion = 'To put something in place of another thing.', ejemplo = 'We need to replace the broken keyboard.' WHERE codigo = 'PAL0446';
UPDATE palabra SET definicion = 'To ask for something politely or officially.', ejemplo = 'You can request a copy of the document.' WHERE codigo = 'PAL0447';
UPDATE palabra SET definicion = 'To need something because of a rule or situation.', ejemplo = 'The course requires regular practice.' WHERE codigo = 'PAL0448';
UPDATE palabra SET definicion = 'A feeling of anger or a desire to hurt someone because of something they did.', ejemplo = 'He wanted revenge after the argument.' WHERE codigo = 'PAL0449';
UPDATE palabra SET definicion = 'A usual way of doing things or a regular pattern.', ejemplo = 'My morning routine includes reading the news.' WHERE codigo = 'PAL0450';
UPDATE palabra SET definicion = 'To do what is necessary to make someone happy or satisfied.', ejemplo = 'The service aims to satisfy every customer.' WHERE codigo = 'PAL0451';
UPDATE palabra SET definicion = 'Money that has been saved rather than spent.', ejemplo = 'Her savings helped pay for the trip.' WHERE codigo = 'PAL0452';
UPDATE palabra SET definicion = 'The study of the natural world through observation and experiments.', ejemplo = 'Science helps us understand how the world works.' WHERE codigo = 'PAL0453';
UPDATE palabra SET definicion = 'Having or showing a serious attitude or importance.', ejemplo = 'This is a serious problem that needs attention.' WHERE codigo = 'PAL0454';
UPDATE palabra SET definicion = 'A person who works for or serves another person or organization.', ejemplo = 'The servant prepared the room for the guests.' WHERE codigo = 'PAL0455';
UPDATE palabra SET definicion = 'A community of people living together or sharing a culture.', ejemplo = 'Society changes as technology develops.' WHERE codigo = 'PAL0456';
UPDATE palabra SET definicion = 'In some way or by some means that is not specified.', ejemplo = 'Somehow, we managed to finish the project on time.' WHERE codigo = 'PAL0457';
UPDATE palabra SET definicion = 'To state or describe something clearly and specifically.', ejemplo = 'Please specify which option you want.' WHERE codigo = 'PAL0458';
UPDATE palabra SET definicion = 'A place or building where trains stop for passengers.', ejemplo = 'We arrived at the station early.' WHERE codigo = 'PAL0459';
UPDATE palabra SET definicion = 'The internal organ that helps digest food.', ejemplo = 'Eating too quickly can upset your stomach.' WHERE codigo = 'PAL0460';
UPDATE palabra SET definicion = 'Unusual or surprising in a way that is difficult to understand.', ejemplo = 'It was strange to see the store completely empty.' WHERE codigo = 'PAL0461';
UPDATE palabra SET definicion = 'To make something longer or larger.', ejemplo = 'You should stretch your legs after sitting for a long time.' WHERE codigo = 'PAL0462';
UPDATE palabra SET definicion = 'A topic or area of study or discussion.', ejemplo = 'English is my favorite school subject.' WHERE codigo = 'PAL0463';
UPDATE palabra SET definicion = 'To successfully do or achieve something.', ejemplo = 'She succeeded in passing the difficult exam.' WHERE codigo = 'PAL0464';
UPDATE palabra SET definicion = 'To give someone an idea or recommend something.', ejemplo = 'I suggest studying for thirty minutes every day.' WHERE codigo = 'PAL0465';
UPDATE palabra SET definicion = 'To help or encourage someone or something.', ejemplo = 'My friends support me when I have problems.' WHERE codigo = 'PAL0466';
UPDATE palabra SET definicion = 'To accept something as true or possible without proof.', ejemplo = 'I suppose we can meet after class.' WHERE codigo = 'PAL0467';
UPDATE palabra SET definicion = 'To continue to live or exist despite difficulties.', ejemplo = 'Many plants cannot survive without water.' WHERE codigo = 'PAL0468';
UPDATE palabra SET definicion = 'An idea or opinion about something.', ejemplo = 'The teacher asked for our thoughts about the story.' WHERE codigo = 'PAL0469';
UPDATE palabra SET definicion = 'A loud sound caused by electricity during a storm.', ejemplo = 'We heard thunder after the lightning.' WHERE codigo = 'PAL0470';
UPDATE palabra SET definicion = 'A great achievement or victory.', ejemplo = 'Winning the competition was a great triumph.' WHERE codigo = 'PAL0471';
UPDATE palabra SET definicion = 'A difficult situation or problem.', ejemplo = 'Learning a new language can be a challenge, but it is worth it.' WHERE codigo = 'PAL0472';
UPDATE palabra SET definicion = 'Typical of a particular group, time, or situation.', ejemplo = 'This weather is typical for the region in winter.' WHERE codigo = 'PAL0473';
UPDATE palabra SET definicion = 'Different from what is usual or expected.', ejemplo = 'It is unusual to see snow in this city.' WHERE codigo = 'PAL0474';
UPDATE palabra SET definicion = 'Different or several kinds of things or people.', ejemplo = 'The library has various books about science.' WHERE codigo = 'PAL0475';
UPDATE palabra SET definicion = 'An attempt to do something or a business activity involving risk.', ejemplo = 'Starting a new business can be a difficult venture.' WHERE codigo = 'PAL0476';
UPDATE palabra SET definicion = 'Using physical force to hurt or damage someone or something.', ejemplo = 'The movie contains a violent scene.' WHERE codigo = 'PAL0477';
UPDATE palabra SET definicion = 'Easy to see or notice.', ejemplo = 'The mountain was visible from the road.' WHERE codigo = 'PAL0478';
UPDATE palabra SET definicion = 'The condition of the atmosphere at a particular time and place.', ejemplo = 'The weather is sunny today.' WHERE codigo = 'PAL0479';
UPDATE palabra SET definicion = 'Related to the west.', ejemplo = 'The western part of the country is very dry.' WHERE codigo = 'PAL0480';
UPDATE palabra SET definicion = 'To make a high sound by blowing air through your lips or a small instrument.', ejemplo = 'He can whistle a popular song.' WHERE codigo = 'PAL0481';
UPDATE palabra SET definicion = 'Ready or happy to do something.', ejemplo = 'She is willing to help her classmates.' WHERE codigo = 'PAL0482';
UPDATE palabra SET definicion = 'The activity of producing letters or words on a surface or screen.', ejemplo = 'Writing in English every day improves your skills.' WHERE codigo = 'PAL0483';

UPDATE palabra SET pronunciacion = '/bríi-ding/' WHERE codigo = 'PAL0500';
UPDATE palabra SET pronunciacion = '/ma-tí-ri-al/' WHERE codigo = 'PAL0568';
UPDATE palabra SET pronunciacion = '/dshe-léi-shen/' WHERE codigo = 'PAL0540';
UPDATE palabra SET pronunciacion = '/o-fí-shal/' WHERE codigo = 'PAL0579';
UPDATE palabra SET pronunciacion = '/plé-sant/' WHERE codigo = 'PAL0593';

UPDATE palabra SET definicion = 'The quality of being exactly correct.', ejemplo = 'The accuracy of the report was checked twice.' WHERE codigo = 'PAL0484';
UPDATE palabra SET definicion = 'Correct and free of mistakes.', ejemplo = 'Her answer was accurate and complete.' WHERE codigo = 'PAL0485';
UPDATE palabra SET definicion = 'The process of mixing air into soil, water or another substance.', ejemplo = 'Aeration helps the grass roots get more oxygen.' WHERE codigo = 'PAL0486';
UPDATE palabra SET definicion = 'A formal agreement between groups or countries to work together.', ejemplo = 'The two countries formed an alliance to protect their trade.' WHERE codigo = 'PAL0487';
UPDATE palabra SET definicion = 'Having complete power; all-powerful.', ejemplo = 'Many people pray to an almighty God.' WHERE codigo = 'PAL0488';
UPDATE palabra SET definicion = 'To tell people something publicly.', ejemplo = 'The teacher will announce the winners tomorrow.' WHERE codigo = 'PAL0489';
UPDATE palabra SET definicion = 'Rubbed with oil as part of a religious ceremony.', ejemplo = 'The new king was anointed with holy oil.' WHERE codigo = 'PAL0490';
UPDATE palabra SET definicion = 'A main character in a story who does not have the usual heroic qualities.', ejemplo = 'The antihero in the film is selfish but still likable.' WHERE codigo = 'PAL0491';
UPDATE palabra SET definicion = 'A section of extra information at the end of a book; also a small organ in the body.', ejemplo = 'The full list of sources is in the appendix.' WHERE codigo = 'PAL0492';
UPDATE palabra SET definicion = 'To come near; or a way of dealing with a problem.', ejemplo = 'Please approach the desk when your name is called.' WHERE codigo = 'PAL0493';
UPDATE palabra SET definicion = 'Official permission or a good opinion of something.', ejemplo = 'You need approval from your teacher before you start.' WHERE codigo = 'PAL0494';
UPDATE palabra SET definicion = 'A disagreement, or a set of reasons used to support an idea.', ejemplo = 'They had an argument about who would drive.' WHERE codigo = 'PAL0495';
UPDATE palabra SET definicion = 'To surprise someone very much.', ejemplo = 'The magic trick will astonish the children.' WHERE codigo = 'PAL0496';
UPDATE palabra SET definicion = 'A male singing voice lower than a tenor and higher than a bass.', ejemplo = 'The baritone sang a deep and powerful solo.' WHERE codigo = 'PAL0497';
UPDATE palabra SET definicion = 'The way a person or an animal acts.', ejemplo = 'The teacher praised the students for their good behavior.' WHERE codigo = 'PAL0498';
UPDATE palabra SET definicion = 'A line that marks the limit of an area.', ejemplo = 'A tall fence marks the boundary of the farm.' WHERE codigo = 'PAL0499';
UPDATE palabra SET definicion = 'The raising of animals or plants to produce young ones.', ejemplo = 'The breeding of horses is her family business.' WHERE codigo = 'PAL0500';
UPDATE palabra SET definicion = 'A structure with walls and a roof.', ejemplo = 'The building has ten floors.' WHERE codigo = 'PAL0501';
UPDATE palabra SET definicion = 'An organization that sells goods or services.', ejemplo = 'She started a small business selling handmade candles.' WHERE codigo = 'PAL0502';
UPDATE palabra SET definicion = 'A planned series of actions to reach a goal, such as winning an election.', ejemplo = 'The campaign to save the park lasted six months.' WHERE codigo = 'PAL0503';
UPDATE palabra SET definicion = 'A vehicle with wheels, usually pulled by horses.', ejemplo = 'The princess arrived in a golden carriage.' WHERE codigo = 'PAL0504';
UPDATE palabra SET definicion = 'Careful to avoid danger or mistakes.', ejemplo = 'Be cautious when you cross the street.' WHERE codigo = 'PAL0505';
UPDATE palabra SET definicion = 'A substance made by or used in chemistry.', ejemplo = 'The factory keeps every chemical in a locked room.' WHERE codigo = 'PAL0506';
UPDATE palabra SET definicion = 'Rude and unfriendly.', ejemplo = 'His churlish reply upset everyone at the table.' WHERE codigo = 'PAL0507';
UPDATE palabra SET definicion = 'To say that you are unhappy about something.', ejemplo = 'Customers often complain when the service is slow.' WHERE codigo = 'PAL0508';
UPDATE palabra SET definicion = 'The amount of attention the media gives to an event; also protection provided by insurance.', ejemplo = 'The news gave full coverage of the final game.' WHERE codigo = 'PAL0509';
UPDATE palabra SET definicion = 'Able to produce new and original ideas or things.', ejemplo = 'She is very creative and paints beautiful pictures.' WHERE codigo = 'PAL0510';
UPDATE palabra SET definicion = 'Related to the customs, arts and beliefs of a group of people.', ejemplo = 'The city hosts a cultural festival every summer.' WHERE codigo = 'PAL0511';
UPDATE palabra SET definicion = 'A female child in relation to her parents.', ejemplo = 'Their daughter starts school next week.' WHERE codigo = 'PAL0512';
UPDATE palabra SET definicion = 'A choice made after thinking about it.', ejemplo = 'It was a hard decision, but she chose to move.' WHERE codigo = 'PAL0513';
UPDATE palabra SET definicion = 'The act of removing or erasing something.', ejemplo = 'The deletion of the file was an accident.' WHERE codigo = 'PAL0514';
UPDATE palabra SET definicion = 'A person who plans how something will look or work.', ejemplo = 'The designer created a new logo for the school.' WHERE codigo = 'PAL0515';
UPDATE palabra SET definicion = 'To have a different opinion from someone else.', ejemplo = 'I disagree with you, but I respect your idea.' WHERE codigo = 'PAL0516';
UPDATE palabra SET definicion = 'To make secret information known.', ejemplo = 'The company refused to disclose the price.' WHERE codigo = 'PAL0517';
UPDATE palabra SET definicion = 'Clearly different or easy to notice.', ejemplo = 'Each bird has a distinct song.' WHERE codigo = 'PAL0518';
UPDATE palabra SET definicion = 'Causing a feeling of spinning or confusion; extremely high or fast.', ejemplo = 'The view from the top of the tower was dizzying.' WHERE codigo = 'PAL0519';
UPDATE palabra SET definicion = 'Not sure, or not likely to be true.', ejemplo = 'I am doubtful that it will stop raining today.' WHERE codigo = 'PAL0520';
UPDATE palabra SET definicion = 'The central business area of a city.', ejemplo = 'We had lunch at a small restaurant downtown.' WHERE codigo = 'PAL0521';
UPDATE palabra SET definicion = 'Sudden and exciting, or full of strong emotion.', ejemplo = 'There was a dramatic change in the weather.' WHERE codigo = 'PAL0522';
UPDATE palabra SET definicion = 'The forces or patterns that cause change in a group or system.', ejemplo = 'The dynamics of the team improved after the meeting.' WHERE codigo = 'PAL0523';
UPDATE palabra SET definicion = 'Having the right to do or receive something.', ejemplo = 'Students with good grades are eligible for a scholarship.' WHERE codigo = 'PAL0524';
UPDATE palabra SET definicion = 'Special importance or attention given to something.', ejemplo = 'The teacher put emphasis on clear pronunciation.' WHERE codigo = 'PAL0525';
UPDATE palabra SET definicion = 'Extremely large.', ejemplo = 'An enormous elephant walked slowly across the road.' WHERE codigo = 'PAL0526';
UPDATE palabra SET definicion = 'People who are moved from a dangerous place to a safe one.', ejemplo = 'The evacuees stayed in a school until the flood ended.' WHERE codigo = 'PAL0527';
UPDATE palabra SET definicion = 'To give something and receive something else in return.', ejemplo = 'Students can exchange books at the library.' WHERE codigo = 'PAL0528';
UPDATE palabra SET definicion = 'Causing strong feelings of interest or happiness.', ejemplo = 'The final round of the contest was very exciting.' WHERE codigo = 'PAL0529';
UPDATE palabra SET definicion = 'On the outside, or coming from the outside.', ejemplo = 'Save your files on an external hard drive.' WHERE codigo = 'PAL0530';
UPDATE palabra SET definicion = 'Well known because you have seen or heard it before.', ejemplo = 'Her face looked familiar to me.' WHERE codigo = 'PAL0531';
UPDATE palabra SET definicion = 'Shown as an important or main part of something.', ejemplo = 'The featured speaker at the event was a famous writer.' WHERE codigo = 'PAL0532';
UPDATE palabra SET definicion = 'A security system that protects a computer network.', ejemplo = 'The firewall blocked the suspicious message.' WHERE codigo = 'PAL0533';
UPDATE palabra SET definicion = 'A low hill at the base of a mountain.', ejemplo = 'They built a small cabin on a quiet foothill.' WHERE codigo = 'PAL0534';
UPDATE palabra SET definicion = 'Most important or best known.', ejemplo = 'She is the foremost expert on ancient languages.' WHERE codigo = 'PAL0535';
UPDATE palabra SET definicion = 'At an earlier time.', ejemplo = 'The restaurant was formerly a bank.' WHERE codigo = 'PAL0536';
UPDATE palabra SET definicion = 'Very tired and nervous.', ejemplo = 'The long day left the teacher feeling frazzled.' WHERE codigo = 'PAL0537';
UPDATE palabra SET definicion = 'Happening often.', ejemplo = 'He makes frequent trips to the library.' WHERE codigo = 'PAL0538';
UPDATE palabra SET definicion = 'Kind and pleasant toward other people.', ejemplo = 'Our neighbors are very friendly.' WHERE codigo = 'PAL0539';
UPDATE palabra SET definicion = 'The process of turning into a gel or a jelly-like substance.', ejemplo = 'Gelation happens when the mixture cools down.' WHERE codigo = 'PAL0540';
UPDATE palabra SET definicion = 'To produce or create something.', ejemplo = 'Wind turbines generate clean energy.' WHERE codigo = 'PAL0541';
UPDATE palabra SET definicion = 'The study of the complete set of genes of living things.', ejemplo = 'Genomics helps scientists understand inherited diseases.' WHERE codigo = 'PAL0542';
UPDATE palabra SET definicion = 'A polite and well-mannered man.', ejemplo = 'The gentleman held the door for everyone.' WHERE codigo = 'PAL0543';
UPDATE palabra SET definicion = 'An official who leads a state or region.', ejemplo = 'The governor gave a speech about education.' WHERE codigo = 'PAL0544';
UPDATE palabra SET definicion = 'Help and advice about how to do something.', ejemplo = 'The counselor gave me guidance about choosing a career.' WHERE codigo = 'PAL0545';
UPDATE palabra SET definicion = 'A thorny shrub or small tree with white flowers and red berries.', ejemplo = 'A hawthorn grows next to the old stone wall.' WHERE codigo = 'PAL0546';
UPDATE palabra SET definicion = 'The study of coats of arms and family symbols.', ejemplo = 'Heraldry uses shields, lions and other symbols.' WHERE codigo = 'PAL0547';
UPDATE palabra SET definicion = 'To pause because you are not sure what to do.', ejemplo = 'Do not hesitate to ask questions.' WHERE codigo = 'PAL0548';
UPDATE palabra SET definicion = 'Having no place to live.', ejemplo = 'The shelter gives food to homeless people.' WHERE codigo = 'PAL0549';
UPDATE palabra SET definicion = 'The process of forming new ideas.', ejemplo = 'Ideation is the first step of the design process.' WHERE codigo = 'PAL0550';
UPDATE palabra SET definicion = 'To recognize something and say what or who it is.', ejemplo = 'Can you identify this bird?' WHERE codigo = 'PAL0551';
UPDATE palabra SET definicion = 'Related to an empire or its ruler.', ejemplo = 'The imperial palace was full of tourists.' WHERE codigo = 'PAL0552';
UPDATE palabra SET definicion = 'To become greater in size, number or amount.', ejemplo = 'Prices tend to increase every year.' WHERE codigo = 'PAL0553';
UPDATE palabra SET definicion = 'Owing thanks or money to someone.', ejemplo = 'I am indebted to my teacher for her help.' WHERE codigo = 'PAL0554';
UPDATE palabra SET definicion = 'To show or point out something.', ejemplo = 'The arrow will indicate the way to the exit.' WHERE codigo = 'PAL0555';
UPDATE palabra SET definicion = 'The making of products in factories, or a branch of business.', ejemplo = 'The car industry employs thousands of workers.' WHERE codigo = 'PAL0556';
UPDATE palabra SET definicion = 'Existing as a natural and permanent part of something.', ejemplo = 'Risk is inherent in every extreme sport.' WHERE codigo = 'PAL0557';
UPDATE palabra SET definicion = 'To start or begin something.', ejemplo = 'The mayor will initiate a new recycling program.' WHERE codigo = 'PAL0558';
UPDATE palabra SET definicion = 'Taking part in something or connected with it.', ejemplo = 'She is involved in many school activities.' WHERE codigo = 'PAL0559';
UPDATE palabra SET definicion = 'To treat or combine with iodine.', ejemplo = 'Some companies iodinate table salt to prevent health problems.' WHERE codigo = 'PAL0560';
UPDATE palabra SET definicion = 'The ability to make wise decisions, or an opinion formed after careful thought.', ejemplo = 'Good judgement helps you make wise choices.' WHERE codigo = 'PAL0561';
UPDATE palabra SET definicion = 'Related to courts of law and judges.', ejemplo = 'The judicial system makes sure the law is followed.' WHERE codigo = 'PAL0562';
UPDATE palabra SET definicion = 'A system of words used by people to communicate.', ejemplo = 'English is the language we speak in class.' WHERE codigo = 'PAL0563';
UPDATE palabra SET definicion = 'A diplomatic office ranking below an embassy.', ejemplo = 'The legation helped citizens who were traveling abroad.' WHERE codigo = 'PAL0564';
UPDATE palabra SET definicion = 'Related to books and writing.', ejemplo = 'She won a literary prize for her first novel.' WHERE codigo = 'PAL0565';
UPDATE palabra SET definicion = 'To keep something in good condition.', ejemplo = 'You must maintain your bike to keep it safe.' WHERE codigo = 'PAL0566';
UPDATE palabra SET definicion = 'The legal union of two people as partners.', ejemplo = 'Their marriage lasted fifty years.' WHERE codigo = 'PAL0567';
UPDATE palabra SET definicion = 'The fabric or matter that something is made of.', ejemplo = 'The dress is made of soft material.' WHERE codigo = 'PAL0568';
UPDATE palabra SET definicion = 'To make something as large or as good as possible.', ejemplo = 'Study every day to maximize your score.' WHERE codigo = 'PAL0569';
UPDATE palabra SET definicion = 'Found the size or amount of something; also careful and controlled.', ejemplo = 'The builder measured the room twice.' WHERE codigo = 'PAL0570';
UPDATE palabra SET definicion = 'A traveling singer and musician in medieval times.', ejemplo = 'The minstrel sang stories in the castle.' WHERE codigo = 'PAL0571';
UPDATE palabra SET definicion = 'A loan used to buy a house or property.', ejemplo = 'They pay their mortgage every month.' WHERE codigo = 'PAL0572';
UPDATE palabra SET definicion = 'A very high natural hill.', ejemplo = 'We climbed the mountain early in the morning.' WHERE codigo = 'PAL0573';
UPDATE palabra SET definicion = 'Feeling sick, as if you might vomit.', ejemplo = 'The rocking boat made me feel nauseous.' WHERE codigo = 'PAL0574';
UPDATE palabra SET definicion = 'Bad or harmful; also less than zero.', ejemplo = 'Try not to have a negative attitude.' WHERE codigo = 'PAL0575';
UPDATE palabra SET definicion = 'In or from the north.', ejemplo = 'Northern winters are long and cold.' WHERE codigo = 'PAL0576';
UPDATE palabra SET definicion = 'Very many.', ejemplo = 'Numerous students joined the contest.' WHERE codigo = 'PAL0577';
UPDATE palabra SET definicion = 'Gently rubbing or pressing with the nose.', ejemplo = 'The puppy was nuzzling my hand.' WHERE codigo = 'PAL0578';
UPDATE palabra SET definicion = 'Approved by someone in authority; also a person who holds a public role.', ejemplo = 'The official results will be posted tonight.' WHERE codigo = 'PAL0579';  -- DUPLICADA de PAL0580
UPDATE palabra SET definicion = 'Approved by someone in authority; also a person who holds a public role.', ejemplo = 'The official results will be posted tonight.' WHERE codigo = 'PAL0580';
UPDATE palabra SET definicion = 'Completely different, or facing the other way.', ejemplo = 'Hot is the opposite of cold.' WHERE codigo = 'PAL0581';
UPDATE palabra SET definicion = 'To arrange things in an orderly way.', ejemplo = 'Please organize your notes by subject.' WHERE codigo = 'PAL0582';
UPDATE palabra SET definicion = 'First or new; not copied from anything else.', ejemplo = 'The museum keeps the original painting.' WHERE codigo = 'PAL0583';
UPDATE palabra SET definicion = 'An object used as a decoration.', ejemplo = 'She hung a glass ornament on the tree.' WHERE codigo = 'PAL0584';
UPDATE palabra SET definicion = 'To defeat or deal successfully with a problem.', ejemplo = 'He worked hard to overcome his fear of speaking.' WHERE codigo = 'PAL0585';
UPDATE palabra SET definicion = 'Above your head.', ejemplo = 'A plane flew overhead.' WHERE codigo = 'PAL0586';
UPDATE palabra SET definicion = 'To pass someone or something that is moving in the same direction.', ejemplo = 'It is dangerous to overtake a truck on a curve.' WHERE codigo = 'PAL0587';
UPDATE palabra SET definicion = 'Going in the same direction and always the same distance apart.', ejemplo = 'The two roads run parallel to the river.' WHERE codigo = 'PAL0588';
UPDATE palabra SET definicion = 'Legally protected so that only the inventor can make or sell it.', ejemplo = 'The company patented its new design.' WHERE codigo = 'PAL0589';
UPDATE palabra SET definicion = 'Calm and quiet, without fighting or noise.', ejemplo = 'The lake is a peaceful place to relax.' WHERE codigo = 'PAL0590';
UPDATE palabra SET definicion = 'To convince someone to do or believe something.', ejemplo = 'I will persuade my parents to let me go.' WHERE codigo = 'PAL0591';
UPDATE palabra SET definicion = 'Related to the body or to real objects.', ejemplo = 'Physical exercise keeps you healthy.' WHERE codigo = 'PAL0592';
UPDATE palabra SET definicion = 'Enjoyable and nice.', ejemplo = 'We had a pleasant walk in the park.' WHERE codigo = 'PAL0593';  -- DUPLICADA de PAL0594
UPDATE palabra SET definicion = 'Enjoyable and nice.', ejemplo = 'We had a pleasant walk in the park.' WHERE codigo = 'PAL0594';
UPDATE palabra SET definicion = 'A feeling of enjoyment or happiness.', ejemplo = 'Reading gives her great pleasure.' WHERE codigo = 'PAL0595';
UPDATE palabra SET definicion = 'Easy to carry or move.', ejemplo = 'I bought a portable speaker for the trip.' WHERE codigo = 'PAL0596';
UPDATE palabra SET definicion = 'To delay something until a later time.', ejemplo = 'They had to postpone the game because of the rain.' WHERE codigo = 'PAL0597';
UPDATE palabra SET definicion = 'Having great strength or influence.', ejemplo = 'A powerful engine drives the ship.' WHERE codigo = 'PAL0598';
UPDATE palabra SET definicion = 'Coming before in time or order.', ejemplo = 'Review the previous lesson before the exam.' WHERE codigo = 'PAL0599';
UPDATE palabra SET definicion = 'Very deep or intense.', ejemplo = 'The book had a profound effect on her.' WHERE codigo = 'PAL0600';
UPDATE palabra SET definicion = 'Something that is owned, such as land or a building.', ejemplo = 'The property has a large garden.' WHERE codigo = 'PAL0601';
UPDATE palabra SET definicion = 'A set of rules or steps that must be followed.', ejemplo = 'Follow the safety protocol in the lab.' WHERE codigo = 'PAL0602';
UPDATE palabra SET definicion = 'In a way that everyone can see or hear.', ejemplo = 'The mayor publicly thanked the volunteers.' WHERE codigo = 'PAL0603';
UPDATE palabra SET definicion = 'To buy something.', ejemplo = 'I will purchase a new backpack tomorrow.' WHERE codigo = 'PAL0604';
UPDATE palabra SET definicion = 'A response to something that happens.', ejemplo = 'His reaction to the news was pure joy.' WHERE codigo = 'PAL0605';
UPDATE palabra SET definicion = 'A connection between people or things.', ejemplo = 'There is a clear relation between sleep and health.' WHERE codigo = 'PAL0606';
UPDATE palabra SET definicion = 'Able to be trusted.', ejemplo = 'My brother is a reliable friend.' WHERE codigo = 'PAL0607';
UPDATE palabra SET definicion = 'The state of depending on someone or something.', ejemplo = 'Our reliance on technology grows every year.' WHERE codigo = 'PAL0608';
UPDATE palabra SET definicion = 'A system of faith and worship.', ejemplo = 'Religion is important in many cultures.' WHERE codigo = 'PAL0609';
UPDATE palabra SET definicion = 'To keep something in your mind or bring back a memory.', ejemplo = 'Remember to bring your homework tomorrow.' WHERE codigo = 'PAL0610';
UPDATE palabra SET definicion = 'Careful study done to discover facts.', ejemplo = 'Scientists do research to find new medicines.' WHERE codigo = 'PAL0611';
UPDATE palabra SET definicion = 'Very strict and thorough.', ejemplo = 'The athletes follow a rigorous training plan.' WHERE codigo = 'PAL0612';
UPDATE palabra SET definicion = 'The edge of a road.', ejemplo = 'We bought fresh fruit at a roadside stand.' WHERE codigo = 'PAL0613';
UPDATE palabra SET definicion = 'A possible situation or series of events.', ejemplo = 'In the worst scenario, the flight will be canceled.' WHERE codigo = 'PAL0614';
UPDATE palabra SET definicion = 'A tool with two blades used for cutting paper or cloth.', ejemplo = 'Please pass me the scissors.' WHERE codigo = 'PAL0615';
UPDATE palabra SET definicion = 'Showing strong disrespect for someone or something.', ejemplo = 'He gave a scornful laugh.' WHERE codigo = 'PAL0616';
UPDATE palabra SET definicion = 'Close and careful examination.', ejemplo = 'The new plan came under public scrutiny.' WHERE codigo = 'PAL0617';
UPDATE palabra SET definicion = 'A rank in the army or the police.', ejemplo = 'The sergeant gave clear orders to the soldiers.' WHERE codigo = 'PAL0618';
UPDATE palabra SET definicion = 'A frozen fruit dessert (variant spelling of sherbet).', ejemplo = 'We ate orange sherbert after dinner.' WHERE codigo = 'PAL0619';
UPDATE palabra SET definicion = 'A situation in which there is not enough of something.', ejemplo = 'A water shortage affected the whole town.' WHERE codigo = 'PAL0620';
UPDATE palabra SET definicion = 'Having or showing great ability.', ejemplo = 'The skillful surgeon finished the operation quickly.' WHERE codigo = 'PAL0621';
UPDATE palabra SET definicion = 'In or from the south.', ejemplo = 'She has a soft southern accent.' WHERE codigo = 'PAL0622';
UPDATE palabra SET definicion = 'Clearly stated and exact.', ejemplo = 'Please give me a specific example.' WHERE codigo = 'PAL0623';
UPDATE palabra SET definicion = 'A wide range of different things; also the band of colors in a rainbow.', ejemplo = 'A rainbow shows the full spectrum of colors.' WHERE codigo = 'PAL0624';
UPDATE palabra SET definicion = 'Perfectly clean.', ejemplo = 'She left the kitchen spotless.' WHERE codigo = 'PAL0625';
UPDATE palabra SET definicion = 'A normal level or rule used for comparison.', ejemplo = 'The test follows a standard format.' WHERE codigo = 'PAL0626';
UPDATE palabra SET definicion = 'A close-fitting garment that covers the foot and leg.', ejemplo = 'He hung a red stocking by the fireplace.' WHERE codigo = 'PAL0627';
UPDATE palabra SET definicion = 'Without a bend or curve.', ejemplo = 'Draw a straight line with a ruler.' WHERE codigo = 'PAL0628';
UPDATE palabra SET definicion = 'The quality of being strong.', ejemplo = 'He lifted the box with great strength.' WHERE codigo = 'PAL0629';
UPDATE palabra SET definicion = 'To try very hard to do something difficult.', ejemplo = 'Many students struggle with spelling at first.' WHERE codigo = 'PAL0630';
UPDATE palabra SET definicion = 'Right or appropriate for a purpose.', ejemplo = 'This movie is suitable for children.' WHERE codigo = 'PAL0631';
UPDATE palabra SET definicion = 'An unexpected event or feeling.', ejemplo = 'The party was a big surprise.' WHERE codigo = 'PAL0632';
UPDATE palabra SET definicion = 'Moving through water by using your arms and legs.', ejemplo = 'Swimming is great exercise.' WHERE codigo = 'PAL0633';
UPDATE palabra SET definicion = 'A unit of sound in a word.', ejemplo = 'Say the word again, one syllable at a time.' WHERE codigo = 'PAL0634';
UPDATE palabra SET definicion = 'A feeling of sorrow for another person because of their trouble.', ejemplo = 'She showed sympathy for her sick friend.' WHERE codigo = 'PAL0635';
UPDATE palabra SET definicion = 'The system of collecting money from people for the government.', ejemplo = 'Taxation pays for schools and roads.' WHERE codigo = 'PAL0636';
UPDATE palabra SET definicion = 'Complete and very careful.', ejemplo = 'The doctor did a thorough check-up.' WHERE codigo = 'PAL0637';
UPDATE palabra SET definicion = 'To say that you will cause harm; to be a possible danger.', ejemplo = 'Dark clouds threaten to spoil the picnic.' WHERE codigo = 'PAL0638';
UPDATE palabra SET definicion = 'A work of art made of three panels joined together.', ejemplo = 'The artist painted a triptych of the sea.' WHERE codigo = 'PAL0639';
UPDATE palabra SET definicion = 'A piece of clothing that covers each leg separately; pants.', ejemplo = 'He wore gray trousers and a white shirt.' WHERE codigo = 'PAL0640';
UPDATE palabra SET definicion = 'A folding cover held over your head to keep off the rain.', ejemplo = 'Take an umbrella because it might rain.' WHERE codigo = 'PAL0641';
UPDATE palabra SET definicion = 'Against the law.', ejemplo = 'Driving without a license is unlawful.' WHERE codigo = 'PAL0642';
UPDATE palabra SET definicion = 'Not likely to happen.', ejemplo = 'It is unlikely that it will snow here.' WHERE codigo = 'PAL0643';
UPDATE palabra SET definicion = 'On or to a higher floor of a building.', ejemplo = 'The bedrooms are upstairs.' WHERE codigo = 'PAL0644';
UPDATE palabra SET definicion = 'Worth a lot of money or very useful.', ejemplo = 'The old coin is very valuable.' WHERE codigo = 'PAL0645';
UPDATE palabra SET definicion = 'Likely to change quickly or to explode.', ejemplo = 'Gasoline is a volatile liquid.' WHERE codigo = 'PAL0646';
UPDATE palabra SET definicion = 'A tall cupboard for hanging clothes; also all the clothes a person owns.', ejemplo = 'She hung her coat in the wardrobe.' WHERE codigo = 'PAL0647';
UPDATE palabra SET definicion = 'A lack of strength; a fault or flaw.', ejemplo = 'Chocolate is his only weakness.' WHERE codigo = 'PAL0648';
UPDATE palabra SET definicion = 'Wild animals and plants living in nature.', ejemplo = 'The park protects local wildlife.' WHERE codigo = 'PAL0649';
UPDATE palabra SET definicion = 'To take something out or take it back.', ejemplo = 'You can withdraw money from the ATM.' WHERE codigo = 'PAL0650';

UPDATE palabra SET pronunciacion = '/ˈbo͝olˌdōzər/' WHERE codigo = 'PAL0666';

UPDATE palabra SET definicion = 'A person who leaves someone or something behind for good.', ejemplo = 'The abandoner left the old house and never returned.' WHERE codigo = 'PAL0651';
UPDATE palabra SET definicion = 'In a way that agrees with something; used in the phrase according to.', ejemplo = 'According to the map, the museum is two blocks away.' WHERE codigo = 'PAL0652';
UPDATE palabra SET definicion = 'The part of the day between noon and evening.', ejemplo = 'We play soccer every afternoon after school.' WHERE codigo = 'PAL0653';
UPDATE palabra SET definicion = 'A shared decision or contract between people or groups.', ejemplo = 'The two companies signed an agreement yesterday.' WHERE codigo = 'PAL0654';
UPDATE palabra SET definicion = 'Next to or together with something.', ejemplo = 'The boat stayed alongside the dock all night.' WHERE codigo = 'PAL0655';
UPDATE palabra SET definicion = 'In a way that is very surprising.', ejemplo = 'Amazingly, nobody was hurt in the accident.' WHERE codigo = 'PAL0656';
UPDATE palabra SET definicion = 'The feeling of finding something funny; also fun and entertainment.', ejemplo = 'She laughed with amusement at the clown.' WHERE codigo = 'PAL0657';
UPDATE palabra SET definicion = 'To say that you are sorry.', ejemplo = 'I need to apologize for being late.' WHERE codigo = 'PAL0658';
UPDATE palabra SET definicion = 'The tools or equipment used for a particular purpose.', ejemplo = 'The lab has a special apparatus for testing water.' WHERE codigo = 'PAL0659';
UPDATE palabra SET definicion = 'Careful listening, looking or thinking.', ejemplo = 'Please pay attention to the instructions.' WHERE codigo = 'PAL0660';
UPDATE palabra SET definicion = 'The power to give orders or make decisions; a person or group with that power.', ejemplo = 'Only the school authority can change the rules.' WHERE codigo = 'PAL0661';
UPDATE palabra SET definicion = 'Working by itself without a person controlling it.', ejemplo = 'The door is automatic and opens when you walk near it.' WHERE codigo = 'PAL0662';
UPDATE palabra SET definicion = 'Very pleasing to look at or hear.', ejemplo = 'The garden is beautiful in spring.' WHERE codigo = 'PAL0663';
UPDATE palabra SET definicion = 'The start of something.', ejemplo = 'The beginning of the movie was very funny.' WHERE codigo = 'PAL0664';
UPDATE palabra SET definicion = 'Very bright, or extremely clever.', ejemplo = 'She had a brilliant idea for the project.' WHERE codigo = 'PAL0665';
UPDATE palabra SET definicion = 'A powerful machine used to push earth and rocks.', ejemplo = 'A bulldozer cleared the land for the new road.' WHERE codigo = 'PAL0666';
UPDATE palabra SET definicion = 'To find a number or amount by using math.', ejemplo = 'Use a calculator to calculate the total cost.' WHERE codigo = 'PAL0667';
UPDATE palabra SET definicion = 'A person who makes and repairs wooden things.', ejemplo = 'The carpenter built a new table for us.' WHERE codigo = 'PAL0668';
UPDATE palabra SET definicion = 'A stick of balm used to protect dry lips.', ejemplo = 'I keep a chapstick in my bag for cold days.' WHERE codigo = 'PAL0669';
UPDATE palabra SET definicion = 'A person in a story; also the personal qualities that make someone unique.', ejemplo = 'My favorite character in the book is a brave girl.' WHERE codigo = 'PAL0670';
UPDATE palabra SET definicion = 'A person you work with.', ejemplo = 'My colleague helped me finish the report.' WHERE codigo = 'PAL0671';
UPDATE palabra SET definicion = 'A group of people chosen to make decisions or do a task.', ejemplo = 'The committee will choose the winner next week.' WHERE codigo = 'PAL0672';
UPDATE palabra SET definicion = 'The state that something is in; also a requirement.', ejemplo = 'The bike is in excellent condition.' WHERE codigo = 'PAL0673';
UPDATE palabra SET definicion = 'Awake and aware of what is happening.', ejemplo = 'The patient was conscious after the operation.' WHERE codigo = 'PAL0674';
UPDATE palabra SET definicion = 'To say what you think is wrong or bad about something.', ejemplo = 'It is easy to criticize, but harder to help.' WHERE codigo = 'PAL0675';
UPDATE palabra SET definicion = 'Likely to cause harm.', ejemplo = 'The road is dangerous when it is icy.' WHERE codigo = 'PAL0676';
UPDATE palabra SET definicion = 'Feeling a strong need for help and ready to try anything.', ejemplo = 'The desperate travelers asked for water.' WHERE codigo = 'PAL0677';
UPDATE palabra SET definicion = 'To find out or decide something exactly.', ejemplo = 'Tests will determine the cause of the problem.' WHERE codigo = 'PAL0678';
UPDATE palabra SET definicion = 'The process of breaking down food in the body.', ejemplo = 'Walking after lunch can help digestion.' WHERE codigo = 'PAL0679';
UPDATE palabra SET definicion = 'The act of finding or learning something for the first time.', ejemplo = 'The discovery of the new island surprised everyone.' WHERE codigo = 'PAL0680';
UPDATE palabra SET definicion = 'A strong wish to do something.', ejemplo = 'He showed great eagerness to start the project.' WHERE codigo = 'PAL0681';
UPDATE palabra SET definicion = 'Working well and producing the result you want.', ejemplo = 'This is an effective way to study.' WHERE codigo = 'PAL0682';
UPDATE palabra SET definicion = 'To give special importance to something.', ejemplo = 'The coach will emphasize teamwork this season.' WHERE codigo = 'PAL0683';
UPDATE palabra SET definicion = 'Extremely good.', ejemplo = 'She gave an excellent presentation.' WHERE codigo = 'PAL0684';
UPDATE palabra SET definicion = 'The state of being real or alive.', ejemplo = 'Scientists proved the existence of a new species of frog.' WHERE codigo = 'PAL0685';
UPDATE palabra SET definicion = 'Extremely beautiful and carefully made.', ejemplo = 'She wore an exquisite silk dress.' WHERE codigo = 'PAL0686';
UPDATE palabra SET definicion = 'To make or build something; also to invent something false.', ejemplo = 'The workers fabricate metal parts for cars.' WHERE codigo = 'PAL0687';
UPDATE palabra SET definicion = 'A scene showing something that happened earlier; a sudden memory of the past.', ejemplo = 'The movie uses a flashback to show his childhood.' WHERE codigo = 'PAL0688';
UPDATE palabra SET definicion = 'Lucky.', ejemplo = 'We were fortunate to find a seat on the bus.' WHERE codigo = 'PAL0689';
UPDATE palabra SET definicion = 'Attractive in an exciting and fashionable way.', ejemplo = 'The actress looked glamorous at the ceremony.' WHERE codigo = 'PAL0690';
UPDATE palabra SET definicion = 'The quality of being very important or outstanding.', ejemplo = 'The greatness of the leader was remembered for many years.' WHERE codigo = 'PAL0691';
UPDATE palabra SET definicion = 'The best or most exciting part of something; also to mark text with a bright color.', ejemplo = 'The highlight of the trip was the boat ride.' WHERE codigo = 'PAL0692';
UPDATE palabra SET definicion = 'To put someone into a sleep-like state in which they follow suggestions.', ejemplo = 'The magician tried to hypnotize a volunteer.' WHERE codigo = 'PAL0693';
UPDATE palabra SET definicion = 'Saying one thing but doing the opposite.', ejemplo = 'It is hypocrisy to ask others to recycle if you never do.' WHERE codigo = 'PAL0694';
UPDATE palabra SET definicion = 'A person who says one thing but does the opposite.', ejemplo = 'He is a hypocrite because he never follows his own advice.' WHERE codigo = 'PAL0695';
UPDATE palabra SET definicion = 'An agreement to pay money if something is lost, damaged or stolen.', ejemplo = 'Car insurance paid for the repairs.' WHERE codigo = 'PAL0696';
UPDATE palabra SET definicion = 'A new thing that someone makes for the first time.', ejemplo = 'The telephone was an important invention.' WHERE codigo = 'PAL0697';
UPDATE palabra SET definicion = 'A small bean-shaped candy with a soft center.', ejemplo = 'She ate a red jellybean.' WHERE codigo = 'PAL0698';
UPDATE palabra SET definicion = 'A sea animal with a soft, clear body and stinging tentacles.', ejemplo = 'A jellyfish floated near the beach.' WHERE codigo = 'PAL0699';
UPDATE palabra SET definicion = 'The ability to make wise decisions; an opinion formed after careful thought.', ejemplo = 'Use good judgement when you choose your friends.' WHERE codigo = 'PAL0700';
UPDATE palabra SET definicion = 'Related to law and the judging of legal cases.', ejemplo = 'The court made a juridical decision about the property.' WHERE codigo = 'PAL0701';
UPDATE palabra SET definicion = 'What you know from learning or experience.', ejemplo = 'Reading gives you a lot of knowledge.' WHERE codigo = 'PAL0702';
UPDATE palabra SET definicion = 'Needing a lot of hard work and effort.', ejemplo = 'Building the wall was slow and laborious.' WHERE codigo = 'PAL0703';
UPDATE palabra SET definicion = 'Needed; something you must have or do.', ejemplo = 'It is necessary to wear a helmet.' WHERE codigo = 'PAL0704';
UPDATE palabra SET definicion = 'To talk in order to reach an agreement.', ejemplo = 'They will negotiate the price of the car.' WHERE codigo = 'PAL0705';
UPDATE palabra SET definicion = 'The act of doing what you are told to do.', ejemplo = 'Dogs are trained to show obedience.' WHERE codigo = 'PAL0706';
UPDATE palabra SET definicion = 'The use of a room, building or space by someone.', ejemplo = 'The hotel has full occupancy this weekend.' WHERE codigo = 'PAL0707';
UPDATE palabra SET definicion = 'If not; in a different way.', ejemplo = 'Hurry up, otherwise we will miss the bus.' WHERE codigo = 'PAL0708';
UPDATE palabra SET definicion = 'Support given by a regular customer or a sponsor.', ejemplo = 'The shop depends on the patronage of local families.' WHERE codigo = 'PAL0709';
UPDATE palabra SET definicion = 'The state of being more than one; a large variety.', ejemplo = 'The plurality of opinions made the discussion interesting.' WHERE codigo = 'PAL0710';
UPDATE palabra SET definicion = 'Possible in the future; the ability to develop or succeed.', ejemplo = 'She has great potential as a writer.' WHERE codigo = 'PAL0711';
UPDATE palabra SET definicion = 'Useful and sensible rather than only based on ideas.', ejemplo = 'A raincoat is a practical gift.' WHERE codigo = 'PAL0712';
UPDATE palabra SET definicion = 'The quality of being fast.', ejemplo = 'The quickness of the cat surprised us.' WHERE codigo = 'PAL0713';
UPDATE palabra SET definicion = 'A wild pig with a narrow, sharp back.', ejemplo = 'A razorback ran across the field.' WHERE codigo = 'PAL0714';
UPDATE palabra SET definicion = 'To know someone or something because you have seen it before.', ejemplo = 'I did not recognize him with his new haircut.' WHERE codigo = 'PAL0715';
UPDATE palabra SET definicion = 'To remember something.', ejemplo = 'I cannot recollect where I put my keys.' WHERE codigo = 'PAL0716';
UPDATE palabra SET definicion = 'To suggest that something is good or useful.', ejemplo = 'I recommend this book to everyone.' WHERE codigo = 'PAL0717';
UPDATE palabra SET definicion = 'A type of mint plant used to flavor gum and candy.', ejemplo = 'This gum has a fresh spearmint flavor.' WHERE codigo = 'PAL0718';
UPDATE palabra SET definicion = 'Related to the soul or faith rather than the physical world.', ejemplo = 'She finds peace through spiritual reading.' WHERE codigo = 'PAL0719';
UPDATE palabra SET definicion = 'A strong beam of light aimed at one place or person; public attention.', ejemplo = 'The singer stood in the spotlight.' WHERE codigo = 'PAL0720';
UPDATE palabra SET definicion = 'Something that is said or written in a formal way.', ejemplo = 'The mayor made a statement to the press.' WHERE codigo = 'PAL0721';
UPDATE palabra SET definicion = 'The way the parts of something are arranged; something that has been built.', ejemplo = 'The structure of the essay is clear.' WHERE codigo = 'PAL0722';
UPDATE palabra SET definicion = 'A type of matter with specific qualities.', ejemplo = 'Water is a clear substance.' WHERE codigo = 'PAL0723';
UPDATE palabra SET definicion = 'To represent an idea or thing.', ejemplo = 'A white dove can symbolize peace.' WHERE codigo = 'PAL0724';
UPDATE palabra SET definicion = 'Lasting for only a short time.', ejemplo = 'This is a temporary job for the summer.' WHERE codigo = 'PAL0725';
UPDATE palabra SET definicion = 'To change words from one language into another.', ejemplo = 'Can you translate this sentence into Spanish?' WHERE codigo = 'PAL0726';
UPDATE palabra SET definicion = 'Medical care given to a patient; the way someone or something is handled.', ejemplo = 'The treatment helped him recover quickly.' WHERE codigo = 'PAL0727';
UPDATE palabra SET definicion = 'To give a medicine that protects against a disease.', ejemplo = 'Nurses vaccinate children at the clinic.' WHERE codigo = 'PAL0728';
UPDATE palabra SET definicion = 'To treat someone unfairly or cruelly.', ejemplo = 'Bullies victimize younger students.' WHERE codigo = 'PAL0729';
UPDATE palabra SET definicion = 'To form a picture of something in your mind.', ejemplo = 'Close your eyes and visualize the beach.' WHERE codigo = 'PAL0730';
UPDATE palabra SET definicion = 'Extremely good or pleasant.', ejemplo = 'We had a wonderful day at the park.' WHERE codigo = 'PAL0731';
UPDATE palabra SET definicion = 'Having no value or use.', ejemplo = 'The old coin turned out to be worthless.' WHERE codigo = 'PAL0732';
UPDATE palabra SET definicion = 'An extra item that goes with something else, such as a bag or a belt.', ejemplo = 'A scarf is a nice accessory for a coat.' WHERE codigo = 'PAL0733';
UPDATE palabra SET definicion = 'Something that puts you in a better position than others.', ejemplo = 'Being tall is an advantage in basketball.' WHERE codigo = 'PAL0734';
UPDATE palabra SET definicion = 'Having a strong wish to succeed.', ejemplo = 'She is an ambitious student who wants to be a doctor.' WHERE codigo = 'PAL0735';
UPDATE palabra SET definicion = 'An animal, such as a frog, that can live both on land and in water.', ejemplo = 'A frog is an amphibian.' WHERE codigo = 'PAL0736';
UPDATE palabra SET definicion = 'To say that you are sorry.', ejemplo = 'I need to apologize for being late.' WHERE codigo = 'PAL0737';  
UPDATE palabra SET definicion = 'The scientific study of stars, planets and space.', ejemplo = 'We learned about the moon in astronomy class.' WHERE codigo = 'PAL0738';
UPDATE palabra SET definicion = 'Taking air into the lungs and letting it out.', ejemplo = 'Deep breathing helps you relax.' WHERE codigo = 'PAL0739';
UPDATE palabra SET definicion = 'A small, round, blue fruit.', ejemplo = 'She put a blueberry on top of the cake.' WHERE codigo = 'PAL0740';

UPDATE palabra SET definicion = 'A feeling of very strong hatred or disgust.', ejemplo = 'He looked at the cruelty with abhorrence.' WHERE codigo = 'PAL0741';
UPDATE palabra SET definicion = 'The act of giving up or denying something to yourself.', ejemplo = 'The monk lived a life of abnegation.' WHERE codigo = 'PAL0742';
UPDATE palabra SET definicion = 'In a very bad or terrible way.', ejemplo = 'The team played abominably in the first half.' WHERE codigo = 'PAL0743';
UPDATE palabra SET definicion = 'The first or original people living in a region, especially in Australia.', ejemplo = 'The aborigines have lived in Australia for tens of thousands of years.' WHERE codigo = 'PAL0744';
UPDATE palabra SET definicion = 'A shorter version of a longer written work.', ejemplo = 'I read an abridgment of the long novel.' WHERE codigo = 'PAL0745';
UPDATE palabra SET definicion = 'The official ending of a law or an agreement.', ejemplo = 'The abrogation of the old law took effect in May.' WHERE codigo = 'PAL0746';
UPDATE palabra SET definicion = 'A person who believes in complete and unlimited power.', ejemplo = 'The absolutist king refused to share his power.' WHERE codigo = 'PAL0747';
UPDATE palabra SET definicion = 'The ability to soak up liquid.', ejemplo = 'Paper towels are known for their absorbency.' WHERE codigo = 'PAL0748';
UPDATE palabra SET definicion = 'Good enough; allowed.', ejemplo = 'Your work is acceptable, but it could be better.' WHERE codigo = 'PAL0749';
UPDATE palabra SET definicion = 'Extra or more than what was already there.', ejemplo = 'Additional chairs were placed in the room.' WHERE codigo = 'PAL0750';
UPDATE palabra SET definicion = 'To act as a judge and decide a case or a dispute.', ejemplo = 'A committee will adjudicate the dispute.' WHERE codigo = 'PAL0751';
UPDATE palabra SET definicion = 'A small change made to improve something.', ejemplo = 'The mechanic made an adjustment to the brakes.' WHERE codigo = 'PAL0752';
UPDATE palabra SET definicion = 'At a later time.', ejemplo = 'We ate dinner, and afterwards we watched a movie.' WHERE codigo = 'PAL0753';
UPDATE palabra SET definicion = 'Ready to attack or argue; very forceful.', ejemplo = 'The aggressive dog barked at everyone.' WHERE codigo = 'PAL0754';
UPDATE palabra SET definicion = 'To expect something and prepare for it.', ejemplo = 'We anticipate a large crowd on Saturday.' WHERE codigo = 'PAL0755';
UPDATE palabra SET definicion = 'To be thankful for something; to understand its value.', ejemplo = 'I appreciate your help with the project.' WHERE codigo = 'PAL0756';
UPDATE palabra SET definicion = 'The fact of being the writer or creator of something.', ejemplo = 'The authorship of the poem is unknown.' WHERE codigo = 'PAL0757';
UPDATE palabra SET definicion = 'The part of a picture behind the main things; the experience and education that a person has had.', ejemplo = 'There is a mountain in the background of the photo.' WHERE codigo = 'PAL0758';
UPDATE palabra SET definicion = 'A large ape with black fur that lives in Africa.', ejemplo = 'The chimpanzee used a stick to get food.' WHERE codigo = 'PAL0759';
UPDATE palabra SET definicion = 'Related to buying and selling; also an advertisement on TV or radio.', ejemplo = 'The commercial for the new phone was very funny.' WHERE codigo = 'PAL0760';
UPDATE palabra SET definicion = 'To understand something fully.', ejemplo = 'It is hard to comprehend such a large number.' WHERE codigo = 'PAL0761';
UPDATE palabra SET definicion = 'The inner voice that tells you what is right or wrong.', ejemplo = 'His conscience told him to return the wallet.' WHERE codigo = 'PAL0762';
UPDATE palabra SET definicion = 'A feeling of deep sadness; also a long period of economic decline.', ejemplo = 'The country suffered a long economic depression.' WHERE codigo = 'PAL0763';
UPDATE palabra SET definicion = 'A conversation about a topic.', ejemplo = 'The class had a discussion about recycling.' WHERE codigo = 'PAL0764';
UPDATE palabra SET definicion = 'To give out or share among many people.', ejemplo = 'Volunteers distribute food to families.' WHERE codigo = 'PAL0765';
UPDATE palabra SET definicion = 'Equal in value, size or meaning.', ejemplo = 'Two halves are equivalent to one whole.' WHERE codigo = 'PAL0766';
UPDATE palabra SET definicion = 'Knowledge gained from doing something; an event that affects you.', ejemplo = 'She has ten years of teaching experience.' WHERE codigo = 'PAL0767';
UPDATE palabra SET definicion = 'The group of people who rule a country or region.', ejemplo = 'The government built a new hospital.' WHERE codigo = 'PAL0768';
UPDATE palabra SET definicion = 'Put into a sleep-like state in which you follow suggestions.', ejemplo = 'The volunteer was hypnotized on stage.' WHERE codigo = 'PAL0769';
UPDATE palabra SET definicion = 'To explain with pictures or examples; to add pictures to a book.', ejemplo = 'She will illustrate the story with colorful drawings.' WHERE codigo = 'PAL0770';
UPDATE palabra SET definicion = 'Perfectly clean and neat.', ejemplo = 'Her room is always immaculate.' WHERE codigo = 'PAL0771';
UPDATE palabra SET definicion = 'Not able to happen or be done.', ejemplo = 'It is impossible to finish this in five minutes.' WHERE codigo = 'PAL0772';
UPDATE palabra SET definicion = 'Causing admiration because of skill, size or quality.', ejemplo = 'The magician gave an impressive show.' WHERE codigo = 'PAL0773';
UPDATE palabra SET definicion = 'Placed side by side to show a contrast.', ejemplo = 'The artist juxtaposed old buildings with modern towers in the photo.' WHERE codigo = 'PAL0774';
UPDATE palabra SET definicion = 'A sport in which fighters punch and kick.', ejemplo = 'She goes to kickboxing class twice a week.' WHERE codigo = 'PAL0775';
UPDATE palabra SET definicion = 'Written works such as novels, poems and plays.', ejemplo = 'We study English literature at school.' WHERE codigo = 'PAL0776';
UPDATE palabra SET definicion = 'Causing harm or evil.', ejemplo = 'The maleficent witch cast a dark spell.' WHERE codigo = 'PAL0777';
UPDATE palabra SET definicion = 'To control or influence someone in a clever, often unfair way; to handle skillfully.', ejemplo = 'Do not let anyone manipulate your decisions.' WHERE codigo = 'PAL0778';
UPDATE palabra SET definicion = 'The reason or desire that makes you want to do something.', ejemplo = 'Her motivation to win kept her practicing every day.' WHERE codigo = 'PAL0779';
UPDATE palabra SET definicion = 'A soft, white Italian cheese often used on pizza.', ejemplo = 'The pizza was covered in melted mozzarella.' WHERE codigo = 'PAL0780';
UPDATE palabra SET definicion = 'A large farm where crops such as coffee or sugar are grown.', ejemplo = 'The plantation grows coffee and bananas.' WHERE codigo = 'PAL0781';
UPDATE palabra SET definicion = 'The part of a theater stage in front of the curtain, or the arch that frames the stage.', ejemplo = 'The actors bowed at the edge of the proscenium.' WHERE codigo = 'PAL0782';
UPDATE palabra SET definicion = 'A penalty given for breaking a rule or a law.', ejemplo = 'The punishment for cheating was a zero.' WHERE codigo = 'PAL0783';
UPDATE palabra SET definicion = 'Fair and sensible.', ejemplo = 'The price is reasonable for such good quality.' WHERE codigo = 'PAL0784';
UPDATE palabra SET definicion = 'Without being affected by something else.', ejemplo = 'We will go regardless of the weather.' WHERE codigo = 'PAL0785';
UPDATE palabra SET definicion = 'Unusual and worth noticing.', ejemplo = 'She made remarkable progress this year.' WHERE codigo = 'PAL0786';
UPDATE palabra SET definicion = 'A woman who sews clothes for a living.', ejemplo = 'The seamstress fixed the hem of my dress.' WHERE codigo = 'PAL0787';
UPDATE palabra SET definicion = 'An expert in one particular subject or field.', ejemplo = 'A heart specialist examined the patient.' WHERE codigo = 'PAL0788';
UPDATE palabra SET definicion = 'Able to be pressed gently to let out what is inside.', ejemplo = 'The squeezable bottle makes it easy to pour the sauce.' WHERE codigo = 'PAL0789';
UPDATE palabra SET definicion = 'Having achieved a goal or become well known.', ejemplo = 'The concert was very successful.' WHERE codigo = 'PAL0790';
UPDATE palabra SET definicion = 'Enough for a particular need.', ejemplo = 'Do we have sufficient food for everyone?' WHERE codigo = 'PAL0791';
UPDATE palabra SET definicion = 'An idea offered for someone to think about.', ejemplo = 'Do you have a suggestion for dinner?' WHERE codigo = 'PAL0792';
UPDATE palabra SET definicion = 'Feeling or causing distrust.', ejemplo = 'The guard saw a suspicious package.' WHERE codigo = 'PAL0793';
UPDATE palabra SET definicion = 'Given a particular surface feel or structure.', ejemplo = 'The texturized paint made the wall look rough.' WHERE codigo = 'PAL0794';
UPDATE palabra SET definicion = 'To know the meaning of something.', ejemplo = 'I do not understand this question.' WHERE codigo = 'PAL0795';
UPDATE palabra SET definicion = 'Not kind or welcoming.', ejemplo = 'The unfriendly clerk did not say hello.' WHERE codigo = 'PAL0796';
UPDATE palabra SET definicion = 'A sport in which two teams hit a ball over a net; also the ball used in this sport.', ejemplo = 'We play volleyball on the beach.' WHERE codigo = 'PAL0797';
UPDATE palabra SET definicion = 'A strong desire to travel.', ejemplo = 'Her wanderlust took her to twenty countries.' WHERE codigo = 'PAL0798';
UPDATE palabra SET definicion = 'Found or happening in many places.', ejemplo = 'The storm caused widespread damage.' WHERE codigo = 'PAL0799';
UPDATE palabra SET definicion = 'The branch of math that deals with adding, subtracting, multiplying and dividing.', ejemplo = 'Arithmetic is the first math skill children learn.' WHERE codigo = 'PAL0800';

UPDATE palabra SET definicion = 'The business of promoting products or services to the public.', ejemplo = 'Advertising on television can be very expensive.' WHERE codigo = 'PAL0801';
UPDATE palabra SET definicion = 'Something that belongs to a different time period from the one it appears in.', ejemplo = 'A cell phone in a movie about ancient Rome would be an anachronism.' WHERE codigo = 'PAL0802';
UPDATE palabra SET definicion = 'The date on which something important happened in an earlier year.', ejemplo = 'They celebrated their tenth anniversary in Paris.' WHERE codigo = 'PAL0803';
UPDATE palabra SET definicion = 'Suitable or correct for a particular situation.', ejemplo = 'Formal clothes are appropriate for the interview.' WHERE codigo = 'PAL0804';
UPDATE palabra SET definicion = 'Traveling or hiking while carrying your belongings in a backpack.', ejemplo = 'Backpacking through Europe was her dream trip.' WHERE codigo = 'PAL0805';
UPDATE palabra SET definicion = 'Showing disrespect toward God or sacred things.', ejemplo = 'The priest called the joke blasphemous.' WHERE codigo = 'PAL0806';
UPDATE palabra SET definicion = 'A special event held to mark a happy occasion.', ejemplo = 'The whole town joined the celebration.' WHERE codigo = 'PAL0807';
UPDATE palabra SET definicion = 'Two events happening at the same time by chance.', ejemplo = 'It was a coincidence that we chose the same book.' WHERE codigo = 'PAL0808';
UPDATE palabra SET definicion = 'Agreement between things; also an alphabetical list of the words used in a book.', ejemplo = 'There is concordance between the two reports.' WHERE codigo = 'PAL0809';
UPDATE palabra SET definicion = 'An idea or feeling that a word suggests in addition to its main meaning.', ejemplo = 'The word cheap has a negative connotation.' WHERE codigo = 'PAL0810';
UPDATE palabra SET definicion = 'Giving details that help you picture something.', ejemplo = 'The writer used descriptive language to paint the scene.' WHERE codigo = 'PAL0811';
UPDATE palabra SET definicion = 'A form of energy used to power lights and machines.', ejemplo = 'The storm cut off the electricity in our neighborhood.' WHERE codigo = 'PAL0812';
UPDATE palabra SET definicion = 'The natural world, or the surroundings in which people live and work.', ejemplo = 'We must protect the environment.' WHERE codigo = 'PAL0813';
UPDATE palabra SET definicion = 'The act of making something; also a made-up story or lie.', ejemplo = 'The story was a complete fabrication.' WHERE codigo = 'PAL0814';
UPDATE palabra SET definicion = 'Not memorable; easy to forget.', ejemplo = 'The movie was pleasant but forgettable.' WHERE codigo = 'PAL0815';
UPDATE palabra SET definicion = 'The act of no longer being angry with someone who did something wrong.', ejemplo = 'She asked for forgiveness after the argument.' WHERE codigo = 'PAL0816';
UPDATE palabra SET definicion = 'The ability to form new ideas or pictures in your mind.', ejemplo = 'Children have a wonderful imagination.' WHERE codigo = 'PAL0817';
UPDATE palabra SET definicion = 'Something or someone that gives you the wish to create or do something.', ejemplo = 'The mountains were her inspiration for the poem.' WHERE codigo = 'PAL0818';
UPDATE palabra SET definicion = 'Able to learn and understand things easily.', ejemplo = 'The intelligent student solved the problem quickly.' WHERE codigo = 'PAL0819';
UPDATE palabra SET definicion = 'A soft, sweet, white candy often toasted over a fire.', ejemplo = 'We roasted a marshmallow at the campfire.' WHERE codigo = 'PAL0820';
UPDATE palabra SET definicion = 'The qualities that make a person different from others.', ejemplo = 'He has a friendly and funny personality.' WHERE codigo = 'PAL0821';
UPDATE palabra SET definicion = 'To be the largest in number or the strongest in influence.', ejemplo = 'Pine trees predominate in this forest.' WHERE codigo = 'PAL0822';
UPDATE palabra SET definicion = 'A word that shows how a noun is related to another word, such as in or on.', ejemplo = 'The word under is a preposition.' WHERE codigo = 'PAL0823';
UPDATE palabra SET definicion = 'Something that is needed or demanded.', ejemplo = 'A passport is a requirement for international travel.' WHERE codigo = 'PAL0824';
UPDATE palabra SET definicion = 'Caring only about yourself and not about others.', ejemplo = 'His selfishness upset the whole team.' WHERE codigo = 'PAL0825';
UPDATE palabra SET definicion = 'Useful and able to do the job, though not fancy.', ejemplo = 'The old car is serviceable and cheap.' WHERE codigo = 'PAL0826';
UPDATE palabra SET definicion = 'A fault or weakness.', ejemplo = 'Impatience is his main shortcoming.' WHERE codigo = 'PAL0827';
UPDATE palabra SET definicion = 'To make things the same in size, quality or method.', ejemplo = 'The company will standardize its forms.' WHERE codigo = 'PAL0828';
UPDATE palabra SET definicion = 'Lower in rank or importance; a person who works under another.', ejemplo = 'The manager gave clear orders to her subordinate.' WHERE codigo = 'PAL0829';
UPDATE palabra SET definicion = 'The state of having enough of something.', ejemplo = 'The farm has a sufficiency of water for its crops.' WHERE codigo = 'PAL0830';
UPDATE palabra SET definicion = 'An idea that you accept as true without proof.', ejemplo = 'His theory is based on supposition, not facts.' WHERE codigo = 'PAL0831';
UPDATE palabra SET definicion = 'Dangerous; also disloyal and ready to betray.', ejemplo = 'The icy road was treacherous.' WHERE codigo = 'PAL0832';
UPDATE palabra SET definicion = 'Unlucky, or regrettable.', ejemplo = 'It was an unfortunate mistake.' WHERE codigo = 'PAL0833';
UPDATE palabra SET definicion = 'Impossible to stop.', ejemplo = 'The team was unstoppable in the second half.' WHERE codigo = 'PAL0834';
UPDATE palabra SET definicion = 'The act of giving a vaccine to protect against a disease.', ejemplo = 'Vaccination protects children from serious illness.' WHERE codigo = 'PAL0835';
UPDATE palabra SET definicion = 'A water sport in which you stand on a board with a sail.', ejemplo = 'Windsurfing is popular on windy beaches.' WHERE codigo = 'PAL0836';
UPDATE palabra SET definicion = 'Something that is not normal or usual.', ejemplo = 'The doctor found no abnormality in the test.' WHERE codigo = 'PAL0837';
UPDATE palabra SET definicion = 'A plan, or the way things are organized.', ejemplo = 'The seating arrangement was changed for the party.' WHERE codigo = 'PAL0838';
UPDATE palabra SET definicion = 'To stop doing or making something.', ejemplo = 'The store will discontinue that product next month.' WHERE codigo = 'PAL0839';
UPDATE palabra SET definicion = 'The natural character or mood of a person; the way something is arranged.', ejemplo = 'She has a cheerful disposition.' WHERE codigo = 'PAL0840';
UPDATE palabra SET definicion = 'Strong encouragement to do something.', ejemplo = 'The coach ended with an exhortation to never give up.' WHERE codigo = 'PAL0841';
UPDATE palabra SET definicion = 'Damaged by extreme cold.', ejemplo = 'The frostbitten fingers turned pale.' WHERE codigo = 'PAL0842';
UPDATE palabra SET definicion = 'To set up or have a main office in a place.', ejemplo = 'The company will headquarter its new division in Chicago.' WHERE codigo = 'PAL0843';
UPDATE palabra SET definicion = 'Causing public shame or disgrace.', ejemplo = 'The team suffered an ignominious defeat.' WHERE codigo = 'PAL0844';
UPDATE palabra SET definicion = 'Eager to learn and always asking questions.', ejemplo = 'The inquisitive child asked about everything.' WHERE codigo = 'PAL0845';
UPDATE palabra SET definicion = 'Playful in a naughty way.', ejemplo = 'The mischievous puppy hid my shoes.' WHERE codigo = 'PAL0846';
UPDATE palabra SET definicion = 'The act of remembering; something kept as a memory.', ejemplo = 'They lit candles in remembrance of the heroes.' WHERE codigo = 'PAL0847';
UPDATE palabra SET definicion = 'A person who spends money carelessly.', ejemplo = 'The spendthrift wasted his salary in a week.' WHERE codigo = 'PAL0848';
UPDATE palabra SET definicion = 'Full of excitement and uncertainty about what will happen.', ejemplo = 'It was a suspenseful movie.' WHERE codigo = 'PAL0849';
UPDATE palabra SET definicion = 'To make things happen at the same time or speed.', ejemplo = 'Let us synchronize our watches.' WHERE codigo = 'PAL0850';

UPDATE palabra SET definicion = 'A person who works to end something officially, especially slavery.', ejemplo = 'The abolitionist gave speeches against slavery.' WHERE codigo = 'PAL0851';
UPDATE palabra SET definicion = 'The quality of being complete and without limits.', ejemplo = 'The absoluteness of his power frightened people.' WHERE codigo = 'PAL0852';
UPDATE palabra SET definicion = 'The ability of a material to absorb something, such as light or heat.', ejemplo = 'Dark surfaces have high absorptivity of heat.' WHERE codigo = 'PAL0853';
UPDATE palabra SET definicion = 'In a way that relates to school or studying.', ejemplo = 'She is doing well academically.' WHERE codigo = 'PAL0854';
UPDATE palabra SET definicion = 'The study of how air moves around objects.', ejemplo = 'Aerodynamics helps engineers design faster cars.' WHERE codigo = 'PAL0855';
UPDATE palabra SET definicion = 'The repeating of the same sound at the start of nearby words.', ejemplo = 'Silly snakes slither slowly is an example of alliteration.' WHERE codigo = 'PAL0856';
UPDATE palabra SET definicion = 'A round, open building with rows of seats around a central space.', ejemplo = 'The concert was held in an ancient amphitheater.' WHERE codigo = 'PAL0857';
UPDATE palabra SET definicion = 'Thankfulness; also understanding the value of something.', ejemplo = 'She wrote a note of appreciation to the teacher.' WHERE codigo = 'PAL0858';
UPDATE palabra SET definicion = 'The art and science of designing buildings.', ejemplo = 'He studies architecture at the university.' WHERE codigo = 'PAL0859';
UPDATE palabra SET definicion = 'A woman who is not married; also a party held for a woman before her wedding.', ejemplo = 'She had a bachelorette party before the wedding.' WHERE codigo = 'PAL0860';
UPDATE palabra SET definicion = 'In a way that relates to how someone acts.', ejemplo = 'The child improved behaviorally after the meeting.' WHERE codigo = 'PAL0861';
UPDATE palabra SET definicion = 'The variety of living things in a place.', ejemplo = 'The rainforest has amazing biodiversity.' WHERE codigo = 'PAL0862';
UPDATE palabra SET definicion = 'The magnetic fields produced by or affecting living things.', ejemplo = 'Scientists study biomagnetism in migrating birds.' WHERE codigo = 'PAL0863';
UPDATE palabra SET definicion = 'The activity of lifting weights to build large muscles.', ejemplo = 'Bodybuilding requires regular training and a strict diet.' WHERE codigo = 'PAL0864';
UPDATE palabra SET definicion = 'Pushing a dangerous situation to the edge of disaster in order to gain an advantage.', ejemplo = 'Political brinkmanship almost caused a war.' WHERE codigo = 'PAL0865';
UPDATE palabra SET definicion = 'A sweet flavor made from butter and brown sugar.', ejemplo = 'I like butterscotch ice cream.' WHERE codigo = 'PAL0866';
UPDATE palabra SET definicion = 'A person who writes in beautiful, decorative handwriting.', ejemplo = 'The calligrapher wrote the invitations by hand.' WHERE codigo = 'PAL0867';
UPDATE palabra SET definicion = 'In a way that changes suddenly for no clear reason.', ejemplo = 'The king ruled capriciously and changed the laws every day.' WHERE codigo = 'PAL0868';
UPDATE palabra SET definicion = 'Behavior that is silly or immature.', ejemplo = 'His childishness annoyed the whole group.' WHERE codigo = 'PAL0869';
UPDATE palabra SET definicion = 'In a secondary or indirect way.', ejemplo = 'The new road affected the town collaterally.' WHERE codigo = 'PAL0870';
UPDATE palabra SET definicion = 'An official in charge of a department or a group.', ejemplo = 'The police commissioner gave a speech.' WHERE codigo = 'PAL0871';
UPDATE palabra SET definicion = 'The study of cells and chromosomes in relation to heredity.', ejemplo = 'Cytogenetics helps doctors find genetic problems.' WHERE codigo = 'PAL0872';
UPDATE palabra SET definicion = 'Able to be read or understood.', ejemplo = 'His handwriting is barely decipherable.' WHERE codigo = 'PAL0873';
UPDATE palabra SET definicion = 'To officially take something out of service.', ejemplo = 'The navy will decommission the old ship.' WHERE codigo = 'PAL0874';
UPDATE palabra SET definicion = 'In a way that combines many different styles or sources.', ejemplo = 'The room was decorated eclectically.' WHERE codigo = 'PAL0875';
UPDATE palabra SET definicion = 'Related to the origin and history of words.', ejemplo = 'An etymological dictionary explains where words come from.' WHERE codigo = 'PAL0876';
UPDATE palabra SET definicion = 'Causing deep sadness or sympathy.', ejemplo = 'The film had a heartrending ending.' WHERE codigo = 'PAL0877';
UPDATE palabra SET definicion = 'Saying one thing and doing the opposite.', ejemplo = 'It is hypocritical to complain about noise while playing loud music.' WHERE codigo = 'PAL0878';
UPDATE palabra SET definicion = 'Impossible to go through or to understand.', ejemplo = 'The jungle was thick and impenetrable.' WHERE codigo = 'PAL0879';
UPDATE palabra SET definicion = 'Freedom from the control of others.', ejemplo = 'The country won its independence after a long struggle.' WHERE codigo = 'PAL0880';
UPDATE palabra SET definicion = 'Redness, swelling and pain in a part of the body.', ejemplo = 'The medicine reduces inflammation in the knee.' WHERE codigo = 'PAL0881';
UPDATE palabra SET definicion = 'The breaking of a law, a rule or a right.', ejemplo = 'Copying the song was an infringement of copyright.' WHERE codigo = 'PAL0882';
UPDATE palabra SET definicion = 'Related to the mind and thinking; a person who enjoys study and ideas.', ejemplo = 'Chess is an intellectual game.' WHERE codigo = 'PAL0883';
UPDATE palabra SET definicion = 'The ability to learn, understand and reason.', ejemplo = 'Dolphins are known for their intelligence.' WHERE codigo = 'PAL0884';
UPDATE palabra SET definicion = 'Making someone feel afraid or nervous.', ejemplo = 'The tall guard was intimidating.' WHERE codigo = 'PAL0885';
UPDATE palabra SET definicion = 'The official power to make legal decisions over an area or a subject.', ejemplo = 'The case is outside the jurisdiction of this court.' WHERE codigo = 'PAL0886';
UPDATE palabra SET definicion = 'A company that makes goods in large numbers.', ejemplo = 'The manufacturer recalled the faulty toys.' WHERE codigo = 'PAL0887';
UPDATE palabra SET definicion = 'A group of people working together for a purpose.', ejemplo = 'She works for a nonprofit organization.' WHERE codigo = 'PAL0888';
UPDATE palabra SET definicion = 'A state in the northeastern United States.', ejemplo = 'Philadelphia is a large city in Pennsylvania.' WHERE codigo = 'PAL0889';  -- nombre propio, revisar si va en el concurso
UPDATE palabra SET definicion = 'Behaving with too much confidence, without having permission.', ejemplo = 'It was presumptuous of him to sit in my seat.' WHERE codigo = 'PAL0890';
UPDATE palabra SET definicion = 'Related to a job that needs special training; showing high skill.', ejemplo = 'She gave a professional presentation.' WHERE codigo = 'PAL0891';
UPDATE palabra SET definicion = 'Stubbornly refusing to obey rules or orders.', ejemplo = 'The recalcitrant student ignored every warning.' WHERE codigo = 'PAL0892';
UPDATE palabra SET definicion = 'The way people or things are connected.', ejemplo = 'They have a close relationship.' WHERE codigo = 'PAL0893';
UPDATE palabra SET definicion = 'The act of coming back to life; the return of something that had disappeared.', ejemplo = 'The resurrection of the old theater brought new life to the town.' WHERE codigo = 'PAL0894';
UPDATE palabra SET definicion = 'The importance or meaning of something.', ejemplo = 'Scientists explained the significance of the discovery.' WHERE codigo = 'PAL0895';
UPDATE palabra SET definicion = 'Happening at irregular times.', ejemplo = 'It rained sporadically throughout the day.' WHERE codigo = 'PAL0896';
UPDATE palabra SET definicion = 'A holiday in the United States and Canada when people give thanks, usually with a big meal.', ejemplo = 'Our family eats turkey on Thanksgiving.' WHERE codigo = 'PAL0897';  -- nombre propio, revisar si va en el concurso
UPDATE palabra SET definicion = 'Not pleasant to look at.', ejemplo = 'The old building was gray and unattractive.' WHERE codigo = 'PAL0898';
UPDATE palabra SET definicion = 'The state of not being firm or balanced.', ejemplo = 'The unsteadiness of the ladder worried him.' WHERE codigo = 'PAL0899';
UPDATE palabra SET definicion = 'A person who talks too much or tells secrets.', ejemplo = 'Do not tell Sam a secret because he is a blabbermouth.' WHERE codigo = 'PAL0900';

INSERT INTO contenido_leccion
(codigo, nombre, descripcion)
VALUES
('CON01', 'Lesson Introduction', 'Introduction and explanation of the lesson.'),
('CON02', 'Vocabulary', 'Vocabulary related to the lesson topic.'),
('CON03', 'Grammar', 'Grammar concepts and examples related to the lesson.'),
('CON04', 'Listening', 'Listening content and comprehension activities.'),
('CON05', 'Speaking', 'Speaking content and pronunciation practice.'),
('CON06', 'Review', 'Review of the concepts and vocabulary learned in the lesson.');

INSERT INTO estado_opcion
(clave, nombre, descripcion)
VALUES
('EST01', 'Correct', 'The option is the correct answer.'),
('EST02', 'Incorrect', 'The option is an incorrect answer.');

INSERT INTO opcion
(clave, nombre, descripcion, estado_opcion)
VALUES

('OPC01', 'Correct Answer', 'The option represents the correct answer.', 'EST01'),
('OPC02', 'Incorrect Answer 1', 'The option represents an incorrect answer.', 'EST02'),
('OPC03', 'Incorrect Answer 2', 'The option represents an incorrect answer.', 'EST02'),
('OPC04', 'Incorrect Answer 3', 'The option represents an incorrect answer.', 'EST02');

INSERT INTO ejercicio
(clave, nombre, descripcion, leccion)
VALUES

('EJE01', 'Vocabulary Selection', 'Select the correct vocabulary answer.', 'LEC01'),
('EJE02', 'Vocabulary Meaning', 'Select the correct meaning of the word.', 'LEC02'),
('EJE03', 'Grammar Selection', 'Select the correct grammar answer.', 'LEC03'),
('EJE04', 'Lesson Review', 'Select the correct answer from the lesson review.', 'LEC04');

INSERT INTO ejercicio_opcion
(ejercicio, opcion)
VALUES

('EJE01', 'OPC01'),
('EJE01', 'OPC02'),
('EJE01', 'OPC03'),
('EJE01', 'OPC04'),

('EJE02', 'OPC01'),
('EJE02', 'OPC02'),
('EJE02', 'OPC03'),
('EJE02', 'OPC04'),

('EJE03', 'OPC01'),
('EJE03', 'OPC02'),
('EJE03', 'OPC03'),
('EJE03', 'OPC04'),

('EJE04', 'OPC01'),
('EJE04', 'OPC02'),
('EJE04', 'OPC03'),
('EJE04', 'OPC04');

ALTER TABLE leccion
ADD COLUMN contenido_leccion VARCHAR(5) NULL;

UPDATE leccion
SET contenido_leccion = 'CON01'
WHERE clave IN ('LEC01','LEC05','LEC09','LEC13','LEC17',
                'LEC21','LEC25','LEC29','LEC33','LEC37');

UPDATE leccion
SET contenido_leccion = 'CON02'
WHERE clave IN ('LEC02','LEC06','LEC10','LEC14','LEC18',
                'LEC22','LEC26','LEC30','LEC34','LEC38');

UPDATE leccion
SET contenido_leccion = 'CON03'
WHERE clave IN ('LEC03','LEC07','LEC11','LEC15','LEC19',
                'LEC23','LEC27','LEC31','LEC35','LEC39');

UPDATE leccion
SET contenido_leccion = 'CON06'
WHERE clave IN ('LEC04','LEC08','LEC12','LEC16','LEC20',
                'LEC24','LEC28','LEC32','LEC36','LEC40');

ALTER TABLE leccion
ADD CONSTRAINT fk_leccion_contenido
FOREIGN KEY (contenido_leccion) REFERENCES contenido_leccion(codigo);

ALTER TABLE leccion
MODIFY contenido_leccion VARCHAR(5) NOT NULL;