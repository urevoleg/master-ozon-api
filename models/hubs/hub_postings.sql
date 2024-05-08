{{ config(
 tags=['ods_hub_postings', 'hub_postings', 'ods_postings',
 'postings', 'ods'],
 schema='ods',
 materialized='incremental',
) }}

{%- set source_model = "stg_report_postings" -%}
{%- set src_pk = "posting_pk" -%}
{%- set src_nk = "posting_id" -%}
{%- set src_extra_columns = [] -%}
{%- set src_ldts = "load_datetime" -%}
{%- set src_source = "record_source" -%}

{{ automate_dv.postgres__hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_extra_columns=src_extra_columns,
                   src_source=src_source, source_model=source_model) }}
