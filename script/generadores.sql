-- 1. Actualización de la tabla de citas
ALTER TABLE tbb_ms_citas_medicas 
ADD COLUMN tipo_movimiento ENUM('Entrada', 'Salida') NOT NULL DEFAULT 'Entrada';

DELIMITER //

-- 2. Corrección del SP del equipo para Pacientes
DROP PROCEDURE IF EXISTS sp_poblar_pacientes //
CREATE PROCEDURE sp_poblar_pacientes(vcantidad INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < vcantidad DO
        -- Insertamos los datos físicos usando las funciones del equipo
        -- Nota: Respetamos los nombres de columna del script original (priner_apellido, fecha_nacimineto)
        INSERT INTO tbb_hr_personas_fisicas (nombre, priner_apellido, genero, fecha_nacimineto, grupo_sanguineo)
        VALUES (
            CONCAT('Paciente_', i+1), 
            'Generado', 
            'N/B', 
            fn_genera_fecha_nacimiento('1950-01-01', '2010-01-01'), 
            fn_genera_grupo_sanguineo()
        );
        
        -- Insertamos el registro en la tabla de pacientes
        INSERT INTO tbb_md_pacientes (estatus) VALUES (1);
        
        SET i = i + 1;
    END WHILE;
END //

-- 3. Generación de Médicos
DROP PROCEDURE IF EXISTS sp_poblar_medicos //
CREATE PROCEDURE sp_poblar_medicos(vcantidad INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < vcantidad DO
        -- Creamos la persona física
        INSERT INTO tbb_hr_personas_fisicas (nombre, priner_apellido, fecha_nacimineto)
        VALUES (CONCAT('Medico_', i+1), 'Generado', '1980-01-01');
        SET @id_persona = LAST_INSERT_ID();
        
        -- Lo registramos como personal
        INSERT INTO tbb_hr_personal (personal_id, puesto, tipo_contrato, fecha_ingreso, estatus)
        VALUES (@id_persona, 'Médico de Planta', 'BASE', CURDATE(), 1);
        SET @id_personal = LAST_INSERT_ID();

        -- Lo registramos en la especialidad médica
        INSERT INTO tbb_hr_personal_medico (personal_id, celula_profecional, especialidad, turno)
        VALUES (@id_personal, CONCAT('CED-', FLOOR(RAND()*1000000)), 'Medicina General', 'MATUTINO');

        SET i = i + 1;
    END WHILE;
END //

-- 4. Generación de Citas
DROP PROCEDURE IF EXISTS sp_poblar_citas //
CREATE PROCEDURE sp_poblar_citas(vcantidad INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_id_paciente INT;
    DECLARE v_id_medico INT;

    WHILE i < vcantidad DO
        -- Seleccionamos de forma aleatoria IDs que SI existan en la base
        SET v_id_paciente = (SELECT ID FROM tbb_md_pacientes ORDER BY RAND() LIMIT 1);
        SET v_id_medico = (SELECT ID FROM tbb_hr_personal_medico ORDER BY RAND() LIMIT 1);

        INSERT INTO tbb_ms_citas_medicas (id_paciente, id_personal_medico, fecha, hora, motivo, tipo_cita, estado_cita, tipo_movimiento)
        VALUES (
            v_id_paciente,
            v_id_medico,
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY), -- Citas en los próximos 30 días
            '10:00:00',
            'Valoración general',
            'Consulta general',
            'Pendiente',
            IF(RAND() > 0.5, 'Entrada', 'Salida')
        );
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;