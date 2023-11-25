{% set my_list = ['once', 'twice', 'qwerty']%}

{% for elem in my_list%}
SELECT '{{ elem }}' as external_name,
      now() as dt
{% if not loop.last %}
UNION ALL
{% endif %}
{% endfor %}