{{ config(
 tags=['stg_report_stocks', 'report_stocks', 'stg'],
 target='duckdb',
 schema='stg',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: stg_view_report_stocks
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!report_stocks'
  process_date: CAST('{{ var("logical_date") }}' as date)
hashed_columns:
  daily_hashdiff:
    is_hashdiff: true
    columns:
      - warehouse_pk
      - product_pk
      - delivery_type
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

