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
    city_borough AS borough,
    community_board,
    zipcode,
    street_address,
    -- Categorize location types into broader categories

FROM unique_location_ids



