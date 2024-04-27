{{ config(
 tags=['ods_hub_products', 'hub_products', 'ods_products', 'products', 'ods'],
 schema='ods',
 materialized='incremental',
) }}

{%- set source_model = "stg_products" -%}
{%- set src_pk = "product_pk" -%}
{%- set src_nk = "offer_id" -%}
{%- set src_extra_columns = ["product_id", "barcode", "fbs_sku", "fbo_sku"] -%}
{%- set src_ldts = "load_datetime" -%}
{%- set src_source = "record_source" -%}

{{ automate_dv.postgres__hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_extra_columns=src_extra_columns,
                   src_source=src_source, source_model=source_model) }}
