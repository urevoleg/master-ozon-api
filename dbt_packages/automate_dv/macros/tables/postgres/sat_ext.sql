/*
 * Copyright (c) Business Thinking Ltd. 2019-2023
 * This software includes code developed by the automate_dv Team at Business Thinking Ltd. Trading as Datavault
 */

{%- macro postgres__sat_ext(src_pk, src_hashdiff, src_payload, src_extra_columns, src_eff, src_ldts, src_source, source_model, derived_columns) -%}

{%- set source_cols = automate_dv.expand_column_list(columns=[src_pk, src_eff, src_hashdiff, src_payload, src_extra_columns, src_ldts, src_source]) -%}
{%- set window_cols = automate_dv.expand_column_list(columns=[src_pk, src_eff, src_hashdiff, src_ldts]) -%}
{%- set rest_cols = automate_dv.expand_column_list(columns=[src_payload, src_extra_columns, src_ldts, src_source]) -%}
{%- set pk_cols = automate_dv.expand_column_list(columns=[src_pk, src_eff]) -%}

{%- if not (src_eff is iterable and src_eff is not string) -%}
    {%- set src_eff = [src_eff] -%}
{%- endif -%}

WITH source_data AS (
    SELECT {{ automate_dv.prefix(source_cols, 'a', alias_target='source') }}
    FROM {{ ref(source_model) }} AS a
    WHERE {{ automate_dv.multikey(src_pk, prefix='a', condition='IS NOT NULL') }}
),
{%- if automate_dv.is_any_incremental() %}
latest_records AS (
    SELECT {{ automate_dv.prefix(window_cols, 'current_records', alias_target='target') }}
    FROM {{ this }} AS current_records
    JOIN (SELECT DISTINCT {{ automate_dv.prefix([src_pk], 'source_data') }} FROM source_data) AS source_records
    ON {{ automate_dv.multikey(src_pk, prefix=['current_records','source_records'], condition='=') }}
),
records_to_insert AS (
    SELECT  coalesce({{ automate_dv.prefix([src_pk], 'stage') }},{{ automate_dv.prefix([src_pk], 'latest_records') }}) as {{src_pk}},
        {%- for field_eff in src_eff -%}
            coalesce({{ automate_dv.prefix([field_eff], 'stage') }},{{ automate_dv.prefix([field_eff], 'latest_records') }})as {{field_eff}},
        {% endfor -%}
            coalesce({{ automate_dv.prefix([src_hashdiff], 'stage') }},latest_records.hashdiff) as hashdiff,
            {{ automate_dv.prefix([rest_cols], 'stage') }},
            case when {{ automate_dv.prefix([src_pk], 'latest_records') }} is null then 1 else 0 end as new_flg
        FROM source_data AS stage
        FULL JOIN latest_records
        ON {{ automate_dv.multikey(pk_cols, prefix=['latest_records','stage'], condition='=') }}
        AND {{ automate_dv.prefix([src_hashdiff], 'stage') }} = latest_records.hashdiff
)
{%- else %}
records_to_insert AS (
    SELECT {{ automate_dv.prefix([src_pk], 'stage') }},
           {{ automate_dv.prefix(src_eff, 'stage') }},
           {{ automate_dv.prefix([src_hashdiff], 'stage') }} as hashdiff,
           {{ automate_dv.prefix([rest_cols], 'stage') }},
           1 as new_flg
    from source_data AS stage
)
{%- endif %}
select   {{ automate_dv.prefix([src_pk], 'b') }}
        ,{{ automate_dv.prefix(src_eff, 'b') }}
        ,b.hashdiff
        ,{{ automate_dv.prefix([rest_cols], 'b') }}
    {%- if automate_dv.is_something(derived_columns) -%}
        ,{{ automate_dv.derive_columns(source_relation=none, columns=derived_columns) }}
    {%- endif %}
from (
    select a.*,lag(a.hashdiff) OVER (PARTITION BY {{ automate_dv.prefix([src_pk], 'a') }} ORDER BY {{ automate_dv.prefix([src_eff], 'a') }}) as prev_hashdiff
    from records_to_insert a) b
where (b.prev_hashdiff is null or b.hashdiff <> b.prev_hashdiff) and b.new_flg = 1

{%- endmacro -%}