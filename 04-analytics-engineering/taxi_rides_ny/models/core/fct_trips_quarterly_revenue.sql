{{
    config(
        materialized='table'
    )
}}

with quarterly_revenue as (
    select 
        extract(year from pickup_datetime) as year,
        extract(quarter from pickup_datetime) as quarter,
        concat(extract(year from pickup_datetime), '/Q', extract(quarter from pickup_datetime)) as year_quarter,
        service_type,
        sum(total_amount) as total_revenue
    from {{ ref('fact_trips') }}
    group by 1, 2, 3, 4
), 

yoy_growth as (
    select 
        q1.year,
        q1.quarter,
        q1.year_quarter,
        q1.service_type,
        q1.total_revenue,
        q2.total_revenue as prev_year_revenue,
        case 
            when q2.total_revenue is not null and q2.total_revenue > 0 
            then round((q1.total_revenue - q2.total_revenue) / q2.total_revenue * 100, 2)
            else null
        end as yoy_revenue_growth
    from quarterly_revenue q1
    left join quarterly_revenue q2
        on q1.service_type = q2.service_type
        and q1.quarter = q2.quarter
        and q1.year = q2.year + 1  -- Join with the previous year's quarter
)

select * from yoy_growth
order by year desc, quarter
