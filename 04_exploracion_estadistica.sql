-- Exploración estadística general: rangos y promedios de las variables
-- biométricas principales
SELECT
	ROUND(MIN(heart_rate), 2) AS hr_minima,
	ROUND(MAX(heart_rate), 2) AS hr_maxima,
	ROUND(AVG(heart_rate), 2) AS hr_promedio,

	ROUND(MIN(oxygen_saturation), 2) AS spo2_minima,
	ROUND(MAX(oxygen_saturation), 2) AS spo2_maxima,
	ROUND(AVG(oxygen_saturation), 2) AS spo2_promedio,

	ROUND(MIN(muscle_activity), 2) AS actividad_muscular_minima,
	ROUND(MAX(muscle_activity), 2) AS actividad_muscular_maxima,
	ROUND(AVG(muscle_activity), 2) AS actividad_muscular_promedio
FROM public.monitoreo_atletas;
