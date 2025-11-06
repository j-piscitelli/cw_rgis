# Exam II
# By submitting this exam on time, you will obtain 55 points
# 15 questions in total, with each worth 3 points
# Points will be awarded if your code produces the expected result(s)

if (!require(pacman)) install.packages("pacman")
library(pacman)

# call packages -----------------------------------------------------------

# Execute the following lines of code to call packages
p_load(tidyverse,
       sf,
       terra,
       exactextractr,
       tidyterra,
       here)

# To answer the following questions, use the data below:
df_site <- read_csv(here("data/data_finsync_nc.csv")) %>% 
  distinct(site_id, 
           lon, 
           lat)

sf_nc_county <- readRDS(here("data/sf_nc_county.rds"))

# vector data analysis ----------------------------------------------------

# Q1. 
# `df_site` currently has no coordinate reference system (CRS). 
# Convert it to an `sf` object and assign the WGS 84 CRS (EPSG: 4326). 
# Save the resulting object as `sf_site`.
sf_site <- st_as_sf(df_site,
                    coords = c("lon","lat"),
                    crs = 4326)

# Q2.
# From `sf_nc_county`, select only the county polygons of the following counties: 
#   "guilford", "randolph", "davidson", and "forsyth". 
# Save the result as `sf_four`.
sf_four <- sf_nc_county %>% 
  filter(county %in% c("guilford","randolph","davidson","forsyth"))


# Q3. 
# Perform a spatial join to identify sites in `sf_site` that fall within 
#   the four selected counties stored in `sf_four`. 
# Make sure that the output object is a POINT layer after spatial join.
# Remove any rows without a `county` value and save the result as `sf_site_four`.
sf_site_four <- st_join(x = sf_site,
                        y = sf_four) %>% 
  filter(!is.na(county))

# Q4. 
# Create a map showing the four selected counties (`sf_four`) 
#   and the sampling sites (`sf_site_four`) overlaid on the same plot. 
ggplot() +
  geom_sf(data = sf_four) +
  geom_sf(data = sf_site_four)


# Q5. 
# Calculate the pairwise distances among all sites in `sf_site_four`
#   with the appropriate CRS, UTM Zone 17N (EPSG: 32617) 
#   so that distances are measured in meters. 
sf_site_four_proj <- sf_site_four %>% 
  st_transform(crs = 32617)

df_site_four_dist <- st_distance(sf_site_four_proj)

# Then, find the maximum distance among all site pairs.

max(df_site_four_dist)

# ENTER YOUR ANSWER HERE: 71724.58 meters

# raster data analysis ----------------------------------------------------

# Q6. 
# The raster file "spr_land_reclass.tif" in the "data" folder 
#   contains reclassified land-cover data, 
#   where pixel values represent land-cover types as follows:
#   1001 = forest
#   1010 = crop
#   1100 = urban
#   0 = other
# 
# Load this raster as `spr_land` and display the unique land-cover codes it contains.

spr_land <- rast("data/spr_land_reclass.tif")

unique(spr_land$code)

# Q7. 
# Reclassify the raster `spr_land` to create a new raster object `spr_crop` 
#   that highlights only cropland areas. 
# Use the following reclassification rules:
#   1001 = 0 (forest)
#   1010 = 1 (crop)
#   1100 = 0 (urban)
#   0 = 0 (other)
cm <- cbind(c(1001,1010,1100,0),
            c(0,1,0,0))

spr_crop <- classify(spr_land,
                     rcl = cm)


# Q8. 
# Crop the cropland raster (`spr_crop`) to the extent of the four selected counties 
# (`sf_four`; "guilford", "randolph", "davidson", and "forsyth")
# Save the resulting cropped raster as `spr_crop_four`.

spr_crop_four <- crop(x = spr_crop,
                      y = sf_four)


# Q9. 
# Create a map showing the cropped cropland raster (`spr_crop_four`) 
#   overlaid with the four counties (`sf_four`). 
# Use a semi-transparent overlay for the counties.

ggplot() +
  geom_spatraster(data = spr_crop_four) +
  geom_sf(data = sf_four,
          alpha = 0.25)


# Q10. Calculate the proportion of cropland pixels within the four counties 
#   from the cropped raster (`spr_crop_four`). 
# Since cropland pixels are coded as 1 and others as 0, the mean gives the proportion.

df_crop_four <- as_tibble(spr_crop_four)
mean(df_crop_four$code)

# This is the proportion of cropland in the rectangle enclosing the four
# counties. Based on the fact that this question is not in the Vector-Raster
# Interactions section, I assume that is the quantity desired. For
# the proportion in the four counties only, not the rest of the rectangle:

# Create one polygon covering the four counties
sf_four_union <- st_as_sf(st_union(sf_four)) # I don't st_union() came up
                                            # in class, but I learned about it
                                            # while working with the Midwest
                                            # fish data, and it seems like the
                                            # thing to use in this situation.

# Extract mean value of spr_crop_four in that polygon
df_crop_prop <- exact_extract(x = spr_crop_four,
                              y = sf_four_union,
                              fun = "mean",
                              append_cols = TRUE) %>% 
  as_tibble() %>% 
  rename(crop_prop = mean)

df_crop_prop$crop_prop


# ENTER YOUR ANSWER HERE:
# 0.077 (rectangle enclosing counties)
# 0.074 (four counties only)

# (round your answer to third decimal places, e.g., 0.021)


# raster-vector interaction -----------------------------------------------

# Q11.
# The raster file "spr_tmp_nc.tif" in the "data" folder contains 
#   annual mean temperature (°C) data for North Carolina. 
# Load this raster and extract the temperature values 
#   at each sampling site in `sf_site`. 

spr_tmp_nc <- rast("data/spr_tmp_nc.tif")
sf_site_tmp <- extract(x = spr_tmp_nc,
                       y = sf_site,
                       bind = TRUE) %>% 
  st_as_sf()


# Then, identify how many sites have temperature values greater than 16°C.

nrow(filter(sf_site_tmp, temperature > 16))
# ENTER YOUR ANSWER HERE: 24 sites


# Q12. Create 3-km buffers around each site in `sf_site_four` (see Q3). 
# Be sure to first transform the coordinate reference system to UTM Zone 17N (EPSG: 32617) 
# so that the buffer distance is measured in meters.

sf_buff_proj <- sf_site_four_proj %>% 
  st_buffer(dist = 3000)


# Q13. Project the cropped cropland raster (`spr_crop_four`) 
# to the same UTM coordinate reference system (EPSG: 32617). 
# Use an appropriate re-sampling method in light of the raster data type.
spr_crop_four_proj <- terra::project(x = spr_crop_four,
               y = crs(sf_site_four_proj),
               method = "near")


# Q14. Create a map displaying the projected cropland raster (`spr_crop_proj`) 
# with 3-km site buffers (`sf_buff_proj`) overlaid.
ggplot() +
  geom_spatraster(data = spr_crop_four_proj) +
  geom_sf(data = sf_buff_proj,
          alpha = 0.25)


# Q15. Calculate the proportion of cropland within each 3-km site buffer. 
# Store the result as `df_crop_frac`, and identify the `site_id` 
# with the highest cropland fraction.

df_crop_frac <- exact_extract(x = spr_crop_four_proj,
              y = sf_buff_proj,
              fun = "mean",
              append_cols = TRUE) %>% 
  as_tibble() %>% 
  rename(crop_frac = mean)

arrange(df_crop_frac, desc(crop_frac))

# site_id with highest cropland fraction: finsync_nrs_nc-10113
