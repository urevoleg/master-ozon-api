-- noinspection SqlNoDataSourceInspectionForFile

-- noinspection SqlDialectInspectionForFile

{{ config(
 tags=['ods_report_stocks', 'sat_report_stocks', 'stocks', 'ods'],
 schema='ods',
 materialized='incremental',
) }}

{%- set yaml_metadata -%}
source_model: "stg_report_stocks"
src_pk: "report_stock_pk"
src_hashdiff:
  source_column: "report_stocks_hashdiff"
  alias: "hashdiff"
src_payload:
  - item_name
  - free_to_sell_amount
  - reserved_amount
src_eff: "load_datetime"
src_ldts: "load_datetime"
src_source: "record_source"
src_extra_columns:
  - product_pk
  - warehouse_pk
  - warehouse_name
  - delivery_type
  - process_date
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__sat(src_pk=metadata_dict["src_pk"],
                   src_hashdiff=metadata_dict["src_hashdiff"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   src_extra_columns=metadata_dict["src_extra_columns"],
                   source_model=metadata_dict["source_model"])   }}

