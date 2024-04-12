{{ config(
 tags=['stg_products', 'products', 'stg'],
 target='duckdb',
 schema='stg',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: raw_products
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!products'
  proccess_date: CAST('{{ var("logical_date") }}' as date)
hashed_columns:
  product_pk:
    is_hashdiff: true
    columns:
      - product_id
      - offer_id
      - barcode
      - fbs_sku
      - fbo_sku
  daily_hashdiff:
    is_hashdiff: true
    columns:
      - product_id
      - offer_id
      - barcode
      - fbs_sku
      - fbo_sku
      - CAST('{{ var("logical_date") }}' as date)
      - '!products'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

