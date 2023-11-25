{% set year_list = [2000, 2005, 2010, 2020]%}

{%- for y in year_list -%}
SELECT '{{y}}' as year,
       COUNT(CASE WHEN production_year = '{{y}}' THEN 1 ELSE NULL END) as films_cnt
FROM stg.kinopoisk
{% if not loop.last -%}
UNION ALL
{% endif -%}
{%- endfor -%}