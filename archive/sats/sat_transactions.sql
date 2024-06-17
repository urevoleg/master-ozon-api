-- noinspection SqlNoDataSourceInspectionForFile
-- noinspection SqlDialectInspectionForFile
-- incremental_strategy='delete+insert',
-- unique_key=['hasdiff']

{{ config(
 tags=['ods_transactions', 'sat_transactions', 'transactions', 'transactions_alt', 'ods'],
 schema='ods',
 materialized='incremental',
) }}

{%- set yaml_metadata -%}
source_model: "stg_transactions_alt"
src_pk: "transaction_pk"
src_hashdiff:
  source_column: "transactions_hashdiff"
  alias: "hasdiff"
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
   - posting_id
   - order_date
src_eff: "effective_dttm"
src_ldts: "load_datetime"
src_source: "record_source"
src_extra_columns:
  - services_raw_obj
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

