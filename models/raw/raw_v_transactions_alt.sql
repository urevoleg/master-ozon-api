{{ config(
 tags=['raw_v_transactions_alt', 'raw_transactions_alt', 'transactions_alt', 'raw'],
 schema='raw',
 materialized='view',
) }}

SELECT
operation_id,
operation_type,
operation_date,
operation_type_name,
delivery_charge,
return_delivery_charge,
accruals_for_sale,
sale_commission,
amount,
type as service_type,
CAST(posting as json) as posting_json_obj,
CAST(items as json) as items_json_obj,
CAST(services as json) as services_json_obj,
case when cast(posting as json) ->> 'posting_number' != '' then CAST(posting as json) ->> 'posting_number'
    else null end as posting_id,
case when cast(posting as json) ->> 'order_date' != '' then (cast(posting as json) ->> 'order_date')::timestamp
           else null end as order_date,
services as services_raw_obj,
effective_dttm
FROM {{ source('external_data', 'raw_report_transactions') }}
