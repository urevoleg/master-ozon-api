{{ config(
 tags=['dm_sku_stocks', 'sku_stocks', 'dm'],
 schema='dm',
 materialized='table',
) }}

with rep as (SELECT
    process_date - interval '1 day' as dated_at,
    product_pk,
    delivery_type,
    warehouse_name,
    sum(free_to_sell_amount) as free_to_sell_amount,
    sum(reserved_amount) as reserved_amount
    FROM {{ref('report_stocks')}}
    group by dated_at, product_pk, delivery_type, warehouse_name)
select rep.dated_at,
       h.offer_id,
       h.barcode,
       s.product_name,
       rep.free_to_sell_amount,
       rep.reserved_amount,
       h.product_pk
from {{ref('hub_products')}} h
join {{ref('sat_products')}} s
using (product_pk)
join rep
using (product_pk)