-- 1. Seleccionar la base de datos
USE `hospital_220859`;

-- 2. Actualización de la tabla de citas
ALTER TABLE tbb_ms_citas_medicas 
ADD COLUMN tipo_movimiento ENUM('Entrada', 'Salida') NOT NULL DEFAULT 'Entrada';

DELIMITER //

-- 3. PARCHE: Corrección de la función del equipo con error (bandera_probabilidad)
DROP FUNCTION IF EXISTS fn_genera_grupo_sanguineo //
CREATE FUNCTION fn_genera_grupo_sanguineo() RETURNS varchar(3) CHARSET utf8mb4
DETERMINISTIC
BEGIN
    DECLARE v_tipo VARCHAR(2);
    DECLARE v_rh CHAR(1);
    
    SET v_rh = IF(fn_genera_bandera_porcentaje(85), '+', '-');
    
    IF fn_genera_bandera_porcentaje(45) THEN
        SET v_tipo = 'O';
    ELSEIF fn_genera_bandera_porcentaje(64) THEN -- ERROR CORREGIDO AQUI
        SET v_tipo = 'A';
    ELSEIF fn_genera_bandera_porcentaje(43) THEN
        SET v_tipo = 'B';
    ELSE
        SET v_tipo = 'AB';
    END IF;

    RETURN CONCAT(v_tipo, v_rh);
END //

-- 4. SP para Pacientes
DROP PROCEDURE IF EXISTS sp_poblar_pacientes //
CREATE PROCEDURE sp_poblar_pacientes(vcantidad INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < vcantidad DO
        INSERT INTO tbb_hr_personas_fisicas (nombre, priner_apellido, genero, fecha_nacimineto, grupo_sanguineo)
        VALUES (
            CONCAT('Paciente_', i+1), 
            'Generado', 
            'N/B', 
            fn_genera_fecha_nacimiento('1950-01-01', '2010-01-01'), 
            fn_genera_grupo_sanguineo()
        );
        INSERT INTO tbb_md_pacientes (estatus) VALUES (1);
        SET i = i + 1;
    END WHILE;
END //

-- 5. SP para Médicos
DROP PROCEDURE IF EXISTS sp_poblar_medicos //
CREATE PROCEDURE sp_poblar_medicos(vcantidad INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < vcantidad DO
        INSERT INTO tbb_hr_personas_fisicas (nombre, priner_apellido, fecha_nacimineto)
        VALUES (CONCAT('Medico_', i+1), 'Generado', '1980-01-01');
        SET @id_persona = LAST_INSERT_ID();
        
        INSERT INTO tbb_hr_personal (personal_id, puesto, tipo_contrato, fecha_ingreso, estatus)
        VALUES (@id_persona, 'Médico de Planta', 'BASE', CURDATE(), 1);
        SET @id_personal = LAST_INSERT_ID();

        INSERT INTO tbb_hr_personal_medico (personal_id, celula_profecional, especialidad, turno)
        VALUES (@id_personal, CONCAT('CED-', FLOOR(RAND()*1000000)), 'Medicina General', 'MATUTINO');

        SET i = i + 1;
    END WHILE;
END //

-- 6. SP para Citas
DROP PROCEDURE IF EXISTS sp_poblar_citas //
CREATE PROCEDURE sp_poblar_citas(vcantidad INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_id_paciente INT;
    DECLARE v_id_medico INT;

    WHILE i < vcantidad DO
        SET v_id_paciente = (SELECT ID FROM tbb_md_pacientes ORDER BY RAND() LIMIT 1);
        SET v_id_medico = (SELECT ID FROM tbb_hr_personal_medico ORDER BY RAND() LIMIT 1);

        INSERT INTO tbb_ms_citas_medicas (id_paciente, id_personal_medico, fecha, hora, motivo, tipo_cita, estado_cita, tipo_movimiento)
        VALUES (
            v_id_paciente,
            v_id_medico,
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY), 
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

-- ==========================================
-- EJECUCIÓN AUTOMÁTICA
-- ==========================================
CALL sp_poblar_pacientes(1000);
CALL sp_poblar_medicos(50);
CALL sp_poblar_citas(3000);