{% macro s3_source(bucket, path) %}
    {%- set logical_date = '''{{ var("logical_date") }}''' -%}
    s3://{{ bucket }}/{{ path }}/{{ logical_date }}/*
{% endmacro %}
