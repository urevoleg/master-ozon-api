-- noinspection SqlNoDataSourceInspectionForFile

-- noinspection SqlDialectInspectionForFile

{{ config(
 tags=['ods_report_transactions', 'sat_report_transactions', 'transactions', 'ods'],
 schema='ods',
 materialized='incremental',
 incremental_strategy='delete+insert',
 unique_key=['hashdiff']
) }}

{%- set yaml_metadata -%}
source_model: "stg_report_transactions"
src_pk: "operation_id"
src_hashdiff:
  source_column: "report_transactions_hashdiff"
  alias: "hashdiff"
src_payload:
  - operation_type
  - operation_date
  - operation_type_name
  - delivery_charge
  - return_delivery_charge
  - accruals_for_sale
  - sale_commission
  - amount
  - service_type
src_eff: "load_datetime"
src_ldts: "load_datetime"
src_source: "record_source"
src_extra_columns:
  - posting
  - items
  - services
  - operation_id
  - transaction_pk
  - process_date
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__sat(src_pk=metadata_dict["src_pk"],
                   src_hashdiff=metadata_dict["src_hashdiff"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   src_extra_columns=metadata_dict["src_extra_columns"],
                   source_model=metadata_dict["source_model"])   }}

