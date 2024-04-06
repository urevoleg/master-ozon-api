{{ config(
 tags=['stg_films', 'films'],
 materialized='table',
 schema='stg',
 pre_hook="SET s3_region = '';
SET s3_endpoint = '127.0.0.1:9002';
SET s3_use_ssl = false;
SET s3_url_style = 'path';
SET s3_access_key_id = 's3admin';
SET s3_secret_access_key = 's3pass_)';"
) }}

select *
from {{ s3_source('dev-stg', 'kinopoisk/films') }}
