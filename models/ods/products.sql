-- noinspection SqlNoDataSourceInspectionForFile

-- noinspection SqlDialectInspectionForFile

{{ config(
 tags=['ods_products', 'sat_products', 'ods'],
 target='duckdb',
 schema='ods',
 materialized='incremental',
) }}

{%- set yaml_metadata -%}
source_model: "stg_products"
src_pk: "product_pk"
src_hashdiff:
  source_column: "daily_hashdiff"
  alias: "hasdiff"
src_payload:
  - is_fbo_visible
  - is_fbs_visible
  - archived
  - is_discounted
  - name
  - buybox_price
  - category_id
  - created_at
  - images
  - marketing_price
  - min_ozon_price
  - old_price
  - premium_price
  - price
  - recommended_price
  - min_price
  - sources
  - stocks
  - errors
  - vat
  - visible
  - visibility_details
  - price_index
  - commissions
  - volume_weight
  - is_prepayment
  - is_prepayment_allowed
  - images360
  - color_image
  - primary_image
  - status
  - state
  - service_type
  - currency_code
  - is_kgt
  - discounted_stocks
  - has_discounted_item
  - barcodes
  - updated_at
  - price_indexes
  - description_category_id
  - type_id
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

