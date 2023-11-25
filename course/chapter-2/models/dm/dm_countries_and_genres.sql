{% from 'reference.sql' import ref %}
{% from 'config.sql' import materialization %}
{{materialization(type='view', schema='cdm', name='kp')}}
SELECT production_year,
       country,
       genre,
       count(1) as cnt,
       avg(imdb) as avg_imdb,
       avg(budget) as avg_budget,
       sum(box_office_usa) / sum(budget) - 1 as profit
FROM {{ ref('raw_kp') }}
GROUP BY production_year, country, genre
ORDER BY production_year
