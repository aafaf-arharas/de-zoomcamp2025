{{
    config(
        materialized='table'
    )
}}

with filtered_trips as (
    select 
        service_type,
        extract(year from pickup_datetime) as year,
        extract(month from pickup_datetime) as month,
        fare_amount
    from {{ ref('fact_trips') }}
    where fare_amount > 0
      and trip_distance > 0
),

fare_percentiles as (
    select 
        service_type,
        year,
        month,
        approx_quantiles(fare_amount, 100)[OFFSET(90)] as fare_amount_p90,
        approx_quantiles(fare_amount, 100)[OFFSET(95)] as fare_amount_p95,
        approx_quantiles(fare_amount, 100)[OFFSET(97)] as fare_amount_p97
    from filtered_trips
    group by service_type, year, month
)

select * from fare_percentiles
order by year desc, month desc, service_type
