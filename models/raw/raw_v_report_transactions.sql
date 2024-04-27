{{ config(
 tags=['raw_v_report_transactions', 'raw_report_transactions', 'report_transactions', 'transactions', 'raw'],
 schema='raw',
 materialized='view',
) }}

SELECT *
FROM {{ source('external_data', 'raw_report_transactions') }}
