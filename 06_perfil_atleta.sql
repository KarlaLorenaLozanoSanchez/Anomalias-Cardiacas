-- Perfil biométrico individual por atleta y deporte
SELECT
	athlete_id,
	sport,
	COUNT(*) AS total_registros,
	ROUND(AVG(heart_rate), 2) AS hr_promedio,
	ROUND(STDDEV(heart_rate), 2) AS hr_desviacion,
	ROUND(AVG(oxygen_saturation), 2) AS spo2_promedio
FROM public.monitoreo_atletas
GROUP BY athlete_id, sport
ORDER BY hr_promedio DESC;
