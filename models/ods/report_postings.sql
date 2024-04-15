-- noinspection SqlNoDataSourceInspectionForFile

-- noinspection SqlDialectInspectionForFile

{{ config(
 tags=['ods_report_postings', 'sat_report_postings', 'ods'],
 target='duckdb',
 schema='ods',
 materialized='incremental',
incremental_strategy='delete+insert',
unique_key=['hasdiff']
) }}

{%- set yaml_metadata -%}
source_model: "stg_report_postings"
src_pk: "product_pk"
src_hashdiff:
  source_column: "daily_hashdiff"
  alias: "hasdiff"
src_payload:
  - order_id
  - posting_id
  - processed_at
  - shipped_at
  - status
  - delivered_at
  - posting_cost
  - money_code_out
  - item_name
  - marketing_price
  - currency_code
  - amount
  - delivery_cost
  - linked_postings
  - repurchase_of_goods
  - old_price
  - discount
  - discount_money
  - promotions
  - delivery_type
  - process_date
src_eff: "load_datetime"
src_ldts: "load_datetime"
src_source: "record_source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__sat(src_pk=metadata_dict["src_pk"],
                   src_hashdiff=metadata_dict["src_hashdiff"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   source_model=metadata_dict["source_model"])   }}

