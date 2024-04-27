{{ config(
 tags=['raw_v_prices', 'raw_prices', 'product_prices', 'prices', 'raw'],
 schema='raw',
 materialized='view',
) }}

SELECT *
FROM {{ source('external_data', 'raw_prices') }}
