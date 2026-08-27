-- Carga del dataset original (CSV) a la tabla base
-- Nota: ajusta la ruta al archivo CSV a tu entorno local antes de ejecutar
COPY PUBLIC.monitoreo_atletas
FROM 'ruta/al/archivo/athlete_physiological_dataset.csv'
DELIMITER ',' CSV HEADER;

-- Verificación rápida de la carga
SELECT * FROM monitoreo_atletas;
