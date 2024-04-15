{{ config(
 tags=['stg_view_report_stocks', 'view_report_stocks', 'stg_report_stocks', 'report_stocks', 'stg'],
 target='duckdb',
 schema='stg',
 materialized='view',
) }}

SELECT
hub.product_pk,
r.warehouse_pk,
r.offer_id,
r.delivery_type,
r.warehouse_name,
r.item_name,
r.free_to_sell_amount,
r.reserved_amount
FROM {{ ref('hub_products') }} hub
JOIN {{ ref('raw_report_stocks') }} r
USING (offer_id)
