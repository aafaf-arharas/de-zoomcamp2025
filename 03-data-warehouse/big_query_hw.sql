CREATE OR REPLACE EXTERNAL TABLE `data-warehouse-week-3.nytaxi.fhv_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://nyc-tl-data/trip data/fhv_tripdata_2019-*.csv']
);


SELECT count(*) FROM `data-warehouse-week-3.nytaxi.fhv_tripdata`;


SELECT COUNT(DISTINCT(dispatching_base_num)) FROM `data-warehouse-week-3.nytaxi.fhv_tripdata`;


CREATE OR REPLACE TABLE `data-warehouse-week-3.nytaxi.fhv_nonpartitioned_tripdata`
AS SELECT * FROM `data-warehouse-week-3.nytaxi.fhv_tripdata`;

CREATE OR REPLACE TABLE `data-warehouse-week-3.nytaxi.fhv_partitioned_tripdata`
PARTITION BY DATE(dropoff_datetime)
CLUSTER BY dispatching_base_num AS (
  SELECT * FROM `data-warehouse-week-3.nytaxi.fhv_tripdata`
);

SELECT count(*) FROM  `data-warehouse-week-3.nytaxi.fhv_nonpartitioned_tripdata`
WHERE DATE(dropoff_datetime) BETWEEN '2019-01-01' AND '2019-03-31'
  AND dispatching_base_num IN ('B00987', 'B02279', 'B02060');


SELECT count(*) FROM `data-warehouse-week-3.nytaxi.fhv_partitioned_tripdata`
WHERE DATE(dropoff_datetime) BETWEEN '2019-01-01' AND '2019-03-31'
  AND dispatching_base_num IN ('B00987', 'B02279', 'B02060');
