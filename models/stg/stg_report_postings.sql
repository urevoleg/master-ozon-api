{{ config(
 tags=['stg_report_postings', 'report_postings', 'postings', 'stg'],
 schema='stg',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: raw_report_postings
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!ozon'
  process_date: CAST('{{ var("logical_date") }}' as date)
  offer_id: offer_id
  order_id: order_id
  posting_id: posting_id
hashed_columns:
  product_pk:
    is_hashdiff: true
    columns:
      - derived_columns.offer_id
      - derived_columns.record_source
  posting_pk:
    is_hashdiff: true
    columns:
      - derived_columns.posting_id
      - derived_columns.record_source
  link_postings_products_pk:
    is_hashdiff: true
    columns:
      - derived_columns.posting_id
      - derived_columns.offer_id
      - derived_columns.record_source
  order_pk:
    is_hashdiff: true
    columns:
      - derived_columns.order_id
      - derived_columns.record_source
  report_posting_pk:
    is_hashdiff: true
    columns:
      - derived_columns.posting_id
      - derived_columns.order_id
      - derived_columns.offer_id
      - derived_columns.record_source
  postings_hashdiff:
    is_hashdiff: true
    columns:
      - processed_at
      - shipped_at
      - status
      - delivered_at
  report_postings_hashdiff:
    is_hashdiff: true
    columns:
      - derived_columns.posting_id
      - derived_columns.order_id
      - derived_columns.offer_id
      - derived_columns.delivery_type
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

