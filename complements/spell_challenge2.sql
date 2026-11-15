-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-11-2026 a las 00:02:59
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
-- Base de datos: `spellchallenge`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_ejercicios_lesson` (IN `p_leccion` VARCHAR(10), IN `p_datos` LONGTEXT)   BEGIN

    -- ========================================================
    -- 1. DECLARACION DE VARIABLES
    -- ========================================================

    -- Control de ejecucion y bloqueo.
    DECLARE v_lock_result INT DEFAULT 0;

    -- Validaciones generales.
    DECLARE v_leccion_existe INT DEFAULT 0;
    DECLARE v_ejercicios_existentes INT DEFAULT 0;

    -- Contadores para recorrer el JSON.
    DECLARE v_total_ejercicios INT DEFAULT 0;
    DECLARE v_total_opciones INT DEFAULT 0;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_j INT DEFAULT 0;

    -- Datos temporales de cada ejercicio.
    DECLARE v_ejercicio_json LONGTEXT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_descripcion TEXT;
    DECLARE v_contenido VARCHAR(5);

    -- Datos temporales de las opciones.
    DECLARE v_opcion_json LONGTEXT;
    DECLARE v_opcion_nombre VARCHAR(100);
    DECLARE v_opcion_descripcion TEXT;
    DECLARE v_estado VARCHAR(5);
    DECLARE v_correctas INT DEFAULT 0;

    -- Control de las claves consecutivas.
    DECLARE v_eje_num INT DEFAULT 0;
    DECLARE v_op_num INT DEFAULT 0;
    DECLARE v_eje_clave VARCHAR(8);
    DECLARE v_op_clave VARCHAR(8);

    -- ========================================================
    -- 2. MANEJADOR DE ERRORES
    -- ========================================================

    -- Si ocurre cualquier error SQL durante la ejecucion,
    -- cancelamos todas las inserciones realizadas.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        -- Revertimos los cambios de la transaccion.
        ROLLBACK;

        -- Liberamos el bloqueo si fue adquirido.
        IF v_lock_result = 1 THEN
            DO RELEASE_LOCK('spellchallenge_insert_ejercicios');
        END IF;

        -- Devolvemos el error original a phpMyAdmin.
        RESIGNAL;

    END;

    -- ========================================================
    -- 3. INICIO DE LA EJECUCION
    -- ========================================================

    -- Solicitamos un bloqueo exclusivo para evitar que
    -- dos ejecuciones generen las mismas claves simultaneamente.
    SELECT GET_LOCK('spellchallenge_insert_ejercicios', 10)
    INTO v_lock_result;

    -- Comprobamos que el bloqueo se haya obtenido correctamente.
    IF v_lock_result IS NULL OR v_lock_result <> 1 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Could not obtain the exercise registration lock.';

    END IF;

    -- Iniciamos la transaccion.
    START TRANSACTION;

    -- ========================================================
    -- 4. VALIDACIONES INICIALES
    -- ========================================================

    -- Comprobamos que la Lesson indicada exista.
    SELECT COUNT(*)
    INTO v_leccion_existe
    FROM leccion
    WHERE clave = p_leccion;

    IF v_leccion_existe = 0 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The specified Lesson does not exist.';

    END IF;

    -- Comprobamos que los datos recibidos sean un JSON valido.
    IF p_datos IS NULL OR JSON_VALID(p_datos) = 0 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The provided data is not a valid JSON document.';

    END IF;

    -- Comprobamos que el JSON principal sea un objeto.
    IF JSON_TYPE(p_datos) <> 'OBJECT' THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The JSON root must be an object.';

    END IF;


    -- Comprobamos que exista la propiedad "ejercicios".
    IF JSON_CONTAINS_PATH(p_datos, 'one', '$.ejercicios') = 0 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The JSON document must contain the ejercicios property.';

    END IF;


    -- Comprobamos que "ejercicios" sea un arreglo.
    IF JSON_TYPE(JSON_EXTRACT(p_datos, '$.ejercicios')) <> 'ARRAY' THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The ejercicios property must be an array.';

    END IF;


    -- Obtenemos la cantidad de ejercicios recibidos.
    SET v_total_ejercicios =
        JSON_LENGTH(JSON_EXTRACT(p_datos, '$.ejercicios'));


    -- No permitimos registrar una Lesson sin ejercicios.
    IF v_total_ejercicios = 0 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'At least one exercise must be provided.';

    END IF;

    -- Comprobamos si la Lesson ya tiene ejercicios registrados.
    SELECT COUNT(*)
    INTO v_ejercicios_existentes
    FROM ejercicio
    WHERE leccion = p_leccion;

    IF v_ejercicios_existentes > 0 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This Lesson already has registered exercises.';

    END IF;

    -- ========================================================
    -- 5. GENERACION AUTOMATICA DE CLAVES
    -- ========================================================

    -- Obtenemos el numero mas alto utilizado en las claves
    -- de ejercicios y calculamos el siguiente disponible.
    SELECT COALESCE(
        MAX(CAST(SUBSTRING(clave, 4) AS UNSIGNED)),
        0
    )
    INTO v_eje_num
    FROM ejercicio
    WHERE clave REGEXP '^EJE[0-9]+$';

    -- Obtenemos el numero mas alto utilizado en las claves
    -- de opciones y calculamos el siguiente disponible.
    SELECT COALESCE(
        MAX(CAST(SUBSTRING(clave, 3) AS UNSIGNED)),
        0
    )
    INTO v_op_num
    FROM opcion
    WHERE clave REGEXP '^OP[0-9]+$';

    -- ========================================================
    -- 6. RECORRIDO Y REGISTRO DE EJERCICIOS
    -- ========================================================

    -- Iniciamos el recorrido del arreglo "ejercicios".
    -- Los arreglos JSON comienzan en la posicion 0.
    SET v_i = 0;

    WHILE v_i < v_total_ejercicios DO

        -- Extraemos el ejercicio actual como un objeto JSON.
        SET v_ejercicio_json = JSON_EXTRACT(
            p_datos,
            CONCAT('$.ejercicios[', v_i, ']')
        );


        -- Comprobamos que el elemento actual sea un objeto.
        IF JSON_TYPE(v_ejercicio_json) <> 'OBJECT' THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Each exercise must be a JSON object.';

        END IF;


        -- Comprobamos que tenga sus propiedades obligatorias.
        IF JSON_CONTAINS_PATH(
            v_ejercicio_json,
            'all',
            '$.nombre',
            '$.descripcion',
            '$.contenido',
            '$.opciones'
        ) = 0 THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'An exercise is missing required properties.';

        END IF;


        -- Comprobamos que nombre, descripcion y contenido
        -- sean valores de texto.
        IF JSON_TYPE(JSON_EXTRACT(v_ejercicio_json, '$.nombre')) <> 'STRING'
           OR JSON_TYPE(JSON_EXTRACT(v_ejercicio_json, '$.descripcion')) <> 'STRING'
           OR JSON_TYPE(JSON_EXTRACT(v_ejercicio_json, '$.contenido')) <> 'STRING' THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Exercise name, description and content must be strings.';

        END IF;


        -- Extraemos los datos del ejercicio actual.
        SET v_nombre = JSON_UNQUOTE(
            JSON_EXTRACT(v_ejercicio_json, '$.nombre')
        );

        SET v_descripcion = JSON_UNQUOTE(
            JSON_EXTRACT(v_ejercicio_json, '$.descripcion')
        );

        SET v_contenido = JSON_UNQUOTE(
            JSON_EXTRACT(v_ejercicio_json, '$.contenido')
        );


        -- Validamos que los campos obligatorios no esten vacios.
        IF TRIM(v_nombre) = ''
           OR TRIM(v_descripcion) = ''
           OR TRIM(v_contenido) = '' THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Exercise fields cannot be empty.';

        END IF;


        -- Validamos que el nombre no supere los 100 caracteres.
        IF CHAR_LENGTH(v_nombre) > 100 THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Exercise name exceeds 100 characters.';

        END IF;


        -- Comprobamos que el contenido curricular exista.
        IF NOT EXISTS (
            SELECT 1
            FROM contenido_leccion
            WHERE codigo = v_contenido
        ) THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'The specified lesson content does not exist.';

        END IF;


        -- Comprobamos que las opciones sean un arreglo JSON.
        IF JSON_TYPE(JSON_EXTRACT(v_ejercicio_json, '$.opciones')) <> 'ARRAY' THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Exercise options must be an array.';

        END IF;


        -- Obtenemos la cantidad de opciones del ejercicio actual.
        SET v_total_opciones = JSON_LENGTH(
            JSON_EXTRACT(v_ejercicio_json, '$.opciones')
        );

        
        -- Incrementamos el consecutivo de ejercicios.
        SET v_eje_num = v_eje_num + 1;


        -- Comprobamos que la clave no supere la capacidad
        -- disponible de VARCHAR(8).
        IF v_eje_num > 99999 THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'The maximum exercise key limit has been reached.';

        END IF;


        -- Generamos la clave del ejercicio.
        -- Conservamos dos digitos como minimo, sin truncar
        -- los numeros que superen las dos posiciones.
        SET v_eje_clave = CONCAT(
            'EJE',
            IF(
                v_eje_num < 10,
                LPAD(v_eje_num, 2, '0'),
                CAST(v_eje_num AS CHAR)
            )
        );

        -- Registramos el ejercicio en la base de datos.
        INSERT INTO ejercicio (
            clave,
            nombre,
            descripcion,
            leccion,
            contenido_leccion
        )
        VALUES (
            v_eje_clave,
            v_nombre,
            v_descripcion,
            p_leccion,
            v_contenido
        );

        -- ====================================================
        -- 7. RECORRIDO Y REGISTRO DE OPCIONES
        -- ====================================================

        -- Reiniciamos el contador de respuestas correctas
        -- para evaluar individualmente cada ejercicio.
        SET v_correctas = 0;

        -- Iniciamos el recorrido de las opciones.
        SET v_j = 0;

        WHILE v_j < v_total_opciones DO

            -- Extraemos la opcion actual del arreglo JSON.
            SET v_opcion_json = JSON_EXTRACT(
                v_ejercicio_json,
                CONCAT('$.opciones[', v_j, ']')
            );


            -- Comprobamos que cada opcion sea un objeto.
            IF JSON_TYPE(v_opcion_json) <> 'OBJECT' THEN

                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Each option must be a JSON object.';

            END IF;


            -- Comprobamos que la opcion tenga sus propiedades obligatorias.
            IF JSON_CONTAINS_PATH(
                v_opcion_json,
                'all',
                '$.nombre',
                '$.descripcion',
                '$.estado'
            ) = 0 THEN

                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'An option is missing required properties.';

            END IF;


            -- Comprobamos que las propiedades sean valores de texto.
            IF JSON_TYPE(JSON_EXTRACT(v_opcion_json, '$.nombre')) <> 'STRING'
               OR JSON_TYPE(JSON_EXTRACT(v_opcion_json, '$.descripcion')) <> 'STRING'
               OR JSON_TYPE(JSON_EXTRACT(v_opcion_json, '$.estado')) <> 'STRING' THEN

                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Option fields must be strings.';

            END IF;


            -- Extraemos los datos de la opcion.
            SET v_opcion_nombre = JSON_UNQUOTE(
                JSON_EXTRACT(v_opcion_json, '$.nombre')
            );

            SET v_opcion_descripcion = JSON_UNQUOTE(
                JSON_EXTRACT(v_opcion_json, '$.descripcion')
            );

            SET v_estado = JSON_UNQUOTE(
                JSON_EXTRACT(v_opcion_json, '$.estado')
            );


            -- Validamos que los campos no esten vacios.
            IF TRIM(v_opcion_nombre) = ''
               OR TRIM(v_opcion_descripcion) = ''
               OR TRIM(v_estado) = '' THEN

                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Option fields cannot be empty.';

            END IF;


            -- Validamos la longitud del nombre de la opcion.
            IF CHAR_LENGTH(v_opcion_nombre) > 100 THEN

                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Option name exceeds 100 characters.';

            END IF;

            -- Solo permitimos los estados existentes para las opciones:
            -- EST01 = Correct
            -- EST02 = Incorrect
            IF v_estado NOT IN ('EST01', 'EST02') THEN

                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Option state must be EST01 or EST02.';

            END IF;


            -- Comprobamos que el estado exista en la tabla correspondiente.
            IF NOT EXISTS (
                SELECT 1
                FROM estado_opcion
                WHERE clave = v_estado
            ) THEN

                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'The specified option state does not exist.';

            END IF;


            -- Contabilizamos las respuestas correctas.
            IF v_estado = 'EST01' THEN

                SET v_correctas = v_correctas + 1;

            END IF;


            
            -- Incrementamos el consecutivo de opciones.
            SET v_op_num = v_op_num + 1;


            -- Comprobamos que la clave no supere la capacidad
            -- disponible de VARCHAR(8).
            IF v_op_num > 999999 THEN

                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'The maximum option key limit has been reached.';

            END IF;

            -- Generamos la clave de la opcion.
            -- Conservamos dos digitos como minimo, sin truncar
            -- los numeros que superen las dos posiciones.
            SET v_op_clave = CONCAT(
                'OP',
                IF(
                    v_op_num < 10,
                    LPAD(v_op_num, 2, '0'),
                    CAST(v_op_num AS CHAR)
                )
            );

            -- Registramos la opcion.
            INSERT INTO opcion (
                clave,
                nombre,
                descripcion,
                estado_opcion
            )
            VALUES (
                v_op_clave,
                v_opcion_nombre,
                v_opcion_descripcion,
                v_estado
            );


            -- Relacionamos la opcion con el ejercicio actual.
            INSERT INTO ejercicio_opcion (
                ejercicio,
                opcion
            )
            VALUES (
                v_eje_clave,
                v_op_clave
            );


            -- Avanzamos a la siguiente opcion.
            SET v_j = v_j + 1;

        END WHILE;

        -- Si el ejercicio tiene opciones, debe existir
        -- exactamente una respuesta correcta.
        IF v_total_opciones > 0 AND v_correctas <> 1 THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Each exercise with options must have exactly one correct answer.';

        END IF;

        -- Avanzamos al siguiente ejercicio del arreglo JSON.
        SET v_i = v_i + 1;

    END WHILE;

    -- ========================================================
    -- 8. FINALIZACION DEL PROCEDIMIENTO
    -- ========================================================

    -- Confirmamos todas las inserciones realizadas.
    COMMIT;


    -- Liberamos el bloqueo para permitir nuevas ejecuciones.
    DO RELEASE_LOCK('spellchallenge_insert_ejercicios');


    -- Devolvemos un mensaje de confirmacion.
    SELECT
        'Exercises registered successfully.' AS resultado,
        p_leccion AS leccion,
        v_total_ejercicios AS ejercicios_registrados;


END$$

DELIMITER ;

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
('0324108155', 'Jesus Omar', 'Castañon', 'Castañon', 'USR0024', 'B2', 'DSM', '', 20, 0),
('2026100001', 'Renata', 'Ortega', 'Rivera', 'USR0001', 'B1', 'EII', 'alumnos_fotos/chicken.png', 320, 12),
('2026100002', 'Emilio', 'Delgado', 'Duran', 'USR0002', 'A2', 'PP', NULL, 0, 5),
('2026100003', 'Ximena', 'Rojas', 'Pineda', 'USR0003', 'B1', 'OLCE', NULL, 0, 0),
('2026100004', 'Adrian', 'Mendoza', 'Contreras', 'USR0004', 'B1', 'DSM', NULL, 0, 0),
('2026100005', 'Camila', 'Aguilar', 'Bravo', 'USR0005', 'C1', 'IRD', NULL, 0, 0),
('2026100006', 'Oscar', 'Silva', 'Chavez', 'USR0006', 'C1', 'EII', NULL, 0, 0),
('2026100007', 'Brenda', 'Campos', 'Luna', 'USR0007', 'A2', 'PP', NULL, 0, 0),
('2026100008', 'Sergio', 'Vargas', 'Robles', 'USR0008', 'B2', 'OLCE', NULL, 0, 0),
('2026100009', 'Melissa', 'Pena', 'Cano', 'USR0009', 'B2', 'DSM', NULL, 0, 0),
('2026100010', 'Gabriel', 'Rios', 'Solis', 'USR0010', 'B1', 'IRD', NULL, 0, 0),
('2026100011', 'Eric', 'Aycardo', 'Balcázar', 'USR0011', 'C1', 'DSM', 'alumnos_fotos/gogeta-blue-ultra-db-legends.jfif', 100, 15),
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
('BITP14', '2026-10-27', '14:51:50', 'Created a new competition: Spell Challenge Competition.', 'PROF04'),
('BITP15', '2026-11-13', '09:34:18', 'Created a new competition: Winter Spelling Bee.', 'PROF02'),
('BITP16', '2026-11-15', '14:40:27', 'Created a new competition: Spell Competition.', 'PROF01');

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
('COM10', 'Spelling Competition', '2026-10-09', '15:15:00', 'PROF01', 'Finished', 'LIST'),
('COM11', 'Nature Spelling Challenge', '2026-10-19', '09:15:00', 'PROF02', 'Finished', 'LIST'),
('COM12', 'Tech Spelling Bee', '2026-10-19', '09:30:00', 'PROF03', 'Finished', 'LIST'),
('COM13', 'Spelling Bee Competition', '2026-10-21', '09:30:00', 'PROF03', 'Active', 'GENERAL'),
('COM14', 'Spell Challenge Competition', '2026-10-28', '08:50:00', 'PROF04', 'Upcoming', 'GENERAL'),
('COM15', 'Winter Spelling Bee', '2026-11-16', '10:30:00', 'PROF02', 'Active', 'GENERAL'),
('COM16', 'Spell Competition', '2026-11-16', '10:45:00', 'PROF01', 'Upcoming', 'GENERAL');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `competencia_alumno`
--

CREATE TABLE `competencia_alumno` (
  `competencia` varchar(10) NOT NULL,
  `alumno` varchar(10) NOT NULL,
  `puntos_obtenidos` int(11) DEFAULT NULL,
  `palabras_correctas` int(11) DEFAULT NULL,
  `palabras_incorrectas` int(11) DEFAULT NULL,
  `posicion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `competencia_alumno`
--

