{{ config(
 tags=['stg_product', 'product', 'stg'],
 schema='stg',
 materialized='table'
) }}

{%- set yaml_metadata -%}
source_model: raw_product_wide
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!ozon'
  process_date: CAST('{{ var("logical_date") }}' as date)
hashed_columns:
  product_pk:
    is_hashdiff: true
    columns:
      - offer_id
      - record_source
  product_hashdiff:
    is_hashdiff: true
    columns:
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
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

