/*
 * Copyright (c) Business Thinking Ltd. 2019-2023
 * This software includes code developed by the automate_dv Team at Business Thinking Ltd. Trading as Datavault
 */

{%- macro postgres__odm(src_pk, src_eff, src_payload, source_model) -%}

{%- set source_cols = automate_dv.expand_column_list(columns=[src_pk, src_eff, src_payload]) -%}
{%- set window_cols = automate_dv.expand_column_list(columns=[src_pk, src_eff]) -%}

WITH source_data AS (
    SELECT {{ automate_dv.prefix(source_cols, 'a') }} FROM (
        SELECT {{ automate_dv.prefix(source_cols, 's') }},
            row_number() over (partition by {{ automate_dv.prefix([src_pk], 's') }} order by {{ automate_dv.prefix([src_eff], 's') }} desc) as rn
        FROM {{ ref(source_model) }} AS s
        WHERE {{ automate_dv.multikey(src_pk, prefix='s', condition='IS NOT NULL') }}) a
    WHERE a.rn = 1
),
records_to_insert AS (
    SELECT coalesce({{ automate_dv.prefix([src_pk], 'stage') }},{{ automate_dv.prefix([src_pk], 'latest_records') }}) as {{src_pk}},
           coalesce({{ automate_dv.prefix([src_eff], 'stage') }},{{ automate_dv.prefix([src_eff], 'latest_records') }}) as {{src_eff}},
        {%- for field in src_payload -%}
            coalesce({{ automate_dv.prefix([field], 'stage') }},{{ automate_dv.prefix([field], 'latest_records') }})as {{field}},
        {% endfor -%}
            row_number() over (partition by coalesce({{ automate_dv.prefix([src_pk], 'stage') }},{{ automate_dv.prefix([src_pk], 'latest_records') }})
                order by coalesce({{ automate_dv.prefix([src_eff], 'stage') }},{{ automate_dv.prefix([src_eff], 'latest_records') }}) desc) as rn
        FROM source_data AS stage
        FULL JOIN  {{ this }} as latest_records
        ON {{ automate_dv.multikey(window_cols, prefix=['latest_records','stage'], condition='=') }}
)
select {{ automate_dv.prefix(source_cols, 'a') }}
from records_to_insert a
where a.rn = 1

{%- endmacro -%}