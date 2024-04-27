{{ config(
 tags=['raw_report_products', 'report_products', 'products', 'raw'],
 schema='raw',
 materialized='view',
) }}

SELECT *
FROM {{ source('external_data', 'raw_report_products') }}
