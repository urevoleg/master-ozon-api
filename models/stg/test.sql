{{ config(
 tags=['stg_test', 'test'],
 materialized='table',
 schema='stg',
 pre_hook="ATTACH 'dbname=tmp user=shpz password=12345 host=127.0.0.1 port=5432' AS db (TYPE POSTGRES);"
) }}

SELECT * FROM postgres_query('db', 'SELECT *
FROM stage.kp_search_results
WHERE checked_at between ''2024-04-06'' and ''2024-04-07''')
