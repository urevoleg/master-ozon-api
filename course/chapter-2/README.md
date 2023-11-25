# Если есть `html` код (и не только) и в него нужно что-то вставить

![jinja2.png](..%2F..%2Fimg%2Fjinja2.png)

Такая задача может встретиться:

* При формировании тела email
* При однотипном SQL, в котором нужно менять имена таблиц и\или значения в условиях
* Нагенерить много любого кода
.....

## html

Пример как сейчас может происходить: используется строка, в которую что-то подставляется:

```html
<h1 style="margin-bottom: 10px;"></h1>
    <span style="font-weight: normal; color: #fff; background: #1D4E89; border-radius: 10px; padding: 10px;">{metric_alert_name}</span>
    <span style="font-weight: normal; color: #333; background: #DDDDDF; border-radius: 10px; padding: 10px;">{week_day_ru}</span>
    <span style="font-weight: normal; color: #333; background: #DDDDDF; border-radius: 10px; padding: 10px;">{diff} % <span style="font-weight: 900; color: #e05263; background: #DDDDDF;">{diff_arrow}</span></span>
  <h4 style="font-weight: 100;  margin-top: 20px; letter-spacing: -1px; color: #34495E;">{formatted_date_ru}</h4>
  <h5 style="font-weight: normal;  margin-top: 10px; letter-spacing: -1px; color: #34495E;"><a href="{dashboard}">ДАШБОРД</a>   <a href="{dag}">DAG</a>   <a href="{gitlab}">GITLAB</a></h5>
    <table class="rwd-table" style="margin: 1em 0; min-width: 300px; background: #34495E; color: #fff; border-radius: .4em; overflow: hidden;">
      <tr style="border-top: 1px solid #ddd; border-bottom: 1px solid #ddd; border-color: #46637f;">
        <th style="display: table-cell; padding: 1em !important; text-align: left; color: #dd5;">Короткое описание</th>
        <th style="display: table-cell; padding: 1em !important; text-align: left; color: #dd5;">Факт</th>
        <th style="display: table-cell; padding: 1em !important; text-align: left; color: #dd5;">Норматив</th>
        <th style="display: table-cell; padding: 1em !important; text-align: left; color: #dd5;">Полное описание</th>
      </tr>
    </table>
```

Сам блок занимает много места, а требуется вставить несколько переменных: **metric_alert_name**, **week_day_ru** и др.

## SQL

Как долго вы еще будете писать эти ужасные многострочные комментарии:

```sql
ch_table_ddl_sql = (
            f"CREATE TABLE IF NOT EXISTS {self.ch_schema}.{self.ch_table} ON CLUSTER '{cluster}' (\n"
            f"{ch_schema_list} \n)\n"
            f"ENGINE = Distributed('{cluster}','{self.ch_schema}','{self.ch_table}_shard',"
            f"cityHash64({self.table_key}))"
        )
```

## Jinja2

Позаимствуем bestpractice из мира разработки, для генерации html кода используются шаблонизаторы. У нас тут Python, поэтому для нас открыт прекрасный мир jinja2.

**Jinja** - это текстовый шаблонизатор, поэтому он может быть использован для любого вида разметки - чем мы и воспользуемся.

### Что нужно чтобы начать пользоваться bestpractice:

1. Установленная jinja `python -m pip install Jinja2`
2. Шаблон - файл, в который будем что-то вставлять, для примера используем варианты выше email_body.html, create_table_template.sql
3. Немного Python кода 😎


Сначала готовим сам шаблон (как выяснили из описания, это любой текстовый файл с необходимой разметкой (чтобы jinja могла его распарсить)):

![template.png](..%2F..%2Fimg%2Ftemplate.png)

```html
<h1 style="margin-bottom: 10px;"></h1>
    <span style="font-weight: normal; color: #fff; background: #1D4E89; border-radius: 10px; padding: 10px;">{{metric_alert_name}}</span>
    <span style="font-weight: normal; color: #333; background: #DDDDDF; border-radius: 10px; padding: 10px;">{{week_day_ru}}</span>
    <span style="font-weight: normal; color: #333; background: #DDDDDF; border-radius: 10px; padding: 10px;">{{diff}} % <span style="font-weight: 900; color: #e05263; background: #DDDDDF;">{{diff_arrow}}</span></span>
  <h4 style="font-weight: 100;  margin-top: 20px; letter-spacing: -1px; color: #34495E;">{{formatted_date_ru}}</h4>
  <h5 style="font-weight: normal;  margin-top: 10px; letter-spacing: -1px; color: #34495E;"><a href="{{dashboard}}">ДАШБОРД</a>   <a href="{{dag}}">DAG</a>   <a href="{{gitlab}}">GITLAB</a></h5>
    <table class="rwd-table" style="margin: 1em 0; min-width: 300px; background: #34495E; color: #fff; border-radius: .4em; overflow: hidden;">
      <tr style="border-top: 1px solid #ddd; border-bottom: 1px solid #ddd; border-color: #46637f;">
        <th style="display: table-cell; padding: 1em !important; text-align: left; color: #dd5;">Короткое описание</th>
        <th style="display: table-cell; padding: 1em !important; text-align: left; color: #dd5;">Факт</th>
        <th style="display: table-cell; padding: 1em !important; text-align: left; color: #dd5;">Норматив</th>
        <th style="display: table-cell; padding: 1em !important; text-align: left; color: #dd5;">Полное описание</th>
      </tr>
    </table>
```

**_Ключевое:_**
- все параметры, которые мы хотим подставлять должны быть заключены в двойные фигурные скобки вот так {{metric_alert_name}}

Аналогичный шаблон создается и для SQL.


Теперь учимся парсить и рендерить наш шаблон, для этого можно использовать заготовку:

```python
from jinja2 import Environment, FileSystemLoader


def get_rendered_template(template_folder:str, template_name:str, **kwargs):
    # создаем окружение шаблонов
    env = Environment(loader=FileSystemLoader(template_folder))

    # подключаем шаблон
    template = env.get_template(template_name)

    # рендерим выходной файл
    return template.render(**kwargs)
```


Внутри любой другой функции получение готового шаблона (с подставленными значениями) выглядит так:

```python
# вызываем функцию, которая рендерит шаблон и передаем ей все аргументы
rendered_template = get_rendered_template(template_folder='templates',
                                               template_name='email_body.html',
                                               metric_alert_name=metric_alert_name,
                                               week_day_ru=week_day_ru,
                                               diff=diff,
                                               diff_arrow=diff_arrow,
                                               formatted_date_ru=formatted_date_ru,
                                               dashboard=dashboard,
                                               dag=dag,
                                               gitlab=gitlab)
```



Все параметры, которые необходимо добавить в шаблон передаются как аргументы.

Ниже показан пример магии🧙:

![jinja-example-0.png](..%2F..%2Fimg%2Fjinja-example-0.png)


Jinja2 умеет не только подставлять всякие значения, но и умеет организовать продвинутую логику, например, if\for, не зря шаблонизатор используется во фреймворке dbt

Ознакомится с другими возможностями шаблонизатора можно в [серии статей](https://proproprogs.ru/modules/ekranirovanie-i-bloki-raw-for-if)

Да, пребудет с вами красота и лаконичность кода🙌

👉 [Deeper to Jinja, go to chapter 2-1](https://github.com/urevoleg/course-dbt-fundamentals/blob/main/course/chapter-2/README-2.md)