{{ config(
 tags=['raw_product_wide', 'raw_products', 'products', 'product', 'raw'],
 schema='raw',
 materialized='table',
) }}

SELECT
p.product_id,
p.offer_id,
cast(is_fbo_visible as bool )::int4 as is_fbo_visible,
cast(is_fbs_visible as bool)::int4 as is_fbs_visible,
cast(archived as bool)::int4 as archived,
cast(p.is_discounted as bool)::int4 as is_discounted,
id,
product_name,
barcode,
CASE WHEN buybox_price = '' THEN NULL ELSE buybox_price::numeric END as buybox_price,
category_id,
created_at,
-- cast(images as json) as images_json_obj,
images,
CASE WHEN pe.marketing_price = '' THEN 0::numeric ELSE pe.marketing_price::numeric END as marketing_price,
CASE WHEN pe.min_ozon_price = '' THEN 0::numeric ELSE pe.min_ozon_price::numeric END as min_ozon_price,
CASE WHEN pe.old_price = '' THEN 0::numeric ELSE pe.old_price::numeric END as old_price,
CASE WHEN pe.premium_price = '' THEN 0::numeric ELSE pe.premium_price::numeric END as premium_price,
CASE WHEN pe.price = '' THEN 0::numeric ELSE pe.price::numeric END as price,
CASE WHEN pe.recommended_price = '' THEN 0::numeric ELSE pe.recommended_price::numeric END as recommended_price,
CASE WHEN pe.min_price = '' THEN 0::numeric ELSE pe.min_price::numeric END as min_price,
sources,
-- cast(sources as json) as sources_json_obj,
-- stocks,
cast(stocks as json) as stocks_json_obj,
errors,
-- cast(errors as json) as errors_json_obj,
pe.vat,
cast(visible as bool)::int4 as visible,
cast(visibility_details as json) as visibility_details_json_obj,
CASE WHEN pe.price_index = '' THEN 0::numeric ELSE pe.price_index::numeric END as price_index,
-- commissions,
cast(commissions as json) as commissions_json_obj,
pe.volume_weight as volume_weight,
cast(is_prepayment as bool)::int4 as is_prepayment,
cast(is_prepayment_allowed as bool)::int4 as is_prepayment_allowed,
images360,
color_image,
primary_image,
cast(status as json) as status_json_obj,
state,
service_type,
CASE WHEN fbo_sku = 0 THEN sku ELSE fbo_sku END AS fbo_sku,
CASE WHEN fbs_sku = 0 THEN sku ELSE fbs_sku END AS fbs_sku,
pe.currency_code,
cast(is_kgt as bool)::int4 as is_kgt,
cast(discounted_stocks as json) as discounted_stocks_json_obj,
cast(has_discounted_item as bool)::int4 as has_discounted_item,
cast(barcodes as json) as barcodes_json_obj,
updated_at::timestamp as effective_dttm,
updated_at::timestamp as updated_at,
cast(price_indexes as json) as price_indexes_json_obj,
sku,
description_category_id,
type_id,
pri.commissions_json_obj as price_commissions_json_obj,
pri.marketing_seller_price as price_marketing_seller_price,
pri.auto_action_enabled as price_auto_action_enabled,
pri.marketing_actions_json_obj as price_marketing_actions_json_obj,
pri.acquiring as price_acquiring,
pri.price_json_obj as price_price_json_obj
FROM {{ source('external_data', 'raw_products_list') }} p
JOIN {{ source('external_data', 'raw_products_extended') }} pe
USING (offer_id)
JOIN {{ ref('raw_v_prices') }} pri
USING (offer_id)
