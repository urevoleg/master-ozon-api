

## Infra

Мне удобно работать локально:
- в качестве хранилища будет Postgres - (aka GreenPlum на минималках)
- источники придумаем (как минимум загрузим что-то из CSV или из S3 (мы взрослые дядьки, мы так умеем))
- в качестве speed-layer будем использовать ClickHouse
- в докере поднимем какой-нибудь BI (MetaBase или еще что)

### Поднимаем инфру

![infra.png](..%2F..%2Fimg%2Finfra.png)

1. Postgres

```
docker run --restart always --name pg13 -d -p 5432:5432 --shm-size=1gb  -e POSTGRES_DB=db -e POSTGRES_USER=pgadmin -e POSTGRES_PASSWORD=12345 -d postgres:13
```

2. ClickHouse

```
docker run -d --name clickhouse-server -e CLICKHOUSE_USER=clickadmin -e CLICKHOUSE_PASSWORD=aLpjr5HMq -p 8123:8123 -p 9000:9000 --ulimit nofile=262144:262144 yandex/clickhouse-server
```

Клиент для подключения к базам, например, [Dbeaver](https://dbeaver.io/download/). Естественно перед запуском контейнеров нужно установить docker - 
это самостоятельный шаг 🚶‍♂️


Идем дальше, по хардкору уcтановим расширение [aws_s3](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PostgreSQL.S3Import.html),
чтобы Postgres умел сам ходить в S3 (аля PXF в GreenPlum).

Пользовался [инструкцией](https://github.com/chimpler/postgres-aws-s3), что еще может потребоваться:
1. Может не быть расширения `plpython3u`

Делаем следующее, ищем нужный пакет для вашей версии pg - `apt-cache search ".*plpython3.*"`

![install_plpython_3u.png](..%2F..%2Fimg%2Finstall_plpython_3u.png)

2. Сначала подключаем расширение `plpython3u`, после `aws_s3`

![create_extensions.png](..%2F..%2Fimg%2Fcreate_extensions.png)

3. Может потребоваться устновить `apt install python3-boto3` - именно такой командой


❇️ DONE: расширения успешно подключены

⚠️ CHECK: проверить/настроить подключение к pg/clickhouse из твоего любимого клиента или из консоли

------------------------------------------

### Layers

Инфра готова, следующий шаг: придумать архитектуру. Слоев в хранилище может быть много:
* STG (Staging) — хранилище консолидированной информации из источников _AS IS_
* ODS (Operational Data Store) — хранилище операционных данных.
* DDS (Detail Data Store) — хранилище детальных исторических данных.
* CDM (Common Data Marts) — слой широких витрин.
* REP (Reporting) — слой детальных витрин, или отчётов.

Все слои мы делать не будем, но обязательными будут:
- **stg** - данные как они есть в источнике _AS IS_
- **dds** - здесь есть модель данных (Dimensional\3NF or DataVault\AnchorModeling)
- **cdm** - широкие витрины-отчеты

Иногда между stg <-> dds добавляют raw-layer - "stg" для dds, из stg в raw могут выполнятся какие-либо нормализации:
- приведение типов
- исключение пропусков
- добавление служебных полей
- и др

dbt живет у нас в слоях raw-dds-cdm, поэтому никто не мешает нам подключить первый источник данных из s3 (у нас же всё по-взрослому)🤘

```sql
CREATE SCHEMA stg;
CREATE SCHEMA dds;
CREATE SCHEMA cdm;
```

------------------------------------------

## Where is data, Lebowski

![where_is_data.gif](..%2F..%2Fimg%2Fwhere_is_data.gif)

Используем данные, спарсенные с [kinopoisk.ru](https://www.kinopoisk.ru/) по фильмам. Данные доступны по [ссылке](https://storage.yandexcloud.net/public-bucket-6/data/kinopoisk_parsing.csv)
Они лежат в YandexObject Storage - наш ответ AWS S3.

Будем подключаться🔌

Создаем таблицу в которую будут импортироваться данные из S3:

```sql
CREATE TABLE stg.kinopoisk (
    id int,
    search_item varchar,
    search_url varchar,
    film_id varchar,
    film_url varchar,
    film_name varchar,
    production_year varchar,
    country varchar,
    genre varchar,
    director varchar,
    screenwriter varchar,
    operator varchar,
    compositor varchar,
    painter varchar,
    mount varchar,
    budget varchar,
    box_office_usa varchar,
    box_office_world varchar,
    box_office_russia varchar,
    rating_kp_top float,
    marks_amount_kinopoisk varchar,
    rating_kp_pos varchar,
    rating_kp_neu varchar,
    rating_kp_neg varchar,
    rating_imbd varchar,
    marks_amount_imbd varchar,
    release_world varchar,
    release_russia varchar,
    digital_release varchar,
    checked_at varchar,
    error varchar,
    poster_link varchar,
    film_descr varchar
);
```

Для подключения необходимо создать некоторые объекты (команды выполняются из консоли):
1. `s3_uri`

```sql
SELECT aws_commons.create_s3_uri(
   'public-bucket-6', -- bucket-name
   'kinopoisk_parsing.csv', -- filename
   'ru-central1' -- always region
) AS s3_uri \gset
```

2. `credentials`

```sql
SELECT aws_commons.create_aws_credentials(
   'YCAJEmLAkZVKmRQ3RR3lGoQb9', -- access_key
   '<my_secret_key>', -- secret-key
   ''
) AS credentials \gset
```

Финально подключаемся к файлу:

```sql
SELECT aws_s3.table_import_from_s3(
   'kinopoisk_parsing',
   '',
   '(FORMAT CSV, DELIMITER ';','', HEADER true)',
   :'s3_uri',
   :'credentials'
);
```
ps: попытка засчитана, расширение пытается подключиться, но тк утилита настроена по дефолту работать с AWS то и endpoint ведет туда 🤷

![aws_s3_error.png](..%2F..%2Fimg%2Faws_s3_error.png)

![crash_truck.png](..%2F..%2Fimg%2Fcrash_truck.png)

Альтернативный вариант с `COPY` (пока так можно):

```sql
COPY kinopoisk FROM PROGRAMM 'curl https://storage.yandexcloud.net/public-bucket-6/data/kinopoisk_parsing.csv' 
DELIMITER ';' CSV HEADER;
```

Чекаем данные:

![check_after_copy.png](..%2F..%2Fimg%2Fcheck_after_copy.png)

Проверка типов данных:

![check_datatypes.png](..%2F..%2Fimg%2Fcheck_datatypes.png)

☝️ИТОГ:
- разобрали способ доставки данных из S3 в DWH
- данные загружены

--------------------------------

roadmap:
- первые модельки
- transform from stg.table to dds.stg_table
