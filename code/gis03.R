pacman::p_load(tidyverse, here, sf, mapview)

#Read NC counties, survey sites, and Guilford Co. streams
sf_nc_county <- readRDS(file = here("data/sf_nc_county.rds"))
sf_site <- readRDS(here::here("data/sf_finsync_nc.rds"))
sf_str <- readRDS(here::here("data/sf_stream_gi.rds"))
# Spatial Join ------------------------------------------------------------

#layer x gets properties from layer y where geometry corresponds.
# in this case, our sites now have county data
sf_site_join <- st_join(x = sf_site, # base layer
                        y = sf_nc_county) #overlay layer

# check that the first site meets
mapview(sf_one <- sf_site %>% 
  slice(1)) + mapview(sf_nc_county)

# subsetting sites in Guilford county
sf_site_guilford <- sf_site_join %>% 
  filter(county == "guilford")
# subsetting Guilford county polygon
sf_nc_guilford <- sf_nc_county %>% 
  filter(county == "guilford")
# plot of Guilford-only data (streams were already Guilford-only)
ggplot() +
  geom_sf(data = sf_nc_guilford) +
  geom_sf(data = sf_str, 
          color = "steelblue") +
  geom_sf(data = sf_site_guilford,
          color = "salmon") +
  theme_bw()

# Exercise - calculate number of sites per county
# and find county with most sites
df_n <- sf_site_join %>% 
  as_tibble() %>% # so that we don't see the unneeded geospatial stuff
  group_by(county) %>% 
  summarize(n_sites = n()) %>% 
  arrange(desc(n_sites))
# add this data back to sf_nc_county as a new column
sf_nc_n <- left_join(sf_nc_county,
                     df_n,
                     by = "county") %>% 
  mutate(n_sites = ifelse(is.na(n_sites), #change NA to 0 in counties w/o sites
                                 0,
                                 n_sites))
arrange(sf_nc_n,desc(n_sites))
# mapping by number of sites
ggplot() +
  geom_sf(data = sf_nc_n,
          aes(fill = n_sites))



# Geometric analysis ------------------------------------------------------

# ALWAYS put data into projected CRS before doing geometric analysis

#Lines
sf_str_proj <- st_transform(sf_str, crs = 32617)
# vector of stream lengths using st_length() function
v_str_l <- as.numeric(st_length(sf_str_proj))
head(v_str_l)
# adding stream lengths as a column to sf_str
sf_str_w_len <- sf_str %>% 
  mutate(length = v_str_l)
ggplot() +
  geom_sf(data = sf_str_w_len,
          aes(color = length))

# in one block, and transforming back into geodetic CRS at the end
sf_str_w_len <-  sf_str %>% 
  st_transform(crs = 32617) %>% 
  mutate(length = st_length(.)) %>% # the . subs in for the piped data
  st_transform(crs = 4326)

# Area
# transform to projected
sf_nc_county_proj <- st_transform(sf_nc_county, crs = 32617)
# create vector
v_area <- as.numeric(st_area(sf_nc_county))
# add as a column to modified sf_nc_county
sf_nc_county_w_area <- sf_nc_county %>% 
  mutate(area = v_area)

# map colored by area
ggplot()+
  geom_sf(data = sf_nc_county_w_area,
          aes(fill = area))

# in one step
sf_nc_county_w_area <- sf_nc_county %>% 
  st_transform(crs = 32617) %>% 
  mutate(area = st_area(.)) %>% 
  st_transform(crs = 4326)

# Filter by geometric attributes
sf_nc_county_1000 <- sf_nc_county_w_area %>% 
  mutate(area = as.numeric(area)/1e+6) %>% # convert from m^2 to km^2
  filter(area > 1000)

ggplot() +
  geom_sf(data = sf_nc_county_1000)


# Exercises ----------------------------------------------------------------
# 1. Spatial join to identify and count New Zealand earthquakes
sf_quakes <- readRDS(here("data/sf_quakes.rds")) # load quakes
sf_nz <- readRDS(here("data/sf_nz.rds")) # load NZ polygon
mapview(sf_nz) + mapview(sf_quakes) # view quakes and NZ
sf_quakes_join <- st_join(x = sf_quakes, y = sf_nz) # join objects
sf_quakes_nz <- drop_na(sf_quakes_join, fid) # remove earthquakes not in NZ
nrow(sf_quakes_nz) # count NZ quakes

# 2. Count survey sites per county
df_n <- sf_site_join %>% 
  as.tibble() %>% 
  group_by(county) %>% 
  summarize(n_sites = n()) 
sf_nc_n <- left_join(sf_nc_county,
                       df_n,
                       by = "county") %>% 
  mutate(n_sites = ifelse(is.na(n_sites), #change NA to 0 in counties w/o sites
                           0,
                           n_sites))

# 3. Subset counties with more than 10 sites
sf_nc_n10 <- sf_nc_n %>% 
  filter(n_sites > 10)

# 4. Create map highlighting counties with more than 10 sites
ggplot() +
  geom_sf(data = sf_nc_n,
          fill = "grey") +
  geom_sf(data = sf_nc_n10,
          fill = "salmon")
