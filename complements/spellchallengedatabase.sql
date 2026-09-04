
-- BASE DATOS SPELL-CHALLENGE 

CREATE DATABASE spell_challenge;
USE DATABASE spell_challenge;

-- TABLAS

CREATE TABLE categoria (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
);

CREATE TABLE nivel (
    codigo VARCHAR(2) PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE carrera (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE insignia (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    crit_obtencion VARCHAR(30) NOT NULL
);

CREATE TABLE juego (
    clave VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    mecanica VARCHAR(30) NOT NULL
);

CREATE TABLE dificultad (
    clave VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE tipo_usuario (
    clave VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE usuario (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre_pila VARCHAR(30) NOT NULL,
    apellPaterno VARCHAR(30) NOT NULL,
    apellMaterno VARCHAR(30) NOT NULL,
    correo VARCHAR(50) NOT NULL,
    contraseña VARCHAR(50) NOT NULL,
    telefono VARCHAR(10) NOT NULL,
    tipo_usuario VARCHAR(5) NOT NULL,
    FOREIGN KEY (tipo_usuario) REFERENCES tipo_usuario(clave)
);

CREATE TABLE administrador (
    clave VARCHAR(10) PRIMARY KEY,
    nombre_pila VARCHAR(30) NOT NULL,
    apellPaterno VARCHAR(30) NOT NULL,
    apellMaterno VARCHAR(30) NULL,
    usuario VARCHAR(10) NOT NULL,
    FOREIGN KEY (usuario) REFERENCES usuario(codigo)
);

CREATE TABLE profesor (
    clave VARCHAR(10) PRIMARY KEY,
    apellPaterno VARCHAR(100) NOT NULL,
    apellMaterno VARCHAR(100) NULL,
    usuario VARCHAR(10) NOT NULL, 
    FOREIGN KEY (usuario) REFERENCES usuario(codigo)   
);

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
);

CREATE TABLE ranking (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    posicion INT NOT NULL,
    periodo VARCHAR(20) NOT NULL,
    puntos INT NOT NULL,
    alumno VARCHAR(15) NOT NULL,
    FOREIGN KEY (alumno) REFERENCES alumno(matricula)
);

CREATE TABLE tipo_ranking (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(30) NOT NULL,
    ranking VARCHAR(10) NOT NULL,
    FOREIGN KEY (ranking) REFERENCES ranking(codigo)
);

CREATE TABLE lista (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    fecha_asignacion DATE NOT NULL;    
    fecha_limite DATE NULL,
    numero_letras INT NOT NULL,
    profesor VARCHAR(10) NOT NULL,
    FOREIGN KEY (profesor) REFERENCES profesor(clave)
);

CREATE TABLE palabra (
    codigo  VARCHAR(10) PRIMARY KEY,
    significado VARCHAR(50) NOT NULL,
    pronunciacion VARCHAR(100) NOT NULL,
    imagen VARCHAR(100) NOT NULL,
    audio VARCHAR(100) NOT NULL,
    categoria VARCHAR(10) NOT NULL,
    nivel VARCHAR(2) NOT NULL,
    FOREIGN KEY (categoria) REFERENCES categoria(codigo),
    FOREIGN KEY (nivel) REFERENCES nivel(codigo)
);

CREATE TABLE reporte (
    codigo VARCHAR(10) PRIMARY KEY,
    fecha_genera DATE NOT NULL,
    tipo_reporte VARCHAR(30) NOT NULL
    profesor VARCHAR(10) NOT NULL,
    FOREIGN KEY (profesor) REFERENCES profesor(clave)
);

CREATE TABLE rango (
    codigo  VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    minimo INT NOT NULL,
    maximo INT NULL,
    alumno VARCHAR(15) NOT NULL,
    FOREIGN KEY (alumno) REFERENCES alumno(matricula)
);


CREATE TABLE grupo (
    codigo  INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    fechaCreacion DATE NOT NULL,
    ciclo VARCHAR(100) NOT NULL,
    profesor VARCHAR(100) NOT NULL,
    alumno VARCHAR(100) NOT NULL,
    FOREIGN KEY (profesor) REFERENCES categoria(clave),
    FOREIGN KEY (alumno) REFERENCES nivel(matricula)
);

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
);

CREATE TABLE intento_palabra (
    clave VARCHAR(10) PRIMARY KEY,
    acertado INT NOT NULL,
    tiempo_respuesta TIMESTAMP NOT NULL,
    numero_intentos INT NOT NULL,
    practica_sesion VARCHAR(10) NOT NULL,      
    FOREIGN KEY (practica_sesion) REFERENCES practica_sesion(clave),
    FOREIGN KEY (palabra) REFERENCES palabra(codigo)
);

CREATE TABLE proceso_lista (
    lista VARCHAR(10) NOT NULL,
    alumno VARCHAR(10) NOT NULL,
    porcent_aciert FLOAT NOT NULL,
    lista_desbloqueada VARCHAR(10) NOT NULL,
    fecha_completado DATE NOT NULL,
    PRIMARY KEY (lista, alumno),
    FOREIGN KEY (lista) REFERENCES lista(codigo)
    FOREIGN KEY (alumno) REFERENCES alumno(matricula)
);

CREATE TABLE lista_grupo (
    lista VARCHAR(10),
    grupo INT NOT NULL,
    PRIMARY KEY (lista, grupo),
    FOREIGN KEY (lista) REFERENCES lista(codigo),
    FOREIGN KEY (grupo) REFERENCES grupo(codigo)
);


CREATE TABLE grupo_alumno (
    grupo VARCHAR(10) NOT NULL,
    alumno VARCHAR(10) NOT NULL,
    PRIMARY KEY (grupo, alumno),
    FOREIGN KEY (grupo) REFERENCES grupo(codigo),
    FOREIGN KEY (alumno) REFERENCES alumno(matricula),
    alumno VARCHAR(10) NOT NULL,
    PRIMARY KEY (grupo, alumno),
    FOREIGN KEY (grupo) REFERENCES grupo(codigo)
    FOREIGN KEY (alumno) REFERENCES alumno(matricula)
);

CREATE TABLE alumno_insignia (
    alumno VARCHAR(10) NOT NULL,
    insignia VARCHAR(10) NOT NULL,
    PRIMARY KEY (alumno, insignia),
    FOREIGN KEY (alumno) REFERENCES alumno(matricula),
    FOREIGN KEY (insignia) REFERENCES insignia(clave)
),

CREATE TABLE alumno_practica (
    alumno VARCHAR(10) NOT NULL,
    practica_sesion VARCHAR(10) NOT NULL,
    PRIMARY KEY (alumno, practica_sesion),
    FOREIGN KEY (alumno) REFERENCES alumno(matricula),
    FOREIGN KEY (practica_sesion) REFERENCES practica_sesion(clave)
),

CREATE TABLE dificultad_juego (
    juego VARCHAR(10) NOT NULL,
    dificultad VARCHAR(10) NOT NULL,
    PRIMARY KEY (juego, dificultad),
    FOREIGN KEY (juego) REFERENCES juego(clave),
    FOREIGN KEY (dificultad) REFERENCES dificultad(clave)
);

-- CATALOGO

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
('CAT10', 'Vehicles')

INSERT INTO nivel VALUES
('A1', 'Beginner level - basic everyday vocabulary'),
('A2', 'Basic level - frequent phrases and expressions'),
('B1', 'Intermediate level - familiar and interesting topics'),
('B2', 'Upper-intermediate level - complex and technical texts'),
('C1', 'Advanced level - flexible and effective use of the language'),
('C2', 'Proficiency level - virtually complete comprehension')

INSERT INTO carrera VALUES
('EII', 'Teaching the English Language', 'Training focused on pedagogical methodology, didactics and advanced command of the English language to work as a teacher or facilitator of the language at different educational and business levels.'),
('PP', 'Production Processes', 'Practical preparation to supervise, optimize and control manufacturing processes and industrial production lines under quality and sustainability standards.'),
('OLCE', 'Logistics Operations and Foreign Trade', 'Focus on supply chain management, customs regulations, international traffic, and global freight transport management.'),
('DSM', 'Multiplatform Software Development', 'Design, programming, implementation and management of computer applications for computers and mobile devices using current languages ​​and technological tools.'),
('IRD', 'Digital Network Infrastructure', 'Installation, configuration, security and administration of local and wide area networks, ensuring connectivity and data flow in organizations.')

INSERT INTO insignia VALUES
('INS01', '7-Day Streak', 'Practice 7 days straight'),
('INS02', '50 Correct Answers', 'Accumulate 50 correct words'),
('INS03', 'No Mistakes', 'Complete a list without making a mistake'),
('INS04', 'Weekly Champion', 'First place of the week'),
('INS05', 'Listening Master', 'Master the audio games'),
('INS06', 'Maximum Speed', 'Responded very quickly'),
('INS07', '30-Day Streak', 'Practice 30 days straight'),
('INS08', '100 Correct Answers', 'Accumulate 100 correct words'),
('INS09', 'Early Bird', 'Practice before 7 am'),
('INS10', 'Monthly Top 3', 'Place in the top 3'),
('INS11', 'Silver student', 'Place in the top 2')

INSERT INTO juego VALUES
('J01', 'Listen and Type', 'Audio plays and the student types the word; on a miss, the answer is shown and the audio repeats.'),
('J02', 'Word Scramble', 'The word appears scrambled and the student reorders it.'),
('J03', 'Hangman', 'Classic hangman with meaning or category hints.'),
('J04', 'Memory', 'Match word to image, or word to meaning.'),
('J05', 'Typing Race', 'Words appear and vanish quickly; the student must type them in time.'),
('J06', 'Word Search', 'Auto-generated word search using the list´s words.'),
('J07', 'Crossword', 'Auto-generated crossword using the teacher´s definitions.'),
('J08', 'Missing Letters', 'Word with gaps that the student fills in.'),
('J09', 'Multiple Choice', 'Audio plays and the student picks the correct word from options.'),
('J10', 'Image Challenge', 'An image is shown and the student types the matching word.'),
('J11', 'Beat the Clock', 'Answer as many words as possible in 60 seconds.'),
('J12', 'Boss Battle', 'Final challenge combining several previous mechanics.')

INSERT INTO dificultad VALUES
('DI01', 'Easy', 'Common, short, everyday words.'),
('DI02', 'Medium', 'Everyday words of moderate length and complexity.'),
('DI03', 'Hard', 'Longer or less common words.')

INSERT INTO tipo_usuario VALUES
('TUSR01', 'Student', 'someone who works in the field and someone who practices English'),
('TUSR02', 'Teacher', 'who creates the groups and teaches the classes'),
('TUSR03', 'Administrator', 'The system administrator')

INSERT INTO usuario VALUES
('USR0001', 'Renata', 'Ortega', 'Rivera', '2026100001@ut-tijuana.edu.mx', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOQ7fXJQ8vK8pYJ8K5JxG8qY9Y2r8zJm', '6641002001', 'TUSR01'),
('USR0002', 'Emilio', 'Delgado', 'Duran', '2026100002@ut-tijuana.edu.mx', '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92q8q3q0j5qK6f7m8n9oP', '6641002002', 'TUSR01'),
('USR0003', 'Ximena', 'Rojas', 'Pineda', '2026100003@ut-tijuana.edu.mx', '$2b$12$W5h8K2pLm9Qx7Vb3Nc4RdO6tYu1Ei8Fa0Gs2Hj5Kl7Mn9Pq4Rs6Tu', '6641002003', 'TUSR01'),
('USR0004', 'Adrian', 'Mendoza', 'Contreras', '2026100004@ut-tijuana.edu.mx', '$2b$12$A7cD9eF2gH4jK6mN8pQ1rS3tV5xY7zB0cE2fG4hJ6kL8mN0pQ2rS', '6641002004', 'TUSR01'),
('USR0005', 'Camila', 'Aguilar', 'Bravo', '2026100005@ut-tijuana.edu.mx', '$2b$12$Z8xC6vB4nM2aS0dF9gH7jK5lP3qW1eR8tY6uI4oP2aS9dF7gH5j', '6641002005', 'TUSR01'),
('USR0006', 'Oscar', 'Silva', 'Chavez', '2026100006@ut-tijuana.edu.mx', '$2b$12$Q4wE6rT8yU0iO2pA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR4tY6u', '6641002006', 'TUSR01'),
('USR0007', 'Brenda', 'Campos', 'Luna', '2026100007@ut-tijuana.edu.mx', '$2b$12$H3jK5lP7qW9eR1tY3uI5oA7sD9fG1hJ3kL5zX7cV9bN1mM3qW5eR', '6641002007', 'TUSR01'),
('USR0008', 'Sergio', 'Vargas', 'Robles', '2026100008@ut-tijuana.edu.mx', '$2b$12$M6nB8vC0xZ2aS4dF6gH8jK0lP2qW4eR6tY8uI0oA2sD4fG6hJ8k', '6641002008', 'TUSR01'),
('USR0009', 'Melissa', 'Pena', 'Cano', '2026100009@ut-tijuana.edu.mx', '$2b$12$R9tY7uI5oP3aS1dF9gH7jK5lP3qW1eR9tY7uI5oP3aS1dF9gH7jK', '6641002009', 'TUSR01'),
('USR0010', 'Gabriel', 'Rios', 'Solis', '2026100010@ut-tijuana.edu.mx', '$2b$12$B2vN4mM6qW8eR0tY2uI4oA6sD8fG0hJ2kL4zX6cV8bN0mM2qW4eR', '6641002010', 'TUSR01'),
('USR0011', 'Gilda', 'Torres', 'Roman', 'gilda.torres@beemail.com', '$2b$12$F5gH7jK9lP1qW3eR5tY7uI9oA1sD3fG5hJ7kL9zX1cV3bN5mM7qW', '6641002011', 'TUSR02'),
('USR0012', 'Blanca', 'Roman', 'Ortiz', 'blanca.roman@beemail.com', '$2b$12$T8yU6iO4pA2sD0fG8hJ6kL4zX2cV0bN8mM6qW4eR2tY0uI8oA6s', '6641002012', 'TUSR02'),
('USR0013', 'Isaac', 'Salvatierra', 'Anguilo', 'isaac.salvatierra@beemail.com', '$2b$12$C1vB3nM5aS7dF9gH1jK3lP5qW7eR9tY1uI3oA5sD7fG9hJ1kL3z', '6641002013', 'TUSR02'),
('USR0014', 'Ariana Lizeth', 'González', 'Osuna', 'ariana.gonzales@beemail.com', '$2b$12$J4kL6zX8cV0bN2mM4qW6eR8tY0uI2oA4sD6fG8hJ0kL2zX4cV6b', '6641002014', 'TUSR02'),
('USR0015', 'Juan Pablo', 'Quiñones', 'Hernández', 'juan.quinones@beemail.com', '$2b$12$P7qW5eR3tY1uI9oA7sD5fG3hJ1kL9zX7cV5bN3mM1qW9eR7tY5uI', '6641002015', 'TUSR02'),
('USR0016', 'Jesus Omar', 'Castañon', 'Castañon', 'omar.castanon@beemail.com', '$2b$12$V0bN2mM4qW6eR8tY0uI2oA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR', '6645114953', 'TUSR03'),
('USR0017', 'Josue Alberto', 'Villegas', 'Hernández', 'josue.villegas@beemail.com', '$2b$12$G9hJ7kL5zX3cV1bN9mM7qW5eR3tY1uI9oA7sD5fG3hJ1kL9zX7cV', '6646167119', 'TUSR03'),
('USR0018', 'Diego', 'Sánchez', 'Hernández', 'diego.sanchez@beemail.com', '$2b$12$K2lP4qW6eR8tY0uI2oA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR4tY', '6633288842', 'TUSR03'),
('USR0019', 'Dulce Aurora', 'de la Cruz', 'Enriquez', 'dulce.delacruz@beemail.com', '$2b$12$Y5uI3oA1sD9fG7hJ5kL3zX1cV9bN7mM5qW3eR1tY9uI7oA5sD3fG', '6642213487', 'TUSR03'),
('USR0020', 'Aline Aketzali', 'Lucido', 'Muñoz', 'aline.lucido@beemail.com', '$2b$12$D8fG6hJ4kL2zX0cV8bN6mM4qW2eR0tY8uI6oA4sD2fG0hJ8kL6zX', '6648199271', 'TUSR03')

INSERT INTO administrador VALUES
('AD01', 'Jesus Omar', 'Castañon', 'Castañon', 'USR0016'),
('AD02', 'Josue Alberto', 'Villegas', 'Hernández', 'USR0017'),
('AD03', 'Diego', 'Sánchez', 'Hernández', 'USR0018'),
('AD04', 'Dulce Aurora', 'de la Cruz', 'Enriquez', 'USR0019'),
('AD05', 'Aline Aketzali', 'Lucido', 'Muñoz', 'USR0020')

INSERT INTO profesor VALUES
('PROF01', 'Gilda', 'Torres', 'Roman', 'USR0011'),
('PROF02', 'Blanca', 'Roman', 'Ortiz', 'USR0012'),
('PROF03', 'Isaac', 'Salvatierra', 'Anguilo', 'USR0013'),
('PROF04', 'Ariana Lizeth', 'González', 'Osuna', 'USR0014'),
('PROF05', 'Juan Pablo', 'Quiñones', 'Hernández', 'USR0015')

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
('2026100010', 'Gabriel', 'Rios', 'Solis', 'USR0010', 'B1', 'IRD')

INSERT INTO ranking VALUES
('RNK01', 'Ranking Semanal #1', 1, 'Semanal', 'AL0001'),
('RNK02', 'Ranking Mensual #2', 2, 'Mensual', 'AL0002'),
('RNK03', 'Ranking Semanal #3', 3, 'Semanal', 'AL0003'),
('RNK04', 'Ranking Global #4', 4, 'Global', 'AL0004'),
('RNK05', 'Ranking Por grupo #5', 5, 'Por grupo', 'AL0005'),
('RNK06', 'Ranking Por carrera #6', 6, 'Por carrera', 'AL0006'),
('RNK07', 'Ranking Semanal #7', 7, 'Semanal', 'AL0007'),
('RNK08', 'Ranking Mensual #8', 8, 'Mensual', 'AL0008'),
('RNK09', 'Ranking Global #9', 9, 'Global', 'AL0009'),
('RNK10', 'Ranking Por grupo #10', 10, 'Por grupo', 'AL0010')

INSERT INTO tipo_ranking VALUES
('TR01', 'Global', 'Ranking de alcance global', 'RNK01'),
('TR02', 'Por grupo', 'Ranking de alcance por grupo', 'RNK02'),
('TR03', 'Por carrera', 'Ranking de alcance por carrera', 'RNK03'),
('TR04', 'Semanal', 'Ranking de alcance semanal', 'RNK04'),
('TR05', 'Mensual', 'Ranking de alcance mensual', 'RNK05')

INSERT INTO lista VALUES
('LIS01', 'Animals', 2026-08-01, 2026-08-15, 'PROF01'),
('LIS02', 'Food', 2026-08-04, 2026-08-18, 'PROF02'),
('LIS03', 'Colors', 2026-08-07, 2026-08-21, 'PROF03'),
('LIS04', 'Family', 2026-08-10, 2026-08-24, 'PROF04'),
('LIS05', 'School', 2026-08-13, 2026-08-27, 'PROF05'),
('LIS06', 'Sports', 2026-08-16, 2026-08-30, 'PROF06'),
('LIS07', 'Nature', 2026-08-16, 2026-09-02, 'PROF07'),
('LIS08', 'Technology', 2026-08-16, 2026-09-05, 'PROF08'),
('LIS09', 'Feelings', 2026-08-16, 2026-09-08, 'PROF09'),
('LIS10', 'Vehicles', 2026-08-16, 2026-09-11, 'PROF10')

INSERT INTO palabra VALUES
('PAL0001', 'apple', '/ap.el/', '', '', 'CAT01', 'A1'),
('PAL0002', 'tigger', '/tai.ger/', '', '', 'CAT02', 'A2'),
('PAL0003', 'purple', '/per.pel/', '', '', 'CAT03', 'B1'),
('PAL0004', 'mother', '/ma.der/', '', '', 'CAT04', 'B2'),
('PAL0005', 'pencil', '/pen.sel/', '', '', 'CAT05', 'C1'),
('PAL0006', 'sooccer', '/sa.ker/', '', '', 'CAT06', 'C2'),
('PAL0007', 'forest', '/fo.rest/', '', '', 'CAT07', 'A1'),
('PAL0008', 'laptop', '/lap.tap/', '', '', 'CAT08', 'A2'),
('PAL0009', 'happy', '/ha.pi/', '', '', 'CAT09', 'B1'),
('PAL0010', 'bicycle', '/bai.si.kel/', '', '', 'CAT10', 'B2')

INSERT INTO reporte VALUES
('REP01', 2026-08-01, 'General Statistics', 'PROF01'),
('REP02', 2026-08-03, 'Most Missed Words', 'PROF02'),
('REP03', 2026-08-05, 'Group Progress', 'PROF03'),
('REP04', 2026-08-07, 'Group Ranking', 'PROF04'),
('REP05', 2026-08-09, 'Inactive Students', 'PROF05'),
('REP06', 2026-08-11, 'Comparison Between Lists', 'PROF01'),
('REP07', 2026-08-13, 'Weekly Evolution', 'PROF02'),
('REP08', 2026-08-15, 'Average Practice Time', 'PROF03'),
('REP09', 2026-08-17, 'Group Average', 'PROF04'),
('REP10', 2026-08-19, 'Easiest Words', 'PROF05')

INSERT INTO rango VALUES
('RAN01', 'Bronze', 0, 999, 'AL0001'),
('RAN02', 'Silver', 1000, 2999, 'AL0002'),
('RAN03', 'Gold', 3000, 5999, 'AL0003'),
('RAN04', 'Diamond', 6000, 9999, 'AL0004'),
('RAN05', 'Spelling Master', 10000, , 'AL0005')

INSERT INTO grupo VALUES
('GRU01', 'Grupo A - EII', 2026-07-15, 'Aug-Dec 2026', 'PROF01', '2026100001'),
('GRU02', 'Grupo B - EII', 2026-07-15, 'Aug-Dec 2026', 'PROF02', '2026100006'),
('GRU03', 'Grupo A - PP', 2026-07-16, 'Aug-Dec 2026', 'PROF03', '2026100002'),
('GRU04', 'Grupo B - PP', 2026-07-16, 'Aug-Dec 2026', 'PROF04', '2026100007'),
('GRU05', 'Grupo A - OLCE', 2026-07-17, 'Aug-Dec 2026', 'PROF05', '2026100003'),
('GRU06', 'Grupo B - OLCE', 2026-07-17, 'Aug-Dec 2026', 'PROF01', '2026100008'),
('GRU07', 'Grupo A - DSM', 2026-07-18, 'Aug-Dec 2026', 'PROF02', '2026100004'),
('GRU08', 'Grupo B - DSM', 2026-07-18, 'Aug-Dec 2026', 'PROF03', '2026100009'),
('GRU09', 'Grupo A - IRD', 2026-07-19, 'Aug-Dec 2026', 'PROF04', '2026100005'),
('GRU10', 'Grupo B - IRD', 2026-07-19, 'Aug-Dec 2026', 'PROF05', '2026100010')

INSERT INTO practica_sesion VALUES
('PRA01', 2026-08-01, 00:02:00, 70, 'JUE01', 'LIS01'),
('PRA02', 2026-08-02, 00:03:00, 72.5, 'JUE02', 'LIS02'),
('PRA03', 2026-08-03, 00:04:00, 75, 'JUE03', 'LIS03'),
('PRA04', 2026-08-04, 00:05:00, 77.5, 'JUE04', 'LIS04'),
('PRA05', 2026-08-05, 00:06:00, 80, 'JUE05', 'LIS05'),
('PRA06', 2026-08-06, 00:02:00, 82.5, 'JUE06', 'LIS06'),
('PRA07', 2026-08-07, 00:03:00, 85, 'JUE07', 'LIS07'),
('PRA08', 2026-08-08, 00:04:00, 87.5, 'JUE08', 'LIS08'),
('PRA09', 2026-08-09, 00:05:00, 90, 'JUE09', 'LIS09'),
('PRA10', 2026-08-10, 00:06:00, 92.5, 'JUE10', 'LIS10')

INSERT INTO intento_palabra VALUES
('INT001', 0, 00:00:03, 1, 'PRA01', 'PAL001'),
('INT002', 1, 00:00:04, 2, 'PRA02', 'PAL002'),
('INT003', 1, 00:00:05, 3, 'PRA03', 'PAL003'),
('INT004', 1, 00:00:06, 1, 'PRA04', 'PAL004'),
('INT005', 0, 00:00:07, 2, 'PRA05', 'PAL005'),
('INT006', 1, 00:00:08, 3, 'PRA06', 'PAL006'),
('INT007', 1, 00:00:03, 1, 'PRA07', 'PAL007'),
('INT008', 1, 00:00:04, 2, 'PRA08', 'PAL008'),
('INT009', 0, 00:00:05, 3, 'PRA09', 'PAL009'),
('INT010', 1, 00:00:06, 1, 'PRA10', 'PAL010')

INSERT INTO proceso_lista VALUES
('LIS01', 'AL0001', 60, 'No', 2026-08-01),
('LIS02', 'AL0002', 63.7, 'No', 2026-08-04),
('LIS03', 'AL0003', 67.4, 'No', 2026-08-07),
('LIS04', 'AL0004', 71.1, 'No', 2026-08-10),
('LIS05', 'AL0005', 74.8, 'No', 2026-08-13),
('LIS06', 'AL0006', 78.5, 'No', 2026-08-16),
('LIS07', 'AL0007', 82.2, 'No', 2026-08-19),
('LIS08', 'AL0008', 85.9, 'No', 2026-08-22),
('LIS09', 'AL0009', 89.6, 'No', 2026-08-25),
('LIS10', 'AL0010', 93.3, 'Si', 2026-08-28)

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
('LIS10', 'GRU01')

INSERT INTO grupo_alumno VALUES
('GRU01', 'AL0003'),
('GRU02', 'AL0004'),
('GRU03', 'AL0005'),
('GRU04', 'AL0006'),
('GRU05', 'AL0007'),
('GRU06', 'AL0008'),
('GRU07', 'AL0009'),
('GRU08', 'AL0010'),
('GRU09', 'AL0001'),
('GRU10', 'AL0002')

INSERT INTO alumno_insignia VALUES
('AL0001', 'INS01', 2026-08-01),
('AL0002', 'INS02', 2026-08-05),
('AL0003', 'INS03', 2026-08-09),
('AL0004', 'INS04', 2026-08-13),
('AL0005', 'INS05', 2026-08-17),
('AL0006', 'INS06', 2026-08-21),
('AL0007', 'INS07', 2026-08-25),
('AL0008', 'INS08', 2026-08-29),
('AL0009', 'INS09', 2026-09-02),
('AL0010', 'INS10', 2026-09-06)

INSERT INTO alumno_practica VALUES
('AL0001', 'PRA01'),
('AL0002', 'PRA02'),
('AL0003', 'PRA03'),
('AL0004', 'PRA04'),
('AL0005', 'PRA05'),
('AL0006', 'PRA06'),
('AL0007', 'PRA07'),
('AL0008', 'PRA08'),
('AL0009', 'PRA09'),
('AL0010', 'PRA10')

INSERT INTO dificultad_juego VALUES
('JUE01', 'DIF01'),
('JUE02', 'DIF02'),
('JUE03', 'DIF03'),
('JUE04', 'DIF01'),
('JUE05', 'DIF02'),
('JUE06', 'DIF03'),
('JUE07', 'DIF03'),
('JUE08', 'DIF01'),
('JUE09', 'DIF02'),
('JUE10', 'DIF03')