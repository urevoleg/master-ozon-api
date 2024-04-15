-- noinspection SqlNoDataSourceInspectionForFile

-- noinspection SqlDialectInspectionForFile

{{ config(
 tags=['ods_report_transactions', 'sat_report_transactions', 'ods'],
 target='duckdb',
 schema='ods',
 materialized='incremental',
incremental_strategy='delete+insert',
unique_key=['hasdiff']
) }}

{%- set yaml_metadata -%}
source_model: "stg_report_transactions"
src_pk: "operation_id"
src_hashdiff:
  source_column: "daily_hashdiff"
  alias: "hasdiff"
src_payload:
  - operation_id
  - operation_type
  - operation_date
  - operation_type_name
  - delivery_charge
  - return_delivery_charge
  - accruals_for_sale
  - sale_commission
  - amount
  - service_type
  - posting
  - items
  - services
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

