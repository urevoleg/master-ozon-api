{{ config(
 tags=['raw_v_report_products', 'raw_report_products', 'raw'],
 schema='raw',
 materialized='view'
) }}

SELECT *
FROM {{ source('external_data', 'raw_report_products') }}
