-- During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, respectively, happened:
-- Up to 1 mile 
-- In between 1 (exclusive) and 3 miles (inclusive),
-- In between 3 (exclusive) and 7 miles (inclusive),
-- In between 7 (exclusive) and 10 miles (inclusive),
-- Over 10 miles
-- Answer :  104830	198995	109642	27686	35201
SELECT 
    SUM(CASE WHEN trip_distance <= 1 THEN 1 ELSE 0 END) AS trips_up_to_1_mile,
    SUM(CASE WHEN trip_distance > 1 AND trip_distance <= 3 THEN 1 ELSE 0 END) AS trips_between_1_and_3_miles,
    SUM(CASE WHEN trip_distance > 3 AND trip_distance <= 7 THEN 1 ELSE 0 END) AS trips_between_3_and_7_miles,
    SUM(CASE WHEN trip_distance > 7 AND trip_distance <= 10 THEN 1 ELSE 0 END) AS trips_between_7_and_10_miles,
    SUM(CASE WHEN trip_distance > 10 THEN 1 ELSE 0 END) AS trips_over_10_miles
FROM yellow_taxi_trips
WHERE lpep_pickup_datetime >= '2019-10-01'
  AND lpep_pickup_datetime < '2019-11-01';


-- Which was the pick up day with the longest trip distance?
-- Answer : 2019-10-31
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

-- Which were the top pickup locations with over 13,000 in total_amount (across all trips) for 2019-10-18?
-- Consider only lpep_pickup_datetime when filtering by date.
-- Answer : East Harlem North, East Harlem South, Morningside Heights

SELECT 
    z."Zone",
    SUM(ytt."total_amount") AS total_amount_sum
FROM 
    yellow_taxi_trips ytt
JOIN 
    zones z ON ytt."PULocationID" = z."LocationID"
WHERE 
    DATE(ytt."lpep_pickup_datetime") = '2019-10-18'
GROUP BY 
    z."Zone"
HAVING 
    SUM(ytt."total_amount") > 13000
ORDER BY 
    total_amount_sum DESC;

-- For the passengers picked up in Ocrober 2019 in the zone name "East Harlem North" which
-- was the drop off zone that had the largest tip?

SELECT 
    z."Zone" AS dropoff_zone,
    SUM(ytt."tip_amount") AS total_tips
FROM 
    yellow_taxi_trips ytt
JOIN 
    zones z ON ytt."DOLocationID" = z."LocationID"
JOIN 
    zones pickup_zone ON ytt."PULocationID" = pickup_zone."LocationID"
WHERE 
    pickup_zone."Zone" = 'East Harlem North'
    AND DATE(ytt."lpep_pickup_datetime") BETWEEN '2019-10-01' AND '2019-10-31'
GROUP BY 
    z."Zone"
ORDER BY 
    total_tips DESC
LIMIT 1;

-- For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
-- Answer : JFK Airport, 87.3
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
    ytt."lpep_pickup_datetime" BETWEEN '2019-10-01 00:00:00' AND '2019-10-30 23:59:59'  
    AND pz."Zone" = 'East Harlem North'
GROUP BY
    dz."Zone"
ORDER BY
    MaxTipAmount DESC
LIMIT 1;

-- ZoomCamp 2024 
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
    AND z."Borough" != 'Unknown' 
GROUP BY
    z."Borough"
HAVING
    SUM(ytt."total_amount") > 50000
ORDER BY
    total_amount_sum DESC
LIMIT 3;

-- How many taxi trips were totally made on September 18th 2019?
-- Answer : 15612
SELECT COUNT(*)
FROM yellow_taxi_trips
WHERE DATE(lpep_pickup_datetime) = '2019-09-18'
  AND DATE(lpep_dropoff_datetime) = '2019-09-18';