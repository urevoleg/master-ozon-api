DROP  VIEW IF EXISTS cdm.kp;
CREATE  VIEW cdm.kp AS
SELECT production_year,
       country,
       genre,
       count(1) as cnt,
       avg(imdb) as avg_imdb,
       avg(budget) as avg_budget,
       sum(box_office_usa) / sum(budget) - 1 as profit
FROM dds.raw_kp
GROUP BY production_year, country, genre
ORDER BY production_year