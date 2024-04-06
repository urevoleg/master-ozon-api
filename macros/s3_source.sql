{% macro s3_source(bucket, path) %}
    's3://{{ bucket }}/{{ path }}/{{ var("logical_date") }}/kinopoisk-films.parquet'
{% endmacro %}
