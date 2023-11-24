{{
    config(
        materialized='view',
        tags=['events']
    )
}}

select *,
       event_datetime::timestamp as event_datetime_ts,
       event_datetime::date as report_date
from {{ source('stg', 'events') }}