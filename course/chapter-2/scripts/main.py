import os

from jinja2 import Environment, FileSystemLoader


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


if __name__ == "__main__":
    stmt = get_rendered_template(["../templates", "../macros", "../models", "../models/dm"],
                                 "kp.sql")
    save_compiled_model("kp.sql", folder="../compiled")

    print(stmt)