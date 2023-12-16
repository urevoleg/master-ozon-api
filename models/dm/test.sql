{{
    config(
        materialized='table',
        tags=['test']
    )
}}

{# Подзапрос определения интервалов для каждого периода #}
{%- set dates_query -%}
SELECT 'day' AS period,
       CAST(now() AT TIME ZONE 'UTC' - INTERVAL '3 day' AS date) AS started_at,
       CAST(now() AT TIME ZONE 'UTC' - INTERVAL '1 day' AS date) AS ended_at
UNION ALL
SELECT 'week' AS period,
       (CASE WHEN extract(isodow from now()) >= 4  THEN date_trunc('week', now())
            ELSE date_trunc('week', now()) - INTERVAL '1 week' END)::date AS started_at,
       CAST(date_trunc('week', now()) AS date) AS ended_at
UNION ALL
SELECT 'month' AS period,
       (CASE WHEN extract(day from now()) >= 4 THEN date_trunc('month', now())
            ELSE date_trunc('month', now()) - INTERVAL '1 month' END)::date AS started_at,
       CAST(date_trunc('month', now()) AS date) AS ended_at
{%- endset -%}

{%- set results = run_query(dates_query) -%}

{%- if execute -%}
{# Return the first column #}
{%- set results_list = results.rows.values() -%}
{%- else -%}
{%- set results_list = [] -%}
{%- endif -%}

{{log(results_list, info=True)}}

{# Loop for periods #}
{%- for result in results_list -%}
    {# Для каждого периода вычисляем список дат #}
    {%- set partial_results_query %}
    SELECT '{{result[0]}}' as period, * FROM generate_series('{{result[1]}}', '{{result[2]}}', '1 {{result[0]}}'::interval) d
    {% endset -%}
    {%- set partial_results = run_query(partial_results_query) -%}
    {# Для каждой даты нужного периоды выполняем запрос #}
    {%- for partial_result in partial_results -%}
        {{log(partial_result, info=True)}}
        SELECT '{{partial_result[0]}}' as report_period,
               '{{partial_result[1]}}' as report_date,
               os_name,
               count(distinct appmetrica_device_id) as dau
        FROM stg.events_view
        WHERE DATE_TRUNC('{{partial_result[0]}}', event_datetime_ts) = '{{partial_result[1]}}'
        GROUP BY os_name
        {% if not loop.last -%}
        UNION ALL
        {% endif %}
    {% endfor %}
{% if not loop.last -%}
UNION ALL
{% endif %}
{%- endfor -%}