{% extends 'add_load_datetime.sql' %}
{% block query -%}
SELECT film_name
       country ,
       genre ,
       director ,
       budget ,
       box_office_usa ,
       rating_imbd
FROM stg.kinopoisk
{%- endblock %}