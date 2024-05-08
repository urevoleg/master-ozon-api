-- noinspection SqlNoDataSourceInspectionForFile
-- noinspection SqlDialectInspectionForFile
-- incremental_strategy='delete+insert',
-- unique_key=['hasdiff']

{{ config(
 tags=['ods_products', 'sat_products_ext', 'products', 'ods'],
 schema='ods',
 materialized='incremental',
) }}

{%- set yaml_metadata -%}
source_model: "stg_products"
src_pk: "product_pk"
src_hashdiff:
  source_column: "product_hashdiff"
  alias: "hashdiff"
src_payload:
  - is_fbo_visible
  - is_fbs_visible
  - archived
  - is_discounted
  - product_name
  - buybox_price
  - category_id
  - created_at
  - marketing_price
  - min_ozon_price
  - old_price
  - premium_price
  - price
  - recommended_price
  - min_price
  - vat
  - visible
  - price_index
  - volume_weight
  - is_prepayment
  - is_prepayment_allowed
  - color_image
  - primary_image
  - state
  - service_type
  - currency_code
  - is_kgt
  - has_discounted_item
  - updated_at
  - description_category_id
  - type_id
src_eff: "effective_dttm"
src_ldts: "load_datetime"
src_source: "record_source"
src_extra_columns:
  - images
  - sources
  - stocks
  - errors
  - visibility_details
  - commissions
  - images360
  - status
  - discounted_stocks
  - barcodes
  - price_indexes
  - process_date
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__sat_ext(src_pk=metadata_dict["src_pk"],
                   src_hashdiff=metadata_dict["src_hashdiff"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   src_extra_columns=metadata_dict["src_extra_columns"],
                   source_model=metadata_dict["source_model"])   }}

