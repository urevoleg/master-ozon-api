{% set my_var = 'Hello, Jinja2!'%}
SELECT '{{ my_var }}' as external_name,
      now() as dt;