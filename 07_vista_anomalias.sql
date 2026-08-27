-- Vista central del proyecto: clasifica cada lectura biométrica según
-- reglas clínicas de negocio (hipoxia, anomalía severa, taquicardia basal)
-- Incluye reading_id único por fila, necesario para graficar cada lectura
-- individual en Power BI sin que se agregue/promedie por atleta.
CREATE VIEW public.vista_monitoreo_anomalias AS
SELECT
	ROW_NUMBER() OVER () AS reading_id,
	athlete_id,
	sport,
	training_intensity,
	heart_rate,
	oxygen_saturation,
	muscle_activity,
	CASE
		WHEN heart_rate > 100 AND training_intensity = 'Low' THEN 'Taquicardia Basal'
		WHEN oxygen_saturation < 95 THEN 'Hipoxia'
		WHEN oxygen_saturation < 90 THEN 'Anomalía Severa'
		ELSE 'Normal'
	END AS estado_salud
FROM public.monitoreo_atletas;

-- Verificación rápida de la vista
SELECT * FROM public.vista_monitoreo_anomalias LIMIT 10;
