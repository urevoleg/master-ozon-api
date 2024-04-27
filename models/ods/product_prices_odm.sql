-- noinspection SqlNoDataSourceInspectionForFile

-- noinspection SqlDialectInspectionForFile

{{ config(
 tags=['ods_product_prices', 'product_prices', 'ods'],
 schema='ods',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: "stg_prices"
src_pk: "product_pk"
src_payload:
  - product_id
  - offer_id
  - price
  - price_index
  - commissions
  - marketing_actions
  - volume_weight
  - price_indexes
  - acquiring
  - process_date
src_eff: "effective_dttm"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__odm(src_pk=metadata_dict["src_pk"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   source_model=metadata_dict["source_model"])   }}

