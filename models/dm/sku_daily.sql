{{ config(
 tags=['dm_sku_daily', 'sku_daily', 'dm'],
 target='duckdb',
 schema='dm',
 materialized='incremental',
incremental_strategy='delete+insert',
unique_key=['process_date', 'product_pk']
) }}

WITH
p AS (SELECT * FROM ods.products WHERE process_date = '{{ var("logical_date") }}'),
rp AS (SELECT * FROM ods.report_products WHERE process_date = '{{ var("logical_date") }}'),
    main as (
        select
            rp.process_date,
            hp.product_pk,
            hp.offer_id,
            hp.barcode,
            pe.name,
            rp.category_comission,
            pe.primary_image,
            rp.price,
            rp.fbo_free_to_sell_amount,
            rp.fbs_free_to_sell_amount,
            rp.rfbs_free_to_sell_amount
        from ods.hub_products hp
        join rp using (product_pk)
        join p pe using (product_pk)
    ),
    o as (
        SELECT product_pk ,
		sum(amount) AS orders,
		sum(posting_cost) AS revenue
		FROM ods.report_postings
		WHERE process_date = '{{ var("logical_date") }}'
		GROUP BY product_pk
    ),
    current_price AS (
    	SELECT p.product_pk,
    	       price AS current_price
    	FROM p
    ),
    repurchase as (
     SELECT now()
    )
select
m.process_date,
m.product_pk,
m.offer_id,
m.barcode,
m.name,
m.category_comission,
m.primary_image,
m.price,
m.fbo_free_to_sell_amount,
m.fbs_free_to_sell_amount,
m.rfbs_free_to_sell_amount,
o.orders,
-1 AS repurchase_amount,
-1 AS repurchase_sum,
p.current_price,
CURRENT_DATE - date_trunc('month', CURRENT_DATE) AS days_from_start_of_month
from main m
join o using (product_pk)
join current_price p using(product_pk)
