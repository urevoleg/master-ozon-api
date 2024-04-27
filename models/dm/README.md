'ephemeral' - работает не так как ожидается, не передаются поля из родительской модели, only cte
Ограничение на длину имени русскими буквами = 32 символа


1. Для sat_products - нужно делать бизнес историчность, тк в отчете нужна как текущая цена (фактически последняя актуальная), 
так и цена на конкретный день
2. order_date и proccessed_at имеют разницу в 3 часа - это может аффектить на расчеты
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