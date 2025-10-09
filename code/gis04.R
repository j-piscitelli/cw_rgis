if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               terra,
               tidyterra,
               mapview,
               stars,
               here)

# Reading/Exporting -------------------------------------------------------
# read .tif raster data with rast() function
(spr_ex <- rast(here("data/spr_example.tif")))

# write .tif raster
writeRaster(x = spr_ex,
            filename = here("data/spr_elev.tif"),
            overwrite = TRUE)

# Visualization -----------------------------------------------------------
# creating a ggplot figure requires tidyterra package
ggplot() +
  geom_spatraster(data = spr_ex)

# stars::st_as_spars is needed to use mapview
star_ex <- st_as_stars(spr_ex)
mapview(star_ex)


# Raster data types -------------------------------------------------------
# Continuous data example: elevation
v_elev <- values(spr_ex) # these are elevation values stripped of coordinates
na.omit(v_elev) %>% 
  mean() # gets average non-NA elevation

# terra::extract() gets values from particular cells
# first argument is data source; second argument is a matrix
# [made with cbind()] of (longitude, latitude)
extract(spr_ex, y = cbind(6.0000, 50.0000)) # from one cell
extract(spr_ex, y =  tibble(lon = c(6, 5.9), lat = c(50, 49.96))) # from two cells
        # tibble() creates a matrix with a lon and lat column

# Discrete data example with binary data: NC forests
spr_for <- rast(here("data/spr_forest_nc.tif"))

unique(spr_for) # there are only two values (forest is 1, other is 0)

ggplot() +
  geom_spatraster(data = spr_for)

v_binary <- values(spr_for) 
(p_forest <- mean(v_binary)) # the mean value here means the _percent_ forest cover
                          # because there are only two values

# Discrete data example with multiple categories: land use types
spr_land <- rast(here("data/spr_land_reclass.tif"))
unique(spr_land) # there are codes like 1001, 1010, etc. corresponding to land use types
extract(spr_land, cbind(-79.8063, 36.0701)) # extract() works the same way

# Reclassing discrete data
# You might want to turn multiple categories into a binary of 0 and 1
(cm <- cbind(c(0,1001,1010,1100), c(0,1,0,0)))
          # conversion matrix: cbind(c(original), c(new value))
spr_bin <- classify(spr_land,
                    rcl = cm) # classify() reclasses data according to
                              # its second argument, rcl = [conversion matrix]
v_bin <- values(spr_bin)
mean(v_bin) # now we can get a mean that represents percent cover

# Exercises ---------------------------------------------------------------

# 1. Read in spr_prec_ncne.tif
(spr_prec_ncne <- rast(here("data/spr_prec_ncne.tif")))

# 2. Inspect raster properties and define them
# Number of rows/columns: the raster covers 162 rows and 532 columns, that is,
  # it is 162 x 532 pixels.
# Resolution: the resolution is 0.008333333 for both x and y. This means the
  # pixels correspond to areas measuring 0.008333333 degrees on each side
# Spatial extent: the minimum (x,y) are (-79.89181,35.24153), and the maximum
  # are (-75.45847,36.59153). These are the bottom left and top right corners,
  # respectively, of the rectangle including all the raster data
# Coordinate Reference System: the latitude and longitude figures are interpreted
  # according to WGS 84 (EPSG code 4326), a standard coordinate reference system
# Min and max precipitation: the minimum precipitation is 1063.1, and the maximum
  # is 1501.5. These are the highest and lowest cell values in the whole raster
  # data set. These numbers are presumably annual precipitation in millimeters.

# 3. Visualize the raster
ggplot() +
  geom_spatraster(data =  spr_prec_ncne)

# 4. Associate raster data with points from a vector data file
sf_site <- readRDS(here("data/sf_finsync_nc.rds")) # vector data of sampling sites
df_xy <- st_coordinates(sf_site) # data frame of sampling site coordinates
df_land <- extract(spr_land, df_xy) # extract land use values for each site
table(df_land) # most common land use type is 1001, forest

# 5. Reclassify spr_land to calculate percent urban land use
urbcm <- cbind(c(0,1001,1010,1100), c(0,0,0,1))
spr_urban <- classify(spr_land,
                    rcl = urbcm)
mean(values(spr_urban))
