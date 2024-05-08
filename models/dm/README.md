# Relations

![raw_erd.png](../../img/raw_erd.png)

--------------------------------


'ephemeral' - работает не так как ожидается, не передаются поля из родительской модели, only cte
Ограничение на длину имени русскими буквами = 32 символа


1. Для sat_products - нужно делать бизнес историчность, тк в отчете нужна как текущая цена (фактически последняя актуальная), 
так и цена на конкретный день

- `product_prices_odm` - актуальная информация по ценам (на сейчас)

2. order_date и proccessed_at имеют разницу в 3 часа - это может аффектить на расчеты (возможно это техническое ожидание очереди)
3. в report_transactions могут приходить дубли???
отбор: row_number() over (partition by operation_id order by process_date desc) as rn

```sql
with rr as (select *, cast(json_array_elements(items::json) ->> 'sku' as bigint) as sku,
                   posting::json ->> 'posting_number' as posting_id,
                   row_number() over (partition by operation_id order by process_date desc) as rn
from ods.report_transactions
where true
and posting::json ->> 'posting_number' = '0106639183-0003-1'
and service_type in ('orders', 'returns'))
select *
from rr
```

Есть две записи о возврате с разными operation_id в один день.

Из hashdiff исключен `process_date` и добавлен `service_type`:
```yaml
  report_transactions_hashdiff:
    is_hashdiff: true
    columns:
      - derived_columns.operation_id
      - derived_columns.service_type
      - derived_columns.record_source
```

Дублей нет


4. дубли в report_postings
отбор: row_number() over (partition by rp.report_posting_pk order by process_date desc) as rn
5. Для всех моделей ods используется 

```yaml
 materialized='incremental',
 incremental_strategy='delete+insert',
 unique_key=['hashdiff']
```

Некоторые модели (например, report_transactions) могут обойтись простым `incremental`, тк в hashdiff не входит 
`process_date`. В тех где входит, могут появлятся дубли, при перезагрузке каких-либо дней не в том порядке.

## DV

1. Наименовать сущности в единственном числе
2. Модель `postgres_sat_ext` - позволяет загружать json
3. `odm` - актуальное состояние сущности
4. Добавить в raw layer:
   5. `report_code`: для отчетов равен идентификатору отчета, для запросов на сейчас равен api url
   6. `created_at` для отчетов равен `created_at` из отчета, для запросов на сейчас равен моменту вызова api
7. Сущность `product` собирать из 3 частей: list + extended + prices