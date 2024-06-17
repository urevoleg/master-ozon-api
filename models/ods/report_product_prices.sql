-- noinspection SqlNoDataSourceInspectionForFile
-- noinspection SqlDialectInspectionForFile
-- incremental_strategy='delete+insert',
-- unique_key=['hasdiff']

{{ config(
 tags=['ods_sat_product_prices', 'sat_product_prices', 'products', 'ods'],
 schema='ods',
 materialized='incremental',
 incremental_strategy='delete+insert',
 unique_key=['hashdiff'],
 post_hook=["GRANT USAGE ON SCHEMA ods TO external_user_ro",
 "GRANT SELECT ON ALL TABLES IN SCHEMA ods TO external_user_ro"]
) }}

{%- set yaml_metadata -%}
source_model: "stg_prices"
src_pk: "product_pk"
src_hashdiff:
  source_column: "report_product_prices_hashdiff"
  alias: "hashdiff"
src_payload:
  - price_index
  - volume_weight
  - acquiring
  - price_json_obj
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
  - process_date
src_eff: "effective_dttm"
src_ldts: "load_datetime"
src_source: "record_source"
src_extra_columns:
  - price_json_obj
  - commissions_json_obj
  - marketing_actions_json_obj
  - price_indexes_json_obj
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

