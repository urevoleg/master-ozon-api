{{ config(
 tags=['dm_product_redumptions_and_returns', 'product_redumptions_and_returns', 'dm'],
 schema='dm',
 materialized='table',
) }}

with tr as (select operation_id,
                   transaction_pk,
                   operation_date as dated_at,
                   cast(json_array_elements(items::json) ->> 'sku' as bigint) as sku,
                   json_array_elements(items::json) ->> 'name'                as item_name,
                   service_type,
                   accruals_for_sale
            from {{ref('report_transactions')}} tr
            where true
              and service_type in ('orders', 'returns')),
rep as (select tr.dated_at,
       h.product_pk,
       tr.service_type, count(1) as redumptions,
       sum(tr.accruals_for_sale) as accruals_for_sale,
       sum(coalesce(s.min_price, s.price)) sum_price
from {{ref('hub_products')}} h
         join {{ref('sat_products')}} s
              using (product_pk)
         join tr
              on (h.fbs_sku = tr.sku) or (h.fbo_sku = tr.sku)
group by tr.dated_at, h.product_pk, tr.service_type)
select rep.dated_at,
       h.offer_id,
       h.barcode,
       s.product_name,
       rep.redumptions,
       rep.accruals_for_sale,
       rep.sum_price,
       h.product_pk
from {{ref('hub_products')}} h
join {{ref('sat_products')}} s
using (product_pk)
join rep
using (product_pk)