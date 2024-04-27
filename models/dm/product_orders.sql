{{ config(
 tags=['dm_product_orders', 'product_rproduct_orders', 'dm'],
 schema='dm',
 materialized='table',
) }}

with rep as (select (processed_at + interval '3 hour')::date as dated_at,
       product_pk,
       count(1) as orders,
       sum(posting_cost) as total_cost
from {{ref('report_postings')}}
group by 1, product_pk)
select rep.dated_at,
       h.offer_id,
       h.barcode,
       s.product_name,
       rep.orders,
       rep.total_cost,
       h.product_pk
from {{ref('hub_products')}} h
join {{ref('sat_products')}} s
using (product_pk)
join rep
using (product_pk)