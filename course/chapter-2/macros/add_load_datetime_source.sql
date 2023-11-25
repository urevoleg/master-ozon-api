SELECT *,
       now() at time zone 'utc' as load_datetime,
       'parsing' as source_name
FROM ({%- block qdt %}{% endblock -%}) sq