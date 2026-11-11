
-- ============================================================
-- SPELL-CHALLENGE
-- Procedimiento para registrar ejercicios y sus opciones
-- Base de datos: MariaDB 12.2.2
--
-- Autor: Proyecto Spell-Challenge
-- Descripcion:
-- Permite registrar los ejercicios de una Lesson mediante
-- un documento JSON, generando automaticamente las claves
-- de ejercicios y opciones, asi como sus relaciones.
-- ============================================================


-- Eliminamos la version anterior del procedimiento
-- si ya existe, para permitir actualizarlo posteriormente.

DROP PROCEDURE IF EXISTS sp_registrar_ejercicios_lesson;


-- Cambiamos temporalmente el delimitador para que MariaDB
-- pueda interpretar correctamente el BEGIN y END del procedimiento.

DELIMITER //


CREATE PROCEDURE sp_registrar_ejercicios_lesson(
    IN p_leccion VARCHAR(10),
    IN p_datos LONGTEXT
)

BEGIN

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


END//

-- Restauramos el delimitador original.

DELIMITER ;
