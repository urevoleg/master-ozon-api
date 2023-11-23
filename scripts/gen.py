import datetime as dt
import os
import random

import uuid

import pandas as pd
from typing import List, Dict

from scipy.stats import skewnorm
from scipy.stats import rv_discrete

from sqlalchemy import create_engine

from dotenv import load_dotenv
load_dotenv()


def get_pg_connection():
    engine= create_engine(url=os.getenv("DB_URI_TMP"))
    return engine.connect()


def gen_data(n: int) -> List[Dict]:
    events = {
        1: 'login',
        2: 'main',
        3: 'page',
        4: 'cart',
        5: 'buy'
    }

    users = [uuid.uuid4() for i in range(1, 10000)]
    data = []

    distrib = rv_discrete(
        values=(sorted(list(events.keys())), [0.5, 0.2, 0.15, 0.1, 0.05]))  # This defines a Scipy probability distribution

    for _ in range(n):
        event = events[distrib.rvs(size=1)[0]]
        price = (skewnorm.rvs(a=1000, size=1) * 1000)[0]
        data += [{
            'user_id': random.choice(users),
            'event': event,
            'event_datetime': dt.datetime.now() - dt.timedelta(days=random.randint(1, 30)),
            'revenue':  price if event == 'buy' and price > 0 else None
        } ]

    return data


if __name__ == '__main__':
    data = gen_data(100000)
    pd.DataFrame(data).to_sql('events', get_pg_connection(), if_exists='replace')