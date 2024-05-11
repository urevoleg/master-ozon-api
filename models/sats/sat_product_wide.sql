-- noinspection SqlNoDataSourceInspectionForFile
-- noinspection SqlDialectInspectionForFile
-- incremental_strategy='delete+insert',
-- unique_key=['hasdiff']

{{ config(
 tags=['ods_product', 'sat_product', 'products', 'product', 'ods'],
 schema='ods',
 materialized='incremental',
) }}

{%- set yaml_metadata -%}
source_model: "stg_product"
src_pk: "product_pk"
src_hashdiff:
  source_column: "product_hashdiff"
  alias: "hashdiff"
src_payload:
  - is_fbo_visible
  - is_fbs_visible
  - archived
  - is_discounted
  - id
  - product_name
  - barcode
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
  - errors
  - vat
  - visible
  - price_index
  - volume_weight
  - is_prepayment
  - is_prepayment_allowed
  - images360
  - color_image
  - primary_image
  - state
  - service_type
  - fbo_sku
  - fbs_sku
  - currency_code
  - is_kgt
  - has_discounted_item
  - sku
  - description_category_id
  - type_id
  - price_marketing_seller_price
  - price_auto_action_enabled
  - price_acquiring
src_eff: "effective_dttm"
src_ldts: "load_datetime"
src_source: "record_source"
src_extra_columns:
  - updated_at
  - process_date
  - stocks_json_obj
  - visibility_details_json_obj
  - commissions_json_obj
  - status_json_obj
  - discounted_stocks_json_obj
  - barcodes_json_obj
  - price_indexes_json_obj
  - price_commissions_json_obj
  - price_marketing_actions_json_obj
  - price_price_json_obj
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

