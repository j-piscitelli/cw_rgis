library(tidyverse)
library(sf)
library(mapview)
library(here)

# Read and export vector data ---------------------------------------------


# read a shapefile (e.g., ESRI Shapefile format)
# `quiet = TRUE` just for cleaner output
# for .shp, no need to call .dbf etc.
(sf_nc_county <- st_read(dsn = here("data/nc.shp"),
                         quiet = TRUE))

# write to .shp and .gpkg
# 'append = FALSE' means the file will overwrite any previous file with that
# name, rather than add data points to it.
st_write(sf_nc_county,
         dsn = here("data/sf_nc_county.shp"),
         append = FALSE)
st_write(sf_nc_county,
         dsn = here("data/sf_nc_county.gpkg"),
         append = FALSE)

# save as .rds (not compatible with non-R software)
saveRDS(sf_nc_county,
        file = here("data/sf_nc_county.rds"))

# read a saved .rds file
sf_nc_county <- readRDS(file = here("data/sf_nc_county.rds"))


# Points ------------------------------------------------------------------

# This file contains a set of point data
(sf_site <- readRDS(here::here("data/sf_finsync_nc.rds")))

# View points
mapview(sf_site,
        col.regions = "black", 
        legend = FALSE)

# subsetting works the same as in any other data frame
(sf_site_f10 <- sf_site %>% 
    slice(1:10))

mapview(sf_site_f10,
        col.regions = "black",
        legend = FALSE)


# Lines -------------------------------------------------------------------

# This file contains line data (streams of Guilford County)
(sf_str <- readRDS(here::here("data/sf_stream_gi.rds")))

mapview(sf_str,
        color = "steelblue",
        legend = FALSE)

# The first ten segments are a random bunch of little lines
(sf_str_f10 <- sf_str %>% 
    slice(1:10))

mapview(sf_str_f10,
        color = "steelblue",
        legend = FALSE)


# Polygons ----------------------------------------------------------------

# Viewing the county data from earlier
mapview(sf_nc_county,
        color = "steelblue",
        col.regions = "tomato",
        legend = FALSE)

# Just Guilford County, using filter()
(sf_nc_gi <- sf_nc_county %>% 
    filter(county == "guilford"))

mapview(sf_nc_gi)


# Mapping vector data -----------------------------------------------------

# You can put a map on a plot! And overlay multiple data sets
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_site,
          color = "gray") +
  geom_sf(data = sf_str)

# but two layers covering the same area may not match up exactly...
ggplot() +
  geom_sf(data = sf_nc_gi,
          fill = "lightgreen")+
  geom_sf(data = sf_str,
          color = "steelblue")


# Exercise ----------------------------------------------------------------

# Read stream line data for Ashe County
sf_str_as <- readRDS(file = here("data/sf_stream_as.rds"))

# Confirm that the CRS matches the county data set
print(sf_str_as) # CRS is WGS 84
print(sf_nc_county) # CRS is WGS 84

# Export as .gpkg
#st_write(sf_str_as,
#         dsn = "data/sf_stream_ashe.gpkg",
#         append = FALSE)
          # error: wrong field type for fid

# Map streams along with county boundaries
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_str_as)

# Subset county layer to Ashe County and remap
sf_nc_as <- sf_nc_county %>% 
  filter(county == "ashe") # subsetting

ggplot() +
  geom_sf(data = sf_nc_as) +
  geom_sf(data = sf_str_as,
          color = "steelblue") # re-mapping

