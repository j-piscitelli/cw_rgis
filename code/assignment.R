# Take-home assignment for 10/16/2025

if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               sf,
               mapview,
               here)

# Q1. Read the dataset "data_finsync_nc.csv" from the data subdirectory 
# and assign it to an object named `df_fish`.
# Reference: Chapter 2

# Q2. Using `df_fish`, create a dataframe with unique site name (`site_id`), 
# longitude (`lon`), and latitude (`lat`), and assign it to `df_site`.
# Hint: use `distinct()` function.
# Reference: Chapter 2

# Q3. `df_site` currently has no coordinate reference system (CRS). 
# Convert it to an `sf` object and assign the WGS 84 CRS (EPSG: 4326). 
# Save the resulting object as `sf_site`.
# Reference: Chapter 2

# Q4. Read "sf_nc_county.rds" from the data subdirectory using the `readRDS()` function.
# Assign the result to `sf_nc_county`.
# Reference: Chapter 3

# Q5. Using the `st_join()` function, associate the county column from `sf_nc_county`
# with each site in `sf_site`. Assign the result to `sf_site_w_county`.
# Reference: Chapter 3

# Q6. Convert `sf_site_w_county` to a tibble using the `as_tibble()` function.
# Assign the result to `df_site_w_county`.
# Reference: Chapter 3

# Q7. Using `df_site_w_county`, create a vector of county names that have at least one fish survey site.
# Assign the result to `v_s1`. (Hint: use group_by(), summarize(), filter(), and pull()).
# Confirm the result contains 49 counties with `length(v_s1)`.
# Reference: https://aterui.github.io/biostats/data-manipulation.html#group-operation

# Q8. Using `v_s1`, subset the county polygons in `sf_nc_county` 
# to include only counties with at least one site.
# Assign the result to `sf_county_s1`.
# Reference: https://aterui.github.io/biostats/data-manipulation.html#row-manipulation

# Q9. Display `sf_county_s1` along with all sampling sites (`sf_site`) 
# on a single map using `ggplot()` and `geom_sf()`.
# Reference: Chapter 3

# Q10. Among the counties that contain at least one sampling site, 
# calculate the area of each county polygon using `st_area()`. 
# Identify the largest county and report its area in [m^2] (should be 2,289,719,021).
# NOTE: Use a projected CRS (UTM Zone 17N) for the calculation of area.
# Reference: Chapter 2 & 3
