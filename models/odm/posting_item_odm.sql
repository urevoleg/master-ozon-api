{{ config(
 tags=['odm_posting_item', 'posting_item', 'odm', 'ods'],
 schema='odm',
 materialized='table',
 post_hook=["GRANT USAGE ON SCHEMA odm TO external_user_ro",
 "GRANT SELECT ON ALL TABLES IN SCHEMA odm TO external_user_ro"]
) }}

{%- set yaml_metadata -%}
source_model: "stg_report_postings"
src_pk: "posting_item_pk"
src_payload:
  - processed_at
  - shipped_at
  - status
  - delivered_at
  - posting_cost
  - money_code_out
  - item_name
  - sku
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
  - load_datetime
  - record_source
  - process_date
  - offer_id
  - order_id
  - posting_id
  - product_pk
  - posting_pk
  - link_postings_products_pk
  - order_pk
  - report_posting_pk
src_eff: "effective_dttm"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__odm(src_pk=metadata_dict["src_pk"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   source_model=metadata_dict["source_model"])   }}

