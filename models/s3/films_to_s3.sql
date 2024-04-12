{{ config(
 tags=['films_to_s3', 's3'],
 materialized='table',
 schema='service',
 target='duckdb',
 pre_hook="SET s3_region = '';
SET s3_endpoint = '127.0.0.1:9002';
SET s3_use_ssl = false;
SET s3_url_style = 'path';
SET s3_access_key_id = 's3admin';
SET s3_secret_access_key = 's3pass_)';
ATTACH 'dbname=tmp user=shpz password=12345 host=127.0.0.1 port=5432' AS db (TYPE POSTGRES);"
) }}

with to_s3 as (COPY (SELECT * FROM postgres_query('db', 'SELECT *
FROM stage.kp_search_results
WHERE checked_at between ''{{ var("logical_date") }}'' and ''CAST(to_date({{ var("logical_date") }}) + INTERVAL 1 day as VARCHAR)'''))
TO {{ s3_source('dev-stg', 'kinopoisk/films') }})
select 'parser' as source_name,
'{{ var("logical_date") }}' as logical_date,
now() as load_datetime