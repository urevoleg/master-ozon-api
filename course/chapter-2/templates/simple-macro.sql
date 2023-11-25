{% macro current_datetime(column_name)%}
SELECT now() as {{column_name}}
{% endmacro %}