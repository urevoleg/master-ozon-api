import datetime as dt
import os
import random

import uuid

from fake_web_events import Simulation

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


def gen_data(n_session_per_day: int=50000, users: int = 1000) -> List[Dict]:
    simulation = Simulation(user_pool_size=users, sessions_per_day=n_session_per_day)
    events = simulation.run(duration_seconds=5)

    data = []

    for event in events:
        event.update({'event_timestamp': dt.datetime.utcnow() + dt.timedelta(days=random.randint(-30, 0))})
        data += [event]
    return data


if __name__ == '__main__':
    import csv
    # data = gen_data(n_session_per_day=100000000, users=1000)
    df = pd.read_csv(os.path.join(os.path.expanduser('~'), 'Downloads', 'appm.csv'),
                     sep=',', skiprows=[0, 1], parse_dates=True)
    print(df.head())
    print(df.shape)
    df.to_sql('events', get_pg_connection(), if_exists='replace', schema='stg')

