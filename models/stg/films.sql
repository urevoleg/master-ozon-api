{{ config(
 tags=['stg_films', 'films'],
 materialized='table',
 schema='stg'
) }}

select *
from {{ s3_source('dev-stg', 'kinopoisk/{{ self }}') }}
