#!/bin/bash
cd /home/userad/projects/master-ozon-api && source venv/bin/activate
dbt docs generate --vars '{"logical_date": "2024-09-01"}' && dbt docs serve --port 18080