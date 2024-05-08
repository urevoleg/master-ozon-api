{{ config(
            tags=['link_transactions', 'transactions', 'transactions_alt', 'ods'],
            materialized='incremental',
            schema='ods')
            }}

{%- set source_model = ['stg_transactions_alt'] -%}
{%- set src_pk = 'link_transactions_postings_pk' -%}
{%- set src_fk = ['transaction_pk', 'posting_pk'] -%}
{%- set src_ldts = 'load_datetime' -%}
{%- set src_source = 'record_source' -%}

{{ automate_dv.postgres__link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                 src_source=src_source, source_model=source_model) }}
