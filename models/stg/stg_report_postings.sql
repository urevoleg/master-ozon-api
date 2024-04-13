{{ config(
 tags=['stg_report_postings', 'report_postings', 'stg'],
 target='duckdb',
 schema='stg',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: raw_report_postings
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!report_postings'
  process_date: CAST('{{ var("logical_date") }}' as date)
hashed_columns:
  daily_hashdiff:
    is_hashdiff: true
    columns:
      - offer_id
      - sku
      - order_id
      - posting_id
      - CAST('{{ var("logical_date") }}' as date)
      - '!report_postings'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

