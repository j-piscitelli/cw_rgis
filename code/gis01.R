# if (!require(pacman)) install.packages("pacman")
#pacman::p_load(tidyverse,sf,mapview,here)

# Coordinate systems ------------------------------------------------------
## reading the data into R
library(tidyverse)
library(sf)
library(mapview)
library(here)
df_fish <- read_csv(here::here("data/data_finsync_nc.csv"))

sf_site <- df_fish %>% 
  distinct(site_id, lon, lat) %>% #extracts unique sites with their coordinates
  st_as_sf(coords = c("lon","lat"), crs=4326) # converts table to georeferenced df
# st_as_sf(coords=c()) takes a vector with column of longitude first, then column of latitude
# crs is coordinate reference system; 4326 is WGS 84
# the number is its EPSG code

class(sf_site)

## putting it onto the map
mapview(sf_site, legend = FALSE)

## saving the sf to data folder for future use
saveRDS(sf_site,
        file = here::here("data/sf_finsync_nc.rds"))


##Converging from geodetic to projected CRS

sf_ft_wgs <- sf_site %>% 
  slice(c(1,2)) # selects the first two rows for simplicity

sf_ft_utm <- sf_ft_wgs %>% 
  st_transform(crs = 32617) # transforms sf_ft_wgs to a projected CRS
# CRS 32617 is a UTM appropriate for North Carolina (UTM 17 North)

st_distance(sf_ft_utm) # since we're in a projected CRS, we can measure distance

mapview(sf_ft_wgs)


# Exercises ---------------------------------------------------------------

# load the data
df_quakes <- as_tibble(quakes)
print(df_quakes)

# convert to an sf object
sf_quakes <- st_as_sf(df_quakes, coords = c("long","lat"), crs=4326)

mapview(sf_quakes)

# calculate distance between two points
sf_ft_quakes <- sf_quakes %>% 
  slice(c(1,2))

sf_ft_quakes_proj_17 <- st_transform(sf_ft_quakes, crs = 32617)
sf_ft_quakes_proj_NZ <- st_transform(sf_ft_quakes, crs = 27200)

st_distance(sf_ft_quakes_proj_17)
st_distance(sf_ft_quakes_proj_NZ)
st_distance(sf_ft_quakes)

mapview(sf_ft_quakes_proj_17) # in CRS for North Carolina
mapview(sf_ft_quakes_proj_NZ) # in CRS for New Zealand
mapview(sf_ft_quakes) # in WGS84

# export the spatial object
saveRDS(sf_quakes, file = here::here("data/sf_quakes.rds"))
