{{ config(
 tags=['stg_transactions_alt', 'transactions_alt', 'stg'],
 schema='stg',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: raw_v_transactions_alt
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!ozon'
  process_date: CAST('{{ var("logical_date") }}' as date)
hashed_columns:
  transaction_pk:
   is_hashdiff: true
   columns:
      - operation_id
      - record_source
  posting_pk:
    is_hashdiff: true
    columns:
      - posting_id
      - record_source
  link_transactions_postings_pk:
    is_hashdiff: true
    columns:
      - posting_id
      - operation_id
      - record_source
  transactions_hashdiff:
    is_hashdiff: true
    columns:
      - operation_type
      - operation_date
      - operation_type_name
      - delivery_charge
      - return_delivery_charge
      - accruals_for_sale
      - sale_commission
      - amount
      - service_type
      - posting_id
      - order_date
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

