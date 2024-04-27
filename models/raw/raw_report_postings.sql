{{ config(
 tags=['raw_report_postings', 'report_postings', 'postings', 'raw'],
 schema='raw',
 materialized='table',
) }}

WITH raw AS (SELECT "Номер заказа",
"Номер отправления",
"Принят в обработку"::timestamp,
"Дата отгрузки"::timestamp,
"Статус",
"Дата доставки"::timestamp,
CAST("Сумма отправления" as numeric),
"Код валюты отправления",
"Наименование товара",
cast("OZON id" as bigint),
"Артикул",
cast("Итоговая стоимость товара" as numeric),
"Код валюты товара",
cast("Количество" as bigint),
"Стоимость доставки",
"Связанные отправления",
"Выкуп товара",
cast("Цена товара до скидок" as numeric),
"Скидка %",
cast("Скидка руб" as numeric),
"Акции",
'fbo' AS delivery_type
FROM {{ source('external_data', 'raw_report_postings_fbo') }}
UNION ALL
SELECT "Номер заказа",
"Номер отправления",
"Принят в обработку"::timestamp,
"Дата отгрузки"::timestamp,
"Статус",
"Дата доставки"::timestamp,
cast("Сумма отправления" as numeric),
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
FROM {{ source('external_data', 'raw_report_postings_fbs') }})
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
