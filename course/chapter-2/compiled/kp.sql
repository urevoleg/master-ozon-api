
DROP  TABLE IF EXISTS dds.raw_kp;
CREATE  TABLE dds.raw_kp AS
SELECT *,
       now() at time zone 'utc' as load_datetime,
       'parsing' as source_name
FROM (SELECT film_name,
       lower(split_part(country, '_', 1)) as country,
       lower(split_part(genre, '_', 1)) as genre ,
       lower(split_part(director, '_', 1)) as director ,
       regexp_replace(substring(budget from '[\d+\s+]+'), '\s+', '', 'g')::int8 as budget,
       regexp_replace(substring(box_office_usa from '[\d+\s+]+'), '\s+', '', 'g')::int8 as box_office_usa,
       regexp_replace(substring(rating_imbd from '\d.\d+'), '\s+', '', 'g')::float imdb
FROM stg.kinopoisk
WHERE film_name IS NOT NULL) sq