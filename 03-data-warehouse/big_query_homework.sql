-- Create an external table from the parquet files
CREATE OR REPLACE EXTERNAL TABLE `data-warehouse-week-3.nytaxihomework.external_yellow_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://dezoomcamp_hw3_aafaf/yellow_tripdata_2024-*.parquet']
);

-- Create a regular table from external table
CREATE OR REPLACE TABLE data-warehouse-week-3.nytaxihomework.regular_yellow_tripdata AS
SELECT * FROM data-warehouse-week-3.nytaxihomework.external_yellow_tripdata;

-- records : 20332093
SELECT count(*) FROM `data-warehouse-week-3.nytaxihomework.regular_yellow_tripdata`;

-- distinct PULocationID : 155.12 MB 
SELECT COUNT(DISTINCT(PULocationID)) FROM `data-warehouse-week-3.nytaxihomework.external_yellow_tripdata`;
SELECT COUNT(DISTINCT(PULocationID)) FROM `data-warehouse-week-3.nytaxihomework.regular_yellow_tripdata`;

-- fareamount 0 :
SELECT COUNT(*) AS zero_fare_trips
FROM `data-warehouse-week-3.nytaxihomework.regular_yellow_tripdata`
WHERE fare_amount = 0;

-- optimized table 
CREATE OR REPLACE TABLE `data-warehouse-week-3.nytaxihomework.optimized_yellow_tripdata`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `data-warehouse-week-3.nytaxihomework.regular_yellow_tripdata`;

-- distinct vendor id comparaison
SELECT DISTINCT VendorID
FROM `data-warehouse-week-3.nytaxihomework.optimized_yellow_tripdata`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';

