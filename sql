-- Creating table // dim_ejercicio

CREATE OR REPLACE TABLE gimnasiosbosa.OLAP_tables.dim_ejercicio AS
SELECT
  t1.id_ejercicio,
  t1.descripcion, 
  t1.tipo, 
  t1.grupo_muscular_principal, 
  t1.nivel_dificultad, 
  CASE 
  WHEN t2.nombre IS NOT NULL THEN 'requiere'
  ELSE 'no requiere'
  END requiere_maquina
FROM
  `gimnasiosbosa.gym_prototype.ejercicios` AS t1
JOIN
  gimnasiosbosa.gym_prototype.maquinas AS t2
ON
  t1.tipo = t2.tipo;

-- creating table // dim_rutina 
CREATE OR REPLACE TABLE gimnasiosbosa.OLAP_tables.dim_rutina AS
SELECT
id_rutina, 
nombre_rutina, 
objetivo, 
duracion_semanas, 
frecuencia_semanal
FROM
  `gimnasiosbosa.gym_prototype.rutinas` 

-- creating table dim_fecha 

 CREATE OR REPLACE TABLE gimnasiosbosa.OLAP_tables.dim_fechas AS
WITH fechas AS (
  SELECT
    fecha,
    FORMAT_DATE('%Y%m%d', fecha) AS id_fecha,
    EXTRACT(YEAR FROM fecha) AS year,
    EXTRACT(MONTH FROM fecha) AS mes,
    EXTRACT(DAY FROM fecha) AS dia,
    EXTRACT(WEEK FROM fecha) AS semana,
    EXTRACT(QUARTER FROM fecha) AS trimestre,
    FORMAT_DATE('%A', fecha) AS dia_semana
  FROM
    UNNEST(GENERATE_DATE_ARRAY(DATE '2025-01-01', DATE '2025-12-31', INTERVAL 1 DAY)) AS fecha
)
SELECT
  CAST(id_fecha AS INT64) AS id_fecha,
  fecha,
  year,
  mes,
  dia,
  semana,
  trimestre,
  dia_semana
FROM fechas;

-- creating table dim_maquina 
CREATE OR REPLACE TABLE gimnasiosbosa.OLAP_tables.dim_maquinas AS
SELECT
  t1.id_maquina,
  t1.nombre, 
  t1.tipo, 
  t1.musculo_objetivo
FROM
  `gimnasiosbosa.gym_prototype.maquinas` AS t1

-- creating table hechos_entrenamiento 

CREATE OR REPLACE TABLE gimnasiosbosa.OLAP_tables.hechos_entrenamiento (
  id_hecho INT64,                    
  id_persona STRING,                 
  id_fecha INT64,                   
  id_ejercicio STRING,               
  id_rutina STRING,                  
  series INT64,
  repeticiones INT64,
  peso_estimado FLOAT64,
  tiempo_descanso_seg INT64,
  duracion_minutos FLOAT64
);


WITH normalize_order_ticket AS (
SELECT
  t.*,
  normalized_order
FROM
  `WELD_ANALYTICS.refund_request_tickets` AS t,
  UNNEST(REGEXP_EXTRACT_ALL(order_number, r'#E\d+|E\d+|#SB\d+|SB\d+|#T\d+|T\d+')) AS extracted_order
LEFT JOIN (
  SELECT
    extracted_order AS original_extracted_order,
    CASE
      WHEN STARTS_WITH(LOWER(extracted_order), '#e') THEN extracted_order
      WHEN STARTS_WITH(LOWER(extracted_order), 'e') THEN CONCAT('#', extracted_order)
      WHEN STARTS_WITH(LOWER(extracted_order), '#sb') THEN extracted_order
      WHEN STARTS_WITH(LOWER(extracted_order), 'sb') THEN CONCAT('#', extracted_order)
      WHEN STARTS_WITH(LOWER(extracted_order), '#t') THEN SUBSTR(extracted_order, 2)
      WHEN STARTS_WITH(LOWER(extracted_order), 't') THEN extracted_order
      ELSE NULL
    END AS normalized_order
  FROM
    `WELD_ANALYTICS.refund_request_tickets`,
    UNNEST(REGEXP_EXTRACT_ALL(order_number, r'#E\d+|E\d+|#SB\d+|SB\d+|#T\d+|T\d+')) AS extracted_order
) AS normalized_orders
ON extracted_order = original_extracted_order
), 
refunds AS (
  SELECT order_number, refund_value_euro, refund_id, refund_date, refund_type, note, department,team, store 
  FROM activaciones-holafly.WELD_ANALYTICS.clients_team__refunded_orders_experience_team
), 
refund_and_tickets AS (
SELECT tc.ticket_id,tc.created_at AS ticket_created_at, tc.updated_at AS ticket_updated_at, tc.state AS ticket_state, tc.team AS refunds_team,tc.category, tc.linked_chat_id, rf.order_number, rf.refund_value_euro, rf.refund_id, rf.refund_date, 
rf.refund_type, rf.note, rf.department, rf.team, rf.store
FROM normalize_order_ticket tc
LEFT JOIN refunds rf
ON tc.normalized_order = rf.order_number
), 
incidences AS (
  SELECT *, 
  CASE  
  WHEN clean_order_number LIKE '#T%' THEN REPLACE(clean_order_number, '#T', 'T')
  ELSE clean_order_number 
  END c_order_number
  FROM activaciones-holafly.WELD_ANALYTICS.clients_team__general_incidents_chats
), 
deduplicate AS (
SELECT ic.* EXCEPT(clean_order_number), tc.*, ROW_NUMBER() OVER(PARTITION BY ic.chat_id ORDER BY created_at ASC) AS rw
FROM incidences  ic
LEFT JOIN refund_and_tickets tc
ON tc.order_number = ic.clean_order_number
), 
pre_final AS (
SELECT 
dd.*, 
ord.total_price AS Total_sold, 
TIMESTAMP_DIFF(refund_date, ticket_created_at, HOUR) AS diff_refund, 
TIMESTAMP_DIFF(dd.ticket_created_at,TIMESTAMP(dd.created_at), HOUR) AS diff_chat_request, 
TIMESTAMP_DIFF(refund_date,TIMESTAMP(dd.created_at), HOUR) AS diff_refund 
FROM deduplicate dd
LEFT JOIN activaciones-holafly.WELD_RAW.shopify__order ord  
ON dd.c_order_number = ord.name
WHERE rw = 1
)
SELECT * EXCEPT(rw)
FROM pre_final
