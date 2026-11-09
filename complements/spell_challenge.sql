-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-11-2026 a las 06:20:08
-- Versión del servidor: 12.2.2-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `spell_challenge`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `administrador`
--

CREATE TABLE `administrador` (
  `clave` varchar(10) NOT NULL,
  `nombre_pila` varchar(30) NOT NULL,
  `apellPaterno` varchar(30) NOT NULL,
  `apellMaterno` varchar(30) DEFAULT NULL,
  `usuario` varchar(10) NOT NULL,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `administrador`
--

INSERT INTO `administrador` (`clave`, `nombre_pila`, `apellPaterno`, `apellMaterno`, `usuario`, `foto`) VALUES
('AD01', 'Jesus Omar', 'Castañon', 'Castañon', 'USR0016', NULL),
('AD02', 'Josue Alberto', 'Villegas', 'Hernández', 'USR0017', NULL),
('AD03', 'Diego', 'Sánchez', 'Hernández', 'USR0018', NULL),
('AD04', 'Dulce Aurora', 'de la Cruz', 'Enriquez', 'USR0019', NULL),
('AD05', 'Aline Aketzali', 'Lucido', 'Muñoz', 'USR0020', NULL),
('ADM002', 'Admin', 'Test', 'User', 'ADM002', NULL),
('ADM003', 'Admin2', 'Test', 'User', 'ADM003', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno`
--

CREATE TABLE `alumno` (
  `matricula` varchar(10) NOT NULL,
  `nombrePila` varchar(30) NOT NULL,
  `apellPaterno` varchar(100) NOT NULL,
  `apellMaterno` varchar(100) DEFAULT NULL,
  `usuario` varchar(10) NOT NULL,
  `nivel` varchar(2) NOT NULL,
  `carrera` varchar(10) NOT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `puntos_experiencia` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `palabras_pronunciadas` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `alumno`
--

INSERT INTO `alumno` (`matricula`, `nombrePila`, `apellPaterno`, `apellMaterno`, `usuario`, `nivel`, `carrera`, `foto`, `puntos_experiencia`, `palabras_pronunciadas`) VALUES
('2026100001', 'Renata', 'Ortega', 'Rivera', 'USR0001', 'B1', 'EII', 'alumnos_fotos/chicken.png', 38, 0),
('2026100002', 'Emilio', 'Delgado', 'Duran', 'USR0002', 'A2', 'PP', NULL, 0, 5),
('2026100003', 'Ximena', 'Rojas', 'Pineda', 'USR0003', 'B1', 'OLCE', NULL, 0, 0),
('2026100004', 'Adrian', 'Mendoza', 'Contreras', 'USR0004', 'B1', 'DSM', NULL, 0, 0),
('2026100005', 'Camila', 'Aguilar', 'Bravo', 'USR0005', 'C1', 'IRD', NULL, 0, 0),
('2026100006', 'Oscar', 'Silva', 'Chavez', 'USR0006', 'C1', 'EII', NULL, 0, 0),
('2026100007', 'Brenda', 'Campos', 'Luna', 'USR0007', 'A2', 'PP', NULL, 0, 0),
('2026100008', 'Sergio', 'Vargas', 'Robles', 'USR0008', 'B2', 'OLCE', NULL, 0, 0),
('2026100009', 'Melissa', 'Pena', 'Cano', 'USR0009', 'B2', 'DSM', NULL, 0, 0),
('2026100010', 'Gabriel', 'Rios', 'Solis', 'USR0010', 'B1', 'IRD', NULL, 0, 0),
('2026100011', 'Eric', 'Aycardo', 'Balcázar', 'USR0011', 'C1', 'DSM', 'alumnos_fotos/gogeta-blue-ultra-db-legends.jfif', 100, 0),
('2026100012', 'Leonardo', 'Valdez', 'Ivan', 'USR0023', 'C1', 'DSM', NULL, 99, 0),
('ALUM001', 'Maria', 'Perez', 'Lopez', 'ALUM001', 'B1', 'DSM', NULL, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno_insignia`
--

CREATE TABLE `alumno_insignia` (
  `alumno` varchar(10) NOT NULL,
  `insignia` varchar(10) NOT NULL,
  `fecha_obtencion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `alumno_insignia`
--

INSERT INTO `alumno_insignia` (`alumno`, `insignia`, `fecha_obtencion`) VALUES
('2026100001', 'INS01', '2026-08-01'),
('2026100002', 'INS02', '2026-08-05'),
('2026100003', 'INS03', '2026-08-09'),
('2026100004', 'INS04', '2026-08-13'),
('2026100005', 'INS05', '2026-08-17'),
('2026100006', 'INS06', '2026-08-21'),
('2026100007', 'INS07', '2026-08-25'),
('2026100008', 'INS08', '2026-08-29'),
('2026100009', 'INS09', '2026-09-02'),
('2026100010', 'INS10', '2026-09-06'),
('2026100011', 'INS14', '2026-11-08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno_leccion`
--

CREATE TABLE `alumno_leccion` (
  `alumno` varchar(10) NOT NULL,
  `leccion` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `alumno_leccion`
--

INSERT INTO `alumno_leccion` (`alumno`, `leccion`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno_practica`
--

CREATE TABLE `alumno_practica` (
  `alumno` varchar(10) NOT NULL,
  `practica_sesion` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `alumno_practica`
--

INSERT INTO `alumno_practica` (`alumno`, `practica_sesion`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 3, 'add_permission'),
(6, 'Can change permission', 3, 'change_permission'),
(7, 'Can delete permission', 3, 'delete_permission'),
(8, 'Can view permission', 3, 'view_permission'),
(9, 'Can add group', 2, 'add_group'),
(10, 'Can change group', 2, 'change_group'),
(11, 'Can delete group', 2, 'delete_group'),
(12, 'Can view group', 2, 'view_group'),
(13, 'Can add user', 4, 'add_user'),
(14, 'Can change user', 4, 'change_user'),
(15, 'Can delete user', 4, 'delete_user'),
(16, 'Can view user', 4, 'view_user'),
(17, 'Can add content type', 5, 'add_contenttype'),
(18, 'Can change content type', 5, 'change_contenttype'),
(19, 'Can delete content type', 5, 'delete_contenttype'),
(20, 'Can view content type', 5, 'view_contenttype'),
(21, 'Can add session', 6, 'add_session'),
(22, 'Can change session', 6, 'change_session'),
(23, 'Can delete session', 6, 'delete_session'),
(24, 'Can view session', 6, 'view_session'),
(25, 'Can add carrera', 11, 'add_carrera'),
(26, 'Can change carrera', 11, 'change_carrera'),
(27, 'Can delete carrera', 11, 'delete_carrera'),
(28, 'Can view carrera', 11, 'view_carrera'),
(29, 'Can add categoria', 12, 'add_categoria'),
(30, 'Can change categoria', 12, 'change_categoria'),
(31, 'Can delete categoria', 12, 'delete_categoria'),
(32, 'Can view categoria', 12, 'view_categoria'),
(33, 'Can add dificultad', 13, 'add_dificultad'),
(34, 'Can change dificultad', 13, 'change_dificultad'),
(35, 'Can delete dificultad', 13, 'delete_dificultad'),
(36, 'Can view dificultad', 13, 'view_dificultad'),
(37, 'Can add insignia', 17, 'add_insignia'),
(38, 'Can change insignia', 17, 'change_insignia'),
(39, 'Can delete insignia', 17, 'delete_insignia'),
(40, 'Can view insignia', 17, 'view_insignia'),
(41, 'Can add juego', 19, 'add_juego'),
(42, 'Can change juego', 19, 'change_juego'),
(43, 'Can delete juego', 19, 'delete_juego'),
(44, 'Can view juego', 19, 'view_juego'),
(45, 'Can add lista', 20, 'add_lista'),
(46, 'Can change lista', 20, 'change_lista'),
(47, 'Can delete lista', 20, 'delete_lista'),
(48, 'Can view lista', 20, 'view_lista'),
(49, 'Can add nivel', 23, 'add_nivel'),
(50, 'Can change nivel', 23, 'change_nivel'),
(51, 'Can delete nivel', 23, 'delete_nivel'),
(52, 'Can view nivel', 23, 'view_nivel'),
(53, 'Can add tipo ranking', 31, 'add_tiporanking'),
(54, 'Can change tipo ranking', 31, 'change_tiporanking'),
(55, 'Can delete tipo ranking', 31, 'delete_tiporanking'),
(56, 'Can view tipo ranking', 31, 'view_tiporanking'),
(57, 'Can add tipo usuario', 32, 'add_tipousuario'),
(58, 'Can change tipo usuario', 32, 'change_tipousuario'),
(59, 'Can delete tipo usuario', 32, 'delete_tipousuario'),
(60, 'Can view tipo usuario', 32, 'view_tipousuario'),
(61, 'Can add usuario', 33, 'add_usuario'),
(62, 'Can change usuario', 33, 'change_usuario'),
(63, 'Can delete usuario', 33, 'delete_usuario'),
(64, 'Can view usuario', 33, 'view_usuario'),
(65, 'Can add administrador', 7, 'add_administrador'),
(66, 'Can change administrador', 7, 'change_administrador'),
(67, 'Can delete administrador', 7, 'delete_administrador'),
(68, 'Can view administrador', 7, 'view_administrador'),
(69, 'Can add alumno', 8, 'add_alumno'),
(70, 'Can change alumno', 8, 'change_alumno'),
(71, 'Can delete alumno', 8, 'delete_alumno'),
(72, 'Can view alumno', 8, 'view_alumno'),
(73, 'Can add palabra', 24, 'add_palabra'),
(74, 'Can change palabra', 24, 'change_palabra'),
(75, 'Can delete palabra', 24, 'delete_palabra'),
(76, 'Can view palabra', 24, 'view_palabra'),
(77, 'Can add practica_ sesion', 25, 'add_practica_sesion'),
(78, 'Can change practica_ sesion', 25, 'change_practica_sesion'),
(79, 'Can delete practica_ sesion', 25, 'delete_practica_sesion'),
(80, 'Can view practica_ sesion', 25, 'view_practica_sesion'),
(81, 'Can add intento_ palabra', 18, 'add_intento_palabra'),
(82, 'Can change intento_ palabra', 18, 'change_intento_palabra'),
(83, 'Can delete intento_ palabra', 18, 'delete_intento_palabra'),
(84, 'Can view intento_ palabra', 18, 'view_intento_palabra'),
(85, 'Can add profesor', 27, 'add_profesor'),
(86, 'Can change profesor', 27, 'change_profesor'),
(87, 'Can delete profesor', 27, 'delete_profesor'),
(88, 'Can view profesor', 27, 'view_profesor'),
(89, 'Can add grupo', 15, 'add_grupo'),
(90, 'Can change grupo', 15, 'change_grupo'),
(91, 'Can delete grupo', 15, 'delete_grupo'),
(92, 'Can view grupo', 15, 'view_grupo'),
(93, 'Can add rango', 28, 'add_rango'),
(94, 'Can change rango', 28, 'change_rango'),
(95, 'Can delete rango', 28, 'delete_rango'),
(96, 'Can view rango', 28, 'view_rango'),
(97, 'Can add reporte', 30, 'add_reporte'),
(98, 'Can change reporte', 30, 'change_reporte'),
(99, 'Can delete reporte', 30, 'delete_reporte'),
(100, 'Can view reporte', 30, 'view_reporte'),
(101, 'Can add ranking', 29, 'add_ranking'),
(102, 'Can change ranking', 29, 'change_ranking'),
(103, 'Can delete ranking', 29, 'delete_ranking'),
(104, 'Can view ranking', 29, 'view_ranking'),
(105, 'Can add grupo_ alumno', 16, 'add_grupo_alumno'),
(106, 'Can change grupo_ alumno', 16, 'change_grupo_alumno'),
(107, 'Can delete grupo_ alumno', 16, 'delete_grupo_alumno'),
(108, 'Can view grupo_ alumno', 16, 'view_grupo_alumno'),
(109, 'Can add alumno_ insignia', 9, 'add_alumno_insignia'),
(110, 'Can change alumno_ insignia', 9, 'change_alumno_insignia'),
(111, 'Can delete alumno_ insignia', 9, 'delete_alumno_insignia'),
(112, 'Can view alumno_ insignia', 9, 'view_alumno_insignia'),
(113, 'Can add dificultad_ juego', 14, 'add_dificultad_juego'),
(114, 'Can change dificultad_ juego', 14, 'change_dificultad_juego'),
(115, 'Can delete dificultad_ juego', 14, 'delete_dificultad_juego'),
(116, 'Can view dificultad_ juego', 14, 'view_dificultad_juego'),
(117, 'Can add lista_ grupo', 21, 'add_lista_grupo'),
(118, 'Can change lista_ grupo', 21, 'change_lista_grupo'),
(119, 'Can delete lista_ grupo', 21, 'delete_lista_grupo'),
(120, 'Can view lista_ grupo', 21, 'view_lista_grupo'),
(121, 'Can add lista_ palabra', 22, 'add_lista_palabra'),
(122, 'Can change lista_ palabra', 22, 'change_lista_palabra'),
(123, 'Can delete lista_ palabra', 22, 'delete_lista_palabra'),
(124, 'Can view lista_ palabra', 22, 'view_lista_palabra'),
(125, 'Can add alumno_ practica', 10, 'add_alumno_practica'),
(126, 'Can change alumno_ practica', 10, 'change_alumno_practica'),
(127, 'Can delete alumno_ practica', 10, 'delete_alumno_practica'),
(128, 'Can view alumno_ practica', 10, 'view_alumno_practica'),
(129, 'Can add proceso_ lista', 26, 'add_proceso_lista'),
(130, 'Can change proceso_ lista', 26, 'change_proceso_lista'),
(131, 'Can delete proceso_ lista', 26, 'delete_proceso_lista'),
(132, 'Can view proceso_ lista', 26, 'view_proceso_lista');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user`
--

CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_groups`
--

CREATE TABLE `auth_user_groups` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_user_permissions`
--

CREATE TABLE `auth_user_user_permissions` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora_administrador`
--

CREATE TABLE `bitacora_administrador` (
  `codigo` varchar(10) NOT NULL,
  `fecha_generacion` date NOT NULL,
  `hora_generacion` time NOT NULL,
  `accion` varchar(255) NOT NULL,
  `usuario` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `bitacora_administrador`
--

INSERT INTO `bitacora_administrador` (`codigo`, `fecha_generacion`, `hora_generacion`, `accion`, `usuario`) VALUES
('BITA01', '2026-08-01', '08:30:00', 'Registered a new student account.', 'USR0016'),
('BITA02', '2026-08-02', '09:45:00', 'Updated user information.', 'USR0017'),
('BITA03', '2026-08-03', '10:15:00', 'Registered a new teacher account.', 'USR0018'),
('BITA04', '2026-08-04', '12:00:00', 'Updated a career record.', 'USR0019'),
('BITA05', '2026-08-05', '13:30:00', 'Created a database backup.', 'USR0020'),
('BITA06', '2026-10-05', '13:59:24', 'Created a new user: Admin2 Test.', 'USR0018'),
('BITA07', '2026-10-22', '11:22:04', 'Updated user: John Smith.', 'USR0018');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora_profesor`
--

CREATE TABLE `bitacora_profesor` (
  `codigo` varchar(10) NOT NULL,
  `fecha_generacion` date NOT NULL,
  `hora_generacion` time NOT NULL,
  `accion` varchar(255) NOT NULL,
  `profesor` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `bitacora_profesor`
--

INSERT INTO `bitacora_profesor` (`codigo`, `fecha_generacion`, `hora_generacion`, `accion`, `profesor`) VALUES
('BITP01', '2026-08-01', '09:15:00', 'Created a new word list: Animals.', 'PROF01'),
('BITP02', '2026-08-04', '10:30:00', 'Updated the Food word list.', 'PROF02'),
('BITP03', '2026-08-07', '11:45:00', 'Created a new word list: Colors.', 'PROF03'),
('BITP04', '2026-08-10', '13:20:00', 'Assigned the Family word list to a group.', 'PROF04'),
('BITP05', '2026-08-13', '14:10:00', 'Created a new word list: School.', 'PROF05'),
('BITP06', '2026-10-05', '13:26:56', 'Created a new competition: Family Spelling II.', 'PROF04'),
('BITP07', '2026-10-08', '09:43:50', 'Updated group details: Grupo C - DSM.', 'PROF01'),
('BITP08', '2026-10-08', '09:44:25', 'Delete group: Grupo C - DSM', 'PROF01'),
('BITP09', '2026-10-09', '15:13:41', 'Created a new competition: Spelling Competition.', 'PROF01'),
('BITP10', '2026-10-13', '08:55:57', 'Updated group details: Grupo A - DSM.', 'PROF02'),
('BITP11', '2026-10-19', '09:08:49', 'Created a new competition: Nature Spelling Competition.', 'PROF02'),
('BITP12', '2026-10-19', '09:28:43', 'Created a new competition: Tech Spelling Bee.', 'PROF03'),
('BITP13', '2026-10-19', '15:15:09', 'Created a new competition: Spelling Bee Competition.', 'PROF03'),
('BITP14', '2026-10-27', '14:51:50', 'Created a new competition: Spell Challenge Competition.', 'PROF04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrera`
--

CREATE TABLE `carrera` (
  `clave` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `carrera`
--

INSERT INTO `carrera` (`clave`, `nombre`, `descripcion`) VALUES
('DSM', 'Multiplatform Software Develop', 'Design, programming, implementation and management of computer applications for computers and mobile devices using current languages and technological tools.'),
('EII', 'Teaching the English Language', 'Training focused on pedagogical methodology, didactics and advanced command of the English language to work as a teacher or facilitator of the language at different educational and business levels.'),
('IRD', 'Digital Network Infrastructure', 'Installation, configuration, security and administration of local and wide area networks, ensuring connectivity and data flow in organizations.'),
('OLCE', 'Logistics Operations and Forei', 'Focus on supply chain management, customs regulations, international traffic, and global freight transport management.'),
('PP', 'Production Processes', 'Practical preparation to supervise, optimize and control manufacturing processes and industrial production lines under quality and sustainability standards.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`codigo`, `nombre`) VALUES
('CAT01', 'Animals'),
('CAT02', 'Food'),
('CAT03', 'Colors'),
('CAT04', 'Family'),
('CAT05', 'School'),
('CAT06', 'Sports'),
('CAT07', 'Nature'),
('CAT08', 'Technology'),
('CAT09', 'Feelings'),
('CAT10', 'Vehicles'),
('CAT11', '6 Letters'),
('CAT12', '7 Letters'),
('CAT13', '8 Letters'),
('CAT14', '9 Letters'),
('CAT15', '10 Letters'),
('CAT16', '11 Letters'),
('CAT17', '12 Letters'),
('CAT18', 'Greetings'),
('CAT19', 'Daily Routines'),
('CAT20', 'Seasons'),
('CAT21', 'Subject Pronouns');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `competencia`
--

CREATE TABLE `competencia` (
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `profesor` varchar(10) NOT NULL,
  `estado` varchar(10) NOT NULL DEFAULT 'Upcoming',
  `tipo` varchar(10) NOT NULL DEFAULT 'LIST'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `competencia`
--

INSERT INTO `competencia` (`codigo`, `nombre`, `fecha`, `hora`, `profesor`, `estado`, `tipo`) VALUES
('COM01', 'Animals Spelling Challenge', '2026-08-15', '10:00:00', 'PROF01', 'Finished', 'LIST'),
('COM02', 'Food Spelling Challenge', '2026-08-18', '11:00:00', 'PROF02', 'Finished', 'LIST'),
('COM03', 'Colors Spelling Challenge', '2026-08-21', '12:00:00', 'PROF03', 'Upcoming', 'LIST'),
('COM04', 'Family Spelling Challenge', '2026-08-24', '13:00:00', 'PROF04', 'Finished', 'LIST'),
('COM05', 'School Spelling Challenge', '2026-08-27', '14:00:00', 'PROF05', 'Upcoming', 'LIST'),
('COM06', 'Sports Spell Challenge', '2026-10-08', '11:00:00', 'PROF01', 'Finished', 'LIST'),
('COM07', 'Feelings Spelling Challenge', '2026-10-05', '12:30:00', 'PROF04', 'Finished', 'LIST'),
('COM08', 'Feelings Spell Challenge II', '2026-10-05', '10:00:00', 'PROF04', 'Finished', 'LIST'),
('COM09', 'Family Spelling II', '2026-10-12', '10:45:00', 'PROF04', 'Finished', 'LIST'),
('COM10', 'Spelling Competition', '2026-10-09', '15:15:00', 'PROF01', 'Active', 'LIST'),
('COM11', 'Nature Spelling Challenge', '2026-10-19', '09:15:00', 'PROF02', 'Finished', 'LIST'),
('COM12', 'Tech Spelling Bee', '2026-10-19', '09:30:00', 'PROF03', 'Finished', 'LIST'),
('COM13', 'Spelling Bee Competition', '2026-10-21', '09:30:00', 'PROF03', 'Active', 'GENERAL'),
('COM14', 'Spell Challenge Competition', '2026-10-28', '08:50:00', 'PROF04', 'Upcoming', 'GENERAL');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `competencia_alumno`
--

CREATE TABLE `competencia_alumno` (
  `competencia` varchar(10) NOT NULL,
  `alumno` varchar(10) NOT NULL,
  `puntos_obtenidos` int(11) DEFAULT NULL,
  `palabras_correctas` int(11) DEFAULT NULL,
  `palabras_incorrectas` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `competencia_alumno`
--

INSERT INTO `competencia_alumno` (`competencia`, `alumno`, `puntos_obtenidos`, `palabras_correctas`, `palabras_incorrectas`) VALUES
('COM01', '2026100002', 95, 19, 1),
('COM02', '2026100003', 88, 18, 2),
('COM02', '2026100011', 100, 10, 0),
('COM03', '2026100004', 100, 20, 0),
('COM04', '2026100002', 90, 9, 1),
('COM04', '2026100005', NULL, NULL, NULL),
('COM05', '2026100006', NULL, NULL, NULL),
('COM06', '2026100001', 90, 9, 9),
('COM06', '2026100006', 80, 8, 8),
('COM06', '2026100007', 70, 7, 7),
('COM07', '2026100010', NULL, NULL, NULL),
('COM08', '2026100002', 80, 8, 2),
('COM08', '2026100004', 100, 10, 0),
('COM08', '2026100009', NULL, NULL, NULL),
('COM08', '2026100010', NULL, NULL, NULL),
('COM10', '2026100001', 0, 0, 0),
('COM10', '2026100002', 0, 0, 0),
('COM11', '2026100002', 90, 9, 1),
('COM12', '2026100011', 100, 10, 0),
('COM12', '2026100012', 100, 10, 0),
('COM13', '2026100011', 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `competencia_profesor`
--

CREATE TABLE `competencia_profesor` (
  `competencia` varchar(10) NOT NULL,
  `profesor` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `competencia_profesor`
--

INSERT INTO `competencia_profesor` (`competencia`, `profesor`) VALUES
('COM01', 'PROF01'),
('COM06', 'PROF01'),
('COM02', 'PROF02'),
('COM03', 'PROF03'),
('COM04', 'PROF04'),
('COM07', 'PROF04'),
('COM08', 'PROF04'),
('COM05', 'PROF05');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contenido_leccion`
--

CREATE TABLE `contenido_leccion` (
  `codigo` varchar(5) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `contenido_leccion`
--

INSERT INTO `contenido_leccion` (`codigo`, `nombre`, `descripcion`) VALUES
('CON01', 'Lesson Introduction', 'Introduction and explanation of the lesson.'),
('CON02', 'Vocabulary', 'Vocabulary related to the lesson topic.'),
('CON03', 'Grammar', 'Grammar concepts and examples related to the lesson.'),
('CON04', 'Listening', 'Listening content and comprehension activities.'),
('CON05', 'Speaking', 'Speaking content and pronunciation practice.'),
('CON06', 'Review', 'Review of the concepts and vocabulary learned in the lesson.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `copia_seguridad`
--

CREATE TABLE `copia_seguridad` (
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `datos` text NOT NULL,
  `administrador` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `copia_seguridad`
--

INSERT INTO `copia_seguridad` (`codigo`, `nombre`, `fecha`, `hora`, `datos`, `administrador`) VALUES
('COP01', 'Backup_2026_08_01', '2026-08-01', '18:00:00', 'Full database backup.', 'AD01'),
('COP02', 'Backup_2026_08_08', '2026-08-08', '18:30:00', 'Full database backup.', 'AD02'),
('COP03', 'Backup_2026_08_15', '2026-08-15', '19:00:00', 'Full database backup.', 'AD03'),
('COP04', 'Backup_2026_08_22', '2026-08-22', '19:30:00', 'Full database backup.', 'AD04'),
('COP05', 'Backup_2026_08_29', '2026-08-29', '20:00:00', 'Full database backup.', 'AD05'),
('COP06', 'backup_2026-10-01_19-58-32.sql', '2026-10-01', '19:58:32', 'Filename: backup_2026-10-01_19-58-32.sql\nSize: 222.67 KB\nType: Manual\nDescription: First database backup test', 'AD03'),
('COP07', 'COP07_uploaded.sql', '2026-10-22', '11:20:11', 'Filename: COP07_uploaded.sql\nSize: 223.14 KB\nType: Uploaded\nDescription: Test Uplodad - October 22', 'AD03'),
('COP08', 'backup_2026-10-26_15-13-59.sql', '2026-10-26', '15:13:59', 'Filename: backup_2026-10-26_15-13-59.sql\nSize: 236.45 KB\nType: Manual\nDescription: A New Backup', 'AD03'),
('COP09', 'COP09_uploaded.sql', '2026-10-26', '15:19:59', 'Filename: COP09_uploaded.sql\nSize: 236.45 KB\nType: Uploaded\nDescription: Today Backup', 'AD03');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dificultad`
--

CREATE TABLE `dificultad` (
  `clave` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `dificultad`
--

INSERT INTO `dificultad` (`clave`, `nombre`, `descripcion`) VALUES
('DI01', 'Easy', 'Common, short, everyday words.'),
('DI02', 'Medium', 'Everyday words of moderate length and complexity.'),
('DI03', 'Hard', 'Longer or less common words.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dificultad_juego`
--

CREATE TABLE `dificultad_juego` (
  `juego` varchar(10) NOT NULL,
  `dificultad` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `dificultad_juego`
--

INSERT INTO `dificultad_juego` (`juego`, `dificultad`) VALUES
('J01', 'DI01'),
('J04', 'DI01'),
('J08', 'DI01'),
('J02', 'DI02'),
('J04', 'DI02'),
('J05', 'DI02'),
('J09', 'DI02'),
('J11', 'DI02'),
('J03', 'DI03'),
('J04', 'DI03'),
('J06', 'DI03'),
('J07', 'DI03'),
('J10', 'DI03'),
('J12', 'DI03');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(2, '2026-09-09 17:49:08.639820', 'USR0021', 'jesus.omar@spell-challenge.usa', 2, '[{\"changed\": {\"fields\": [\"Tipo usuario\"]}}]', 33, 'USR0021');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(1, 'admin', 'logentry'),
(2, 'auth', 'group'),
(3, 'auth', 'permission'),
(4, 'auth', 'user'),
(5, 'contenttypes', 'contenttype'),
(7, 'home', 'administrador'),
(8, 'home', 'alumno'),
(9, 'home', 'alumno_insignia'),
(10, 'home', 'alumno_practica'),
(11, 'home', 'carrera'),
(12, 'home', 'categoria'),
(13, 'home', 'dificultad'),
(14, 'home', 'dificultad_juego'),
(15, 'home', 'grupo'),
(16, 'home', 'grupo_alumno'),
(17, 'home', 'insignia'),
(18, 'home', 'intento_palabra'),
(19, 'home', 'juego'),
(20, 'home', 'lista'),
(21, 'home', 'lista_grupo'),
(22, 'home', 'lista_palabra'),
(23, 'home', 'nivel'),
(24, 'home', 'palabra'),
(25, 'home', 'practica_sesion'),
(26, 'home', 'proceso_lista'),
(27, 'home', 'profesor'),
(28, 'home', 'rango'),
(29, 'home', 'ranking'),
(30, 'home', 'reporte'),
(31, 'home', 'tiporanking'),
(32, 'home', 'tipousuario'),
(33, 'home', 'usuario'),
(6, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2026-09-04 17:19:33.903590'),
(2, 'auth', '0001_initial', '2026-09-04 17:19:34.525291'),
(6, 'contenttypes', '0002_remove_content_type_name', '2026-09-04 17:19:34.749662'),
(7, 'auth', '0002_alter_permission_name_max_length', '2026-09-04 17:19:34.818703'),
(8, 'auth', '0003_alter_user_email_max_length', '2026-09-04 17:19:34.867852'),
(9, 'auth', '0004_alter_user_username_opts', '2026-09-04 17:19:34.878272'),
(10, 'auth', '0005_alter_user_last_login_null', '2026-09-04 17:19:34.921231'),
(11, 'auth', '0006_require_contenttypes_0002', '2026-09-04 17:19:34.924413'),
(12, 'auth', '0007_alter_validators_add_error_messages', '2026-09-04 17:19:34.935002'),
(13, 'auth', '0008_alter_user_username_max_length', '2026-09-04 17:19:34.969662'),
(14, 'auth', '0009_alter_user_last_name_max_length', '2026-09-04 17:19:35.002594'),
(15, 'auth', '0010_alter_group_name_max_length', '2026-09-04 17:19:35.036311'),
(16, 'auth', '0011_update_proxy_permissions', '2026-09-04 17:19:35.049146'),
(17, 'auth', '0012_alter_user_first_name_max_length', '2026-09-04 17:19:35.081764'),
(18, 'sessions', '0001_initial', '2026-09-04 17:19:35.128931'),
(24, 'home', '0001_initial', '2026-09-14 06:13:08.748461'),
(25, 'admin', '0001_initial', '2026-09-14 06:14:16.414845'),
(26, 'admin', '0002_logentry_remove_auto_add', '2026-09-14 06:14:16.422841'),
(27, 'admin', '0003_logentry_add_action_flag_choices', '2026-09-14 06:14:16.425430'),
(28, 'home', '0002_competencia_alumno_competencia_profesor_and_more', '2026-10-23 22:16:55.831997'),
(29, 'home', '0003_profesor_foto', '2026-10-23 22:16:55.841768');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ejercicio`
--

CREATE TABLE `ejercicio` (
  `clave` varchar(5) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text NOT NULL,
  `leccion` varchar(10) NOT NULL,
  `contenido_leccion` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ejercicio`
--

INSERT INTO `ejercicio` (`clave`, `nombre`, `descripcion`, `leccion`, `contenido_leccion`) VALUES
('EJE01', 'Vocabulary Selection', 'Select the correct vocabulary answer.', 'LEC01', 'CON02'),
('EJE02', 'Vocabulary Meaning', 'Select the correct meaning of the word.', 'LEC02', 'CON02'),
('EJE03', 'Verb To Be - Yes/No Questions', 'Choose the correct question using the verb To Be to describe an animal.', 'LEC03', 'CON03'),
('EJE04', 'Lesson Review - Animals and Grammar', 'Choose the correct sentence to describe animals using subject pronouns and the verb To Be.', 'LEC04', 'CON06'),
('EJE05', 'Subject Pronouns', 'Choose the correct subject pronoun. ___ am a student.', 'LEC01', 'CON03'),
('EJE06', 'Subject Pronouns', 'Mary is my friend. ___ is nice.', 'LEC01', 'CON03'),
('EJE07', 'Verb To Be', 'Choose the correct verb. You ___ welcome.', 'LEC01', 'CON03'),
('EJE08', 'Introductions', 'Choose the correct sentence.', 'LEC01', 'CON03'),
('EJE09', 'Greetings and To Be', 'Hello! My name ___ Anna.', 'LEC01', 'CON03'),
('EJE10', 'Listening Greetings', 'Listen and choose what you hear.', 'LEC01', 'CON04'),
('EJE11', 'Listening Introductions', 'Listen to the audio and select the option.', 'LEC01', 'CON04'),
('EJE12', 'Listening Expressions', 'Which phrase did you hear?', 'LEC01', 'CON04'),
('EJE13', 'Speaking Greetings', 'Good morning', 'LEC01', 'CON05'),
('EJE14', 'Speaking Farewells', 'See you later', 'LEC01', 'CON05'),
('EJE15', 'Animal Characteristics', 'Which animal can fly?', 'LEC02', 'CON02'),
('EJE16', 'Verb To Be - Affirmative', 'A dog ___ a pet.', 'LEC02', 'CON03'),
('EJE17', 'Verb To Be - Plural', 'Cats ___ animals.', 'LEC02', 'CON03'),
('EJE18', 'Verb To Be - Negative', 'A fish ___ a bird.', 'LEC02', 'CON03'),
('EJE19', 'Subject Pronouns', '___ is a large animal. (An elephant)', 'LEC02', 'CON03'),
('EJE20', 'Subject Pronouns - Plural', '___ are wild animals. (Lions)', 'LEC02', 'CON03'),
('EJE21', 'Listening - Animal Descriptions', 'Listen and choose the sentence you hear.', 'LEC02', 'CON04'),
('EJE22', 'Listening - Wild Animals', 'Listen and identify the animal.', 'LEC02', 'CON04'),
('EJE23', 'Listening - Animal Groups', 'Listen and choose the correct sentence.', 'LEC02', 'CON04'),
('EJE24', 'Speaking - Describe an Animal', 'A dog is a friendly animal.', 'LEC02', 'CON05'),
('EJE25', 'Speaking - Animal Characteristics', 'Elephants are large animals.', 'LEC02', 'CON05'),
('EJE26', 'Animal Lesson Review', 'Which sentence correctly describes a tiger?', 'LEC02', 'CON06'),
('EJE27', 'Animal Habitats', 'Choose the correct vocabulary answer about animal habitats and characteristics.', 'LEC03', 'CON02'),
('EJE28', 'Verb To Be - Short Answers', 'Choose the correct short answer to the question about an animal.', 'LEC03', 'CON03'),
('EJE29', 'Verb To Be - Questions', 'Select the correct question structure using the verb To Be.', 'LEC03', 'CON03'),
('EJE30', 'Subject Pronouns - Animal Descriptions', 'Choose the correct subject pronoun to complete the sentence.', 'LEC03', 'CON03'),
('EJE31', 'Verb To Be - Mixed Practice', 'Complete the sentence using the correct form of the verb To Be.', 'LEC03', 'CON03'),
('EJE32', 'Listening - Animal Questions', 'Listen carefully and identify the animal being described.', 'LEC03', 'CON04'),
('EJE33', 'Listening - Animal Characteristics', 'Listen to the description and select the correct animal characteristic.', 'LEC03', 'CON04'),
('EJE34', 'Listening - Short Answers', 'Listen to the question and identify the correct short answer.', 'LEC03', 'CON04'),
('EJE35', 'Speaking - Describe an Animal', 'Say: A penguin is a bird, and it is black and white.', 'LEC03', 'CON05'),
('EJE36', 'Speaking - Animal Questions', 'Say: Is a dolphin a fish? No, it is not. It is a mammal.', 'LEC03', 'CON05'),
('EJE37', 'Lesson Review - Animals and Grammar', 'Review animal vocabulary, subject pronouns and the verb To Be.', 'LEC03', 'CON06'),
('EJE38', 'Animal Characteristics', 'Which animal is a marine mammal that breathes air and lives in the ocean?', 'LEC04', 'CON02'),
('EJE39', 'Subject Pronouns', 'Look at the elephants. ___ are large animals.', 'LEC04', 'CON03'),
('EJE40', 'Verb To Be - Affirmative', 'The penguin ___ black and white.', 'LEC04', 'CON03'),
('EJE41', 'Verb To Be - Negative', 'A tiger ___ a domestic animal.', 'LEC04', 'CON03'),
('EJE42', 'Subject Pronouns and To Be', 'Elephants ___ large animals.', 'LEC04', 'CON03'),
('EJE43', 'Mixed Animal Descriptions', 'A dolphin is a mammal. ___ lives in the ocean.', 'LEC04', 'CON03'),
('EJE44', 'Identify the Animal', 'Listen to the audio and identify the animal being described.', 'LEC04', 'CON04'),
('EJE45', 'Animal Characteristics', 'Listen to the description and select the animal that matches its characteristics.', 'LEC04', 'CON04'),
('EJE46', 'True or False - Animals', 'Listen to the statement: A dolphin is a mammal. Is the statement true or false?', 'LEC04', 'CON04'),
('EJE47', 'Describe Your Favorite Animal', 'Say: My favorite animal is a rabbit. It is small and cute. It has long ears.', 'LEC04', 'CON05'),
('EJE48', 'Compare Two Animals', 'Say: A dolphin is a mammal, but a penguin is a bird.', 'LEC04', 'CON05');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ejercicio_opcion`
--

CREATE TABLE `ejercicio_opcion` (
  `ejercicio` varchar(5) NOT NULL,
  `opcion` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ejercicio_opcion`
--

INSERT INTO `ejercicio_opcion` (`ejercicio`, `opcion`) VALUES
('EJE27', 'OP081'),
('EJE27', 'OP082'),
('EJE27', 'OP083'),
('EJE27', 'OP084'),
('EJE03', 'OP085'),
('EJE03', 'OP086'),
('EJE03', 'OP087'),
('EJE03', 'OP088'),
('EJE28', 'OP089'),
('EJE28', 'OP090'),
('EJE28', 'OP091'),
('EJE28', 'OP092'),
('EJE29', 'OP093'),
('EJE29', 'OP094'),
('EJE29', 'OP095'),
('EJE29', 'OP096'),
('EJE30', 'OP097'),
('EJE30', 'OP098'),
('EJE30', 'OP099'),
('EJE30', 'OP100'),
('EJE31', 'OP101'),
('EJE31', 'OP102'),
('EJE31', 'OP103'),
('EJE31', 'OP104'),
('EJE32', 'OP105'),
('EJE32', 'OP106'),
('EJE32', 'OP107'),
('EJE32', 'OP108'),
('EJE33', 'OP109'),
('EJE33', 'OP110'),
('EJE33', 'OP111'),
('EJE33', 'OP112'),
('EJE34', 'OP113'),
('EJE34', 'OP114'),
('EJE34', 'OP115'),
('EJE34', 'OP116'),
('EJE37', 'OP117'),
('EJE37', 'OP118'),
('EJE37', 'OP119'),
('EJE37', 'OP120'),
('EJE04', 'OP121'),
('EJE04', 'OP122'),
('EJE04', 'OP123'),
('EJE04', 'OP124'),
('EJE38', 'OP125'),
('EJE38', 'OP126'),
('EJE38', 'OP127'),
('EJE38', 'OP128'),
('EJE39', 'OP129'),
('EJE39', 'OP130'),
('EJE39', 'OP131'),
('EJE39', 'OP132'),
('EJE40', 'OP133'),
('EJE40', 'OP134'),
('EJE40', 'OP135'),
('EJE40', 'OP136'),
('EJE41', 'OP137'),
('EJE41', 'OP138'),
('EJE41', 'OP139'),
('EJE41', 'OP140'),
('EJE42', 'OP141'),
('EJE42', 'OP142'),
('EJE42', 'OP143'),
('EJE42', 'OP144'),
('EJE43', 'OP145'),
('EJE43', 'OP146'),
('EJE43', 'OP147'),
('EJE43', 'OP148'),
('EJE44', 'OP149'),
('EJE44', 'OP150'),
('EJE44', 'OP151'),
('EJE44', 'OP152'),
('EJE45', 'OP153'),
('EJE45', 'OP154'),
('EJE45', 'OP155'),
('EJE45', 'OP156'),
('EJE46', 'OP157'),
('EJE46', 'OP158'),
('EJE46', 'OP159'),
('EJE46', 'OP160'),
('EJE01', 'OPC01'),
('EJE01', 'OPC02'),
('EJE01', 'OPC03'),
('EJE01', 'OPC04'),
('EJE05', 'OPC05'),
('EJE05', 'OPC06'),
('EJE05', 'OPC07'),
('EJE05', 'OPC08'),
('EJE06', 'OPC09'),
('EJE06', 'OPC10'),
('EJE06', 'OPC11'),
('EJE06', 'OPC12'),
('EJE07', 'OPC13'),
('EJE07', 'OPC14'),
('EJE07', 'OPC15'),
('EJE07', 'OPC16'),
('EJE08', 'OPC17'),
('EJE08', 'OPC18'),
('EJE08', 'OPC19'),
('EJE08', 'OPC20'),
('EJE09', 'OPC21'),
('EJE09', 'OPC22'),
('EJE09', 'OPC23'),
('EJE09', 'OPC24'),
('EJE10', 'OPC25'),
('EJE10', 'OPC26'),
('EJE10', 'OPC27'),
('EJE10', 'OPC28'),
('EJE11', 'OPC29'),
('EJE11', 'OPC30'),
('EJE11', 'OPC31'),
('EJE11', 'OPC32'),
('EJE12', 'OPC33'),
('EJE12', 'OPC34'),
('EJE12', 'OPC35'),
('EJE12', 'OPC36'),
('EJE02', 'OPC37'),
('EJE02', 'OPC38'),
('EJE02', 'OPC39'),
('EJE02', 'OPC40'),
('EJE15', 'OPC41'),
('EJE15', 'OPC42'),
('EJE15', 'OPC43'),
('EJE15', 'OPC44'),
('EJE16', 'OPC45'),
('EJE16', 'OPC46'),
('EJE16', 'OPC47'),
('EJE16', 'OPC48'),
('EJE17', 'OPC49'),
('EJE17', 'OPC50'),
('EJE17', 'OPC51'),
('EJE17', 'OPC52'),
('EJE18', 'OPC53'),
('EJE18', 'OPC54'),
('EJE18', 'OPC55'),
('EJE18', 'OPC56'),
('EJE19', 'OPC57'),
('EJE19', 'OPC58'),
('EJE19', 'OPC59'),
('EJE19', 'OPC60'),
('EJE20', 'OPC61'),
('EJE20', 'OPC62'),
('EJE20', 'OPC63'),
('EJE20', 'OPC64'),
('EJE21', 'OPC65'),
('EJE21', 'OPC66'),
('EJE21', 'OPC67'),
('EJE21', 'OPC68'),
('EJE22', 'OPC69'),
('EJE22', 'OPC70'),
('EJE22', 'OPC71'),
('EJE22', 'OPC72'),
('EJE23', 'OPC73'),
('EJE23', 'OPC74'),
('EJE23', 'OPC75'),
('EJE23', 'OPC76'),
('EJE26', 'OPC77'),
('EJE26', 'OPC78'),
('EJE26', 'OPC79'),
('EJE26', 'OPC80');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_opcion`
--

CREATE TABLE `estado_opcion` (
  `clave` varchar(5) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado_opcion`
--

INSERT INTO `estado_opcion` (`clave`, `nombre`, `descripcion`) VALUES
('EST01', 'Correct', 'The option is the correct answer.'),
('EST02', 'Incorrect', 'The option is an incorrect answer.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupo`
--

CREATE TABLE `grupo` (
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `fechaCreacion` date NOT NULL,
  `ciclo` varchar(100) NOT NULL,
  `profesor` varchar(10) NOT NULL,
  `codigo_union` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `grupo`
--

INSERT INTO `grupo` (`codigo`, `nombre`, `fechaCreacion`, `ciclo`, `profesor`, `codigo_union`) VALUES
('8OOP75', 'Grupo B - EII', '2026-09-28', 'C2', 'PROF01', '8OOP75'),
('C7FOX6', 'Grupo A - IRD', '2026-09-28', 'A1', 'PROF01', 'C7FOX6'),
('GRP34875', 'Grupo A - DSM', '2026-10-14', 'C1', 'PROF03', 'TM5W07'),
('GRU01', 'Grupo A - EII', '2026-07-15', 'Aug-Dec 2026', 'PROF01', 'GRU01'),
('GRU02', 'Grupo B - EII', '2026-07-15', 'Aug-Dec 2026', 'PROF02', 'GRU02'),
('GRU03', 'Grupo A - PP', '2026-07-16', 'Aug-Dec 2026', 'PROF03', 'GRU03'),
('GRU04', 'Grupo B - PP', '2026-07-16', 'Aug-Dec 2026', 'PROF04', 'GRU04'),
('GRU05', 'Grupo A - OLCE', '2026-07-17', 'Aug-Dec 2026', 'PROF05', 'GRU05'),
('GRU06', 'Grupo B - OLCE', '2026-07-17', 'Aug-Dec 2026', 'PROF01', 'GRU06'),
('GRU07', 'Grupo A - DSM', '2026-07-18', 'Aug-Dec 2026', 'PROF02', 'GRU07'),
('GRU08', 'Grupo B - DSM', '2026-07-18', 'Aug-Dec 2026', 'PROF03', 'GRU08'),
('GRU09', 'Grupo A - IRD', '2026-07-19', 'Aug-Dec 2026', 'PROF04', 'GRU09'),
('GRU10', 'Grupo B - IRD', '2026-07-19', 'Aug-Dec 2026', 'PROF05', 'GRU10'),
('PE1MHL', 'Group C - DSM', '2026-10-02', 'B1', 'PROF04', 'PE1MHL'),
('V8Q33X', 'Grupo A - DSM', '2026-10-13', 'C1', 'PROF02', 'V8Q33X');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupo_alumno`
--

CREATE TABLE `grupo_alumno` (
  `grupo` varchar(10) NOT NULL,
  `alumno` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `grupo_alumno`
--

INSERT INTO `grupo_alumno` (`grupo`, `alumno`) VALUES
('C7FOX6', '2026100001'),
('GRU01', '2026100001'),
('8OOP75', '2026100002'),
('GRU02', '2026100002'),
('PE1MHL', '2026100002'),
('GRU03', '2026100003'),
('GRU04', '2026100004'),
('GRU05', '2026100005'),
('GRU06', '2026100006'),
('GRU07', '2026100007'),
('GRU08', '2026100008'),
('GRU09', '2026100009'),
('GRU10', '2026100010'),
('GRP34875', '2026100011'),
('PE1MHL', '2026100011'),
('GRP34875', '2026100012'),
('V8Q33X', '2026100012');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupo_carrera`
--

CREATE TABLE `grupo_carrera` (
  `grupo` varchar(10) NOT NULL,
  `carrera` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `grupo_carrera`
--

INSERT INTO `grupo_carrera` (`grupo`, `carrera`) VALUES
('GRU07', 'DSM'),
('GRU08', 'DSM'),
('GRU01', 'EII'),
('GRU02', 'EII'),
('GRU09', 'IRD'),
('GRU10', 'IRD'),
('GRU05', 'OLCE'),
('GRU06', 'OLCE'),
('GRU03', 'PP'),
('GRU04', 'PP');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `insignia`
--

CREATE TABLE `insignia` (
  `clave` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(100) NOT NULL,
  `crit_obtencion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `insignia`
--

INSERT INTO `insignia` (`clave`, `nombre`, `descripcion`, `crit_obtencion`) VALUES
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
('INS11', 'Silver Student', 'Place in the top 2', 'Reach weekly ranking second place'),
('INS14', 'XP Collector', 'Accumulate 100 experience points', 'Reach 100 total XP'),
('INS16', 'XP Master', 'Accumulate 500 experience points', 'Reach 500 total XP'),
('INS17', 'Voice Explorer', 'Speak 50 words correctly', 'Reach 50 correctly pronounced words'),
('INS18', 'Speaking Star', 'Speak 100 words correctly', 'Reach 100 correctly pronounced words'),
('INS19', 'Voice Champion', 'Speak 500 words correctly', 'Reach 500 correctly pronounced words');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `intento_palabra`
--

CREATE TABLE `intento_palabra` (
  `clave` varchar(10) NOT NULL,
  `acertado` int(11) NOT NULL,
  `tiempo_respuesta` time NOT NULL,
  `numero_intentos` int(11) NOT NULL,
  `practica_sesion` varchar(10) NOT NULL,
  `palabra` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `intento_palabra`
--

INSERT INTO `intento_palabra` (`clave`, `acertado`, `tiempo_respuesta`, `numero_intentos`, `practica_sesion`, `palabra`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `juego`
--

CREATE TABLE `juego` (
  `clave` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `mecanica` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `juego`
--

INSERT INTO `juego` (`clave`, `nombre`, `descripcion`, `mecanica`) VALUES
('J01', 'Listen and Type', 'Audio plays and the student types the word; on a miss, the answer is shown and the audio repeats.', 'Listen and Type'),
('J02', 'Word Scramble', 'The word appears scrambled and the student reorders it.', 'Word Scramble'),
('J03', 'Hangman', 'Classic hangman with meaning or category hints.', 'Hangman'),
('J04', 'Memory', 'Match word to image, or word to meaning.', 'Memory'),
('J05', 'Typing Race', 'Words appear and vanish quickly; the student must type them in time.', 'Typing Race'),
('J06', 'Word Search', 'Auto-generated word search using the list words.', 'Word Search'),
('J07', 'Crossword', 'Auto-generated crossword using the teacher definitions.', 'Crossword'),
('J08', 'Missing Letters', 'Word with gaps that the student fills in.', 'Missing Letters'),
('J09', 'Multiple Choice', 'Audio plays and the student picks the correct word from options.', 'Multiple Choice'),
('J10', 'Image Challenge', 'An image is shown and the student types the matching word.', 'Image Challenge'),
('J11', 'Beat the Clock', 'Answer as many words as possible in 60 seconds.', 'Beat the Clock'),
('J12', 'Boss Battle', 'Final challenge combining several previous mechanics.', 'Boss Battle');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `leccion`
--

CREATE TABLE `leccion` (
  `clave` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `practica_sesion` varchar(10) NOT NULL,
  `puntaje` varchar(10) NOT NULL,
  `contenido_leccion` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `leccion`
--

INSERT INTO `leccion` (`clave`, `nombre`, `descripcion`, `practica_sesion`, `puntaje`, `contenido_leccion`) VALUES
('LEC01', 'Lesson 1 - PRA01', 'First lesson of practice PRA01.', 'PRA01', 'PUN01', 'CON01'),
('LEC02', 'Lesson 2 - PRA01', 'Second lesson of practice PRA01.', 'PRA01', 'PUN01', 'CON02'),
('LEC03', 'Lesson 3 - PRA01', 'Third lesson of practice PRA01.', 'PRA01', 'PUN01', 'CON03'),
('LEC04', 'Lesson 4 - PRA01', 'Fourth lesson of practice PRA01.', 'PRA01', 'PUN01', 'CON06'),
('LEC05', 'Lesson 1 - PRA02', 'First lesson of practice PRA02.', 'PRA02', 'PUN01', 'CON01'),
('LEC06', 'Lesson 2 - PRA02', 'Second lesson of practice PRA02.', 'PRA02', 'PUN01', 'CON02'),
('LEC07', 'Lesson 3 - PRA02', 'Third lesson of practice PRA02.', 'PRA02', 'PUN01', 'CON03'),
('LEC08', 'Lesson 4 - PRA02', 'Fourth lesson of practice PRA02.', 'PRA02', 'PUN01', 'CON06'),
('LEC09', 'Lesson 1 - PRA03', 'First lesson of practice PRA03.', 'PRA03', 'PUN01', 'CON01'),
('LEC10', 'Lesson 2 - PRA03', 'Second lesson of practice PRA03.', 'PRA03', 'PUN01', 'CON02'),
('LEC100', 'Lesson 4 - PRA25', 'Fourth lesson of practice PRA25.', 'PRA25', 'PUN01', 'CON06'),
('LEC101', 'Lesson 1 - PRA26', 'First lesson of practice PRA26.', 'PRA26', 'PUN01', 'CON01'),
('LEC102', 'Lesson 2 - PRA26', 'Second lesson of practice PRA26.', 'PRA26', 'PUN01', 'CON02'),
('LEC103', 'Lesson 3 - PRA26', 'Third lesson of practice PRA26.', 'PRA26', 'PUN01', 'CON03'),
('LEC104', 'Lesson 4 - PRA26', 'Fourth lesson of practice PRA26.', 'PRA26', 'PUN01', 'CON06'),
('LEC105', 'Lesson 1 - PRA27', 'First lesson of practice PRA27.', 'PRA27', 'PUN01', 'CON01'),
('LEC106', 'Lesson 2 - PRA27', 'Second lesson of practice PRA27.', 'PRA27', 'PUN01', 'CON02'),
('LEC107', 'Lesson 3 - PRA27', 'Third lesson of practice PRA27.', 'PRA27', 'PUN01', 'CON03'),
('LEC108', 'Lesson 4 - PRA27', 'Fourth lesson of practice PRA27.', 'PRA27', 'PUN01', 'CON06'),
('LEC109', 'Lesson 1 - PRA28', 'First lesson of practice PRA28.', 'PRA28', 'PUN01', 'CON01'),
('LEC11', 'Lesson 3 - PRA03', 'Third lesson of practice PRA03.', 'PRA03', 'PUN01', 'CON03'),
('LEC110', 'Lesson 2 - PRA28', 'Second lesson of practice PRA28.', 'PRA28', 'PUN01', 'CON02'),
('LEC111', 'Lesson 3 - PRA28', 'Third lesson of practice PRA28.', 'PRA28', 'PUN01', 'CON03'),
('LEC112', 'Lesson 4 - PRA28', 'Fourth lesson of practice PRA28.', 'PRA28', 'PUN01', 'CON06'),
('LEC113', 'Lesson 1 - PRA29', 'First lesson of practice PRA29.', 'PRA29', 'PUN01', 'CON01'),
('LEC114', 'Lesson 2 - PRA29', 'Second lesson of practice PRA29.', 'PRA29', 'PUN01', 'CON02'),
('LEC115', 'Lesson 3 - PRA29', 'Third lesson of practice PRA29.', 'PRA29', 'PUN01', 'CON03'),
('LEC116', 'Lesson 4 - PRA29', 'Fourth lesson of practice PRA29.', 'PRA29', 'PUN01', 'CON06'),
('LEC117', 'Lesson 1 - PRA30', 'First lesson of practice PRA30.', 'PRA30', 'PUN01', 'CON01'),
('LEC118', 'Lesson 2 - PRA30', 'Second lesson of practice PRA30.', 'PRA30', 'PUN01', 'CON02'),
('LEC119', 'Lesson 3 - PRA30', 'Third lesson of practice PRA30.', 'PRA30', 'PUN01', 'CON03'),
('LEC12', 'Lesson 4 - PRA03', 'Fourth lesson of practice PRA03.', 'PRA03', 'PUN01', 'CON06'),
('LEC120', 'Lesson 4 - PRA30', 'Fourth lesson of practice PRA30.', 'PRA30', 'PUN01', 'CON06'),
('LEC121', 'Lesson 1 - PRA31', 'First lesson of practice PRA31.', 'PRA31', 'PUN01', 'CON01'),
('LEC122', 'Lesson 2 - PRA31', 'Second lesson of practice PRA31.', 'PRA31', 'PUN01', 'CON02'),
('LEC123', 'Lesson 3 - PRA31', 'Third lesson of practice PRA31.', 'PRA31', 'PUN01', 'CON03'),
('LEC124', 'Lesson 4 - PRA31', 'Fourth lesson of practice PRA31.', 'PRA31', 'PUN01', 'CON06'),
('LEC125', 'Lesson 1 - PRA32', 'First lesson of practice PRA32.', 'PRA32', 'PUN01', 'CON01'),
('LEC126', 'Lesson 2 - PRA32', 'Second lesson of practice PRA32.', 'PRA32', 'PUN01', 'CON02'),
('LEC127', 'Lesson 3 - PRA32', 'Third lesson of practice PRA32.', 'PRA32', 'PUN01', 'CON03'),
('LEC128', 'Lesson 4 - PRA32', 'Fourth lesson of practice PRA32.', 'PRA32', 'PUN01', 'CON06'),
('LEC129', 'Lesson 1 - PRA33', 'First lesson of practice PRA33.', 'PRA33', 'PUN01', 'CON01'),
('LEC13', 'Lesson 1 - PRA04', 'First lesson of practice PRA04.', 'PRA04', 'PUN01', 'CON01'),
('LEC130', 'Lesson 2 - PRA33', 'Second lesson of practice PRA33.', 'PRA33', 'PUN01', 'CON02'),
('LEC131', 'Lesson 3 - PRA33', 'Third lesson of practice PRA33.', 'PRA33', 'PUN01', 'CON03'),
('LEC132', 'Lesson 4 - PRA33', 'Fourth lesson of practice PRA33.', 'PRA33', 'PUN01', 'CON06'),
('LEC133', 'Lesson 1 - PRA34', 'First lesson of practice PRA34.', 'PRA34', 'PUN01', 'CON01'),
('LEC134', 'Lesson 2 - PRA34', 'Second lesson of practice PRA34.', 'PRA34', 'PUN01', 'CON02'),
('LEC135', 'Lesson 3 - PRA34', 'Third lesson of practice PRA34.', 'PRA34', 'PUN01', 'CON03'),
('LEC136', 'Lesson 4 - PRA34', 'Fourth lesson of practice PRA34.', 'PRA34', 'PUN01', 'CON06'),
('LEC137', 'Lesson 1 - PRA35', 'First lesson of practice PRA35.', 'PRA35', 'PUN01', 'CON01'),
('LEC138', 'Lesson 2 - PRA35', 'Second lesson of practice PRA35.', 'PRA35', 'PUN01', 'CON02'),
('LEC139', 'Lesson 3 - PRA35', 'Third lesson of practice PRA35.', 'PRA35', 'PUN01', 'CON03'),
('LEC14', 'Lesson 2 - PRA04', 'Second lesson of practice PRA04.', 'PRA04', 'PUN01', 'CON02'),
('LEC140', 'Lesson 4 - PRA35', 'Fourth lesson of practice PRA35.', 'PRA35', 'PUN01', 'CON06'),
('LEC141', 'Lesson 1 - PRA36', 'First lesson of practice PRA36.', 'PRA36', 'PUN01', 'CON01'),
('LEC142', 'Lesson 2 - PRA36', 'Second lesson of practice PRA36.', 'PRA36', 'PUN01', 'CON02'),
('LEC143', 'Lesson 3 - PRA36', 'Third lesson of practice PRA36.', 'PRA36', 'PUN01', 'CON03'),
('LEC144', 'Lesson 4 - PRA36', 'Fourth lesson of practice PRA36.', 'PRA36', 'PUN01', 'CON06'),
('LEC145', 'Lesson 1 - PRA37', 'First lesson of practice PRA37.', 'PRA37', 'PUN01', 'CON01'),
('LEC146', 'Lesson 2 - PRA37', 'Second lesson of practice PRA37.', 'PRA37', 'PUN01', 'CON02'),
('LEC147', 'Lesson 3 - PRA37', 'Third lesson of practice PRA37.', 'PRA37', 'PUN01', 'CON03'),
('LEC148', 'Lesson 4 - PRA37', 'Fourth lesson of practice PRA37.', 'PRA37', 'PUN01', 'CON06'),
('LEC149', 'Lesson 1 - PRA38', 'First lesson of practice PRA38.', 'PRA38', 'PUN01', 'CON01'),
('LEC15', 'Lesson 3 - PRA04', 'Third lesson of practice PRA04.', 'PRA04', 'PUN01', 'CON03'),
('LEC150', 'Lesson 2 - PRA38', 'Second lesson of practice PRA38.', 'PRA38', 'PUN01', 'CON02'),
('LEC151', 'Lesson 3 - PRA38', 'Third lesson of practice PRA38.', 'PRA38', 'PUN01', 'CON03'),
('LEC152', 'Lesson 4 - PRA38', 'Fourth lesson of practice PRA38.', 'PRA38', 'PUN01', 'CON06'),
('LEC153', 'Lesson 1 - PRA39', 'First lesson of practice PRA39.', 'PRA39', 'PUN01', 'CON01'),
('LEC154', 'Lesson 2 - PRA39', 'Second lesson of practice PRA39.', 'PRA39', 'PUN01', 'CON02'),
('LEC155', 'Lesson 3 - PRA39', 'Third lesson of practice PRA39.', 'PRA39', 'PUN01', 'CON03'),
('LEC156', 'Lesson 4 - PRA39', 'Fourth lesson of practice PRA39.', 'PRA39', 'PUN01', 'CON06'),
('LEC157', 'Lesson 1 - PRA40', 'First lesson of practice PRA40.', 'PRA40', 'PUN01', 'CON01'),
('LEC158', 'Lesson 2 - PRA40', 'Second lesson of practice PRA40.', 'PRA40', 'PUN01', 'CON02'),
('LEC159', 'Lesson 3 - PRA40', 'Third lesson of practice PRA40.', 'PRA40', 'PUN01', 'CON03'),
('LEC16', 'Lesson 4 - PRA04', 'Fourth lesson of practice PRA04.', 'PRA04', 'PUN01', 'CON06'),
('LEC160', 'Lesson 4 - PRA40', 'Fourth lesson of practice PRA40.', 'PRA40', 'PUN01', 'CON06'),
('LEC161', 'Lesson 1 - PRA41', 'First lesson of practice PRA41.', 'PRA41', 'PUN01', 'CON01'),
('LEC162', 'Lesson 2 - PRA41', 'Second lesson of practice PRA41.', 'PRA41', 'PUN01', 'CON02'),
('LEC163', 'Lesson 3 - PRA41', 'Third lesson of practice PRA41.', 'PRA41', 'PUN01', 'CON03'),
('LEC164', 'Lesson 4 - PRA41', 'Fourth lesson of practice PRA41.', 'PRA41', 'PUN01', 'CON06'),
('LEC165', 'Lesson 1 - PRA42', 'First lesson of practice PRA42.', 'PRA42', 'PUN01', 'CON01'),
('LEC166', 'Lesson 2 - PRA42', 'Second lesson of practice PRA42.', 'PRA42', 'PUN01', 'CON02'),
('LEC167', 'Lesson 3 - PRA42', 'Third lesson of practice PRA42.', 'PRA42', 'PUN01', 'CON03'),
('LEC168', 'Lesson 4 - PRA42', 'Fourth lesson of practice PRA42.', 'PRA42', 'PUN01', 'CON06'),
('LEC169', 'Lesson 1 - PRA43', 'First lesson of practice PRA43.', 'PRA43', 'PUN01', 'CON01'),
('LEC17', 'Lesson 1 - PRA05', 'First lesson of practice PRA05.', 'PRA05', 'PUN01', 'CON01'),
('LEC170', 'Lesson 2 - PRA43', 'Second lesson of practice PRA43.', 'PRA43', 'PUN01', 'CON02'),
('LEC171', 'Lesson 3 - PRA43', 'Third lesson of practice PRA43.', 'PRA43', 'PUN01', 'CON03'),
('LEC172', 'Lesson 4 - PRA43', 'Fourth lesson of practice PRA43.', 'PRA43', 'PUN01', 'CON06'),
('LEC173', 'Lesson 1 - PRA44', 'First lesson of practice PRA44.', 'PRA44', 'PUN01', 'CON01'),
('LEC174', 'Lesson 2 - PRA44', 'Second lesson of practice PRA44.', 'PRA44', 'PUN01', 'CON02'),
('LEC175', 'Lesson 3 - PRA44', 'Third lesson of practice PRA44.', 'PRA44', 'PUN01', 'CON03'),
('LEC176', 'Lesson 4 - PRA44', 'Fourth lesson of practice PRA44.', 'PRA44', 'PUN01', 'CON06'),
('LEC177', 'Lesson 1 - PRA45', 'First lesson of practice PRA45.', 'PRA45', 'PUN01', 'CON01'),
('LEC178', 'Lesson 2 - PRA45', 'Second lesson of practice PRA45.', 'PRA45', 'PUN01', 'CON02'),
('LEC179', 'Lesson 3 - PRA45', 'Third lesson of practice PRA45.', 'PRA45', 'PUN01', 'CON03'),
('LEC18', 'Lesson 2 - PRA05', 'Second lesson of practice PRA05.', 'PRA05', 'PUN01', 'CON02'),
('LEC180', 'Lesson 4 - PRA45', 'Fourth lesson of practice PRA45.', 'PRA45', 'PUN01', 'CON06'),
('LEC181', 'Lesson 1 - PRA46', 'First lesson of practice PRA46.', 'PRA46', 'PUN01', 'CON01'),
('LEC182', 'Lesson 2 - PRA46', 'Second lesson of practice PRA46.', 'PRA46', 'PUN01', 'CON02'),
('LEC183', 'Lesson 3 - PRA46', 'Third lesson of practice PRA46.', 'PRA46', 'PUN01', 'CON03'),
('LEC184', 'Lesson 4 - PRA46', 'Fourth lesson of practice PRA46.', 'PRA46', 'PUN01', 'CON06'),
('LEC185', 'Lesson 1 - PRA47', 'First lesson of practice PRA47.', 'PRA47', 'PUN01', 'CON01'),
('LEC186', 'Lesson 2 - PRA47', 'Second lesson of practice PRA47.', 'PRA47', 'PUN01', 'CON02'),
('LEC187', 'Lesson 3 - PRA47', 'Third lesson of practice PRA47.', 'PRA47', 'PUN01', 'CON03'),
('LEC188', 'Lesson 4 - PRA47', 'Fourth lesson of practice PRA47.', 'PRA47', 'PUN01', 'CON06'),
('LEC189', 'Lesson 1 - PRA48', 'First lesson of practice PRA48.', 'PRA48', 'PUN01', 'CON01'),
('LEC19', 'Lesson 3 - PRA05', 'Third lesson of practice PRA05.', 'PRA05', 'PUN01', 'CON03'),
('LEC190', 'Lesson 2 - PRA48', 'Second lesson of practice PRA48.', 'PRA48', 'PUN01', 'CON02'),
('LEC191', 'Lesson 3 - PRA48', 'Third lesson of practice PRA48.', 'PRA48', 'PUN01', 'CON03'),
('LEC192', 'Lesson 4 - PRA48', 'Fourth lesson of practice PRA48.', 'PRA48', 'PUN01', 'CON06'),
('LEC20', 'Lesson 4 - PRA05', 'Fourth lesson of practice PRA05.', 'PRA05', 'PUN01', 'CON06'),
('LEC21', 'Lesson 1 - PRA06', 'First lesson of practice PRA06.', 'PRA06', 'PUN01', 'CON01'),
('LEC22', 'Lesson 2 - PRA06', 'Second lesson of practice PRA06.', 'PRA06', 'PUN01', 'CON02'),
('LEC23', 'Lesson 3 - PRA06', 'Third lesson of practice PRA06.', 'PRA06', 'PUN01', 'CON03'),
('LEC24', 'Lesson 4 - PRA06', 'Fourth lesson of practice PRA06.', 'PRA06', 'PUN01', 'CON06'),
('LEC25', 'Lesson 1 - PRA07', 'First lesson of practice PRA07.', 'PRA07', 'PUN01', 'CON01'),
('LEC26', 'Lesson 2 - PRA07', 'Second lesson of practice PRA07.', 'PRA07', 'PUN01', 'CON02'),
('LEC27', 'Lesson 3 - PRA07', 'Third lesson of practice PRA07.', 'PRA07', 'PUN01', 'CON03'),
('LEC28', 'Lesson 4 - PRA07', 'Fourth lesson of practice PRA07.', 'PRA07', 'PUN01', 'CON06'),
('LEC29', 'Lesson 1 - PRA08', 'First lesson of practice PRA08.', 'PRA08', 'PUN01', 'CON01'),
('LEC30', 'Lesson 2 - PRA08', 'Second lesson of practice PRA08.', 'PRA08', 'PUN01', 'CON02'),
('LEC31', 'Lesson 3 - PRA08', 'Third lesson of practice PRA08.', 'PRA08', 'PUN01', 'CON03'),
('LEC32', 'Lesson 4 - PRA08', 'Fourth lesson of practice PRA08.', 'PRA08', 'PUN01', 'CON06'),
('LEC33', 'Lesson 1 - PRA09', 'First lesson of practice PRA09.', 'PRA09', 'PUN01', 'CON01'),
('LEC34', 'Lesson 2 - PRA09', 'Second lesson of practice PRA09.', 'PRA09', 'PUN01', 'CON02'),
('LEC35', 'Lesson 3 - PRA09', 'Third lesson of practice PRA09.', 'PRA09', 'PUN01', 'CON03'),
('LEC36', 'Lesson 4 - PRA09', 'Fourth lesson of practice PRA09.', 'PRA09', 'PUN01', 'CON06'),
('LEC37', 'Lesson 1 - PRA10', 'First lesson of practice PRA10.', 'PRA10', 'PUN01', 'CON01'),
('LEC38', 'Lesson 2 - PRA10', 'Second lesson of practice PRA10.', 'PRA10', 'PUN01', 'CON02'),
('LEC39', 'Lesson 3 - PRA10', 'Third lesson of practice PRA10.', 'PRA10', 'PUN01', 'CON03'),
('LEC40', 'Lesson 4 - PRA10', 'Fourth lesson of practice PRA10.', 'PRA10', 'PUN01', 'CON06'),
('LEC41', 'Lesson 1 - PRA11', 'First lesson of practice PRA11.', 'PRA11', 'PUN01', 'CON01'),
('LEC42', 'Lesson 2 - PRA11', 'Second lesson of practice PRA11.', 'PRA11', 'PUN01', 'CON02'),
('LEC43', 'Lesson 3 - PRA11', 'Third lesson of practice PRA11.', 'PRA11', 'PUN01', 'CON03'),
('LEC44', 'Lesson 4 - PRA11', 'Fourth lesson of practice PRA11.', 'PRA11', 'PUN01', 'CON06'),
('LEC45', 'Lesson 1 - PRA12', 'First lesson of practice PRA12.', 'PRA12', 'PUN01', 'CON01'),
('LEC46', 'Lesson 2 - PRA12', 'Second lesson of practice PRA12.', 'PRA12', 'PUN01', 'CON02'),
('LEC47', 'Lesson 3 - PRA12', 'Third lesson of practice PRA12.', 'PRA12', 'PUN01', 'CON03'),
('LEC48', 'Lesson 4 - PRA12', 'Fourth lesson of practice PRA12.', 'PRA12', 'PUN01', 'CON06'),
('LEC49', 'Lesson 1 - PRA13', 'First lesson of practice PRA13.', 'PRA13', 'PUN01', 'CON01'),
('LEC50', 'Lesson 2 - PRA13', 'Second lesson of practice PRA13.', 'PRA13', 'PUN01', 'CON02'),
('LEC51', 'Lesson 3 - PRA13', 'Third lesson of practice PRA13.', 'PRA13', 'PUN01', 'CON03'),
('LEC52', 'Lesson 4 - PRA13', 'Fourth lesson of practice PRA13.', 'PRA13', 'PUN01', 'CON06'),
('LEC53', 'Lesson 1 - PRA14', 'First lesson of practice PRA14.', 'PRA14', 'PUN01', 'CON01'),
('LEC54', 'Lesson 2 - PRA14', 'Second lesson of practice PRA14.', 'PRA14', 'PUN01', 'CON02'),
('LEC55', 'Lesson 3 - PRA14', 'Third lesson of practice PRA14.', 'PRA14', 'PUN01', 'CON03'),
('LEC56', 'Lesson 4 - PRA14', 'Fourth lesson of practice PRA14.', 'PRA14', 'PUN01', 'CON06'),
('LEC57', 'Lesson 1 - PRA15', 'First lesson of practice PRA15.', 'PRA15', 'PUN01', 'CON01'),
('LEC58', 'Lesson 2 - PRA15', 'Second lesson of practice PRA15.', 'PRA15', 'PUN01', 'CON02'),
('LEC59', 'Lesson 3 - PRA15', 'Third lesson of practice PRA15.', 'PRA15', 'PUN01', 'CON03'),
('LEC60', 'Lesson 4 - PRA15', 'Fourth lesson of practice PRA15.', 'PRA15', 'PUN01', 'CON06'),
('LEC61', 'Lesson 1 - PRA16', 'First lesson of practice PRA16.', 'PRA16', 'PUN01', 'CON01'),
('LEC62', 'Lesson 2 - PRA16', 'Second lesson of practice PRA16.', 'PRA16', 'PUN01', 'CON02'),
('LEC63', 'Lesson 3 - PRA16', 'Third lesson of practice PRA16.', 'PRA16', 'PUN01', 'CON03'),
('LEC64', 'Lesson 4 - PRA16', 'Fourth lesson of practice PRA16.', 'PRA16', 'PUN01', 'CON06'),
('LEC65', 'Lesson 1 - PRA17', 'First lesson of practice PRA17.', 'PRA17', 'PUN01', 'CON01'),
('LEC66', 'Lesson 2 - PRA17', 'Second lesson of practice PRA17.', 'PRA17', 'PUN01', 'CON02'),
('LEC67', 'Lesson 3 - PRA17', 'Third lesson of practice PRA17.', 'PRA17', 'PUN01', 'CON03'),
('LEC68', 'Lesson 4 - PRA17', 'Fourth lesson of practice PRA17.', 'PRA17', 'PUN01', 'CON06'),
('LEC69', 'Lesson 1 - PRA18', 'First lesson of practice PRA18.', 'PRA18', 'PUN01', 'CON01'),
('LEC70', 'Lesson 2 - PRA18', 'Second lesson of practice PRA18.', 'PRA18', 'PUN01', 'CON02'),
('LEC71', 'Lesson 3 - PRA18', 'Third lesson of practice PRA18.', 'PRA18', 'PUN01', 'CON03'),
('LEC72', 'Lesson 4 - PRA18', 'Fourth lesson of practice PRA18.', 'PRA18', 'PUN01', 'CON06'),
('LEC73', 'Lesson 1 - PRA19', 'First lesson of practice PRA19.', 'PRA19', 'PUN01', 'CON01'),
('LEC74', 'Lesson 2 - PRA19', 'Second lesson of practice PRA19.', 'PRA19', 'PUN01', 'CON02'),
('LEC75', 'Lesson 3 - PRA19', 'Third lesson of practice PRA19.', 'PRA19', 'PUN01', 'CON03'),
('LEC76', 'Lesson 4 - PRA19', 'Fourth lesson of practice PRA19.', 'PRA19', 'PUN01', 'CON06'),
('LEC77', 'Lesson 1 - PRA20', 'First lesson of practice PRA20.', 'PRA20', 'PUN01', 'CON01'),
('LEC78', 'Lesson 2 - PRA20', 'Second lesson of practice PRA20.', 'PRA20', 'PUN01', 'CON02'),
('LEC79', 'Lesson 3 - PRA20', 'Third lesson of practice PRA20.', 'PRA20', 'PUN01', 'CON03'),
('LEC80', 'Lesson 4 - PRA20', 'Fourth lesson of practice PRA20.', 'PRA20', 'PUN01', 'CON06'),
('LEC81', 'Lesson 1 - PRA21', 'First lesson of practice PRA21.', 'PRA21', 'PUN01', 'CON01'),
('LEC82', 'Lesson 2 - PRA21', 'Second lesson of practice PRA21.', 'PRA21', 'PUN01', 'CON02'),
('LEC83', 'Lesson 3 - PRA21', 'Third lesson of practice PRA21.', 'PRA21', 'PUN01', 'CON03'),
('LEC84', 'Lesson 4 - PRA21', 'Fourth lesson of practice PRA21.', 'PRA21', 'PUN01', 'CON06'),
('LEC85', 'Lesson 1 - PRA22', 'First lesson of practice PRA22.', 'PRA22', 'PUN01', 'CON01'),
('LEC86', 'Lesson 2 - PRA22', 'Second lesson of practice PRA22.', 'PRA22', 'PUN01', 'CON02'),
('LEC87', 'Lesson 3 - PRA22', 'Third lesson of practice PRA22.', 'PRA22', 'PUN01', 'CON03'),
('LEC88', 'Lesson 4 - PRA22', 'Fourth lesson of practice PRA22.', 'PRA22', 'PUN01', 'CON06'),
('LEC89', 'Lesson 1 - PRA23', 'First lesson of practice PRA23.', 'PRA23', 'PUN01', 'CON01'),
('LEC90', 'Lesson 2 - PRA23', 'Second lesson of practice PRA23.', 'PRA23', 'PUN01', 'CON02'),
('LEC91', 'Lesson 3 - PRA23', 'Third lesson of practice PRA23.', 'PRA23', 'PUN01', 'CON03'),
('LEC92', 'Lesson 4 - PRA23', 'Fourth lesson of practice PRA23.', 'PRA23', 'PUN01', 'CON06'),
('LEC93', 'Lesson 1 - PRA24', 'First lesson of practice PRA24.', 'PRA24', 'PUN01', 'CON01'),
('LEC94', 'Lesson 2 - PRA24', 'Second lesson of practice PRA24.', 'PRA24', 'PUN01', 'CON02'),
('LEC95', 'Lesson 3 - PRA24', 'Third lesson of practice PRA24.', 'PRA24', 'PUN01', 'CON03'),
('LEC96', 'Lesson 4 - PRA24', 'Fourth lesson of practice PRA24.', 'PRA24', 'PUN01', 'CON06'),
('LEC97', 'Lesson 1 - PRA25', 'First lesson of practice PRA25.', 'PRA25', 'PUN01', 'CON01'),
('LEC98', 'Lesson 2 - PRA25', 'Second lesson of practice PRA25.', 'PRA25', 'PUN01', 'CON02'),
('LEC99', 'Lesson 3 - PRA25', 'Third lesson of practice PRA25.', 'PRA25', 'PUN01', 'CON03');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `leccion_palabra`
--

CREATE TABLE `leccion_palabra` (
  `leccion` varchar(10) NOT NULL,
  `palabra` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `leccion_palabra`
--

INSERT INTO `leccion_palabra` (`leccion`, `palabra`) VALUES
('LEC02', 'PAL0002'),
('LEC03', 'PAL0002'),
('LEC04', 'PAL0002'),
('LEC02', 'PAL0011'),
('LEC03', 'PAL0011'),
('LEC04', 'PAL0011'),
('LEC02', 'PAL0012'),
('LEC03', 'PAL0012'),
('LEC04', 'PAL0012'),
('LEC02', 'PAL0013'),
('LEC03', 'PAL0013'),
('LEC04', 'PAL0013'),
('LEC02', 'PAL0014'),
('LEC03', 'PAL0014'),
('LEC04', 'PAL0014'),
('LEC02', 'PAL0015'),
('LEC03', 'PAL0015'),
('LEC04', 'PAL0015'),
('LEC01', 'PAL0902'),
('LEC01', 'PAL0905'),
('LEC01', 'PAL0906'),
('LEC01', 'PAL0907'),
('LEC01', 'PAL0908'),
('LEC01', 'PAL0909'),
('LEC01', 'PAL0910'),
('LEC01', 'PAL0911'),
('LEC01', 'PAL0912'),
('LEC01', 'PAL0913'),
('LEC01', 'PAL0914'),
('LEC01', 'PAL0915'),
('LEC01', 'PAL0916'),
('LEC01', 'PAL0917'),
('LEC01', 'PAL0918'),
('LEC01', 'PAL0919'),
('LEC01', 'PAL0920');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista`
--

CREATE TABLE `lista` (
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `fecha_asignacion` date NOT NULL,
  `fecha_limite` date DEFAULT NULL,
  `numero_letras` int(11) NOT NULL,
  `profesor` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `lista`
--

INSERT INTO `lista` (`codigo`, `nombre`, `fecha_asignacion`, `fecha_limite`, `numero_letras`, `profesor`) VALUES
('LIS01', 'Animals', '2026-08-01', '2026-08-15', 6, 'PROF01'),
('LIS02', 'Food', '2026-08-04', '2026-08-18', 6, 'PROF02'),
('LIS03', 'Colors', '2026-08-07', '2026-08-21', 6, 'PROF03'),
('LIS04', 'Family', '2026-08-10', '2026-08-24', 6, 'PROF04'),
('LIS05', 'School', '2026-08-13', '2026-08-27', 6, 'PROF05'),
('LIS06', 'Sports', '2026-08-16', '2026-08-30', 6, 'PROF01'),
('LIS07', 'Nature', '2026-08-16', '2026-09-02', 6, 'PROF02'),
('LIS08', 'Technology', '2026-08-16', '2026-09-05', 6, 'PROF03'),
('LIS09', 'Feelings', '2026-08-16', '2026-09-08', 6, 'PROF04'),
('LIS10', 'Vehicles', '2026-08-16', '2026-09-11', 6, 'PROF05'),
('LIS11', 'Greetings', '2026-10-16', NULL, 13, 'PROF04'),
('LIS12', 'Daily Routines', '2026-10-16', NULL, 9, 'PROF01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_competencia`
--

CREATE TABLE `lista_competencia` (
  `lista` varchar(10) NOT NULL,
  `competencia` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `lista_competencia`
--

INSERT INTO `lista_competencia` (`lista`, `competencia`) VALUES
('LIS01', 'COM01'),
('LIS02', 'COM02'),
('LIS03', 'COM03'),
('LIS04', 'COM04'),
('LIS05', 'COM05'),
('LIS06', 'COM06'),
('LIS09', 'COM07'),
('LIS09', 'COM08'),
('LIS04', 'COM09'),
('LIS01', 'COM10'),
('LIS07', 'COM11'),
('LIS08', 'COM12');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_grupo`
--

CREATE TABLE `lista_grupo` (
  `lista` varchar(10) NOT NULL,
  `grupo` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `lista_grupo`
--

INSERT INTO `lista_grupo` (`lista`, `grupo`) VALUES
('LIS12', '8OOP75'),
('LIS01', 'C7FOX6'),
('LIS08', 'GRP34875'),
('LIS06', 'GRU01'),
('LIS02', 'GRU02'),
('LIS03', 'GRU03'),
('LIS04', 'GRU04'),
('LIS05', 'GRU05'),
('LIS07', 'GRU07'),
('LIS09', 'GRU09'),
('LIS10', 'GRU10'),
('LIS11', 'PE1MHL');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_leccion`
--

CREATE TABLE `lista_leccion` (
  `lista` varchar(10) NOT NULL,
  `leccion` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `lista_leccion`
--

INSERT INTO `lista_leccion` (`lista`, `leccion`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista_palabra`
--

CREATE TABLE `lista_palabra` (
  `lista` varchar(10) NOT NULL,
  `palabra` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `lista_palabra`
--

INSERT INTO `lista_palabra` (`lista`, `palabra`) VALUES
('LIS02', 'PAL0001'),
('LIS01', 'PAL0002'),
('LIS03', 'PAL0003'),
('LIS04', 'PAL0004'),
('LIS05', 'PAL0005'),
('LIS06', 'PAL0006'),
('LIS07', 'PAL0007'),
('LIS08', 'PAL0008'),
('LIS09', 'PAL0009'),
('LIS10', 'PAL0010'),
('LIS01', 'PAL0011'),
('LIS01', 'PAL0012'),
('LIS01', 'PAL0013'),
('LIS01', 'PAL0014'),
('LIS01', 'PAL0015'),
('LIS02', 'PAL0016'),
('LIS02', 'PAL0017'),
('LIS02', 'PAL0018'),
('LIS02', 'PAL0019'),
('LIS02', 'PAL0020'),
('LIS03', 'PAL0021'),
('LIS03', 'PAL0022'),
('LIS03', 'PAL0023'),
('LIS03', 'PAL0024'),
('LIS03', 'PAL0025'),
('LIS04', 'PAL0026'),
('LIS04', 'PAL0027'),
('LIS04', 'PAL0028'),
('LIS04', 'PAL0029'),
('LIS04', 'PAL0030'),
('LIS05', 'PAL0031'),
('LIS05', 'PAL0032'),
('LIS05', 'PAL0033'),
('LIS05', 'PAL0034'),
('LIS05', 'PAL0035'),
('LIS06', 'PAL0036'),
('LIS06', 'PAL0037'),
('LIS06', 'PAL0038'),
('LIS06', 'PAL0039'),
('LIS06', 'PAL0040'),
('LIS07', 'PAL0041'),
('LIS07', 'PAL0042'),
('LIS07', 'PAL0043'),
('LIS07', 'PAL0044'),
('LIS07', 'PAL0045'),
('LIS08', 'PAL0046'),
('LIS08', 'PAL0047'),
('LIS08', 'PAL0048'),
('LIS08', 'PAL0049'),
('LIS08', 'PAL0050'),
('LIS09', 'PAL0051'),
('LIS09', 'PAL0052'),
('LIS09', 'PAL0053'),
('LIS09', 'PAL0054'),
('LIS09', 'PAL0055'),
('LIS10', 'PAL0056'),
('LIS10', 'PAL0057'),
('LIS10', 'PAL0058'),
('LIS10', 'PAL0059'),
('LIS10', 'PAL0060'),
('LIS11', 'PAL0902'),
('LIS12', 'PAL0903'),
('LIS12', 'PAL0904'),
('LIS11', 'PAL0905'),
('LIS11', 'PAL0906'),
('LIS11', 'PAL0907'),
('LIS11', 'PAL0908'),
('LIS11', 'PAL0909');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nivel`
--

CREATE TABLE `nivel` (
  `codigo` varchar(2) NOT NULL,
  `descripcion` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `nivel`
--

INSERT INTO `nivel` (`codigo`, `descripcion`) VALUES
('A1', 'Beginner level - basic everyday vocabulary'),
('A2', 'Basic level - frequent phrases and expressions'),
('B1', 'Intermediate level - familiar and interesting topics'),
('B2', 'Upper-intermediate level - complex and technical texts'),
('C1', 'Advanced level - flexible and effective use of the language'),
('C2', 'Proficiency level - virtually complete comprehension');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificacion`
--

CREATE TABLE `notificacion` (
  `id` int(11) NOT NULL,
  `alumno` varchar(10) NOT NULL,
  `tipo` varchar(30) NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `mensaje` varchar(255) NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  `leida` tinyint(1) NOT NULL DEFAULT 0,
  `competencia` varchar(10) DEFAULT NULL,
  `insignia` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `notificacion`
--

INSERT INTO `notificacion` (`id`, `alumno`, `tipo`, `titulo`, `mensaje`, `fecha_creacion`, `leida`, `competencia`, `insignia`) VALUES
(1, '2026100002', 'COMPETITION_RESULT', 'Competition Results Available!', 'Your results are ready. Open Competitions to review your performance.', '2026-10-09 10:46:12', 1, 'COM01', NULL),
(2, '2026100002', 'ACHIEVEMENT', 'New Achievement Unlocked!', 'Congratulations! You earned the 50 Correct Answers badge.', '2026-10-09 10:46:28', 1, NULL, 'INS02'),
(3, '2026100002', 'COMPETITION_RESULT', 'Results Available: Family Spelling Challenge', 'Your results for Family Spelling Challenge are available. Correct: 9, Incorrect: 1, Points: 90.', '2026-10-12 20:07:54', 1, 'COM04', NULL),
(4, '2026100011', 'COMPETITION_RESULT', 'Results Available: Food Spelling Challenge', 'Your results for Food Spelling Challenge are available. Correct: 10, Incorrect: 0, Points: 100.', '2026-10-13 16:04:57', 1, 'COM02', NULL),
(5, '2026100002', 'COMPETITION_RESULT', 'Results Available: Nature Spelling Challenge', 'Your results for Nature Spelling Challenge are available. Correct: 9, Incorrect: 1, Points: 90.', '2026-10-19 16:16:57', 1, 'COM11', NULL),
(6, '2026100012', 'COMPETITION_RESULT', 'Results Available: Tech Spelling Bee', 'Your results for Tech Spelling Bee are available. Correct: 10, Incorrect: 0, Points: 100.', '2026-10-19 16:37:35', 1, 'COM12', NULL),
(7, '2026100011', 'COMPETITION_RESULT', 'Results Available: Tech Spelling Bee', 'Your results for Tech Spelling Bee are available. Correct: 10, Incorrect: 0, Points: 100.', '2026-10-19 16:37:46', 1, 'COM12', NULL),
(8, '2026100011', 'ACHIEVEMENT', 'New Achievement: XP Collector', '(\'You earned the XP Collector\', \'Accumulate 100 experience points\')', '2026-11-09 03:00:05', 1, NULL, 'INS14');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `opcion`
--

CREATE TABLE `opcion` (
  `clave` varchar(5) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text NOT NULL,
  `estado_opcion` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `opcion`
--

INSERT INTO `opcion` (`clave`, `nombre`, `descripcion`, `estado_opcion`) VALUES
('OP081', 'The ocean', 'Correct answer.', 'EST01'),
('OP082', 'The desert', 'Incorrect answer.', 'EST02'),
('OP083', 'The forest', 'Incorrect answer.', 'EST02'),
('OP084', 'The farm', 'Incorrect answer.', 'EST02'),
('OP085', 'Is a dolphin a mammal?', 'Correct question structure.', 'EST01'),
('OP086', 'A dolphin is a mammal?', 'Incorrect question structure.', 'EST02'),
('OP087', 'Are a dolphin a mammal?', 'Incorrect verb agreement.', 'EST02'),
('OP088', 'Is a dolphin are mammal?', 'Incorrect grammatical structure.', 'EST02'),
('OP089', 'Yes, it is.', 'Correct short answer.', 'EST01'),
('OP090', 'Yes, it are.', 'Incorrect verb form.', 'EST02'),
('OP091', 'Yes, they is.', 'Incorrect pronoun and verb agreement.', 'EST02'),
('OP092', 'Yes, it am.', 'Incorrect verb form.', 'EST02'),
('OP093', 'Are elephants large animals?', 'Correct question structure.', 'EST01'),
('OP094', 'Elephants are large animals?', 'Incorrect question structure.', 'EST02'),
('OP095', 'Is elephants large animals?', 'Incorrect verb agreement.', 'EST02'),
('OP096', 'Are elephants is large animals?', 'Incorrect grammatical structure.', 'EST02'),
('OP097', 'They', 'Correct subject pronoun for multiple animals.', 'EST01'),
('OP098', 'It', 'Incorrect pronoun for multiple animals.', 'EST02'),
('OP099', 'He', 'Incorrect pronoun for multiple animals.', 'EST02'),
('OP100', 'She', 'Incorrect pronoun for multiple animals.', 'EST02'),
('OP101', 'A tiger is a wild animal.', 'Correct sentence.', 'EST01'),
('OP102', 'A tiger are a wild animal.', 'Incorrect verb agreement.', 'EST02'),
('OP103', 'A tiger am a wild animal.', 'Incorrect verb form.', 'EST02'),
('OP104', 'A tiger be a wild animal.', 'Incorrect verb form.', 'EST02'),
('OP105', 'Penguin', 'Correct answer.', 'EST01'),
('OP106', 'Tiger', 'Incorrect answer.', 'EST02'),
('OP107', 'Monkey', 'Incorrect answer.', 'EST02'),
('OP108', 'Rabbit', 'Incorrect answer.', 'EST02'),
('OP109', 'It can swim.', 'Correct answer.', 'EST01'),
('OP110', 'It can fly.', 'Incorrect answer.', 'EST02'),
('OP111', 'It lives in trees.', 'Incorrect answer.', 'EST02'),
('OP112', 'It has four legs.', 'Incorrect answer.', 'EST02'),
('OP113', 'No, it is not.', 'Correct short answer.', 'EST01'),
('OP114', 'Yes, it are.', 'Incorrect verb form.', 'EST02'),
('OP115', 'No, they is not.', 'Incorrect pronoun and verb agreement.', 'EST02'),
('OP116', 'Yes, it am.', 'Incorrect verb form.', 'EST02'),
('OP117', 'They are wild animals.', 'Correct sentence using a plural subject pronoun.', 'EST01'),
('OP118', 'They is wild animals.', 'Incorrect verb agreement.', 'EST02'),
('OP119', 'It are wild animals.', 'Incorrect pronoun and verb agreement.', 'EST02'),
('OP120', 'They am wild animals.', 'Incorrect verb form.', 'EST02'),
('OP121', 'Correct Answer', 'They are wild animals.', 'EST01'),
('OP122', 'Incorrect Answer 1', 'It is a domestic animal.', 'EST02'),
('OP123', 'Incorrect Answer 2', 'They lives in the ocean.', 'EST02'),
('OP124', 'Incorrect Answer 3', 'It are a mammal.', 'EST02'),
('OP125', 'Dolphin', 'Correct Answer', 'EST01'),
('OP126', 'Penguin', 'Incorrect Answer 1', 'EST02'),
('OP127', 'Tiger', 'Incorrect Answer 2', 'EST02'),
('OP128', 'Monkey', 'Incorrect Answer 3', 'EST02'),
('OP129', 'They', 'Correct Answer', 'EST01'),
('OP130', 'It', 'Incorrect Answer 1', 'EST02'),
('OP131', 'He', 'Incorrect Answer 2', 'EST02'),
('OP132', 'She', 'Incorrect Answer 3', 'EST02'),
('OP133', 'is', 'Correct Answer', 'EST01'),
('OP134', 'are', 'Incorrect Answer 1', 'EST02'),
('OP135', 'am', 'Incorrect Answer 2', 'EST02'),
('OP136', 'be', 'Incorrect Answer 3', 'EST02'),
('OP137', 'is not', 'Correct Answer', 'EST01'),
('OP138', 'are not', 'Incorrect Answer 1', 'EST02'),
('OP139', 'am not', 'Incorrect Answer 2', 'EST02'),
('OP140', 'is', 'Incorrect Answer 3', 'EST02'),
('OP141', 'are', 'Correct Answer', 'EST01'),
('OP142', 'is', 'Incorrect Answer 1', 'EST02'),
('OP143', 'am', 'Incorrect Answer 2', 'EST02'),
('OP144', 'be', 'Incorrect Answer 3', 'EST02'),
('OP145', 'It', 'Correct Answer', 'EST01'),
('OP146', 'They', 'Incorrect Answer 1', 'EST02'),
('OP147', 'He', 'Incorrect Answer 2', 'EST02'),
('OP148', 'She', 'Incorrect Answer 3', 'EST02'),
('OP149', 'Dolphin', 'Correct Answer', 'EST01'),
('OP150', 'Tiger', 'Incorrect Answer 1', 'EST02'),
('OP151', 'Rabbit', 'Incorrect Answer 2', 'EST02'),
('OP152', 'Elephant', 'Incorrect Answer 3', 'EST02'),
('OP153', 'It can swim and has flippers.', 'Correct Answer', 'EST01'),
('OP154', 'It can fly and has feathers.', 'Incorrect Answer 1', 'EST02'),
('OP155', 'It lives in trees.', 'Incorrect Answer 2', 'EST02'),
('OP156', 'It has four legs and stripes.', 'Incorrect Answer 3', 'EST02'),
('OP157', 'True', 'Correct Answer', 'EST01'),
('OP158', 'False', 'Incorrect Answer 1', 'EST02'),
('OP159', 'Not mentioned', 'Incorrect Answer 2', 'EST02'),
('OP160', 'Both are correct', 'Incorrect Answer 3', 'EST02'),
('OPC01', 'Correct Answer', 'The option represents the correct answer.', 'EST01'),
('OPC02', 'Incorrect Answer 1', 'The option represents an incorrect answer.', 'EST02'),
('OPC03', 'Incorrect Answer 2', 'The option represents an incorrect answer.', 'EST02'),
('OPC04', 'Incorrect Answer 3', 'The option represents an incorrect answer.', 'EST02'),
('OPC05', 'I', 'Correct answer.', 'EST01'),
('OPC06', 'He', 'Incorrect answer.', 'EST02'),
('OPC07', 'She', 'Incorrect answer.', 'EST02'),
('OPC08', 'They', 'Incorrect answer.', 'EST02'),
('OPC09', 'He', 'Incorrect answer.', 'EST02'),
('OPC10', 'She', 'Correct answer.', 'EST01'),
('OPC11', 'It', 'Incorrect answer.', 'EST02'),
('OPC12', 'We', 'Incorrect answer.', 'EST02'),
('OPC13', 'am', 'Incorrect answer.', 'EST02'),
('OPC14', 'is', 'Incorrect answer.', 'EST02'),
('OPC15', 'are', 'Correct answer.', 'EST01'),
('OPC16', 'be', 'Incorrect answer.', 'EST02'),
('OPC17', 'I is Omar.', 'Incorrect answer.', 'EST02'),
('OPC18', 'I am Omar.', 'Correct answer.', 'EST01'),
('OPC19', 'I are Omar.', 'Incorrect answer.', 'EST02'),
('OPC20', 'I be Omar.', 'Incorrect answer.', 'EST02'),
('OPC21', 'am', 'Incorrect answer.', 'EST02'),
('OPC22', 'are', 'Incorrect answer.', 'EST02'),
('OPC23', 'be', 'Incorrect answer.', 'EST02'),
('OPC24', 'is', 'Correct answer.', 'EST01'),
('OPC25', 'A) Good morning', 'Correct answer', 'EST01'),
('OPC26', 'B) Good night', 'Incorrect answer', 'EST02'),
('OPC27', 'C) See you', 'Incorrect answer', 'EST02'),
('OPC28', 'D) Welcome', 'Incorrect answer', 'EST02'),
('OPC29', 'A) Nice to meet you', 'Incorrect answer', 'EST02'),
('OPC30', 'B) See you later', 'Incorrect answer', 'EST02'),
('OPC31', 'C) Good afternoon', 'Incorrect answer', 'EST02'),
('OPC32', 'D) Thank you', 'Correct answer', 'EST01'),
('OPC33', 'A) How are you?', 'Incorrect answer', 'EST02'),
('OPC34', 'B) Good night', 'Correct answer', 'EST01'),
('OPC35', 'C) See you later', 'Incorrect answer', 'EST02'),
('OPC36', 'D) Thank you', 'Incorrect answer', 'EST02'),
('OPC37', 'Dog', 'Correct answer.', 'EST01'),
('OPC38', 'Lion', 'Incorrect answer.', 'EST02'),
('OPC39', 'Shark', 'Incorrect answer.', 'EST02'),
('OPC40', 'Eagle', 'Incorrect answer.', 'EST02'),
('OPC41', 'Eagle', 'Correct answer.', 'EST01'),
('OPC42', 'Elephant', 'Incorrect answer.', 'EST02'),
('OPC43', 'Dolphin', 'Incorrect answer.', 'EST02'),
('OPC44', 'Tiger', 'Incorrect answer.', 'EST02'),
('OPC45', 'am', 'Incorrect answer.', 'EST02'),
('OPC46', 'is', 'Correct answer.', 'EST01'),
('OPC47', 'are', 'Incorrect answer.', 'EST02'),
('OPC48', 'be', 'Incorrect answer.', 'EST02'),
('OPC49', 'am', 'Incorrect answer.', 'EST02'),
('OPC50', 'is', 'Incorrect answer.', 'EST02'),
('OPC51', 'are', 'Correct answer.', 'EST01'),
('OPC52', 'be', 'Incorrect answer.', 'EST02'),
('OPC53', 'is', 'Incorrect answer.', 'EST02'),
('OPC54', 'are', 'Incorrect answer.', 'EST02'),
('OPC55', 'is not', 'Correct answer.', 'EST01'),
('OPC56', 'am not', 'Incorrect answer.', 'EST02'),
('OPC57', 'He', 'Incorrect answer.', 'EST02'),
('OPC58', 'She', 'Incorrect answer.', 'EST02'),
('OPC59', 'It', 'Correct answer.', 'EST01'),
('OPC60', 'They', 'Incorrect answer.', 'EST02'),
('OPC61', 'He', 'Incorrect answer.', 'EST02'),
('OPC62', 'It', 'Incorrect answer.', 'EST02'),
('OPC63', 'She', 'Incorrect answer.', 'EST02'),
('OPC64', 'They', 'Correct answer.', 'EST01'),
('OPC65', 'The cat is small.', 'Correct answer.', 'EST01'),
('OPC66', 'The dog is big.', 'Incorrect answer.', 'EST02'),
('OPC67', 'The bird is blue.', 'Incorrect answer.', 'EST02'),
('OPC68', 'The fish is fast.', 'Incorrect answer.', 'EST02'),
('OPC69', 'It is a tiger.', 'Incorrect answer.', 'EST02'),
('OPC70', 'It is a lion.', 'Correct answer.', 'EST01'),
('OPC71', 'It is a monkey.', 'Incorrect answer.', 'EST02'),
('OPC72', 'It is a bear.', 'Incorrect answer.', 'EST02'),
('OPC73', 'They are dogs.', 'Incorrect answer.', 'EST02'),
('OPC74', 'They are elephants.', 'Correct answer.', 'EST01'),
('OPC75', 'It is an elephant.', 'Incorrect answer.', 'EST02'),
('OPC76', 'They are birds.', 'Incorrect answer.', 'EST02'),
('OPC77', 'A tiger is a wild animal.', 'Correct answer.', 'EST01'),
('OPC78', 'A tiger are a wild animal.', 'Incorrect answer.', 'EST02'),
('OPC79', 'A tiger am a wild animal.', 'Incorrect answer.', 'EST02'),
('OPC80', 'A tiger be a wild animal.', 'Incorrect answer.', 'EST02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `opcion_backup_lesson4`
--

CREATE TABLE `opcion_backup_lesson4` (
  `clave` varchar(5) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text NOT NULL,
  `estado_opcion` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `opcion_backup_lesson4`
--

INSERT INTO `opcion_backup_lesson4` (`clave`, `nombre`, `descripcion`, `estado_opcion`) VALUES
('OP125', 'Correct Answer', 'Dolphin', 'EST01'),
('OP126', 'Incorrect Answer 1', 'Penguin', 'EST02'),
('OP127', 'Incorrect Answer 2', 'Tiger', 'EST02'),
('OP128', 'Incorrect Answer 3', 'Monkey', 'EST02'),
('OP129', 'Correct Answer', 'They', 'EST01'),
('OP130', 'Incorrect Answer 1', 'It', 'EST02'),
('OP131', 'Incorrect Answer 2', 'He', 'EST02'),
('OP132', 'Incorrect Answer 3', 'She', 'EST02'),
('OP133', 'Correct Answer', 'is', 'EST01'),
('OP134', 'Incorrect Answer 1', 'are', 'EST02'),
('OP135', 'Incorrect Answer 2', 'am', 'EST02'),
('OP136', 'Incorrect Answer 3', 'be', 'EST02'),
('OP137', 'Correct Answer', 'is not', 'EST01'),
('OP138', 'Incorrect Answer 1', 'are not', 'EST02'),
('OP139', 'Incorrect Answer 2', 'am not', 'EST02'),
('OP140', 'Incorrect Answer 3', 'is', 'EST02'),
('OP141', 'Correct Answer', 'are', 'EST01'),
('OP142', 'Incorrect Answer 1', 'is', 'EST02'),
('OP143', 'Incorrect Answer 2', 'am', 'EST02'),
('OP144', 'Incorrect Answer 3', 'be', 'EST02'),
('OP145', 'Correct Answer', 'It', 'EST01'),
('OP146', 'Incorrect Answer 1', 'They', 'EST02'),
('OP147', 'Incorrect Answer 2', 'He', 'EST02'),
('OP148', 'Incorrect Answer 3', 'She', 'EST02'),
('OP149', 'Correct Answer', 'Dolphin', 'EST01'),
('OP150', 'Incorrect Answer 1', 'Tiger', 'EST02'),
('OP151', 'Incorrect Answer 2', 'Rabbit', 'EST02'),
('OP152', 'Incorrect Answer 3', 'Elephant', 'EST02'),
('OP153', 'Correct Answer', 'It can swim and has flippers.', 'EST01'),
('OP154', 'Incorrect Answer 1', 'It can fly and has feathers.', 'EST02'),
('OP155', 'Incorrect Answer 2', 'It lives in trees.', 'EST02'),
('OP156', 'Incorrect Answer 3', 'It has four legs and stripes.', 'EST02'),
('OP157', 'Correct Answer', 'True', 'EST01'),
('OP158', 'Incorrect Answer 1', 'False', 'EST02'),
('OP159', 'Incorrect Answer 2', 'Not mentioned', 'EST02'),
('OP160', 'Incorrect Answer 3', 'Both are correct', 'EST02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `palabra`
--

CREATE TABLE `palabra` (
  `codigo` varchar(10) NOT NULL,
  `significado` varchar(50) NOT NULL,
  `pronunciacion` varchar(100) NOT NULL,
  `imagen` varchar(100) DEFAULT NULL,
  `audio` varchar(100) DEFAULT NULL,
  `categoria` varchar(10) NOT NULL,
  `nivel` varchar(2) NOT NULL,
  `definicion` varchar(255) DEFAULT NULL,
  `ejemplo` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `palabra`
--

INSERT INTO `palabra` (`codigo`, `significado`, `pronunciacion`, `imagen`, `audio`, `categoria`, `nivel`, `definicion`, `ejemplo`) VALUES
('PAL0001', 'apple', '/ap.el/', 'palabras/imagenes/apple-red.png', 'palabras/audios/apple.mp3', 'CAT02', 'A1', 'A round fruit that is usually red, green, or yellow.', 'I eat an apple every morning.'),
('PAL0002', 'tiger', '/tai.ger/', 'palabras/imagenes/tiger.png', 'palabras/audios/tiger.mp3', 'CAT01', 'A2', 'A large wild cat with orange fur and black stripes.', 'The tiger is one of the largest wild cats.'),
('PAL0003', 'purple', '/per.pel/', 'palabras/imagenes/purple_vImdHfX.jpg', 'palabras/audios/purple_av2sYT9.mp3', 'CAT03', 'B1', 'A color made by mixing red and blue.', 'Her favorite color is purple.'),
('PAL0004', 'mother', '/ma.der/', 'palabras/imagenes/mother.png', 'palabras/audios/mother.mp3', 'CAT04', 'B2', 'A female parent.', 'My mother cooks dinner every evening.'),
('PAL0005', 'pencil', '/pen.sel/', 'palabras/imagenes/pencil.png', 'palabras/audios/pencil.mp3', 'CAT05', 'C1', 'A thin writing tool with a graphite core.', 'I write my homework with a pencil.'),
('PAL0006', 'soccer', '/sa.ker/', 'palabras/imagenes/soccer.png', 'palabras/audios/soccer.mp3', 'CAT06', 'C2', 'A sport in which two teams try to score by kicking a ball into a goal.', 'We play soccer after school.'),
('PAL0007', 'forest', '/fo.rest/', 'palabras/imagenes/forest.png', 'palabras/audios/forest.mp3', 'CAT07', 'A1', 'A large area covered mainly by trees and other plants.', 'We walked through the forest.'),
('PAL0008', 'laptop', '/lap.tap/', 'palabras/imagenes/laptop.png', 'palabras/audios/laptop.mp3', 'CAT08', 'A2', 'A portable computer that can be used in different places.', 'I use my laptop for school projects.'),
('PAL0009', 'happy', '/ha.pi/', 'palabras/imagenes/happy.png', 'palabras/audios/happy.mp3', 'CAT09', 'B1', 'Feeling good, pleased, or satisfied.', 'She is happy because she passed the exam.'),
('PAL0010', 'bicycle', '/bai.si.kel/', 'palabras/imagenes/bicycle.png', 'palabras/audios/bicycle.mp3', 'CAT10', 'B2', 'A two-wheeled vehicle that you ride by pushing pedals.', 'He rides his bicycle to school.'),
('PAL0011', 'rabbit', '/ra.bit/', 'palabras/imagenes/rabbit.png', 'palabras/audios/rabbit.mp3', 'CAT01', 'A1', 'A small animal with long ears that can hop.', 'The rabbit is eating a carrot.'),
('PAL0012', 'monkey', '/mon.ki/', 'palabras/imagenes/monkey.png', 'palabras/audios/monkey.mp3', 'CAT01', 'A1', 'An intelligent animal that lives mainly in trees and has a long tail.', 'The monkey is climbing the tree.'),
('PAL0013', 'dolphin', '/dol.fin/', 'palabras/imagenes/dolphin.png', 'palabras/audios/dolphin.mp3', 'CAT01', 'A2', 'A highly intelligent sea animal that lives in groups.', 'We saw a dolphin swimming near the boat.'),
('PAL0014', 'elephant', '/e.le.fant/', 'palabras/imagenes/elephant_rXSpfcb.png', 'palabras/audios/elephant.mp3', 'CAT01', 'B1', 'A very large land animal with a long trunk and large ears.', 'The elephant is drinking water.'),
('PAL0015', 'penguin', '/pen.gwin/', 'palabras/imagenes/penguin.png', 'palabras/audios/penguin.mp3', 'CAT01', 'B1', 'A black and white bird that cannot fly and lives in cold regions.', 'The penguin is walking on the ice.'),
('PAL0016', 'banana', '/ba.na.na/', 'palabras/imagenes/banana.png', 'palabras/audios/banana.mp3', 'CAT02', 'A1', 'A long curved fruit with yellow skin.', 'She ate a banana for breakfast.'),
('PAL0017', 'cheese', '/chiiz/', 'palabras/imagenes/cheese.png', 'palabras/audios/cheese.mp3', 'CAT02', 'A1', 'A food made from milk that can be hard or soft.', 'I like cheese on my sandwich.'),
('PAL0018', 'chicken', '/chi.ken/', 'palabras/imagenes/chicken.png', 'palabras/audios/chicken.mp3', 'CAT02', 'A2', 'A type of bird that is commonly eaten as food.', 'We had chicken for dinner.'),
('PAL0019', 'sandwich', '/sand.wich/', 'palabras/imagenes/sandwich.png', 'palabras/audios/sandwich.mp3', 'CAT02', 'B1', 'Food made with two pieces of bread and a filling between them.', 'I made a sandwich for lunch.'),
('PAL0020', 'vegetable', '/vej.ta.bol/', 'palabras/imagenes/vegetable.png', 'palabras/audios/vegetable.mp3', 'CAT02', 'B2', 'A plant or part of a plant that is used as food.', 'Eating vegetables is good for your health.'),
('PAL0021', 'red', '/red/', 'palabras/imagenes/red.jpg', 'palabras/audios/red.mp3', 'CAT03', 'A1', 'The color of blood, strawberries, or roses.', 'The car is red.'),
('PAL0022', 'yellow', '/ye.low/', 'palabras/imagenes/yellow.jpg', 'palabras/audios/yellow.mp3', 'CAT03', 'A1', 'The color of the sun and many ripe bananas.', 'She is wearing a yellow dress.'),
('PAL0023', 'orange', '/o.ranch/', 'palabras/imagenes/orange.jpg', 'palabras/audios/orange.mp3', 'CAT03', 'A2', 'A color produced by mixing red and yellow.', 'The orange ball is on the table.'),
('PAL0024', 'green', '/grin/', 'palabras/imagenes/green.jpg', 'palabras/audios/green.mp3', 'CAT03', 'A2', 'The color of grass and many leaves.', 'The grass is green.'),
('PAL0025', 'turquoise', '/ter.kwoiz/', 'palabras/imagenes/turquoise.png', 'palabras/audios/turquoise.mp3', 'CAT03', 'B1', 'A blue-green color.', 'She chose a turquoise shirt.'),
('PAL0026', 'father', '/fa.der/', 'palabras/imagenes/father.png', 'palabras/audios/father.mp3', 'CAT04', 'A1', 'A male parent.', 'My father works at a hospital.'),
('PAL0027', 'sister', '/sis.ter/', 'palabras/imagenes/sister.png', 'palabras/audios/sister.mp3', 'CAT04', 'A1', 'A girl or woman who has the same parents as you.', 'My sister is older than me.'),
('PAL0028', 'brother', '/bra.der/', 'palabras/imagenes/brother.png', 'palabras/audios/brother.mp3', 'CAT04', 'A1', 'A boy or man who has the same parents as you.', 'My brother plays soccer.'),
('PAL0029', 'daughter', '/do.ter/', 'palabras/imagenes/daughter.png', 'palabras/audios/daughter.mp3', 'CAT04', 'A2', 'A female child of a person.', 'Their daughter is six years old.'),
('PAL0030', 'grandmother', '/grand.ma.der/', 'palabras/imagenes/grandmother.png', 'palabras/audios/grandmother.mp3', 'CAT04', 'B1', 'The mother of your mother or father.', 'My grandmother makes delicious cookies.'),
('PAL0031', 'book', '/buk/', 'palabras/imagenes/book.png', 'palabras/audios/book.mp3', 'CAT05', 'A1', 'A set of pages with printed or written information, usually covered with a cover.', 'I am reading a book.'),
('PAL0032', 'teacher', '/ti.cher/', 'palabras/imagenes/teacher.png', 'palabras/audios/teacher.mp3', 'CAT05', 'A1', 'A person who teaches students.', 'The teacher explained the lesson.'),
('PAL0033', 'classroom', '/klas.rum/', 'palabras/imagenes/classroom.png', 'palabras/audios/classroom.mp3', 'CAT05', 'A2', 'A room where students learn at school.', 'The students are in the classroom.'),
('PAL0034', 'homework', '/hom.work/', 'palabras/imagenes/homework.png', 'palabras/audios/homework.mp3', 'CAT05', 'A2', 'Work that students must do at home for school.', 'I need to finish my homework tonight.'),
('PAL0035', 'assignment', '/a.sain.ment/', 'palabras/imagenes/assignment.png', 'palabras/audios/assignment.mp3', 'CAT05', 'B1', 'A piece of work that a student is asked to complete.', 'The teacher gave us a new assignment.'),
('PAL0036', 'tennis', '/te.nis/', 'palabras/imagenes/tennis.png', 'palabras/audios/tennis.mp3', 'CAT06', 'A1', 'A sport played by hitting a ball over a net with a racket.', 'She plays tennis every Saturday.'),
('PAL0037', 'basketball', '/bas.ket.bol/', 'palabras/imagenes/basketball.png', 'palabras/audios/basketball.mp3', 'CAT06', 'A1', 'A sport in which two teams try to score points by throwing a ball through a hoop.', 'They play basketball after class.'),
('PAL0038', 'baseball', '/beis.bol/', 'palabras/imagenes/baseball.png', 'palabras/audios/baseball.mp3', 'CAT06', 'A2', 'A sport in which players hit a ball with a bat and run around bases.', 'My brother plays baseball.'),
('PAL0039', 'swimming', '/swi.ming/', 'palabras/imagenes/swimming.png', 'palabras/audios/swimming.mp3', 'CAT06', 'A2', 'The activity or sport of moving through water by using your arms and legs.', 'Swimming is my favorite sport.'),
('PAL0040', 'competition', '/kom.pe.ti.shon/', 'palabras/imagenes/competition.png', 'palabras/audios/competition.mp3', 'CAT06', 'B1', 'A contest in which people or teams compete against each other.', 'Our school is having a spelling competition.'),
('PAL0041', 'tree', '/tri/', 'palabras/imagenes/tree.png', 'palabras/audios/tree.mp3', 'CAT07', 'A1', 'A tall plant with a trunk, branches, and leaves.', 'There is a big tree in the garden.'),
('PAL0042', 'flower', '/flau.er/', 'palabras/imagenes/flower.png', 'palabras/audios/flower.mp3', 'CAT07', 'A1', 'The colorful part of a plant that often has a pleasant smell.', 'This flower is very beautiful.'),
('PAL0043', 'river', '/ri.ver/', 'palabras/imagenes/river.png', 'palabras/audios/river.mp3', 'CAT07', 'A2', 'A natural flow of water that moves across land.', 'The river flows through the city.'),
('PAL0044', 'mountain', '/maun.ten/', 'palabras/imagenes/mountain.png', 'palabras/audios/mountain.mp3', 'CAT07', 'A2', 'A very high area of land with steep sides, often higher than a hill.', 'We climbed the mountain last summer.'),
('PAL0045', 'waterfall', '/wo.ter.fol/', 'palabras/imagenes/waterfall.png', 'palabras/audios/water.mp3', 'CAT07', 'B1', 'A place where water falls from a high point to a lower point.', 'The waterfall is surrounded by trees.'),
('PAL0046', 'phone', '/fon/', 'palabras/imagenes/phone.png', 'palabras/audios/phone.mp3', 'CAT08', 'A1', 'A device used for calling and communicating with people.', 'I use my phone to call my parents.'),
('PAL0047', 'computer', '/kom.piu.ter/', 'palabras/imagenes/computer.png', 'palabras/audios/computer.mp3', 'CAT08', 'A1', 'An electronic machine that processes and stores information.', 'I use my computer to study.'),
('PAL0048', 'keyboard', '/ki.bord/', 'palabras/imagenes/keyboard.png', 'palabras/audios/keyboard.mp3', 'CAT08', 'A2', 'A set of keys used to type letters, numbers, and symbols on a computer.', 'My keyboard has many different keys.'),
('PAL0049', 'software', '/soft.wer/', 'palabras/imagenes/software-icon.png', 'palabras/audios/software.mp3', 'CAT08', 'B1', 'Programs and instructions that make a computer work.', 'The software needs to be updated.'),
('PAL0050', 'database', '/dei.ta.beis/', 'palabras/imagenes/database.png', 'palabras/audios/database.mp3', 'CAT08', 'B1', 'An organized collection of information stored in a computer system.', 'The application stores the information in a database.'),
('PAL0051', 'sad', '/sad/', 'palabras/imagenes/sad.png', 'palabras/audios/sad.mp3', 'CAT09', 'A1', 'Feeling unhappy or not pleased.', 'He felt sad after losing the game.'),
('PAL0052', 'angry', '/ang.gri/', 'palabras/imagenes/angry.png', 'palabras/audios/angry.mp3', 'CAT09', 'A1', 'Feeling very upset or annoyed.', 'She was angry because someone broke her phone.'),
('PAL0053', 'excited', '/ik.sai.ted/', 'palabras/imagenes/excited.png', 'palabras/audios/excited.mp3', 'CAT09', 'A2', 'Feeling very happy and enthusiastic about something.', 'The students are excited about the competition.'),
('PAL0054', 'nervous', '/ner.vos/', 'palabras/imagenes/nervous.png', 'palabras/audios/nervous.mp3', 'CAT09', 'A2', 'Feeling worried or afraid about something that may happen.', 'I feel nervous before an exam.'),
('PAL0055', 'confident', '/kon.fi.dent/', 'palabras/imagenes/confident.png', 'palabras/audios/confident.mp3', 'CAT09', 'B1', 'Feeling sure about your abilities or decisions.', 'She feels confident when she speaks English.'),
('PAL0056', 'car', '/kar/', 'palabras/imagenes/car.png', 'palabras/audios/car.mp3', 'CAT10', 'A1', 'A road vehicle with four wheels used to carry people.', 'My family has a new car.'),
('PAL0057', 'bus', '/bas/', 'palabras/imagenes/bus.png', 'palabras/audios/bus.mp3', 'CAT10', 'A1', 'A large road vehicle that carries many passengers.', 'I take the bus to school.'),
('PAL0058', 'train', '/trein/', 'palabras/imagenes/train.png', 'palabras/audios/train.mp3', 'CAT10', 'A2', 'A long vehicle that travels on railway tracks.', 'The train arrived at the station.'),
('PAL0059', 'airplane', '/er.plein/', 'palabras/imagenes/airplane.png', 'palabras/audios/airplane.mp3', 'CAT10', 'A2', 'A vehicle with wings that flies through the air.', 'The airplane is flying over the city.'),
('PAL0060', 'motorcycle', '/mo.tor.sai.kol/', 'palabras/imagenes/motorcycle.png', 'palabras/audios/motorcycle.mp3', 'CAT10', 'B1', 'A two-wheeled vehicle powered by an engine.', 'He rides his motorcycle to work.'),
('PAL0061', 'Abrade', '/a-bréid/', 'palabras/imagenes/abrade.png', 'palabras/audios/abrade.mp3', 'CAT11', 'B1', 'To rub a surface with something rough and remove part of it.', 'The workers abraded the surface before painting it.'),
('PAL0062', 'Abroad', '/a-bród/', '', '', 'CAT11', 'B1', 'In or to a foreign country.', 'She traveled abroad to study English.'),
('PAL0063', 'Absorb', '/ab-sórb/', '', '', 'CAT11', 'B1', 'To take in or soak up a substance or energy.', 'Plants absorb water through their roots.'),
('PAL0064', 'Accept', '/ak-sépt/', '', '', 'CAT11', 'B1', 'To agree to receive or do something.', 'She accepted the invitation to the competition.'),
('PAL0065', 'Access', '/ák-ses/', '', '', 'CAT11', 'B1', 'The ability or right to enter, use, or reach something.', 'Students need access to the online platform.'),
('PAL0066', 'Accuse', '/a-kiús/', '', '', 'CAT11', 'B1', 'To say that someone has done something wrong or illegal.', 'The teacher accused him of cheating.'),
('PAL0067', 'Aching', '/éik-ing/', '', '', 'CAT11', 'B1', 'Having a continuous or painful feeling in the body.', 'My back is aching after the long trip.'),
('PAL0068', 'Active', '/ák-tiv/', '', '', 'CAT11', 'B1', 'Doing things or moving rather than being still.', 'She is very active and plays several sports.'),
('PAL0069', 'Acuity', '/a-kiú-i-ti/', '', '', 'CAT11', 'B1', 'The ability to see, hear, or understand things clearly and accurately.', 'Good visual acuity is important for this task.'),
('PAL0070', 'Adhere', '/ad-jíer/', '', '', 'CAT11', 'B1', 'To stick firmly to something or follow a rule or agreement.', 'The label must adhere to the surface.'),
('PAL0071', 'Adjust', '/a-dshást/', '', '', 'CAT11', 'B1', 'To change something slightly to make it work better or fit better.', 'We need to adjust the settings.'),
('PAL0072', 'Admire', '/ad-máiar/', '', '', 'CAT11', 'B1', 'To respect or like someone because of their qualities or achievements.', 'I admire her dedication to learning English.'),
('PAL0073', 'Advice', '/ad-váis/', '', '', 'CAT11', 'B1', 'An opinion about what someone should do.', 'My teacher gave me useful advice.'),
('PAL0074', 'Advise', '/ad-váis/', '', '', 'CAT11', 'B1', 'To tell someone what you think they should do.', 'I advise you to practice every day.'),
('PAL0075', 'Afford', '/a-fórd/', '', '', 'CAT11', 'B1', 'To have enough money or time to pay for or do something.', 'We cannot afford a new computer right now.'),
('PAL0076', 'Afraid', '/a-fréid/', '', '', 'CAT11', 'B1', 'Feeling fear or worried about something.', 'The child was afraid of the dark.'),
('PAL0077', 'Ageism', '/éidsh-i-sam/', '', '', 'CAT11', 'B1', 'Unfair treatment or discrimination based on a person’s age.', 'The organization works to reduce ageism.'),
('PAL0078', 'Amazes', '/a-méi-sis/', '', '', 'CAT11', 'B1', 'Makes someone feel surprised, impressed, or pleased.', 'The results amaze everyone.'),
('PAL0079', 'Amount', '/a-máunt/', '', '', 'CAT11', 'B1', 'A quantity of something.', 'A large amount of water was needed.'),
('PAL0080', 'Annual', '/á-niu-al/', '', '', 'CAT11', 'B1', 'Happening once every year.', 'The school publishes an annual report.'),
('PAL0081', 'Appeal', '/a-píil/', '', '', 'CAT11', 'B1', 'A request for a decision to be changed or a situation to be considered again.', 'The student made an appeal against the decision.'),
('PAL0082', 'Appear', '/a-píer/', '', '', 'CAT11', 'B1', 'To become visible or be seen.', 'A rainbow appeared after the rain.'),
('PAL0083', 'Arabic', '/á-ra-bik/', '', '', 'CAT11', 'B1', 'Relating to the language, culture, or people of Arab countries.', 'She is taking an Arabic language course.'),
('PAL0084', 'Arrive', '/a-ráiv/', '', '', 'CAT11', 'B1', 'To reach a place after traveling.', 'We arrived at school early.'),
('PAL0085', 'Ashore', '/a-shór/', '', '', 'CAT11', 'B1', 'On or toward the land from the sea.', 'The sailors came ashore after the storm.'),
('PAL0086', 'Asleep', '/a-slíip/', '', '', 'CAT11', 'B1', 'In a state of sleep.', 'The baby is asleep.'),
('PAL0087', 'Assume', '/a-siúm/', '', '', 'CAT11', 'B1', 'To accept something as true without proof.', 'Do not assume that everyone knows the answer.'),
('PAL0088', 'Attack', '/a-ták/', '', '', 'CAT11', 'B1', 'To use force against a person, place, or group.', 'The army attacked the city.'),
('PAL0089', 'Battle', '/bá-tl/', '', '', 'CAT11', 'B1', 'A fight between people, groups, or armies.', 'The two teams prepared for the final battle.'),
('PAL0090', 'Become', '/bi-kám/', '', '', 'CAT11', 'B1', 'To start to be or develop into something.', 'She wants to become a teacher.'),
('PAL0091', 'Behalf', '/bi-jáf/', '', '', 'CAT11', 'B1', 'For the benefit or advantage of someone.', 'He spoke on behalf of his team.'),
('PAL0092', 'Belief', '/bi-líif/', '', '', 'CAT11', 'B1', 'A feeling of trust or confidence in something or someone.', 'Her belief in herself helped her succeed.'),
('PAL0093', 'Belong', '/bi-lóng/', '', '', 'CAT11', 'B1', 'To be in the right place or to be accepted as a member of a group.', 'I feel that I belong in this group.'),
('PAL0094', 'Better', '/bé-ter/', '', '', 'CAT11', 'B1', 'Of a higher quality or more desirable than another thing.', 'This solution is better than the previous one.'),
('PAL0095', 'Bitter', '/bí-ter/', '', '', 'CAT11', 'B1', 'Having a sharp, unpleasant taste or feeling.', 'The medicine has a bitter taste.'),
('PAL0096', 'Blazed', '/bléizd/', '', '', 'CAT11', 'B1', 'Burned brightly or strongly in the past.', 'The candles blazed brightly during the ceremony.'),
('PAL0097', 'Blight', '/bláit/', '', '', 'CAT11', 'B1', 'A disease or condition that causes plants to die or become damaged.', 'The disease caused blight in the crops.'),
('PAL0098', 'Bonnet', '/bó-net/', '', '', 'CAT11', 'B1', 'A type of hat, especially one worn as part of a uniform.', 'The driver wore a traditional bonnet.'),
('PAL0099', 'Boring', '/bó-ring/', '', '', 'CAT11', 'B1', 'Not interesting or exciting.', 'The lecture was boring.'),
('PAL0100', 'Borrow', '/bó-rou/', '', '', 'CAT11', 'B1', 'To take and use something belonging to someone else with the intention of returning it.', 'Can I borrow your pencil?'),
('PAL0101', 'Bounce', '/báus/', '', '', 'CAT11', 'B1', 'To move quickly away from a surface after hitting it.', 'The ball bounced off the wall.'),
('PAL0102', 'Bounty', '/báun-ti/', '', '', 'CAT11', 'B1', 'A reward or amount of money offered for something.', 'The king offered a bounty for the lost treasure.'),
('PAL0103', 'Breath', '/brez/', '', '', 'CAT11', 'B1', 'The air that you take into and send out of your lungs.', 'Take a deep breath before you speak.'),
('PAL0104', 'Budget', '/bá-dtshet/', '', '', 'CAT11', 'B1', 'A plan showing how much money is available and how it will be spent.', 'The team created a budget for the project.'),
('PAL0105', 'Burden', '/bér-den/', '', '', 'CAT11', 'B1', 'A heavy responsibility or problem.', 'The heavy burden made the task difficult.'),
('PAL0106', 'Bureau', '/biú-rou/', '', '', 'CAT11', 'B1', 'An office or organization that provides a particular service.', 'She works at a government bureau.'),
('PAL0107', 'Burrow', '/bá-rou/', '', '', 'CAT11', 'B1', 'A hole or passage made by an animal under the ground.', 'The rabbit disappeared into its burrow.'),
('PAL0108', 'Butter', '/bá-ter/', '', '', 'CAT11', 'B1', 'A soft yellow food made from milk and used in cooking or on bread.', 'She spread butter on the bread.'),
('PAL0109', 'Bygone', '/bái-gon/', '', '', 'CAT11', 'B1', 'Belonging to or relating to a time in the past.', 'That is a story from a bygone era.'),
('PAL0110', 'Canvas', '/kán-vas/', '', '', 'CAT11', 'B1', 'Strong cloth used for making things such as bags, tents, or paintings.', 'The artist painted on a large canvas.'),
('PAL0111', 'Cashew', '/ká-shiu/', '', '', 'CAT11', 'B1', 'A curved nut with a hard shell and a sweet taste.', 'She added cashews to the salad.'),
('PAL0112', 'Caucus', '/kó-kas/', '', '', 'CAT11', 'B1', 'A meeting or group of people, especially members of a political party.', 'The political caucus met before the election.'),
('PAL0113', 'Caught', '/kot/', '', '', 'CAT11', 'B1', 'Caught or captured, or received a ball or object successfully.', 'The goalkeeper caught the ball.'),
('PAL0114', 'Chance', '/chans/', '', '', 'CAT11', 'B1', 'A possibility or occasion for something to happen.', 'There is a chance of rain today.'),
('PAL0115', 'Change', '/chéindsh/', '', '', 'CAT11', 'B1', 'To make something different or become different.', 'We need to change our plans.'),
('PAL0116', 'Charge', '/chárdsh/', '', '', 'CAT11', 'B1', 'To ask someone to pay money or to officially accuse someone of a crime.', 'The hotel will charge a fee for parking.'),
('PAL0117', 'Choose', '/chúus/', '', '', 'CAT11', 'B1', 'To decide which thing you want from two or more possibilities.', 'You can choose any book you like.'),
('PAL0118', 'Circle', '/sér-kl/', '', '', 'CAT11', 'B1', 'A completely round shape or a group of people or things forming a ring.', 'Draw a circle around the correct answer.'),
('PAL0119', 'Commit', '/ko-mít/', '', '', 'CAT11', 'B1', 'To promise or decide to do something or to become involved in something.', 'They committed to finishing the project.'),
('PAL0120', 'Common', '/kó-mon/', '', '', 'CAT11', 'B1', 'Happening often or shared by many people.', 'English is a common language around the world.'),
('PAL0121', 'Comply', '/kom-plái/', '', '', 'CAT11', 'B1', 'To obey a rule, order, or request.', 'All students must comply with the rules.'),
('PAL0122', 'Copper', '/kó-per/', '', '', 'CAT11', 'B1', 'A reddish-brown metal.', 'The statue is made of copper.'),
('PAL0123', 'Cotton', '/kó-ton/', '', '', 'CAT11', 'B1', 'A soft natural material used to make cloth and clothing.', 'This shirt is made of cotton.'),
('PAL0124', 'County', '/káun-ti/', '', '', 'CAT11', 'B1', 'An administrative area of a country or state.', 'The county has several small towns.'),
('PAL0125', 'Create', '/kri-éit/', '', '', 'CAT11', 'B1', 'To make or produce something new.', 'Students create projects during the course.'),
('PAL0126', 'Credit', '/kré-dit/', '', '', 'CAT11', 'B1', 'Praise or recognition given to someone for something they have done.', 'She received credit for her excellent work.'),
('PAL0127', 'Damage', '/dá-midsh/', '', '', 'CAT11', 'B1', 'Physical or other harm caused to something.', 'The storm caused serious damage.'),
('PAL0128', 'Danger', '/déin-dsher/', '', '', 'CAT11', 'B1', 'The possibility that something harmful or dangerous may happen.', 'The warning helped us avoid danger.'),
('PAL0129', 'Decent', '/dí-sent/', '', '', 'CAT11', 'B1', 'Acceptable, satisfactory, or of a reasonably good standard.', 'He found a decent place to stay.'),
('PAL0130', 'Decide', '/di-sáid/', '', '', 'CAT11', 'B1', 'To make a choice after thinking about different possibilities.', 'You need to decide before Friday.'),
('PAL0131', 'Defeat', '/di-fíit/', '', '', 'CAT11', 'B1', 'To win against someone or something.', 'Our team defeated the champions.'),
('PAL0132', 'Degree', '/di-gríi/', '', '', 'CAT11', 'B1', 'A level or amount of something, or a university qualification.', 'She earned a degree in computer science.'),
('PAL0133', 'Demand', '/di-mánd/', '', '', 'CAT11', 'B1', 'A strong request for something to be done or provided.', 'The company received a demand for payment.'),
('PAL0134', 'Depend', '/di-pénd/', '', '', 'CAT11', 'B1', 'To need someone or something for support or to function.', 'Children depend on adults for support.'),
('PAL0135', 'Deploy', '/di-plói/', '', '', 'CAT11', 'B1', 'To use or arrange people, equipment, or resources for a particular purpose.', 'The company deployed new equipment.'),
('PAL0136', 'Desert', '/dé-sert/', '', '', 'CAT11', 'B1', 'A large dry area of land with very little rain.', 'Very little rain falls in the desert.'),
('PAL0137', 'Design', '/di-sáin/', '', '', 'CAT11', 'B1', 'A plan or drawing that shows how something will look or work.', 'She created the design for the new website.'),
('PAL0138', 'Desire', '/di-sáiar/', '', '', 'CAT11', 'B1', 'A strong wish to have or do something.', 'He has a strong desire to learn.'),
('PAL0139', 'Detail', '/di-téil/', '', '', 'CAT11', 'B1', 'A small piece of information or an individual part of something.', 'Please check every detail before submitting it.'),
('PAL0140', 'Device', '/di-váis/', '', '', 'CAT11', 'B1', 'An object or piece of equipment designed for a particular purpose.', 'This device can measure temperature.'),
('PAL0141', 'Differ', '/dí-fer/', '', '', 'CAT11', 'B1', 'To be different from someone or something else.', 'The two products differ in price.'),
('PAL0142', 'Double', '/dá-bl/', '', '', 'CAT11', 'B1', 'Twice as much or twice as many.', 'This room is double the size of the other one.'),
('PAL0143', 'Effect', '/i-fékt/', '', '', 'CAT11', 'B1', 'The result or influence that an action or event has.', 'The medicine had a positive effect.'),
('PAL0144', 'Either', '/í-der/', '', '', 'CAT11', 'B1', 'One or the other of two choices or possibilities.', 'You can choose either option.'),
('PAL0145', 'Enable', '/e-néi-bl/', '', '', 'CAT11', 'B1', 'To make something possible or allow someone to do something.', 'The app enables students to practice anywhere.'),
('PAL0146', 'Engage', '/en-géidsh/', '', '', 'CAT11', 'B1', 'To become involved in an activity or situation.', 'Students engage in different learning activities.'),
('PAL0147', 'Enough', '/i-náf/', '', '', 'CAT11', 'B1', 'As much or as many as needed.', 'We have enough time to finish.'),
('PAL0148', 'Ensure', '/en-shúer/', '', '', 'CAT11', 'B1', 'To make certain that something happens or is true.', 'Please ensure that the door is closed.'),
('PAL0149', 'Entail', '/en-téil/', '', '', 'CAT11', 'B1', 'To involve something as a necessary part or consequence.', 'The job will entail some travel.'),
('PAL0150', 'Entire', '/en-táiar/', '', '', 'CAT11', 'B1', 'Whole or complete.', 'The entire class participated.'),
('PAL0151', 'Equity', '/é-kui-ti/', '', '', 'CAT11', 'B1', 'Fairness and equal treatment for different people or groups.', 'The program promotes equity in education.'),
('PAL0152', 'Expand', '/ek-spánd/', '', '', 'CAT11', 'B1', 'To become larger or make something larger.', 'The company plans to expand next year.'),
('PAL0153', 'Expect', '/ek-spékt/', '', '', 'CAT11', 'B1', 'To think that something will happen.', 'I expect the competition to be challenging.'),
('PAL0154', 'Expert', '/ék-spert/', '', '', 'CAT11', 'B1', 'A person with a high level of knowledge or skill in a particular subject.', 'We asked an expert for advice.'),
('PAL0155', 'Extend', '/ek-sténd/', '', '', 'CAT11', 'B1', 'To make something longer or continue something for a longer time.', 'The teacher extended the deadline.'),
('PAL0156', 'Facing', '/féi-sing/', '', '', 'CAT11', 'B1', 'Being directed toward or dealing with a particular situation.', 'We are facing a difficult problem.'),
('PAL0157', 'Famous', '/féi-mos/', '', '', 'CAT11', 'B1', 'Known by many people.', 'She became famous after winning the competition.'),
('PAL0158', 'Flight', '/flait/', '', '', 'CAT11', 'B1', 'The act of traveling by air, or a journey by airplane.', 'The flight leaves at eight o’clock.'),
('PAL0159', 'Follow', '/fó-lou/', '', '', 'CAT11', 'B1', 'To go after or move behind someone or something.', 'Please follow the instructions carefully.'),
('PAL0160', 'Forbid', '/for-bíd/', '', '', 'CAT11', 'B1', 'To officially tell someone that they must not do something.', 'The rules forbid students from using phones.'),
('PAL0161', 'Forget', '/for-gét/', '', '', 'CAT11', 'B1', 'To fail to remember something.', 'Do not forget your homework.'),
('PAL0162', 'Formal', '/fór-mal/', '', '', 'CAT11', 'B1', 'Suitable for official or serious situations.', 'He wore formal clothes to the event.'),
('PAL0163', 'Former', '/fór-mer/', '', '', 'CAT11', 'B1', 'Having existed or happened before the present time.', 'The former teacher visited the school.'),
('PAL0164', 'Freeze', '/friis/', '', '', 'CAT11', 'B1', 'To turn from liquid into solid because of cold.', 'Water can freeze when the temperature drops.'),
('PAL0165', 'Funnel', '/fá-nel/', '', '', 'CAT11', 'B1', 'A tube or container that is wider at one end.', 'The liquid passed through the funnel.'),
('PAL0166', 'Galore', '/ga-lór/', '', '', 'CAT11', 'B1', 'Existing or available in very large amounts.', 'There were flowers galore at the festival.'),
('PAL0167', 'Gather', '/gá-der/', '', '', 'CAT11', 'B1', 'To bring people or things together in one place.', 'The students gathered in the classroom.'),
('PAL0168', 'Geared', '/glóu-bal/', '', '', 'CAT11', 'B1', 'Designed or arranged to work well for a particular purpose.', 'The system is geared toward helping students learn.'),
('PAL0169', 'Growth', '/gróuz/', '', '', 'CAT11', 'B1', 'The process of growing, increasing, or developing.', 'The company experienced rapid growth.'),
('PAL0170', 'Guilty', '/gíl-ti/', '', '', 'CAT11', 'B1', 'Responsible for a crime or wrong action.', 'The man was found guilty of the crime.'),
('PAL0171', 'Harbor', '/jár-bor/', '', '', 'CAT11', 'B1', 'A place where ships can stay safely near the land.', 'The ships returned safely to the harbor.'),
('PAL0172', 'Hardly', '/shárd-li/', '', '', 'CAT11', 'B1', 'Almost not or only to a small degree.', 'The patient could hardly walk.'),
('PAL0173', 'Horror', '/jó-ror/', '', '', 'CAT11', 'B1', 'A strong feeling of fear or something that causes extreme fear.', 'The movie was full of horror.'),
('PAL0174', 'Hybrid', '/jái-brid/', '', '', 'CAT11', 'B1', 'A combination of two different systems, ideas, or types.', 'The car uses a hybrid engine.'),
('PAL0175', 'Ignore', '/ig-nór/', '', '', 'CAT11', 'B1', 'To deliberately pay no attention to someone or something.', 'Please do not ignore the warning.'),
('PAL0176', 'Inform', '/in-fórm/', '', '', 'CAT11', 'B1', 'To give someone information about something.', 'The teacher informed us about the changes.'),
('PAL0177', 'Insist', '/in-síst/', '', '', 'CAT11', 'B1', 'To demand or say something firmly and repeatedly.', 'She insisted on finishing the project.'),
('PAL0178', 'Intend', '/in-ténd/', '', '', 'CAT11', 'B1', 'To have a plan or purpose to do something.', 'They intend to improve the system.'),
('PAL0179', 'Invest', '/in-vést/', '', '', 'CAT11', 'B1', 'To put money, time, or effort into something with the expectation of a benefit.', 'Many people invest in education.'),
('PAL0180', 'Island', '/ái-land/', '', '', 'CAT11', 'B1', 'A piece of land surrounded by water.', 'We spent a week on a tropical island.'),
('PAL0181', 'Kindle', '/kín-dl/', '', '', 'CAT11', 'B1', 'To start a fire or light something.', 'They used dry wood to kindle the fire.'),
('PAL0182', 'Latter', '/lá-ter/', '', '', 'CAT11', 'B1', 'The second of two people or things mentioned.', 'The latter option is cheaper.'),
('PAL0183', 'Letter', '/lé-ter/', '', '', 'CAT11', 'B1', 'A written or printed symbol used to represent a sound in a language.', 'Write one letter in each box.'),
('PAL0184', 'Likely', '/láik-li/', '', '', 'CAT11', 'B1', 'Probably or very probably.', 'She will likely arrive soon.'),
('PAL0185', 'Liquid', '/lí-kuid/', '', '', 'CAT11', 'B1', 'A substance that can flow and takes the shape of its container.', 'Water is a common liquid.'),
('PAL0186', 'Listen', '/lí-sn/', '', '', 'CAT11', 'B1', 'To pay attention to a sound or someone speaking.', 'Please listen to the instructions.'),
('PAL0187', 'Little', '/lí-tl/', '', '', 'CAT11', 'B1', 'Small in size or amount.', 'There is a little time left.'),
('PAL0188', 'Lonely', '/lóun-li/', '', '', 'CAT11', 'B1', 'Unhappy because you are alone or without company.', 'He felt lonely after moving to a new city.'),
('PAL0189', 'Lounge', '/láundsh/', '', '', 'CAT11', 'B1', 'A comfortable public room or area where people can relax.', 'We waited in the airport lounge.'),
('PAL0190', 'Luxury', '/lák-shu-ri/', '', '', 'CAT11', 'B1', 'A condition or experience that is expensive and comfortable.', 'They stayed in a luxury hotel.'),
('PAL0191', 'Manage', '/má-nidsh/', '', '', 'CAT11', 'B1', 'To control, organize, or be responsible for something.', 'She manages the school computer system.'),
('PAL0192', 'Market', '/már-ket/', '', '', 'CAT11', 'B1', 'A place or system where goods or services are bought and sold.', 'The company sells its products in the local market.'),
('PAL0193', 'Matter', '/má-ter/', '', '', 'CAT11', 'B1', 'A subject, situation, or problem that is being discussed.', 'Climate change is an important matter.'),
('PAL0194', 'Mature', '/ma-tsiúr/', '', '', 'CAT11', 'B1', 'Fully developed or grown.', 'The fruit is mature and ready to eat.'),
('PAL0195', 'Mental', '/mén-tal/', '', '', 'CAT11', 'B1', 'Related to the mind or thoughts.', 'Mental health is important for students.'),
('PAL0196', 'Middle', '/mí-dl/', '', '', 'CAT11', 'B1', 'The central part of something or a position between two sides.', 'The teacher stood in the middle of the room.'),
('PAL0197', 'Module', '/mó-diul/', '', '', 'CAT11', 'B1', 'One part of a larger system or course.', 'This module explains the basic concepts.'),
('PAL0198', 'Monkey', '/mán-ki/', '', '', 'CAT11', 'B1', 'A small intelligent animal that is related to apes.', 'The monkey climbed the tree quickly.'),
('PAL0199', 'Muscle', '/má-sl/', '', '', 'CAT11', 'B1', 'A tissue in the body that produces movement by contracting.', 'Regular exercise helps strengthen your muscles.'),
('PAL0200', 'Narrow', '/ná-rou/', '', '', 'CAT11', 'B1', 'Having a small distance from one side to the other.', 'The road is too narrow for two cars.'),
('PAL0201', 'Native', '/néi-tiv/', '', '', 'CAT11', 'B1', 'Connected with the place or country where a person was born or grew up.', 'English is not my native language.'),
('PAL0202', 'Nearly', '/níer-li/', '', '', 'CAT11', 'B1', 'Almost, but not completely.', 'The project is nearly finished.'),
('PAL0203', 'Needle', '/níi-dl/', '', '', 'CAT11', 'B1', 'A thin, sharp object used for sewing.', 'She used a needle to sew the fabric.'),
('PAL0204', 'Notice', '/nóu-tis/', '', '', 'CAT11', 'B1', 'To see, hear, or become aware of something.', 'Did you notice the change in the classroom?'),
('PAL0205', 'Obtain', '/ob-téin/', '', '', 'CAT11', 'B1', 'To get or obtain something.', 'Students can obtain information from the library.'),
('PAL0206', 'Office', '/ó-fis/', '', '', 'CAT11', 'B1', 'A room or building where people work.', 'She works in an office downtown.'),
('PAL0207', 'Orange', '/ó-rindsh/', '', '', 'CAT11', 'B1', 'A round citrus fruit with orange-colored skin and flesh.', 'I ate an orange after lunch.'),
('PAL0208', 'Pencil', '/pén-sil/', '', '', 'CAT11', 'B1', 'A writing tool with a thin graphite core inside a wooden or plastic body.', 'I need a pencil to write the answer.'),
('PAL0209', 'Plough', '/pláu/', '', '', 'CAT11', 'B1', 'A large farm tool or machine used to turn over soil.', 'The farmer used a plough to prepare the field.'),
('PAL0210', 'Pocket', '/pó-ket/', '', '', 'CAT11', 'B1', 'A small container or part of clothing used for carrying things.', 'He kept his keys in his pocket.'),
('PAL0211', 'Potato', '/po-téi-tou/', '', '', 'CAT11', 'B1', 'A round vegetable that grows underground.', 'We planted potatoes in the garden.'),
('PAL0212', 'Prefer', '/pri-fér/', '', '', 'CAT11', 'B1', 'To like one thing more than another.', 'I prefer tea to coffee.'),
('PAL0213', 'Prince', '/prins/', '', '', 'CAT11', 'B1', 'A male member of a royal family.', 'The prince waved to the crowd.'),
('PAL0214', 'Prison', '/prí-son/', '', '', 'CAT11', 'B1', 'A place where people are kept as punishment for crimes.', 'The prisoner was taken back to prison.'),
('PAL0215', 'Proper', '/pró-per/', '', '', 'CAT11', 'B1', 'Correct, suitable, or appropriate.', 'Please use the proper procedure.'),
('PAL0216', 'Proven', '/prú-ven/', '', '', 'CAT11', 'B1', 'Shown to be true or correct.', 'The theory has been proven by several studies.'),
('PAL0217', 'Pursue', '/per-siú/', '', '', 'CAT11', 'B1', 'To try to achieve or obtain something.', 'She wants to pursue a career in technology.'),
('PAL0218', 'Python', '/pái-son/', '', '', 'CAT11', 'B1', 'A programming language known for its simple and readable syntax.', 'Python is widely used for programming.'),
('PAL0219', 'Recall', '/ri-kól/', '', '', 'CAT11', 'B1', 'To remember something or ask for something to be brought back.', 'I cannot recall his name.'),
('PAL0220', 'Recent', '/rí-sent/', '', '', 'CAT11', 'B1', 'Having happened or appeared not long ago.', 'The student gave a recent example.'),
('PAL0221', 'Refuse', '/ri-fiús/', '', '', 'CAT11', 'B1', 'To say no to something or decline to accept it.', 'He refused the offer.'),
('PAL0222', 'Regime', '/re-shíim/', '', '', 'CAT11', 'B1', 'A system or period of government, especially one that is strict or authoritarian.', 'The country changed its political regime.'),
('PAL0223', 'Regret', '/ri-grét/', '', '', 'CAT11', 'B1', 'To feel sorry or disappointed about something.', 'She regrets missing the opportunity.'),
('PAL0224', 'Relate', '/ri-léit/', '', '', 'CAT11', 'B1', 'To be connected with or have a connection to something.', 'The lesson relates to our previous topic.'),
('PAL0225', 'Relief', '/ri-líif/', '', '', 'CAT11', 'B1', 'A feeling of comfort after pain, worry, or difficulty has decreased.', 'The medicine brought relief from the pain.'),
('PAL0226', 'Remain', '/ri-méin/', '', '', 'CAT11', 'B1', 'To continue to exist or stay in a particular place or condition.', 'Please remain seated.'),
('PAL0227', 'Remote', '/ri-móut/', '', '', 'CAT11', 'B1', 'Far away from other people, places, or things.', 'The students studied at a remote location.'),
('PAL0228', 'Rescue', '/rés-kiu/', '', '', 'CAT11', 'B1', 'To save someone from danger or harm.', 'The firefighters rescued the family.'),
('PAL0229', 'Resent', '/ri-sént/', '', '', 'CAT11', 'B1', 'To feel angry or upset because of something unfair or unpleasant.', 'He resents being treated unfairly.'),
('PAL0230', 'Retain', '/ri-téin/', '', '', 'CAT11', 'B1', 'To keep or continue to have something.', 'The company wants to retain its employees.'),
('PAL0231', 'Retire', '/ri-táiar/', '', '', 'CAT11', 'B1', 'To stop working, especially because of reaching a certain age.', 'My grandfather plans to retire next year.'),
('PAL0232', 'Reveal', '/ri-víil/', '', '', 'CAT11', 'B1', 'To show something that was previously hidden or unknown.', 'The investigation revealed new information.'),
('PAL0233', 'Rhythm', '/rí-dam/', '', '', 'CAT11', 'B1', 'A regular pattern of beats, sounds, or movements.', 'The song has a strong rhythm.'),
('PAL0234', 'Rugged', '/rá-gid/', '', '', 'CAT11', 'B1', 'Rough, strong, and able to survive difficult conditions.', 'The hikers walked across rugged terrain.'),
('PAL0235', 'Scanty', '/skán-ti/', '', '', 'CAT11', 'B1', 'Small in amount or not enough.', 'The supplies were scanty after the storm.'),
('PAL0236', 'Scared', '/skérd/', '', '', 'CAT11', 'B1', 'Frightened or afraid.', 'The child was scared of the dog.'),
('PAL0237', 'Scenic', '/sí-nik/', '', '', 'CAT11', 'B1', 'Having attractive natural views or scenery.', 'We drove along a scenic road.'),
('PAL0238', 'Scheme', '/skiim/', '', '', 'CAT11', 'B1', 'A plan or system intended to achieve a particular purpose.', 'The company developed a new marketing scheme.'),
('PAL0239', 'School', '/skuul/', '', '', 'CAT11', 'B1', 'A place where children or students go to learn.', 'The children walked to school.'),
('PAL0240', 'Settle', '/sé-tl/', '', '', 'CAT11', 'B1', 'To become comfortable with a new situation or to reach an agreement.', 'It took time to settle into the new routine.'),
('PAL0241', 'Severe', '/si-víer/', '', '', 'CAT11', 'B1', 'Very serious, severe, or extreme.', 'The patient suffered from severe pain.'),
('PAL0242', 'Should', '/shud/', '', '', 'CAT11', 'B1', 'Used to talk about what someone ought to do or what is expected.', 'You should study for the exam.'),
('PAL0243', 'Shrink', '/shrink/', '', '', 'CAT11', 'B1', 'To become smaller or make something smaller.', 'The sweater may shrink in hot water.'),
('PAL0244', 'Signal', '/síg-nal/', '', '', 'CAT11', 'B1', 'A sign, sound, or message that gives information or a warning.', 'The traffic signal turned red.'),
('PAL0245', 'Silver', '/síl-ver/', '', '', 'CAT11', 'B1', 'A shiny gray-white metal.', 'The ring is made of silver.'),
('PAL0246', 'Simmer', '/sí-mer/', '', '', 'CAT11', 'B1', 'To cook something slowly in liquid just below boiling point.', 'Let the soup simmer for ten minutes.'),
('PAL0247', 'Simple', '/sím-pl/', '', '', 'CAT11', 'B1', 'Easy to understand, do, or use.', 'The instructions are simple to follow.'),
('PAL0248', 'Slight', '/slait/', '', '', 'CAT11', 'B1', 'Small in degree or amount.', 'There is a slight difference between them.'),
('PAL0249', 'Smooth', '/smuud/', '', '', 'CAT11', 'B1', 'Having an even surface or texture without roughness.', 'The surface feels smooth.'),
('PAL0250', 'Sorrow', '/só-rou/', '', '', 'CAT11', 'B1', 'A feeling of deep sadness.', 'The poem expresses deep sorrow.'),
('PAL0251', 'Soviet', '/sóu-vi-et/', '', '', 'CAT11', 'B1', 'Related to the former Soviet Union.', 'The museum has a collection of Soviet posters.'),
('PAL0252', 'Sponge', '/spóndsh/', '', '', 'CAT11', 'B1', 'A soft material with many small holes that absorbs liquid.', 'Use a sponge to clean the table.'),
('PAL0253', 'Spread', '/spred/', '', '', 'CAT11', 'B1', 'To spread something over an area or among people.', 'The teacher spread the information among the students.'),
('PAL0254', 'Spring', '/spring/', '', '', 'CAT11', 'B1', 'The season between winter and summer.', 'Flowers begin to grow in spring.'),
('PAL0255', 'Square', '/skuér/', '', '', 'CAT11', 'B1', 'A shape with four equal sides and four right angles.', 'Draw a square around the correct answer.'),
('PAL0256', 'Stable', '/stéi-bl/', '', '', 'CAT11', 'B1', 'Firm, steady, and unlikely to change or fall.', 'The table is stable and will not move.'),
('PAL0257', 'Status', '/stá-tus/', '', '', 'CAT11', 'B1', 'The current situation or position of a person or thing.', 'The student´s status changed after the exam.'),
('PAL0258', 'Steady', '/sté-di/', '', '', 'CAT11', 'B1', 'Firm, regular, and not changing suddenly.', 'She made steady progress in English.'),
('PAL0259', 'Stream', '/striim/', '', '', 'CAT11', 'B1', 'A continuous flow of water or other liquid.', 'The river forms a narrow stream.'),
('PAL0260', 'Street', '/striit/', '', '', 'CAT11', 'B1', 'A public road in a town or city.', 'The school is on the main street.'),
('PAL0261', 'Strict', '/strikt/', '', '', 'CAT11', 'B1', 'Strict and requiring rules to be followed exactly.', 'The teacher has strict rules.'),
('PAL0262', 'Strike', '/straik/', '', '', 'CAT11', 'B1', 'To hit something or stop working suddenly, depending on context.', 'He tried to strike the ball.'),
('PAL0263', 'Struck', '/strak/', '', '', 'CAT11', 'B1', 'Hit something with force or was damaged by impact.', 'The car struck the wall and was badly damaged.'),
('PAL0264', 'Submit', '/sab-mít/', '', '', 'CAT11', 'B1', 'To formally send something for consideration or approval.', 'Please submit your assignment before Friday.'),
('PAL0265', 'Sudden', '/sá-den/', '', '', 'CAT11', 'B1', 'Happening quickly and unexpectedly.', 'There was a sudden change in the weather.'),
('PAL0266', 'Suffer', '/sá-fer/', '', '', 'CAT11', 'B1', 'To experience pain, difficulty, or an unpleasant situation.', 'Many people suffer from stress.'),
('PAL0267', 'Supply', '/sa-plái/', '', '', 'CAT11', 'B1', 'To provide something that is needed or requested.', 'The store supplies food to local restaurants.'),
('PAL0268', 'Thread', '/zred/', '', '', 'CAT11', 'B1', 'A thin strand of cotton, wool, or other material used for sewing or weaving.', 'She used a thread to repair the shirt.'),
('PAL0269', 'Thrive', '/szráiv/', '', '', 'CAT11', 'B1', 'To grow strongly, develop successfully, or become successful.', 'Plants thrive with enough sunlight and water.'),
('PAL0270', 'Throat', '/zróut/', '', '', 'CAT11', 'B1', 'The passage in the neck through which food and air travel.', 'The doctor examined his throat.'),
('PAL0271', 'Ticket', '/tí-ket/', '', '', 'CAT11', 'B1', 'A small piece of paper or electronic document that allows entry or travel.', 'I bought a ticket for the concert.'),
('PAL0272', 'Tiptoe', '/típ-tou/', '', '', 'CAT11', 'B1', 'To walk quietly and carefully on the tips of your toes.', 'The children tiptoed into the room.'),
('PAL0273', 'Tissue', '/tí-shiu/', '', '', 'CAT11', 'B1', 'Soft paper used for cleaning, wiping, or other purposes.', 'Please use a tissue to clean your hands.'),
('PAL0274', 'Tongue', '/tong/', '', '', 'CAT11', 'B1', 'The muscular organ in the mouth used for tasting and speaking.', 'The doctor asked me to stick out my tongue.'),
('PAL0275', 'Treaty', '/trí-ti/', '', '', 'CAT11', 'B1', 'A formal agreement between countries or groups.', 'The two countries signed a peace treaty.'),
('PAL0276', 'Tuning', '/tiú-ning/', '', '', 'CAT11', 'B1', 'The adjustment of musical instruments to the correct pitch.', 'The musician is tuning the guitar.'),
('PAL0277', 'Tunnel', '/tá-nel/', '', '', 'CAT11', 'B1', 'A long passage under or through the ground, a mountain, or another structure.', 'The train passed through the tunnel.'),
('PAL0278', 'Unable', '/an-éi-bl/', '', '', 'CAT11', 'B1', 'Not able to do something.', 'He was unable to attend the competition.'),
('PAL0279', 'Unfair', '/an-fér/', '', '', 'CAT11', 'B1', 'Not fair or not treating people equally.', 'The students said the decision was unfair.'),
('PAL0280', 'United', '/iu-nái-tid/', '', '', 'CAT11', 'B1', 'Joined together or made into one group.', 'The students worked together as a united team.'),
('PAL0281', 'Useful', '/iús-ful/', '', '', 'CAT11', 'B1', 'Helpful or practical for a particular purpose.', 'This website is useful for learning English.'),
('PAL0282', 'Utmost', '/át-moust/', '', '', 'CAT11', 'B1', 'The greatest possible amount or degree.', 'She did her utmost to finish the project.'),
('PAL0283', 'Vacuum', '/vá-kium/', '', '', 'CAT11', 'B1', 'A space with most or all of the air removed.', 'The machine creates a vacuum inside the container.'),
('PAL0284', 'Virtue', '/vér-tsiu/', '', '', 'CAT11', 'B1', 'A good quality or behavior that is considered morally valuable.', 'Honesty is an important virtue.'),
('PAL0285', 'Voyage', '/vói-idsh/', '', '', 'CAT11', 'B1', 'A long journey, especially by sea.', 'The family went on a long voyage.'),
('PAL0286', 'Wander', '/uón-der/', '', '', 'CAT11', 'B1', 'To walk around without a clear purpose or direction.', 'We like to wander around the city.'),
('PAL0287', 'Wealth', '/uelz/', '', '', 'CAT11', 'B1', 'A large amount of money, property, or valuable possessions.', 'The country has great natural wealth.'),
('PAL0288', 'Weekly', '/uíik-li/', '', '', 'CAT11', 'B1', 'Happening or published once every week.', 'The teacher gives us a weekly assignment.'),
('PAL0289', 'Weight', '/ueit/', '', '', 'CAT11', 'B1', 'How heavy something is.', 'The package has a weight of five kilograms.'),
('PAL0290', 'Widget', '/uí-dshet/', '', '', 'CAT11', 'B1', 'A small tool, application, or component that performs a particular function.', 'The website includes a useful weather widget.'),
('PAL0291', 'Window', '/uín-dou/', '', '', 'CAT11', 'B1', 'An opening in a wall with glass that lets in light and allows people to see outside.', 'Please close the window before leaving.'),
('PAL0292', 'Winter', '/uín-ter/', '', '', 'CAT11', 'B1', 'The coldest season of the year.', 'The days are shorter in winter.'),
('PAL0293', 'Account', '/a-káunt/', '', '', 'CAT12', 'B1', 'A record of money kept by a bank for a person or organization.', 'I opened a new bank account last week.'),
('PAL0294', 'Achieve', '/a-chíiv/', '', '', 'CAT12', 'B1', 'To successfully complete something or reach a goal.', 'She worked hard to achieve her goals.'),
('PAL0295', 'Acquire', '/a-kuáiar/', '', '', 'CAT12', 'B1', 'To get or obtain something, especially through effort.', 'He hopes to acquire new skills this year.'),
('PAL0296', 'Airline', '/ér-lain/', '', '', 'CAT12', 'B1', 'A company that provides transportation by air.', 'The airline canceled our flight because of the storm.'),
('PAL0297', 'Amazing', '/a-méi-sing/', '', '', 'CAT12', 'B1', 'Very good, impressive, or surprising.', 'She gave an amazing performance.'),
('PAL0298', 'Analyst', '/á-na-list/', '', '', 'CAT12', 'B1', 'A person who studies information to understand a situation or problem.', 'The analyst examined the company data carefully.'),
('PAL0299', 'Anguish', '/áng-guish/', '', '', 'CAT12', 'B1', 'A strong feeling of pain, sadness, or confusion.', 'The loss caused him great anguish.'),
('PAL0300', 'Another', '/a-ná-der/', '', '', 'CAT12', 'B1', 'One more person or thing of the same type.', 'Would you like another piece of cake?'),
('PAL0301', 'Anxious', '/áng-shos/', '', '', 'CAT12', 'B1', 'Worried or nervous about something that may happen.', 'She felt anxious before the exam.'),
('PAL0302', 'Approve', '/a-prúuv/', '', '', 'CAT12', 'B1', 'To accept or agree to something officially.', 'The manager approved the new plan.'),
('PAL0303', 'Arrange', '/a-réindsh/', '', '', 'CAT12', 'B1', 'To organize or plan something.', 'We need to arrange a meeting for Friday.'),
('PAL0304', 'Arrival', '/a-rái-val/', '', '', 'CAT12', 'B1', 'The act or process of arriving somewhere.', 'The arrival of the train was delayed.'),
('PAL0305', 'Attempt', '/a-témpt/', '', '', 'CAT12', 'B1', 'An effort to do or achieve something.', 'His first attempt was not successful.'),
('PAL0306', 'Attract', '/a-trákt/', '', '', 'CAT12', 'B1', 'To attract someone or something toward you.', 'Bright colors attract many customers.'),
('PAL0307', 'Auction', '/ók-shen/', '', '', 'CAT12', 'B1', 'A public sale in which things are sold to the person offering the most money.', 'She bought the painting at an auction.');
INSERT INTO `palabra` (`codigo`, `significado`, `pronunciacion`, `imagen`, `audio`, `categoria`, `nivel`, `definicion`, `ejemplo`) VALUES
('PAL0308', 'Awkward', '/ók-uerd/', '', '', 'CAT12', 'B1', 'Not comfortable or easy to understand or deal with.', 'He felt awkward during the conversation.'),
('PAL0309', 'Balance', '/bá-lans/', '', '', 'CAT12', 'B1', 'A situation in which different things are in the correct amounts or proportions.', 'She tries to maintain a healthy balance between work and study.'),
('PAL0310', 'Beliefs', '/bi-líifs/', '', '', 'CAT12', 'B1', 'Opinions or ideas that someone accepts as true.', 'His beliefs are very important to him.'),
('PAL0311', 'Believe', '/bi-líiv/', '', '', 'CAT12', 'B1', 'To accept that something is true or real.', 'I believe that she can solve the problem.'),
('PAL0312', 'Broader', '/bró-der/', '', '', 'CAT12', 'B1', 'Wider or more general than something else.', 'The new policy has a broader purpose.'),
('PAL0313', 'Brought', '/brot/', '', '', 'CAT12', 'B1', 'Past tense of bring; carried something to a place.', 'She brought some food for everyone.'),
('PAL0314', 'Capable', '/kéi-pa-bl/', '', '', 'CAT12', 'B1', 'Having the ability or qualities needed to do something.', 'She is capable of solving difficult problems.'),
('PAL0315', 'Careful', '/kér-ful/', '', '', 'CAT12', 'B1', 'Taking care to avoid danger, mistakes, or problems.', 'Be careful when you cross the street.'),
('PAL0316', 'Certain', '/sér-ten/', '', '', 'CAT12', 'B1', 'Having no doubt or uncertainty about something.', 'I am certain that he knows the answer.'),
('PAL0317', 'Chattel', '/chá-tel/', '', '', 'CAT12', 'B1', 'An item of property, especially one that is not common or modern.', 'The museum displayed an old chattel from the nineteenth century.'),
('PAL0318', 'Chronic', '/kró-nik/', '', '', 'CAT12', 'B1', 'Continuing for a long time or difficult to change.', 'He suffers from chronic back pain.'),
('PAL0319', 'Citizen', '/sí-ti-sen/', '', '', 'CAT12', 'B1', 'A person who belongs to a particular country or community.', 'Every citizen has certain rights and responsibilities.'),
('PAL0320', 'Classic', '/klá-sik/', '', '', 'CAT12', 'B1', 'Belonging to a style or type that is considered standard or traditional.', 'She wore a classic black dress.'),
('PAL0321', 'Comfort', '/kám-fort/', '', '', 'CAT12', 'B1', 'A state of physical or emotional ease.', 'The hotel offers comfort and excellent service.'),
('PAL0322', 'Company', '/kám-pa-ni/', '', '', 'CAT12', 'B1', 'A business organization that sells goods or services.', 'The company opened a new office downtown.'),
('PAL0323', 'Compare', '/kom-pér/', '', '', 'CAT12', 'B1', 'To examine two or more things to see how they are similar or different.', 'We need to compare the two computers before buying one.'),
('PAL0324', 'Compete', '/kom-píit/', '', '', 'CAT12', 'B1', 'To try to win or succeed against someone or something.', 'Several teams will compete in the tournament.'),
('PAL0325', 'Complex', '/kóm-pleks/', '', '', 'CAT12', 'B1', 'Complicated and made of many connected parts.', 'The human brain is a complex organ.'),
('PAL0326', 'Concern', '/kon-sérn/', '', '', 'CAT12', 'B1', 'A feeling of worry about something.', 'There is growing concern about pollution.'),
('PAL0327', 'Confirm', '/kon-férm/', '', '', 'CAT12', 'B1', 'To state that something is true or correct.', 'Please confirm your appointment by email.'),
('PAL0328', 'Connect', '/ko-nékt/', '', '', 'CAT12', 'B1', 'To join or link people or things together.', 'The bridge connects the two towns.'),
('PAL0329', 'Consent', '/kon-sént/', '', '', 'CAT12', 'B1', 'Permission or agreement to do something.', 'You need your parents consent before joining the trip.'),
('PAL0330', 'Contain', '/kon-téin/', '', '', 'CAT12', 'B1', 'To have or include something as a part.', 'The course contains several practical activities.'),
('PAL0331', 'Control', '/kon-tróul/', '', '', 'CAT12', 'B1', 'To manage or direct people or activities.', 'She controls the project schedule.'),
('PAL0332', 'Correct', '/ko-rékt/', '', '', 'CAT12', 'B1', 'Free from mistakes or errors.', 'Please make sure the information is correct.'),
('PAL0333', 'Country', '/kán-tri/', '', '', 'CAT12', 'B1', 'A nation or area with its own government.', 'France is a European country.'),
('PAL0334', 'Courage', '/ká-ridsh/', '', '', 'CAT12', 'B1', 'The ability to face fear, pain, or difficulty.', 'It takes courage to speak in front of a large audience.'),
('PAL0335', 'Curious', '/kiú-ri-os//', '', '', 'CAT12', 'B1', 'Wanting to know or learn about something.', 'The curious student asked many questions.'),
('PAL0336', 'Current', '/ká-rent/', '', '', 'CAT12', 'B1', 'Happening or existing at the present time.', 'The current situation requires careful planning.'),
('PAL0337', 'Curtain', '/kér-ten/', '', '', 'CAT12', 'B1', 'A covering used to close or decorate a window or room.', 'She opened the curtain to let in the sunlight.'),
('PAL0338', 'Cushion', '/kú-shen/', '', '', 'CAT12', 'B1', 'A soft object used to support the head or body.', 'I put a cushion on the chair.'),
('PAL0339', 'Decorum', '/di-kó-ram/', '', '', 'CAT12', 'B1', 'Behavior or manners that are considered proper or acceptable.', 'Good decorum is expected during the ceremony.'),
('PAL0340', 'Deserve', '/di-sérv/', '', '', 'CAT12', 'B1', 'To be worthy of something or to have a right to receive it.', 'You deserve a reward for your hard work.'),
('PAL0341', 'Dessert', '/di-sért/', '', '', 'CAT12', 'B1', 'A sweet food usually eaten at the end of a meal.', 'We ordered chocolate cake for dessert.'),
('PAL0342', 'Destroy', '/di-strói/', '', '', 'CAT12', 'B1', 'To damage something so badly that it cannot be used.', 'The fire destroyed several buildings.'),
('PAL0343', 'Develop', '/di-vé-lop/', '', '', 'CAT12', 'B1', 'To grow or change into a more advanced form.', 'Children develop new skills as they grow.'),
('PAL0344', 'Discuss', '/dis-kás/', '', '', 'CAT12', 'B1', 'To talk about something with another person or group.', 'We need to discuss the project tomorrow.'),
('PAL0345', 'Disease', '/di-síis/', '', '', 'CAT12', 'B1', 'An illness or medical condition.', 'The doctor treated the disease quickly.'),
('PAL0346', 'Disgust', '/dis-gást/', '', '', 'CAT12', 'B1', 'A strong feeling of dislike or opposition.', 'He expressed disgust at the dirty kitchen.'),
('PAL0347', 'Dislike', '/dis-láik/', '', '', 'CAT12', 'B1', 'To not enjoy or approve of someone or something.', 'I dislike waiting in long lines.'),
('PAL0348', 'Driving', '/drái-ving/', '', '', 'CAT12', 'B1', 'Moving or operating a vehicle.', 'Driving requires attention and responsibility.'),
('PAL0349', 'Eastern', '/íis-tern/', '', '', 'CAT12', 'B1', 'Related to the east.', 'The eastern part of the country receives less rain.'),
('PAL0350', 'Economy', '/i-kó-no-mi/', '', '', 'CAT12', 'B1', 'The system by which money, goods, and services are produced and used.', 'The economy is growing slowly this year.'),
('PAL0351', 'Embassy', '/ém-ba-si/', '', '', 'CAT12', 'B1', 'A building or office used by representatives of one country in another country.', 'The ambassador works at the embassy.'),
('PAL0352', 'Enhance', '/en-jáns/', '', '', 'CAT12', 'B1', 'To improve something or make it more attractive or effective.', 'The new technology will enhance the learning experience.'),
('PAL0353', 'Ensnare', '/en-snér/', '', '', 'CAT12', 'B1', 'To trap or capture someone or something.', 'The spider can ensnare insects in its web.'),
('PAL0354', 'Enzymes', '/én-saims/', '', '', 'CAT12', 'B1', 'Proteins that help chemical reactions happen in living organisms.', 'Enzymes help the body digest food.'),
('PAL0355', 'Evening', '/íiv-ning/', '', '', 'CAT12', 'B1', 'The part of the day between afternoon and night.', 'We usually exercise in the evening.'),
('PAL0356', 'Examine', '/eg-sá-min/', '', '', 'CAT12', 'B1', 'To look at or study something carefully in order to understand it.', 'The teacher asked us to examine the results.'),
('PAL0357', 'Excited', '/ek-sái-tid/', '', '', 'CAT12', 'B1', 'Feeling very happy or enthusiastic about something.', 'The children were excited about the school trip.'),
('PAL0358', 'Exhibit', '/eg-sí-bit/', '', '', 'CAT12', 'B1', 'To show something publicly or make it visible.', 'The museum will exhibit several paintings.'),
('PAL0359', 'Explain', '/ek-spléin/', '', '', 'CAT12', 'B1', 'To make something clear or easy to understand.', 'Can you explain this grammar rule?'),
('PAL0360', 'Explore', '/ek-splór/', '', '', 'CAT12', 'B1', 'To travel around or investigate a place or subject.', 'We want to explore the city this weekend.'),
('PAL0361', 'Express', '/ek-sprés/', '', '', 'CAT12', 'B1', 'To communicate an idea or feeling clearly.', 'She expressed her opinion politely.'),
('PAL0362', 'Feather', '/fé-der/', '', '', 'CAT12', 'B1', 'A covering of soft hair, wool, or feathers on an animal.', 'The bird has a beautiful feather.'),
('PAL0363', 'Feature', '/fí-tsiur/', '', '', 'CAT12', 'B1', 'A characteristic or important part of something.', 'One useful feature of the app is its simple design.'),
('PAL0364', 'Feeling', '/fíi-ling/', '', '', 'CAT12', 'B1', 'An emotion or state of being aware of something.', 'She had a strange feeling that something was wrong.'),
('PAL0365', 'Fellow', '/fé-lou/', '', '', 'CAT12', 'B1', 'A person who is in the same situation or group as another person.', 'He is my fellow student.'),
('PAL0366', 'Fiction', '/fík-shen/', '', '', 'CAT12', 'B1', 'Writing or stories about imaginary events and characters.', 'She enjoys reading science fiction.'),
('PAL0367', 'Foreign', '/fó-ren/', '', '', 'CAT12', 'B1', 'Related to a country or culture outside your own.', 'The university offers several foreign language courses.'),
('PAL0368', 'Forgive', '/for-gív/', '', '', 'CAT12', 'B1', 'To stop being angry with someone for something they did wrong.', 'I hope you can forgive me for my mistake.'),
('PAL0369', 'Forward', '/fór-uerd/', '', '', 'CAT12', 'B1', 'Toward the future or in the direction ahead.', 'We need to move forward with the project.'),
('PAL0370', 'Freeman', '/fríi-man/', '', '', 'CAT12', 'B1', 'A person who is free and has no master or employer, often used as a name or historical term.', 'The story describes Freeman as an independent man.'),
('PAL0371', 'Friable', '/frái-a-bl/', '', '', 'CAT12', 'B1', 'Easily broken, damaged, or affected.', 'The old material was friable and broke easily.'),
('PAL0372', 'Genuine', '/dshén-iu-in/', '', '', 'CAT12', 'B1', 'Real, sincere, and honest.', 'She gave a genuine apology.'),
('PAL0373', 'Harmony', '/jár-mo-ni/', '', '', 'CAT12', 'B1', 'A peaceful relationship or agreement between people or groups.', 'The family lived together in harmony.'),
('PAL0374', 'Healthy', '/jél-zi/', '', '', 'CAT12', 'B1', 'In good physical or mental condition.', 'Regular exercise helps you stay healthy.'),
('PAL0375', 'Hearing', '/jíe-ring/', '', '', 'CAT12', 'B1', 'The ability to hear or the act of listening to sounds.', 'His hearing improved after the treatment.'),
('PAL0376', 'Helpful', '/jélp-ful/', '', '', 'CAT12', 'B1', 'Willing to help or useful to someone.', 'The helpful teacher explained the exercise again.'),
('PAL0377', 'Highway', '/jái-uei/', '', '', 'CAT12', 'B1', 'A main road connecting cities or important places.', 'The highway was crowded during the holiday.'),
('PAL0378', 'History', '/jís-to-ri/', '', '', 'CAT12', 'B1', 'All the events and experiences that happened in the past.', 'She loves studying history at school.'),
('PAL0379', 'Holiday', '/jó-li-dei/', '', '', 'CAT12', 'B1', 'A period when people do not work or attend school, often for travel or rest.', 'We are planning a holiday in July.'),
('PAL0380', 'Illegal', '/i-lí-gal/', '', '', 'CAT12', 'B1', 'Not allowed by law.', 'It is illegal to park here.'),
('PAL0381', 'Illness', '/íl-nes/', '', '', 'CAT12', 'B1', 'An illness or period of poor health.', 'She missed school because of an illness.'),
('PAL0382', 'Impress', '/im-prés/', '', '', 'CAT12', 'B1', 'To cause someone to admire or respect you.', 'Her speech impressed the audience.'),
('PAL0383', 'Improve', '/im-prúuv/', '', '', 'CAT12', 'B1', 'To become better or make something better.', 'Practice can improve your pronunciation.'),
('PAL0384', 'Impulse', '/ím-pals/', '', '', 'CAT12', 'B1', 'A sudden strong desire or reaction that may be difficult to control.', 'He had an impulse to buy the expensive phone.'),
('PAL0385', 'Include', '/in-klúud/', '', '', 'CAT12', 'B1', 'To contain something as part of a whole.', 'The course includes practical exercises.'),
('PAL0386', 'Initial', '/i-ní-shal/', '', '', 'CAT12', 'B1', 'Happening or existing at the beginning of something.', 'The initial plan was changed later.'),
('PAL0387', 'Install', '/in-stól/', '', '', 'CAT12', 'B1', 'To put a system, program, or equipment into use.', 'We need to install the software first.'),
('PAL0388', 'Involve', '/in-vólv/', '', '', 'CAT12', 'B1', 'To include or involve someone or something.', 'The project involves several students.'),
('PAL0389', 'Jointly', '/dshóint-li/', '', '', 'CAT12', 'B1', 'Together or in cooperation with others.', 'The students worked jointly on the presentation.'),
('PAL0390', 'Journey', '/dshér-ni/', '', '', 'CAT12', 'B1', 'A trip or movement from one place to another.', 'Our journey took five hours.'),
('PAL0391', 'Justify', '/dshás-ti-fai/', '', '', 'CAT12', 'B1', 'To show or prove that something is reasonable or right.', 'Can you justify your answer?'),
('PAL0392', 'Kingdom', '/kíng-dom/', '', '', 'CAT12', 'B1', 'A country or area ruled by a king or queen.', 'The museum tells the history of the ancient kingdom.'),
('PAL0393', 'Kitchen', '/kí-tshen/', '', '', 'CAT12', 'B1', 'A room where food is prepared and cooked.', 'My mother is making dinner in the kitchen.'),
('PAL0394', 'Leading', '/líi-ding/', '', '', 'CAT12', 'B1', 'Going first or being more advanced than others.', 'She is a leading expert in the field.'),
('PAL0395', 'Leather', '/lé-der/', '', '', 'CAT12', 'B1', 'Animal skin prepared and used as material.', 'The jacket is made of leather.'),
('PAL0396', 'Leisure', '/lé-shur/', '', '', 'CAT12', 'B1', 'Free time used for relaxation or enjoyment.', 'She enjoys reading during her leisure time.'),
('PAL0397', 'Manager', '/má-na-dsher/', '', '', 'CAT12', 'B1', 'A person who is responsible for controlling or organizing a business or activity.', 'The manager organized the meeting.'),
('PAL0398', 'Massive', '/má-siv/', '', '', 'CAT12', 'B1', 'Very large, heavy, or important.', 'The company made a massive investment.'),
('PAL0399', 'Maximum', '/mák-si-mom/', '', '', 'CAT12', 'B1', 'The greatest possible amount, size, or degree.', 'The machine can reach a maximum speed of 100 kilometers per hour.'),
('PAL0400', 'Measure', '/mé-shur/', '', '', 'CAT12', 'B1', 'To find out the size, amount, or degree of something.', 'The scientist will measure the temperature.'),
('PAL0401', 'Seaweed', '/síi-uiid/', '', '', 'CAT12', 'B1', 'A plant that lives mainly in the sea and resembles a simple plant.', 'Seaweed grows near the rocky coast.'),
('PAL0402', 'Mention', '/mén-shen/', '', '', 'CAT12', 'B1', 'To talk about or refer to something.', 'She mentioned your name during the meeting.'),
('PAL0403', 'Midwife', '/míd-uaif/', '', '', 'CAT12', 'B1', 'A woman who helps other women give birth.', 'The midwife helped the mother during childbirth.'),
('PAL0404', 'Minimum', '/mí-ni-mom/', '', '', 'CAT12', 'B1', 'The smallest amount or number.', 'The minimum age for the activity is eighteen.'),
('PAL0405', 'Mission', '/mí-shen/', '', '', 'CAT12', 'B1', 'An organized group of people with a particular purpose.', 'The mission helps people in remote communities.'),
('PAL0406', 'Monthly', '/mánz-li/', '', '', 'CAT12', 'B1', 'Happening once every month.', 'The club publishes a monthly newsletter.'),
('PAL0407', 'Neglect', '/ni-glékt/', '', '', 'CAT12', 'B1', 'To pay little or no attention to something.', 'Do not neglect your homework.'),
('PAL0408', 'Neither', '/ní-der/', '', '', 'CAT12', 'B1', 'Not one and not the other of two possibilities.', 'Neither answer is correct.'),
('PAL0409', 'Nervous', '/nér-vos/', '', '', 'CAT12', 'B1', 'Worried or afraid about something.', 'He felt nervous before speaking in public.'),
('PAL0410', 'Network', '/nét-uerk/', '', '', 'CAT12', 'B1', 'A group of connected people, computers, or organizations.', 'The school has a computer network.'),
('PAL0411', 'Nowhere', '/nóu-juer/', '', '', 'CAT12', 'B1', 'Not in any place or no place.', 'There was nowhere to sit.'),
('PAL0412', 'Observe', '/ob-sérv/', '', '', 'CAT12', 'B1', 'To watch, notice, or study something carefully.', 'Scientists observe the animals in their natural environment.'),
('PAL0413', 'Obvious', '/ób-vi-os/', '', '', 'CAT12', 'B1', 'Easy to see, understand, or recognize.', 'The difference between the two colors is obvious.'),
('PAL0414', 'Operate', '/ó-pe-reit/', '', '', 'CAT12', 'B1', 'To work, function, or manage an activity.', 'The machine operates automatically.'),
('PAL0415', 'Outside', '/aut-sáid/', '', '', 'CAT12', 'B1', 'Situated outside or beyond a particular place.', 'The students waited outside the classroom.'),
('PAL0416', 'Overall', '/óu-ver-ol/', '', '', 'CAT12', 'B1', 'Including everything or considering the whole situation.', 'Overall, the project was successful.'),
('PAL0417', 'Parking', '/pár-king/', '', '', 'CAT12', 'B1', 'The act of leaving a vehicle in a particular place.', 'Parking is difficult near the university.'),
('PAL0418', 'Passage', '/pá-sidsh/', '', '', 'CAT12', 'B1', 'A way through or along something; also a section of a journey.', 'The passage through the mountains was dangerous.'),
('PAL0419', 'Patient', '/péi-shent/', '', '', 'CAT12', 'B1', 'Able to wait calmly or accept delays without becoming angry.', 'You need to be patient when learning a new language.'),
('PAL0420', 'Paucity', '/pó-si-ti/', '', '', 'CAT12', 'B1', 'A lack or small amount of something.', 'There is a paucity of information about the topic.'),
('PAL0421', 'Payment', '/péi-ment/', '', '', 'CAT12', 'B1', 'Money given in exchange for a product or service.', 'The payment must be made before delivery.'),
('PAL0422', 'Perfect', '/pér-fekt/', '', '', 'CAT12', 'B1', 'As good as possible or without mistakes.', 'She gave a perfect answer.'),
('PAL0423', 'Perform', '/per-fórm/', '', '', 'CAT12', 'B1', 'To do something or carry out a task.', 'The students must perform the experiment carefully.'),
('PAL0424', 'Phoneme', '/fóu-niim/', '', '', 'CAT12', 'B1', 'The smallest unit of sound in a language that can change meaning.', 'The teacher explained how each phoneme is pronounced.'),
('PAL0425', 'Possess', '/po-sés/', '', '', 'CAT12', 'B1', 'To have or own something.', 'The museum possesses several valuable paintings.'),
('PAL0426', 'Powdery', '/páu-de-ri/', '', '', 'CAT12', 'B1', 'Having a soft texture and a surface covered with fine powder.', 'The powdery snow covered the ground.'),
('PAL0427', 'Prepare', '/pri-pér/', '', '', 'CAT12', 'B1', 'To get ready for something.', 'We need to prepare for the English exam.'),
('PAL0428', 'Pretend', '/pri-ténd/', '', '', 'CAT12', 'B1', 'To pretend that something is true when it is not.', 'The children pretended to be astronauts.'),
('PAL0429', 'Prevent', '/pri-vént/', '', '', 'CAT12', 'B1', 'To stop something from happening.', 'Wearing a helmet can prevent serious injuries.'),
('PAL0430', 'Proceed', '/pro-síid/', '', '', 'CAT12', 'B1', 'To continue with an action or process.', 'Please proceed to the next exercise.'),
('PAL0431', 'Process', '/pró-ses/', '', '', 'CAT12', 'B1', 'A series of actions or changes that happen over time.', 'Learning a language is a gradual process.'),
('PAL0432', 'Produce', '/pro-diús/', '', '', 'CAT12', 'B1', 'To make or create something.', 'The factory produces electronic equipment.'),
('PAL0433', 'Promise', '/pró-mis/', '', '', 'CAT12', 'B1', 'To say that you will do or give something.', 'He promised to help me with my homework.'),
('PAL0434', 'Propose', '/pro-póus/', '', '', 'CAT12', 'B1', 'To suggest or present an idea for consideration.', 'She proposed a new solution to the problem.'),
('PAL0435', 'Purpose', '/pér-pos/', '', '', 'CAT12', 'B1', 'The reason or intention for doing something.', 'The purpose of this activity is to practice spelling.'),
('PAL0436', 'Qualify', '/kuó-li-fai/', '', '', 'CAT12', 'B1', 'To meet the necessary conditions or requirements.', 'Students must qualify for the competition.'),
('PAL0437', 'Quality', '/kuó-li-ti/', '', '', 'CAT12', 'B1', 'How good or useful something is.', 'The teacher checked the quality of the students work.'),
('PAL0438', 'Quarter', '/kuór-ter/', '', '', 'CAT12', 'B1', 'One of four equal parts of something.', 'She ate a quarter of the cake.'),
('PAL0439', 'Railway', '/réil-uei/', '', '', 'CAT12', 'B1', 'A system of tracks and trains used for transportation.', 'The railway connects several cities.'),
('PAL0440', 'Reading', '/ríi-ding/', '', '', 'CAT12', 'B1', 'The activity of looking at or understanding written words.', 'Reading every day can improve your vocabulary.'),
('PAL0441', 'Realize', '/rí-a-lais/', '', '', 'CAT12', 'B1', 'To understand or become aware of something.', 'She realized that she had forgotten her notebook.'),
('PAL0442', 'Receipt', '/ri-síit/', '', '', 'CAT12', 'B1', 'A written or electronic document showing that something was received or purchased.', 'Keep the receipt in case you need to return the product.'),
('PAL0443', 'Receive', '/ri-síiv/', '', '', 'CAT12', 'B1', 'To get something that you have been given or sent.', 'Did you receive my email?'),
('PAL0444', 'Reflect', '/ri-flékt/', '', '', 'CAT12', 'B1', 'To think carefully about something again.', 'He reflected on his mistakes after the exam.'),
('PAL0445', 'Relieve', '/ri-líiv/', '', '', 'CAT12', 'B1', 'To make someone feel less worried or to reduce pain or difficulty.', 'The medicine helped relieve her pain.'),
('PAL0446', 'Replace', '/ri-pléis/', '', '', 'CAT12', 'B1', 'To put something in place of another thing.', 'We need to replace the broken keyboard.'),
('PAL0447', 'Request', '/ri-kuést/', '', '', 'CAT12', 'B1', 'To ask for something politely or officially.', 'You can request a copy of the document.'),
('PAL0448', 'Require', '/ri-kuáiar/', '', '', 'CAT12', 'B1', 'To need something because of a rule or situation.', 'The course requires regular practice.'),
('PAL0449', 'Revenge', '/ri-véndsh/', '', '', 'CAT12', 'B1', 'A feeling of anger or a desire to hurt someone because of something they did.', 'He wanted revenge after the argument.'),
('PAL0450', 'Routine', '/ruu-tíin/', '', '', 'CAT12', 'B1', 'A usual way of doing things or a regular pattern.', 'My morning routine includes reading the news.'),
('PAL0451', 'Satisfy', '/sá-tis-fai/', '', '', 'CAT12', 'B1', 'To do what is necessary to make someone happy or satisfied.', 'The service aims to satisfy every customer.'),
('PAL0452', 'Savings', '/séi-vings/', '', '', 'CAT12', 'B1', 'Money that has been saved rather than spent.', 'Her savings helped pay for the trip.'),
('PAL0453', 'Science', '/sái-ens/', '', '', 'CAT12', 'B1', 'The study of the natural world through observation and experiments.', 'Science helps us understand how the world works.'),
('PAL0454', 'Serious', '/sí-ri-os/', '', '', 'CAT12', 'B1', 'Having or showing a serious attitude or importance.', 'This is a serious problem that needs attention.'),
('PAL0455', 'Servant', '/sér-vant/', '', '', 'CAT12', 'B1', 'A person who works for or serves another person or organization.', 'The servant prepared the room for the guests.'),
('PAL0456', 'Society', '/so-sái-e-ti/', '', '', 'CAT12', 'B1', 'A community of people living together or sharing a culture.', 'Society changes as technology develops.'),
('PAL0457', 'Somehow', '/sám-jau/', '', '', 'CAT12', 'B1', 'In some way or by some means that is not specified.', 'Somehow, we managed to finish the project on time.'),
('PAL0458', 'Specify', '/espé-si-fai/', '', '', 'CAT12', 'B1', 'To state or describe something clearly and specifically.', 'Please specify which option you want.'),
('PAL0459', 'Station', '/stéi-shen/', '', '', 'CAT12', 'B1', 'A place or building where trains stop for passengers.', 'We arrived at the station early.'),
('PAL0460', 'Stomach', '/stó-mak/', '', '', 'CAT12', 'B1', 'The internal organ that helps digest food.', 'Eating too quickly can upset your stomach.'),
('PAL0461', 'Strange', '/stréindsh/', '', '', 'CAT12', 'B1', 'Unusual or surprising in a way that is difficult to understand.', 'It was strange to see the store completely empty.'),
('PAL0462', 'Stretch', '/stretsh/', '', '', 'CAT12', 'B1', 'To make something longer or larger.', 'You should stretch your legs after sitting for a long time.'),
('PAL0463', 'Subject', '/sáb-dshekt/', '', '', 'CAT12', 'B1', 'A topic or area of study or discussion.', 'English is my favorite school subject.'),
('PAL0464', 'Succeed', '/sak-síid/', '', '', 'CAT12', 'B1', 'To successfully do or achieve something.', 'She succeeded in passing the difficult exam.'),
('PAL0465', 'Suggest', '/sag-dshést/', '', '', 'CAT12', 'B1', 'To give someone an idea or recommend something.', 'I suggest studying for thirty minutes every day.'),
('PAL0466', 'Support', '/sa-pórt/', '', '', 'CAT12', 'B1', 'To help or encourage someone or something.', 'My friends support me when I have problems.'),
('PAL0467', 'Suppose', '/sa-póus/', '', '', 'CAT12', 'B1', 'To accept something as true or possible without proof.', 'I suppose we can meet after class.'),
('PAL0468', 'Survive', '/ser-váiv/', '', '', 'CAT12', 'B1', 'To continue to live or exist despite difficulties.', 'Many plants cannot survive without water.'),
('PAL0469', 'Thought', '/zot/', '', '', 'CAT12', 'B1', 'An idea or opinion about something.', 'The teacher asked for our thoughts about the story.'),
('PAL0470', 'Thunder', '/zán-der/', '', '', 'CAT12', 'B1', 'A loud sound caused by electricity during a storm.', 'We heard thunder after the lightning.'),
('PAL0471', 'Triumph', '/trái-umf/', '', '', 'CAT12', 'B1', 'A great achievement or victory.', 'Winning the competition was a great triumph.'),
('PAL0472', 'Trouble', '/trá-bl/', '', '', 'CAT12', 'B1', 'A difficult situation or problem.', 'Learning a new language can be a challenge, but it is worth it.'),
('PAL0473', 'Typical', '/tí-pi-kal/', '', '', 'CAT12', 'B1', 'Typical of a particular group, time, or situation.', 'This weather is typical for the region in winter.'),
('PAL0474', 'Unusual', '/an-iú-shu-al/', '', '', 'CAT12', 'B1', 'Different from what is usual or expected.', 'It is unusual to see snow in this city.'),
('PAL0475', 'Various', '/vé-ri-os/', '', '', 'CAT12', 'B1', 'Different or several kinds of things or people.', 'The library has various books about science.'),
('PAL0476', 'Venture', '/vén-tsiur/', '', '', 'CAT12', 'B1', 'An attempt to do something or a business activity involving risk.', 'Starting a new business can be a difficult venture.'),
('PAL0477', 'Violent', '/vái-o-lent/', '', '', 'CAT12', 'B1', 'Using physical force to hurt or damage someone or something.', 'The movie contains a violent scene.'),
('PAL0478', 'Visible', '/ví-si-bl/', '', '', 'CAT12', 'B1', 'Easy to see or notice.', 'The mountain was visible from the road.'),
('PAL0479', 'Weather', '/ué-der/', '', '', 'CAT12', 'B1', 'The condition of the atmosphere at a particular time and place.', 'The weather is sunny today.'),
('PAL0480', 'Western', '/ués-tern/', '', '', 'CAT12', 'B1', 'Related to the west.', 'The western part of the country is very dry.'),
('PAL0481', 'Whistle', '/uís-l/', '', '', 'CAT12', 'B1', 'To make a high sound by blowing air through your lips or a small instrument.', 'He can whistle a popular song.'),
('PAL0482', 'Willing', '/uí-ling/', '', '', 'CAT12', 'B1', 'Ready or happy to do something.', 'She is willing to help her classmates.'),
('PAL0483', 'Writing', '/rái-ting/', '', '', 'CAT12', 'B1', 'The activity of producing letters or words on a surface or screen.', 'Writing in English every day improves your skills.'),
('PAL0484', 'Accuracy', '/á-kiu-ra-si/', '', '', 'CAT13', 'B1', 'The quality of being exactly correct.', 'The accuracy of the report was checked twice.'),
('PAL0485', 'Accurate', '/á-kiu-ret/', '', '', 'CAT13', 'B1', 'Correct and free of mistakes.', 'Her answer was accurate and complete.'),
('PAL0486', 'Aeration', '/e-réi-shen/', '', '', 'CAT13', 'B1', 'The process of mixing air into soil, water or another substance.', 'Aeration helps the grass roots get more oxygen.'),
('PAL0487', 'Alliance', '/a-lái-ans/', '', '', 'CAT13', 'B1', 'A formal agreement between groups or countries to work together.', 'The two countries formed an alliance to protect their trade.'),
('PAL0488', 'Almighty', '/ol-mái-ti/', '', '', 'CAT13', 'B1', 'Having complete power; all-powerful.', 'Many people pray to an almighty God.'),
('PAL0489', 'Announce', '/a-náuns/', '', '', 'CAT13', 'B1', 'To tell people something publicly.', 'The teacher will announce the winners tomorrow.'),
('PAL0490', 'Anointed', '/a-nóin-tid/', '', '', 'CAT13', 'B1', 'Rubbed with oil as part of a religious ceremony.', 'The new king was anointed with holy oil.'),
('PAL0491', 'Antihero', '/án-ti-jí-rou/', '', '', 'CAT13', 'B1', 'A main character in a story who does not have the usual heroic qualities.', 'The antihero in the film is selfish but still likable.'),
('PAL0492', 'Appendix', '/a-pén-diks/', '', '', 'CAT13', 'B1', 'A section of extra information at the end of a book; also a small organ in the body.', 'The full list of sources is in the appendix.'),
('PAL0493', 'Approach', '/a-próutsh/', '', '', 'CAT13', 'B1', 'To come near; or a way of dealing with a problem.', 'Please approach the desk when your name is called.'),
('PAL0494', 'Approval', '/a-prúu-val/', '', '', 'CAT13', 'B1', 'Official permission or a good opinion of something.', 'You need approval from your teacher before you start.'),
('PAL0495', 'Argument', '/ár-giu-ment/', '', '', 'CAT13', 'B1', 'A disagreement, or a set of reasons used to support an idea.', 'They had an argument about who would drive.'),
('PAL0496', 'Astonish', '/as-tó-nish/', '', '', 'CAT13', 'B1', 'To surprise someone very much.', 'The magic trick will astonish the children.'),
('PAL0497', 'Baritone', '/bá-ri-toun/', '', '', 'CAT13', 'B1', 'A male singing voice lower than a tenor and higher than a bass.', 'The baritone sang a deep and powerful solo.'),
('PAL0498', 'Behavior', '/bi-héi-vior/', '', '', 'CAT13', 'B1', 'The way a person or an animal acts.', 'The teacher praised the students for their good behavior.'),
('PAL0499', 'Boundary', '/báun-da-ri/', '', '', 'CAT13', 'B1', 'A line that marks the limit of an area.', 'A tall fence marks the boundary of the farm.'),
('PAL0500', 'Breeding', '/bríi-ding/', '', '', 'CAT13', 'B1', 'The raising of animals or plants to produce young ones.', 'The breeding of horses is her family business.'),
('PAL0501', 'Building', '/bíl-ding/', '', '', 'CAT13', 'B1', 'A structure with walls and a roof.', 'The building has ten floors.'),
('PAL0502', 'Business', '/bís-nes/', '', '', 'CAT13', 'B1', 'An organization that sells goods or services.', 'She started a small business selling handmade candles.'),
('PAL0503', 'Campaign', '/kam-péin/', '', '', 'CAT13', 'B1', 'A planned series of actions to reach a goal, such as winning an election.', 'The campaign to save the park lasted six months.'),
('PAL0504', 'Carriage', '/ká-ridsh/', '', '', 'CAT13', 'B1', 'A vehicle with wheels, usually pulled by horses.', 'The princess arrived in a golden carriage.'),
('PAL0505', 'Cautious', '/kó-shos/', '', '', 'CAT13', 'B1', 'Careful to avoid danger or mistakes.', 'Be cautious when you cross the street.'),
('PAL0506', 'Chemical', '/ké-mi-kal/', '', '', 'CAT13', 'B1', 'A substance made by or used in chemistry.', 'The factory keeps every chemical in a locked room.'),
('PAL0507', 'Churlish', '/chér-lish/', '', '', 'CAT13', 'B1', 'Rude and unfriendly.', 'His churlish reply upset everyone at the table.'),
('PAL0508', 'Complain', '/kom-pléin/', '', '', 'CAT13', 'B1', 'To say that you are unhappy about something.', 'Customers often complain when the service is slow.'),
('PAL0509', 'Coverage', '/ká-ve-ridsh/', '', '', 'CAT13', 'B1', 'The amount of attention the media gives to an event; also protection provided by insurance.', 'The news gave full coverage of the final game.'),
('PAL0510', 'Creative', '/kri-éi-tiv/', '', '', 'CAT13', 'B1', 'Able to produce new and original ideas or things.', 'She is very creative and paints beautiful pictures.'),
('PAL0511', 'Cultural', '/kál-tshe-ral/', '', '', 'CAT13', 'B1', 'Related to the customs, arts and beliefs of a group of people.', 'The city hosts a cultural festival every summer.'),
('PAL0512', 'Daughter', '/dó-ter/', '', '', 'CAT13', 'B1', 'A female child in relation to her parents.', 'Their daughter starts school next week.'),
('PAL0513', 'Decision', '/di-sí-shen/', '', '', 'CAT13', 'B1', 'A choice made after thinking about it.', 'It was a hard decision, but she chose to move.'),
('PAL0514', 'Deletion', '/di-lí-shen/', '', '', 'CAT13', 'B1', 'The act of removing or erasing something.', 'The deletion of the file was an accident.'),
('PAL0515', 'Designer', '/di-sái-ner/', '', '', 'CAT13', 'B1', 'A person who plans how something will look or work.', 'The designer created a new logo for the school.'),
('PAL0516', 'Disagree', '/dis-a-gríi/', '', '', 'CAT13', 'B1', 'To have a different opinion from someone else.', 'I disagree with you, but I respect your idea.'),
('PAL0517', 'Disclose', '/dis-klóus/', '', '', 'CAT13', 'B1', 'To make secret information known.', 'The company refused to disclose the price.'),
('PAL0518', 'Distinct', '/dis-tínkt/', '', '', 'CAT13', 'B1', 'Clearly different or easy to notice.', 'Each bird has a distinct song.'),
('PAL0519', 'Dizzying', '/dí-si-ing/', '', '', 'CAT13', 'B1', 'Causing a feeling of spinning or confusion; extremely high or fast.', 'The view from the top of the tower was dizzying.'),
('PAL0520', 'Doubtful', '/dáut-ful/', '', '', 'CAT13', 'B1', 'Not sure, or not likely to be true.', 'I am doubtful that it will stop raining today.'),
('PAL0521', 'Downtown', '/daun-táun/', '', '', 'CAT13', 'B1', 'The central business area of a city.', 'We had lunch at a small restaurant downtown.'),
('PAL0522', 'Dramatic', '/dra-má-tik/', '', '', 'CAT13', 'B1', 'Sudden and exciting, or full of strong emotion.', 'There was a dramatic change in the weather.'),
('PAL0523', 'Dynamics', '/dai-ná-miks/', '', '', 'CAT13', 'B1', 'The forces or patterns that cause change in a group or system.', 'The dynamics of the team improved after the meeting.'),
('PAL0524', 'Eligible', '/é-li-dshi-bl/', '', '', 'CAT13', 'B1', 'Having the right to do or receive something.', 'Students with good grades are eligible for a scholarship.'),
('PAL0525', 'Emphasis', '/ém-fa-sis/', '', '', 'CAT13', 'B1', 'Special importance or attention given to something.', 'The teacher put emphasis on clear pronunciation.'),
('PAL0526', 'Enormous', '/i-nór-mos/', '', '', 'CAT13', 'B1', 'Extremely large.', 'An enormous elephant walked slowly across the road.'),
('PAL0527', 'Evacuees', '/i-va-kiu-íis/', '', '', 'CAT13', 'B1', 'People who are moved from a dangerous place to a safe one.', 'The evacuees stayed in a school until the flood ended.'),
('PAL0528', 'Exchange', '/eks-chéindsh/', '', '', 'CAT13', 'B1', 'To give something and receive something else in return.', 'Students can exchange books at the library.'),
('PAL0529', 'Exciting', '/ek-sái-ting/', '', '', 'CAT13', 'B1', 'Causing strong feelings of interest or happiness.', 'The final round of the contest was very exciting.'),
('PAL0530', 'External', '/eks-tér-nal/', '', '', 'CAT13', 'B1', 'On the outside, or coming from the outside.', 'Save your files on an external hard drive.'),
('PAL0531', 'Familiar', '/fa-mí-liar/', '', '', 'CAT13', 'B1', 'Well known because you have seen or heard it before.', 'Her face looked familiar to me.'),
('PAL0532', 'Featured', '/fí-tsiurd/', '', '', 'CAT13', 'B1', 'Shown as an important or main part of something.', 'The featured speaker at the event was a famous writer.'),
('PAL0533', 'Firewall', '/fáiar-uol/', '', '', 'CAT13', 'B1', 'A security system that protects a computer network.', 'The firewall blocked the suspicious message.'),
('PAL0534', 'Foothill', '/fút-jil/', '', '', 'CAT13', 'B1', 'A low hill at the base of a mountain.', 'They built a small cabin on a quiet foothill.'),
('PAL0535', 'Foremost', '/fór-moust/', '', '', 'CAT13', 'B1', 'Most important or best known.', 'She is the foremost expert on ancient languages.'),
('PAL0536', 'Formerly', '/fór-mer-li/', '', '', 'CAT13', 'B1', 'At an earlier time.', 'The restaurant was formerly a bank.'),
('PAL0537', 'Frazzled', '/frá-suld/', '', '', 'CAT13', 'B1', 'Very tired and nervous.', 'The long day left the teacher feeling frazzled.'),
('PAL0538', 'Frequent', '/frí-kuent/', '', '', 'CAT13', 'B1', 'Happening often.', 'He makes frequent trips to the library.'),
('PAL0539', 'Friendly', '/frénd-li/', '', '', 'CAT13', 'B1', 'Kind and pleasant toward other people.', 'Our neighbors are very friendly.'),
('PAL0540', 'Gelation', '/dshe-léi-shen/', '', '', 'CAT13', 'B1', 'The process of turning into a gel or a jelly-like substance.', 'Gelation happens when the mixture cools down.'),
('PAL0541', 'Generate', '/dshé-ne-reit/', '', '', 'CAT13', 'B1', 'To produce or create something.', 'Wind turbines generate clean energy.'),
('PAL0542', 'Genomics', '/dshi-nó-miks/', '', '', 'CAT13', 'B1', 'The study of the complete set of genes of living things.', 'Genomics helps scientists understand inherited diseases.'),
('PAL0543', 'Gentleman', '/dshén-tl-man/', '', '', 'CAT13', 'B1', 'A polite and well-mannered man.', 'The gentleman held the door for everyone.'),
('PAL0544', 'Governor', '/gá-ver-nor/', '', '', 'CAT13', 'B1', 'An official who leads a state or region.', 'The governor gave a speech about education.'),
('PAL0545', 'Guidance', '/gái-dans/', '', '', 'CAT13', 'B1', 'Help and advice about how to do something.', 'The counselor gave me guidance about choosing a career.'),
('PAL0546', 'Hawthorn', '/jó-zorn/', '', '', 'CAT13', 'B1', 'A thorny shrub or small tree with white flowers and red berries.', 'A hawthorn grows next to the old stone wall.'),
('PAL0547', 'Heraldry', '/hé-ral-dri/', '', '', 'CAT13', 'B1', 'The study of coats of arms and family symbols.', 'Heraldry uses shields, lions and other symbols.'),
('PAL0548', 'Hesitate', '/jé-si-teit/', '', '', 'CAT13', 'B1', 'To pause because you are not sure what to do.', 'Do not hesitate to ask questions.'),
('PAL0549', 'Homeless', '/jóum-les/', '', '', 'CAT13', 'B1', 'Having no place to live.', 'The shelter gives food to homeless people.'),
('PAL0550', 'Ideation', '/ai-di-éi-shen/', '', '', 'CAT13', 'B1', 'The process of forming new ideas.', 'Ideation is the first step of the design process.'),
('PAL0551', 'Identify', '/ai-dén-ti-fai/', '', '', 'CAT13', 'B1', 'To recognize something and say what or who it is.', 'Can you identify this bird?'),
('PAL0552', 'Imperial', '/im-pí-ri-al/', '', '', 'CAT13', 'B1', 'Related to an empire or its ruler.', 'The imperial palace was full of tourists.'),
('PAL0553', 'Increase', '/in-kríis/', '', '', 'CAT13', 'B1', 'To become greater in size, number or amount.', 'Prices tend to increase every year.'),
('PAL0554', 'Indebted', '/in-dé-tid/', '', '', 'CAT13', 'B1', 'Owing thanks or money to someone.', 'I am indebted to my teacher for her help.'),
('PAL0555', 'Indicate', '/ín-di-keit/', '', '', 'CAT13', 'B1', 'To show or point out something.', 'The arrow will indicate the way to the exit.'),
('PAL0556', 'Industry', '/ín-das-tri/', '', '', 'CAT13', 'B1', 'The making of products in factories, or a branch of business.', 'The car industry employs thousands of workers.'),
('PAL0557', 'Inherent', '/in-jé-rent/', '', '', 'CAT13', 'B1', 'Existing as a natural and permanent part of something.', 'Risk is inherent in every extreme sport.'),
('PAL0558', 'Initiate', '/i-ní-shi-eit/', '', '', 'CAT13', 'B1', 'To start or begin something.', 'The mayor will initiate a new recycling program.'),
('PAL0559', 'Involved', '/in-vólvd/', '', '', 'CAT13', 'B1', 'Taking part in something or connected with it.', 'She is involved in many school activities.'),
('PAL0560', 'Iodinate', '/ái-o-di-neit/', '', '', 'CAT13', 'B1', 'To treat or combine with iodine.', 'Some companies iodinate table salt to prevent health problems.'),
('PAL0561', 'Judgement', '/dshádsh-ment/', '', '', 'CAT13', 'B1', 'The ability to make wise decisions, or an opinion formed after careful thought.', 'Good judgement helps you make wise choices.'),
('PAL0562', 'Judicial', '/dshu-dí-shal/', '', '', 'CAT13', 'B1', 'Related to courts of law and judges.', 'The judicial system makes sure the law is followed.'),
('PAL0563', 'Language', '/láng-guidsh/', '', '', 'CAT13', 'B1', 'A system of words used by people to communicate.', 'English is the language we speak in class.'),
('PAL0564', 'Legation', '/li-géi-shen/', '', '', 'CAT13', 'B1', 'A diplomatic office ranking below an embassy.', 'The legation helped citizens who were traveling abroad.'),
('PAL0565', 'Literary', '/lí-te-ra-ri/', '', '', 'CAT13', 'B1', 'Related to books and writing.', 'She won a literary prize for her first novel.'),
('PAL0566', 'Maintain', '/mein-téin/', '', '', 'CAT13', 'B1', 'To keep something in good condition.', 'You must maintain your bike to keep it safe.'),
('PAL0567', 'Marriage', '/má-ridsh/', '', '', 'CAT13', 'B1', 'The legal union of two people as partners.', 'Their marriage lasted fifty years.'),
('PAL0568', 'Material', '/ma-tí-ri-al/', '', '', 'CAT13', 'B1', 'The fabric or matter that something is made of.', 'The dress is made of soft material.'),
('PAL0569', 'Maximize', '/mák-si-mais/', '', '', 'CAT13', 'B1', 'To make something as large or as good as possible.', 'Study every day to maximize your score.'),
('PAL0570', 'Measured', '/mé-shurd/', '', '', 'CAT13', 'B1', 'Found the size or amount of something; also careful and controlled.', 'The builder measured the room twice.'),
('PAL0571', 'Minstrel', '/míns-trel/', '', '', 'CAT13', 'B1', 'A traveling singer and musician in medieval times.', 'The minstrel sang stories in the castle.'),
('PAL0572', 'Mortgage', '/mór-gidsh/', '', '', 'CAT13', 'B1', 'A loan used to buy a house or property.', 'They pay their mortgage every month.'),
('PAL0573', 'Mountain', '/máun-ten/', '', '', 'CAT13', 'B1', 'A very high natural hill.', 'We climbed the mountain early in the morning.'),
('PAL0574', 'Nauseous', '/nó-shos/', '', '', 'CAT13', 'B1', 'Feeling sick, as if you might vomit.', 'The rocking boat made me feel nauseous.'),
('PAL0575', 'Negative', '/né-ga-tiv/', '', '', 'CAT13', 'B1', 'Bad or harmful; also less than zero.', 'Try not to have a negative attitude.'),
('PAL0576', 'Northern', '/nór-dern/', '', '', 'CAT13', 'B1', 'In or from the north.', 'Northern winters are long and cold.'),
('PAL0577', 'Numerous', '/niú-me-ros/', '', '', 'CAT13', 'B1', 'Very many.', 'Numerous students joined the contest.'),
('PAL0578', 'Nuzzling', '/ná-sling/', '', '', 'CAT13', 'B1', 'Gently rubbing or pressing with the nose.', 'The puppy was nuzzling my hand.'),
('PAL0579', 'Woodland', '/WUUD-lənd/', '', '', 'CAT13', 'B1', 'Area of land covered with trees and shrubs.', 'Woodland birds.'),
('PAL0580', 'Official', '/o-fí-shal/', '', '', 'CAT13', 'B1', 'Approved by someone in authority; also a person who holds a public role.', 'The official results will be posted tonight.'),
('PAL0581', 'Opposite', '/ó-po-sit/', '', '', 'CAT13', 'B1', 'Completely different, or facing the other way.', 'Hot is the opposite of cold.'),
('PAL0582', 'Organize', '/ór-ga-nais/', '', '', 'CAT13', 'B1', 'To arrange things in an orderly way.', 'Please organize your notes by subject.'),
('PAL0583', 'Original', '/o-rí-dshi-nal/', '', '', 'CAT13', 'B1', 'First or new; not copied from anything else.', 'The museum keeps the original painting.'),
('PAL0584', 'Ornament', '/ór-na-ment/', '', '', 'CAT13', 'B1', 'An object used as a decoration.', 'She hung a glass ornament on the tree.'),
('PAL0585', 'Overcome', '/ou-ver-kám/', '', '', 'CAT13', 'B1', 'To defeat or deal successfully with a problem.', 'He worked hard to overcome his fear of speaking.'),
('PAL0586', 'Overhead', '/ou-ver-jéd/', '', '', 'CAT13', 'B1', 'Above your head.', 'A plane flew overhead.'),
('PAL0587', 'Overtake', '/ou-ver-téik/', '', '', 'CAT13', 'B1', 'To pass someone or something that is moving in the same direction.', 'It is dangerous to overtake a truck on a curve.'),
('PAL0588', 'Parallel', '/pá-ra-lel/', '', '', 'CAT13', 'B1', 'Going in the same direction and always the same distance apart.', 'The two roads run parallel to the river.'),
('PAL0589', 'Patented', '/pá-ten-tid/', '', '', 'CAT13', 'B1', 'Legally protected so that only the inventor can make or sell it.', 'The company patented its new design.'),
('PAL0590', 'Peaceful', '/píis-ful/', '', '', 'CAT13', 'B1', 'Calm and quiet, without fighting or noise.', 'The lake is a peaceful place to relax.'),
('PAL0591', 'Persuade', '/per-suéid/', '', '', 'CAT13', 'B1', 'To convince someone to do or believe something.', 'I will persuade my parents to let me go.'),
('PAL0592', 'Physical', '/fí-si-kal/', '', '', 'CAT13', 'B1', 'Related to the body or to real objects.', 'Physical exercise keeps you healthy.'),
('PAL0593', 'Pleasant', '/plé-sant/', '', '', 'CAT13', 'B1', 'Enjoyable and nice.', 'We had a pleasant walk in the park.'),
('PAL0594', 'Pleasure', '/plé-shur/', '', '', 'CAT13', 'B1', 'feeling that produces that good feeling.', 'Itˈs a pleasure to meet you.'),
('PAL0595', 'Pleasure', '/plé-shur/', '', '', 'CAT13', 'B1', 'A feeling of enjoyment or happiness.', 'Reading gives her great pleasure.'),
('PAL0596', 'Portable', '/pór-ta-bl/', '', '', 'CAT13', 'B1', 'Easy to carry or move.', 'I bought a portable speaker for the trip.'),
('PAL0597', 'Postpone', '/poust-póun/', '', '', 'CAT13', 'B1', 'To delay something until a later time.', 'They had to postpone the game because of the rain.'),
('PAL0598', 'Powerful', '/páu-er-ful/', '', '', 'CAT13', 'B1', 'Having great strength or influence.', 'A powerful engine drives the ship.'),
('PAL0599', 'Previous', '/prí-vi-os/', '', '', 'CAT13', 'B1', 'Coming before in time or order.', 'Review the previous lesson before the exam.'),
('PAL0600', 'Profound', '/pro-fáund/', '', '', 'CAT13', 'B1', 'Very deep or intense.', 'The book had a profound effect on her.'),
('PAL0601', 'Property', '/pró-per-ti/', '', '', 'CAT13', 'B1', 'Something that is owned, such as land or a building.', 'The property has a large garden.'),
('PAL0602', 'Protocol', '/pró-to-kol/', '', '', 'CAT13', 'B1', 'A set of rules or steps that must be followed.', 'Follow the safety protocol in the lab.'),
('PAL0603', 'Publicly', '/páb-lik-li/', '', '', 'CAT13', 'B1', 'In a way that everyone can see or hear.', 'The mayor publicly thanked the volunteers.'),
('PAL0604', 'Purchase', '/pér-tshes/', '', '', 'CAT13', 'B1', 'To buy something.', 'I will purchase a new backpack tomorrow.'),
('PAL0605', 'Reaction', '/ri-ák-shen/', '', '', 'CAT13', 'B1', 'A response to something that happens.', 'His reaction to the news was pure joy.'),
('PAL0606', 'Relation', '/ri-léi-shen/', '', '', 'CAT13', 'B1', 'A connection between people or things.', 'There is a clear relation between sleep and health.'),
('PAL0607', 'Reliable', '/ri-lái-a-bl/', '', '', 'CAT13', 'B1', 'Able to be trusted.', 'My brother is a reliable friend.'),
('PAL0608', 'Reliance', '/ri-lái-ans/', '', '', 'CAT13', 'B1', 'The state of depending on someone or something.', 'Our reliance on technology grows every year.'),
('PAL0609', 'Religion', '/ri-lí-dshon/', '', '', 'CAT13', 'B1', 'A system of faith and worship.', 'Religion is important in many cultures.'),
('PAL0610', 'Remember', '/ri-mém-ber/', '', '', 'CAT13', 'B1', 'To keep something in your mind or bring back a memory.', 'Remember to bring your homework tomorrow.'),
('PAL0611', 'Research', '/ri-sérsh/', '', '', 'CAT13', 'B1', 'Careful study done to discover facts.', 'Scientists do research to find new medicines.'),
('PAL0612', 'Rigorous', '/rí-go-ros/', '', '', 'CAT13', 'B1', 'Very strict and thorough.', 'The athletes follow a rigorous training plan.'),
('PAL0613', 'Roadside', '/róud-said/', '', '', 'CAT13', 'B1', 'The edge of a road.', 'We bought fresh fruit at a roadside stand.'),
('PAL0614', 'Scenario', '/si-ná-ri-ou/', '', '', 'CAT13', 'B1', 'A possible situation or series of events.', 'In the worst scenario, the flight will be canceled.'),
('PAL0615', 'Scissors', '/sí-sors/', '', '', 'CAT13', 'B1', 'A tool with two blades used for cutting paper or cloth.', 'Please pass me the scissors.'),
('PAL0616', 'Scornful', '/skórn-ful/', '', '', 'CAT13', 'B1', 'Showing strong disrespect for someone or something.', 'He gave a scornful laugh.'),
('PAL0617', 'Scrutiny', '/skrúu-ti-ni/', '', '', 'CAT13', 'B1', 'Close and careful examination.', 'The new plan came under public scrutiny.'),
('PAL0618', 'Sergeant', '/sár-dshent/', '', '', 'CAT13', 'B1', 'A rank in the army or the police.', 'The sergeant gave clear orders to the soldiers.'),
('PAL0619', 'Sherbert', '/shér-bert/', '', '', 'CAT13', 'B1', 'A frozen fruit dessert (variant spelling of sherbet).', 'We ate orange sherbert after dinner.'),
('PAL0620', 'Shortage', '/shór-tidsh/', '', '', 'CAT13', 'B1', 'A situation in which there is not enough of something.', 'A water shortage affected the whole town.'),
('PAL0621', 'Skillful', '/skíl-ful/', '', '', 'CAT13', 'B1', 'Having or showing great ability.', 'The skillful surgeon finished the operation quickly.'),
('PAL0622', 'Southern', '/sá-dern/', '', '', 'CAT13', 'B1', 'In or from the south.', 'She has a soft southern accent.'),
('PAL0623', 'Specific', '/spe-sí-fik/', '', '', 'CAT13', 'B1', 'Clearly stated and exact.', 'Please give me a specific example.'),
('PAL0624', 'Spectrum', '/espék-trom/', '', '', 'CAT13', 'B1', 'A wide range of different things; also the band of colors in a rainbow.', 'A rainbow shows the full spectrum of colors.'),
('PAL0625', 'Spotless', '/espót-les/', '', '', 'CAT13', 'B1', 'Perfectly clean.', 'She left the kitchen spotless.'),
('PAL0626', 'Standard', '/están-dard/', '', '', 'CAT13', 'B1', 'A normal level or rule used for comparison.', 'The test follows a standard format.'),
('PAL0627', 'Stocking', '/estó-king/', '', '', 'CAT13', 'B1', 'A close-fitting garment that covers the foot and leg.', 'He hung a red stocking by the fireplace.');
INSERT INTO `palabra` (`codigo`, `significado`, `pronunciacion`, `imagen`, `audio`, `categoria`, `nivel`, `definicion`, `ejemplo`) VALUES
('PAL0628', 'Straight', '/estreit/', '', '', 'CAT13', 'B1', 'Without a bend or curve.', 'Draw a straight line with a ruler.'),
('PAL0629', 'Strength', '/estrenz/', '', '', 'CAT13', 'B1', 'The quality of being strong.', 'He lifted the box with great strength.'),
('PAL0630', 'Struggle', '/estrá-gl/', '', '', 'CAT13', 'B1', 'To try very hard to do something difficult.', 'Many students struggle with spelling at first.'),
('PAL0631', 'Suitable', '/siú-ta-bl/', '', '', 'CAT13', 'B1', 'Right or appropriate for a purpose.', 'This movie is suitable for children.'),
('PAL0632', 'Surprise', '/ser-práis/', '', '', 'CAT13', 'B1', 'An unexpected event or feeling.', 'The party was a big surprise.'),
('PAL0633', 'Swimming', '/suí-ming/', '', '', 'CAT13', 'B1', 'Moving through water by using your arms and legs.', 'Swimming is great exercise.'),
('PAL0634', 'Syllable', '/sí-la-bl/', '', '', 'CAT13', 'B1', 'A unit of sound in a word.', 'Say the word again, one syllable at a time.'),
('PAL0635', 'Sympathy', '/sím-pa-zi/', '', '', 'CAT13', 'B1', 'A feeling of sorrow for another person because of their trouble.', 'She showed sympathy for her sick friend.'),
('PAL0636', 'Taxation', '/tak-séi-shen/', '', '', 'CAT13', 'B1', 'The system of collecting money from people for the government.', 'Taxation pays for schools and roads.'),
('PAL0637', 'Thorough', '/zó-rou/', '', '', 'CAT13', 'B1', 'Complete and very careful.', 'The doctor did a thorough check-up.'),
('PAL0638', 'Threaten', '/zré-ten/', '', '', 'CAT13', 'B1', 'To say that you will cause harm; to be a possible danger.', 'Dark clouds threaten to spoil the picnic.'),
('PAL0639', 'Triptych', '/tríp-tik/', '', '', 'CAT13', 'B1', 'A work of art made of three panels joined together.', 'The artist painted a triptych of the sea.'),
('PAL0640', 'Trousers', '/tráu-sers/', '', '', 'CAT13', 'B1', 'A piece of clothing that covers each leg separately; pants.', 'He wore gray trousers and a white shirt.'),
('PAL0641', 'Umbrella', '/am-bré-la/', '', '', 'CAT13', 'B1', 'A folding cover held over your head to keep off the rain.', 'Take an umbrella because it might rain.'),
('PAL0642', 'Unlawful', '/an-ló-ful/', '', '', 'CAT13', 'B1', 'Against the law.', 'Driving without a license is unlawful.'),
('PAL0643', 'Unlikely', '/an-láik-li/', '', '', 'CAT13', 'B1', 'Not likely to happen.', 'It is unlikely that it will snow here.'),
('PAL0644', 'Upstairs', '/ap-stérs/', '', '', 'CAT13', 'B1', 'On or to a higher floor of a building.', 'The bedrooms are upstairs.'),
('PAL0645', 'Valuable', '/vá-liu-a-bl/', '', '', 'CAT13', 'B1', 'Worth a lot of money or very useful.', 'The old coin is very valuable.'),
('PAL0646', 'Volatile', '/vó-la-tail/', '', '', 'CAT13', 'B1', 'Likely to change quickly or to explode.', 'Gasoline is a volatile liquid.'),
('PAL0647', 'Wardrobe', '/uór-droub/', '', '', 'CAT13', 'B1', 'A tall cupboard for hanging clothes; also all the clothes a person owns.', 'She hung her coat in the wardrobe.'),
('PAL0648', 'Weakness', '/uíik-nes/', '', '', 'CAT13', 'B1', 'A lack of strength; a fault or flaw.', 'Chocolate is his only weakness.'),
('PAL0649', 'Wildlife', '/uáild-laif/', '', '', 'CAT13', 'B1', 'Wild animals and plants living in nature.', 'The park protects local wildlife.'),
('PAL0650', 'Withdraw', '/uis-dró/', '', '', 'CAT13', 'B1', 'To take something out or take it back.', 'You can withdraw money from the ATM.'),
('PAL0651', 'abandoner', '/əˈbændənər/', '', '', 'CAT14', 'B1', 'A person who leaves someone or something behind for good.', 'The abandoner left the old house and never returned.'),
('PAL0652', 'according', '/əˈkôrdiNG/', '', '', 'CAT14', 'B1', 'In a way that agrees with something; used in the phrase according to.', 'According to the map, the museum is two blocks away.'),
('PAL0653', 'afternoon', '/ˌaftərˈno͞on/', '', '', 'CAT14', 'B1', 'The part of the day between noon and evening.', 'We play soccer every afternoon after school.'),
('PAL0654', 'agreement', '/əˈɡrēm(ə)nt/', '', '', 'CAT14', 'B1', 'A shared decision or contract between people or groups.', 'The two companies signed an agreement yesterday.'),
('PAL0655', 'alongside', '/əˌlôNGˈsīd/', '', '', 'CAT14', 'B1', 'Next to or together with something.', 'The boat stayed alongside the dock all night.'),
('PAL0656', 'amazingly', '/əˈmāziNGlē/', '', '', 'CAT14', 'B1', 'In a way that is very surprising.', 'Amazingly, nobody was hurt in the accident.'),
('PAL0657', 'amusement', '/əˈmyo͞ozmənt/', '', '', 'CAT14', 'B1', 'The feeling of finding something funny; also fun and entertainment.', 'She laughed with amusement at the clown.'),
('PAL0658', 'apologize', '/əˈpäləˌjīz/', '', '', 'CAT14', 'B1', 'To say that you are sorry.', 'I need to apologize for being late.'),
('PAL0659', 'apparatus', '/ˌapəˈradəs/', '', '', 'CAT14', 'B1', 'The tools or equipment used for a particular purpose.', 'The lab has a special apparatus for testing water.'),
('PAL0660', 'attention', '/əˈten(t)SHən/', '', '', 'CAT14', 'B1', 'Careful listening, looking or thinking.', 'Please pay attention to the instructions.'),
('PAL0661', 'authority', '/əˈTHôrədē/', '', '', 'CAT14', 'B1', 'The power to give orders or make decisions; a person or group with that power.', 'Only the school authority can change the rules.'),
('PAL0662', 'automatic', '/ˌôdəˈmadik/', '', '', 'CAT14', 'B1', 'Working by itself without a person controlling it.', 'The door is automatic and opens when you walk near it.'),
('PAL0663', 'beautiful', '/ˈbyo͞odəfəl/', '', '', 'CAT14', 'B1', 'Very pleasing to look at or hear.', 'The garden is beautiful in spring.'),
('PAL0664', 'beginning', '/bəˈɡiniNG/', '', '', 'CAT14', 'B1', 'The start of something.', 'The beginning of the movie was very funny.'),
('PAL0665', 'brilliant', '/ˈbrilyənt/', '', '', 'CAT14', 'B1', 'Very bright, or extremely clever.', 'She had a brilliant idea for the project.'),
('PAL0666', 'bulldozer', '/ˈbo͝olˌdōzər/', '', '', 'CAT14', 'B2', 'A powerful machine used to push earth and rocks.', 'A bulldozer cleared the land for the new road.'),
('PAL0667', 'calculate', '/ˈkalkyəˌlāt/', '', '', 'CAT14', 'B1', 'To find a number or amount by using math.', 'Use a calculator to calculate the total cost.'),
('PAL0668', 'carpenter', '/ˈkärpən(t)ər/', '', '', 'CAT14', 'B1', 'A person who makes and repairs wooden things.', 'The carpenter built a new table for us.'),
('PAL0669', 'chapstick', '/ˈtʃæpˌstɪk/', '', '', 'CAT14', 'B1', 'A stick of balm used to protect dry lips.', 'I keep a chapstick in my bag for cold days.'),
('PAL0670', 'character', '/ˈker(ə)ktər/', '', '', 'CAT14', 'B1', 'A person in a story; also the personal qualities that make someone unique.', 'My favorite character in the book is a brave girl.'),
('PAL0671', 'colleague', '/ˈkälēɡ/', '', '', 'CAT14', 'B1', 'A person you work with.', 'My colleague helped me finish the report.'),
('PAL0672', 'committee', '/kəˈmidē/', '', '', 'CAT14', 'B1', 'A group of people chosen to make decisions or do a task.', 'The committee will choose the winner next week.'),
('PAL0673', 'condition', '/kənˈdiSHən/', '', '', 'CAT14', 'B1', 'The state that something is in; also a requirement.', 'The bike is in excellent condition.'),
('PAL0674', 'conscious', '/ˈkänSHəs/', '', '', 'CAT14', 'B1', 'Awake and aware of what is happening.', 'The patient was conscious after the operation.'),
('PAL0675', 'criticize', '/ˈkridəˌsīz/', '', '', 'CAT14', 'B1', 'To say what you think is wrong or bad about something.', 'It is easy to criticize, but harder to help.'),
('PAL0676', 'dangerous', '/ˈdānj(ə)rəs/', '', '', 'CAT14', 'B1', 'Likely to cause harm.', 'The road is dangerous when it is icy.'),
('PAL0677', 'desperate', '/ˈdesp(ə)rət/', '', '', 'CAT14', 'B1', 'Feeling a strong need for help and ready to try anything.', 'The desperate travelers asked for water.'),
('PAL0678', 'determine', '/dəˈtərmən/', '', '', 'CAT14', 'B1', 'To find out or decide something exactly.', 'Tests will determine the cause of the problem.'),
('PAL0679', 'digestion', '/dəˈjesCH(ə)n/', '', '', 'CAT14', 'B1', 'The process of breaking down food in the body.', 'Walking after lunch can help digestion.'),
('PAL0680', 'discovery', '/dəˈskəv(ə)rē/', '', '', 'CAT14', 'B1', 'The act of finding or learning something for the first time.', 'The discovery of the new island surprised everyone.'),
('PAL0681', 'eagerness', '/ˈēɡərnəs/', '', '', 'CAT14', 'B2', 'A strong wish to do something.', 'He showed great eagerness to start the project.'),
('PAL0682', 'effective', '/əˈfektiv/', '', '', 'CAT14', 'B1', 'Working well and producing the result you want.', 'This is an effective way to study.'),
('PAL0683', 'emphasize', '/ˈemfəˌsīz/', '', '', 'CAT14', 'B1', 'To give special importance to something.', 'The coach will emphasize teamwork this season.'),
('PAL0684', 'excellent', '/ˈeks(ə)lənt/', '', '', 'CAT14', 'B1', 'Extremely good.', 'She gave an excellent presentation.'),
('PAL0685', 'existence', '/iɡˈzist(ə)ns/', '', '', 'CAT14', 'B1', 'The state of being real or alive.', 'Scientists proved the existence of a new species of frog.'),
('PAL0686', 'exquisite', '/ekˈskwizət/', '', '', 'CAT14', 'B1', 'Extremely beautiful and carefully made.', 'She wore an exquisite silk dress.'),
('PAL0687', 'fabricate', '/ˈfabrəˌkāt/', '', '', 'CAT14', 'B1', 'To make or build something; also to invent something false.', 'The workers fabricate metal parts for cars.'),
('PAL0688', 'flashback', '/ˈflaSHˌbak/', '', '', 'CAT14', 'B1', 'A scene showing something that happened earlier; a sudden memory of the past.', 'The movie uses a flashback to show his childhood.'),
('PAL0689', 'fortunate', '/ˈfôrCH(ə)nət/', '', '', 'CAT14', 'B1', 'Lucky.', 'We were fortunate to find a seat on the bus.'),
('PAL0690', 'glamorous', '/ˈɡlam(ə)rəs/', '', '', 'CAT14', 'B1', 'Attractive in an exciting and fashionable way.', 'The actress looked glamorous at the ceremony.'),
('PAL0691', 'greatness', '/ˈɡrātnəs/', '', '', 'CAT14', 'B1', 'The quality of being very important or outstanding.', 'The greatness of the leader was remembered for many years.'),
('PAL0692', 'highlight', '/ˈhīˌlīt/', '', '', 'CAT14', 'B1', 'The best or most exciting part of something; also to mark text with a bright color.', 'The highlight of the trip was the boat ride.'),
('PAL0693', 'hypnotize', '/ˈhipnəˌtīz/', '', '', 'CAT14', 'B1', 'To put someone into a sleep-like state in which they follow suggestions.', 'The magician tried to hypnotize a volunteer.'),
('PAL0694', 'hypocrisy', '/həˈpäkrəsē/', '', '', 'CAT14', 'B1', 'Saying one thing but doing the opposite.', 'It is hypocrisy to ask others to recycle if you never do.'),
('PAL0695', 'hypocrite', '/ˈhipəˌkrit/', '', '', 'CAT14', 'B1', 'A person who says one thing but does the opposite.', 'He is a hypocrite because he never follows his own advice.'),
('PAL0696', 'insurance', '/inˈSHo͝orəns/', '', '', 'CAT14', 'B1', 'An agreement to pay money if something is lost, damaged or stolen.', 'Car insurance paid for the repairs.'),
('PAL0697', 'invention', '/inˈvenSHən/', '', '', 'CAT14', 'B1', 'A new thing that someone makes for the first time.', 'The telephone was an important invention.'),
('PAL0698', 'jellybean', '/ˈdʒɛlibiːn/', '', '', 'CAT14', 'B1', 'A small bean-shaped candy with a soft center.', 'She ate a red jellybean.'),
('PAL0699', 'jellyfish', '/ˈjelēˌfiSH/', '', '', 'CAT14', 'B1', 'A sea animal with a soft, clear body and stinging tentacles.', 'A jellyfish floated near the beach.'),
('PAL0700', 'judgement', '/ˈjəjmənt/', '', '', 'CAT14', 'B1', 'The ability to make wise decisions; an opinion formed after careful thought.', 'Use good judgement when you choose your friends.'),
('PAL0701', 'juridical', '/jo͝oˈridək(ə)l/', '', '', 'CAT14', 'B1', 'Related to law and the judging of legal cases.', 'The court made a juridical decision about the property.'),
('PAL0702', 'knowledge', '/ˈnäləj/', '', '', 'CAT14', 'B1', 'What you know from learning or experience.', 'Reading gives you a lot of knowledge.'),
('PAL0703', 'laborious', '/ləˈbôrēəs/', '', '', 'CAT14', 'B1', 'Needing a lot of hard work and effort.', 'Building the wall was slow and laborious.'),
('PAL0704', 'necessary', '/ˈnesəˌserē/', '', '', 'CAT14', 'B1', 'Needed; something you must have or do.', 'It is necessary to wear a helmet.'),
('PAL0705', 'negotiate', '/nəˈɡōSHēˌāt/', '', '', 'CAT14', 'B1', 'To talk in order to reach an agreement.', 'They will negotiate the price of the car.'),
('PAL0706', 'obedience', '/əˈbēdēəns/', '', '', 'CAT14', 'B1', 'The act of doing what you are told to do.', 'Dogs are trained to show obedience.'),
('PAL0707', 'occupancy', '/ˈäkyəp(ə)nsē/', '', '', 'CAT14', 'B1', 'The use of a room, building or space by someone.', 'The hotel has full occupancy this weekend.'),
('PAL0708', 'otherwise', '/ˈəT͟Hərˌwīz/', '', '', 'CAT14', 'B2', 'If not; in a different way.', 'Hurry up, otherwise we will miss the bus.'),
('PAL0709', 'patronage', '/ˈpatrənəj/', '', '', 'CAT14', 'B1', 'Support given by a regular customer or a sponsor.', 'The shop depends on the patronage of local families.'),
('PAL0710', 'plurality', '/plo͝oˈralədē/', '', '', 'CAT14', 'B1', 'The state of being more than one; a large variety.', 'The plurality of opinions made the discussion interesting.'),
('PAL0711', 'potential', '/pəˈten(t)SH(ə)l/', '', '', 'CAT14', 'B1', 'Possible in the future; the ability to develop or succeed.', 'She has great potential as a writer.'),
('PAL0712', 'practical', '/ˈpraktək(ə)l/', '', '', 'CAT14', 'B1', 'Useful and sensible rather than only based on ideas.', 'A raincoat is a practical gift.'),
('PAL0713', 'quickness', '/ˈkwiknəs/', '', '', 'CAT14', 'B1', 'The quality of being fast.', 'The quickness of the cat surprised us.'),
('PAL0714', 'razorback', '/ˈrāzərˌbak/', '', '', 'CAT14', 'B2', 'A wild pig with a narrow, sharp back.', 'A razorback ran across the field.'),
('PAL0715', 'recognize', '/ˈrekə(ɡ)ˌnīz/', '', '', 'CAT14', 'B1', 'To know someone or something because you have seen it before.', 'I did not recognize him with his new haircut.'),
('PAL0716', 'recollect', '/ˌrekəˈlek(t)/', '', '', 'CAT14', 'B1', 'To remember something.', 'I cannot recollect where I put my keys.'),
('PAL0717', 'recommend', '/ˌrekəˈmend/', '', '', 'CAT14', 'B1', 'To suggest that something is good or useful.', 'I recommend this book to everyone.'),
('PAL0718', 'spearmint', '/ˈspirˌmint/', '', '', 'CAT14', 'B1', 'A type of mint plant used to flavor gum and candy.', 'This gum has a fresh spearmint flavor.'),
('PAL0719', 'spiritual', '/ˈspirəCH(əw)əl/', '', '', 'CAT14', 'B1', 'Related to the soul or faith rather than the physical world.', 'She finds peace through spiritual reading.'),
('PAL0720', 'spotlight', '/ˈspätˌlīt/', '', '', 'CAT14', 'B1', 'A strong beam of light aimed at one place or person; public attention.', 'The singer stood in the spotlight.'),
('PAL0721', 'statement', '/ˈstātmənt/', '', '', 'CAT14', 'B1', 'Something that is said or written in a formal way.', 'The mayor made a statement to the press.'),
('PAL0722', 'structure', '/ˈstrək(t)SHər/', '', '', 'CAT14', 'B1', 'The way the parts of something are arranged; something that has been built.', 'The structure of the essay is clear.'),
('PAL0723', 'substance', '/ˈsəbstəns/', '', '', 'CAT14', 'B1', 'A type of matter with specific qualities.', 'Water is a clear substance.'),
('PAL0724', 'symbolize', '/ˈsimbəˌlīz/', '', '', 'CAT14', 'B1', 'To represent an idea or thing.', 'A white dove can symbolize peace.'),
('PAL0725', 'temporary', '/ˈtempəˌrerē/', '', '', 'CAT14', 'B1', 'Lasting for only a short time.', 'This is a temporary job for the summer.'),
('PAL0726', 'translate', '/tranzˈlāt/', '', '', 'CAT14', 'B1', 'To change words from one language into another.', 'Can you translate this sentence into Spanish?'),
('PAL0727', 'treatment', '/ˈtrētmənt/', '', '', 'CAT14', 'B1', 'Medical care given to a patient; the way someone or something is handled.', 'The treatment helped him recover quickly.'),
('PAL0728', 'vaccinate', '/ˈvaksəˌnāt/', '', '', 'CAT14', 'B1', 'To give a medicine that protects against a disease.', 'Nurses vaccinate children at the clinic.'),
('PAL0729', 'victimize', '/ˈviktəˌmīz/', '', '', 'CAT14', 'B1', 'To treat someone unfairly or cruelly.', 'Bullies victimize younger students.'),
('PAL0730', 'visualize', '/ˈviZHəˌlīz/', '', '', 'CAT14', 'B1', 'To form a picture of something in your mind.', 'Close your eyes and visualize the beach.'),
('PAL0731', 'wonderful', '/ˈwəndərf(ə)l/', '', '', 'CAT14', 'B1', 'Extremely good or pleasant.', 'We had a wonderful day at the park.'),
('PAL0732', 'worthless', '/ˈwərTHləs/', '', '', 'CAT14', 'B1', 'Having no value or use.', 'The old coin turned out to be worthless.'),
('PAL0733', 'accessory', '/əkˈses(ə)rē/', '', '', 'CAT14', 'B1', 'An extra item that goes with something else, such as a bag or a belt.', 'A scarf is a nice accessory for a coat.'),
('PAL0734', 'advantage', '/ədˈvan(t)ij/', '', '', 'CAT14', 'B1', 'Something that puts you in a better position than others.', 'Being tall is an advantage in basketball.'),
('PAL0735', 'ambitious', '/amˈbiSHəs/', '', '', 'CAT14', 'B1', 'Having a strong wish to succeed.', 'She is an ambitious student who wants to be a doctor.'),
('PAL0736', 'amphibian', '/amˈ(p)fibēən/', '', '', 'CAT14', 'B1', 'An animal, such as a frog, that can live both on land and in water.', 'A frog is an amphibian.'),
('PAL0737', 'apologize', '/əˈpäləˌjīz/', '', '', 'CAT14', 'B1', 'To say that you are sorry.', 'I need to apologize for being late.'),
('PAL0738', 'astronomy', '/əˈstränəmē/', '', '', 'CAT14', 'B1', 'The scientific study of stars, planets and space.', 'We learned about the moon in astronomy class.'),
('PAL0739', 'breathing', '/ˈbrēT͟HiNG/', '', '', 'CAT14', 'B1', 'Taking air into the lungs and letting it out.', 'Deep breathing helps you relax.'),
('PAL0740', 'blueberry', '/ˈblo͞oˌberē/', '', '', 'CAT14', 'B1', 'A small, round, blue fruit.', 'She put a blueberry on top of the cake.'),
('PAL0741', 'abhorrence', '/əbˈhôrəns/', '', '', 'CAT15', 'B2', 'A feeling of very strong hatred or disgust.', 'He looked at the cruelty with abhorrence.'),
('PAL0742', 'abnegation', '/ˌabnəˈɡāSH(ə)n/', '', '', 'CAT15', 'B2', 'The act of giving up or denying something to yourself.', 'The monk lived a life of abnegation.'),
('PAL0743', 'abominably', '/əˈbäm(ə)nəblē/', '', '', 'CAT15', 'B2', 'In a very bad or terrible way.', 'The team played abominably in the first half.'),
('PAL0744', 'aborigines', '/ˌæb.əˈrɪdʒ.ən.iːz/', '', '', 'CAT15', 'B2', 'The first or original people living in a region, especially in Australia.', 'The aborigines have lived in Australia for tens of thousands of years.'),
('PAL0745', 'abridgment', '/əˈbrijm(ə)nt/', '', '', 'CAT15', 'B2', 'A shorter version of a longer written work.', 'I read an abridgment of the long novel.'),
('PAL0746', 'abrogation', '/ˌabrəˈɡāSH(ə)n/', '', '', 'CAT15', 'B2', 'The official ending of a law or an agreement.', 'The abrogation of the old law took effect in May.'),
('PAL0747', 'absolutist', '/ˈabsəˌlo͞odəst/', '', '', 'CAT15', 'B2', 'A person who believes in complete and unlimited power.', 'The absolutist king refused to share his power.'),
('PAL0748', 'absorbency', '/əbˈsɔːrbənsi/', '', '', 'CAT15', 'B2', 'The ability to soak up liquid.', 'Paper towels are known for their absorbency.'),
('PAL0749', 'acceptable', '/əkˈseptəb(ə)l/', '', '', 'CAT15', 'B2', 'Good enough; allowed.', 'Your work is acceptable, but it could be better.'),
('PAL0750', 'additional', '/əˈdiSHənl/', '', '', 'CAT15', 'B2', 'Extra or more than what was already there.', 'Additional chairs were placed in the room.'),
('PAL0751', 'adjudicate', '/əˈjo͞odəˌkāt/', '', '', 'CAT15', 'B2', 'To act as a judge and decide a case or a dispute.', 'A committee will adjudicate the dispute.'),
('PAL0752', 'adjustment', '/əˈjəs(t)m(ə)nt/', '', '', 'CAT15', 'B2', 'A small change made to improve something.', 'The mechanic made an adjustment to the brakes.'),
('PAL0753', 'afterwards', '/ˈaftərwərdz/', '', '', 'CAT15', 'B2', 'At a later time.', 'We ate dinner, and afterwards we watched a movie.'),
('PAL0754', 'aggressive', '/əˈɡresiv/', '', '', 'CAT15', 'B2', 'Ready to attack or argue; very forceful.', 'The aggressive dog barked at everyone.'),
('PAL0755', 'anticipate', '/anˈtisəˌpāt/', '', '', 'CAT15', 'B2', 'To expect something and prepare for it.', 'We anticipate a large crowd on Saturday.'),
('PAL0756', 'appreciate', '/əˈprēSHēˌāt/', '', '', 'CAT15', 'B2', 'To be thankful for something; to understand its value.', 'I appreciate your help with the project.'),
('PAL0757', 'authorship', '/ˈôTHərˌSHip/', '', '', 'CAT15', 'B2', 'The fact of being the writer or creator of something.', 'The authorship of the poem is unknown.'),
('PAL0758', 'background', '/ˈbakˌɡround/', '', '', 'CAT15', 'B2', 'The part of a picture behind the main things; the experience and education that a person has had.', 'There is a mountain in the background of the photo.'),
('PAL0759', 'chimpanzee', '/ˌCHimˈpanzē/', '', '', 'CAT15', 'B2', 'A large ape with black fur that lives in Africa.', 'The chimpanzee used a stick to get food.'),
('PAL0760', 'commercial', '/kəˈmərSHəl/', '', '', 'CAT15', 'B2', 'Related to buying and selling; also an advertisement on TV or radio.', 'The commercial for the new phone was very funny.'),
('PAL0761', 'comprehend', '/ˌkämprəˈhend/', '', '', 'CAT15', 'B2', 'To understand something fully.', 'It is hard to comprehend such a large number.'),
('PAL0762', 'conscience', '/ˈkänSHəns/', '', '', 'CAT15', 'B1', 'The inner voice that tells you what is right or wrong.', 'His conscience told him to return the wallet.'),
('PAL0763', 'depression', '/dəˈpreSH(ə)n/', '', '', 'CAT15', 'B2', 'A feeling of deep sadness; also a long period of economic decline.', 'The country suffered a long economic depression.'),
('PAL0764', 'discussion', '/dəˈskəSHən/', '', '', 'CAT15', 'B2', 'A conversation about a topic.', 'The class had a discussion about recycling.'),
('PAL0765', 'distribute', '/dəˈstribyo͞ot/', '', '', 'CAT15', 'B2', 'To give out or share among many people.', 'Volunteers distribute food to families.'),
('PAL0766', 'equivalent', '/əˈkwiv(ə)lənt/', '', '', 'CAT15', 'B2', 'Equal in value, size or meaning.', 'Two halves are equivalent to one whole.'),
('PAL0767', 'experience', '/ikˈspirēəns/', '', '', 'CAT15', 'B1', 'Knowledge gained from doing something; an event that affects you.', 'She has ten years of teaching experience.'),
('PAL0768', 'government', '/ˈɡəvər(n)mənt/', '', '', 'CAT15', 'B2', 'The group of people who rule a country or region.', 'The government built a new hospital.'),
('PAL0769', 'hypnotized', '/ˈhɪpnətaɪzd/', '', '', 'CAT15', 'B2', 'Put into a sleep-like state in which you follow suggestions.', 'The volunteer was hypnotized on stage.'),
('PAL0770', 'illustrate', '/ˈiləˌstrāt/', '', '', 'CAT15', 'B2', 'To explain with pictures or examples; to add pictures to a book.', 'She will illustrate the story with colorful drawings.'),
('PAL0771', 'immaculate', '/iˈmakyələt/', '', '', 'CAT15', 'B2', 'Perfectly clean and neat.', 'Her room is always immaculate.'),
('PAL0772', 'impossible', '/imˈpäsəb(ə)l/', '', '', 'CAT15', 'B2', 'Not able to happen or be done.', 'It is impossible to finish this in five minutes.'),
('PAL0773', 'impressive', '/əmˈpresiv/', '', '', 'CAT15', 'B2', 'Causing admiration because of skill, size or quality.', 'The magician gave an impressive show.'),
('PAL0774', 'juxtaposed', '/ˌdʒʌkstəˈpoʊzd/', '', '', 'CAT15', 'C1', 'Placed side by side to show a contrast.', 'The artist juxtaposed old buildings with modern towers in the photo.'),
('PAL0775', 'kickboxing', '/ˈkɪkˌbɑːksɪŋ/', '', '', 'CAT15', 'C1', 'A sport in which fighters punch and kick.', 'She goes to kickboxing class twice a week.'),
('PAL0776', 'literature', '/ˈlidər(ə)CHər/', '', '', 'CAT15', 'B1', 'Written works such as novels, poems and plays.', 'We study English literature at school.'),
('PAL0777', 'maleficent', '/məˈlefəsənt/', '', '', 'CAT15', 'B2', 'Causing harm or evil.', 'The maleficent witch cast a dark spell.'),
('PAL0778', 'manipulate', '/məˈnipyəˌlāt/', '', '', 'CAT15', 'B2', 'To control or influence someone in a clever, often unfair way; to handle skillfully.', 'Do not let anyone manipulate your decisions.'),
('PAL0779', 'motivation', '/ˌmōdəˈvāSH(ə)n/', '', '', 'CAT15', 'B2', 'The reason or desire that makes you want to do something.', 'Her motivation to win kept her practicing every day.'),
('PAL0780', 'mozzarella', '/ˌmätsəˈrelə/', '', '', 'CAT15', 'B1', 'A soft, white Italian cheese often used on pizza.', 'The pizza was covered in melted mozzarella.'),
('PAL0781', 'plantation', '/planˈtāSH(ə)n/', '', '', 'CAT15', 'B1', 'A large farm where crops such as coffee or sugar are grown.', 'The plantation grows coffee and bananas.'),
('PAL0782', 'proscenium', '/prəˈsēnēəm/', '', '', 'CAT15', 'B2', 'The part of a theater stage in front of the curtain, or the arch that frames the stage.', 'The actors bowed at the edge of the proscenium.'),
('PAL0783', 'punishment', '/ˈpəniSHm(ə)nt/', '', '', 'CAT15', 'B1', 'A penalty given for breaking a rule or a law.', 'The punishment for cheating was a zero.'),
('PAL0784', 'reasonable', '/ˈrēzənəb(ə)l/', '', '', 'CAT15', 'B2', 'Fair and sensible.', 'The price is reasonable for such good quality.'),
('PAL0785', 'regardless', '/rəˈɡärdləs/', '', '', 'CAT15', 'B2', 'Without being affected by something else.', 'We will go regardless of the weather.'),
('PAL0786', 'remarkable', '/rəˈmärkəb(ə)l/', '', '', 'CAT15', 'B2', 'Unusual and worth noticing.', 'She made remarkable progress this year.'),
('PAL0787', 'seamstress', '/ˈsēmstrəs/', '', '', 'CAT15', 'B2', 'A woman who sews clothes for a living.', 'The seamstress fixed the hem of my dress.'),
('PAL0788', 'specialist', '/ˈspeSH(ə)ləst/', '', '', 'CAT15', 'B1', 'An expert in one particular subject or field.', 'A heart specialist examined the patient.'),
('PAL0789', 'squeezable', '/ˈskwiːzəbl/', '', '', 'CAT15', 'B2', 'Able to be pressed gently to let out what is inside.', 'The squeezable bottle makes it easy to pour the sauce.'),
('PAL0790', 'successful', '/səkˈsesf(ə)l/', '', '', 'CAT15', 'B1', 'Having achieved a goal or become well known.', 'The concert was very successful.'),
('PAL0791', 'sufficient', '/səˈfiSH(ə)nt/', '', '', 'CAT15', 'B1', 'Enough for a particular need.', 'Do we have sufficient food for everyone?'),
('PAL0792', 'suggestion', '/səˈjesCHən/', '', '', 'CAT15', 'B2', 'An idea offered for someone to think about.', 'Do you have a suggestion for dinner?'),
('PAL0793', 'suspicious', '/səˈspiSHəs/', '', '', 'CAT15', 'B2', 'Feeling or causing distrust.', 'The guard saw a suspicious package.'),
('PAL0794', 'texturized', '/ˈtɛkstʃəˌraɪzd/', '', '', 'CAT15', 'B2', 'Given a particular surface feel or structure.', 'The texturized paint made the wall look rough.'),
('PAL0795', 'understand', '/ˌəndərˈstand/', '', '', 'CAT15', 'B1', 'To know the meaning of something.', 'I do not understand this question.'),
('PAL0796', 'unfriendly', '/ˌənˈfren(d)lē/', '', '', 'CAT15', 'B1', 'Not kind or welcoming.', 'The unfriendly clerk did not say hello.'),
('PAL0797', 'volleyball', '/ˈvälēˌbôl/', '', '', 'CAT15', 'B1', 'A sport in which two teams hit a ball over a net; also the ball used in this sport.', 'We play volleyball on the beach.'),
('PAL0798', 'wanderlust', '/ˈwändərˌləst/', '', '', 'CAT15', 'B2', 'A strong desire to travel.', 'Her wanderlust took her to twenty countries.'),
('PAL0799', 'widespread', '/ˈwīdˌspred/', '', '', 'CAT15', 'B2', 'Found or happening in many places.', 'The storm caused widespread damage.'),
('PAL0800', 'arithmetic', '/əˈrɪθ.mə.tɪk/', '', '', 'CAT15', 'B2', 'The branch of math that deals with adding, subtracting, multiplying and dividing.', 'Arithmetic is the first math skill children learn.'),
('PAL0801', 'advertising', '/ˈæd.vər.taɪ.zɪŋ/', '', '', 'CAT16', 'B2', 'The business of promoting products or services to the public.', 'Advertising on television can be very expensive.'),
('PAL0802', 'anachronism', '/əˈnæk.rə.nɪ.zəm/', '', '', 'CAT16', 'B2', 'Something that belongs to a different time period from the one it appears in.', 'A cell phone in a movie about ancient Rome would be an anachronism.'),
('PAL0803', 'anniversary', '/ˌæn.əˈvɜːr.sər.i/', '', '', 'CAT16', 'B2', 'The date on which something important happened in an earlier year.', 'They celebrated their tenth anniversary in Paris.'),
('PAL0804', 'appropriate', '/əˈproʊ.pri.ət/', '', '', 'CAT16', 'B2', 'Suitable or correct for a particular situation.', 'Formal clothes are appropriate for the interview.'),
('PAL0805', 'backpacking', '/ˈbækˌpæk.ɪŋ/', '', '', 'CAT16', 'B2', 'Traveling or hiking while carrying your belongings in a backpack.', 'Backpacking through Europe was her dream trip.'),
('PAL0806', 'blasphemous', '/ˈblæs.fə.məs/', '', '', 'CAT16', 'B2', 'Showing disrespect toward God or sacred things.', 'The priest called the joke blasphemous.'),
('PAL0807', 'celebration', '/ˌsel.əˈbreɪ.ʃən/', '', '', 'CAT16', 'B2', 'A special event held to mark a happy occasion.', 'The whole town joined the celebration.'),
('PAL0808', 'coincidence', '/koʊˈɪn.sɪ.dəns/', '', '', 'CAT16', 'B2', 'Two events happening at the same time by chance.', 'It was a coincidence that we chose the same book.'),
('PAL0809', 'concordance', '/kənˈkɔːr.dəns/', '', '', 'CAT16', 'B2', 'Agreement between things; also an alphabetical list of the words used in a book.', 'There is concordance between the two reports.'),
('PAL0810', 'connotation', '/ˌkɒn.əˈteɪ.ʃən/', '', '', 'CAT16', 'B2', 'An idea or feeling that a word suggests in addition to its main meaning.', 'The word cheap has a negative connotation.'),
('PAL0811', 'descriptive', '/dɪˈskrɪp.tɪv/', '', '', 'CAT16', 'B2', 'Giving details that help you picture something.', 'The writer used descriptive language to paint the scene.'),
('PAL0812', 'electricity', '/ɪˌlekˈtrɪs.ə.ti/', '', '', 'CAT16', 'B2', 'A form of energy used to power lights and machines.', 'The storm cut off the electricity in our neighborhood.'),
('PAL0813', 'environment', '/ɪnˈvaɪ.rən.mənt/', '', '', 'CAT16', 'B2', 'The natural world, or the surroundings in which people live and work.', 'We must protect the environment.'),
('PAL0814', 'fabrication', '/ˌfæb.rɪˈkeɪ.ʃən/', '', '', 'CAT16', 'B2', 'The act of making something; also a made-up story or lie.', 'The story was a complete fabrication.'),
('PAL0815', 'forgettable', '/fərˈɡet.ə.bəl/', '', '', 'CAT16', 'B2', 'Not memorable; easy to forget.', 'The movie was pleasant but forgettable.'),
('PAL0816', 'forgiveness', '/fərˈɡɪv.nəs/', '', '', 'CAT16', 'B2', 'The act of no longer being angry with someone who did something wrong.', 'She asked for forgiveness after the argument.'),
('PAL0817', 'imagination', '/ɪˌmædʒ.əˈneɪ.ʃən/', '', '', 'CAT16', 'B2', 'The ability to form new ideas or pictures in your mind.', 'Children have a wonderful imagination.'),
('PAL0818', 'inspiration', '/ˌɪn.spəˈreɪ.ʃən/', '', '', 'CAT16', 'B2', 'Something or someone that gives you the wish to create or do something.', 'The mountains were her inspiration for the poem.'),
('PAL0819', 'intelligent', '/ɪnˈtel.ɪ.dʒənt/', '', '', 'CAT16', 'B2', 'Able to learn and understand things easily.', 'The intelligent student solved the problem quickly.'),
('PAL0820', 'marshmallow', '/ˈmɑːrʃˌmæl.oʊ/', '', '', 'CAT16', 'B2', 'A soft, sweet, white candy often toasted over a fire.', 'We roasted a marshmallow at the campfire.'),
('PAL0821', 'personality', '/ˌpɜːr.sənˈæl.ə.ti/', '', '', 'CAT16', 'B2', 'The qualities that make a person different from others.', 'He has a friendly and funny personality.'),
('PAL0822', 'predominate', '/prɪˈdɒm.ɪ.neɪt/', '', '', 'CAT16', 'B2', 'To be the largest in number or the strongest in influence.', 'Pine trees predominate in this forest.'),
('PAL0823', 'preposition', '/ˌprep.əˈzɪʃ.ən/', '', '', 'CAT16', 'B2', 'A word that shows how a noun is related to another word, such as in or on.', 'The word under is a preposition.'),
('PAL0824', 'requirement', '/rɪˈkwaɪər.mənt/', '', '', 'CAT16', 'B2', 'Something that is needed or demanded.', 'A passport is a requirement for international travel.'),
('PAL0825', 'selfishness', '/ˈsel.fɪʃ.nəs/', '', '', 'CAT16', 'B2', 'Caring only about yourself and not about others.', 'His selfishness upset the whole team.'),
('PAL0826', 'serviceable', '/ˈsɜːr.vɪs.ə.bəl/', '', '', 'CAT16', 'B2', 'Useful and able to do the job, though not fancy.', 'The old car is serviceable and cheap.'),
('PAL0827', 'shortcoming', '/ˈʃɔːrtˌkʌm.ɪŋ/', '', '', 'CAT16', 'B2', 'A fault or weakness.', 'Impatience is his main shortcoming.'),
('PAL0828', 'standardize', '/ˈstæn.dər.daɪz/', '', '', 'CAT16', 'B2', 'To make things the same in size, quality or method.', 'The company will standardize its forms.'),
('PAL0829', 'subordinate', '/səˈbɔːr.dɪ.nət/', '', '', 'CAT16', 'B2', 'Lower in rank or importance; a person who works under another.', 'The manager gave clear orders to her subordinate.'),
('PAL0830', 'sufficiency', '/səˈfɪʃ.ən.si/', '', '', 'CAT16', 'B2', 'The state of having enough of something.', 'The farm has a sufficiency of water for its crops.'),
('PAL0831', 'supposition', '/ˌsʌp.əˈzɪʃ.ən/', '', '', 'CAT16', 'B2', 'An idea that you accept as true without proof.', 'His theory is based on supposition, not facts.'),
('PAL0832', 'treacherous', '/ˈtretʃ.ər.əs/', '', '', 'CAT16', 'B2', 'Dangerous; also disloyal and ready to betray.', 'The icy road was treacherous.'),
('PAL0833', 'unfortunate', '/ʌnˈfɔːr.tʃə.nət/', '', '', 'CAT16', 'B2', 'Unlucky, or regrettable.', 'It was an unfortunate mistake.'),
('PAL0834', 'unstoppable', '/ʌnˈstɒp.ə.bəl/', '', '', 'CAT16', 'B2', 'Impossible to stop.', 'The team was unstoppable in the second half.'),
('PAL0835', 'vaccination', '/ˌvæk.sɪˈneɪ.ʃən/', '', '', 'CAT16', 'B2', 'The act of giving a vaccine to protect against a disease.', 'Vaccination protects children from serious illness.'),
('PAL0836', 'windsurfing', '/ˈwɪndˌsɜːr.fɪŋ/', '', '', 'CAT16', 'B2', 'A water sport in which you stand on a board with a sail.', 'Windsurfing is popular on windy beaches.'),
('PAL0837', 'abnormality', '/ˌæb.nɔːrˈmæl.ə.ti/', '', '', 'CAT16', 'B2', 'Something that is not normal or usual.', 'The doctor found no abnormality in the test.'),
('PAL0838', 'arrangement', '/əˈreɪndʒ.mənt/', '', '', 'CAT16', 'B2', 'A plan, or the way things are organized.', 'The seating arrangement was changed for the party.'),
('PAL0839', 'discontinue', '/ˌdɪs.kənˈtɪn.juː/', '', '', 'CAT16', 'B2', 'To stop doing or making something.', 'The store will discontinue that product next month.'),
('PAL0840', 'disposition', '/ˌdɪs.pəˈzɪʃ.ən/', '', '', 'CAT16', 'B2', 'The natural character or mood of a person; the way something is arranged.', 'She has a cheerful disposition.'),
('PAL0841', 'exhortation', '/ˌeɡ.zɔːrˈteɪ.ʃən/', '', '', 'CAT16', 'B2', 'Strong encouragement to do something.', 'The coach ended with an exhortation to never give up.'),
('PAL0842', 'frostbitten', '/ˈfrɒstˌbɪt.ən/', '', '', 'CAT16', 'B2', 'Damaged by extreme cold.', 'The frostbitten fingers turned pale.'),
('PAL0843', 'headquarter', '/ˈhedˌkwɔːr.tər/', '', '', 'CAT16', 'B2', 'To set up or have a main office in a place.', 'The company will headquarter its new division in Chicago.'),
('PAL0844', 'ignominious', '/ˌɪɡ.nəˈmɪn.i.əs/', '', '', 'CAT16', 'B2', 'Causing public shame or disgrace.', 'The team suffered an ignominious defeat.'),
('PAL0845', 'inquisitive', '/ɪnˈkwɪz.ə.tɪv/', '', '', 'CAT16', 'B2', 'Eager to learn and always asking questions.', 'The inquisitive child asked about everything.'),
('PAL0846', 'mischievous', '/ˈmɪs.tʃɪ.vəs/', '', '', 'CAT16', 'B2', 'Playful in a naughty way.', 'The mischievous puppy hid my shoes.'),
('PAL0847', 'remembrance', '/rɪˈmem.brəns/', '', '', 'CAT16', 'B2', 'The act of remembering; something kept as a memory.', 'They lit candles in remembrance of the heroes.'),
('PAL0848', 'spendthrift', '/ˈspendˌθrɪft/', '', '', 'CAT16', 'B2', 'A person who spends money carelessly.', 'The spendthrift wasted his salary in a week.'),
('PAL0849', 'suspenseful', '/səˈspens.fəl/', '', '', 'CAT16', 'B2', 'Full of excitement and uncertainty about what will happen.', 'It was a suspenseful movie.'),
('PAL0850', 'synchronize', '/ˈsɪŋ.krə.naɪz/', '', '', 'CAT16', 'B2', 'To make things happen at the same time or speed.', 'Let us synchronize our watches.'),
('PAL0851', 'abolitionist', '/ˌæb.əˈlɪʃ.ən.ɪst/', '', '', 'CAT17', 'B2', 'A person who works to end something officially, especially slavery.', 'The abolitionist gave speeches against slavery.'),
('PAL0852', 'absoluteness', '/ˈæb.sə.luːt.nəs/', '', '', 'CAT17', 'B2', 'The quality of being complete and without limits.', 'The absoluteness of his power frightened people.'),
('PAL0853', 'absorptivity', '/ˌæb.sɔːrpˈtɪv.ə.ti/', '', '', 'CAT17', 'B2', 'The ability of a material to absorb something, such as light or heat.', 'Dark surfaces have high absorptivity of heat.'),
('PAL0854', 'academically', '/ˌæk.əˈdem.ɪ.kli/', '', '', 'CAT17', 'B2', 'In a way that relates to school or studying.', 'She is doing well academically.'),
('PAL0855', 'aerodynamics', '/ˌeə.roʊ.daɪˈnæm.ɪks/', '', '', 'CAT17', 'B2', 'The study of how air moves around objects.', 'Aerodynamics helps engineers design faster cars.'),
('PAL0856', 'alliteration', '/əˌlɪt.əˈreɪ.ʃən/', '', '', 'CAT17', 'B2', 'The repeating of the same sound at the start of nearby words.', 'Silly snakes slither slowly is an example of alliteration.'),
('PAL0857', 'amphitheater', '/ˈæm.fɪˌθiː.ə.tər/', '', '', 'CAT17', 'B2', 'A round, open building with rows of seats around a central space.', 'The concert was held in an ancient amphitheater.'),
('PAL0858', 'appreciation', '/əˌpriː.ʃiˈeɪ.ʃən/', '', '', 'CAT17', 'B2', 'Thankfulness; also understanding the value of something.', 'She wrote a note of appreciation to the teacher.'),
('PAL0859', 'architecture', '/ˈɑːr.kɪ.tek.tʃər/', '', '', 'CAT17', 'B2', 'The art and science of designing buildings.', 'He studies architecture at the university.'),
('PAL0860', 'bachelorette', '/ˌbætʃ.əl.əˈret/', '', '', 'CAT17', 'B2', 'A woman who is not married; also a party held for a woman before her wedding.', 'She had a bachelorette party before the wedding.'),
('PAL0861', 'behaviorally', '/bɪˈheɪ.vjər.ə.li/', '', '', 'CAT17', 'B2', 'In a way that relates to how someone acts.', 'The child improved behaviorally after the meeting.'),
('PAL0862', 'biodiversity', '/ˌbaɪ.oʊ.daɪˈvɜːr.sə.ti/', '', '', 'CAT17', 'B2', 'The variety of living things in a place.', 'The rainforest has amazing biodiversity.'),
('PAL0863', 'biomagnetism', '/ˌbaɪ.oʊˈmæɡ.nə.tɪ.zəm/', '', '', 'CAT17', 'B2', 'The magnetic fields produced by or affecting living things.', 'Scientists study biomagnetism in migrating birds.'),
('PAL0864', 'bodybuilding', '/ˈbɒd.iˌbɪl.dɪŋ/', '', '', 'CAT17', 'B2', 'The activity of lifting weights to build large muscles.', 'Bodybuilding requires regular training and a strict diet.'),
('PAL0865', 'brinkmanship', '/ˈbrɪŋk.mən.ʃɪp/', '', '', 'CAT17', 'B2', 'Pushing a dangerous situation to the edge of disaster in order to gain an advantage.', 'Political brinkmanship almost caused a war.'),
('PAL0866', 'butterscotch', '/ˈbʌt.ər.skɒtʃ/', '', '', 'CAT17', 'B2', 'A sweet flavor made from butter and brown sugar.', 'I like butterscotch ice cream.'),
('PAL0867', 'calligrapher', '/kəˈlɪɡ.rə.fər/', '', '', 'CAT17', 'B2', 'A person who writes in beautiful, decorative handwriting.', 'The calligrapher wrote the invitations by hand.'),
('PAL0868', 'capriciously', '/kəˈprɪʃ.əs.li/', '', '', 'CAT17', 'B2', 'In a way that changes suddenly for no clear reason.', 'The king ruled capriciously and changed the laws every day.'),
('PAL0869', 'childishness', '/ˈtʃaɪl.dɪʃ.nəs/', '', '', 'CAT17', 'B2', 'Behavior that is silly or immature.', 'His childishness annoyed the whole group.'),
('PAL0870', 'collaterally', '/kəˈlæt.ər.əl.i/', '', '', 'CAT17', 'B2', 'In a secondary or indirect way.', 'The new road affected the town collaterally.'),
('PAL0871', 'commissioner', '/kəˈmɪʃ.ən.ər/', '', '', 'CAT17', 'B2', 'An official in charge of a department or a group.', 'The police commissioner gave a speech.'),
('PAL0872', 'cytogenetics', '/ˌsaɪ.toʊ.dʒəˈnet.ɪks/', '', '', 'CAT17', 'B2', 'The study of cells and chromosomes in relation to heredity.', 'Cytogenetics helps doctors find genetic problems.'),
('PAL0873', 'decipherable', '/dɪˈsaɪ.fər.ə.bəl/', '', '', 'CAT17', 'B2', 'Able to be read or understood.', 'His handwriting is barely decipherable.'),
('PAL0874', 'decommission', '/ˌdiː.kəˈmɪʃ.ən/', '', '', 'CAT17', 'B2', 'To officially take something out of service.', 'The navy will decommission the old ship.'),
('PAL0875', 'eclectically', '/ɪˈklek.tɪ.kli/', '', '', 'CAT17', 'B2', 'In a way that combines many different styles or sources.', 'The room was decorated eclectically.'),
('PAL0876', 'etymological', '/ˌet.ɪ.məˈlɒdʒ.ɪ.kəl/', '', '', 'CAT17', 'B2', 'Related to the origin and history of words.', 'An etymological dictionary explains where words come from.'),
('PAL0877', 'heartrending', '/ˈhɑːrtˌren.dɪŋ/', '', '', 'CAT17', 'B2', 'Causing deep sadness or sympathy.', 'The film had a heartrending ending.'),
('PAL0878', 'hypocritical', '/ˌhɪp.əˈkrɪt.ɪ.kəl/', '', '', 'CAT17', 'B2', 'Saying one thing and doing the opposite.', 'It is hypocritical to complain about noise while playing loud music.'),
('PAL0879', 'impenetrable', '/ɪmˈpen.ɪ.trə.bəl/', '', '', 'CAT17', 'B2', 'Impossible to go through or to understand.', 'The jungle was thick and impenetrable.'),
('PAL0880', 'independence', '/ˌɪn.dɪˈpen.dəns/', '', '', 'CAT17', 'B2', 'Freedom from the control of others.', 'The country won its independence after a long struggle.'),
('PAL0881', 'inflammation', '/ˌɪn.fləˈmeɪ.ʃən/', '', '', 'CAT17', 'B2', 'Redness, swelling and pain in a part of the body.', 'The medicine reduces inflammation in the knee.'),
('PAL0882', 'infringement', '/ɪnˈfrɪndʒ.mənt/', '', '', 'CAT17', 'B2', 'The breaking of a law, a rule or a right.', 'Copying the song was an infringement of copyright.'),
('PAL0883', 'intellectual', '/ˌɪn.təlˈek.tʃu.əl/', '', '', 'CAT17', 'B2', 'Related to the mind and thinking; a person who enjoys study and ideas.', 'Chess is an intellectual game.'),
('PAL0884', 'intelligence', '/ɪnˈtel.ɪ.dʒəns/', '', '', 'CAT17', 'B2', 'The ability to learn, understand and reason.', 'Dolphins are known for their intelligence.'),
('PAL0885', 'intimidating', '/ɪnˈtɪm.ɪ.deɪ.tɪŋ/', '', '', 'CAT17', 'B2', 'Making someone feel afraid or nervous.', 'The tall guard was intimidating.'),
('PAL0886', 'jurisdiction', '/ˌdʒʊr.ɪsˈdɪk.ʃən/', '', '', 'CAT17', 'B2', 'The official power to make legal decisions over an area or a subject.', 'The case is outside the jurisdiction of this court.'),
('PAL0887', 'manufacturer', '/ˌmæn.jəˈfæk.tʃər.ər/', '', '', 'CAT17', 'B2', 'A company that makes goods in large numbers.', 'The manufacturer recalled the faulty toys.'),
('PAL0888', 'organization', '/ˌɔːr.ɡən.əˈzeɪ.ʃən/', '', '', 'CAT17', 'B2', 'A group of people working together for a purpose.', 'She works for a nonprofit organization.'),
('PAL0889', 'Pennsylvania', '/ˌpen.səlˈveɪ.ni.ə/', '', '', 'CAT17', 'B2', 'A state in the northeastern United States.', 'Philadelphia is a large city in Pennsylvania.'),
('PAL0890', 'presumptuous', '/prɪˈzʌmp.tʃu.əs/', '', '', 'CAT17', 'B2', 'Behaving with too much confidence, without having permission.', 'It was presumptuous of him to sit in my seat.'),
('PAL0891', 'professional', '/prəˈfeʃ.ən.əl/', '', '', 'CAT17', 'B2', 'Related to a job that needs special training; showing high skill.', 'She gave a professional presentation.'),
('PAL0892', 'recalcitrant', '/rɪˈkæl.sɪ.trənt/', '', '', 'CAT17', 'B2', 'Stubbornly refusing to obey rules or orders.', 'The recalcitrant student ignored every warning.'),
('PAL0893', 'relationship', '/rɪˈleɪ.ʃən.ʃɪp/', '', '', 'CAT17', 'B2', 'The way people or things are connected.', 'They have a close relationship.'),
('PAL0894', 'resurrection', '/ˌrez.əˈrek.ʃən/', '', '', 'CAT17', 'B2', 'The act of coming back to life; the return of something that had disappeared.', 'The resurrection of the old theater brought new life to the town.'),
('PAL0895', 'significance', '/sɪɡˈnɪf.ɪ.kəns/', '', '', 'CAT17', 'B2', 'The importance or meaning of something.', 'Scientists explained the significance of the discovery.'),
('PAL0896', 'sporadically', '/spəˈræd.ɪ.kli/', '', '', 'CAT17', 'B2', 'Happening at irregular times.', 'It rained sporadically throughout the day.'),
('PAL0897', 'Thanksgiving', '/ˌθæŋksˈɡɪv.ɪŋ/', '', '', 'CAT17', 'B2', 'A holiday in the United States and Canada when people give thanks, usually with a big meal.', 'Our family eats turkey on Thanksgiving.'),
('PAL0898', 'unattractive', '/ˌʌn.əˈtræk.tɪv/', '', '', 'CAT17', 'B2', 'Not pleasant to look at.', 'The old building was gray and unattractive.'),
('PAL0899', 'unsteadiness', '/ʌnˈsted.i.nəs/', '', '', 'CAT17', 'B2', 'The state of not being firm or balanced.', 'The unsteadiness of the ladder worried him.'),
('PAL0900', 'blabbermouth', '/ˈblæb.ər.maʊθ/', '', '', 'CAT17', 'B2', 'A person who talks too much or tells secrets.', 'Do not tell Sam a secret because he is a blabbermouth.'),
('PAL0901', 'Candor', '/ˈkæn.dɚ/', '', '', 'CAT11', 'B1', 'Speaking with frankness and telling the truth.', 'I appreciate your candor about the projectˈs delay.'),
('PAL0902', 'Welcome', '/ˈwelkəm/', '', '', 'CAT18', 'A1', 'A way to greet someone every day', 'Welcome to Five Stars Hotel'),
('PAL0903', 'Breakfast', '/ˈbrekfəst/', '', '', 'CAT19', 'A2', 'The first meal of the day', 'For breakfast, I would like eggs with bacon'),
('PAL0904', 'exercise', '/ˈɛksərˌsaɪz/', '', '', 'CAT19', 'A2', 'Physical activity that you do to make your body strong and healthy, or a set of questions and tasks designed to practice a skill.', 'She goes for a run and does push-ups as part of her daily exercise.'),
('PAL0905', 'good morning', '/ˌɡʊd ˈmɔːrnɪŋ/', 'palabras/imagenes/good-morning.png', '', 'CAT18', 'A1', 'A polite greeting used when you meet someone in the morning.', 'Good morning! Did you sleep well?'),
('PAL0906', 'Hello', '/həˈloʊ/', '', '', 'CAT18', 'A1', 'A word used when meeting someone or beginning a telephone conversation.', 'Hello, my name is Sarah. It is nice to meet you.'),
('PAL0907', 'good afternoon', '/ˌɡʊd ˈæftərnʊn/', '', '', 'CAT18', 'A1', 'A polite greeting used when meeting or speaking to someone in the afternoon.', 'Good afternoon, professor; I have a question about the assignment.'),
('PAL0908', 'good evening', '/ˌɡʊd ˈiːvənɪŋ/', '', '', 'CAT18', 'A1', 'A polite greeting used when you meet someone in the evening, usually after 6:00 PM.', 'Good evening, Professor, I have a question about today\'s lecture.'),
('PAL0909', 'nice to meet you', '/naɪs tu mit ju/', '', '', 'CAT18', 'A1', 'A polite phrase used when you are introduced to someone for the first time.', 'Hi, I am Sarah. - Nice to meet you, Sarah. I am John.'),
('PAL0910', 'Good night', '/ˌɡʊd ˈnaɪt/', NULL, NULL, 'CAT18', 'A1', 'A greeting used when saying goodbye to someone at night or before going to sleep.', 'Good night, Mom. See you tomorrow!'),
('PAL0911', 'Thank you', '/ˈθæŋk juː/', NULL, NULL, 'CAT18', 'A1', 'A polite expression used to show gratitude.', 'Thank you for your help.'),
('PAL0912', 'How are you?', '/ˈhaʊ ɑːr juː/', NULL, NULL, 'CAT18', 'A1', 'A common expression used to ask someone about their well-being.', 'Hello, Sarah! How are you?'),
('PAL0913', 'I\'m fine', '/aɪm faɪn/', NULL, NULL, 'CAT18', 'A1', 'An expression used to say that you are feeling well.', 'I am fine, thank you.'),
('PAL0914', 'See you', '/ˈsiː juː/', NULL, NULL, 'CAT18', 'A1', 'An informal expression used when saying goodbye to someone.', 'See you tomorrow, John!'),
('PAL0915', 'See you later', '/ˈsiː juː ˈleɪtər/', NULL, NULL, 'CAT18', 'A1', 'An informal expression used to say goodbye when you expect to meet someone again soon.', 'Goodbye, Anna! See you later.'),
('PAL0916', 'Goodbye', '/ˌɡʊdˈbaɪ/', NULL, NULL, 'CAT18', 'A1', 'A common expression used when leaving or ending a conversation.', 'Goodbye, everyone! Have a nice day.'),
('PAL0917', 'My name is', '/maɪ ˈneɪm ɪz/', NULL, NULL, 'CAT18', 'A1', 'An expression used to introduce yourself by saying your name.', 'Hello! My name is David.'),
('PAL0918', 'I', '/aɪ/', NULL, NULL, 'CAT21', 'A1', 'A subject pronoun used by the speaker to refer to themselves.', 'I am a student.'),
('PAL0919', 'You', '/juː/', NULL, NULL, 'CAT21', 'A1', 'A subject pronoun used to refer to the person or people being spoken to.', 'You are my friend.'),
('PAL0920', 'She', '/ʃiː/', NULL, NULL, 'CAT21', 'A1', 'A subject pronoun used to refer to a female person.', 'She is my teacher.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `practica_sesion`
--

CREATE TABLE `practica_sesion` (
  `clave` varchar(10) NOT NULL,
  `fecha` date NOT NULL,
  `duracion` time NOT NULL,
  `porcent_aciertos` float NOT NULL,
  `puntos_obt` float NOT NULL,
  `juego` varchar(10) NOT NULL,
  `lista` varchar(10) NOT NULL,
  `nivel` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `practica_sesion`
--

INSERT INTO `practica_sesion` (`clave`, `fecha`, `duracion`, `porcent_aciertos`, `puntos_obt`, `juego`, `lista`, `nivel`) VALUES
('PRA01', '2026-08-01', '00:02:00', 70, 100, 'J01', 'LIS01', 'A1'),
('PRA02', '2026-08-02', '00:03:00', 72.5, 110, 'J02', 'LIS02', 'A1'),
('PRA03', '2026-08-03', '00:04:00', 75, 120, 'J03', 'LIS03', 'A1'),
('PRA04', '2026-08-04', '00:05:00', 77.5, 130, 'J04', 'LIS04', 'A1'),
('PRA05', '2026-08-05', '00:06:00', 80, 140, 'J05', 'LIS05', 'A1'),
('PRA06', '2026-08-06', '00:02:00', 82.5, 150, 'J06', 'LIS06', 'A1'),
('PRA07', '2026-08-07', '00:03:00', 85, 160, 'J07', 'LIS07', 'A1'),
('PRA08', '2026-08-08', '00:04:00', 87.5, 170, 'J08', 'LIS08', 'A1'),
('PRA09', '2026-08-09', '00:05:00', 90, 180, 'J09', 'LIS09', 'A2'),
('PRA10', '2026-08-10', '00:06:00', 92.5, 190, 'J10', 'LIS10', 'A2'),
('PRA11', '2026-11-07', '00:00:00', 0, 0, 'J11', 'LIS11', 'A2'),
('PRA12', '2026-11-07', '00:00:00', 0, 0, 'J12', 'LIS12', 'A2'),
('PRA13', '2026-11-07', '00:00:00', 0, 0, 'J01', 'LIS01', 'A2'),
('PRA14', '2026-11-07', '00:00:00', 0, 0, 'J02', 'LIS02', 'A2'),
('PRA15', '2026-11-07', '00:00:00', 0, 0, 'J03', 'LIS03', 'A2'),
('PRA16', '2026-11-07', '00:00:00', 0, 0, 'J04', 'LIS04', 'A2'),
('PRA17', '2026-11-07', '00:00:00', 0, 0, 'J05', 'LIS05', 'B1'),
('PRA18', '2026-11-07', '00:00:00', 0, 0, 'J06', 'LIS06', 'B1'),
('PRA19', '2026-11-07', '00:00:00', 0, 0, 'J07', 'LIS07', 'B1'),
('PRA20', '2026-11-07', '00:00:00', 0, 0, 'J08', 'LIS08', 'B1'),
('PRA21', '2026-11-07', '00:00:00', 0, 0, 'J09', 'LIS09', 'B1'),
('PRA22', '2026-11-07', '00:00:00', 0, 0, 'J10', 'LIS10', 'B1'),
('PRA23', '2026-11-07', '00:00:00', 0, 0, 'J11', 'LIS11', 'B1'),
('PRA24', '2026-11-07', '00:00:00', 0, 0, 'J12', 'LIS12', 'B1'),
('PRA25', '2026-11-07', '00:00:00', 0, 0, 'J01', 'LIS01', 'B2'),
('PRA26', '2026-11-07', '00:00:00', 0, 0, 'J02', 'LIS02', 'B2'),
('PRA27', '2026-11-07', '00:00:00', 0, 0, 'J03', 'LIS03', 'B2'),
('PRA28', '2026-11-07', '00:00:00', 0, 0, 'J04', 'LIS04', 'B2'),
('PRA29', '2026-11-07', '00:00:00', 0, 0, 'J05', 'LIS05', 'B2'),
('PRA30', '2026-11-07', '00:00:00', 0, 0, 'J06', 'LIS06', 'B2'),
('PRA31', '2026-11-07', '00:00:00', 0, 0, 'J07', 'LIS07', 'B2'),
('PRA32', '2026-11-07', '00:00:00', 0, 0, 'J08', 'LIS08', 'B2'),
('PRA33', '2026-11-07', '00:00:00', 0, 0, 'J09', 'LIS09', 'C1'),
('PRA34', '2026-11-07', '00:00:00', 0, 0, 'J10', 'LIS10', 'C1'),
('PRA35', '2026-11-07', '00:00:00', 0, 0, 'J11', 'LIS11', 'C1'),
('PRA36', '2026-11-07', '00:00:00', 0, 0, 'J12', 'LIS12', 'C1'),
('PRA37', '2026-11-07', '00:00:00', 0, 0, 'J01', 'LIS01', 'C1'),
('PRA38', '2026-11-07', '00:00:00', 0, 0, 'J02', 'LIS02', 'C1'),
('PRA39', '2026-11-07', '00:00:00', 0, 0, 'J03', 'LIS03', 'C1'),
('PRA40', '2026-11-07', '00:00:00', 0, 0, 'J04', 'LIS04', 'C1'),
('PRA41', '2026-11-07', '00:00:00', 0, 0, 'J05', 'LIS05', 'C2'),
('PRA42', '2026-11-07', '00:00:00', 0, 0, 'J06', 'LIS06', 'C2'),
('PRA43', '2026-11-07', '00:00:00', 0, 0, 'J07', 'LIS07', 'C2'),
('PRA44', '2026-11-07', '00:00:00', 0, 0, 'J08', 'LIS08', 'C2'),
('PRA45', '2026-11-07', '00:00:00', 0, 0, 'J09', 'LIS09', 'C2'),
('PRA46', '2026-11-07', '00:00:00', 0, 0, 'J10', 'LIS10', 'C2'),
('PRA47', '2026-11-07', '00:00:00', 0, 0, 'J11', 'LIS11', 'C2'),
('PRA48', '2026-11-07', '00:00:00', 0, 0, 'J12', 'LIS12', 'C2');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proceso_lista`
--

CREATE TABLE `proceso_lista` (
  `lista` varchar(10) NOT NULL,
  `alumno` varchar(10) NOT NULL,
  `porcent_aciert` float NOT NULL,
  `lista_desbloqueada` varchar(10) NOT NULL,
  `fecha_completado` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proceso_lista`
--

INSERT INTO `proceso_lista` (`lista`, `alumno`, `porcent_aciert`, `lista_desbloqueada`, `fecha_completado`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesor`
--

CREATE TABLE `profesor` (
  `clave` varchar(10) NOT NULL,
  `nombre_pila` varchar(30) NOT NULL,
  `apellPaterno` varchar(100) NOT NULL,
  `apellMaterno` varchar(100) DEFAULT NULL,
  `usuario` varchar(10) NOT NULL,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `profesor`
--

INSERT INTO `profesor` (`clave`, `nombre_pila`, `apellPaterno`, `apellMaterno`, `usuario`, `foto`) VALUES
('PROF001', 'Alex', 'Smith', 'Johnson', 'PROF001', NULL),
('PROF002', 'John', 'Smith', 'Johnson', 'PROF002', NULL),
('PROF008', 'Jesus Omar', 'Castañon', 'Castañon', 'PROF008', NULL),
('PROF01', 'Gilda', 'Torres', 'Roman', 'USR0022', NULL),
('PROF02', 'Blanca', 'Roman', 'Ortiz', 'USR0012', NULL),
('PROF03', 'Isaac', 'Salvatierra', 'Anguilo', 'USR0013', NULL),
('PROF04', 'Ariana Lizeth', 'González', 'Osuna', 'USR0014', 'profesores_fotos/androide_21.jpeg'),
('PROF05', 'Juan Pablo', 'Quiñones', 'Hernández', 'USR0015', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puntaje`
--

CREATE TABLE `puntaje` (
  `codigo` varchar(10) NOT NULL,
  `experiencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `puntaje`
--

INSERT INTO `puntaje` (`codigo`, `experiencia`) VALUES
('PUN01', 20);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rango`
--

CREATE TABLE `rango` (
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `minimo` int(11) NOT NULL,
  `maximo` int(11) DEFAULT NULL,
  `alumno` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rango`
--

INSERT INTO `rango` (`codigo`, `nombre`, `minimo`, `maximo`, `alumno`) VALUES
('RAN01', 'Bronze', 0, 999, '2026100001'),
('RAN02', 'Silver', 1000, 2999, '2026100002'),
('RAN03', 'Gold', 3000, 5999, '2026100003'),
('RAN04', 'Diamond', 6000, 9999, '2026100004'),
('RAN05', 'Spelling Master', 10000, NULL, '2026100005');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ranking`
--

CREATE TABLE `ranking` (
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `posicion` int(11) NOT NULL,
  `periodo` varchar(20) NOT NULL,
  `puntos` int(11) NOT NULL,
  `alumno` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ranking`
--

INSERT INTO `ranking` (`codigo`, `nombre`, `posicion`, `periodo`, `puntos`, `alumno`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reporte`
--

CREATE TABLE `reporte` (
  `codigo` varchar(10) NOT NULL,
  `fecha_genera` date NOT NULL,
  `tipo_reporte` varchar(30) NOT NULL,
  `profesor` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `reporte`
--

INSERT INTO `reporte` (`codigo`, `fecha_genera`, `tipo_reporte`, `profesor`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_ranking`
--

CREATE TABLE `tipo_ranking` (
  `codigo` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(50) NOT NULL,
  `ranking` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_ranking`
--

INSERT INTO `tipo_ranking` (`codigo`, `nombre`, `descripcion`, `ranking`) VALUES
('TR01', 'Global', 'Ranking de alcance global', 'RNK01'),
('TR02', 'Por grupo', 'Ranking de alcance por grupo', 'RNK02'),
('TR03', 'Por carrera', 'Ranking de alcance por carrera', 'RNK03'),
('TR04', 'Semanal', 'Ranking de alcance semanal', 'RNK04'),
('TR05', 'Mensual', 'Ranking de alcance mensual', 'RNK05');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_usuario`
--

CREATE TABLE `tipo_usuario` (
  `clave` varchar(10) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_usuario`
--

INSERT INTO `tipo_usuario` (`clave`, `nombre`, `descripcion`) VALUES
('TUSR01', 'Student', 'Someone who practices English'),
('TUSR02', 'Teacher', 'Creates groups and teaches classes'),
('TUSR03', 'Administrator', 'The system administrator');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `codigo` varchar(10) NOT NULL,
  `nombre_pila` varchar(30) NOT NULL,
  `apellPaterno` varchar(30) NOT NULL,
  `apellMaterno` varchar(30) NOT NULL,
  `correo` varchar(50) NOT NULL,
  `contraseña` varchar(128) NOT NULL,
  `telefono` varchar(10) NOT NULL,
  `tipo_usuario` varchar(10) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL DEFAULT 0,
  `is_staff` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`codigo`, `nombre_pila`, `apellPaterno`, `apellMaterno`, `correo`, `contraseña`, `telefono`, `tipo_usuario`, `last_login`, `is_superuser`, `is_staff`, `is_active`) VALUES
('ADM002', 'Admin', 'Test', 'User', 'admin2@test.com', 'pbkdf2_sha256$1200000$5YB7mai166aHWYDaHeMF8a$hCOJneF/kBvrv9mVhMpIQkiayiLtYy+8sDT4aOxQWZs=', '6641234567', 'TUSR03', NULL, 0, 0, 1),
('ADM003', 'Admin2', 'Test', 'User', 'admin3@test.com', 'pbkdf2_sha256$1200000$BCx6p4lB66Rx2q8e0FJzTQ$oCDHhkf8DAn8k/eotqdEmPuozcB3EQNNW9kOPf2sj1k=', '6633456789', 'TUSR03', NULL, 0, 0, 1),
('ALUM001', 'Maria', 'Perez', 'Lopez', 'maria@test.com', 'pbkdf2_sha256$1200000$dzsC0lqOXrsZ0tkuGEuq2m$WfYHosk4WiuD+MPhOvGJ1fYlGJekBbgjPZvFrdgDbwI=', '6641234567', 'TUSR01', NULL, 0, 0, 1),
('PROF001', 'Alex', 'Smith', '', 'alex@test.com', 'pbkdf2_sha256$1200000$Bq5vZYFpeceyjsHgzkvrCj$zYdh7uKQqREsukAxstO7qXvZuNSXgC+w9z8XAUN3GP0=', '6641357913', 'TUSR02', NULL, 0, 0, 1),
('PROF002', 'John', 'Smith', 'Johnson', 'john@beemail.com', 'pbkdf2_sha256$1200000$2QurRGw9WOVEelpfjOLCGh$puc00YH5hsT8k2r62zP9qQtSUxvc4X43C1ehLLsPo8E=', '6641234567', 'TUSR02', NULL, 0, 0, 0),
('PROF008', 'Jesus Omar', 'Castañon', 'Castañon', 'jesus.omar@beemail.com', 'pbkdf2_sha256$1200000$Owf8PsggPZyjpT0bxhBwZf$d47sDvCtAmPx9PSxC21MKgH8JP5D44LxGPykwTQaq58=', '656 160 08', 'TUSR02', NULL, 0, 0, 1),
('USR0001', 'Renata', 'Ortega', 'Rivera', '2026100001@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$M9YE6JOiovSuKX6zWo1WgI$PPetslg2nVkT8qQN2myV1BHcJhcLEuONpXSD4SYA7Co=', '6641002001', 'TUSR01', '2026-11-09 05:11:04.022475', 0, 0, 1),
('USR0002', 'Emilio', 'Delgado', 'Duran', '2026100002@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$5bLyeSQH8d2MWVJb3AA2bi$dQbCTRzYW4y3ei3Ek2SsljzDvbve9MvSNqFodzM5+Nk=', '6641002002', 'TUSR01', '2026-11-09 04:48:47.251385', 0, 0, 1),
('USR0003', 'Ximena', 'Rojas', 'Pineda', '2026100003@ut-tijuana.edu.mx', '$2b$12$W5h8K2pLm9Qx7Vb3Nc4RdO6tYu1Ei8Fa0Gs2Hj5Kl7Mn9Pq4Rs6Tu', '6641002003', 'TUSR01', NULL, 0, 0, 1),
('USR0004', 'Adrian', 'Mendoza', 'Contreras', '2026100004@ut-tijuana.edu.mx', '$2b$12$A7cD9eF2gH4jK6mN8pQ1rS3tV5xY7zB0cE2fG4hJ6kL8mN0pQ2rS', '6641002004', 'TUSR01', NULL, 0, 0, 1),
('USR0005', 'Camila', 'Aguilar', 'Bravo', '2026100005@ut-tijuana.edu.mx', '$2b$12$Z8xC6vB4nM2aS0dF9gH7jK5lP3qW1eR8tY6uI4oP2aS9dF7gH5j', '6641002005', 'TUSR01', NULL, 0, 0, 1),
('USR0006', 'Oscar', 'Silva', 'Chavez', '2026100006@ut-tijuana.edu.mx', '$2b$12$Q4wE6rT8yU0iO2pA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR4tY6u', '6641002006', 'TUSR01', NULL, 0, 0, 1),
('USR0007', 'Brenda', 'Campos', 'Luna', '2026100007@ut-tijuana.edu.mx', '$2b$12$H3jK5lP7qW9eR1tY3uI5oA7sD9fG1hJ3kL5zX7cV9bN1mM3qW5eR', '6641002007', 'TUSR01', NULL, 0, 0, 1),
('USR0008', 'Sergio', 'Vargas', 'Robles', '2026100008@ut-tijuana.edu.mx', '$2b$12$M6nB8vC0xZ2aS4dF6gH8jK0lP2qW4eR6tY8uI0oA2sD4fG6hJ8k', '6641002008', 'TUSR01', NULL, 0, 0, 1),
('USR0009', 'Melissa', 'Pena', 'Cano', '2026100009@ut-tijuana.edu.mx', '$2b$12$R9tY7uI5oP3aS1dF9gH7jK5lP3qW1eR9tY7uI5oP3aS1dF9gH7jK', '6641002009', 'TUSR01', NULL, 0, 0, 1),
('USR0010', 'Gabriel', 'Rios', 'Solis', '2026100010@ut-tijuana.edu.mx', '$2b$12$B2vN4mM6qW8eR0tY2uI4oA6sD8fG0hJ2kL4zX6cV8bN0mM2qW4eR', '6641002010', 'TUSR01', NULL, 0, 0, 1),
('USR0011', 'Eric', 'Aycardo', 'Balcázar', '2026100011@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$bpfFZFsoHODn0FSWLhqUxT$8rp24MyGX2+7CsoLeP2V9wZYSn7I7hHofYsfYwu2fgw=', '6641470369', 'TUSR01', '2026-11-09 04:15:22.516489', 0, 0, 1),
('USR0012', 'Blanca', 'Roman', 'Ortiz', 'blanca.roman@beemail.com', 'pbkdf2_sha256$1200000$2qSYaAmBmD2VZ50KFCYwim$upxlGL8Gy2k76IQAKlK8UNF0v5Z/LKhmDvf8sjbRcao=', '6641002012', 'TUSR02', '2026-10-20 18:33:53.740400', 0, 0, 1),
('USR0013', 'Isaac', 'Salvatierra', 'Anguilo', 'isaac.salvatierra@beemail.com', 'pbkdf2_sha256$1200000$ygsdp65f7LYJHDSxT7OrYr$zd81zvi5kgVY6aR7VEgplAzhxhKnfB6C+NtgPzzfoTw=', '6641002013', 'TUSR02', '2026-10-27 18:27:18.842050', 0, 0, 1),
('USR0014', 'Ariana Lizeth', 'González', 'Osuna', 'ariana.gonzales@beemail.com', 'pbkdf2_sha256$1200000$aPnBu8VkAVZRwSizqeMRyd$6ewjFI2ev2qCdQgsS/CacYGhnygiEDN+c2J9SX6opi4=', '6641002014', 'TUSR02', '2026-11-07 05:47:09.760573', 0, 0, 1),
('USR0015', 'Juan Pablo', 'Quiñones', 'Hernández', 'juan.quinones@beemail.com', 'pbkdf2_sha256$1200000$t6m7P3OTailywgZBJ8x4oL$V0ltFjEAa1dUKGvksP4MR2DcOGpu07BtGUZFCq55zJA=', '6641002015', 'TUSR02', '2026-10-20 18:37:09.908310', 0, 0, 1),
('USR0016', 'Jesus Omar', 'Castañon', 'Castañon', 'omar.castanon@beemail.com', '$2b$12$V0bN2mM4qW6eR8tY0uI2oA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR', '6645114953', 'TUSR03', NULL, 0, 0, 1),
('USR0017', 'Josue Alberto', 'Villegas', 'Hernández', 'josue.villegas@beemail.com', '$2b$12$G9hJ7kL5zX3cV1bN9mM7qW5eR3tY1uI9oA7sD5fG3hJ1kL9zX7cV', '6646167119', 'TUSR03', NULL, 0, 0, 1),
('USR0018', 'Diego', 'Sánchez', 'Hernández', 'diego.sanchez@beemail.com', 'pbkdf2_sha256$1200000$7YZe3qCvJ7o2T20le58KGJ$FqXP2TdTCpGX8Jxx+21ZjBmysx4CxYPaIR+xfNeiS5k=', '6633288842', 'TUSR03', '2026-10-27 16:45:17.662066', 0, 0, 1),
('USR0019', 'Dulce Aurora', 'de la Cruz', 'Enriquez', 'dulce.delacruz@beemail.com', '$2b$12$Y5uI3oA1sD9fG7hJ5kL3zX1cV9bN7mM5qW3eR1tY9uI7oA5sD3fG', '6642213487', 'TUSR03', NULL, 0, 0, 1),
('USR0020', 'Aline Aketzali', 'Lucido', 'Muñoz', 'aline.lucido@beemail.com', '$2b$12$D8fG6hJ4kL2zX0cV8bN6mM4qW2eR0tY8uI6oA4sD2fG0hJ8kL6zX', '6648199271', 'TUSR03', NULL, 0, 0, 1),
('USR0021', 'Jesus Omar', 'Castañon', 'Castañon', 'jesus.omar@spell-challenge.usa', 'pbkdf2_sha256$1200000$mnlUQcBFbNJRqTps5JzuHw$zt46DvMw3QIQ9kCvRh0h/FTnqA2q0XhjQI9MQauABW0=', '', 'TUSR02', '2026-09-11 16:32:23.762934', 1, 1, 1),
('USR0022', 'Gilda', 'Torres', 'Roman', 'gilda.torres@beemail.com', 'pbkdf2_sha256$1200000$D93qaje5jV8DOq1gc1KmTQ$8kfxz9ZNEje8dD0jV57RJa8M9De01ZpLmMzoJwaRghY=', '6643692581', 'TUSR02', '2026-10-29 22:16:37.848896', 0, 0, 1),
('USR0023', 'Leonardo', 'Valdez', 'Ivan', '2026100012@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$MLjXlOOfGinxCHTlOLGDMd$j1Z+K+rIqL2iPpxoYtrBUsapD1fl4aix6b8fKRjt+ps=', '6631593715', 'TUSR01', '2026-11-09 02:58:16.525578', 0, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_groups`
--

CREATE TABLE `usuario_groups` (
  `id` bigint(20) NOT NULL,
  `usuario_id` varchar(10) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_user_permissions`
--

CREATE TABLE `usuario_user_permissions` (
  `id` bigint(20) NOT NULL,
  `usuario_id` varchar(10) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `administrador`
--
ALTER TABLE `administrador`
  ADD PRIMARY KEY (`clave`),
  ADD KEY `usuario` (`usuario`);

--
-- Indices de la tabla `alumno`
--
ALTER TABLE `alumno`
  ADD PRIMARY KEY (`matricula`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `nivel` (`nivel`),
  ADD KEY `carrera` (`carrera`);

--
-- Indices de la tabla `alumno_insignia`
--
ALTER TABLE `alumno_insignia`
  ADD PRIMARY KEY (`alumno`,`insignia`),
  ADD KEY `insignia` (`insignia`);

--
-- Indices de la tabla `alumno_leccion`
--
ALTER TABLE `alumno_leccion`
  ADD PRIMARY KEY (`alumno`,`leccion`),
  ADD KEY `leccion` (`leccion`);

--
-- Indices de la tabla `alumno_practica`
--
ALTER TABLE `alumno_practica`
  ADD PRIMARY KEY (`alumno`,`practica_sesion`),
  ADD KEY `practica_sesion` (`practica_sesion`);

--
-- Indices de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indices de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indices de la tabla `auth_user`
--
ALTER TABLE `auth_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indices de la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  ADD KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`);

--
-- Indices de la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  ADD KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `bitacora_administrador`
--
ALTER TABLE `bitacora_administrador`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `usuario` (`usuario`);

--
-- Indices de la tabla `bitacora_profesor`
--
ALTER TABLE `bitacora_profesor`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `profesor` (`profesor`);

--
-- Indices de la tabla `carrera`
--
ALTER TABLE `carrera`
  ADD PRIMARY KEY (`clave`);

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `competencia`
--
ALTER TABLE `competencia`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `profesor` (`profesor`);

--
-- Indices de la tabla `competencia_alumno`
--
ALTER TABLE `competencia_alumno`
  ADD PRIMARY KEY (`competencia`,`alumno`),
  ADD KEY `fk_competencia_alumno_alumno` (`alumno`);

--
-- Indices de la tabla `competencia_profesor`
--
ALTER TABLE `competencia_profesor`
  ADD PRIMARY KEY (`competencia`,`profesor`),
  ADD KEY `fk_competencia_profesor_profesor` (`profesor`);

--
-- Indices de la tabla `contenido_leccion`
--
ALTER TABLE `contenido_leccion`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `copia_seguridad`
--
ALTER TABLE `copia_seguridad`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `administrador` (`administrador`);

--
-- Indices de la tabla `dificultad`
--
ALTER TABLE `dificultad`
  ADD PRIMARY KEY (`clave`);

--
-- Indices de la tabla `dificultad_juego`
--
ALTER TABLE `dificultad_juego`
  ADD PRIMARY KEY (`juego`,`dificultad`),
  ADD KEY `dificultad` (`dificultad`);

--
-- Indices de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_usuario_codigo` (`user_id`);

--
-- Indices de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indices de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indices de la tabla `ejercicio`
--
ALTER TABLE `ejercicio`
  ADD PRIMARY KEY (`clave`),
  ADD KEY `fk_ejercicio_leccion` (`leccion`),
  ADD KEY `fk_ejercicio_contenido` (`contenido_leccion`);

--
-- Indices de la tabla `ejercicio_opcion`
--
ALTER TABLE `ejercicio_opcion`
  ADD PRIMARY KEY (`ejercicio`,`opcion`),
  ADD KEY `fk_ejercicio_opcion_opcion` (`opcion`);

--
-- Indices de la tabla `estado_opcion`
--
ALTER TABLE `estado_opcion`
  ADD PRIMARY KEY (`clave`);

--
-- Indices de la tabla `grupo`
--
ALTER TABLE `grupo`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `profesor` (`profesor`);

--
-- Indices de la tabla `grupo_alumno`
--
ALTER TABLE `grupo_alumno`
  ADD PRIMARY KEY (`grupo`,`alumno`),
  ADD KEY `alumno` (`alumno`);

--
-- Indices de la tabla `grupo_carrera`
--
ALTER TABLE `grupo_carrera`
  ADD PRIMARY KEY (`grupo`,`carrera`),
  ADD KEY `carrera` (`carrera`);

--
-- Indices de la tabla `insignia`
--
ALTER TABLE `insignia`
  ADD PRIMARY KEY (`clave`);

--
-- Indices de la tabla `intento_palabra`
--
ALTER TABLE `intento_palabra`
  ADD PRIMARY KEY (`clave`),
  ADD KEY `practica_sesion` (`practica_sesion`),
  ADD KEY `palabra` (`palabra`);

--
-- Indices de la tabla `juego`
--
ALTER TABLE `juego`
  ADD PRIMARY KEY (`clave`);

--
-- Indices de la tabla `leccion`
--
ALTER TABLE `leccion`
  ADD PRIMARY KEY (`clave`),
  ADD KEY `practica_sesion` (`practica_sesion`),
  ADD KEY `puntaje` (`puntaje`),
  ADD KEY `fk_leccion_contenido` (`contenido_leccion`);

--
-- Indices de la tabla `leccion_palabra`
--
ALTER TABLE `leccion_palabra`
  ADD PRIMARY KEY (`leccion`,`palabra`),
  ADD KEY `fk_leccion_palabra_palabra` (`palabra`);

--
-- Indices de la tabla `lista`
--
ALTER TABLE `lista`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `profesor` (`profesor`);

--
-- Indices de la tabla `lista_competencia`
--
ALTER TABLE `lista_competencia`
  ADD PRIMARY KEY (`lista`,`competencia`),
  ADD KEY `competencia` (`competencia`);

--
-- Indices de la tabla `lista_grupo`
--
ALTER TABLE `lista_grupo`
  ADD PRIMARY KEY (`lista`,`grupo`),
  ADD KEY `grupo` (`grupo`);

--
-- Indices de la tabla `lista_leccion`
--
ALTER TABLE `lista_leccion`
  ADD PRIMARY KEY (`lista`,`leccion`),
  ADD KEY `leccion` (`leccion`);

--
-- Indices de la tabla `lista_palabra`
--
ALTER TABLE `lista_palabra`
  ADD PRIMARY KEY (`lista`,`palabra`),
  ADD KEY `palabra` (`palabra`);

--
-- Indices de la tabla `nivel`
--
ALTER TABLE `nivel`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notificacion_alumno` (`alumno`),
  ADD KEY `idx_notificacion_competencia` (`competencia`),
  ADD KEY `idx_notificacion_insignia` (`insignia`),
  ADD KEY `idx_notificacion_alumno_leida` (`alumno`,`leida`);

--
-- Indices de la tabla `opcion`
--
ALTER TABLE `opcion`
  ADD PRIMARY KEY (`clave`),
  ADD KEY `fk_opcion_estado` (`estado_opcion`);

--
-- Indices de la tabla `palabra`
--
ALTER TABLE `palabra`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `categoria` (`categoria`),
  ADD KEY `nivel` (`nivel`);

--
-- Indices de la tabla `practica_sesion`
--
ALTER TABLE `practica_sesion`
  ADD PRIMARY KEY (`clave`),
  ADD KEY `juego` (`juego`),
  ADD KEY `lista` (`lista`);

--
-- Indices de la tabla `proceso_lista`
--
ALTER TABLE `proceso_lista`
  ADD PRIMARY KEY (`lista`,`alumno`),
  ADD KEY `alumno` (`alumno`);

--
-- Indices de la tabla `profesor`
--
ALTER TABLE `profesor`
  ADD PRIMARY KEY (`clave`),
  ADD KEY `usuario` (`usuario`);

--
-- Indices de la tabla `puntaje`
--
ALTER TABLE `puntaje`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `rango`
--
ALTER TABLE `rango`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `alumno` (`alumno`);

--
-- Indices de la tabla `ranking`
--
ALTER TABLE `ranking`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `alumno` (`alumno`);

--
-- Indices de la tabla `reporte`
--
ALTER TABLE `reporte`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `profesor` (`profesor`);

--
-- Indices de la tabla `tipo_ranking`
--
ALTER TABLE `tipo_ranking`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `ranking` (`ranking`);

--
-- Indices de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  ADD PRIMARY KEY (`clave`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`codigo`),
  ADD UNIQUE KEY `usuario_correo_unique` (`correo`),
  ADD KEY `tipo_usuario` (`tipo_usuario`);

--
-- Indices de la tabla `usuario_groups`
--
ALTER TABLE `usuario_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuario_groups_usuario_id_group_id_uniq` (`usuario_id`,`group_id`),
  ADD KEY `usuario_groups_group_id_fk` (`group_id`);

--
-- Indices de la tabla `usuario_user_permissions`
--
ALTER TABLE `usuario_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuario_user_permissions_usuario_id_permission_id_uniq` (`usuario_id`,`permission_id`),
  ADD KEY `usuario_user_permissions_permission_id_fk` (`permission_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT de la tabla `auth_user`
--
ALTER TABLE `auth_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `usuario_groups`
--
ALTER TABLE `usuario_groups`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuario_user_permissions`
--
ALTER TABLE `usuario_user_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `administrador`
--
ALTER TABLE `administrador`
  ADD CONSTRAINT `1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`codigo`);

--
-- Filtros para la tabla `alumno`
--
ALTER TABLE `alumno`
  ADD CONSTRAINT `1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`nivel`) REFERENCES `nivel` (`codigo`),
  ADD CONSTRAINT `3` FOREIGN KEY (`carrera`) REFERENCES `carrera` (`clave`);

--
-- Filtros para la tabla `alumno_insignia`
--
ALTER TABLE `alumno_insignia`
  ADD CONSTRAINT `1` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`),
  ADD CONSTRAINT `2` FOREIGN KEY (`insignia`) REFERENCES `insignia` (`clave`);

--
-- Filtros para la tabla `alumno_leccion`
--
ALTER TABLE `alumno_leccion`
  ADD CONSTRAINT `1` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`),
  ADD CONSTRAINT `2` FOREIGN KEY (`leccion`) REFERENCES `leccion` (`clave`);

--
-- Filtros para la tabla `alumno_practica`
--
ALTER TABLE `alumno_practica`
  ADD CONSTRAINT `1` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`),
  ADD CONSTRAINT `2` FOREIGN KEY (`practica_sesion`) REFERENCES `practica_sesion` (`clave`);

--
-- Filtros para la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Filtros para la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Filtros para la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  ADD CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `bitacora_administrador`
--
ALTER TABLE `bitacora_administrador`
  ADD CONSTRAINT `1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`codigo`);

--
-- Filtros para la tabla `bitacora_profesor`
--
ALTER TABLE `bitacora_profesor`
  ADD CONSTRAINT `1` FOREIGN KEY (`profesor`) REFERENCES `profesor` (`clave`);

--
-- Filtros para la tabla `competencia`
--
ALTER TABLE `competencia`
  ADD CONSTRAINT `1` FOREIGN KEY (`profesor`) REFERENCES `profesor` (`clave`);

--
-- Filtros para la tabla `competencia_alumno`
--
ALTER TABLE `competencia_alumno`
  ADD CONSTRAINT `fk_competencia_alumno_alumno` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_competencia_alumno_competencia` FOREIGN KEY (`competencia`) REFERENCES `competencia` (`codigo`) ON DELETE CASCADE;

--
-- Filtros para la tabla `competencia_profesor`
--
ALTER TABLE `competencia_profesor`
  ADD CONSTRAINT `fk_competencia_profesor_competencia` FOREIGN KEY (`competencia`) REFERENCES `competencia` (`codigo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_competencia_profesor_profesor` FOREIGN KEY (`profesor`) REFERENCES `profesor` (`clave`) ON DELETE CASCADE;

--
-- Filtros para la tabla `copia_seguridad`
--
ALTER TABLE `copia_seguridad`
  ADD CONSTRAINT `1` FOREIGN KEY (`administrador`) REFERENCES `administrador` (`clave`);

--
-- Filtros para la tabla `dificultad_juego`
--
ALTER TABLE `dificultad_juego`
  ADD CONSTRAINT `1` FOREIGN KEY (`juego`) REFERENCES `juego` (`clave`),
  ADD CONSTRAINT `2` FOREIGN KEY (`dificultad`) REFERENCES `dificultad` (`clave`);

--
-- Filtros para la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_usuario_codigo` FOREIGN KEY (`user_id`) REFERENCES `usuario` (`codigo`);

--
-- Filtros para la tabla `ejercicio`
--
ALTER TABLE `ejercicio`
  ADD CONSTRAINT `fk_ejercicio_contenido` FOREIGN KEY (`contenido_leccion`) REFERENCES `contenido_leccion` (`codigo`),
  ADD CONSTRAINT `fk_ejercicio_leccion` FOREIGN KEY (`leccion`) REFERENCES `leccion` (`clave`);

--
-- Filtros para la tabla `ejercicio_opcion`
--
ALTER TABLE `ejercicio_opcion`
  ADD CONSTRAINT `fk_ejercicio_opcion_ejercicio` FOREIGN KEY (`ejercicio`) REFERENCES `ejercicio` (`clave`),
  ADD CONSTRAINT `fk_ejercicio_opcion_opcion` FOREIGN KEY (`opcion`) REFERENCES `opcion` (`clave`);

--
-- Filtros para la tabla `grupo`
--
ALTER TABLE `grupo`
  ADD CONSTRAINT `1` FOREIGN KEY (`profesor`) REFERENCES `profesor` (`clave`);

--
-- Filtros para la tabla `grupo_alumno`
--
ALTER TABLE `grupo_alumno`
  ADD CONSTRAINT `1` FOREIGN KEY (`grupo`) REFERENCES `grupo` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`);

--
-- Filtros para la tabla `grupo_carrera`
--
ALTER TABLE `grupo_carrera`
  ADD CONSTRAINT `1` FOREIGN KEY (`grupo`) REFERENCES `grupo` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`carrera`) REFERENCES `carrera` (`clave`);

--
-- Filtros para la tabla `intento_palabra`
--
ALTER TABLE `intento_palabra`
  ADD CONSTRAINT `1` FOREIGN KEY (`practica_sesion`) REFERENCES `practica_sesion` (`clave`),
  ADD CONSTRAINT `2` FOREIGN KEY (`palabra`) REFERENCES `palabra` (`codigo`);

--
-- Filtros para la tabla `leccion`
--
ALTER TABLE `leccion`
  ADD CONSTRAINT `1` FOREIGN KEY (`practica_sesion`) REFERENCES `practica_sesion` (`clave`),
  ADD CONSTRAINT `2` FOREIGN KEY (`puntaje`) REFERENCES `puntaje` (`codigo`),
  ADD CONSTRAINT `fk_leccion_contenido` FOREIGN KEY (`contenido_leccion`) REFERENCES `contenido_leccion` (`codigo`);

--
-- Filtros para la tabla `leccion_palabra`
--
ALTER TABLE `leccion_palabra`
  ADD CONSTRAINT `fk_leccion_palabra_leccion` FOREIGN KEY (`leccion`) REFERENCES `leccion` (`clave`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_leccion_palabra_palabra` FOREIGN KEY (`palabra`) REFERENCES `palabra` (`codigo`) ON DELETE CASCADE;

--
-- Filtros para la tabla `lista`
--
ALTER TABLE `lista`
  ADD CONSTRAINT `1` FOREIGN KEY (`profesor`) REFERENCES `profesor` (`clave`);

--
-- Filtros para la tabla `lista_competencia`
--
ALTER TABLE `lista_competencia`
  ADD CONSTRAINT `1` FOREIGN KEY (`lista`) REFERENCES `lista` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`competencia`) REFERENCES `competencia` (`codigo`);

--
-- Filtros para la tabla `lista_grupo`
--
ALTER TABLE `lista_grupo`
  ADD CONSTRAINT `1` FOREIGN KEY (`lista`) REFERENCES `lista` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`grupo`) REFERENCES `grupo` (`codigo`);

--
-- Filtros para la tabla `lista_leccion`
--
ALTER TABLE `lista_leccion`
  ADD CONSTRAINT `1` FOREIGN KEY (`lista`) REFERENCES `lista` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`leccion`) REFERENCES `leccion` (`clave`);

--
-- Filtros para la tabla `lista_palabra`
--
ALTER TABLE `lista_palabra`
  ADD CONSTRAINT `1` FOREIGN KEY (`lista`) REFERENCES `lista` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`palabra`) REFERENCES `palabra` (`codigo`);

--
-- Filtros para la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD CONSTRAINT `fk_notificacion_alumno` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_notificacion_competencia` FOREIGN KEY (`competencia`) REFERENCES `competencia` (`codigo`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_notificacion_insignia` FOREIGN KEY (`insignia`) REFERENCES `insignia` (`clave`) ON DELETE SET NULL;

--
-- Filtros para la tabla `opcion`
--
ALTER TABLE `opcion`
  ADD CONSTRAINT `fk_opcion_estado` FOREIGN KEY (`estado_opcion`) REFERENCES `estado_opcion` (`clave`);

--
-- Filtros para la tabla `palabra`
--
ALTER TABLE `palabra`
  ADD CONSTRAINT `1` FOREIGN KEY (`categoria`) REFERENCES `categoria` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`nivel`) REFERENCES `nivel` (`codigo`);

--
-- Filtros para la tabla `practica_sesion`
--
ALTER TABLE `practica_sesion`
  ADD CONSTRAINT `1` FOREIGN KEY (`juego`) REFERENCES `juego` (`clave`),
  ADD CONSTRAINT `2` FOREIGN KEY (`lista`) REFERENCES `lista` (`codigo`);

--
-- Filtros para la tabla `proceso_lista`
--
ALTER TABLE `proceso_lista`
  ADD CONSTRAINT `1` FOREIGN KEY (`lista`) REFERENCES `lista` (`codigo`),
  ADD CONSTRAINT `2` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`);

--
-- Filtros para la tabla `profesor`
--
ALTER TABLE `profesor`
  ADD CONSTRAINT `1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`codigo`);

--
-- Filtros para la tabla `rango`
--
ALTER TABLE `rango`
  ADD CONSTRAINT `1` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`);

--
-- Filtros para la tabla `ranking`
--
ALTER TABLE `ranking`
  ADD CONSTRAINT `1` FOREIGN KEY (`alumno`) REFERENCES `alumno` (`matricula`);

--
-- Filtros para la tabla `reporte`
--
ALTER TABLE `reporte`
  ADD CONSTRAINT `1` FOREIGN KEY (`profesor`) REFERENCES `profesor` (`clave`);

--
-- Filtros para la tabla `tipo_ranking`
--
ALTER TABLE `tipo_ranking`
  ADD CONSTRAINT `1` FOREIGN KEY (`ranking`) REFERENCES `ranking` (`codigo`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `1` FOREIGN KEY (`tipo_usuario`) REFERENCES `tipo_usuario` (`clave`);

--
-- Filtros para la tabla `usuario_groups`
--
ALTER TABLE `usuario_groups`
  ADD CONSTRAINT `usuario_groups_group_id_fk` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  ADD CONSTRAINT `usuario_groups_usuario_id_fk` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`codigo`);

--
-- Filtros para la tabla `usuario_user_permissions`
--
ALTER TABLE `usuario_user_permissions`
  ADD CONSTRAINT `usuario_user_permissions_permission_id_fk` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `usuario_user_permissions_usuario_id_fk` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`codigo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
