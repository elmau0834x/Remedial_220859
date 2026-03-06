# Examen Remedial - Base de Datos Hospital

**Alumno:** [Tu Nombre]
**Matrícula:** 220859

## 🎯 Puntos Evaluados y Cumplidos

- [x] **Restauración con matrícula:** La base de datos fue restaurada y renombrada a `hospital_220859`.
- [x] **Uso de funciones del equipo:** Se integraron y utilizaron las funciones de generación de fechas y grupos sanguíneos creadas por el equipo.
- [x] **Generación de 1000 pacientes:** Se implementó `sp_poblar_pacientes` insertando 1000 registros físicos y lógicos.
- [x] **Generación de 50 médicos:** Se adaptó el método del equipo creando `sp_poblar_medicos` para insertar 50 especialistas.
- [x] **Generación de 3000 citas:** Se creó `sp_poblar_citas` vinculando los IDs aleatorios de pacientes y médicos existentes.
- [x] **Control de versiones:** Todo el proceso, desde la restauración hasta la exportación final, fue documentado con Git.

## 🛠️ Correcciones Adicionales Implementadas
Durante el desarrollo se aplicaron las siguientes mejoras necesarias para el funcionamiento:
1. Se corrigió la función `fn_genera_grupo_sanguineo` del equipo original, la cual llamaba a una función inexistente (`bandera_probabilidad`).
2. Se alteró la tabla `tbb_ms_citas_medicas` para agregar la columna `tipo_movimiento` como tipo `ENUM('Entrada', 'Salida')`.

## 📋 Instrucciones de Verificación
El archivo `Examen_Final_220859.sql` contiene el volcado completo de la estructura y los datos. Una vez restaurado, se puede comprobar el cumplimiento de los registros con las siguientes consultas:

```sql
USE `hospital_220859`;
SELECT COUNT(*) AS Total_Pacientes FROM tbb_md_pacientes; -- Esperado: 1000
SELECT COUNT(*) AS Total_Medicos FROM tbb_hr_personal; -- Esperado: 50
SELECT COUNT(*) AS Total_Citas FROM tbb_ms_citas_medicas; -- Esperado: 3000