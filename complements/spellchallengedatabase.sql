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
(clave, nombre, descripcion, practica_sesion, puntaje)
VALUES

-- PRA01
('LEC01', 'Lesson 1 - PRA01', 'First lesson of practice PRA01.', 'PRA01', 'PUN01'),
('LEC02', 'Lesson 2 - PRA01', 'Second lesson of practice PRA01.', 'PRA01', 'PUN01'),
('LEC03', 'Lesson 3 - PRA01', 'Third lesson of practice PRA01.', 'PRA01', 'PUN01'),
('LEC04', 'Lesson 4 - PRA01', 'Fourth lesson of practice PRA01.', 'PRA01', 'PUN01'),

-- PRA02
('LEC05', 'Lesson 1 - PRA02', 'First lesson of practice PRA02.', 'PRA02', 'PUN01'),
('LEC06', 'Lesson 2 - PRA02', 'Second lesson of practice PRA02.', 'PRA02', 'PUN01'),
('LEC07', 'Lesson 3 - PRA02', 'Third lesson of practice PRA02.', 'PRA02', 'PUN01'),
('LEC08', 'Lesson 4 - PRA02', 'Fourth lesson of practice PRA02.', 'PRA02', 'PUN01'),

-- PRA03
('LEC09', 'Lesson 1 - PRA03', 'First lesson of practice PRA03.', 'PRA03', 'PUN01'),
('LEC10', 'Lesson 2 - PRA03', 'Second lesson of practice PRA03.', 'PRA03', 'PUN01'),
('LEC11', 'Lesson 3 - PRA03', 'Third lesson of practice PRA03.', 'PRA03', 'PUN01'),
('LEC12', 'Lesson 4 - PRA03', 'Fourth lesson of practice PRA03.', 'PRA03', 'PUN01'),

-- PRA04
('LEC13', 'Lesson 1 - PRA04', 'First lesson of practice PRA04.', 'PRA04', 'PUN01'),
('LEC14', 'Lesson 2 - PRA04', 'Second lesson of practice PRA04.', 'PRA04', 'PUN01'),
('LEC15', 'Lesson 3 - PRA04', 'Third lesson of practice PRA04.', 'PRA04', 'PUN01'),
('LEC16', 'Lesson 4 - PRA04', 'Fourth lesson of practice PRA04.', 'PRA04', 'PUN01'),

-- PRA05
('LEC17', 'Lesson 1 - PRA05', 'First lesson of practice PRA05.', 'PRA05', 'PUN01'),
('LEC18', 'Lesson 2 - PRA05', 'Second lesson of practice PRA05.', 'PRA05', 'PUN01'),
('LEC19', 'Lesson 3 - PRA05', 'Third lesson of practice PRA05.', 'PRA05', 'PUN01'),
('LEC20', 'Lesson 4 - PRA05', 'Fourth lesson of practice PRA05.', 'PRA05', 'PUN01'),

-- PRA06
('LEC21', 'Lesson 1 - PRA06', 'First lesson of practice PRA06.', 'PRA06', 'PUN01'),
('LEC22', 'Lesson 2 - PRA06', 'Second lesson of practice PRA06.', 'PRA06', 'PUN01'),
('LEC23', 'Lesson 3 - PRA06', 'Third lesson of practice PRA06.', 'PRA06', 'PUN01'),
('LEC24', 'Lesson 4 - PRA06', 'Fourth lesson of practice PRA06.', 'PRA06', 'PUN01'),

-- PRA07
('LEC25', 'Lesson 1 - PRA07', 'First lesson of practice PRA07.', 'PRA07', 'PUN01'),
('LEC26', 'Lesson 2 - PRA07', 'Second lesson of practice PRA07.', 'PRA07', 'PUN01'),
('LEC27', 'Lesson 3 - PRA07', 'Third lesson of practice PRA07.', 'PRA07', 'PUN01'),
('LEC28', 'Lesson 4 - PRA07', 'Fourth lesson of practice PRA07.', 'PRA07', 'PUN01'),

-- PRA08
('LEC29', 'Lesson 1 - PRA08', 'First lesson of practice PRA08.', 'PRA08', 'PUN01'),
('LEC30', 'Lesson 2 - PRA08', 'Second lesson of practice PRA08.', 'PRA08', 'PUN01'),
('LEC31', 'Lesson 3 - PRA08', 'Third lesson of practice PRA08.', 'PRA08', 'PUN01'),
('LEC32', 'Lesson 4 - PRA08', 'Fourth lesson of practice PRA08.', 'PRA08', 'PUN01'),

-- PRA09
('LEC33', 'Lesson 1 - PRA09', 'First lesson of practice PRA09.', 'PRA09', 'PUN01'),
('LEC34', 'Lesson 2 - PRA09', 'Second lesson of practice PRA09.', 'PRA09', 'PUN01'),
('LEC35', 'Lesson 3 - PRA09', 'Third lesson of practice PRA09.', 'PRA09', 'PUN01'),
('LEC36', 'Lesson 4 - PRA09', 'Fourth lesson of practice PRA09.', 'PRA09', 'PUN01'),

-- PRA10
('LEC37', 'Lesson 1 - PRA10', 'First lesson of practice PRA10.', 'PRA10', 'PUN01'),
('LEC38', 'Lesson 2 - PRA10', 'Second lesson of practice PRA10.', 'PRA10', 'PUN01'),
('LEC39', 'Lesson 3 - PRA10', 'Third lesson of practice PRA10.', 'PRA10', 'PUN01'),
('LEC40', 'Lesson 4 - PRA10', 'Fourth lesson of practice PRA10.', 'PRA10', 'PUN01');

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