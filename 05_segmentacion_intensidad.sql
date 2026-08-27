-- Segmentación de frecuencia cardíaca y SpO2 por intensidad de entrenamiento
SELECT
	training_intensity,
	COUNT(*) AS total_lecturas,
	ROUND(AVG(heart_rate), 2) AS hr_promedio,
	ROUND(MIN(heart_rate), 2) AS hr_minima,
	ROUND(MAX(heart_rate), 2) AS hr_maxima,
	ROUND(AVG(oxygen_saturation), 2) AS spo2_promedio,
	ROUND(MIN(oxygen_saturation), 2) AS spo2_minima
FROM public.monitoreo_atletas
GROUP BY training_intensity
ORDER BY hr_promedio DESC;
