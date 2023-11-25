{% set my_var = ['once', 'twice', 'qwerty']%}
SELECT '{{ my_var }}' as external_name,
      now() as dt;