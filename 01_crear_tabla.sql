-- Creación de la tabla base con los registros biométricos de los atletas
CREATE TABLE PUBLIC.monitoreo_atletas (
	Athlete_ID VARCHAR(50),
	Sport VARCHAR(50),
	Age INT,
	Gender VARCHAR(20),
	Heart_Rate NUMERIC(8,4),
	Oxygen_Saturation NUMERIC(4,1),
	Muscle_Activity NUMERIC(5,2),
	Motion_X NUMERIC(6,2),
	Motion_Y NUMERIC(6,2),
	Motion_Z NUMERIC(6,2),
	Training_Intensity VARCHAR(20),
	Injury_Risk VARCHAR(20)
);
