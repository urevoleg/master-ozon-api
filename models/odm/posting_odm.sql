{{ config(
 tags=['ods_report_postings', 'report_postings', 'posting', 'odm', 'ods'],
 schema='odm',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: "stg_report_postings"
src_pk: "posting_pk"
src_payload:
  - processed_at
  - shipped_at
  - status
  - delivered_at
  - linked_postings
  - load_datetime
  - record_source
  - process_date
  - order_id
  - posting_id
  - product_pk
  - link_postings_products_pk
  - order_pk
  - report_posting_pk
  - postings_hashdiff
src_eff: "effective_dttm"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__odm(src_pk=metadata_dict["src_pk"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   source_model=metadata_dict["source_model"])   }}

