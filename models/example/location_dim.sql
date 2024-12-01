-- models/location_dimension.sql

{{
  config(
    materialized='table'
  )
}}


WITH combined_location_data AS (
    
    SELECT DISTINCT
        location_type,
        UPPER(borough) AS city_borough,
        community_board,
        street_name AS street_address,
        incident_zip AS zipcode
    FROM `cis9440gp.RawDataset.FoodEstablishment`
    WHERE location_type IS NOT NULL

    UNION DISTINCT

    SELECT DISTINCT
        inspection_type AS location_type,
        UPPER(boro) AS city_borough,
        community_board,
        street AS street_address,
        zipcode
    FROM `cis9440gp.RawDataset.RestaurantInspection`
    WHERE inspection_type IS NOT NULL
),

unique_location_ids AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY location_type, city_borough, zipcode) AS location_dim_id,
        location_type,
        city_borough,
        community_board,
        zipcode,
        street_address 
    FROM combined_location_data
)


SELECT 
    location_dim_id,
    city_borough,
    community_board,
    zipcode,
    street_address,

FROM unique_location_ids



