{{ config(
 tags=['raw_report_postings', 'report_postings', 'raw'],
 target='duckdb',
 schema='raw',
 materialized='table',
 pre_hook="SET s3_region = '';
    SET s3_endpoint = '127.0.0.1:9002';
    SET s3_use_ssl = false;
    SET s3_url_style = 'path';
    SET s3_access_key_id = 's3admin';
    SET s3_secret_access_key = 's3pass_)';
    ATTACH 'dbname=tmp user=shpz password=12345 host=127.0.0.1 port=5432' AS db (TYPE POSTGRES);"
) }}

WITH raw AS (SELECT "Номер заказа",
"Номер отправления",
"Принят в обработку",
"Дата отгрузки",
"Статус",
"Дата доставки",
"Сумма отправления",
"Код валюты отправления",
"Наименование товара",
"OZON id",
"Артикул",
"Итоговая стоимость товара",
"Код валюты товара",
"Количество",
"Стоимость доставки",
"Связанные отправления",
"Выкуп товара",
"Цена товара до скидок",
"Скидка %",
"Скидка руб",
"Акции",
'fbo' AS delivery_type
FROM {{ ref('raw_report_postings_fbo') }}
UNION ALL
SELECT "Номер заказа",
"Номер отправления",
"Принят в обработку",
"Дата отгрузки",
"Статус",
"Дата доставки",
"Сумма отправления",
"Код валюты отправления",
"Наименование товара",
"OZON id",
"Артикул",
"Итоговая стоимость товара",
"Код валюты товара",
"Количество",
"Стоимость доставки",
"Связанные отправления",
"Выкуп товара",
"Цена товара до скидок",
"Скидка %",
"Скидка руб",
"Акции",
'fbs' AS delivery_type
FROM {{ ref('raw_report_postings_fbs') }})
SELECT
"Номер заказа" AS order_id,
"Номер отправления" AS posting_id,
"Принят в обработку" AS processed_at,
"Дата отгрузки" shipped_at,
"Статус" AS status,
"Дата доставки" AS delivered_at,
"Сумма отправления" AS posting_cost,
"Код валюты отправления" AS money_code_out,
"Наименование товара" AS item_name,
"OZON id" AS sku,
"Артикул" AS offer_id,
"Итоговая стоимость товара" AS marketing_price,
"Код валюты товара" AS currency_code,
"Количество" AS amount,
"Стоимость доставки" AS delivery_cost,
"Связанные отправления" AS linked_postings,
"Выкуп товара" AS repurchase_of_goods,
"Цена товара до скидок" AS old_price,
"Скидка %" AS discount,
"Скидка руб" AS discount_money,
"Акции" AS promotions,
delivery_type
FROM raw
