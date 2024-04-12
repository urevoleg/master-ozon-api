{{ config(
 tags=['raw_report_stocks_fbo', 'report_stocks_fbo', 'report_stocks', 'raw'],
 target='duckdb',
 schema='raw',
 materialized='table',
 pre_hook="SET s3_region = '';
    SET s3_endpoint = '127.0.0.1:9002';
    SET s3_use_ssl = false;
    SET s3_url_style = 'path';
    SET s3_access_key_id = 's3admin';
    SET s3_secret_access_key = 's3pass_)';
    ATTACH 'dbname=tmp user=shpz password=12345 host=127.0.0.1 port=5432' AS db (TYPE POSTGRES);"
) }}

select *
from 's3://dev-raw/reports/stocks/{{ var("logical_date") }}/fbo_stocks_{{ var("logical_date") }}.json'
