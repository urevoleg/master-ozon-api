{{ config(
 tags=['stg_report_products', 'report_products', 'products', 'stg'],
 schema='stg',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: raw_v_report_products
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!ozon'
  process_date: CAST('{{ var("logical_date") }}' as date)
  offer_id:
    source_column: CAST(RIGHT(offer_id, LENGTH(offer_id)-1) as varchar)
  product_id:
    source_column: CAST(product_id as varchar)
  barcode:
    source_column: CAST(barcode as varchar)
  fbs_sku:
    source_column: CAST(fbs_sku as varchar)
  fbo_sku:
    source_column: CAST(fbo_sku as varchar)
hashed_columns:
  product_pk:
    is_hashdiff: true
    columns:
      - derived_columns.offer_id
      - derived_columns.record_source
  report_products_hashdiff:
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

