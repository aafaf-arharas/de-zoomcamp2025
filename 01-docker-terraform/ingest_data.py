#!/usr/bin/env python
# coding: utf-8

import os
import gzip
import argparse

from time import time

import pandas as pd
from sqlalchemy import create_engine


def ingest_zones_data(zones_data_url, engine):
    csv_name = "./csv_files/taxi_zone_lookup.csv"
    os.system(f"wget {zones_data_url} -O {csv_name}")
    df_zones = pd.read_csv(csv_name)
    df_zones.to_sql(name='zones', con=engine, if_exists='replace')

def ingest_trip_data(trip_data_url, engine, table_name) :
    # the backup files are gzipped, and it's important to keep the correct extension
    # for pandas to be able to open the file
    if trip_data_url.endswith('.csv.gz'):
        csv_name = './csv_files/yellow_trip_data.csv.gz'
    else:
        csv_name = './csv_files/yellow_trip_data.csv'
    
    os.system(f"wget {trip_data_url} -O {csv_name}")
    os.system(f"gunzip {csv_name}")

    df_iter = pd.read_csv(csv_name[:-3], iterator=True, chunksize=100000)

    df = next(df_iter)

    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)

    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    df.to_sql(name=table_name, con=engine, if_exists='append')


    while True: 

        try:
            t_start = time()
            
            df = next(df_iter)

            df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
            df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)

            df.to_sql(name=table_name, con=engine, if_exists='append')

            t_end = time()

            print('inserted another chunk, took %.3f second' % (t_end - t_start))

        except StopIteration:
            print("Finished ingesting data into the postgres database")
            break

def main(params):
    user = params.user
    password = params.password
    host = params.host 
    port = params.port 
    db = params.db
    table_name = params.table_name
    trip_data_url = params.trip_data_url
    zones_data_url = params.zones_data_url

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')
    ingest_trip_data(trip_data_url, engine, table_name)
    ingest_zones_data(zones_data_url, engine)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--user', required=True, help='user name for postgres')
    parser.add_argument('--password', required=True, help='password for postgres')
    parser.add_argument('--host', required=True, help='host for postgres')
    parser.add_argument('--port', required=True, help='port for postgres')
    parser.add_argument('--db', required=True, help='database name for postgres')
    parser.add_argument('--table_name', required=True, help='name of the table where we will write the results to')
    parser.add_argument('--trip_data_url', required=True, help='url of the csv file of trip data')
    parser.add_argument('--zones_data_url', required=True, help='url of the csv file of zones data')

    args = parser.parse_args()

    main(args)

"""
### call main :
python ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --trip_data_url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz" \
    --zones_data_url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"
"""