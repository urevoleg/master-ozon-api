{{ config(
 tags=['dm_stocks', 'stocks', 'dm'],
 schema='dm',
 materialized='table',
 post_hook=["GRANT USAGE ON SCHEMA dm TO external_user_ro",
 "GRANT SELECT ON ALL TABLES IN SCHEMA dm TO external_user_ro"],
) }}

with sat_product as (
    select h.offer_id, -- артикул
           h.product_pk,
           s.product_name
    from {{ ref('hub_products') }} h
    join {{ ref('sat_products') }} s
    on h.product_pk = s.product_pk
),
stock as (SELECT
    process_date - interval '1 day' as dated_at,
    warehouse_pk,
    product_pk,
    delivery_type,
    warehouse_name,
    sum(free_to_sell_amount) as free_to_sell_amount,
    sum(reserved_amount) as reserved_amount
    FROM {{ ref('report_stocks') }}
    group by dated_at, product_pk, delivery_type, warehouse_name, warehouse_pk)
select stock.dated_at,
       stock.warehouse_name,
       s.offer_id,
       s.product_name,
       stock.free_to_sell_amount,
       stock.reserved_amount,
       stock.warehouse_pk,
       s.product_pk
from sat_product s
join stock
using (product_pk)