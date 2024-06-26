{{ config(
 tags=['raw_products', 'products', 'raw'],
 schema='raw',
 materialized='table',
) }}

SELECT
product_id,
p.offer_id,
is_fbo_visible,
is_fbs_visible,
archived,
p.is_discounted,
id,
product_name,
barcode,
CASE WHEN buybox_price = '' THEN NULL ELSE buybox_price::numeric END as buybox_price,
category_id,
created_at,
images,
CASE WHEN marketing_price = '' THEN 0::numeric ELSE marketing_price::numeric END as marketing_price,
CASE WHEN min_ozon_price = '' THEN 0::numeric ELSE min_ozon_price::numeric END as min_ozon_price,
CASE WHEN old_price = '' THEN 0::numeric ELSE old_price::numeric END as old_price,
CASE WHEN premium_price = '' THEN 0::numeric ELSE premium_price::numeric END as premium_price,
CASE WHEN price = '' THEN 0::numeric ELSE price::numeric END as price,
CASE WHEN recommended_price = '' THEN 0::numeric ELSE recommended_price::numeric END as recommended_price,
CASE WHEN min_price = '' THEN 0::numeric ELSE min_price::numeric END as min_price,
sources,
stocks,
cast(stocks as json) as stocks_json_obj,
errors,
vat,
visible,
visibility_details,
CASE WHEN price_index = '' THEN 0::numeric ELSE price_index::numeric END as price_index,
commissions,
cast(commissions as json) as commissions_json_obj,
volume_weight,
is_prepayment,
is_prepayment_allowed,
images360,
color_image,
primary_image,
status,
state,
service_type,
CASE WHEN fbo_sku = 0 THEN sku ELSE fbo_sku END AS fbo_sku,
CASE WHEN fbs_sku = 0 THEN sku ELSE fbs_sku END AS fbs_sku,
currency_code,
is_kgt,
discounted_stocks,
has_discounted_item,
barcodes,
updated_at,
price_indexes,
sku,
description_category_id,
type_id,
p.effective_dttm
FROM {{ source('external_data', 'raw_products_list') }} p
JOIN {{ source('external_data', 'raw_products_extended') }} pe
USING (offer_id)
