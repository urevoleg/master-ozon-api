{{ config(
 tags=['stg_report_products', 'report_products', 'stg'],
 target='duckdb',
 schema='stg',
 materialized='table',
) }}

{%- set yaml_metadata -%}
source_model: raw_report_products
derived_columns:
  load_datetime: CAST(now() as timestamp)
  record_source: '!report_products'
  proccess_date: CAST('{{ var("logical_date") }}' as date)
  offer_id:
    source_column: CAST(RIGHT("Артикул", LENGTH("Артикул")-1) as varchar)
  product_id:
    source_column: CAST("Ozon Product ID" as varchar)
  barcode:
    source_column: CAST("Barcode" as varchar)
    alias: barcode
  fbs_sku:
    source_column: CAST("FBS OZON SKU ID" as varchar)
  fbo_sku:
    source_column: CAST("FBO OZON SKU ID" as varchar)
  item_name: '"Наименование товара"'
  content_rating: '"Контент-рейтинг"'
  brand: '"Бренд"'
  item_status: '"Статус товара"'
  is_fbo_visible: '"Видимость FBO"'
  reason_fbo_visible: '"Причины скрытия FBO (при наличии)"'
  is_fbs_visible: '"Видимость FBS"'
  reason_fbs_visible: '"Причины скрытия FBS (при наличии)"'
  created_at: '"Дата создания"'
  category_comission: '"Категория комиссии"'
  item_volume: '"Объем товара, л"'
  item_weight: '"Объемный вес, кг"'
  fbo_free_to_sell_amount: '"Доступно к продаже по схеме FBO, шт."'
  exclude_tver: '"Вывезти и нанести КИЗ (кроме Твери), шт"'
  reserved_amount: '"Зарезервировано, шт"'
  fbs_free_to_sell_amount: '"Доступно к продаже по схеме FBS, шт."'
  rfbs_free_to_sell_amount: '"Доступно к продаже по схеме realFBS, шт."'
  seller_reserved_amount: '"Зарезервировано на моих складах, шт"'
  price: '"Текущая цена с учетом скидки, ₽"'
  old_price: '"Цена до скидки (перечеркнутая цена), ₽"'
  premium_price: '"Цена Premium, ₽"'
  marketing_price: '"Рыночная цена, ₽"'
  link_marketing_price: '"Актуальная ссылка на рыночную цену"'
  nds: '"Размер НДС, %"'
hashed_columns:
  product_pk:
    is_hashdiff: true
    columns:
      - derived_columns.product_id
      - derived_columns.offer_id
      - derived_columns.barcode
      - derived_columns.fbs_sku
      - derived_columns.fbo_sku
  daily_hashdiff:
    is_hashdiff: true
    columns:
      - derived_columns.product_id
      - derived_columns.offer_id
      - derived_columns.barcode
      - derived_columns.fbs_sku
      - derived_columns.fbo_sku
      - CAST('{{ var("logical_date") }}' as date)
      - '!report_products'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=no,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}

