pacman::p_load(tidyverse,
               terra,
               tidyterra,
               mapview,
               stars,
               here,
               exactextractr)

# Loading data ------------------------------------------------------------


# finsync surveys sites
sf_site <- readRDS(here("data/sf_finsync_nc.rds"))

# county polygons
sf_nc_county <- readRDS(here("data/sf_nc_county.rds"))

# precipitation raster
# I don't have the complete spr_prec_nc file
# but I do have the tiles making it up...
spr_nw <- rast(here("data/spr_prec_ncnw.tif"))
spr_ne <- rast(here("data/spr_prec_ncne.tif"))
spr_sw <- rast(here("data/spr_prec_ncsw.tif"))
spr_se <- rast(here("data/spr_prec_ncse.tif"))
list_spr <- list(spr_nw,
                 spr_ne,
                 spr_sw,
                 spr_se)
spr_col <- sprc(list_spr)
#... and the ability to merge them
spr_prec_nc <- merge(spr_col)


# Pointwise extraction ----------------------------------------------------

# visualization of sites over NC precip raster
ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_site) +
  scale_fill_viridis_c() +
  theme_bw()

# extracting precip raster values at sites
# terra::extract() with x = raster and y = sf_site
sf_site_prec <- extract(x = spr_prec_nc,
                        y = sf_site,
                        bind = TRUE) %>% 
  st_as_sf()

# re-visualization with sites colored by precip
ggplot() +
  geom_sf(data = sf_nc_county,
          fill = "grey") +
  geom_sf(data = sf_site_prec,
          aes(color = precipitation)) +
  scale_color_viridis_c() +
  theme_bw()


# Zonal statistics using existing polygons --------------------------------------------------------
# i.e. summarizing raster values within some polygon
# such as a county's mean precipitation, maximum elevation, etc.
# The exactextractr package has tools for zonal analysis

# Polygon-based analysis
# First make sure that both layers use the same (projected!) CRS
sf_nc_county_proj <- st_transform(sf_nc_county,
                                  crs = 32617)
spr_prec_nc_proj <- terra::project(x = spr_prec_nc,
                                   y = crs(sf_nc_county_proj),
                                   method = "bilinear") # rather than "near"
                                                        # b/c data is continuous

# use exact_extract() to get mean precip by county
df_prec_county <- exact_extract(x = spr_prec_nc_proj,
                                y = sf_nc_county_proj,
                                fun = "mean", # we want _average_ county precip
                                append_cols = TRUE, # adds column names
                                progress = FALSE) %>% # turns off progress bar
  as_tibble() %>%
  rename(precipitation = mean) # change col name from "mean" to "precipitation"

# or you can do a different summary statistic
df_prec_county_sd <- exact_extract(x = spr_prec_nc_proj,
                                y = sf_nc_county_proj,
                                fun = "stdev", # we want _average_ county precip
                                append_cols = TRUE, # adds column names
                                progress = FALSE) %>% # turns off progress bar
  as_tibble() %>%
  rename(precipitation = stdev) # change col name from "mean" to "precipitation"


# join to other county data
sf_nc_county_prec <- sf_nc_county %>% 
  left_join(df_prec_county,
            by = "county")

# visualize
ggplot() +
  geom_sf(data = sf_nc_county_prec,
          aes(fill = precipitation)) +
  scale_fill_viridis_c() +
  theme_bw()

# Alternative method without explicit re-projection
# using fun = "weighted_mean" and
# and weights = "area"
# This is less accurate, but useful where no single UTM covers the study area
df_prec_county_alt <- exact_extract(x = spr_prec_nc,
                                    y = sf_nc_county,
                                    fun = "weighted_mean",
                                    weights = "area",
                                    append_cols = TRUE,
                                    progress = FALSE) %>% 
  as_tibble() %>% 
  rename(precipitatio = weighted_mean)



# Zonal statistics using buffers -----------------------------------------------
# To create a custom zone around a feature to
# do zonal statistics on

sf_site_proj <- sf_site %>% 
  st_transform(crs = 32617)

# st_buffer() creates buffer zone
sf_site_buff_proj <- sf_site_proj %>% 
  st_buffer(dist = 10000) # in units used by CRS; here, meters

# for visualization, reprojecting back into a geodetic CRS is preferred
sf_site_buff <- sf_site_buff_proj %>% 
  st_transform(crs = 4326)

# visualization: circular zones around points
ggplot() +
  geom_sf(data = sf_nc_county,
          fill = "grey") +
  geom_sf(data = sf_site_buff,
          fill = "salmon") +
  geom_sf(data = sf_site) +
  theme_bw()

# taking zonal statistics works the same way as with polygons
# this gets the mean precip in each buffer zone
df_prec_buff <- exact_extract(x = spr_prec_nc_proj,
                              y = sf_site_buff_proj,
                              fun = "mean",
                              append_cols = TRUE,
                              progress = FALSE) %>% 
  as_tibble() %>% 
  rename(precipitation = mean)

sf_site_prec_buff <- sf_site %>% 
  left_join(df_prec_buff,
            by = "site_id")

# visualize with precip data
ggplot() +
  geom_sf(data = sf_nc_county,
          fill = "grey") +
  geom_sf(data = sf_site_prec_buff,
          aes(color = precipitation)) +
  scale_color_viridis_c() +
  theme_bw()

# find top three sites by mean precip in buffer zone
sf_site_prec_buff %>% 
  arrange(desc(precipitation)) %>% 
  slice(1:3)

# Buffer with line vector data
sf_stream <- readRDS(here("data/sf_stream_gi.rds"))

sf_stream_proj <- sf_stream %>% 
  st_transform(crs = 32617)

sf_stream_buff_proj <- sf_stream_proj %>% 
  st_buffer(dist = 200)

sf_stream_buff <- sf_stream_buff_proj %>% 
  st_transform(crs = 4326)

ggplot() +
  geom_sf(data = sf_stream_buff,
          fill = "steelblue") +
  geom_sf(data = sf_stream,
          color = "darkblue")
