# Tablero Analítico de Telemedicina para la Detección de Anomalías Cardíacas

**Autora:** Karla Lorena Lozano Sánchez
**Stack:** PostgreSQL (SQL Engine) · Power BI Desktop (DAX & Data Viz)
**Volumen de datos:** 23,400 registros biométricos continuos

---

## Resumen Ejecutivo

Este proyecto implementa un sistema de monitoreo biométrico para atletas de diversas disciplinas, con el objetivo de **detectar oportunamente anomalías fisiológicas** —episodios de hipoxia y taquicardia basal— a partir de datos capturados por dispositivos wearables (frecuencia cardíaca, saturación de oxígeno y actividad muscular).

La lógica de clasificación de anomalías se implementó directamente en el motor de base de datos (PostgreSQL) mediante una vista SQL, garantizando que la regla de negocio sea única, auditable y reutilizable por cualquier herramienta de BI conectada — en este caso, Power BI.

### Resultados clave

| Métrica | Valor |
|---|---|
| Lecturas evaluadas | 23,400 |
| Tasa global de anomalías | 35.35% |
| Atletas con hipoxia | 233 |

---

## Arquitectura del Proyecto

```
CSV (dataset original)
   └── PostgreSQL (tabla monitoreo_atletas)
         └── Vista SQL (vista_monitoreo_anomalias) ← lógica de clasificación
               └── Power BI (conexión directa a PostgreSQL)
                     └── Medidas DAX + Dashboard
```

---

## Base de Datos (PostgreSQL)

### Estructura de la tabla base

```sql
CREATE TABLE public.monitoreo_atletas (
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
```

### Carga de datos

```sql
COPY PUBLIC.monitoreo_atletas
FROM 'ruta/al/archivo/athlete_physiological_dataset.csv'
DELIMITER ',' CSV HEADER;
```

### Validación de calidad de datos

Antes de analizar, se verificó volumen y nulos por columna:

```sql
SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT athlete_id) AS atletas,
    COUNT(DISTINCT sport) AS total_deportes,
    COUNT(*) - COUNT(heart_rate) AS nulos_heart_rate,
    COUNT(*) - COUNT(oxygen_saturation) AS nulos_spo2,
    COUNT(*) - COUNT(muscle_activity) AS nulos_muscle_activity,
    COUNT(*) - COUNT(training_intensity) AS nulos_intensidad
FROM public.monitoreo_atletas;
```

### Exploración estadística general

```sql
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
```

### Segmentación por intensidad de entrenamiento

```sql
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
```

### Perfil individual por atleta

```sql
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
```

---

## Lógica de Negocio: Vista de Anomalías

El corazón del proyecto es esta vista, que centraliza la regla clínica de clasificación directamente en la base de datos:

| Condición fisiológica | Regla SQL | Categoría asignada |
|---|---|---|
| Saturación de oxígeno < 90% | `oxygen_saturation < 90` | Anomalía Severa |
| Saturación de oxígeno 90–94% | `oxygen_saturation < 95` | Hipoxia |
| FC > 100 bpm en intensidad baja | `heart_rate > 100 AND training_intensity = 'Low'` | Taquicardia Basal |
| Sin criterios de alteración | — | Normal |

```sql
CREATE VIEW public.vista_monitoreo_anomalias AS
SELECT
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
```

> **Nota de diseño:** el orden de evaluación en el `CASE` importa — la taquicardia basal se evalúa primero porque es independiente de SpO₂, evitando que una lectura con ambas condiciones se clasifique incorrectamente solo por hipoxia.

---

## Capa Analítica: Power BI + DAX

Power BI Desktop se conectó directamente a PostgreSQL (import mode sobre la vista `vista_monitoreo_anomalias`), y se construyeron medidas en una tabla dedicada `_Medidas`:

**Tasa de Anomalías (%)**
```dax
Tasa Anomalias % =
VAR TotalRegistros = COUNT('public vista_monitoreo_anomalias'[heart_rate])
VAR RegistrosAnomalos =
    CALCULATE(
        COUNTROWS('public vista_monitoreo_anomalias'),
        'public vista_monitoreo_anomalias'[estado_salud] <> "Normal"
    )
RETURN
    DIVIDE(RegistrosAnomalos, TotalRegistros, 0)
```

**Atletas Afectados por Hipoxia**
```dax
Atletas con Hipoxia =
CALCULATE(
    DISTINCTCOUNT('public vista_monitoreo_anomalias'[athlete_id]),
    'public vista_monitoreo_anomalias'[estado_salud] IN {"Hipoxia", "Anomalía Severa"}
)
```

---

## Hallazgos Analíticos

- **Identificación de clústeres:** el scatter plot de SpO₂ vs. frecuencia cardíaca aisló claramente el grupo con episodios de hipoxia por debajo del 95% de saturación, concentrado entre 93% y 95%.
- **Consistencia entre disciplinas:** al segmentar por deporte (ej. tenis), la prevalencia de anomalías se mantiene estable cerca del 35.22%, identificando un grupo focal de 50 atletas en riesgo.
- **Tasa global:** 35.35% de las 23,400 lecturas evaluadas presentó algún tipo de anomalía, con 233 atletas distintos afectados por hipoxia.

---

## Dashboard

<img width="2075" height="1200" alt="Anomalias_Cardiacas_Todos_page-0001" src="https://github.com/user-attachments/assets/65698ee5-4ea5-47b6-a1b2-c53e3e4e923f" />
<img width="2075" height="1200" alt="Anomalias_Cardiacas_page-0002" src="https://github.com/user-attachments/assets/52438051-83ca-4a07-9182-4ad23f69bd7f" />
<img width="2075" height="1200" alt="Anomalias_Cardiacas_page-0001" src="https://github.com/user-attachments/assets/a08b1df2-575d-4661-be3f-c22ab42f13d5" />

## Alcance y Limitaciones

Este es un **proyecto educativo y de portafolio**, no un dispositivo médico certificado. Los umbrales de clasificación (SpO₂, frecuencia cardíaca) están basados en criterios fisiológicos generales y no sustituyen el criterio de un profesional de la salud.

---

## Cómo reproducirlo

1. Crea la base de datos y carga el dataset con el script en `sql/01_setup.sql`.
2. Ejecuta la vista de anomalías (`sql/02_vista_anomalias.sql`).
3. Abre `dashboard/telemedicina.pbix` en Power BI Desktop y actualiza la conexión a tu instancia de PostgreSQL.

---

## Autora

**Karla Lorena Lozano Sánchez** — Ingeniera Biónica con enfoque en análisis de datos.
[LinkedIn](https://www.linkedin.com/in/karlalorenalozanosanchez) · lorena.lozanosan27@gmail.com
