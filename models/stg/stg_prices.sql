{{ config(
 tags=['stg_prices', 'product_prices', 'prices', 'stg'],
 schema='stg',
 materialized='table'
) }}

{%- set yaml_metadata -%}
source_model: raw_v_prices
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!ozon'
  process_date: CAST('{{ var("logical_date") }}' as date)
  offer_id: offer_id
hashed_columns:
  product_pk:
    is_hashdiff: true
    columns:
      - derived_columns.offer_id
      - derived_columns.record_source
  product_prices_hashdiff:
    is_hashdiff: true
    columns:
      - derived_columns.offer_id
      - derived_columns.record_source
  report_product_prices_hashdiff:
    is_hashdiff: true
    columns:
      - derived_columns.offer_id
      - derived_columns.process_date
      - derived_columns.record_source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

