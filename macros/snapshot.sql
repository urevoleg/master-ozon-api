-- generate snapshot
{% macro snapshot(src_tab, src_hub, src_pk, src_nk, src_eff, src_cols, incr_tab, link_flag) %}
  {%- if execute -%}
    {%- if not (src_eff is iterable and src_eff is not string) -%}
      {%- set src_eff = [src_eff] -%}
    {%- endif -%}

    {%- if not (src_cols is iterable and src_cols is not string) -%}
      {%- set src_cols = [src_cols] -%}
    {%- endif -%}

    {% if link_flag is true %}
      {%- set join_col = src_cols[0] -%}
    {% else %}
      {%- set join_col = src_pk -%}
    {% endif %}

    {% if src_hub is not none and src_hub|string|length == 0 %}
      {% set src_hub = none %}
    {% endif %}

    {% if src_nk is not none and src_nk|string|length == 0 %}
      {% set src_nk = none %}
    {% endif %}

    {% if incr_tab is not none and incr_tab|length == 0 %}
      {% set incr_tab = none %}
    {% endif %}

    {% set link_flag = link_flag|default(false) %}

    {%- set sel_cols = automate_dv.expand_column_list(columns=[src_pk, src_cols]) -%}

    {% set query %}
      select {{ automate_dv.prefix([sel_cols], 'a') }}
      {% if src_hub is not none and src_nk is not none %}
      ,{{ automate_dv.prefix([src_nk], 'h') }}
      {% endif -%}
      from (
        select {{ automate_dv.prefix([sel_cols], 's') }},
          row_number() over (partition by {{ automate_dv.prefix([src_pk], 's') }} order by{{'\n'}}
          {%- for eff_col in src_eff -%}
            {{ automate_dv.prefix([eff_col], 's') }} desc {% if not loop.last %},{% endif %}
          {% endfor -%}) as rn
          from {{src_tab}} s) a
      {% if src_hub is not none %}
      join {{src_hub}} h on
        {{ automate_dv.multikey(join_col, prefix=['h','a'], condition='=') }}
      {% endif -%}
      where a.rn = 1
      {% if incr_tab is not none %}
        and exists (select 1 from {{incr_tab}} i where {{ automate_dv.multikey(src_pk, prefix=['i','a'], condition='=') }})
      {% endif -%}
    {% endset %}

    {{return(query)}}
  {% endif %}
{%- endmacro %}