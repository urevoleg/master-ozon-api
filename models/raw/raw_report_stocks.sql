{{ config(
 tags=['raw_report_stocks', 'report_stocks', 'stocks', 'raw'],
 schema='raw',
 materialized='table',
) }}

WITH raw AS (SELECT
--"Идентификатор склада" AS warehouse_id,
"Название склада" AS warehouse_name,
"Артикул" AS offer_id,
"Наименование товара" item_name,
"Доступно на моем складе, шт" AS free_to_sell_amount,
"Зарезервировано на моем складе, шт" as reserved_amount,
'fbs' AS delivery_type
FROM {{ source('external_data', 'raw_report_stocks_fbs') }}
UNION ALL
SELECT
--sku,
warehouse_name::varchar,
item_code AS offer_id,
item_name,
--promised_amount,
free_to_sell_amount,
reserved_amount,
'fbo' AS delivery_type
FROM {{ source('external_data', 'raw_report_stocks_fbo') }})
SELECT *
FROM raw