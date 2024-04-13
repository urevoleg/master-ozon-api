-- noinspection SqlNoDataSourceInspectionForFile

-- noinspection SqlDialectInspectionForFile

{{ config(
 tags=['ods_report_products', 'sat_report_products', 'ods'],
 target='duckdb',
 schema='ods',
 materialized='incremental',
) }}

{%- set yaml_metadata -%}
source_model: "stg_report_products"
src_pk: "product_pk"
src_hashdiff:
  source_column: "daily_hashdiff"
  alias: "hasdiff"
src_payload:
  - item_name
  - content_rating
  - brand
  - item_status
  - is_fbo_visible
  - reason_fbo_visible
  - is_fbs_visible
  - reason_fbs_visible
  - created_at
  - category_comission
  - item_volume
  - item_weight
  - fbo_free_to_sell_amount
  - exclude_tver
  - reserved_amount
  - fbs_free_to_sell_amount
  - rfbs_free_to_sell_amount
  - seller_reserved_amount
  - price
  - old_price
  - premium_price
  - marketing_price
  - link_marketing_price
  - nds
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

