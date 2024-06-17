-- noinspection SqlNoDataSourceInspectionForFile

-- noinspection SqlDialectInspectionForFile
-- incremental_strategy='delete+insert',
-- unique_key=['hasdiff']

{{ config(
 tags=['ods_report_postings', 'sat_report_postings', 'report_postings', 'postings', 'ods'],
 schema='ods',
 materialized='incremental',
 incremental_strategy='delete+insert',
 unique_key=['hashdiff'],
 post_hook=["GRANT USAGE ON SCHEMA ods TO external_user_ro",
 "GRANT SELECT ON ALL TABLES IN SCHEMA ods TO external_user_ro"]
) }}

{%- set yaml_metadata -%}
source_model: "stg_report_postings"
src_pk: "report_posting_pk"
src_hashdiff:
  source_column: "report_postings_hashdiff"
  alias: "hashdiff"
src_payload:
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
src_eff: "load_datetime"
src_ldts: "load_datetime"
src_source: "record_source"
src_extra_columns:
  - posting_id
  - posting_pk
  - order_id
  - order_pk
  - product_pk
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

