{{ config(
 tags=['ods_product_prices', 'product_prices', 'product_prices_odm', 'prices', 'ods', 'odm'],
 schema='odm',
 materialized='table',
 post_hook=["GRANT USAGE ON SCHEMA odm TO external_user_ro",
 "GRANT SELECT ON ALL TABLES IN SCHEMA odm TO external_user_ro"]
) }}

{%- set yaml_metadata -%}
source_model: "stg_prices"
src_pk: "product_pk"
src_payload:
  - offer_id
  - product_id
  - price_index
  - volume_weight
  - acquiring
  - price
  - old_price
  - premium_price
  - recommended_price
  - vat
  - min_ozon_price
  - marketing_price
  - marketing_seller_price
  - min_price
  - currency_code
  - auto_action_enabled
  - load_datetime
  - record_source
  - process_date
  - product_prices_hashdiff
src_eff: "effective_dttm"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__odm(src_pk=metadata_dict["src_pk"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   source_model=metadata_dict["source_model"])   }}

