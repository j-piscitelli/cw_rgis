pacman::p_load(tidyverse,
               terra,
               tidyterra,
               mapview,
               stars,
               here)

# Cropping ----------------------------------------------------------------
# for reducing the load of big raster datasets to what you need

spr_prec <- rast(here("data/spr_prec_us.tif")) # load raster data (precip.)

ext(spr_prec) # spatial extent of layer (expressed with degrees)
              # it's very large

## Cropping to a specified coordinate range
spr_prec_crop <- crop(x = spr_prec,
                      y = c(-80, -75, 34, 37)) # c(xmin, xmax, ymin, ymax)

ext(spr_prec_crop) # the new extent is bounded by our chosen coordinates

sf_nc_county <- readRDS(here("data/sf_nc_county.rds")) # load vector layer

ggplot() +  # visualize cropped raster with NC outline
  geom_spatraster(data = spr_prec_crop) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

## Cropping to a vector's spatial extent
spr_prec_nc <- crop(x = spr_prec,
                    y = sf_nc_county) # instead of coordinates, y is entered as
                                      # a vector masking layer

ggplot() + # visualize cropped raster (covers whole rectangle bounding NC)
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

# Merging -----------------------------------------------------------------
# for when you want to unite two tiles into one
# merge() requires panels to be of the same size on the side that is merged
# and panels must not overlap

  # four tiles covering NC
spr_nw <- rast(here("data/spr_prec_ncnw.tif"))
spr_ne <- rast(here("data/spr_prec_ncne.tif"))
spr_sw <- rast(here("data/spr_prec_ncsw.tif"))
spr_se <- rast(here("data/spr_prec_ncse.tif"))

ggplot() + # visualizing one of the tiles
  geom_spatraster(data = spr_nw) + 
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

## Merge two tiles
spr_n <- merge(spr_nw, spr_ne) # merging northern two tiles

ggplot() + # visualizing merged data
  geom_spatraster(data = spr_n) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

## Merge multiple tiles

# it's most efficient to create a SpatRaster Collection (sprc)
list_spr <- list(spr_nw,# put rasters to merge in list
         spr_ne,
         spr_sw,
         spr_se)
spr_col <- sprc(list_spr) # sprc() creates as SpatRaster Collection from a list

# now we can merge the collected layers
spr_merge <- merge(spr_col)

ggplot() + # visualize merged tiles
  geom_spatraster(data = spr_merge) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)


# Stacking -------------------------------------------------------------------
# stacking adds coextensive raster layers (with coextensive cells)
# into one set of cells with multiple attributes in each cell

spr_tmp_nc <- rast(here("data/spr_tmp_nc.tif")) # loading raster of temperature to
                                            # stack with spr_prec_nc

# check that extent and resolution are equal
print(spr_prec_nc)
print(spr_tmp_nc)

# we can stack with the humble c() function!
spr_pt_nc <- c(spr_prec_nc,
               spr_tmp_nc)

print(spr_pt_nc) # the description of this object includes nlyr = 2 (two layers)
                # it also shows the sources of the two rasters
                # and min and max values of both layers
# We can reference a layer just like a column, with $
print(spr_pt_nc$precipitation)


# Reprojection ------------------------------------------------------------
# you might need to change the CRS of raster data
# importantly, you can't change it back and forth without losing fidelity

# project spr_prec_nc (currently in WGS 84) into UTM 17
spr_prec_nc_proj <- project(x = spr_prec_nc,
                            y = "EPSG:32617",
                            method = "bilinear")

## Resampling:
  # The reprojected layer will have different cell boundaries.
  # There are several methods. It's safest to specify the one you want.
  # project(method = "near") assigns each new cell the value of the nearest old
    # cell center. This is appropriate with _categorical data_.
  # project(method = "bilinear") takes the weighted average of the nearest
    # original cells. This is good for _continuous data_.
  # cubic interpolation is a method that is like bilinear interpolation but
  # smoother, appropriate for, e.g. elevation data, where change is continuous
  # more options can be found in the terra::project documentation

## Irreversibility:
  # Putting a cell through two resamplings, back and forth from one CRS, will
  # not necessarily get you the original cell boundary and value.
  # So, keep the original and reuse it if necessary.


# Exercises ---------------------------------------------------------------

# 1. Merge raster files
spr_tmp_ncnw <- rast(here("data/spr_tmp_ncnw.tif")) # load
spr_tmp_ncne <- rast(here("data/spr_tmp_ncne.tif")) # four
spr_tmp_ncsw <- rast(here("data/spr_tmp_ncsw.tif")) # raster
spr_tmp_ncse <- rast(here("data/spr_tmp_ncse.tif")) # tiles

list_spr_tmp <- list(spr_tmp_ncnw, # collect tiles into a list
                     spr_tmp_ncne,
                     spr_tmp_ncsw,
                     spr_tmp_ncse)

sprc_tmp_nc <- sprc(list_spr_tmp) # create SpatRaster Collection from list

spr_merge <- merge(sprc_tmp_nc) # merge SpatRaster Collection

ggplot() + # visualize with reference vector
  geom_spatraster(data = spr_merge) +
  geom_sf(data = sf_nc_county,
          alpha = 0,
          color = "white")

# 2. Crop raster to a defined extent
sf_camden <- sf_nc_county %>%  # get Camden County as vector polygon
  filter(county == "camden")

ext(sf_camden) # inspect extent of sf_camden

spr_tmp_camden <- crop(x = spr_merge, # crop spr_merge to Camden County
     y = sf_camden)

ggplot() +
  geom_spatraster(data = spr_tmp_camden) +
  geom_sf(data = sf_camden,
          alpha = 0,
          color = "white")


# 3. Reproject raster and explore resampling
spr_tmp_camden_proj <- project(x = spr_tmp_camden, # reproject into UTM 18
                               y = "EPSG:32618",
                               method = "bilinear") # bilinear resampling
                                                    # for continuous data

print(spr_tmp_camden_proj) # inspect CRS and resolution
