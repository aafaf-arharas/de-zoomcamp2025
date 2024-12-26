-- How many taxi trips were totally made on September 18th 2019?
-- Answer : 15612
SELECT COUNT(*)
FROM yellow_taxi_trips
WHERE DATE(lpep_pickup_datetime) = '2019-09-18'
  AND DATE(lpep_dropoff_datetime) = '2019-09-18';

-- Which was the pick up day with the longest trip distance?
-- Answer : 2019-09-26
WITH DailyMaxDistances AS (
    SELECT
        DATE(lpep_pickup_datetime) AS pickup_date,
        MAX(trip_distance) AS max_trip_distance
    FROM
        yellow_taxi_trips
    GROUP BY
        pickup_date
),
LongestTripOnEachDay AS (
    SELECT
        DATE(lpep_pickup_datetime) AS pickup_date,
        trip_distance
    FROM
        yellow_taxi_trips ytt
    WHERE EXISTS (
        SELECT 1
        FROM DailyMaxDistances dmd
        WHERE DATE(ytt.lpep_pickup_datetime) = dmd.pickup_date
          AND ytt.trip_distance = dmd.max_trip_distance
    )
)
SELECT pickup_date
FROM LongestTripOnEachDay
ORDER BY trip_distance DESC
LIMIT 1;

-- Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown
-- Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
-- Answer : "Brooklyn" "Manhattan" "Queens"
SELECT
    z."Borough",
    SUM(ytt."total_amount") AS total_amount_sum
FROM
    yellow_taxi_trips ytt
JOIN
    zones z ON ytt."PULocationID" = z."LocationID"
WHERE
    DATE(ytt."lpep_pickup_datetime") = '2019-09-18'
    AND z."Borough" != 'Unknown'  -- Or however you represent unknown boroughs
GROUP BY
    z."Borough"
HAVING
    SUM(ytt."total_amount") > 50000
ORDER BY
    total_amount_sum DESC
LIMIT 3;

-- For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
-- Answer : JFK Airport, 62.31
SELECT
    dz."Zone" AS DropoffZone,
    MAX(ytt."tip_amount") AS MaxTipAmount
FROM
    yellow_taxi_trips ytt
JOIN
    zones pz ON ytt."PULocationID" = pz."LocationID"  -- Join for pickup zone
JOIN
    zones dz ON ytt."DOLocationID" = dz."LocationID"  -- Join for dropoff zone
WHERE
    ytt."lpep_pickup_datetime" BETWEEN '2019-09-01 00:00:00' AND '2019-09-30 23:59:59'   -- Filter for September 2019
    AND pz."Zone" = 'Astoria' --Filter for pickup zone Astoria
GROUP BY
    dz."Zone"
ORDER BY
    MaxTipAmount DESC
LIMIT 1;