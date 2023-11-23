{{
    config(
        materialized='table',
        tags=['dau', 'events']
    )
}}

{%- set dates_query -%}
select distinct report_date from {{ ref('events_view') }} order by 1
{%- endset -%}

{%- set results = run_query(dates_query) -%}

{%- if execute -%}
{# Return the first column #}
{%- set results_list = results.columns[0].values() -%}
{%- else -%}
{%- set results_list = [] -%}
{%- endif -%}

{{log(results_list, info=True)}}

{%- for result in results_list -%}
SELECT '{{result}}' as report_date,
       os_name,
       count(distinct appmetrica_device_id) as dau
FROM {{ref('events_view')}}
WHERE event_datetime_ts BETWEEN '{{result}}'::timestamp - INTERVAL '7day' and '{{result}}'::timestamp
GROUP BY os_name
{% if not loop.last -%}
UNION ALL
{% endif %}
{%- endfor -%}
ORDER BY 1