INSERT INTO `competencia_alumno` (`competencia`, `alumno`, `puntos_obtenidos`, `palabras_correctas`, `palabras_incorrectas`, `posicion`) VALUES
('COM01', '2026100002', 95, 19, 1, NULL),
('COM02', '2026100003', 88, 18, 2, NULL),
('COM02', '2026100011', 100, 10, 0, NULL),
('COM03', '2026100004', 100, 20, 0, NULL),
('COM04', '2026100002', 90, 9, 1, NULL),
('COM04', '2026100005', NULL, NULL, NULL, NULL),
('COM05', '2026100006', NULL, NULL, NULL, NULL),
('COM06', '2026100001', 90, 9, 9, NULL),
('COM06', '2026100006', 80, 8, 8, NULL),
('COM06', '2026100007', 70, 7, 7, NULL),
('COM07', '2026100010', NULL, NULL, NULL, NULL),
('COM08', '2026100002', 80, 8, 2, NULL),
('COM08', '2026100004', 100, 10, 0, NULL),
('COM08', '2026100009', NULL, NULL, NULL, NULL),
('COM08', '2026100010', NULL, NULL, NULL, NULL),
('COM10', '2026100001', 0, 0, 0, NULL),
('COM10', '2026100002', 0, 0, 0, NULL),
('COM11', '2026100002', 100, 10, 0, 1),
('COM11', '2026100007', 90, 9, 1, 2),
('COM12', '2026100011', 100, 10, 0, NULL),
('COM12', '2026100012', 100, 10, 0, NULL),
('COM13', '2026100011', 0, 0, 0, NULL),
('COM15', '2026100012', 0, 0, 0, NULL);

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
  `clave` varchar(8) NOT NULL,
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
('EJE100', 'Listening to Names', 'Listen and choose the name you hear.', 'LEC09', 'CON04'),
('EJE101', 'Listening to Age', 'Listen and choose the correct age.', 'LEC09', 'CON04'),
('EJE102', 'Listening to Occupations', 'Listen and identify the occupation.', 'LEC09', 'CON04'),
('EJE103', 'Introducing Personal Information', 'Hello. My name is Lucas. I am eighteen years old. I am from Brazil.', 'LEC09', 'CON05'),
('EJE104', 'Talking About an Occupation', 'Hi. My name is Sophie. I am twenty years old. I am a teacher.', 'LEC09', 'CON05'),
('EJE105', 'Personal Information Vocabulary', 'Choose the word that refers to the name a person uses to identify themselves.', 'LEC10', 'CON02'),
('EJE106', 'Occupations Vocabulary', 'Choose the occupation of a person who teaches students at school.', 'LEC10', 'CON02'),
('EJE107', 'Nationality Vocabulary', 'Choose the nationality of a person from Japan.', 'LEC10', 'CON02'),
('EJE108', 'WH-Questions - Asking for a Surname', 'Choose the correct question to ask for the family name of a person.', 'LEC10', 'CON03'),
('EJE109', 'WH-Questions - Asking About Occupations', 'Choose the correct question to ask about someones job.', 'LEC10', 'CON03'),
('EJE11', 'Listening Introductions', 'Listen to the audio and select the option.', 'LEC01', 'CON04'),
('EJE110', 'Possessive Adjectives - My and Your', 'Complete the sentence: I am Emma. ___ nationality is Mexican.', 'LEC10', 'CON03'),
('EJE111', 'Possessive Adjectives - Her and His', 'Complete the sentence: Olivia is a doctor. ___ occupation is very important.', 'LEC10', 'CON03'),
('EJE112', 'Listening to Nationalities', 'Listen and choose the nationality you hear.', 'LEC10', 'CON04'),
('EJE113', 'Listening to Occupations', 'Listen and choose the occupation you hear.', 'LEC10', 'CON04'),
('EJE114', 'Listening to Personal Details', 'Listen and choose the correct personal information.', 'LEC10', 'CON04'),
('EJE115', 'Introducing Your Personal Details', 'Hello. My name is Noah. My last name is Wilson. I am nineteen years old.', 'LEC10', 'CON05'),
('EJE116', 'Talking About Your Family', 'This is my sister, Emily. She is twenty-two years old. She is a nurse. Her nationality is Canadian.', 'LEC10', 'CON05'),
('EJE117', 'Age Vocabulary', 'Choose the word that means the number of years a person has lived.', 'LEC11', 'CON02'),
('EJE118', 'Hospital Occupations Vocabulary', 'Choose the occupation of a person who cares for patients in a hospital.', 'LEC11', 'CON02'),
('EJE119', 'Nationalities Vocabulary', 'Choose the nationality of a person from Italy.', 'LEC11', 'CON02'),
('EJE12', 'Listening Expressions', 'Which phrase did you hear?', 'LEC01', 'CON04'),
('EJE120', 'WH-Questions - Asking About Age', 'Choose the correct question to ask about the age of a person.', 'LEC11', 'CON03'),
('EJE121', 'WH-Questions - Asking About Origin', 'Choose the correct question to ask about the country Carolina comes from.', 'LEC11', 'CON03'),
('EJE122', 'Possessive Adjectives - His', 'Complete the sentence: This is Ethan. ___ father is a doctor.', 'LEC11', 'CON03'),
('EJE123', 'Possessive Adjectives - Their', 'Complete the sentence: Lucas and Mia are from Brazil. ___ nationality is Brazilian.', 'LEC11', 'CON03'),
('EJE124', 'Listening to Age', 'Listen and choose how old Lucas is.', 'LEC11', 'CON04'),
('EJE125', 'Listening to Nationalities', 'Listen and choose the nationality you hear.', 'LEC11', 'CON04'),
('EJE126', 'Listening to Occupations', 'Listen and identify the occupation of the person.', 'LEC11', 'CON04'),
('EJE127', 'Introducing Yourself', 'Hi. My name is Leo. I am twenty years old. I am from Mexico. I am Mexican.', 'LEC11', 'CON05'),
('EJE128', 'Introducing Your Parents', 'These are my parents. Their names are Anna and David. My mother is a nurse, and my father is a teacher.', 'LEC11', 'CON05'),
('EJE129', 'Personal Information Vocabulary', 'Choose the expression that refers to the day, month and year a person was born.', 'LEC12', 'CON02'),
('EJE13', 'Speaking Greetings', 'Good morning', 'LEC01', 'CON05'),
('EJE130', 'Numbers and Age Vocabulary', 'Choose the correct expression for the number  twenty-five when talking about age.', 'LEC12', 'CON02'),
('EJE131', 'Occupations Vocabulary', 'Choose the occupation of a person who works in a hospital and takes care of patients.', 'LEC12', 'CON02'),
('EJE132', 'WH-Questions - Asking About Age', 'Choose the correct question to ask about a persons age.', 'LEC12', 'CON03'),
('EJE133', 'WH-Questions - Asking About Origin', 'Choose the correct question to ask where a person comes from.', 'LEC12', 'CON03'),
('EJE134', 'Possessive Adjectives - Our', 'Complete the sentence: We are students. ___ teacher is Mr. Brown.', 'LEC12', 'CON03'),
('EJE135', 'Possessive Adjectives - Their and His', 'Complete the sentence: Daniel and Joseph are brothers. ___ nationality is Mexican.', 'LEC12', 'CON03'),
('EJE136', 'Listening - Full Name', 'Listen and choose the correct full name.', 'LEC12', 'CON04'),
('EJE137', 'Listening - Age and Nationality', 'Listen and choose the correct age and nationality.', 'LEC12', 'CON04'),
('EJE138', 'Listening - Occupations', 'Listen and identify the occupation.', 'LEC12', 'CON04'),
('EJE139', 'Speaking - Introducing Yourself', 'Hello. My name is Lucas Anderson. I am twenty-one years old. I am Mexican.', 'LEC12', 'CON05'),
('EJE14', 'Speaking Farewells', 'See you later', 'LEC01', 'CON05'),
('EJE140', 'Speaking - Introducing Another Person', 'This is my friend, Sophia. She is twenty-three years old. She is Canadian. She is a teacher.', 'LEC12', 'CON05'),
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
('EJE48', 'Compare Two Animals', 'Say: A dolphin is a mammal, but a penguin is a bird.', 'LEC04', 'CON05'),
('EJE49', 'Personal Introductions', 'Choose the correct sentence to introduce yourself.', 'LEC05', 'CON03'),
('EJE50', 'Verb To Be: Am, Is, Are', 'Complete the sentence: She ___ my friend.', 'LEC05', 'CON03'),
('EJE51', 'Introducing Yourself', 'Choose the correct way to say your name.', 'LEC05', 'CON03'),
('EJE52', 'Greetings and Responses', 'Complete the conversation: Hello! I ___ fine, thank you.', 'LEC05', 'CON03'),
('EJE53', 'Basic Introductions', 'Choose the sentence with the correct word order.', 'LEC05', 'CON03'),
('EJE54', 'Common Greetings', 'Listen carefully and choose the greeting you hear.', 'LEC05', 'CON04'),
('EJE55', 'Personal Introductions', 'Listen to the introduction and choose the correct name.', 'LEC05', 'CON04'),
('EJE56', 'Everyday Expressions', 'Listen to the conversation and choose the correct response.', 'LEC05', 'CON04'),
('EJE57', 'Introducing Yourself', 'Hello, my name is Emily. I am a student.', 'LEC05', 'CON05'),
('EJE58', 'Greeting Someone', 'Good morning! How are you today?', 'LEC05', 'CON05'),
('EJE59', 'Meeting Someone', 'Choose the correct expression to greet someone you are meeting for the first time.', 'LEC06', 'CON02'),
('EJE60', 'Asking Personal Information', 'Choose the correct question to ask about someone\'s nationality or place of origin.', 'LEC06', 'CON02'),
('EJE61', 'Introducing Someone', 'Choose the correct expression to introduce another person.', 'LEC06', 'CON02'),
('EJE62', 'Negative Form: Am Not', 'Complete the sentence: I ___ from Canada.', 'LEC06', 'CON03'),
('EJE63', 'Negative Form: Is Not', 'Complete the sentence: She ___ my English teacher.', 'LEC06', 'CON03'),
('EJE64', 'Questions with Are', 'Choose the correct question to ask if someone is a student.', 'LEC06', 'CON03'),
('EJE65', 'Questions with Is', 'Complete the question: ___ he your new classmate?', 'LEC06', 'CON03'),
('EJE66', 'Personal Information', 'Listen to the conversation and choose where the person is from.', 'LEC06', 'CON04'),
('EJE67', 'Meeting a New Student', 'Listen carefully and choose the correct answer about the conversation.', 'LEC06', 'CON04'),
('EJE68', 'Asking About Someone', 'Listen to the question and choose the correct response.', 'LEC06', 'CON04'),
('EJE69', 'Asking a Question', 'Are you a student?', 'LEC06', 'CON05'),
('EJE70', 'Giving Personal Information', 'Hello, my name is Daniel. I am from Mexico.', 'LEC06', 'CON05'),
('EJE71', 'Greetings at Different Times', 'Choose the correct greeting for 9:00 AM.', 'LEC07', 'CON02'),
('EJE72', 'Responding to Greetings', 'Choose the best response to: How are you?', 'LEC07', 'CON02'),
('EJE73', 'Introducing Yourself', 'Choose the expression used to tell someone your name.', 'LEC07', 'CON02'),
('EJE74', 'Verb To Be - Affirmative', 'Complete the sentence with the correct form of the verb To Be: I ___ a new student.', 'LEC07', 'CON03'),
('EJE75', 'Verb To Be - Negative', 'Complete the negative sentence: She ___ my teacher.', 'LEC07', 'CON03'),
('EJE76', 'Verb To Be - Questions', 'Choose the correct question to ask someone if they are from Mexico.', 'LEC07', 'CON03'),
('EJE77', 'Verb To Be - Short Answers', 'Choose the correct short answer: Are they classmates?', 'LEC07', 'CON03'),
('EJE78', 'Listening to Greetings', 'Listen and choose the greeting you hear.', 'LEC07', 'CON04'),
('EJE79', 'Listening to Introductions', 'Listen and choose the correct introduction.', 'LEC07', 'CON04'),
('EJE80', 'Listening to Questions', 'Listen and choose the question you hear.', 'LEC07', 'CON04'),
('EJE81', 'Personal Introduction', 'Hello. My name is Emma. I am a student.', 'LEC07', 'CON05'),
('EJE82', 'Introducing Your Origin', 'Hi. I am Joseph. I am from Mexico.', 'LEC07', 'CON05'),
('EJE83', 'Polite Greetings', 'Choose the polite expression to greet your teacher in the morning.', 'LEC08', 'CON02'),
('EJE84', 'Asking for a Name', 'Choose the correct expression to ask someone their name.', 'LEC08', 'CON02'),
('EJE85', 'Saying Goodbye', 'Choose the expression you use when you leave someone and expect to see them again soon.', 'LEC08', 'CON02'),
('EJE86', 'Verb To Be - Personal Information', 'Complete the sentence: My name ___ Sophia.', 'LEC08', 'CON03'),
('EJE87', 'Verb To Be - Negative Statements', 'Complete the sentence: We ___ from Canada. We are from Mexico.', 'LEC08', 'CON03'),
('EJE88', 'Verb To Be - Yes or No Questions', 'Choose the correct question to ask if Ariana is a teacher.', 'LEC08', 'CON03'),
('EJE89', 'Verb To Be - Short Answers', 'Choose the correct short answer: Is he your friend?', 'LEC08', 'CON03'),
('EJE90', 'Listening to Personal Information', 'Listen and choose the sentence you hear.', 'LEC08', 'CON04'),
('EJE91', 'Listening to Nationalities and Origins', 'Listen and identify where the person is from.', 'LEC08', 'CON04'),
('EJE92', 'Listening to Introductions', 'Listen and choose the correct introduction.', 'LEC08', 'CON04'),
('EJE93', 'Introducing Yourself', 'Hello. My name is Mia. I am from Australia. Nice to meet you.', 'LEC08', 'CON05'),
('EJE94', 'Talking About a Friend', 'This is my friend, Ethan. He is a student. He is from the United States.', 'LEC08', 'CON05'),
('EJE95', 'Asking for Personal Information', 'Choose the correct question to ask someone for their name.', 'LEC09', 'CON03'),
('EJE96', 'Asking About Nationality', 'Choose the correct question to ask where someone comes from.', 'LEC09', 'CON03'),
('EJE97', 'Asking About Age', 'Choose the correct question to ask about the age of a person.', 'LEC09', 'CON03'),
('EJE98', 'Possessive Adjectives - His and Her', 'Complete the sentence: Daniel is a student. ___ teacher is Mr. Brown.', 'LEC09', 'CON03'),
('EJE99', 'Possessive Adjectives - Their', 'Complete the sentence: Emma and Lucas are students. ___ school is in London.', 'LEC09', 'CON03');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ejercicio_opcion`
--

CREATE TABLE `ejercicio_opcion` (
  `ejercicio` varchar(8) NOT NULL,
  `opcion` varchar(8) NOT NULL
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
('EJE49', 'OP161'),
('EJE49', 'OP162'),
('EJE49', 'OP163'),
('EJE49', 'OP164'),
('EJE50', 'OP165'),
('EJE50', 'OP166'),
('EJE50', 'OP167'),
('EJE50', 'OP168'),
('EJE51', 'OP169'),
('EJE51', 'OP170'),
('EJE51', 'OP171'),
('EJE51', 'OP172'),
('EJE52', 'OP173'),
('EJE52', 'OP174'),
('EJE52', 'OP175'),
('EJE52', 'OP176'),
('EJE53', 'OP177'),
('EJE53', 'OP178'),
('EJE53', 'OP179'),
('EJE53', 'OP180'),
('EJE54', 'OP181'),
('EJE54', 'OP182'),
('EJE54', 'OP183'),
('EJE54', 'OP184'),
('EJE55', 'OP185'),
('EJE55', 'OP186'),
('EJE55', 'OP187'),
('EJE55', 'OP188'),
('EJE56', 'OP189'),
('EJE56', 'OP190'),
('EJE56', 'OP191'),
('EJE56', 'OP192'),
('EJE59', 'OP193'),
('EJE59', 'OP194'),
('EJE59', 'OP195'),
('EJE59', 'OP196'),
('EJE60', 'OP197'),
('EJE60', 'OP198'),
('EJE60', 'OP199'),
('EJE60', 'OP200'),
('EJE61', 'OP201'),
('EJE61', 'OP202'),
('EJE61', 'OP203'),
('EJE61', 'OP204'),
('EJE62', 'OP205'),
('EJE62', 'OP206'),
('EJE62', 'OP207'),
('EJE62', 'OP208'),
('EJE63', 'OP209'),
('EJE63', 'OP210'),
('EJE63', 'OP211'),
('EJE63', 'OP212'),
('EJE64', 'OP213'),
('EJE64', 'OP214'),
('EJE64', 'OP215'),
('EJE64', 'OP216'),
('EJE65', 'OP217'),
('EJE65', 'OP218'),
('EJE65', 'OP219'),
('EJE65', 'OP220'),
('EJE66', 'OP221'),
('EJE66', 'OP222'),
('EJE66', 'OP223'),
('EJE66', 'OP224'),
('EJE67', 'OP225'),
('EJE67', 'OP226'),
('EJE67', 'OP227'),
('EJE67', 'OP228'),
('EJE68', 'OP229'),
('EJE68', 'OP230'),
('EJE68', 'OP231'),
('EJE68', 'OP232'),
('EJE71', 'OP233'),
('EJE71', 'OP234'),
('EJE71', 'OP235'),
('EJE71', 'OP236'),
('EJE72', 'OP237'),
('EJE72', 'OP238'),
('EJE72', 'OP239'),
('EJE72', 'OP240'),
('EJE73', 'OP241'),
('EJE73', 'OP242'),
('EJE73', 'OP243'),
('EJE73', 'OP244'),
('EJE74', 'OP245'),
('EJE74', 'OP246'),
('EJE74', 'OP247'),
('EJE74', 'OP248'),
('EJE75', 'OP249'),
('EJE75', 'OP250'),
('EJE75', 'OP251'),
('EJE75', 'OP252'),
('EJE76', 'OP253'),
('EJE76', 'OP254'),
('EJE76', 'OP255'),
('EJE76', 'OP256'),
('EJE77', 'OP257'),
('EJE77', 'OP258'),
('EJE77', 'OP259'),
('EJE77', 'OP260'),
('EJE78', 'OP261'),
('EJE78', 'OP262'),
('EJE78', 'OP263'),
('EJE78', 'OP264'),
('EJE79', 'OP265'),
('EJE79', 'OP266'),
('EJE79', 'OP267'),
('EJE79', 'OP268'),
('EJE80', 'OP269'),
('EJE80', 'OP270'),
('EJE80', 'OP271'),
('EJE80', 'OP272'),
('EJE83', 'OP273'),
('EJE83', 'OP274'),
('EJE83', 'OP275'),
('EJE83', 'OP276'),
('EJE84', 'OP277'),
('EJE84', 'OP278'),
('EJE84', 'OP279'),
('EJE84', 'OP280'),
('EJE85', 'OP281'),
('EJE85', 'OP282'),
('EJE85', 'OP283'),
('EJE85', 'OP284'),
('EJE86', 'OP285'),
('EJE86', 'OP286'),
('EJE86', 'OP287'),
('EJE86', 'OP288'),
('EJE87', 'OP289'),
('EJE87', 'OP290'),
('EJE87', 'OP291'),
('EJE87', 'OP292'),
('EJE88', 'OP293'),
('EJE88', 'OP294'),
('EJE88', 'OP295'),
('EJE88', 'OP296'),
('EJE89', 'OP297'),
('EJE89', 'OP298'),
('EJE89', 'OP299'),
('EJE89', 'OP300'),
('EJE90', 'OP301'),
('EJE90', 'OP302'),
('EJE90', 'OP303'),
('EJE90', 'OP304'),
('EJE91', 'OP305'),
('EJE91', 'OP306'),
('EJE91', 'OP307'),
('EJE91', 'OP308'),
('EJE92', 'OP309'),
('EJE92', 'OP310'),
('EJE92', 'OP311'),
('EJE92', 'OP312'),
('EJE95', 'OP313'),
('EJE95', 'OP314'),
('EJE95', 'OP315'),
('EJE95', 'OP316'),
('EJE96', 'OP317'),
('EJE96', 'OP318'),
('EJE96', 'OP319'),
('EJE96', 'OP320'),
('EJE97', 'OP321'),
('EJE97', 'OP322'),
('EJE97', 'OP323'),
('EJE97', 'OP324'),
('EJE98', 'OP325'),
('EJE98', 'OP326'),
('EJE98', 'OP327'),
('EJE98', 'OP328'),
('EJE99', 'OP329'),
('EJE99', 'OP330'),
('EJE99', 'OP331'),
('EJE99', 'OP332'),
('EJE100', 'OP333'),
('EJE100', 'OP334'),
('EJE100', 'OP335'),
('EJE100', 'OP336'),
('EJE101', 'OP337'),
('EJE101', 'OP338'),
('EJE101', 'OP339'),
('EJE101', 'OP340'),
('EJE102', 'OP341'),
('EJE102', 'OP342'),
('EJE102', 'OP343'),
('EJE102', 'OP344'),
('EJE105', 'OP345'),
('EJE105', 'OP346'),
('EJE105', 'OP347'),
('EJE105', 'OP348'),
('EJE106', 'OP349'),
('EJE106', 'OP350'),
('EJE106', 'OP351'),
('EJE106', 'OP352'),
('EJE107', 'OP353'),
('EJE107', 'OP354'),
('EJE107', 'OP355'),
('EJE107', 'OP356'),
('EJE108', 'OP357'),
('EJE108', 'OP358'),
('EJE108', 'OP359'),
('EJE108', 'OP360'),
('EJE109', 'OP361'),
('EJE109', 'OP362'),
('EJE109', 'OP363'),
('EJE109', 'OP364'),
('EJE110', 'OP365'),
('EJE110', 'OP366'),
('EJE110', 'OP367'),
('EJE110', 'OP368'),
('EJE111', 'OP369'),
('EJE111', 'OP370'),
('EJE111', 'OP371'),
('EJE111', 'OP372'),
('EJE112', 'OP373'),
('EJE112', 'OP374'),
('EJE112', 'OP375'),
('EJE112', 'OP376'),
('EJE113', 'OP377'),
('EJE113', 'OP378'),
('EJE113', 'OP379'),
('EJE113', 'OP380'),
('EJE114', 'OP381'),
('EJE114', 'OP382'),
('EJE114', 'OP383'),
('EJE114', 'OP384'),
('EJE117', 'OP385'),
('EJE117', 'OP386'),
('EJE117', 'OP387'),
('EJE117', 'OP388'),
('EJE118', 'OP389'),
('EJE118', 'OP390'),
('EJE118', 'OP391'),
('EJE118', 'OP392'),
('EJE119', 'OP393'),
('EJE119', 'OP394'),
('EJE119', 'OP395'),
('EJE119', 'OP396'),
('EJE120', 'OP397'),
('EJE120', 'OP398'),
('EJE120', 'OP399'),
('EJE120', 'OP400'),
('EJE121', 'OP401'),
('EJE121', 'OP402'),
('EJE121', 'OP403'),
('EJE121', 'OP404'),
('EJE122', 'OP405'),
('EJE122', 'OP406'),
('EJE122', 'OP407'),
('EJE122', 'OP408'),
('EJE123', 'OP409'),
('EJE123', 'OP410'),
('EJE123', 'OP411'),
('EJE123', 'OP412'),
('EJE124', 'OP413'),
('EJE124', 'OP414'),
('EJE124', 'OP415'),
('EJE124', 'OP416'),
('EJE125', 'OP417'),
('EJE125', 'OP418'),
('EJE125', 'OP419'),
('EJE125', 'OP420'),
('EJE126', 'OP421'),
('EJE126', 'OP422'),
('EJE126', 'OP423'),
('EJE126', 'OP424'),
('EJE129', 'OP425'),
('EJE129', 'OP426'),
('EJE129', 'OP427'),
('EJE129', 'OP428'),
('EJE130', 'OP429'),
('EJE130', 'OP430'),
('EJE130', 'OP431'),
('EJE130', 'OP432'),
('EJE131', 'OP433'),
('EJE131', 'OP434'),
('EJE131', 'OP435'),
('EJE131', 'OP436'),
('EJE132', 'OP437'),
('EJE132', 'OP438'),
('EJE132', 'OP439'),
('EJE132', 'OP440'),
('EJE133', 'OP441'),
('EJE133', 'OP442'),
('EJE133', 'OP443'),
('EJE133', 'OP444'),
('EJE134', 'OP445'),
('EJE134', 'OP446'),
('EJE134', 'OP447'),
('EJE134', 'OP448'),
('EJE135', 'OP449'),
('EJE135', 'OP450'),
('EJE135', 'OP451'),
('EJE135', 'OP452'),
('EJE136', 'OP453'),
('EJE136', 'OP454'),
('EJE136', 'OP455'),
('EJE136', 'OP456'),
('EJE137', 'OP457'),
('EJE137', 'OP458'),
('EJE137', 'OP459'),
('EJE137', 'OP460'),
('EJE138', 'OP461'),
('EJE138', 'OP462'),
('EJE138', 'OP463'),
('EJE138', 'OP464'),
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
(5, '2026100002', 'COMPETITION_RESULT', 'Results Available: Nature Spelling Challenge', 'Your results for Nature Spelling Challenge are available. Correct: 10, Incorrect: 0, Points: 100.', '2026-10-19 16:16:57', 1, 'COM11', NULL),
(6, '2026100012', 'COMPETITION_RESULT', 'Results Available: Tech Spelling Bee', 'Your results for Tech Spelling Bee are available. Correct: 10, Incorrect: 0, Points: 100.', '2026-10-19 16:37:35', 1, 'COM12', NULL),
(7, '2026100011', 'COMPETITION_RESULT', 'Results Available: Tech Spelling Bee', 'Your results for Tech Spelling Bee are available. Correct: 10, Incorrect: 0, Points: 100.', '2026-10-19 16:37:46', 1, 'COM12', NULL),
(8, '2026100011', 'ACHIEVEMENT', 'New Achievement: XP Collector', '(\'You earned the XP Collector\', \'Accumulate 100 experience points\')', '2026-11-09 03:00:05', 1, NULL, 'INS14'),
(9, '2026100007', 'COMPETITION_RESULT', 'Results Available: Nature Spelling Challenge', 'Your results for Nature Spelling Challenge are available. Correct: 9, Incorrect: 1, Points: 90.', '2026-11-13 18:32:12', 0, 'COM11', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `opcion`
--

CREATE TABLE `opcion` (
  `clave` varchar(8) NOT NULL,
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
('OP161', 'I am Omar.', 'Correct! Use \"I am\" to introduce yourself.', 'EST01'),
('OP162', 'I is Omar.', 'Incorrect. Use \"am\" with \"I\".', 'EST02'),
('OP163', 'I are Omar.', 'Incorrect. Use \"am\" with \"I\".', 'EST02'),
('OP164', 'I be Omar.', 'Incorrect. The correct form is \"I am\".', 'EST02'),
('OP165', 'am', 'Incorrect. Use \"is\" with \"she\".', 'EST02'),
('OP166', 'are', 'Incorrect. Use \"is\" with \"she\".', 'EST02'),
('OP167', 'is', 'Correct! Use \"is\" with \"she\".', 'EST01'),
('OP168', 'be', 'Incorrect. The correct form is \"is\".', 'EST02'),
('OP169', 'My name are Daniel.', 'Incorrect. Use \"is\" after \"My name\".', 'EST02'),
('OP170', 'My name is Daniel.', 'Correct! Use \"My name is\" to introduce your name.', 'EST01'),
('OP171', 'My name am Daniel.', 'Incorrect. Use \"is\" after \"My name\".', 'EST02'),
('OP172', 'My names be Daniel.', 'Incorrect. The correct expression is \"My name is\".', 'EST02'),
('OP173', 'are', 'Incorrect. Remember: \"I am\".', 'EST02'),
('OP174', 'be', 'Incorrect. The correct form is \"am\".', 'EST02'),
('OP175', 'am', 'Correct! Use \"am\" with \"I\".', 'EST01'),
('OP176', 'is', 'Incorrect. Remember: \"I am\".', 'EST02'),
('OP177', 'Are they students.', 'Incorrect. Use \"They are students\" for this affirmative sentence.', 'EST02'),
('OP178', 'They students are.', 'Incorrect. Use subject + verb + complement.', 'EST02'),
('OP179', 'They is students.', 'Incorrect. Use \"are\" with \"they\".', 'EST02'),
('OP180', 'They are students.', 'Correct! The order is subject + verb + complement.', 'EST01'),
('OP181', 'Good evening! How are you today?', 'Incorrect. Listen again and identify the greeting.', 'EST02'),
('OP182', 'Good morning! How are you today?', 'Correct! The speaker says \"Good morning\".', 'EST01'),
('OP183', 'Good night! See you tomorrow!', 'Incorrect. Listen again and identify the greeting.', 'EST02'),
('OP184', 'Goodbye! Have a nice day!', 'Incorrect. Listen again and identify the greeting.', 'EST02'),
('OP185', 'Emma', 'Incorrect. Listen again to identify the speaker\'s name.', 'EST02'),
('OP186', 'Olivia', 'Incorrect. Listen again to identify the speaker\'s name.', 'EST02'),
('OP187', 'Emily', 'Correct! The speaker introduces herself as Emily.', 'EST01'),
('OP188', 'Sophia', 'Incorrect. Listen again to identify the speaker\'s name.', 'EST02'),
('OP189', 'I am great, thank you!', 'Correct! This is an appropriate response.', 'EST01'),
('OP190', 'My name is great.', 'Incorrect. Listen again and identify the response.', 'EST02'),
('OP191', 'Good night, goodbye.', 'Incorrect. Listen again and identify the response.', 'EST02'),
('OP192', 'I are a student.', 'Incorrect. Listen again and identify the response.', 'EST02'),
('OP193', 'Good night!', 'Incorrect. Good night is generally used when saying goodbye before sleeping.', 'EST02'),
('OP194', 'Nice to meet you!', 'Correct. This expression is used when meeting someone for the first time.', 'EST01'),
('OP195', 'See you tomorrow!', 'Incorrect. This expression is used when saying goodbye to someone you expect to see the next day.', 'EST02'),
('OP196', 'Goodbye!', 'Incorrect. Goodbye is used to end a conversation, not specifically to meet someone for the first time.', 'EST02'),
('OP197', 'How old are you?', 'Incorrect. This question asks about someone\'s age.', 'EST02'),
('OP198', 'What is your name?', 'Incorrect. This question asks for someone\'s name.', 'EST02'),
('OP199', 'Where are you from?', 'Correct. This question asks about someone\'s place of origin.', 'EST01'),
('OP200', 'How are you?', 'Incorrect. This question asks about someone\'s condition or feelings.', 'EST02'),
('OP201', 'This is my friend Daniel.', 'Correct. This expression is used to introduce another person.', 'EST01'),
('OP202', 'I am fine, thank you.', 'Incorrect. This expression is used to respond when someone asks how you are.', 'EST02'),
('OP203', 'Good night, everyone.', 'Incorrect. This expression is used to say goodbye at night.', 'EST02'),
('OP204', 'My name is Daniel.', 'Incorrect. This expression introduces yourself, not another person.', 'EST02'),
('OP205', 'is not', 'Incorrect. Is not is used with he, she, and it.', 'EST02'),
('OP206', 'are not', 'Incorrect. Are not is used with you, we, and they.', 'EST02'),
('OP207', 'am not', 'Correct. Am not is the negative form of the verb to be used with I.', 'EST01'),
('OP208', 'be not', 'Incorrect. Be not is not the standard negative form used in this sentence.', 'EST02'),
('OP209', 'am not', 'Incorrect. Am not is used with the subject I.', 'EST02'),
('OP210', 'is not', 'Correct. Is not is the negative form of the verb to be used with she.', 'EST01'),
('OP211', 'are not', 'Incorrect. Are not is used with you, we, and they.', 'EST02'),
('OP212', 'not is', 'Incorrect. The negative form places not after the verb is.', 'EST02'),
('OP213', 'You are a student?', 'Incorrect. In standard yes-or-no questions, the verb are comes before the subject you.', 'EST02'),
('OP214', 'Are you a student?', 'Correct. Questions with you use are before the subject.', 'EST01'),
('OP215', 'Is you a student?', 'Incorrect. Is is not used with the subject you.', 'EST02'),
('OP216', 'Am you a student?', 'Incorrect. Am is used with the subject I.', 'EST02'),
('OP217', 'Am', 'Incorrect. Am is used with the subject I.', 'EST02'),
('OP218', 'Are', 'Incorrect. Are is used with you, we, and they.', 'EST02'),
('OP219', 'Is', 'Correct. Is is used with he, she, and it.', 'EST01'),
('OP220', 'Be', 'Incorrect. Be is not the correct conjugated form for this question.', 'EST02'),
('OP221', 'Canada', 'Incorrect. The conversation does not mention Canada as the person\'s place of origin.', 'EST02'),
('OP222', 'Mexico', 'Correct. The person says: I am from Mexico.', 'EST01'),
('OP223', 'The United States', 'Incorrect. The person says they are not from the United States.', 'EST02'),
('OP224', 'England', 'Incorrect. England is not mentioned in the conversation.', 'EST02'),
('OP225', 'Daniel is his brother.', 'Incorrect. The speaker says Daniel is not his brother.', 'EST02'),
('OP226', 'Daniel is his teacher.', 'Incorrect. The conversation does not identify Daniel as a teacher.', 'EST02'),
('OP227', 'Daniel is his friend.', 'Correct. The speaker says: He is my friend.', 'EST01'),
('OP228', 'Daniel is his classmate.', 'Incorrect. The speaker identifies Daniel as a friend, not specifically as a classmate.', 'EST02'),
('OP229', 'No, I am not.', 'Incorrect. The speaker confirms that they are a new student.', 'EST02'),
('OP230', 'Yes, I am.', 'Correct. This response confirms that the speaker is a new student.', 'EST01'),
('OP231', 'No, she is not.', 'Incorrect. This response uses she and does not answer the question correctly.', 'EST02'),
('OP232', 'Yes, he is.', 'Incorrect. This response uses he instead of the subject I.', 'EST02'),
('OP233', 'Good morning!', 'Correct answer.', 'EST01'),
('OP234', 'Good evening!', 'Incorrect answer.', 'EST02'),
('OP235', 'Good night!', 'Incorrect answer.', 'EST02'),
('OP236', 'Goodbye!', 'Incorrect answer.', 'EST02'),
('OP237', 'I am fine, thank you.', 'Correct answer.', 'EST01'),
('OP238', 'My name is Anna.', 'Incorrect answer.', 'EST02'),
('OP239', 'I am from Mexico.', 'Incorrect answer.', 'EST02'),
('OP240', 'Goodbye, teacher.', 'Incorrect answer.', 'EST02'),
('OP241', 'My name is Anna.', 'Correct answer.', 'EST01'),
('OP242', 'How old are you?', 'Incorrect answer.', 'EST02'),
('OP243', 'See you tomorrow.', 'Incorrect answer.', 'EST02'),
('OP244', 'Good afternoon.', 'Incorrect answer.', 'EST02'),
('OP245', 'am', 'Correct answer.', 'EST01'),
('OP246', 'is', 'Incorrect answer.', 'EST02'),
('OP247', 'are', 'Incorrect answer.', 'EST02'),
('OP248', 'be', 'Incorrect answer.', 'EST02'),
('OP249', 'is not', 'Correct answer.', 'EST01'),
('OP250', 'am not', 'Incorrect answer.', 'EST02'),
('OP251', 'are not', 'Incorrect answer.', 'EST02'),
('OP252', 'not is', 'Incorrect answer.', 'EST02'),
('OP253', 'Are you from Mexico?', 'Correct answer.', 'EST01'),
('OP254', 'You are from Mexico?', 'Incorrect answer.', 'EST02'),
('OP255', 'Is you from Mexico?', 'Incorrect answer.', 'EST02'),
('OP256', 'Am you from Mexico?', 'Incorrect answer.', 'EST02'),
('OP257', 'Yes, they are.', 'Correct answer.', 'EST01'),
('OP258', 'Yes, they is.', 'Incorrect answer.', 'EST02'),
('OP259', 'Yes, I am.', 'Incorrect answer.', 'EST02'),
('OP260', 'Yes, they do.', 'Incorrect answer.', 'EST02'),
('OP261', 'Good morning, Anna.', 'Correct answer.', 'EST01'),
('OP262', 'Good night, Anna.', 'Incorrect answer.', 'EST02'),
('OP263', 'Goodbye, Anna.', 'Incorrect answer.', 'EST02'),
('OP264', 'See you later, Anna.', 'Incorrect answer.', 'EST02'),
('OP265', 'Hello, I am Leo.', 'Correct answer.', 'EST01'),
('OP266', 'Goodbye, I am Leo.', 'Incorrect answer.', 'EST02'),
('OP267', 'How are you, Leo?', 'Incorrect answer.', 'EST02'),
('OP268', 'See you tomorrow, Leo.', 'Incorrect answer.', 'EST02'),
('OP269', 'Are you a student?', 'Correct answer.', 'EST01'),
('OP270', 'You are a student.', 'Incorrect answer.', 'EST02'),
('OP271', 'She is a student.', 'Incorrect answer.', 'EST02'),
('OP272', 'They are students.', 'Incorrect answer.', 'EST02'),
('OP273', 'Good morning, teacher.', 'Correct answer.', 'EST01'),
('OP274', 'Good night, teacher.', 'Incorrect answer.', 'EST02'),
('OP275', 'See you tomorrow, teacher.', 'Incorrect answer.', 'EST02'),
('OP276', 'Goodbye, teacher.', 'Incorrect answer.', 'EST02'),
('OP277', 'What is your name?', 'Correct answer.', 'EST01'),
('OP278', 'Where are you from?', 'Incorrect answer.', 'EST02'),
('OP279', 'How are you today?', 'Incorrect answer.', 'EST02'),
('OP280', 'How old are you?', 'Incorrect answer.', 'EST02'),
('OP281', 'See you later!', 'Correct answer.', 'EST01'),
('OP282', 'Nice to meet you!', 'Incorrect answer.', 'EST02'),
('OP283', 'Good morning!', 'Incorrect answer.', 'EST02'),
('OP284', 'How do you spell it?', 'Incorrect answer.', 'EST02'),
('OP285', 'is', 'Correct answer.', 'EST01'),
('OP286', 'am', 'Incorrect answer.', 'EST02'),
('OP287', 'are', 'Incorrect answer.', 'EST02'),
('OP288', 'be', 'Incorrect answer.', 'EST02'),
('OP289', 'are not', 'Correct answer.', 'EST01'),
('OP290', 'is not', 'Incorrect answer.', 'EST02'),
('OP291', 'am not', 'Incorrect answer.', 'EST02'),
('OP292', 'not are', 'Incorrect answer.', 'EST02'),
('OP293', 'Is Ariana a teacher?', 'Correct answer.', 'EST01'),
('OP294', 'Are Ariana a teacher?', 'Incorrect answer.', 'EST02'),
('OP295', 'Am Ariana a teacher?', 'Incorrect answer.', 'EST02'),
('OP296', 'Ariana is a teacher?', 'Incorrect answer.', 'EST02'),
('OP297', 'No, he is not.', 'Correct answer.', 'EST01'),
('OP298', 'No, he are not.', 'Incorrect answer.', 'EST02'),
('OP299', 'No, he am not.', 'Incorrect answer.', 'EST02'),
('OP300', 'No, he do not.', 'Incorrect answer.', 'EST02'),
('OP301', 'I am twenty years old.', 'Correct answer.', 'EST01'),
('OP302', 'I am twenty years young.', 'Incorrect answer.', 'EST02'),
('OP303', 'I is twenty years old.', 'Incorrect answer.', 'EST02'),
('OP304', 'I are twenty years old.', 'Incorrect answer.', 'EST02'),
('OP305', 'She is from Japan.', 'Correct answer.', 'EST01'),
('OP306', 'She is from Brazil.', 'Incorrect answer.', 'EST02'),
('OP307', 'She is from Canada.', 'Incorrect answer.', 'EST02'),
('OP308', 'She is from Mexico.', 'Incorrect answer.', 'EST02'),
('OP309', 'Hi, my name is Oliver. Nice to meet you.', 'Correct answer.', 'EST01'),
('OP310', 'Goodbye, my name is Oliver. See you later.', 'Incorrect answer.', 'EST02'),
('OP311', 'Good night, my name is Oliver. How are you?', 'Incorrect answer.', 'EST02'),
('OP312', 'See you tomorrow, Oliver. Good morning.', 'Incorrect answer.', 'EST02'),
('OP313', 'What is your name?', 'Correct answer.', 'EST01'),
('OP314', 'Where is your name?', 'Incorrect answer.', 'EST02'),
('OP315', 'How old is your name?', 'Incorrect answer.', 'EST02'),
('OP316', 'Who are your name?', 'Incorrect answer.', 'EST02'),
('OP317', 'Where are you from?', 'Correct answer.', 'EST01'),
('OP318', 'What are you from?', 'Incorrect answer.', 'EST02'),
('OP319', 'Who are you from?', 'Incorrect answer.', 'EST02'),
('OP320', 'When are you from?', 'Incorrect answer.', 'EST02'),
('OP321', 'How old are you?', 'Correct answer.', 'EST01'),
('OP322', 'How many are you?', 'Incorrect answer.', 'EST02'),
('OP323', 'What old are you?', 'Incorrect answer.', 'EST02'),
('OP324', 'Where old are you?', 'Incorrect answer.', 'EST02'),
('OP325', 'His', 'Correct answer.', 'EST01'),
('OP326', 'Her', 'Incorrect answer.', 'EST02'),
('OP327', 'My', 'Incorrect answer.', 'EST02'),
('OP328', 'Our', 'Incorrect answer.', 'EST02'),
('OP329', 'Their', 'Correct answer.', 'EST01'),
('OP330', 'His', 'Incorrect answer.', 'EST02'),
('OP331', 'Her', 'Incorrect answer.', 'EST02'),
('OP332', 'My', 'Incorrect answer.', 'EST02'),
('OP333', 'My name is Olivia.', 'Correct answer.', 'EST01'),
('OP334', 'My name is Amelia.', 'Incorrect answer.', 'EST02'),
('OP335', 'My name is Sophia.', 'Incorrect answer.', 'EST02'),
('OP336', 'My name is Isabella.', 'Incorrect answer.', 'EST02'),
('OP337', 'I am eighteen years old.', 'Correct answer.', 'EST01'),
('OP338', 'I am sixteen years old.', 'Incorrect answer.', 'EST02'),
('OP339', 'I am nineteen years old.', 'Incorrect answer.', 'EST02'),
('OP340', 'I am twenty years old.', 'Incorrect answer.', 'EST02'),
('OP341', 'She is a doctor.', 'Correct answer.', 'EST01'),
('OP342', 'She is a teacher.', 'Incorrect answer.', 'EST02'),
('OP343', 'She is a nurse.', 'Incorrect answer.', 'EST02'),
('OP344', 'She is a student.', 'Incorrect answer.', 'EST02'),
('OP345', 'First name', 'Correct answer.', 'EST01'),
('OP346', 'Age', 'Incorrect answer.', 'EST02'),
('OP347', 'Occupation', 'Incorrect answer.', 'EST02'),
('OP348', 'Nationality', 'Incorrect answer.', 'EST02'),
('OP349', 'Teacher', 'Correct answer.', 'EST01'),
('OP350', 'Doctor', 'Incorrect answer.', 'EST02'),
('OP351', 'Nurse', 'Incorrect answer.', 'EST02'),
('OP352', 'Driver', 'Incorrect answer.', 'EST02'),
('OP353', 'Japanese', 'Correct answer.', 'EST01'),
('OP354', 'Brazilian', 'Incorrect answer.', 'EST02'),
('OP355', 'Mexican', 'Incorrect answer.', 'EST02'),
('OP356', 'Canadian', 'Incorrect answer.', 'EST02'),
('OP357', 'What is your last name?', 'Correct answer.', 'EST01'),
('OP358', 'Where is your last name?', 'Incorrect answer.', 'EST02'),
('OP359', 'How old is your last name?', 'Incorrect answer.', 'EST02'),
('OP360', 'Who is your last name?', 'Incorrect answer.', 'EST02'),
('OP361', 'What is your job?', 'Correct answer.', 'EST01'),
('OP362', 'Where is your job?', 'Incorrect answer.', 'EST02'),
('OP363', 'When is your job?', 'Incorrect answer.', 'EST02'),
('OP364', 'Who is your job?', 'Incorrect answer.', 'EST02'),
('OP365', 'My', 'Correct answer.', 'EST01'),
('OP366', 'Your', 'Incorrect answer.', 'EST02'),
('OP367', 'His', 'Incorrect answer.', 'EST02'),
('OP368', 'Their', 'Incorrect answer.', 'EST02'),
('OP369', 'Her', 'Correct answer.', 'EST01'),
('OP370', 'His', 'Incorrect answer.', 'EST02'),
('OP371', 'Our', 'Incorrect answer.', 'EST02'),
('OP372', 'Your', 'Incorrect answer.', 'EST02'),
('OP373', 'I am Mexican.', 'Correct answer.', 'EST01'),
('OP374', 'I am Japanese.', 'Incorrect answer.', 'EST02'),
('OP375', 'I am Canadian.', 'Incorrect answer.', 'EST02'),
('OP376', 'I am Brazilian.', 'Incorrect answer.', 'EST02'),
('OP377', 'He is a doctor.', 'Correct answer.', 'EST01'),
('OP378', 'He is a teacher.', 'Incorrect answer.', 'EST02'),
('OP379', 'He is a driver.', 'Incorrect answer.', 'EST02'),
('OP380', 'He is a student.', 'Incorrect answer.', 'EST02'),
('OP381', 'Her name is Isabella.', 'Correct answer.', 'EST01'),
('OP382', 'Her name is Victoria.', 'Incorrect answer.', 'EST02'),
('OP383', 'Her name is Gabriella.', 'Incorrect answer.', 'EST02'),
('OP384', 'Her name is Charlotte.', 'Incorrect answer.', 'EST02'),
('OP385', 'Age', 'Correct answer.', 'EST01'),
('OP386', 'Name', 'Incorrect answer.', 'EST02'),
('OP387', 'Country', 'Incorrect answer.', 'EST02'),
('OP388', 'Occupation', 'Incorrect answer.', 'EST02'),
('OP389', 'Nurse', 'Correct answer.', 'EST01'),
('OP390', 'Pilot', 'Incorrect answer.', 'EST02'),
('OP391', 'Teacher', 'Incorrect answer.', 'EST02'),
('OP392', 'Farmer', 'Incorrect answer.', 'EST02'),
('OP393', 'Italian', 'Correct answer.', 'EST01'),
('OP394', 'French', 'Incorrect answer.', 'EST02'),
('OP395', 'Mexican', 'Incorrect answer.', 'EST02'),
('OP396', 'Japanese', 'Incorrect answer.', 'EST02'),
('OP397', 'How old are you?', 'Correct answer.', 'EST01'),
('OP398', 'Where are you?', 'Incorrect answer.', 'EST02'),
('OP399', 'Who are you?', 'Incorrect answer.', 'EST02'),
('OP400', 'What are you?', 'Incorrect answer.', 'EST02'),
('OP401', 'Where is Carolina from?', 'Correct answer.', 'EST01'),
('OP402', 'How old is Carolina?', 'Incorrect answer.', 'EST02'),
('OP403', 'Why is Carolina?', 'Incorrect answer.', 'EST02'),
('OP404', 'Who is Carolina', 'Incorrect answer.', 'EST02'),
('OP405', 'His', 'Correct answer.', 'EST01'),
('OP406', 'Her', 'Incorrect answer.', 'EST02'),
('OP407', 'Their', 'Incorrect answer.', 'EST02'),
('OP408', 'Our', 'Incorrect answer.', 'EST02'),
('OP409', 'Their', 'Correct answer.', 'EST01'),
('OP410', 'His', 'Incorrect answer.', 'EST02'),
('OP411', 'Her', 'Incorrect answer.', 'EST02'),
('OP412', 'My', 'Incorrect answer.', 'EST02'),
('OP413', 'He is eighteen years old.', 'Correct answer.', 'EST01'),
('OP414', 'He is sixteen years old.', 'Incorrect answer.', 'EST02'),
('OP415', 'He is twenty years old.', 'Incorrect answer.', 'EST02'),
('OP416', 'He is twenty-five years old.', 'Incorrect answer.', 'EST02'),
('OP417', 'She is Italian.', 'Correct answer.', 'EST01'),
('OP418', 'She is French.', 'Incorrect answer.', 'EST02'),
('OP419', 'She is Mexican.', 'Incorrect answer.', 'EST02'),
('OP420', 'She is Japanese.', 'Incorrect answer.', 'EST02'),
('OP421', 'He is a pilot.', 'Correct answer.', 'EST01'),
('OP422', 'He is a farmer.', 'Incorrect answer.', 'EST02'),
('OP423', 'He is a nurse.', 'Incorrect answer.', 'EST02'),
('OP424', 'He is a teacher.', 'Incorrect answer.', 'EST02'),
('OP425', 'Date of birth', 'Correct answer.', 'EST01'),
('OP426', 'Nationality', 'Incorrect answer.', 'EST02'),
('OP427', 'Occupation', 'Incorrect answer.', 'EST02'),
('OP428', 'Last name', 'Incorrect answer.', 'EST02'),
('OP429', 'Twenty-five years old', 'Correct answer.', 'EST01'),
('OP430', 'Twenty-five nationalities', 'Incorrect answer.', 'EST02'),
('OP431', 'Twenty-five occupations', 'Incorrect answer.', 'EST02'),
('OP432', 'Twenty-five last names', 'Incorrect answer.', 'EST02'),
('OP433', 'Nurse', 'Correct answer.', 'EST01'),
('OP434', 'Teacher', 'Incorrect answer.', 'EST02'),
('OP435', 'Driver', 'Incorrect answer.', 'EST02'),
('OP436', 'Chef', 'Incorrect answer.', 'EST02'),
('OP437', 'How old are you?', 'Correct answer.', 'EST01'),
('OP438', 'Where are you?', 'Incorrect answer.', 'EST02'),
('OP439', 'What is your nationality?', 'Incorrect answer.', 'EST02'),
('OP440', 'Who are you?', 'Incorrect answer.', 'EST02'),
('OP441', 'Where are you from?', 'Correct answer.', 'EST01'),
('OP442', 'When are you from?', 'Incorrect answer.', 'EST02'),
('OP443', 'Who are you from?', 'Incorrect answer.', 'EST02'),
('OP444', 'How old are you from?', 'Incorrect answer.', 'EST02'),
('OP445', 'Our', 'Correct answer.', 'EST01'),
('OP446', 'Their', 'Incorrect answer.', 'EST02'),
('OP447', 'His', 'Incorrect answer.', 'EST02'),
('OP448', 'Her', 'Incorrect answer.', 'EST02'),
('OP449', 'Their', 'Correct answer.', 'EST01'),
('OP450', 'His', 'Incorrect answer.', 'EST02'),
('OP451', 'Her', 'Incorrect answer.', 'EST02'),
('OP452', 'Our', 'Incorrect answer.', 'EST02'),
('OP453', 'Carolina Martinez', 'Correct answer.', 'EST01'),
('OP454', 'Carolina Wilson', 'Incorrect answer.', 'EST02'),
('OP455', 'Isabella Martinez', 'Incorrect answer.', 'EST02'),
('OP456', 'Olivia Brown', 'Incorrect answer.', 'EST02'),
('OP457', 'She is twenty years old and Brazilian.', 'Correct answer.', 'EST01'),
('OP458', 'She is twenty-two years old and Mexican.', 'Incorrect answer.', 'EST02'),
('OP459', 'She is nineteen years old and Japanese.', 'Incorrect answer.', 'EST02'),
('OP460', 'She is twenty-five years old and Canadian.', 'Incorrect answer.', 'EST02'),
('OP461', 'She is a nurse.', 'Correct answer.', 'EST01'),
('OP462', 'She is a teacher.', 'Incorrect answer.', 'EST02'),
('OP463', 'She is a doctor.', 'Incorrect answer.', 'EST02'),
('OP464', 'She is a chef.', 'Incorrect answer.', 'EST02'),
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
-- Estructura de tabla para la tabla `pista_boss_battle`
--

CREATE TABLE `pista_boss_battle` (
  `codigo` varchar(10) NOT NULL,
  `palabra` varchar(10) NOT NULL,
  `pista_facil` varchar(255) NOT NULL,
  `pista_intermedia` varchar(255) NOT NULL,
  `pista_dificil` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pista_boss_battle`
