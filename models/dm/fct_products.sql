{{ config(
 tags=['dm_fct_products', 'fct_products', 'dm'],
 schema='dm',
 materialized='table',
) }}

with rp as (select process_date - interval '1 day' as dated_at,
                   product_pk,
                   min(category_comission) as category_comission,
                   min(fbo_free_to_sell_amount) as fbo_free_to_sell_amount,
                   min(fbs_free_to_sell_amount) as fbs_free_to_sell_amount,
                   min(rfbs_free_to_sell_amount) as rfbs_free_to_sell_amount
            from {{ref('report_products')}}
            group by dated_at, product_pk),
rep as (select
                 coalesce(po.dated_at, prr.dated_at, rp.dated_at) as dated_at,
                 COALESCE(po.product_pk, prr.product_pk) as product_pk,
                 COALESCE(po.offer_id, prr.offer_id) as offer_id,
                 coalesce(po.barcode, prr.barcode) as barcode,
                 coalesce(po.product_name, prr.product_name) as product_name,
                 coalesce(po.orders, 0) as orders,
                 coalesce(po.total_cost, 0) as total_cost,
                 coalesce(prr.redumptions, 0) as redumptions,
                 coalesce(prr.accruals_for_sale, 0) as accruals_for_sale,
                 coalesce(prr.sum_price, 0) as sum_price,
                 coalesce(rp.category_comission, NULL) as category_comission,
                 coalesce(rp.fbs_free_to_sell_amount, 0) as fbs_free_to_sell_amount,
                 coalesce(rp.rfbs_free_to_sell_amount, 0) as rfbs_free_to_sell_amount,
                 coalesce(rp.fbo_free_to_sell_amount, 0) as fbo_free_to_sell_amount
        from {{ref('product_orders')}} po
        full join {{ref('product_redumptions_and_returns')}} prr
        using (dated_at, product_pk)
        left join rp
        using (dated_at, product_pk))
select rep.*,
       s.primary_image,
       coalesce(s.min_price, s.price) as current_price
from {{ref('hub_products')}} h
join {{ref('sat_products')}} s
using (product_pk)
join rep
using (product_pk)
