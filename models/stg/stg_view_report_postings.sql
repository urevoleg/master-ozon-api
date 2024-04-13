{{ config(
 tags=['stg_view_report_postings', 'view_report_postings', 'stg_report_postings', 'report_postings', 'stg'],
 target='duckdb',
 schema='stg',
 materialized='view',
) }}

SELECT
hub.product_pk,
r.order_id,
r.posting_id,
r.processed_at,
r.shipped_at,
r.status,
r.delivered_at,
r.posting_cost,
r.money_code_out,
r.item_name,
r.marketing_price,
r.currency_code,
r.amount,
r.delivery_cost,
r.linked_postings,
r.repurchase_of_goods,
r.old_price,
r.discount,
r.discount_money,
r.promotions,
r.delivery_type
FROM {{ ref('hub_products') }} hub
JOIN {{ ref('raw_report_postings') }} r
USING (offer_id)
