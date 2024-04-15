{{ config(
 tags=['dm_sku_stocks', 'sku_stocks', 'dm'],
 target='duckdb',
 schema='dm',
 materialized='incremental',
) }}

SELECT
process_date,
offer_id,
item_name,
warehouse_name,
free_to_sell_amount,
reserved_amount
FROM {{ ref('report_stocks') }}
WHERE process_date = '{{ var("logical_date") }}'
    AND (SELECT count(1) FROM {{ this }} WHERE process_date = '{{ var("logical_date") }}') = 0