--

INSERT INTO `pista_boss_battle` (`codigo`, `palabra`, `pista_facil`, `pista_intermedia`, `pista_dificil`) VALUES
('PBB000002', 'PAL0002', 'It is a big wild animal that looks like a cat, with orange fur and black lines on its body.', 'This dangerous mammal lives in the jungle, eats meat, and is famous for its loud roar.', 'A solitary hunter of Asia, this apex predator is the largest member of the feline family.'),
('PBB000003', 'PAL0003', 'It is a dark color that you get when you mix red and blue together.', 'This shade is often associated with royalty, grapes, and lavender flowers.', 'Situated between red and blue on the visible spectrum, this secondary hue historically symbolized luxury and power due to the high cost of its dye.'),
('PBB000004', 'PAL0004', 'The female parent who gives birth to or raises a child.', 'A female who assumes the primary parental role in nurturing and raising offspring.', 'The maternal figure biologically or socially responsible for guiding a child through their formative years.'),
('PBB000005', 'PAL0005', 'An elongated utensil featuring a dark mineral core encased in wood, utilized for sketching or drafting temporary notes.', 'An indispensable stationery item whose carbonaceous insert leaves erasable marks on parchment, requiring periodic maintenance with a blade or abrasive block.', 'A bilateral composite writing implement characterized by a non-permanent pigmented core that undergoes mechanical ablation during application.'),
('PBB000006', 'PAL0006', 'An outdoor team game played on a grass pitch where players maneuver a spherical sphere primarily with their feet to score.', 'The most widely played global pastime featuring a referee, two opposing elevens, and ninety minutes of regulation play culminating in goals.', 'Often referred to as association football to distinguish it from its gridiron or rugby counterparts, this discipline mandates exceptional lower-limb dexterity.'),
('PBB000007', 'PAL0007', 'A place with many green trees and animals living outside.', 'A wild land full of tall plants, wood, and shade from the sun.', 'A vast ecosystem dominated by thick vegetation and wildlife far away from cities.'),
('PBB000008', 'PAL0008', 'A small computer that you can close like a book and carry with you in a bag.', 'A personal electronic device with a screen and keyboard that runs on a battery so you can work away from a desk.', 'A mobile workstation designed for travel, combining a display, input board, and processor into one folding unit.'),
('PBB000009', 'PAL0009', 'This is how you feel when something great happens to you, often showing a big smile.', 'A positive emotional state where you feel content, pleased, and generally satisfied with your day.', 'An enduring sense of psychological well-being and cheerfulness, often contrasted with sadness or despair.'),
('PBB000010', 'PAL0010', 'This human-powered mode of transportation has a pair of wheels, handlebars for steering, and a saddle.', 'A common eco-friendly conveyance featuring a chain-driven mechanism activated by the rider\'s feet.', 'A personal conveyance relying on mechanical advantage through gear ratios to propel forward via pedal rotation.'),
('PBB000011', 'PAL0012', 'A brown animal that loves to eat bananas and can climb trees very well.', 'It is a furry creature with a long tail that lives in the jungle and makes funny sounds.', 'A clever mammal with hands and feet, often seen swinging from branch to branch.'),
('PBB000012', 'PAL0013', 'This is a very smart gray animal that lives in the ocean and loves to jump out of the water.', 'It is a friendly sea mammal that breathes air, swims in groups called pods, and makes clicking sounds.', 'A warm-blooded aquatic creature known for using echolocation to navigate and communicate with others in its family.'),
('PBB000013', 'PAL0014', 'A giant grey animal from Africa or Asia that has four thick legs and a long nose called a trunk.', 'This intelligent herbivore uses its flexible nose to drink water, grab food, and communicate with its family herd.', 'Known for having massive ivory tusks and incredible memory, this endangered mammal is the largest creature walking on land today.'),
('PBB000014', 'PAL0015', 'A famous sea bird with black and white feathers that looks like it is wearing a suit, but it cannot fly in the air.', 'This animal spends most of its life swimming in very cold southern oceans and uses its wings as flippers to move fast.', 'A flightless avian species famous for waddling upright across ice and snow, mostly found in the Southern Hemisphere.'),
('PBB000015', 'PAL0016', 'A yellow fruit that monkeys like to eat.', 'It is long and curved, and you must take off the skin before you eat it.', 'A tropical food that grows in bunches on large plants and becomes sweet and soft as it ripens.'),
('PBB000016', 'PAL0017', 'It is a yellow or white food made from milk that you can put on a pizza or a sandwich.', 'A yellow or white solid food made from cow, goat, or sheep milk, often used in cooking or eaten with crackers.', 'A popular dairy product that comes in many types like cheddar or mozzarella, formed by curdling milk.'),
('PBB000017', 'PAL0018', 'This is a very common farm animal that has feathers and two legs, and many people eat its meat or its white eggs.', 'A domestic bird often raised on farms around the world that cannot fly very high, known for making a clucking sound.', 'A popular poultry species whose male is called a rooster, frequently featured in popular dishes at fast-food restaurants.'),
('PBB000018', 'PAL0020', 'A type of plant, such as a carrot, broccoli, or spinach, that people regularly eat.', 'An edible agricultural produce that is typically savory rather than sweet and forms a core part of a balanced diet.', 'Botanically distinct from fruits, this category encompasses various edible roots, stems, and leaves cultivated for human consumption.'),
('PBB000019', 'PAL0021', 'It is the color of a stop sign, a fire truck, and fresh strawberries.', 'This bright primary color is often used to show love on Valentine\'s Day.', 'In many cultures, this vibrant hue symbolizes passion, energy, and warmth.'),
('PBB000020', 'PAL0022', 'This is the bright color of a lemon and a sunflower.', 'It is one of the primary colors, sitting right between orange and green on the color wheel.', 'In many cultures, this cheerful shade is often used to symbolize happiness, warmth, and caution.'),
('PBB000021', 'PAL0023', 'It is a bright and happy color that is the same as a sweet citrus fruit you like to eat.', 'This warm color comes right between red and yellow on a rainbow.', 'Many safety vests and construction cones use this high-visibility hue so people can see them easily.'),
('PBB000022', 'PAL0024', 'This is the color of fresh grass, spring trees, and some healthy vegetables like broccoli and salad.', 'In a traffic light, this color tells cars that they can go forward.', 'When you mix blue and yellow paint together, you create this shade.'),
('PBB000023', 'PAL0025', 'It is a bright color between blue and green, often associated with tropical oceans.', 'This precious gemstone has a distinct greenish-blue shade and has been used in jewelry for thousands of years.', 'Derived from the French word for Turkish, this mineral name also describes a specific vivid hue found in traditional Southwestern jewelry.'),
('PBB000024', 'PAL0026', 'Your male parent; the man who has a child.', 'The husband of your mother.', 'The male ancestor who helps bring a new person into a family.'),
('PBB000025', 'PAL0027', 'A girl who shares the same mother and father with you.', 'Your female sibling; she is the daughter of your parents.', 'A female family member who grows up in the same household with you, having both parents in common.'),
('PBB000026', 'PAL0028', 'A male sibling who shares the same mother and father with you.', 'A boy in your family who has your parents, making him your male relative of the same generation.', 'A male family member with whom you share both biological creators, growing up together in the same household.'),
('PBB000027', 'PAL0029', 'This is a girl who is your child, just like a boy is a son.', 'If your brother has a little girl, she is your niece, but she is her parents\' what?', 'In a family tree, this female descendant is born to a mother and a father.'),
('PBB000028', 'PAL0031', 'You read this object. It has many paper pages inside a front and back cover.', 'You open this item to read stories, look at pictures, or study for your school classes.', 'A portable object containing bound sheets of paper with text or images, often found in a library.'),
('PBB000029', 'PAL0032', 'This person works in a school and helps students learn subjects like math and English.', 'You raise your hand to ask this person questions when you do not understand your homework.', 'Someone whose daily job is to stand in front of a classroom and share knowledge with others.'),
('PBB000030', 'PAL0033', 'This is a place inside a school with chairs, a blackboard, and desks where you sit to study.', 'You go into this specific space every day with your teacher and classmates to listen to lessons.', 'Inside an educational building, this enclosed area fills with learning activities and discussions during morning hours.'),
('PBB000031', 'PAL0034', 'Teachers give you this school task to finish when you go back to your house.', 'Extra assignments given by teachers to complete outside of regular classroom hours.', 'Academic obligations taken beyond the classroom to reinforce daily lessons independently.'),
('PBB000032', 'PAL0035', 'A task or project that your teacher gives you to do for school.', 'Something you are told to complete outside of class hours, often at home.', 'A formal duty or allotted responsibility given to someone as part of their studies or job.'),
('PBB000033', 'PAL0036', 'It is a popular sport where two or four players hit a small yellow ball over a net using rackets.', 'Players score points by making the ball land in the opponent\'s court so they cannot hit it back.', 'Matches are played on a rectangular grass, clay, or hard surface, and players count points as love, 15, 30, 40.'),
('PBB000034', 'PAL0037', 'A popular game where tall players bounce an orange ball and throw it high into a net.', 'Two teams play this indoor sport on a court with a wooden floor and a backboard at each end.', 'A fast team game where players dribble down the court to score points by shooting through a metal ring.'),
('PBB000035', 'PAL0038', 'It is a popular American sport. Players use a long wooden stick to hit a small white ball and run.', 'In this outdoor game, two teams take turns trying to score points by running around four corners of a large field.', 'A pitcher throws a hard ball toward a batter who tries to hit it far into the field before dropping the bat to run.'),
('PBB000036', 'PAL0039', 'This is a popular summer sport where people move through water using their arms and legs.', 'People often go to a pool or the beach to do this exercise on a hot day.', 'This aquatic hobby and competitive sport requires you to float and propel yourself forward without touching the bottom.'),
('PBB000037', 'PAL0041', 'It is a very big plant with green leaves, a brown trunk, and branches.', 'Birds often build their nests in this living thing to stay safe.', 'This tall organism gives us shade on sunny days and produces oxygen to help us breathe.'),
('PBB000038', 'PAL0042', 'A pretty plant part that has many colors and smells very nice.', 'You can put these in a vase with water to make your room look nice.', 'Bees and butterflies fly to this part of a plant to get sweet juice.'),
('PBB000039', 'PAL0043', 'It is a long line of water that moves across the land into the sea.', 'People can swim, fish, or take boat trips on this flowing body of fresh water.', 'This geographical feature often starts in the mountains and constantly flows downward toward the ocean.'),
('PBB000040', 'PAL0044', 'It is a very big and high natural pile of rock and earth, much bigger than a hill.', 'People like to climb to the very top of this landform to see the view, and it is often covered with snow.', 'This large geographical feature has steep slopes and forms a massive barrier in the landscape, sometimes reaching above the clouds.'),
('PBB000041', 'PAL0045', 'A natural stream of water that drops down from a high cliff or mountain.', 'A scenic geographic feature where a river flows over a vertical drop in the landscape.', 'A dramatic vertical descent of flowing liquid, often found in remote forests or mountain ranges.'),
('PBB000042', 'PAL0047', 'A machine with a screen and keyboard that you use to play games, watch videos, and go on the internet.', 'An electronic device that lets you write documents, send emails, and find information online.', 'A programmable digital system that accepts data as input, executes instructions, and outputs results.'),
('PBB000043', 'PAL0048', 'You use this device with many buttons to write words and numbers on your computer screen.', 'It is connected to a PC or laptop and has letters, numbers, and a space bar in the middle.', 'An input hardware component featuring an array of tactile switches pressed to input text and execute shortcuts.'),
('PBB000044', 'PAL0049', 'The digital apps and games you download and run on your phone, tablet, or computer.', 'The non-physical data and instructions that tell a computer processor what tasks to perform.', 'Intangible digital products created by developers, contrasted with the physical electronic components of a system.'),
('PBB000045', 'PAL0050', 'A digital filing cabinet on a computer where you can store, search, and manage lots of information easily.', 'An electronic system that holds large amounts of structured data so that computer programs can quickly find what they need.', 'A systematically arranged repository of digital records designed for rapid retrieval, updating, and management by software applications.'),
('PBB000046', 'PAL0052', 'How you feel when someone takes your toy or makes you very unhappy.', 'You make this face and feel hot inside when something bad happens to you.', 'A strong negative emotion that causes you to raise your voice or frown.'),
('PBB000047', 'PAL0053', 'How you feel when it is your birthday and you get a great present.', 'You have a big smile, a lot of energy, and you cannot wait for something fun to happen.', 'A state of high nervous energy and great eagerness before a fun event starts.'),
('PBB000048', 'PAL0057', 'A very big yellow or red car that takes many people to school or work.', 'You wait at a special station for this public vehicle and pay the driver to ride inside.', 'A heavy motor vehicle operating on fixed city routes with multiple seats for travelers.'),
('PBB000049', 'PAL0058', 'It is a very long vehicle that carries many people on metal tracks from one city to another.', 'You buy a ticket to ride this public transport inside a station, and it stops at different platforms.', 'This transport connects towns and cities by moving on iron rails, powered by an engine at the front.'),
('PBB000050', 'PAL0059', 'A big flying machine with wings that takes people to other countries.', 'You need to buy a ticket and go to an airport to travel on this fast transport.', 'This heavy metal vehicle uses powerful engines to move through the clouds above the earth.'),
('PBB000051', 'PAL0060', 'It is a fast, two-wheeled ride with an engine, and riders usually wear a helmet for safety.', 'A motorized vehicle that balances on two wheels, allowing a person to travel quickly on roads.', 'A personal mechanized transport offering the speed of a car but requiring the rider to lean into turns to maintain balance on its dual wheels.'),
('PBB000052', 'PAL0061', 'To damage the surface of something by rubbing it hard with something rough.', 'To wear away skin or a material layer through continuous friction.', 'To cause gradual deterioration of a physical barrier by mechanical scraping or wearing.'),
('PBB000053', 'PAL0062', 'This word describes traveling, living, or working in another nation across the sea or border.', 'When you leave your native land to visit somewhere overseas, you are traveling to this place.', 'Used as an adverb, this term indicates movement or presence outside one\'s national boundaries.'),
('PBB000054', 'PAL0063', 'Like a sponge taking in water, this action means to soak up liquid or energy.', 'When a dry paper towel touches spilled milk, it will automatically do this to the liquid.', 'To fully engage your attention or to take in information so completely that you understand it thoroughly.'),
('PBB000055', 'PAL0064', 'To say yes when someone offers you a gift, an invitation, or a new job.', 'To willingly take something that is being handed or offered to you by someone else.', 'To officially recognize and submit to a situation, truth, or responsibility without fighting it.'),
('PBB000056', 'PAL0066', 'To tell someone that you think they did something bad or broke a rule.', 'To point a finger at a person and officially charge them with a crime or a mistake.', 'To formally attribute blame or wrongdoing to an individual, often initiating a legal or disciplinary process.'),
('PBB000057', 'PAL0067', 'Feeling a steady, physical pain in your muscles or joints after doing a lot of exercise.', 'Describing a body part that hurts constantly and makes you feel tired or uncomfortable.', 'A dull, lingering discomfort that often follows intense physical effort or a long day of standing.'),
('PBB000058', 'PAL0068', 'This describes a person who plays sports, exercises a lot, or is always busy doing something instead of sitting down.', 'It is the opposite of lazy or resting; someone with this quality likes to participate and get involved in projects.', 'A dynamic state characterized by constant energy, productivity, and physical or mental engagement rather than passivity.'),
('PBB000059', 'PAL0069', 'How clearly and sharply you can see, hear, or understand things around you.', 'A high level of mental sharpness or the ability to notice small details very easily.', 'A noun describing the keenness or penetrating cleverness of someone\'s senses or intellect.'),
('PBB000060', 'PAL0070', 'To physically attach or glue one thing to another surface so it stays in place.', 'To continue to follow a specific plan, instruction, or promise without changing your mind.', 'To maintain loyalty and dedication to a principle, belief, or established guideline over time.'),
('PBB000061', 'PAL0071', 'To change something a little bit so that it fits correctly or works better.', 'What you do to your chair height or car mirrors to make them more comfortable for you.', 'To fine-tune a mechanism or adapt your behavior to new conditions for a better outcome.'),
('PBB000062', 'PAL0072', 'To look at someone and feel a lot of respect or liking for them because of who they are or what they have done.', 'To hold a very high opinion of a person\'s character, skills, or accomplishments, often wishing to be like them.', 'To view someone with a mixture of wonder, approval, and deep appreciation for their exceptional traits or success.'),
('PBB000063', 'PAL0074', 'To give someone your opinion on what action they should take in a difficult situation.', 'To offer professional recommendations or expert suggestions to help someone make a decision.', 'To act as a consultant by sharing specialized knowledge to guide someone\'s future choices.'),
('PBB000064', 'PAL0076', 'How you feel when you watch a scary movie or think something bad might happen to you.', 'An emotional state where someone feels nervous, frightened, or concerned about a specific danger.', 'Experiencing a sense of apprehension or dread regarding a potential threat or unpleasant outcome.'),
('PBB000065', 'PAL0077', 'Treating older or younger people unfairly just because of how many years old they are.', 'A type of prejudice where people make negative judgments or deny opportunities based strictly on a person\'s generation.', 'Systemic bias that marginalizes individuals in the workplace or society due to preconceived notions about their stage in the life cycle.'),
('PBB000066', 'PAL0078', 'This action happens when something is so wonderful or shocking that it makes you say \'Wow!\'', 'It describes when a magic trick or a brilliant performance fills you with great wonder and admiration.', 'A verb showing that someone\'s exceptional talent or a surprising event leaves observers completely astounded.'),
('PBB000067', 'PAL0079', 'This noun describes how much you have of something, like money or water.', 'It refers to the total size, value, or number of something when you collect it all together.', 'Often used with uncountable nouns, this term denotes a specific sum or measured mass of a substance.'),
('PBB000068', 'PAL0080', 'An event that happens one time every twelve months, like a birthday celebration.', 'An adjective used to describe a report, fee, or festival that occurs regularly on the exact same date each year.', 'Pertaining to a twelve-month cycle, often used to categorize plants that complete their entire life cycle within a single growing season.'),
('PBB000069', 'PAL0081', 'When you lose a court case or a sports decision, you can make this formal request to ask a higher authority to change it.', 'This noun describes a serious, urgent request for help, money, or public support during a difficult time.', 'To be found attractive, interesting, or pleasing to someone\'s tastes; it also means to formally challenge a verdict.'),
('PBB000070', 'PAL0083', 'This is a major language spoken in countries like Egypt, Saudi Arabia, and Morocco, written from right to left.', 'Relating to the traditional culture, heritage, and populations originating from the Middle East and North Africa.', 'Pertaining to the Semitic language family that serves as the official tongue for over twenty nations.'),
('PBB000071', 'PAL0084', 'To finally get to the destination or place you wanted to go after a journey.', 'To successfully complete a trip and show up at a hotel, party, or appointment.', 'The moment a scheduled flight or train finally pulls in and is ready for passengers to get off.'),
('PBB000072', 'PAL0086', 'This is the physical state you are in when your eyes are closed and you are resting deeply during the night.', 'You are in this condition when you are not awake and your brain rests, often dreaming in bed.', 'A temporary suspension of consciousness during which the body recovers and awareness of the surrounding environment is turned off.'),
('PBB000073', 'PAL0087', 'To think that something is a fact before you have any proof or evidence.', 'To take something for granted without checking if it is actually correct.', 'To form a conclusion about a situation in the absence of concrete facts.'),
('PBB000074', 'PAL0088', 'To try to hurt or damage someone or something by using physical force.', 'An aggressive action taken against an opponent or enemy during a fight or competition.', 'To launch a sudden offensive maneuver or begin actively working to destroy a problem or rival.'),
('PBB000075', 'PAL0089', 'A large fight or conflict between two opposing armies or groups of people during a war.', 'An extended struggle or competition to achieve something difficult, or to overcome a serious problem.', 'A major contest of strength, will, or resources between opposing forces striving for victory or dominance.'),
('PBB000076', 'PAL0090', 'To change over time and grow into a different type of person or thing, such as a caterpillar turning into a butterfly.', 'To undergo a process of transformation where your current state changes into a new role, status, or identity.', 'To evolve or transition from one condition into another, often used when describing a future career aspiration or a shift in personal traits.'),
('PBB000077', 'PAL0091', 'This word means doing something to help or support another person, often used in phrases like \"on my ___.\"', 'When you act as a representative for someone else, you are doing it for their benefit or interest.', 'A noun often found in formal speeches or legal contexts when someone speaks to represent a group or an absent person.'),
('PBB000078', 'PAL0093', 'This verb describes where something naturally goes, like a book returning to its correct shelf on the library bookcase.', 'You feel this way when you share the same values and interests as your friends and they treat you as part of their social circle.', 'To fit in seamlessly with your surroundings or environment, creating a strong sense of personal ownership and permanent connection.'),
('PBB000079', 'PAL0094', 'This is the comparative form of \'good\', used when something is nicer or more useful than before.', 'You use this word to describe an option that is an improvement over a previous choice.', 'To surpass a previous standard of performance or to recover from an illness means you are feeling this way.'),
('PBB000080', 'PAL0095', 'This is how black coffee or dark chocolate tastes when you do not add any sugar.', 'This describes a taste like lemon peel, or a feeling of deep disappointment and anger.', 'An adjective for a cold weather condition or a lasting emotional resentment after an argument.'),
('PBB000081', 'PAL0096', 'This is the past tense of a verb that means to burn with a very bright, strong flame.', 'It describes a fire or light that produced a lot of heat and shone with great intensity yesterday.', 'To have produced a brilliant, fierce light or energy source in the past, often used metaphorically for a sudden display of passion.'),
('PBB000082', 'PAL0097', 'A serious sickness that damages plants and makes their leaves turn brown and die.', 'Something that ruins crops in a farm or garden, often destroying the food supply for an entire season.', 'A widespread destructive influence or persistent problem that ruins growth and causes things to wither away.'),
('PBB000083', 'PAL0098', 'A traditional style of headwear tied under the chin with strings, often worn by babies or in the past by women.', 'A brimless cap that frames the face, historically used for everyday wear and currently included in certain traditional nurse or scout uniforms.', 'Derived from Old French, this term refers specifically to a soft, tied head covering historically associated with domestic servants, nursing attire, and Scottish traditional dress.'),
('PBB000084', 'PAL0099', 'This is how you feel when a movie or book has no action and makes you want to fall asleep.', 'An adjective used to describe a long lecture or activity that makes time feel like it is moving very slowly.', 'Lacking any quality that captures attention or stimulates curiosity, often causing a strong desire for a change of activity.'),
('PBB000085', 'PAL0100', 'To temporarily take something from a friend, like a book or a pen, and plan to give it back later.', 'An action where you receive an item for temporary use, understanding that you must return the exact same object to its owner.', 'To establish a temporary agreement of possession where utility is transferred without ownership, pending future restitution.'),
('PBB000086', 'PAL0101', 'What a rubber ball does when you throw it hard against the floor and it comes right back up to your hand.', 'To spring back into the air after hitting a hard surface, like a basketball on a wooden court.', 'To cause a cheque to be returned by a bank because there is not enough money in the account.'),
('PBB000087', 'PAL0102', 'This is money given as a prize or reward, often for finding something that was lost.', 'Governments sometimes offer this cash payment to people who help catch a dangerous criminal.', 'Historically, this financial incentive was paid to hunters for capturing harmful wild animals.'),
('PBB000088', 'PAL0103', 'This is the air you pull into your body through your nose or mouth and push back out.', 'You do this unconscious action thousands of times every day to keep your body alive and supplied with oxygen.', 'Visible as a small cloud of white vapor when you step outside into freezing winter weather.'),
('PBB000089', 'PAL0104', 'A financial plan that helps you track your income and decide how to spend your money.', 'Before starting a big project or trip, people calculate their expected costs and available funds in this document.', 'A quantitative expression of a proposed plan of operations for a specific future period, often used by governments and businesses to control expenses.'),
('PBB000090', 'PAL0105', 'A heavy load that you carry, or a difficult problem that makes you feel stressed.', 'Something very difficult to deal with emotionally, like keeping a big secret or managing too much work.', 'An oppressive duty or serious obligation that weighs constantly on someone\'s mind and energy.'),
('PBB000091', 'PAL0106', 'A government department or business office that gives information or handles a specific public service.', 'A specialized administrative division within a larger company or government agency.', 'An institutional entity dedicated to gathering information, managing administrative tasks, or delivering specialized public assistance.'),
('PBB000092', 'PAL0108', 'This is a yellow spread made from milk that people often put on toast or use in baking.', 'A dairy product churned from cream, commonly used as a cooking fat or melted over hot vegetables.', 'An emulsion of water in oil prepared by churning animal cream, essential for pastry making and flavoring dishes.'),
('PBB000093', 'PAL0109', 'An adjective that describes things, customs, or eras that happened a long time ago and no longer exist.', 'Often used in phrases like \'let bygones be bygones,\' this word refers to history or memories that are far behind us.', 'Describing something displaced by the modern march of time, evoking a nostalgic sense of an earlier, departed age.'),
('PBB000094', 'PAL0110', 'This is a heavy, strong type of material that artists paint their pictures on.', 'A durable woven fabric frequently used to manufacture backpacks, hiking tents, and sails for boats.', 'Derived from the Latin word for hemp, this sturdy textile provides the foundational surface for oil and acrylic masterpieces.'),
('PBB000095', 'PAL0111', 'A popular snack nut that has an unusual curved shape, somewhat like a kidney bean, and grows attached to the bottom of a large bright fruit.', 'This tropical tree seed is rarely sold with its outer covering because a toxic oil surrounds the shell, so it must be roasted before people can eat it.', 'Botanically speaking, this edible kernel is actually the seed of a false fruit known locally as an apple, native to coastal regions of northeastern Brazil.'),
('PBB000096', 'PAL0112', 'A private gathering where members of a political party discuss policies and choose their candidates.', 'An official assembly of organization or government members who unite to make decisions and plan strategies.', 'A localized closed-door convention used in some political systems to select nominees before a general election.'),
('PBB000097', 'PAL0114', 'An opportunity or a time when you are able to do something you want.', 'The possibility that a particular event or result will happen in the future.', 'A situation that offers a favorable opening to achieve a goal, often depending on luck.'),
('PBB000098', 'PAL0115', 'To turn something into a different version, like putting on a brand new outfit.', 'To transform or adjust a situation so that it is no longer the same as before.', 'Coins and paper bills given back as the remaining balance after paying more than the total cost.'),
('PBB000099', 'PAL0117', 'To pick one option when you have a few different things to look at.', 'To make up your mind about which person, item, or action you prefer from a group.', 'To select a preferred path or alternative after careful consideration of available options.'),
('PBB0001', 'PAL0001', 'It is a fruit that can be red, green, or yellow. People often eat it as a snack.', 'This fruit grows on trees and is often used to make juice, pies, and other desserts.', 'A popular fruit associated with orchards, teachers, and a well-known saying about keeping doctors away.'),
('PBB000100', 'PAL0118', 'This is a round 2D shape where every point on the edge is the exact same distance from the center.', 'People often sit in this curved shape during a meeting or a game so everyone can see each other.', 'A closed geometric curve with no corners, commonly used to describe a close group of friends or associates.'),
('PBB000101', 'PAL0119', 'To give your full time, attention, or energy to a plan, person, or goal.', 'To make a firm decision to do something important and not change your mind.', 'To officially send someone to a prison or a hospital for specialized care.'),
('PBB000102', 'PAL0120', 'Something that you see or experience every day because it is normal and happens all the time.', 'An adjective describing a situation, problem, or interest that is experienced by a large group of people.', 'Lacking any unique or rare qualities; a widespread characteristic belonging equally to numerous individuals or places.'),
('PBB000103', 'PAL0121', 'To follow a rule or do what you are asked to do by someone in authority.', 'To act in accordance with official guidelines, regulations, or someone\'s specific wishes.', 'To yield or submit to a standard, requirement, or external demand without resistance.'),
('PBB000104', 'PAL0124', 'A local region or district inside a larger state or nation, often having its own local government.', 'A territorial division used by governments for organizing public services, elections, and local laws.', 'A subnational geographical jurisdiction situated between a municipality and the national level.'),
('PBB000105', 'PAL0125', 'To make something new that did not exist before, like an artist making a painting.', 'To bring something into existence through your own imagination or abilities.', 'To initiate the origin of a concept, project, or physical item from scratch.'),
('PBB000106', 'PAL0126', 'This is the special thanks or recognition you get when you successfully complete a good job or project.', 'When teachers or colleagues acknowledge that you were responsible for a great idea, they give you this.', 'In academic settings, this term also refers to the units you earn for successfully passing a university course.'),
('PBB000107', 'PAL0127', 'This is what happens when something gets broken or hurt so it is not in good condition anymore.', 'It refers to the negative effect or destruction caused by an accident, a storm, or a careless action.', 'A noun describing the impairment, loss of value, or structural compromise inflicted upon an object or system.'),
('PBB000108', 'PAL0128', 'This is a situation where you might get hurt or something bad could happen to you.', 'When you see a warning sign on a fence or a bottle, it is telling you about this potential risk.', 'A state of exposure to potential harm, often requiring caution or protective measures to avoid injury.'),
('PBB000109', 'PAL0130', 'To make up your mind about something after thinking about your options.', 'To reach a final conclusion or select a specific course of action after careful consideration.', 'To settle a question or dispute by officially choosing one path and ending all doubts.'),
('PBB000110', 'PAL0131', 'To win a game, fight, or competition against another person or team.', 'To successfully overcome a challenge or stop a plan from being successful.', 'To cause a rival or opponent to fail in achieving their goal.'),
('PBB000111', 'PAL0132', 'This is a paper you receive when you successfully finish your studies at a university.', 'This word describes a unit for measuring angles or temperature, like Celsius.', 'It represents the extent, measure, or intensity to which something happens or is present.'),
('PBB000112', 'PAL0133', 'To ask for something firmly and strongly because you need or expect it.', 'An urgent or forceful order for goods, services, or answers that must be given.', 'In economics, this refers to how much consumers want to buy a specific product or service.'),
('PBB000113', 'PAL0134', 'To need a person or thing to help you, give you money, or keep you safe.', 'To be controlled or decided by something else, such as the weather or your plans.', 'To place your full trust in someone to be there for you when things get difficult.'),
('PBB000114', 'PAL0135', 'To send people or things like soldiers or equipment to a place so they are ready to act or fight.', 'To put a plan, strategy, or system into action so it starts working effectively.', 'To effectively utilize available resources, forces, or assets to achieve a specific objective or goal.'),
('PBB000115', 'PAL0136', 'This is a very hot and dry place with lots of sand and almost no trees or water.', 'Camels and cactus plants survive in this harsh, barren environment where it rarely rains.', 'A vast geographical region characterized by extreme aridity, sparse vegetation, and high temperatures.'),
('PBB000116', 'PAL0138', 'This is a feeling of really wanting something, like a new phone or a delicious meal.', 'It is a strong motivation or ambition to achieve a specific goal or possess an item.', 'A powerful psychological yearning that compels a person to seek fulfillment or take action.'),
('PBB000117', 'PAL0139', 'A single, small fact or piece of information about a larger topic, person, or object.', 'When you look closely at a painting or a plan, you might focus on one specific part rather than the whole picture.', 'To give a thorough report, you must include every specific element and minor feature without missing anything important.'),
('PBB000118', 'PAL0140', 'A machine or tool made to do a special job.', 'A small piece of technology, like a smartphone or a kitchen tool, built for a specific function.', 'A clever mechanical or electronic creation invented to solve a practical problem.'),
('PBB000119', 'PAL0141', 'To not be the same as someone or something else; to have a different opinion.', 'When two things are not identical and show a contrast in qualities, views, or features.', 'To diverge in characteristics or fail to agree on a particular subject or decision.'),
('PBB000120', 'PAL0143', 'This is what happens because of something you did, like when you drop a glass and it breaks.', 'A change or outcome that is produced by a specific action, decision, or event.', 'Often confused with a similar-sounding verb, this noun describes the tangible consequence of an external stimulus.'),
('PBB000121', 'PAL0144', 'This word is used when you have two options and you need to pick just one of them.', 'You use this conjunction with the word \'or\' to present a pair of positive alternatives.', 'A determiner and pronoun indicating a choice between a dual set of possibilities, where selecting both is not required.'),
('PBB000122', 'PAL0145', 'To give someone the power, right, or opportunity to do something easily.', 'To provide the necessary tools or conditions so that an action can happen successfully.', 'To activate a function or give the authority and means required to achieve a specific goal.'),
('PBB000123', 'PAL0146', 'To take part in something, like a game, a conversation, or a group activity.', 'To catch and hold someone\'s attention or interest while working together on a task.', 'To establish a meaningful connection or enter into a formal agreement to perform a specific duty.'),
('PBB000124', 'PAL0147', 'This word means having the correct amount of something, so you do not need any more.', 'You use this quantity adjective when you have as much of something as is necessary for a specific purpose.', 'It describes a situation where a supply meets all requirements, leaving no deficit or shortfall.'),
('PBB000125', 'PAL0148', 'To check something carefully so you know it will happen successfully.', 'To take action beforehand to guarantee a particular result or outcome.', 'To secure a desired state of affairs by removing any doubt or preventing failure.'),
('PBB000126', 'PAL0149', 'To need something or make it a necessary part of an action or plan.', 'When a job or a decision requires a specific action or causes a certain result.', 'To logically demand a certain consequence or make a specific condition unavoidable.'),
('PBB000127', 'PAL0150', 'Not divided or broken into pieces; you have everything from start to finish.', 'Used to describe something with no parts missing, such as a day or a collection.', 'An adjective meaning lacking any omission or exception, encompassing every single component.'),
('PBB000128', 'PAL0151', 'This is a noun that means treating everyone in a fair way so that people have the same chances in life.', 'Often contrasted with equality, this concept focuses on giving individuals what they specifically need to succeed rather than giving everyone the exact same thing.', 'In finance and business, this term also refers to the value of the shares owned by shareholders in a company.'),
('PBB000129', 'PAL0152', 'To grow bigger in size, shape, or area.', 'To open up or spread out something that was previously folded or tightly closed.', 'To increase the scope, volume, or importance of a business, project, or range of ideas.'),
('PBB000130', 'PAL0153', 'To wait for something that you believe will happen in the future.', 'To have a strong feeling or belief that a specific event or action will occur soon.', 'To anticipate an outcome based on prior information or plans.'),
('PBB000131', 'PAL0155', 'To stretch something out to make it physically bigger, longer, or able to cover a greater distance.', 'To increase the duration of an activity or event so that it lasts past its original deadline or finish time.', 'To offer an invitation, an apology, or a gesture of goodwill to someone, or to place your hand outward.'),
('PBB000132', 'PAL0156', 'Looking directly at someone or something, or having your front turned toward a specific direction.', 'Standing in a position where you must look at a difficult problem or challenge instead of running away.', 'Being positioned directly opposite something, or actively dealing with a serious situation or choice.'),
('PBB000133', 'PAL0157', 'An adjective that describes a person, place, or thing that a lot of people know about.', 'Used to describe someone who appears often in the media and is recognized everywhere they go.', 'Possessing widespread renown and celebrated across society for notable achievements or actions.'),
('PBB000134', 'PAL0159', 'To walk or drive right behind another person or vehicle to see where they are going.', 'To accept and act according to a rule, instruction, or piece of advice.', 'To happen as a natural result or consequence of a previous action or event.'),
('PBB000135', 'PAL0160', 'To say \'no\' to something or tell someone they cannot do an action.', 'An authority figure uses this action to stop people from doing a specific rule-breaking activity.', 'To officially issue a strict ban that makes a particular behavior illegal or totally unacceptable.'),
('PBB000136', 'PAL0161', 'This is what happens when information slips out of your mind and you cannot recall it anymore.', 'To let a piece of knowledge, a task, or an appointment completely leave your memory.', 'To fail to retain or bring back a past detail into your conscious awareness when needed.'),
('PBB000137', 'PAL0162', 'This is the type of clothing you wear to a very important party, like a wedding or a job interview, instead of casual jeans.', 'It describes events, language, or behavior that follow strict rules and are meant for serious, official occasions rather than hanging out with friends.', 'Often contrasted with casual, this adjective describes an established structure or ceremony where traditional protocols and proper etiquette are strictly observed.'),
('PBB000138', 'PAL0163', 'This word describes something that happened in the past, or a person who used to have a specific job or title.', 'You use this adjective to talk about an earlier version of something or a previous stage of your life.', 'Antonymous to current, this term refers to the first of two things already mentioned in a conversation.'),
('PBB000139', 'PAL0164', 'This is what happens to water when the weather gets very cold and it turns into ice.', 'When your computer stops working and the screen refuses to move or respond to your mouse, people often say it did this.', 'To become completely motionless or stuck in one place, either because of extreme low temperatures or intense fear.'),
('PBB000140', 'PAL0165', 'It is a cone-shaped tool with a wide opening at the top and a narrow pipe at the bottom, used to pour liquids into small bottles.', 'You use this kitchen or garage item to transfer oil, water, or dry ingredients into a container with a very small opening without spilling.', 'This device directs the flow of substances through a narrow aperture by utilizing a broad surface area to catch and channel the material downward.'),
('PBB000141', 'PAL0166', 'This word means having a lot of something, or having it in very large amounts.', 'Often used after a noun, this adjective describes a situation where there are plenty of choices or items available.', 'Originating from an Irish phrase meaning \'to excess\', this term is used when something is present in such great quantities that you cannot possibly run out.'),
('PBB000142', 'PAL0167', 'To collect or pull many things or people into one specific spot.', 'To accumulate items or invite individuals to assemble for a common purpose.', 'To harvest crops from a field or gradually infer a conclusion from various facts.'),
('PBB000143', 'PAL0168', 'Made or organized to do one specific job very well.', 'Adjusted, prepared, or directed toward a particular goal or audience.', 'Equipped functionally to align with specific requirements or external demands.'),
('PBB000144', 'PAL0170', 'This is how you feel when you know you did something bad or broke a rule.', 'You are described this way in a court of law if the judge decides you committed a crime.', 'Carrying the heavy mental burden of having done something morally wrong or unlawful.'),
('PBB000145', 'PAL0172', 'It means almost not at all, or only a very small amount, like when you can barely hear a quiet sound.', 'You use this adverb when something is barely true or occurs so rarely that it is close to zero.', 'A synonym for \'scarcely\' or \'barely\' used to indicate that an action or event is nearly impossible or extremely limited.'),
('PBB000146', 'PAL0174', 'A car that uses both gasoline and electricity to move is called this type of vehicle.', 'Something made by joining two different styles, materials, or methods together to get the best features of both.', 'A biological offspring resulting from the crossbreeding of two distinct species, varieties, or cultivars.'),
('PBB000147', 'PAL0175', 'To act as if you do not see or hear someone when they are talking to you.', 'To choose not to listen to advice or a warning given by another person.', 'To fail to consider important information purposely when making a decision.'),
('PBB000148', 'PAL0176', 'To tell someone about something or give them facts.', 'To supply someone with important news or details they need to know.', 'To officially notify or update a person regarding a specific situation or topic.'),
('PBB000149', 'PAL0177', 'To say something very clearly and strongly, refusing to change your mind.', 'To forcefully state that something must happen or that you are right about a fact.', 'To maintain a rigid position on a requirement or belief despite opposition.'),
('PBB000150', 'PAL0178', 'To plan to do something in the future.', 'To have a specific goal or purpose in your mind before starting an action.', 'What you mean to achieve or what your objective is when making a decision.'),
('PBB000151', 'PAL0179', 'To spend your money on buying a house, shares, or starting a business because you hope to make a profit later.', 'To dedicate your financial resources or personal energy to a project, believing it will grow or bring success in the future.', 'To commit capital or valuable assets into a commercial venture with the strategic aim of generating future financial returns.'),
('PBB000152', 'PAL0180', 'It is a small piece of land with water all around it.', 'You usually need to take a boat or a plane to visit this place located in the middle of the sea or an ocean.', 'Geographically, this isolated landmass is completely detached from any continent yet remains entirely above sea level.'),
('PBB000153', 'PAL0181', 'To use wood and matches to make a fire start burning.', 'To make a flame begin or to cause strong feelings and emotions to grow inside someone.', 'To arouse an intense reaction, such as an emotion or an argument, often compared to the initial spark of a flame.'),
('PBB000154', 'PAL0182', 'When you talk about two things, this word refers to the second one you mentioned.', 'This term is the opposite of \'former\' and helps you point back to the last option in a list of two.', 'Used in formal writing, this adjective specifies the final item among a pair previously introduced.'),
('PBB000155', 'PAL0183', 'You put these in a row to make words when you write or type on a keyboard.', 'The alphabet consists of twenty-six of these individual graphic units in English.', 'A fundamental written component that corresponds to a specific phoneme in spoken communication.'),
('PBB000156', 'PAL0184', 'This word describes something that has a very good chance of happening or being true.', 'You use this adjective when you expect a particular event or outcome to occur based on the circumstances.', 'Functioning as an adverb or adjective, it sits between a mere possibility and a certain guarantee.'),
('PBB000157', 'PAL0185', 'This is a state of matter, like water or milk, that you can drink and pour into a glass.', 'Unlike a solid, this type of substance easily changes its shape to match whatever holds it.', 'Matter in this phase has a definite volume but no fixed shape, allowing its molecules to move freely past one another.');
INSERT INTO `pista_boss_battle` (`codigo`, `palabra`, `pista_facil`, `pista_intermedia`, `pista_dificil`) VALUES
('PBB000158', 'PAL0186', 'To use your ears to hear what someone is saying or to catch a noise.', 'To focus your hearing on a specific audio source, like music, advice, or a conversation.', 'To act as a receptive audience for acoustic signals, often requiring concentration and comprehension.'),
('PBB000159', 'PAL0187', 'The opposite of big; a word used to describe something that does not take up much space.', 'Used to describe a younger sibling or a compact version of an everyday object.', 'An adjective frequently applied to quantities, degrees, or durations that fall well below the average expectation.'),
('PBB000160', 'PAL0188', 'How you feel when you are by yourself and have no friends around to talk to or play with.', 'An emotional state of sadness caused by missing human contact or not having anyone to share your thoughts with.', 'A persistent psychological sensation of isolation, experienced even in a crowd when meaningful emotional connections are absent.'),
('PBB000161', 'PAL0189', 'A room in a hotel, airport, or home where you sit down, wait, and relax.', 'A public space furnished with comfortable sofas and chairs designed for socializing or taking a break.', 'To spend time lazily in a relaxed posture, often while waiting in a designated hospitality area.'),
('PBB000162', 'PAL0190', 'This word describes something very nice, expensive, and comfortable that you do not really need every day.', 'It refers to a lifestyle or item of great comfort and high cost that goes far beyond what is necessary for basic living.', 'This noun represents an exceptional pleasure or rare indulgence that brings great physical comfort but requires significant financial wealth.'),
('PBB000163', 'PAL0191', 'To be in charge of a business, a project, or a team of people.', 'To successfully handle a difficult situation or make time for daily tasks.', 'To direct the operations of resources or staff to achieve a specific goal.'),
('PBB000164', 'PAL0192', 'A busy outdoor or indoor area where people go to buy fresh fruit, vegetables, and other everyday products.', 'An economic environment where buyers and sellers come together to trade items and determine prices.', 'A dynamic sphere of commercial activity influenced by supply, demand, and global competition.'),
('PBB000165', 'PAL0193', 'This is a topic, situation, or problem that people need to talk about or deal with.', 'When someone says \'it\'s a private _____,\' they mean it is a personal issue that should not be shared with others.', 'An abstract or physical affair of concern; it can refer to a physical substance or an abstract topic of discussion.'),
('PBB000166', 'PAL0194', 'This word describes a person, animal, or plant that has finished growing and is now an adult.', 'When cheese or wine is left for a long time to develop its best flavor, we say it does this.', 'Used to describe ideas or behavior that show good judgment and the wisdom of an adult rather than a child.'),
('PBB000167', 'PAL0195', 'This word describes things that happen inside your head, like thinking, remembering, or solving puzzles.', 'It refers to the health or condition of your brain and psychological well-being, rather than your physical body.', 'An adjective used to characterize internal cognitive processes, perceptions, and intellectual activities.'),
('PBB000168', 'PAL0196', 'It is the point that is equally distant from both ends or edges of an object.', 'This is the space or time that occurs between the beginning and the end of an event.', 'In a sequence of three items, this position is preceded by the first and followed by the last.'),
('PBB000169', 'PAL0197', 'A separate section or unit that makes up a larger university class or piece of software.', 'An interchangeable building block designed to be combined with others to create a complete structure.', 'A standardized, self-contained component whose design allows it to be easily integrated into various larger systems.'),
('PBB000170', 'PAL0198', 'A furry animal with a long tail that loves to climb trees and eat bananas.', 'A clever mammal related to apes, often seen jumping from branch to branch in the jungle.', 'A highly social primate known for its playful behavior and expressive face, distinct from its larger tailless relatives.'),
('PBB000171', 'PAL0199', 'An internal body tissue that helps you move your arms, legs, and other parts by getting tighter.', 'Athletes train these body parts carefully to become stronger, lift heavy objects, and run faster.', 'A biological system composed of soft cellular bundles that transforms chemical energy into physical force and motion.'),
('PBB000172', 'PAL0200', 'The opposite of wide; think of a street or a path where only one person can walk at a time.', 'Used to describe something that measures very little from one side to the opposite side.', 'Often used metaphorically to describe a very close victory or a limited choice between options.'),
('PBB000173', 'PAL0201', 'This describes something or someone that belongs to a specific country from birth, rather than coming from somewhere else.', 'It refers to an animal or plant that naturally grows or lives in a particular region, not having been brought from another part of the world.', 'Often used to describe the first language a person learns to speak at home as a baby before any other.'),
('PBB000174', 'PAL0202', 'It means a little bit less than total, or falling just short of a goal.', 'You use this adverb when something is very close to happening or being finished, but is not quite done.', 'A synonym for practically or roughly, indicating that a condition is met in almost every respect.'),
('PBB000175', 'PAL0203', 'A small metal tool with a sharp point and a tiny hole at one end, used with thread to make or fix clothes.', 'You use this slender implement along with string or yarn to stitch pieces of fabric together.', 'A narrow, pointed instrument traditionally associated with finding a tiny object in a massive stack of hay.'),
('PBB000176', 'PAL0204', 'To pay attention to something using your eyes or ears for the first time.', 'To realize that something is happening around you because you perceive a change in your environment.', 'To register a detail consciously in your mind, shifting it from background noise or vision into active awareness.'),
('PBB000177', 'PAL0205', 'To successfully get or acquire something that you want or need.', 'To come into possession of an item, often by making an effort or following a specific process.', 'To secure ownership or control of a desired resource through purchase, request, or personal endeavor.'),
('PBB000178', 'PAL0206', 'A place with desks and computers where people sit down and do their jobs.', 'A professional workspace usually containing chairs, filing cabinets, and business equipment.', 'An administrative environment where corporate employees manage paperwork, hold meetings, and plan projects daily.'),
('PBB000179', 'PAL0207', 'It is a popular round fruit that shares its name with its bright color.', 'This juicy citrus fruit grows on trees and is very rich in vitamin C.', 'Botanically classified as a modified berry, this peelable produce is heavily cultivated in warm climates for both fresh consumption and breakfast juice.'),
('PBB000180', 'PAL0208', 'You use this yellow wooden tool with paper to write notes or draw pictures, and you can remove your mistakes with a pink eraser at the top.', 'This handheld instrument leaves dark marks on a page using a grey material inside, and unlike a pen, its lines can be completely rubbed out.', 'A cylindrical implement containing a non-permanent marking core, heavily relied upon by students for sketching diagrams and taking temporary notes.'),
('PBB000181', 'PAL0209', 'This is a large heavy farming tool pulled by a tractor or animals to cut and turn over the dirt before planting seeds.', 'Farmers use this heavy agricultural equipment to prepare fields in the spring by digging deep lines into the earth.', 'Before sowing crops, this implement breaks the surface crust of the ground, burying weeds and bringing fresh nutrients to the top.'),
('PBB000182', 'PAL0210', 'You usually find this little sewn-in bag on your jeans or jacket, perfect for holding small items like keys or coins.', 'A small fabric pouch attached to garments, designed to securely hold portable everyday objects while you walk around.', 'A recessed cavity integrated into the structure of apparel, functioning as a concealed storage compartment for personal belongings.'),
('PBB000183', 'PAL0211', 'This is a very common brown or red root vegetable that people often mash, bake, or cut into long sticks and fry.', 'A starchy underground crop originating in the Andes, which became a dietary staple across Europe after being brought from the Americas.', 'Botanically a tuber rather than a root, this agricultural commodity is propagated by planting pieces of the previous harvest rather than seeds.'),
('PBB000184', 'PAL0212', 'To choose one option because you like it more than another thing.', 'To hold a stronger liking for a specific choice compared to other available alternatives.', 'To place a particular option in a higher priority or favor based on personal inclination.'),
('PBB000185', 'PAL0213', 'The son of a king or queen who lives in a palace.', 'A male ruler of a small country or a high-ranking nobleman in a monarchy.', 'In traditional fairy tales, this title often belongs to the young man who rescues the main character.'),
('PBB000186', 'PAL0214', 'A secure building with locked cells where people who break the law are sent to stay as a penalty.', 'An official correctional facility operated by the government to detain lawbreakers away from society.', 'A heavily guarded institution designed to restrict personal freedom and rehabilitate individuals convicted of serious offenses.'),
('PBB000187', 'PAL0215', 'This word describes something that is right, correct, or the best choice for a specific situation.', 'You use this adjective when following the socially accepted rules or good manners of a particular group or culture.', 'Often contrasted with casual or informal, this term refers to what is strictly accurate, formal, or fits established standards.'),
('PBB000188', 'PAL0216', 'Tested and found to be true or real.', 'Demonstrated by facts or evidence to work successfully.', 'Established beyond doubt through repeated testing or past performance.'),
('PBB000189', 'PAL0217', 'To follow something or someone in order to catch, reach, or get it.', 'To work hard over a long period to achieve a goal, dream, or career.', 'To chase after an opportunity or objective with steady effort and determination.'),
('PBB000190', 'PAL0218', 'A popular computer language often used for beginners because it is easy to read and write.', 'This software development tool is named after a large snake and uses clear indentation for its code structure.', 'A versatile high-level coding system widely applied in data science, artificial intelligence, and web development.'),
('PBB000191', 'PAL0219', 'To bring a past memory back into your mind.', 'An official request made by a company for customers to return a faulty product.', 'To officially order someone to return to their original place or organization.'),
('PBB000192', 'PAL0220', 'This describes something that took place only a short time before now, like yesterday or last week.', 'It is the opposite of ancient or old, often used when talking about news, events, or changes in fashion.', 'Appearing or occurring close to the present moment in time, without a long history behind it.'),
('PBB000193', 'PAL0221', 'This is what you do when you decide not to accept an offer or an invitation from a friend.', 'To express a clear unwillingness to give, do, or agree to something that someone has asked of you.', 'To formally turn down a request or proposal, standing your ground against compliance.'),
('PBB000194', 'PAL0222', 'This word means a particular government or system in power, especially one that is strict.', 'It refers to the ruling administration of a country, often associated with authoritarian control during a specific historical period.', 'A structured system of rule, management, or administrative order that dictates how a society or organization is controlled from the top.'),
('PBB000195', 'PAL0224', 'To show how two things are similar or have a connection to each other.', 'To feel that you can understand someone\'s feelings, problems, or situation because you have had a similar experience.', 'To establish a logical or emotional association between separate ideas, events, or individuals.'),
('PBB000196', 'PAL0226', 'To stay in the same place and not leave when others go away.', 'To continue being in a certain state or condition without changing.', 'What is left behind after a part has been used, taken away, or destroyed.'),
('PBB000197', 'PAL0227', 'Located a very long distance away from towns, cities, and other people.', 'Used to describe a quiet place in the countryside that is hard to reach and has few visitors.', 'Describes a possibility that is extremely unlikely to happen, or a chance that is very small.'),
('PBB000198', 'PAL0229', 'To feel angry or unhappy because someone treated you in a way that is not fair.', 'To hold onto a negative feeling toward a person who has caused you hurt or disrespect.', 'To experience a bitter sense of grievance when subjected to perceived injustice or mistreatment.'),
('PBB000199', 'PAL0230', 'To hold onto something and not lose it or let it go.', 'To continue having possession of an item, information, or a memory over time.', 'To absorb and keep holding onto a substance, or to continue employing someone\'s services.'),
('PBB000200', 'PAL0231', 'To leave your job permanently because you have reached an age where you no longer need to work.', 'To end your active career and start enjoying a relaxing lifestyle with more free time.', 'To withdraw from professional life permanently, often receiving a pension to support yourself in later years.'),
('PBB000201', 'PAL0232', 'To take away a cover or curtain so that people can see what is underneath.', 'To make a secret or hidden fact known to other people for the first time.', 'To strip away the mystery surrounding information that was previously kept confidential or out of sight.'),
('PBB000202', 'PAL0233', 'This is a regular pattern of sound in music that makes you want to tap your foot or dance.', 'It refers to a measured motion or flow characterized by regular recurrence of stressed elements.', 'A strong, regular, repeated pattern of movement or sound found in poetry, dance, and percussion.'),
('PBB000203', 'PAL0234', 'Describing something that is strong, solid, and made to last in bad weather or outdoor use.', 'Having a rough and uneven surface, or used to describe a person who is tough and able to handle hardships.', 'Characterized by stern endurance or irregular terrain, often applied to landscapes that are difficult to travel across.'),
('PBB000204', 'PAL0235', 'This word describes something that is very small in size or amount, and not as much as you actually need.', 'When food, money, or information is barely enough to get by, we might say it is inadequate or limited.', 'Often used to describe resources or details that fall short of what is required, leaving you wanting more.'),
('PBB000205', 'PAL0236', 'How you feel when you watch a very scary horror movie in the dark.', 'An emotional state where someone feels sudden danger or extreme worry.', 'Experiencing a physical reaction like a racing heart and shaking due to perceived threat.'),
('PBB000206', 'PAL0237', 'Describing a place that has beautiful mountains, rivers, or trees that are nice to look at.', 'Often used to describe a road or train trip where you can look out the window at wonderful natural views.', 'A visual adjective frequently applied to landscapes or dramatic viewpoints that make you want to take a photograph.'),
('PBB000207', 'PAL0238', 'A clever plan or design to organize something or reach a specific goal.', 'An official or large-scale proposal for how government programs, business projects, or future actions should work.', 'Sometimes used to describe a secret, tricky, or dishonest plot made by people working together.'),
('PBB000208', 'PAL0239', 'An educational institution with classrooms where teachers help young people gain knowledge and study various subjects.', 'A daily destination for pupils and teenagers where they attend academic classes, complete homework, and interact with classmates.', 'An organized environment dedicated to instruction, typically featuring a structured curriculum, grade levels, and graduation milestones.'),
('PBB000209', 'PAL0240', 'To stop moving around and finally make a quiet, comfortable home in a new town or house.', 'To finally feel calm and relaxed in a new job, school, or place after feeling nervous at first.', 'To resolve a disagreement by reaching a final decision that both people can accept.'),
('PBB000210', 'PAL0241', 'Describing something very bad, intense, or painful, like a terrible headache or bad weather.', 'Used to describe a punishment, condition, or problem that is extremely strict, harsh, or serious.', 'Marked by extreme intensity or rigorous standards, leaving little room for comfort, mercy, or flexibility.'),
('PBB000211', 'PAL0242', 'A polite helper word used to give advice, like when you tell a friend they need to study for a test.', 'Past tense of \'shall\', frequently used to express a strong recommendation, duty, or expectation.', 'A modal auxiliary employed to indicate probability or what is socially and morally proper in a given situation.'),
('PBB000212', 'PAL0243', 'This happens to your favorite cotton t-shirt if you wash it in water that is too hot.', 'To lose size, length, or volume, often when exposed to heat, water, or pressure.', 'A verb describing a reduction in physical dimensions, which can also metaphorically describe a cowardly retreat from fear.'),
('PBB000213', 'PAL0244', 'A red traffic light is a visual one of these that tells drivers to stop their cars.', 'This is any gesture, sound, or action used to send information or instructions to someone else.', 'A captain might use a flashlight to send a coded message in the dark using this kind of transmitted indicator.'),
('PBB000214', 'PAL0246', 'To keep food cooking gently in hot liquid, right before it starts to boil rapidly.', 'A cooking method where a pot stays on low heat so the liquid inside makes very small, quiet bubbles.', 'To maintain a liquid just under its boiling point to cook ingredients slowly without breaking them apart.'),
('PBB000215', 'PAL0247', 'Opposite of difficult; something that takes very little effort to do or understand.', 'Requiring no special skill or intelligence to accomplish; lacking complexity.', 'Characterized by an absence of intricate parts or confusing elements, making it straightforward.'),
('PBB000216', 'PAL0248', 'An adjective that means very little in amount, size, or degree.', 'Used to describe a change or difference that is barely noticeable because it is so small.', 'To treat someone with disrespect or ignore them by paying too little attention to their presence.'),
('PBB000217', 'PAL0249', 'This is how a desk, a mirror, or glass feels when there are no bumps or rough parts on it.', 'This describes a liquid movement or music that flows easily and nicely without any sudden stops or bad changes.', 'This can describe a process or transition that happens without any problems, difficulties, or unexpected interruptions.'),
('PBB000218', 'PAL0250', 'This is an emotion you feel when something very sad happens to you or someone you care about.', 'It is a heavy emotional pain caused by loss, disappointment, or a very difficult life situation.', 'Often expressed through tears or silence, this state of profound grief is the opposite of joy and happiness.'),
('PBB000219', 'PAL0251', 'An adjective for things related to the large country that broke apart into Russia and other nations in 1991.', 'Pertaining to the political system and history of the Union of Soviet Socialist Republics, a major global superpower during the Cold War.', 'Relating to the historic council-based governance structure that dominated Eastern Europe and central Asian territories for most of the twentieth century.'),
('PBB000220', 'PAL0252', 'An absorbent bathroom item used for washing your body or cleaning surfaces by soaking up soapy water.', 'A porous, flexible tool made of natural or synthetic material that easily drinks up liquids when pressed against them.', 'A resilient, compressible matrix characterized by cellular voids that facilitates capillary action for fluid retention.'),
('PBB000221', 'PAL0253', 'To open something wider, like a map or a blanket, and lay it flat on a surface.', 'To distribute butter, jam, or paint evenly across the surface of something else using a knife or brush.', 'To make news, information, or a disease reach a much larger group of people or cover a wider geographical region.'),
('PBB000222', 'PAL0254', 'The warm season that comes after winter, when flowers start to grow and trees get their green leaves back.', 'A period of the year marked by rising temperatures, longer daylight hours, and frequent rain showers that help plants bloom.', 'Metaphorically used to describe a sudden upward or forward movement, this term also names a coiled metal device that bounces back when released.'),
('PBB000223', 'PAL0255', 'It is a basic geometric shape that has four equal sides and four corners that look like the letter L.', 'In a city, this word often describes an open public space where people gather, usually surrounded by buildings and streets.', 'When you multiply a number by itself, mathematicians say you are raising that number to this specific power.'),
('PBB000224', 'PAL0256', 'Something that is strong, balanced, and not easily shaken or knocked over.', 'A state or condition that remains constant and reliable over time without sudden or unexpected changes.', 'Describing an emotional state of being calm and well-balanced, or a structure built securely enough to resist collapse.'),
('PBB000225', 'PAL0257', 'Your current condition or standing, like whether you are single or married on social media.', 'The official position or rank of a person within a group, organization, or society.', 'The relative social, professional, or legal standing that determines your rights and duties.'),
('PBB000226', 'PAL0258', 'Staying in the same place or position without shaking, moving, or falling over.', 'Happening in a smooth, regular way without sudden stops or changes.', 'Showing emotional control and reliability, especially when dealing with difficult situations.'),
('PBB000227', 'PAL0259', 'A small, natural body of moving water that is smaller than a river.', 'An outdoor ribbon of fresh water flowing steadily across the land towards the ocean or a lake.', 'A continuous, moving current of liquid, often used to describe both outdoor water paths and digital video broadcasts.'),
('PBB000228', 'PAL0261', 'Describing someone or something that makes people follow all the rules very carefully without any exceptions.', 'Being very firm and demanding exact obedience from others, leaving no room for mistakes or breaking the guidelines.', 'Characterized by uncompromising standards and tight control, often applied to tough teachers, bosses, or rigid laws.'),
('PBB000229', 'PAL0262', 'To hit something very hard and fast with your hand or an object.', 'When employees refuse to work in order to protest for better pay or conditions.', 'To occur suddenly in the mind, or to have a dramatic impact like a sudden disaster.'),
('PBB000230', 'PAL0263', 'Past tense of hit; what you do when you use your hand or a tool to make contact with something forcefully.', 'To experience a sudden impact, or what a match does against the side of the box to create a fire.', 'To be deeply affected by a sudden emotion, an idea, or a disaster, much like being physically hit.'),
('PBB000231', 'PAL0264', 'To give your completed homework or project to your teacher so they can grade it.', 'To present a document, proposal, or application to someone in authority for their review or decision.', 'To yield or surrender your own opinion or control to accept the power or authority of another person.'),
('PBB000232', 'PAL0266', 'To feel physical pain or sadness when something bad happens to you.', 'To go through a difficult or unpleasant experience that causes hurt or trouble.', 'To bear or endure a negative condition, hardship, or distress over a period of time.'),
('PBB000233', 'PAL0267', 'To give someone something that they need or ask for.', 'To make goods or items available for people to buy or use.', 'To fulfill a demand by furnishing a necessary resource or quantity.'),
('PBB000234', 'PAL0268', 'You use this long, very thin piece of cotton or silk with a needle to mend torn clothes or make garments.', 'This word also describes a continuous sequence of messages in an online forum or the central theme running through a complex story.', 'Derived from Old English, this noun refers to a slender filament of twisted fibers, and it can also act as a verb meaning to pass something through a tiny opening.'),
('PBB000235', 'PAL0269', 'To grow very well, be healthy, and become successful in life.', 'To make great progress and achieve success, especially when conditions around you are good.', 'To flourish and reach your highest potential, moving past just surviving to truly excel.'),
('PBB000236', 'PAL0270', 'This is the front part of your neck, located behind your chin, where food goes down when you swallow.', 'Inside the neck, this internal tube connects your mouth and nose to both your stomach and your lungs.', 'Muscular and tubular in structure, this anatomical conduit serves as a shared pathway for both the respiratory and digestive systems.'),
('PBB000237', 'PAL0271', 'You need to buy this small paper or digital pass before you can board a train or enter a cinema.', 'This official voucher gives you the right to travel on public transport, attend a concert, or visit a museum.', 'A mandatory token of admission or transit, often checked by staff or scanned at a gate to verify payment.'),
('PBB000238', 'PAL0272', 'To walk very quietly using only the front part of your feet so people cannot hear you.', 'You might move this way across a room when everyone else is sleeping and you do not want to wake them.', 'A silent method of locomotion often used by sneakers or spies to avoid making any sound with each step.'),
('PBB000239', 'PAL0274', 'This flexible pink muscle inside your mouth helps you taste your food and speak.', 'It is the primary organ of taste and plays an essential role in swallowing and forming sounds for human speech.', 'A fleshy, highly mobile appendage within the oral cavity covered in papillae and taste buds.'),
('PBB000240', 'PAL0275', 'An official written promise or deal made between two or more different countries.', 'When governments want to end a war or trade peacefully, they sign this formal document.', 'A binding international pact that requires nations to follow specific rules and promises they agreed upon.'),
('PBB000241', 'PAL0278', 'Having no power, skill, or time to complete a specific task or action.', 'Lacking the necessary capability or qualification to achieve a goal.', 'Deprived of the physical or mental capacity required to accomplish a given objective.'),
('PBB000242', 'PAL0279', 'This describes a situation where one person gets all the benefits and another gets nothing, which is not right or just.', 'When a game has broken rules that favor one player over everyone else, the match is considered this.', 'An adjective describing an outcome or decision that lacks impartiality and violates basic standards of justice.'),
('PBB000243', 'PAL0280', 'When separate people or groups work together as one team, they are this.', 'Describes countries or states that form a single nation or share a common purpose.', 'Representing a strong alliance where individual parts combine to create a stronger collective force.'),
('PBB000244', 'PAL0281', 'An adjective that describes something you can easily use to do a job or solve a problem.', 'Something that provides practical help or makes a task much easier to complete successfully.', 'A descriptor for an instrument or object that serves a distinct function and yields a beneficial result.'),
('PBB000245', 'PAL0282', 'This word means the maximum amount or the very highest degree of something.', 'When you try your hardest and put in all your effort, you are doing your absolute best.', 'It describes a limit that cannot be pushed any further because you have reached the absolute maximum capacity.'),
('PBB000246', 'PAL0283', 'An empty space where there is no air or matter inside.', 'This condition happens when pressure drops significantly, often used in cleaning tools to pull up dust.', 'A region devoid of matter, famously found in outer space between planets and stars.'),
('PBB000247', 'PAL0284', 'A very good personal quality or habit, like honesty or kindness.', 'An admirable moral trait that shows someone is fair, honorable, and does the right thing.', 'A positive characteristic representing high ethical standards, often considered the opposite of a flaw or vice.'),
('PBB000248', 'PAL0285', 'A very long trip that people usually take across the ocean on a large ship.', 'An extended period of travel to a distant place, traditionally associated with sailors exploring the globe.', 'A historic expedition across uncharted waters, often undertaken by explorers seeking new lands.'),
('PBB000249', 'PAL0286', 'To move around on foot in a slow and relaxed way without knowing exactly where you are going.', 'To move about an area freely with no specific destination, schedule, or objective in mind.', 'To drift off the intended path or let your footsteps take you wherever you please without a plan.'),
('PBB000250', 'PAL0287', 'This word describes having a lot of money and expensive things like big houses and cars.', 'An abundance of valuable possessions, properties, or financial resources accumulated over time.', 'A state of economic prosperity where an individual or nation possesses vast material assets beyond basic needs.'),
('PBB000251', 'PAL0288', 'Something that happens seven times a year? No, something that occurs precisely once in every seven days.', 'A periodical magazine or a television show that releases a brand new episode every seven days follows this schedule.', 'Describing an interval defined by the completion of a full cycle of seven consecutive days, often applied to routine chores or allowances.'),
('PBB000252', 'PAL0289', 'This is a measurement of how heavy an object is, often found by standing on a bathroom scale.', 'Fitness enthusiasts track this metric when trying to gain muscle or lose fat using kilograms or pounds.', 'A physical property that represents the downward force exerted on an object due to gravity.'),
('PBB000253', 'PAL0290', 'A small digital application or button on a computer or phone screen that shows useful information like the weather.', 'A generic term for a small manufactured mechanical part, device, or utility whose specific name is not important right now.', 'Often used in business and programming as a placeholder name for any unnamed gadget, gizmo, or functional software element.'),
('PBB000254', 'PAL0291', 'This is a glass opening in the wall of a house that lets you look outside and brings sunshine into the room.', 'People often look through this transparent structure to check the weather outside before leaving their homes.', 'Architects design these transparent panels into buildings to provide natural illumination and ventilation.'),
('PBB000255', 'PAL0292', 'The coldest season of the year, coming after autumn and before spring.', 'The time of year when temperatures drop significantly and trees often lose all their leaves.', 'The annual period characterized by the longest nights, shortest days, and frequently freezing precipitation in temperate regions.'),
('PBB000256', 'PAL0293', 'This is a service you open at a bank to keep your money safe and make payments.', 'It is a detailed financial history showing all the money you have put into or taken out of a business or institution.', 'To explain the reasons for something, or a formal statement given to authorities explaining financial transactions.'),
('PBB000257', 'PAL0294', 'To get what you wanted to do after working hard, like passing a difficult exam.', 'To reach a personal objective or finish a major project successfully through effort.', 'To attain a desired outcome or realization of ambition by overcoming challenges.'),
('PBB000258', 'PAL0295', 'To buy, win, or get something that now belongs to you.', 'To gain a new skill, knowledge, or possession through your own work or actions.', 'To come into possession of an asset or trait as a result of time, study, or deliberate effort.'),
('PBB000259', 'PAL0296', 'A business that owns flying vehicles to carry passengers from one city or country to another.', 'An enterprise operating scheduled flights for travelers who want to cross oceans or continents quickly.', 'A commercial corporation managing a fleet of passenger aircraft, booking tickets, and scheduling global routes.'),
('PBB000260', 'PAL0297', 'This word describes something that makes you say \'wow\' because it is so cool or wonderful.', 'An adjective used to express that an experience, performance, or result is exceptionally good and impressive.', 'Synonymous with astonishing, this term is frequently used to praise something that exceeds all normal expectations.'),
('PBB000261', 'PAL0299', 'An intense feeling of deep physical or mental pain and unhappiness.', 'Severe suffering that someone experiences after a major tragedy, loss, or heartbreak.', 'A profound state of emotional agony where a person feels completely overwhelmed by distress and sorrow.'),
('PBB000262', 'PAL0300', 'If you want a second cup of coffee because the first one was good, you might ask for this.', 'This word is used to talk about an additional item or person that is similar to the one you already have.', 'Often used before a singular noun, it indicates an extra option or replacement choice beyond the current one.'),
('PBB000263', 'PAL0301', 'Feeling nervous or worried about something that is going to happen in the future.', 'A state of mind where you cannot relax because you keep thinking about possible bad outcomes.', 'Experiencing a mix of excitement and apprehension while waiting for the result of an important event.'),
('PBB000264', 'PAL0302', 'To say yes to a plan or official idea, showing that you think it is good.', 'To give formal permission or agreement for something to happen.', 'To officially validate a proposal or decision so that it can move forward.'),
('PBB000265', 'PAL0303', 'To put things in a neat, correct, or nice order, like books on a shelf.', 'To plan, prepare, or coordinate an event, meeting, or schedule in advance.', 'To systemically coordinate elements into a specific pattern or structure for a better result.'),
('PBB000266', 'PAL0306', 'To make people or things come closer to you because they like what they see.', 'To pull something toward yourself using a special power, like a magnet with metal.', 'To capture someone\'s interest so successfully that they cannot look away.'),
('PBB000267', 'PAL0307', 'A public event where items are sold to the person who offers the highest price.', 'A process where buyers compete against each other by shouting out or raising their offers until no one wants to pay more.', 'An organized commercial gathering led by an official who bangs a small hammer to finalize the sale of each item.'),
('PBB000268', 'PAL0308', 'This describes a situation that makes you feel embarrassed, nervous, or uncomfortable.', 'It refers to a movement or social moment that lacks grace, skill, or smoothness.', 'Describing an object or a design that is difficult to hold, operate, or use comfortably.'),
('PBB000269', 'PAL0309', 'This is what you need to keep when you ride a bicycle so you do not fall over.', 'It describes a state where two or more opposing forces or weights are equal and steady.', 'A healthy lifestyle often requires this key factor between working hard and getting enough rest.'),
('PBB000270', 'PAL0310', 'Things that you think are true, even if you cannot prove them.', 'Strong personal convictions or values that guide how a person lives their life.', 'Mental acceptances of a claim or proposition as being real or valid, often shaped by culture or experience.'),
('PBB000271', 'PAL0311', 'To feel sure that something is true or that someone is telling the truth.', 'To hold an opinion or conviction about the reality of an idea or fact without needing physical proof.', 'To repose mental trust in the validity, authenticity, or existence of a concept or statement.'),
('PBB000272', 'PAL0312', 'This is the comparative form of an adjective used to describe something that covers a larger physical distance from side to side.', 'It refers to something that includes more topics, details, or options, making it less specific or limited than before.', 'Used to describe a perspective or category that is more inclusive and less restricted by narrow definitions or small boundaries.'),
('PBB000273', 'PAL0313', 'This is the past form of the action verb you use when you take something with you to a new location.', 'If you went to the store yesterday and returned home with some groceries in your bag, you have done this.', 'This past-tense verb indicates that an object or person was successfully transported from one place to the speaker\'s current location.'),
('PBB000274', 'PAL0314', 'Having the power, skill, or qualities to successfully finish a task or job.', 'Describing someone who is competent and well-prepared to handle a specific responsibility.', 'Possessing the inherent potential or proficiency required to achieve a particular outcome.'),
('PBB000275', 'PAL0315', 'An adjective that means paying close attention so you do not make mistakes or have accidents.', 'Describing someone who thinks about potential risks before acting, ensuring they do not break things or get hurt.', 'A disposition characterized by vigilance and thoroughness, often shown when handling fragile items or dangerous tasks.'),
('PBB000276', 'PAL0316', 'Feeling completely sure and positive that something is true.', 'Used to describe a fact or event that is definitely going to happen or is known to be true.', 'Firmly convinced in one\'s mind, leaving no room for any doubt or hesitation.'),
('PBB000277', 'PAL0317', 'A movable piece of personal property that you own, such as furniture or livestock, but not land or buildings.', 'An old-fashioned legal term for personal possessions or movable goods, distinct from real estate.', 'Historically used in legal contexts to describe any tangible movable asset that can be bought, sold, or legally possessed.'),
('PBB000278', 'PAL0318', 'An illness or problem that lasts for a very long time and is hard to cure.', 'Used to describe a bad situation or habit that happens over and over again for months or years.', 'Opposite of temporary, this adjective refers to deeply rooted, persistent issues that resist standard solutions.'),
('PBB000279', 'PAL0319', 'An official member of a specific nation who usually carries a passport from that country.', 'Someone who has legal rights, duties, and protections within a particular town or country.', 'An individual recognized by the state as owing allegiance in exchange for political and social privileges.'),
('PBB000280', 'PAL0320', 'This word describes something that is traditional, very popular for a long time, and never goes out of style, like a favorite old song or movie.', 'It refers to a standard design or style that represents the best quality of a certain period and is widely accepted as a permanent model.', 'Used to denote a benchmark work of art or literature that has enduring significance and serves as an exemplary standard in its field.'),
('PBB000281', 'PAL0321', 'How you feel when you sit in a very soft armchair after a long, tiring day.', 'A pleasant feeling of physical relaxation or emotional relief from stress and pain.', 'A state of freedom from worry or hardship that provides a cozy and secure environment.'),
('PBB000282', 'PAL0322', 'This is a commercial business or corporation where people work together to make and sell products.', 'A legal entity formed by a group of individuals to engage in and operate a commercial enterprise.', 'A collective commercial establishment that coordinates labor and capital to supply the public with marketable provisions.'),
('PBB000283', 'PAL0323', 'To look at two things and find out how they are the same or different.', 'To analyze multiple items side by side in order to discover their similarities and differences.', 'To evaluate relationships between various subjects by measuring their relative qualities or characteristics.'),
('PBB000284', 'PAL0324', 'To take part in a race or game where everyone wants to be the winner.', 'To strive against others to achieve a goal, secure a prize, or gain superiority in a contest.', 'To engage in a rivalry where parties match their skills or resources to outperform opponents.'),
('PBB000285', 'PAL0325', 'The opposite of simple; something that has many different parts and is hard to understand.', 'A situation or machine that is difficult to figure out because too many things are happening at the same time.', 'A structural network of interconnected elements where finding a single solution requires deep analysis.'),
('PBB000286', 'PAL0326', 'This is a noun or verb that describes a feeling of worry, anxiety, or interest about a specific problem or situation.', 'It refers to a matter that is important to you, or the uneasy sensation you get when thinking about a potential trouble.', 'To have a direct bearing or personal relevance to someone, often evoking a sense of responsibility or guarded attention.'),
('PBB000287', 'PAL0327', 'To say that something you heard or planned is definitely true, correct, or happening.', 'To remove all doubt about a reservation, appointment, or piece of news by making it official.', 'To validate a previous suspicion or provide final evidence that supports a belief.'),
('PBB000288', 'PAL0328', 'To attach two different things together so they are touching or combined.', 'To establish a relationship, communication, or physical path between separate places or devices.', 'To bridge a gap or create a meaningful association between abstract concepts, ideas, or transport routes.'),
('PBB000289', 'PAL0329', 'To say \'yes\' and allow someone to do something.', 'Official approval or agreement given before an action happens.', 'Voluntarily granting authorization for a specific plan or procedure to take place.'),
('PBB000290', 'PAL0330', 'This is what a box does when it holds things like toys or clothes inside it.', 'To keep something physically inside a specific space or limit, such as water in a bottle.', 'To control or hold back a strong emotion like anger or excitement so it does not show.'),
('PBB000291', 'PAL0331', 'To have the power to make decisions about how something is run or organized.', 'To successfully restrain, regulate, or influence the behavior of someone or something.', 'To maintain dominant authority and direction over a system, operation, or machine.'),
('PBB000292', 'PAL0332', 'This is what you say when something has no mistakes and is right.', 'To make something right, or to fix a mistake you have made.', 'To adjust a measurement or device so that it gives an accurate result.'),
('PBB000293', 'PAL0333', 'A large land with its own borders, flag, and government, such as France, Japan, or Brazil.', 'An independent sovereign state with a distinct population, culture, and political system.', 'A geopolitical territory recognized internationally, operating under a unified sovereign administration.'),
('PBB000294', 'PAL0334', 'This is the mental strength to keep going when you are afraid or facing a hard situation.', 'A positive quality of being brave, allowing someone to deal with dangerous or painful moments without running away.', 'Often contrasted with cowardice, this internal trait empowers individuals to conquer their deepest anxieties and trials.'),
('PBB000295', 'PAL0335', 'This is how you feel when you want to ask many questions because you are interested in something new.', 'An adjective describing someone who investigates or explores because they desire to learn new information.', 'Showing an eager interest in discovering secrets, details, or things that are usually hidden from view.'),
('PBB000296', 'PAL0336', 'This word describes things that are happening right now, in this exact period, rather than in the past or future.', 'When you read the news online or in a newspaper, you are usually looking at information about events that are relevant today.', 'This adjective can also describe the steady, continuous flow of electricity through a wire or water moving in a specific direction.'),
('PBB000297', 'PAL0338', 'It is a soft bag filled with feathers or foam that you put on a sofa or bed to make it more comfortable.', 'You often place this textile item on chairs or benches to make sitting for a long time less tiring.', 'Beyond its domestic use for comfort, this term metaphorically describes anything that lessens the impact of a financial loss or difficult situation.'),
('PBB000298', 'PAL0339', 'Good manners and polite behavior that show respect in a social situation.', 'Acting in a way that is considered correct, formal, and acceptable by society.', 'A sense of style, proper conduct, and restraint expected during formal public events.'),
('PBB000299', 'PAL0340', 'To earn something through good actions or hard work, like getting a reward for helping.', 'To have the right to a specific reaction, treatment, or outcome because of your behavior.', 'To be a fitting and justifiable recipient of a particular consequence, whether positive or negative.'),
('PBB000300', 'PAL0342', 'To ruin something completely so it is broken forever and cannot be fixed or used again.', 'To pull down or break a building or object into pieces so that it ceases to exist in its original form.', 'To cause the complete ruin or downfall of a structure, plan, or system, making restoration impossible.'),
('PBB000301', 'PAL0343', 'To get bigger, better, or more advanced over time, like a plant growing from a small seed.', 'To slowly create or improve a skill, idea, or product through careful planning and practice.', 'To cause a situation, plot, or relationship to gradually expand and become more complex or complete.'),
('PBB000302', 'PAL0344', 'To talk together with someone about a specific topic and share your opinions.', 'To hold a conversation with others to examine different viewpoints before making a decision.', 'To formally exchange thoughts and arguments on a subject in order to reach a conclusion.'),
('PBB000303', 'PAL0345', 'A sickness or health problem that makes your body feel bad and stop working normally.', 'A harmful condition affecting the body or mind, often caused by infections or unhealthy habits.', 'A medical disorder with specific symptoms that disrupts regular biological functions and requires treatment.'),
('PBB000304', 'PAL0346', 'This is the strong negative feeling you get when you smell something very bad or see something nasty.', 'It describes the sudden reaction of intense revulsion or nausea caused by something completely unpleasant.', 'A visceral emotional state characterized by profound aversion, moral rejection, or physical repugnance.'),
('PBB000305', 'PAL0347', 'To feel that you do not like a certain food, activity, or person.', 'To have a negative feeling towards something because it makes you feel uncomfortable or annoyed.', 'To hold a personal aversion or lack of affection for an object, situation, or individual.'),
('PBB000306', 'PAL0348', 'The action of controlling a car, bus, or truck to make it travel down a road.', 'Being behind the wheel to guide a motorized transport from one location to another.', 'Actively managing the controls and direction of a self-propelled vehicle while in motion.'),
('PBB000307', 'PAL0349', 'This compass direction is opposite to the west, where the sun comes up in the morning.', 'It is an adjective used to describe countries, cultures, or regions located in the orient part of the world.', 'This term often refers to the hemisphere traditionally associated with ancient philosophies, spices, and rising populations.'),
('PBB000308', 'PAL0350', 'This word describes how a country makes, spends, and manages its money, business, and trade.', 'It refers to the large network of workers, companies, and governments that buy and sell products.', 'A term for the overall financial health of a nation, measured by things like jobs, prices, and growth.'),
('PBB000309', 'PAL0352', 'To make something better, nicer, or more useful than it was before.', 'To add quality, value, or beauty to an object, skill, or situation.', 'To raise a specific quality or performance to a higher degree of success or effectiveness.'),
('PBB000310', 'PAL0353', 'To catch an animal or person in a trap so they cannot escape.', 'To involve someone in a difficult situation or bad plan from which it is hard to get away.', 'To catch someone or something in a hidden net or device, making escape impossible.'),
('PBB000311', 'PAL0354', 'These are special proteins in your body that speed up important chemical changes to keep you alive and healthy.', 'Often called biological catalysts, these molecules make natural processes occur much faster without being used up themselves.', 'Acting as cellular facilitators, these complex macromolecules lower the activation energy required for vital metabolic pathways.');
INSERT INTO `pista_boss_battle` (`codigo`, `palabra`, `pista_facil`, `pista_intermedia`, `pista_dificil`) VALUES
('PBB000312', 'PAL0355', 'This is the time of day when the sun goes down and people usually eat their dinner.', 'It is the transition period that comes right after the afternoon and just before it becomes fully dark outside.', 'Astronomically beginning at sunset, this daily phase often signals the end of the traditional workday and the beginning of leisure hours.'),
('PBB000313', 'PAL0356', 'To look at something very closely to see how it works or if there is a problem.', 'A doctor does this to a patient, or a teacher does this to a test to check the answers.', 'To inspect a situation, object, or document in detail before making a decision or finding the truth.'),
('PBB000314', 'PAL0357', 'How you feel when something great is about to happen, like your birthday or a fun trip.', 'A state of high energy and eager anticipation because you are looking forward to an upcoming event.', 'Experiencing a surge of positive arousal and psychological activation driven by strong anticipation or joy.'),
('PBB000315', 'PAL0358', 'To put something in a museum or art gallery so that people can look at it.', 'To make an object, skill, or feeling clearly visible to an audience.', 'To publicly demonstrate a particular quality, behavior, or physical item.'),
('PBB000316', 'PAL0359', 'To give details so that someone can understand a topic or problem much better.', 'To describe how something works or why it happens using simple words and reasons.', 'To translate complex information into a simpler form so that others can easily follow the meaning.'),
('PBB000317', 'PAL0360', 'To travel to new places to see what is there.', 'To examine a subject or idea very carefully to learn more about it.', 'To venture into unknown territory for the purpose of discovery.'),
('PBB000318', 'PAL0361', 'To say or show what you think, feel, or want using words or your face.', 'To make your thoughts or emotions known to others through speaking, writing, or art.', 'To externalize an internal concept or sentiment so that it is clearly understood by an audience.'),
('PBB000319', 'PAL0362', 'This is one of the light, soft growths that cover a bird\'s body and help it fly.', 'Birds use these specialized skin growths to keep themselves warm, dry, and able to soar through the air.', 'Historically used in writing instruments and to stuff sleeping cushions, this delicate avian appendage grows in various colors and patterns.'),
('PBB000320', 'PAL0363', 'A noticeable part or quality that something has, like a camera on a smartphone.', 'A special function or prominent element designed into a product, website, or service.', 'A distinct attribute that sets an item apart, often highlighted in advertisements to show its value.'),
('PBB000321', 'PAL0364', 'What you experience inside when you are happy, sad, or angry.', 'A personal reaction or awareness that comes from your heart or mind rather than pure logic.', 'An internal psychological and physical response to an event, person, or situation.'),
('PBB000322', 'PAL0365', 'An informal word for a man, boy, or someone who shares your interests and activities.', 'Someone who belongs to the same professional group, university society, or shares your exact circumstances.', 'A scholar or researcher who receives special funding to study at an academic institution.'),
('PBB000323', 'PAL0366', 'Books and stories about people and places that are not real, like Harry Potter or Spider-Man.', 'A type of literature where authors use their imagination to create unreal characters and plots instead of sharing facts.', 'Narrative works born entirely from the author\'s creativity, distinct from biographies, history, and academic textbooks.'),
('PBB000324', 'PAL0367', 'Something that comes from another nation, not your own country.', 'An adjective used to describe languages, foods, or customs from outside your homeland.', 'Describing an unfamiliar environment, strange customs, or external elements not native to a specific place.'),
('PBB000325', 'PAL0369', 'This is the opposite of backward; it describes moving in the direction you are facing.', 'You use this directional word when you want to make a video play at a faster speed or move to the next part.', 'This term can describe someone who is confident and bold in their social behavior, or an action that promotes progress and advancement.'),
('PBB000326', 'PAL0370', 'This is a person who is not enslaved and answers to no boss or employer.', 'Historically, this describes someone who enjoys full civil rights and is not owned by a master.', 'A compound noun formed by combining a common adjective meaning independent with a title for a man.'),
('PBB000327', 'PAL0371', 'Describes a dry material, like a old cookie or dry soil, that crumbles easily into small pieces when you touch it.', 'Often used in cooking or gardening to describe something that breaks apart into powder or tiny flakes without much pressure.', 'A physical property of matter indicating that an object lacks toughness and will readily fracture or disintegrate under stress.'),
('PBB000328', 'PAL0372', 'Something that is truly what it seems to be, rather than being fake or a copy.', 'Describing a person who is trustworthy, truthful, and acts with a sincere heart.', 'Authentic and completely free from any artificial disguise, deception, or pretense.'),
('PBB000329', 'PAL0373', 'When people get along well together without fighting or arguing, they live in this pleasant state.', 'This noun describes a situation where different groups or ideas fit together nicely without any conflict.', 'Musically it means notes sounding good together, but socially it refers to a balanced and calm coexistence.'),
('PBB000330', 'PAL0374', 'This word describes a person who eats good food, exercises regularly, and rarely gets sick.', 'It refers to someone who is in a very good physical condition and has a strong immune system.', 'A term for a lifestyle or a body that functions properly, free from disease or weakness.'),
('PBB000331', 'PAL0375', 'This is one of your five physical senses, which allows you to perceive sounds with your ears.', 'This term describes the biological process that lets humans and animals detect noises, music, and spoken words.', 'This is the faculty of perceiving acoustic vibrations, often tested during routine medical checkups to ensure optimal sensory function.'),
('PBB000332', 'PAL0376', 'Describing someone who gives their time to assist you with tasks or makes your day easier.', 'An adjective for a person who frequently offers support, or an object that provides practical benefits.', 'Characterized by a cooperative attitude and a readiness to contribute to the success of others.'),
('PBB000333', 'PAL0377', 'A very wide public road where cars and buses travel quickly over long distances between towns.', 'A major paved route designed for fast-moving traffic, usually featuring multiple lanes and few traffic lights.', 'An arterial transportation corridor engineered for high-speed vehicular transit, linking major urban centers.'),
('PBB000334', 'PAL0378', 'The school subject that teaches you about old times, famous kings, wars, and things that happened long ago.', 'A continuous record of past events connected with a particular country, subject, or person.', 'The collective narrative of human existence, documenting how society, culture, and nations evolved over the centuries.'),
('PBB000335', 'PAL0379', 'This is a span of days away from your job or classes when you can relax, stay home, or go on a trip.', 'People often look forward to this time of year to escape their usual routines, visit new cities, or spend quality time with family.', 'A scheduled temporary cessation of daily professional or academic duties, frequently associated with leisure and tourism.'),
('PBB000336', 'PAL0381', 'This is a state when your body feels bad and you need to stay in bed.', 'A condition that stops your body or mind from working normally, often causing symptoms like a fever or cough.', 'A physical or mental disturbance that disrupts normal bodily functions and requires medical recovery time.'),
('PBB000337', 'PAL0382', 'To make people feel very positive about something you did well, like a great performance.', 'To create a strong, good opinion of yourself in someone else\'s mind through your actions or skills.', 'To leave a powerful, positive mental mark on an observer by displaying exceptional ability or character.'),
('PBB000338', 'PAL0383', 'To make something better or more useful than it was before.', 'To develop your skills or raise the quality of a situation over time.', 'To upgrade a condition or performance so that it reaches a higher standard.'),
('PBB000339', 'PAL0385', 'To have something inside as a part of a larger group or list.', 'To make someone or something part of a larger activity, situation, or total amount.', 'To enclose or embrace within a specific boundary, making it an essential component of the whole.'),
('PBB000340', 'PAL0386', 'This word describes something that happens right at the start or first part of an action or process.', 'Often used as an adjective to describe the very first letter of a person\'s name.', 'Serving as the foundational or opening phase before any further steps or developments take place.'),
('PBB000341', 'PAL0387', 'To set up a new computer program or piece of equipment so that it is ready to use.', 'To officially place a piece of machinery or software into its proper location and make it operational.', 'To integrate hardware or applications into a network or device to prepare them for functioning.'),
('PBB000342', 'PAL0388', 'To make someone take part in an activity, a game, or a conversation.', 'To have something as a necessary part or result of a situation or plan.', 'To connect or entangle someone deeply in a complicated situation or problem.'),
('PBB000343', 'PAL0389', 'This word describes doing something together with another person as a team.', 'It is an adverb used when two or more people share the responsibility or work on a project at the same time.', 'Describing an action performed by multiple parties in collaboration rather than individually.'),
('PBB000344', 'PAL0390', 'An act of traveling from one location to another, often taking a long time.', 'The process of getting from your starting point to a distant destination.', 'A passage of time or distance experienced while moving toward a final goal.'),
('PBB000345', 'PAL0391', 'To give a good reason for an action or decision to show it is right.', 'To explain why something is necessary or fair when people question your choice.', 'To provide evidence or a valid argument supporting the correctness of a disputed claim.'),
('PBB000346', 'PAL0392', 'This is a large country or territory that is ruled by a royal leader, usually a monarch like a king or queen.', 'In biology, this term describes the highest major category into which living things are classified, such as animals or plants.', 'Historically, this word refers to a realm where a specific sovereign holds supreme power and authority over the land and its people.'),
('PBB000347', 'PAL0393', 'This is a room in a house where people use a stove and a fridge to make meals every day.', 'You can find a sink, counters, and various utensils in this domestic space dedicated to cooking and storing ingredients.', 'A domestic area where raw elements undergo culinary transformation through heating, chopping, and mixing before consumption.'),
('PBB000348', 'PAL0394', 'This describes someone or something that is in the front position, showing the way for others to follow.', 'When a person or team is in first place during a competition, they are said to be in this position.', 'This term refers to being the main or most important element in a group, or having a superior status over others.'),
('PBB000349', 'PAL0395', 'This is a durable material made from animal skin, commonly used to make jackets, shoes, and bags.', 'To create this flexible and tough substance, the raw hide of an animal goes through a chemical process called tanning.', 'Often associated with heavy-duty motorcycle gear or classic furniture upholstery, this organic hide product resists water and wear over time.'),
('PBB000350', 'PAL0397', 'This person is the boss who tells workers what to do and helps run an office or store.', 'A professional in charge of planning daily operations, solving problems, and leading a team.', 'Someone who coordinates resources and guides staff to make sure a company reaches its goals.'),
('PBB000351', 'PAL0398', 'An adjective that means extremely big or heavy, like an elephant or a mountain.', 'Used to describe something of considerable scale, size, or degree that dominates its surroundings.', 'A synonym for colossal or immense, often applied to abstract concepts like a failure or a undertaking of great significance.'),
('PBB000352', 'PAL0399', 'This is the highest possible number or limit you can reach, like the top speed of a car.', 'You use this word to describe the upper limit of something, such as capacity or temperature, beyond which it cannot go.', 'Antonym of minimum, this noun represents the peak limit or upper bound of a scale or measurement.'),
('PBB000353', 'PAL0400', 'To use a ruler, scale, or tape to check how long, heavy, or big an object is.', 'To calculate the exact quantity, dimensions, or capacity of something using standard units like meters or kilograms.', 'To evaluate or assess the magnitude, extent, or proportions of a physical property or abstract quality.'),
('PBB000354', 'PAL0401', 'This is a green or brown plant that grows in the ocean or on the beach.', 'Marine organisms belonging to this algae group often wash up on sandy shores after a storm.', 'Underwater photosynthetic flora lacking true roots, stems, or leaves, serving as a vital habitat for coastal marine life.'),
('PBB000355', 'PAL0403', 'This is a medical professional who assists mothers during pregnancy and childbirth.', 'A trained healthcare specialist whose main job is to deliver babies and support women in labor.', 'Historically, this traditional birth attendant provides essential care and clinical guidance to expectant mothers before and after delivery.'),
('PBB000356', 'PAL0404', 'This is the lowest possible number or limit of something you can have.', 'You need to reach this required bottom boundary or baseline to qualify for the job.', 'Opposite of maximum, it represents the least possible degree or quantity allowed.'),
('PBB000357', 'PAL0406', 'This word describes something that happens twelve times a year, exactly once in every thirty or thirty-on-day period.', 'If you receive a magazine or pay a regular bill precisely every four weeks, you might describe that schedule using this adjective.', 'A recurring temporal adjective often used to classify regular subscriptions, recurring financial statements, or periodic reports issued throughout the calendar year.'),
('PBB000358', 'PAL0407', 'To fail to care for someone or something properly.', 'To ignore something or not give it the attention and time it needs.', 'To abandon duties or responsibilities through carelessness or indifference.'),
('PBB000359', 'PAL0408', 'Choose this when you want zero options out of two choices, meaning a negative result for both.', 'A conjunction used to show that two negative statements are both true, often paired with the word \'nor\'.', 'A dual-exclusion pronoun used to indicate complete absence of selection between a pair of alternatives.'),
('PBB000360', 'PAL0409', 'How you might feel right before giving a big presentation in front of the whole class.', 'Feeling uneasy, tense, or slightly scared because you are waiting for an important event to happen.', 'Experiencing a state of heightened anxiety and physical restlessness, often accompanied by butterflies in your stomach.'),
('PBB000361', 'PAL0411', 'The opposite of everywhere; a location that does not exist.', 'If you cannot find your keys in your room, the bag, or the car, they might be in this non-existent location.', 'An adverb describing a complete absence of a destination or physical space.'),
('PBB000362', 'PAL0412', 'To look at something very carefully to see what is happening.', 'To monitor a situation or behavior over a period of time without interfering.', 'To comply with a rule, law, or traditional custom during a ceremony or daily routine.'),
('PBB000363', 'PAL0413', 'This describes something that is very clear and easy for everyone to see or understand right away.', 'It refers to a fact or situation that requires no special effort to notice because it stands out plainly.', 'A descriptor for a conclusion or detail so transparently apparent that further explanation feels completely unnecessary.'),
('PBB000364', 'PAL0415', 'This is the open area under the sky, not inside a building or a house.', 'You are here when you step through the front door and leave a room or a vehicle.', 'This word describes the external surface or the space away from the interior of a structure.'),
('PBB000365', 'PAL0416', 'This word means from one end to the other, or when you look at everything together as a single group.', 'Used to describe a result or situation when you take all the different parts and details into account.', 'A general evaluation that summarizes a complex situation by focusing on the complete picture rather than specific details.'),
('PBB000366', 'PAL0417', 'What you do when you stop your car and turn off the engine to leave it in a specific spot for a while.', 'Finding a vacant space on the street or in a large lot to temporarily store your automobile while you go inside a building.', 'The process of positioning an automobile in a designated slot, often requiring you to maneuver backward between two other vehicles.'),
('PBB000367', 'PAL0419', 'Someone who stays calm and does not get angry when they have to wait a long time.', 'This adjective describes a person who can handle frustrating delays and problems without complaining.', 'Possessing the emotional endurance to tolerate tedious delays and obstacles with a tranquil mindset.'),
('PBB000368', 'PAL0420', 'This word means having very little of something, or not having enough to meet a need.', 'It is a formal noun used when a supply or quantity is much smaller than what is required or expected.', 'Often used in academic writing to describe an insufficient supply, this term highlights a scarce presence or severe shortage.'),
('PBB000369', 'PAL0421', 'This is the money you give to a shop assistant when you buy something.', 'An amount of money transferred from a customer to a business to settle a bill or debt.', 'The fulfillment of a financial obligation or the act of giving funds to clear an invoice.'),
('PBB000370', 'PAL0422', 'This describes something that has no mistakes and is completely correct.', 'When an item or situation has reached its highest possible standard and cannot be improved any further.', 'Representing an absolute state of excellence where absolutely no flaws, errors, or defects can be found.'),
('PBB000371', 'PAL0423', 'To complete an action, duty, or job that you were asked to do.', 'To present a song, play, or dance in front of an audience to entertain people.', 'To function or operate in a specific way, often describing how well a machine or a person works under pressure.'),
('PBB000372', 'PAL0424', 'This is the smallest single sound in a spoken language that can make a difference in the meaning of a word, like the difference between \'cat\' and \'bat\'.', 'In linguistics, this term describes the basic building blocks of speech sounds that native speakers recognize as distinct units within their language.', 'Linguists analyze spoken languages by identifying these abstract sound categories, proving their distinct status when swapping one for another changes a word\'s definition.'),
('PBB000373', 'PAL0425', 'To have something as your property or to own it.', 'To hold or keep something in your control, such as a physical item or a specific quality.', 'To exert control, influence, or ownership over an object, ability, or characteristic.'),
('PBB000374', 'PAL0426', 'It describes something that feels soft and is covered in very tiny, dry bits like flour or dust.', 'This adjective is often used to describe the texture of fine makeup, old chalk, or dry soil that easily crumbles.', 'Derived from a noun meaning a dry, fine substance, this quality is often found on the surface of certain ripe fruits or crushed minerals.'),
('PBB000375', 'PAL0427', 'To make something or yourself ready for an upcoming event, test, or task.', 'To organize materials, arrange a space, or study beforehand so you can successfully complete a future activity.', 'To lay the necessary groundwork or proactively assemble resources ahead of time to face an anticipated challenge.'),
('PBB000376', 'PAL0428', 'To act like something is real, even though you know it is just a game or a story.', 'To behave in a way that makes other people believe something untrue for fun or to deceive.', 'To adopt a false appearance or simulate a condition to create a misleading impression.'),
('PBB000377', 'PAL0429', 'To keep something bad from happening before it starts.', 'To take action ahead of time so that an unwanted event does not occur.', 'To successfully block or intercept a potential situation from becoming a reality.'),
('PBB000378', 'PAL0430', 'To move forward and keep doing something after you have stopped.', 'To start or continue an action, plan, or task after making a pause.', 'To advance in a course of action without letting obstacles stop you.'),
('PBB000379', 'PAL0431', 'A set of steps you follow in order to do or make something, like cooking a meal.', 'A natural or artificial series of changes that happen over a period of time to achieve a specific result.', 'A continuous progression of operations or development that transforms raw inputs into a finished product.'),
('PBB000380', 'PAL0432', 'To make or build something so that people can use it or buy it.', 'To cause a particular result or bring something into existence, often through manufacturing or growing.', 'To yield or generate goods, materials, or creative work as a result of effort or natural processes.'),
('PBB000381', 'PAL0433', 'When you tell someone \'I will definitely do this for you,\' you make one of these.', 'A verbal commitment or assurance that you will certainly complete a future task.', 'An official guarantee of your future actions that builds trust between people.'),
('PBB000382', 'PAL0434', 'To officially ask someone to marry you, or to put forward a plan for others to discuss.', 'To introduce a new plan, theory, or intention during a meeting so people can think about it.', 'To formally submit a recommendation or motion for official consideration and approval.'),
('PBB000383', 'PAL0435', 'The main goal or reason why you decide to do a specific action or project.', 'The underlying intention that guides a person\'s plans, decisions, and daily actions.', 'The driving resolution or motivating objective behind a deliberate choice.'),
('PBB000384', 'PAL0436', 'To pass a test or finish a stage so you can move on to the next round or official competition.', 'To officially have the right, skills, or papers to do a specific job or take part in an event.', 'To modify a statement by making it less absolute, or to officially become eligible for a role.'),
('PBB000385', 'PAL0437', 'This word describes how good or bad an item is when you buy it.', 'It refers to the standard of something, like whether a product will last a long time or break quickly.', 'A key characteristic or feature that makes a person or object special and different from others.'),
('PBB000386', 'PAL0438', 'If you divide a cake or a pizza into four equal pieces, each single piece is called this.', 'This word also describes a standard coin in the United States worth twenty-five cents, or twenty-five percent of a dollar.', 'In many professional team sports, like American football or basketball, a game is officially divided into four separate periods known by this term.'),
('PBB000387', 'PAL0439', 'This is a form of public transportation where metal cars travel on long iron tracks.', 'Passengers buy tickets at stations to board these heavy vehicles for long-distance travel between cities.', 'A dedicated transportation network utilizing parallel steel bars to guide heavy locomotives across the country.'),
('PBB000388', 'PAL0440', 'The action of looking at books, newspapers, or magazines to understand the words inside them.', 'A common hobby and essential study skill where your eyes follow printed text to take in information and ideas.', 'A cognitive process of decoding symbols on a page to interpret meaning, often done quietly for pleasure or information.'),
('PBB000389', 'PAL0441', 'To finally understand a situation clearly after not knowing about it before.', 'To suddenly have a clear mental picture or full comprehension of a fact or truth.', 'To make something you have been dreaming or planning actually happen in the physical world.'),
('PBB000390', 'PAL0442', 'A piece of paper or digital note the store gives you after you pay for your items.', 'You need to show this document to the cashier if you want to return an item you bought.', 'A formal acknowledgement verifying that goods, money, or services have officially changed hands.'),
('PBB000391', 'PAL0443', 'To take something that someone hands or sends to you.', 'To be the person who accepts a delivery, a present, or a message.', 'To experience or undergo an action directed toward you by an outside source.'),
('PBB000392', 'PAL0445', 'To make a physical pain or a heavy worry go away or become much better.', 'To provide comfort or assistance when someone is going through a difficult or stressful situation.', 'To take someone\'s place on duty, or to lessen the burden of a challenge so it becomes manageable.'),
('PBB000393', 'PAL0446', 'To take out an old or broken item and put a new one in its spot.', 'To use a different person or object to fulfill the same function or role.', 'To act as a substitute when the original is lost, damaged, or no longer available.'),
('PBB000394', 'PAL0447', 'To say nicely that you want something from someone.', 'To formally or politely ask someone to give or do something for you.', 'An official application or call for action directed to an authority figure.'),
('PBB000395', 'PAL0448', 'To must have something because it is necessary or very important for you.', 'To make it obligatory for someone to do a particular action according to a rule or law.', 'To demand or call for a specific condition to be met in order to achieve a successful result.'),
('PBB000396', 'PAL0449', 'The action of hurting someone back because they did something bad to you first.', 'An emotional reaction where you want to make someone suffer for a wrong they committed against you.', 'A calculated retributive act driven by bitterness to settle a personal grievance.'),
('PBB000397', 'PAL0450', 'This is a fixed schedule or set of actions that you do every day, like brushing your teeth before bed.', 'It refers to a habitual series of steps or movements that you perform regularly without needing to think much about them.', 'A structured sequence of activities or performances, such as a comedian\'s comedic act or a gymnast\'s floor exercise.'),
('PBB000398', 'PAL0451', 'To give someone what they want or need so they feel happy and pleased.', 'To meet the exact requirements, conditions, or expectations of a rule or a person.', 'To fulfill a desire, demand, or need to the point where nothing more is missing.'),
('PBB000399', 'PAL0453', 'A school subject where you learn about plants, animals, and chemistry by doing fun experiments in a lab.', 'The organized process of discovering how the physical universe works through careful testing and factual evidence.', 'A systematic enterprise that builds and organizes knowledge in the form of testable explanations and predictions about nature.'),
('PBB000400', 'PAL0454', 'The opposite of joking or playing; when someone has a very quiet and thoughtful face.', 'Used to describe a situation, problem, or illness that is dangerous or needs a lot of careful attention.', 'A personality trait describing someone who takes their work, responsibilities, and rules extremely to heart without laughing much.'),
('PBB000401', 'PAL0455', 'Someone who is paid to do household chores or help take care of a large house and its owners.', 'An individual whose job is to perform duties, tasks, or labor for a specific household or employer.', 'A domestic worker who is employed within someone else\'s residence to provide personal assistance and support.'),
('PBB000402', 'PAL0456', 'A large group of human beings living together in an organized community with shared laws and traditions.', 'The collective structure of individuals interacting daily, forming institutions, governments, and shared cultural norms.', 'A complex network of social relations and shared institutions that connects human populations across generations.'),
('PBB000403', 'PAL0457', 'This word means in a way that is not known or explained yet.', 'You use this adverb when you achieve a goal, but you are not sure exactly how you did it.', 'Expresses that a method or reason is unclear, though the final result actually happened.'),
('PBB000404', 'PAL0458', 'To give exact details about something instead of speaking in a general way.', 'To clearly mention a particular item, time, or instruction so there is no confusion.', 'To formally demand or set exact requirements that must be followed without any doubt.'),
('PBB000405', 'PAL0459', 'A place where people wait to get on or off a train.', 'A public transportation stop equipped with platforms where rail vehicles regularly pick up and drop off travelers.', 'A designated terminal facility along a railway line that serves as a hub for boarding passengers and managing rail traffic.'),
('PBB000406', 'PAL0460', 'This is the body part inside you that processes the food and drink you consume every day.', 'An internal organ located in your upper abdomen that uses acids to break down meals before they move further.', 'Often referred to colloquially as your belly or tummy, this muscular sac contracts to mix ingested nutrients with gastric juices.'),
('PBB000407', 'PAL0461', 'Not normal or familiar; something that makes you feel a little confused because you have never seen it before.', 'Bizarre or peculiar; describing an event or behavior that does not follow the usual rules and is hard to explain.', 'A synonym for eccentric or uncanny, referring to phenomena that defy standard expectations and provoke curiosity or doubt.'),
('PBB000408', 'PAL0462', 'To pull something so that it becomes longer or wider without breaking.', 'What you do to your arms and legs to warm up your muscles before doing sports.', 'To continue a word, sound, or activity over a longer period than usual.'),
('PBB000409', 'PAL0463', 'This is a main topic or lesson that you study in school, like math, history, or science.', 'This refers to the principal theme or main idea of a conversation, book, or piece of art.', 'In academic research or discussion, this represents the central focus or area of inquiry explored by experts.'),
('PBB000410', 'PAL0464', 'To achieve a good result in a test, a game, or a job.', 'To reach a goal or finish something the way you wanted to.', 'To follow someone else in a role, position, or title after they leave.'),
('PBB000411', 'PAL0465', 'To tell a friend your plan for what to do this weekend, like saying, \"Let\'s go to the cinema!\"', 'To put a thought or a possible plan into someone\'s mind for them to think about.', 'To formally propose a theory or course of action without stating it as an absolute fact.'),
('PBB000412', 'PAL0466', 'To give help, money, or comfort to someone when they need it.', 'To hold the weight of something so it does not fall down.', 'To provide evidence or facts that prove a theory or idea is true.'),
('PBB000413', 'PAL0467', 'To imagine or guess that something might be true, even if you do not know for sure.', 'To form a theory or belief about a situation without having concrete evidence to confirm it.', 'To hypothetically grant a premise for the sake of argument or to explore a potential outcome.'),
('PBB000414', 'PAL0468', 'To stay alive after a dangerous event, a serious illness, or a very difficult situation.', 'To manage to keep going through a hard time when things could have gone very wrong.', 'To outlast challenging conditions or a catastrophe without being destroyed or defeated.'),
('PBB000415', 'PAL0469', 'This is what appears in your mind when you think of a plan or a new concept.', 'The mental process of considering something or forming an opinion in your head.', 'A product of mental activity that can lead to a decision, a belief, or a sudden inspiration.'),
('PBB000416', 'PAL0470', 'The loud booming noise you often hear in the sky right after a flash of bright light during a heavy rainstorm.', 'A powerful acoustic shockwave produced in the atmosphere when superheated air expands rapidly around a bolt of electricity.', 'A natural atmospheric phenomenon characterized by a deep rumbling frequency that physically vibrates buildings and startles wildlife.'),
('PBB000417', 'PAL0471', 'A very big success or winning a major competition.', 'The feeling of great joy and pride after finally achieving a difficult goal.', 'A historic military or sporting conquest that is celebrated by the entire nation.'),
('PBB000418', 'PAL0472', 'This is a negative situation when things go wrong and you need to find a solution.', 'You experience this when you face an unexpected challenge or worry that causes you stress.', 'An undesirable state of affairs characterized by complication, distress, or unfavorable circumstances.'),
('PBB000419', 'PAL0473', 'This word describes something that happens normally or shows the usual qualities of a certain person, place, or thing.', 'It refers to a representative example that clearly shows the standard characteristics of a larger group or category.', 'Used to denote an action, behavior, or appearance that acts as a reliable benchmark for a specific era or social class.'),
('PBB000420', 'PAL0474', 'This describes something that is not normal or happens very rarely.', 'You might use this word to describe a strange event, a unique hobby, or a day that was different from your daily routine.', 'Synonymous with uncommon and bizarre, this term points to occurrences or behaviors that deviate significantly from standard expectations.'),
('PBB000421', 'PAL0476', 'A new business project or trip that might be dangerous or fail.', 'To go somewhere unknown or start a risky project.', 'To bravely step into a situation where the final result is uncertain.'),
('PBB000422', 'PAL0477', 'Describing an action that uses strong physical power to cause injury, pain, or damage to a person or property.', 'An adjective often used to describe intense storms, aggressive behavior, or sudden, uncontrolled outbursts of anger.', 'Marked by great emotional or physical intensity, often resulting in severe harm or destruction without peaceful resolution.'),
('PBB000423', 'PAL0478', 'You can see something with your own eyes when it is this.', 'An adjective used to describe objects or details that stand out clearly against a background.', 'Describing a state or quality where an object is not hidden from view, allowing light to reflect off it into an observer\'s eyes.'),
('PBB000424', 'PAL0479', 'It tells you if it is sunny, rainy, cold, or hot outside today.', 'This daily outside condition includes things like temperature, wind, and rain in a specific area.', 'Meteorologists study the atmospheric phenomena of a specific region to forecast these short-term outdoor changes.'),
('PBB000425', 'PAL0480', 'This is the opposite of eastern; it describes the part of the world that includes Europe and the Americas.', 'It refers to a famous genre of American movies featuring cowboys, horses, and life in the old frontier.', 'This geographical adjective often represents industrialized democratic nations historically contrasted with the East during the Cold War.'),
('PBB000426', 'PAL0481', 'A sharp, musical sound you make by pushing air through your pursed lips.', 'Referees use this small metal or plastic device in their mouths to stop a sports game with a loud sound.', 'To produce a clear, high-pitched tone through a narrow opening, often done to catch someone\'s attention from a distance.'),
('PBB000427', 'PAL0482', 'Having a positive attitude to help out or do a task when someone asks you.', 'Feeling prepared, agreeable, and not hesitant to take on a new responsibility or activity.', 'Demonstrating a voluntary and cooperative mindset, showing no reluctance to participate.'),
('PBB000428', 'PAL0483', 'This is what you do with a pen, pencil, or keyboard to put your thoughts onto paper or a screen.', 'Students do this often in class to take notes, create essays, or complete homework assignments.', 'This essential communication skill transforms spoken language and abstract ideas into a permanent visual record.'),
('PBB000429', 'PAL0484', 'This means hitting the target right in the center without making any mistakes.', 'It is the noun form of an adjective that describes information, measurements, or answers that are totally right and free from errors.', 'In fields like science, mathematics, and translation, professionals strive for this high standard to ensure their data and results can be completely trusted.'),
('PBB000430', 'PAL0485', 'This describes something that has zero errors or mistakes, just like a math answer that is completely right.', 'When you measure something carefully so that the numbers or details match reality without any mistakes, your work is this.', 'A synonym for precise and exact, often used to describe information or data that you can completely trust.'),
('PBB000431', 'PAL0488', 'An adjective that means having unlimited power or being able to do everything.', 'Often used to describe a supreme religious being who controls the entire universe.', 'Derived from combining two common words meaning complete and strong, describing absolute authority.'),
('PBB000432', 'PAL0489', 'To officially share important news or information with a large group of people.', 'To make a formal statement to the public, often using a microphone or the media.', 'To broadcast a decision, arrival, or upcoming event so everyone becomes aware of it.'),
('PBB000433', 'PAL0490', 'To put oil on someone\'s body in a special church ceremony.', 'To be officially chosen for a holy or very important role by having oil put on your head.', 'Describing a person who has been specially selected or blessed using sacred liquids during a ritual.'),
('PBB000434', 'PAL0492', 'You can find this extra information section at the very back of a textbook or novel.', 'This word refers to supplementary material in a publication, but it is also the name of a tiny pouch-like organ attached to your large intestine.', 'Derived from a Latin word meaning \'hanging on,\' this term describes both a detachable textual addendum and a vestigial anatomical feature prone to inflammation.'),
('PBB000435', 'PAL0493', 'To walk or move closer to someone or something.', 'A particular method or strategy used for solving a problem or doing a task.', 'An oncoming movement toward a destination, or the preliminary steps taken to tackle a complex situation.'),
('PBB000436', 'PAL0494', 'When someone says \'yes\' or claps to show they like your new idea, they are giving you this positive reaction.', 'This noun means having a good opinion of something or giving official permission for a plan to go ahead.', 'A formal validation or favorable judgment that transforms an uncertain proposal into an authorized project.'),
('PBB000437', 'PAL0495', 'A verbal fight or discussion where two people have different opinions and are angry.', 'A series of logical statements used by a writer or speaker to prove a point.', 'The main plot or storyline of a book, movie, or play.'),
('PBB000438', 'PAL0496', 'To make someone feel very surprised because something unexpected happened.', 'To fill someone with sudden great wonder or amazement by an unbelievable event.', 'To stagger the mind of an observer through an occurrence that defies normal expectations.'),
('PBB000439', 'PAL0497', 'This is a type of male singing voice that is lower than a tenor but higher than a bass.', 'In a choir, a man with this vocal range usually sings parts that are right in the middle, between the very high and very low sections.', 'Musically positioned between the highest male singing type and the deepest foundation voice, this term also describes a brass instrument pitched below the trumpet.');

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
('PROF008', 'Jesus Omar', 'Castañon', 'Castañon', 'jesus.omar@beemail.com', 'pbkdf2_sha256$1200000$Owf8PsggPZyjpT0bxhBwZf$d47sDvCtAmPx9PSxC21MKgH8JP5D44LxGPykwTQaq58=', '656 160 08', 'TUSR02', '2026-11-13 17:33:29.636503', 0, 0, 1),
('USR0001', 'Renata', 'Ortega', 'Rivera', '2026100001@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$M9YE6JOiovSuKX6zWo1WgI$PPetslg2nVkT8qQN2myV1BHcJhcLEuONpXSD4SYA7Co=', '6641002001', 'TUSR01', '2026-11-15 21:45:12.477750', 0, 0, 1),
('USR0002', 'Emilio', 'Delgado', 'Duran', '2026100002@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$5bLyeSQH8d2MWVJb3AA2bi$dQbCTRzYW4y3ei3Ek2SsljzDvbve9MvSNqFodzM5+Nk=', '6641002002', 'TUSR01', '2026-11-13 19:40:11.359405', 0, 0, 1),
('USR0003', 'Ximena', 'Rojas', 'Pineda', '2026100003@ut-tijuana.edu.mx', '$2b$12$W5h8K2pLm9Qx7Vb3Nc4RdO6tYu1Ei8Fa0Gs2Hj5Kl7Mn9Pq4Rs6Tu', '6641002003', 'TUSR01', NULL, 0, 0, 1),
('USR0004', 'Adrian', 'Mendoza', 'Contreras', '2026100004@ut-tijuana.edu.mx', '$2b$12$A7cD9eF2gH4jK6mN8pQ1rS3tV5xY7zB0cE2fG4hJ6kL8mN0pQ2rS', '6641002004', 'TUSR01', NULL, 0, 0, 1),
('USR0005', 'Camila', 'Aguilar', 'Bravo', '2026100005@ut-tijuana.edu.mx', '$2b$12$Z8xC6vB4nM2aS0dF9gH7jK5lP3qW1eR8tY6uI4oP2aS9dF7gH5j', '6641002005', 'TUSR01', NULL, 0, 0, 1),
('USR0006', 'Oscar', 'Silva', 'Chavez', '2026100006@ut-tijuana.edu.mx', '$2b$12$Q4wE6rT8yU0iO2pA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR4tY6u', '6641002006', 'TUSR01', NULL, 0, 0, 1),
('USR0007', 'Brenda', 'Campos', 'Luna', '2026100007@ut-tijuana.edu.mx', '$2b$12$H3jK5lP7qW9eR1tY3uI5oA7sD9fG1hJ3kL5zX7cV9bN1mM3qW5eR', '6641002007', 'TUSR01', NULL, 0, 0, 1),
('USR0008', 'Sergio', 'Vargas', 'Robles', '2026100008@ut-tijuana.edu.mx', '$2b$12$M6nB8vC0xZ2aS4dF6gH8jK0lP2qW4eR6tY8uI0oA2sD4fG6hJ8k', '6641002008', 'TUSR01', NULL, 0, 0, 1),
('USR0009', 'Melissa', 'Pena', 'Cano', '2026100009@ut-tijuana.edu.mx', '$2b$12$R9tY7uI5oP3aS1dF9gH7jK5lP3qW1eR9tY7uI5oP3aS1dF9gH7jK', '6641002009', 'TUSR01', NULL, 0, 0, 1),
('USR0010', 'Gabriel', 'Rios', 'Solis', '2026100010@ut-tijuana.edu.mx', '$2b$12$B2vN4mM6qW8eR0tY2uI4oA6sD8fG0hJ2kL4zX6cV8bN0mM2qW4eR', '6641002010', 'TUSR01', NULL, 0, 0, 1),
('USR0011', 'Eric', 'Aycardo', 'Balcázar', '2026100011@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$bpfFZFsoHODn0FSWLhqUxT$8rp24MyGX2+7CsoLeP2V9wZYSn7I7hHofYsfYwu2fgw=', '6641470369', 'TUSR01', '2026-11-13 19:40:43.818123', 0, 0, 1),
('USR0012', 'Blanca', 'Roman', 'Ortiz', 'blanca.roman@beemail.com', 'pbkdf2_sha256$1200000$2qSYaAmBmD2VZ50KFCYwim$upxlGL8Gy2k76IQAKlK8UNF0v5Z/LKhmDvf8sjbRcao=', '6641002012', 'TUSR02', '2026-11-13 18:31:41.500971', 0, 0, 1),
('USR0013', 'Isaac', 'Salvatierra', 'Anguilo', 'isaac.salvatierra@beemail.com', 'pbkdf2_sha256$1200000$ygsdp65f7LYJHDSxT7OrYr$zd81zvi5kgVY6aR7VEgplAzhxhKnfB6C+NtgPzzfoTw=', '6641002013', 'TUSR02', '2026-10-27 18:27:18.842050', 0, 0, 1),
('USR0014', 'Ariana Lizeth', 'González', 'Osuna', 'ariana.gonzales@beemail.com', 'pbkdf2_sha256$1200000$aPnBu8VkAVZRwSizqeMRyd$6ewjFI2ev2qCdQgsS/CacYGhnygiEDN+c2J9SX6opi4=', '6641002014', 'TUSR02', '2026-11-13 17:25:13.423615', 0, 0, 1),
('USR0015', 'Juan Pablo', 'Quiñones', 'Hernández', 'juan.quinones@beemail.com', 'pbkdf2_sha256$1200000$t6m7P3OTailywgZBJ8x4oL$V0ltFjEAa1dUKGvksP4MR2DcOGpu07BtGUZFCq55zJA=', '6641002015', 'TUSR02', '2026-10-20 18:37:09.908310', 0, 0, 1),
('USR0016', 'Jesus Omar', 'Castañon', 'Castañon', 'omar.castanon@beemail.com', '$2b$12$V0bN2mM4qW6eR8tY0uI2oA4sD6fG8hJ0kL2zX4cV6bN8mM0qW2eR', '6645114953', 'TUSR03', NULL, 0, 0, 1),
('USR0017', 'Josue Alberto', 'Villegas', 'Hernández', 'josue.villegas@beemail.com', '$2b$12$G9hJ7kL5zX3cV1bN9mM7qW5eR3tY1uI9oA7sD5fG3hJ1kL9zX7cV', '6646167119', 'TUSR03', NULL, 0, 0, 1),
('USR0018', 'Diego', 'Sánchez', 'Hernández', 'diego.sanchez@beemail.com', 'pbkdf2_sha256$1200000$7YZe3qCvJ7o2T20le58KGJ$FqXP2TdTCpGX8Jxx+21ZjBmysx4CxYPaIR+xfNeiS5k=', '6633288842', 'TUSR03', '2026-11-09 17:00:14.636757', 0, 0, 1),
('USR0019', 'Dulce Aurora', 'de la Cruz', 'Enriquez', 'dulce.delacruz@beemail.com', '$2b$12$Y5uI3oA1sD9fG7hJ5kL3zX1cV9bN7mM5qW3eR1tY9uI7oA5sD3fG', '6642213487', 'TUSR03', NULL, 0, 0, 1),
('USR0020', 'Aline Aketzali', 'Lucido', 'Muñoz', 'aline.lucido@beemail.com', '$2b$12$D8fG6hJ4kL2zX0cV8bN6mM4qW2eR0tY8uI6oA4sD2fG0hJ8kL6zX', '6648199271', 'TUSR03', NULL, 0, 0, 1),
('USR0021', 'Jesus Omar', 'Castañon', 'Castañon', 'jesus.omar@spell-challenge.usa', 'pbkdf2_sha256$1200000$mnlUQcBFbNJRqTps5JzuHw$zt46DvMw3QIQ9kCvRh0h/FTnqA2q0XhjQI9MQauABW0=', '', 'TUSR02', '2026-09-11 16:32:23.762934', 1, 1, 1),
('USR0022', 'Gilda', 'Torres', 'Roman', 'gilda.torres@beemail.com', 'pbkdf2_sha256$1200000$D93qaje5jV8DOq1gc1KmTQ$8kfxz9ZNEje8dD0jV57RJa8M9De01ZpLmMzoJwaRghY=', '6643692581', 'TUSR02', '2026-11-15 22:37:55.873794', 0, 0, 1),
('USR0023', 'Leonardo', 'Valdez', 'Ivan', '2026100012@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$MLjXlOOfGinxCHTlOLGDMd$j1Z+K+rIqL2iPpxoYtrBUsapD1fl4aix6b8fKRjt+ps=', '6631593715', 'TUSR01', '2026-11-13 18:36:19.963100', 0, 0, 1),
('USR0024', 'Jesus Omar', 'Castañon', 'Castañon', '0324108155@ut-tijuana.edu.mx', 'pbkdf2_sha256$1200000$gmH0PmuwHVvRhvoKedcYaK$QijQ8M+TJwpTJP6rekD+87j6WBgwNm3mM0eWexdvmzs=', '656 160 08', 'TUSR01', '2026-11-13 18:08:03.885330', 0, 0, 1);

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
-- Indices de la tabla `pista_boss_battle`
--
ALTER TABLE `pista_boss_battle`
  ADD PRIMARY KEY (`codigo`),
  ADD UNIQUE KEY `uq_pista_boss_palabra` (`palabra`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
-- Filtros para la tabla `pista_boss_battle`
--
ALTER TABLE `pista_boss_battle`
  ADD CONSTRAINT `fk_pista_boss_palabra` FOREIGN KEY (`palabra`) REFERENCES `palabra` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

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
