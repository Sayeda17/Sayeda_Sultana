-- models/location_dimension.sql
{{ config(materialized="table") }}

{{ config(materialized="table") }}

WITH combined_location_data AS (
    -- Extract data from FoodEstablishment dataset
    SELECT DISTINCT
        location_type,
        borough AS city_borough,
        community_board,
        street_name AS street_address,
        incident_zip AS zipcode
    FROM `cis9440gp.RawDataset.FoodEstablishment`
    WHERE location_type IS NOT NULL

    UNION DISTINCT

    -- Extract data from RestaurantInspection dataset
    SELECT DISTINCT
        inspection_type AS location_type,
        boro AS city_borough,
        community_board,
        street AS street_address,
        zipcode
    FROM `cis9440gp.RawDataset.RestaurantInspection`
    WHERE inspection_type IS NOT NULL
),

unique_location_ids AS (
    -- Assign unique IDs to each distinct location
    SELECT 
        ROW_NUMBER() OVER (ORDER BY location_type, city_borough, zipcode) AS location_dim_id,
        location_type,
        city_borough,
        community_board,
        zipcode,
        street_address  -- No comma here
    FROM combined_location_data
)

-- Final location dimension
SELECT 
    location_dim_id,
    location_type,
    city_borough AS borough,
    community_board,
    zipcode,
    street_address,
    -- Categorize location types into broader categories
    CASE 
        WHEN location_type IN ('Cafeteria - College/University', 'Cafeteria - Private School', 'Cafeteria - Public School') THEN 'Educational'
        WHEN location_type IN ('Food Cart Vendor', 'Mobile Food Vendor', 'Street Vendor', 'Street Fair Vendor') THEN 'Mobile Service'
        WHEN location_type IN ('Restaurant', 'Restaurant/Bar/Deli/Bakery') THEN 'Restaurant'
        WHEN location_type IN ('Catering Service', 'Catering Hall') THEN 'Catering'
        ELSE 'Other'
    END AS location_category
FROM unique_location_ids



