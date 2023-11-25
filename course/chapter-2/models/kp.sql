{% from 'config.sql' import materialization %}
{{materialization(type='table', schema='dds', name='raw_kp')}}
{% extends 'add_load_datetime_source.sql' %}
{% block qdt -%}
SELECT film_name,
       lower(split_part(country, '_', 1)) as country,
       lower(split_part(genre, '_', 1)) as genre ,
       lower(split_part(director, '_', 1)) as director ,
       regexp_replace(substring(budget from '[\d+\s+]+'), '\s+', '', 'g')::int8 as budget,
       regexp_replace(substring(box_office_usa from '[\d+\s+]+'), '\s+', '', 'g')::int8 as box_office_usa,
       regexp_replace(substring(rating_imbd from '\d.\d+'), '\s+', '', 'g')::float imdb
FROM stg.kinopoisk
WHERE film_name IS NOT NULL
{%- endblock qdt %}
