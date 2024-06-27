{{ config(
 tags=['post_dq___deviation_cnt__posting_item_odm___posting_item_odm', 'dq'],
 schema='dq',
 materialized='incremental',
 incremental_strategy='append',
 post_hook=["GRANT USAGE ON SCHEMA dq TO external_user_ro",
 "GRANT SELECT ON ALL TABLES IN SCHEMA dq TO external_user_ro"]
) }}

with daily as (SELECT count(1) as __cnt
                FROM {{ ref('posting_item_odm') }}
                WHERE processed_at > now() - interval '7 day'
                GROUP BY cast(processed_at as date)),
avg as (SELECT avg(__cnt) as __avg FROM daily),
deviation as (
SELECT ((select count(1) FROM {{ ref('stg_report_postings') }}) - (select __avg FROM avg)) / (select __avg FROM avg) as __deviation
    )
select __deviation,
       (select __avg from avg) as __avg,
       '{{ var("logical_date") }}'::date  as dq_date_test,
        current_timestamp as dq_load_datetime
from deviation
;