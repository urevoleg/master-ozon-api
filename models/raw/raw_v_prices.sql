{{ config(
 tags=['raw_v_prices', 'raw_prices', 'product_prices', 'prices', 'raw'],
 schema='raw',
 materialized='view',
) }}

SELECT
product_id,
offer_id,
CAST(price_index as numeric) as price_index,
-- commissions,
CAST (commissions as json) as commissions_json_obj,
-- marketing_actions,
CAST (marketing_actions as json) as marketing_actions_json_obj,
volume_weight,
-- price_indexes,
CAST (price_indexes as json) as price_indexes_json_obj,
acquiring,
CAST (price as json) as price_json_obj,
CAST ((CASE WHEN (CAST (price as json) ->> 'price') = '' THEN NULL ELSE CAST (price as json) ->> 'price' END) as numeric) as price,
CAST ((CASE WHEN (CAST (price as json) ->> 'old_price') = '' THEN NULL ELSE CAST (price as json) ->> 'old_price' END) as numeric) as old_price,
CAST ((CASE WHEN (CAST (price as json) ->> 'premium_price') = '' THEN NULL ELSE CAST (price as json) ->> 'premium_price' END) as numeric) as premium_price,
CAST ((CASE WHEN (CAST (price as json) ->> 'recommended_price') = '' THEN NULL ELSE CAST (price as json) ->> 'recommended_price' END) as numeric) as recommended_price,
CAST ((CASE WHEN (CAST (price as json) ->> 'vat') = '' THEN NULL ELSE CAST (price as json) ->> 'vat' END) as numeric) as vat,
CAST ((CASE WHEN (CAST (price as json) ->> 'min_ozon_price') = '' THEN NULL ELSE CAST (price as json) ->> 'min_ozon_price' END) as numeric) as min_ozon_price,
CAST ((CASE WHEN (CAST (price as json) ->> 'marketing_price') = '' THEN NULL ELSE CAST (price as json) ->> 'marketing_price' END) as numeric) as marketing_price,
CAST ((CASE WHEN (CAST (price as json) ->> 'marketing_seller_price') = '' THEN NULL ELSE CAST (price as json) ->> 'marketing_seller_price' END) as numeric) as marketing_seller_price,
CAST ((CASE WHEN (CAST (price as json) ->> 'min_price') = '' THEN NULL ELSE CAST (price as json) ->> 'min_price' END) as numeric) as min_price,
CASE WHEN (CAST (price as json) ->> 'currency_code') = '' THEN NULL ELSE CAST (price as json) ->> 'currency_code' END as currency_code,
CAST ((CASE WHEN (CAST (price as json) ->> 'auto_action_enabled') = '' THEN NULL ELSE CAST(CAST (price as json) ->> 'auto_action_enabled' as bool) END) as int4) as auto_action_enabled,
effective_dttm
FROM {{ source('external_data', 'raw_prices') }}
