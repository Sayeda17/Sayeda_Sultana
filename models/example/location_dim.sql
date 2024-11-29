-- models/location_dimension.sql
{{ config(materialized="table") }}

WITH raw_location_data AS (
    SELECT DISTINCT
        location_type,
        borough,
        zipcode
    FROM `cis9440gp.RawDataset.FoodEstablishment`
    WHERE location_type IS NOT NULL
),

unique_location_ids AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY location_type, borough, zipcode) AS location_dim_id,
        location_type,
        borough,
        zipcode
    FROM raw_location_data
)

SELECT 
    location_dim_id,
    location_type,
    borough,
    zipcode,
    -- Optional categorization based on location_type
    CASE 
        WHEN location_type IN ('Cafeteria - College/University', 'Cafeteria - Private School', 'Cafeteria - Public School') THEN 'Educational'
        WHEN location_type IN ('Food Cart Vendor', 'Mobile Food Vendor', 'Street Vendor', 'Street Fair Vendor') THEN 'Mobile Service'
        WHEN location_type IN ('Restaurant', 'Restaurant/Bar/Deli/Bakery') THEN 'Restaurant'
        WHEN location_type IN ('Catering Service', 'Catering Hall') THEN 'Catering'
        ELSE 'Other'
    END AS location_category
FROM unique_location_ids
