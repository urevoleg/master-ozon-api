{{ config(
            tags=['link_postings', 'postings', 'ods'],
            materialized='incremental',
            schema='ods')
            }}

{%- set source_model = ['stg_report_postings'] -%}
{%- set src_pk = 'link_postings_products_pk' -%}
{%- set src_fk = ['posting_pk', 'product_pk'] -%}
{%- set src_ldts = 'load_datetime' -%}
{%- set src_source = 'record_source' -%}

{{ automate_dv.postgres__link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                 src_source=src_source, source_model=source_model) }}
