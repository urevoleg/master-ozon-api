{% import 'm_datetime.sql' as m %}
{% extends 'add_load_datetime.sql' %}
{% block query %}
SELECT film_name
       country ,
       genre ,
       director ,
       budget ,
       box_office_usa ,
       rating_imbd,
       '{{m.current_datetime()}}' as dt_from_macro
FROM stg.kinopoisk
{% endblock %}