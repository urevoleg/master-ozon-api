{%- macro materialization(type, schema, name) -%}
DROP {% if type=='table' %} TABLE {% else %} VIEW {% endif -%} IF EXISTS {{schema}}.{{name}};
CREATE {% if type=='table' %} TABLE {% else %} VIEW {% endif -%} {{schema}}.{{name}} AS
{%- endmacro -%}