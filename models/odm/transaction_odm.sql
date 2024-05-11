{{ config(
 tags=['odm_transaction', 'transaction_odm', 'transaction', 'odm', 'ods'],
 schema='odm',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: "stg_transactions_alt"
src_pk: "transaction_pk"
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
  - posting_json_obj
  - items_json_obj
  - services_json_obj
  - posting_id
  - order_date
  - services_raw_obj
  - load_datetime
  - record_source
  - process_date
  - posting_pk
  - link_transactions_postings_pk
  - transactions_hashdiff
src_eff: "effective_dttm"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.postgres__odm(src_pk=metadata_dict["src_pk"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   source_model=metadata_dict["source_model"])   }}

