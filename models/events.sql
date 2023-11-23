{{
    config(
        materialized='table',
        tags=['events']
    )
}}

select *,
       event_datetime::date as report_date
from stg.events