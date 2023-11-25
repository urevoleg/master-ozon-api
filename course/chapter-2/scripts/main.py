from jinja2 import Environment, FileSystemLoader


def get_rendered_template(template_folder:str, template_name:str, **kwargs):
    # создаем окружение шаблонов
    env = Environment(loader=FileSystemLoader(template_folder))

    # подключаем шаблон
    template = env.get_template(template_name)

    # рендерим выходной файл
    return template.render(**kwargs)


if __name__ == "__main__":
    stmt = get_rendered_template("../templates",
                                 "set-for-if-example-1.sql")

    print(stmt)