{{ config(
 tags=['dm_products', 'products', 'dm'],
 schema='dm',
 materialized='table',
) }}

with sat_product as (
    select s.primary_image,
           s.product_name,
           -- категория продукта
           -- ссылка на товар
           -- бренд
           h.offer_id, -- артикул
           h.product_id, -- ozon product_id
           h.fbo_sku, -- fbo ozon sku
           h.fbs_sku, -- fbs ozon sku
           h.barcode, -- barcode
           s.price,
           h.product_pk
    from {{ref('hub_products')}} h
    join {{ref('sat_products')}} s
    on h.product_pk = s.product_pk
),
transactions as (select *
from {{ref('transaction_odm')}} t
where t.service_type = 'orders'
and t.accruals_for_sale > 0),
orders as (select cast(post.processed_at as date) as dated_at,
       l1.product_pk,
       count(post.posting_pk) as orders_amount,
       count(tr.transaction_pk) as transactions_amount,
       sum(tr.accruals_for_sale) as accruals_for_sale,
       round(1.0 * count(tr.transaction_pk) / count(post.posting_pk), 2) as repurchase
from {{ref('posting_odm')}} post
left join {{ ref('link_postings_products') }} l1
    on post.posting_pk = l1.posting_pk
left join transactions tr
    on post.posting_pk = tr.posting_pk
group by 1, 2
order by 1, 2)
select o.dated_at,
       s.product_pk,
       s.primary_image,
       s.product_name,
       p.category_comission,    -- категория продукта
        -- ссылка на товар
       p.brand,-- бренд
       s.offer_id, -- артикул
       s.product_id, -- ozon product_id
       s.fbo_sku, -- fbo ozon sku
       s.fbs_sku, -- fbs ozon sku
       s.barcode, -- barcode
       s.price, -- текущая цена
       price.price as current_price,
       p.fbo_free_to_sell_amount,
       p.fbs_free_to_sell_amount,
       p.rfbs_free_to_sell_amount,
       p.reserved_amount,
       p.seller_reserved_amount,
       o.orders_amount,
       o.transactions_amount,
       o.accruals_for_sale,
       o.repurchase,
       price.min_price,
       price.marketing_seller_price
from orders o
join {{ ref('report_products') }} p
on o.product_pk = p.product_pk
and o.dated_at = (p.process_date - interval '1 day')
left join {{ ref('product_prices_odm') }} price
on o.product_pk = price.product_pk
join sat_product s
on o.product_pk = s.product_pk
order by o.dated_at, o.product_pk