import os
import logging
logging.basicConfig(level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

from sqlalchemy import create_engine, text

from jinja2 import Environment, FileSystemLoader

from dotenv import load_dotenv
load_dotenv()


def get_rendered_template(template_folder:str, template_name:str, **kwargs):
    # создаем окружение шаблонов
    env = Environment(loader=FileSystemLoader(template_folder))

    # подключаем шаблон
    template = env.get_template(template_name)

    # рендерим выходной файл
    return template.render(**kwargs)


def save_compiled_model(file:str, folder:str='compiled'):
    with open(os.path.join(folder, file), 'w') as f:
        f.write(stmt)


def get_pg_connection():
    return create_engine(url=os.getenv('DB_URI_TMP'))


def execute_sql(stmt, engine):
    with engine.connect() as conn:
        conn.execute(stmt)
        conn.commit()
    logging.info("[SUCCESS]")


if __name__ == "__main__":
    template_name = "dm_countries_and_genres.sql"
    stmt = get_rendered_template(["../templates", "../macros", "../models", "../models/dm"],
                                 template_name)
    save_compiled_model(template_name, folder="../compiled")
    print(stmt)
    execute_sql(text(stmt), engine=get_pg_connection())