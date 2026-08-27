-- Validación de volumen y calidad de datos: conteo de registros, atletas,
-- deportes distintos, y nulos por columna clave
SELECT
	COUNT(*) AS total_registros,
	COUNT(DISTINCT athlete_id) AS atletas,
	COUNT(DISTINCT sport) AS total_deportes,
	COUNT(*) - COUNT(heart_rate) AS nulos_heart_rate,
	COUNT(*) - COUNT(oxygen_saturation) AS nulos_spo2,
	COUNT(*) - COUNT(muscle_activity) AS nulos_muscle_activity,
	COUNT(*) - COUNT(training_intensity) AS nulos_intensidad
FROM public.monitoreo_atletas;
