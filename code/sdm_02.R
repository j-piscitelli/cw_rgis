pacman::p_load(tidyverse,
               terra,
               tidyterra,
               sf,
               mapview,
               here,
               ggeffects,
               exactextractr)

df_deq_raw <- read_csv(here("data/data_nc_deq.csv"))

df_deq_stadate <- df_deq_raw %>% 
  mutate(station_date = paste(StationID, Date))

df_deq_wide <- df_deq_raw %>%
  mutate(presence = 1) %>% 
  mutate(station_date = paste(StationID, Date)) %>%
  pivot_wider(id_cols = c(station_date, StationID, Date, Latitude, Longitude),
              names_from = `Scientific Name`,
              values_from = presence)

# Remove station-dates with multiple collections of the same species --------
bad_stations <- NULL


for(col in names(df_deq_wide)) {
  if (is.list(df_deq_wide[[col]])) {
    for (row in 1:nrow(df_deq_wide)) {
      if (length(df_deq_wide[[col]][[row]]) > 1) {
        bad_stations <- append(bad_stations,
                               df_deq_wide$station_date[row])
      }
    } 
  }
}

df_deq_wide <- filter(df_deq_stadate, !station_date %in% bad_stations) %>%   
  mutate(presence = 1) %>% 
  mutate(station_date = paste(StationID, Date)) %>%
  pivot_wider(id_cols = c(station_date, StationID, Date, Latitude, Longitude),
              names_from = `Scientific Name`,
              values_from = presence,
              values_fill = 0)


# Select one visit per site -----------------------------------------------
  # I think it would make sense to pick the nearest visit to the median date,
  # rather than the most recent.

  # Convert Date column from character to date class
df_deq_wide <- df_deq_wide %>% 
  mutate(Date = parse_date_time(Date,
                                orders = "m/d/y") %>% 
           as.Date())
  # Checking out distribution of dates: mostly ~1995-2017
ggplot(df_deq_wide) +
  geom_histogram(aes(x = Date))

  # I think it makes sense to use the median date rather than the mean.
median_date <- median(df_deq_wide$Date)

  # Select visit to each site that is closest to the median date
df_deq_wide <- df_deq_wide %>%
  mutate(date_diff = as.numeric(abs(Date - median_date))) %>% 
  group_by(StationID) %>%
  filter(date_diff == min(date_diff)) %>% 
  ungroup()



# Associate points with human footprint values ------------------------------------------------------------

# Place stations in space 
sf_deq <- st_as_sf(df_deq_wide,
                   coords = c("Longitude",
                             "Latitude"),
                   crs = 4326)

# Load human footprint data
spr_hfp <- rast(here("data/spr_hfp2022.tif"))

# Project in WGS 84
spr_hfp <- project(x = spr_hfp,
                   y = "EPSG:4326")

# Associate HFP values with stations
sf_deq_hfp <- extract(x = spr_hfp,
                      y = sf_deq,
                      bind = TRUE) %>% 
  st_as_sf()

# return to df
df_deq_hfp <- as_tibble(sf_deq_hfp) %>% 
  select(-geometry)

# GLM with presence of Lepomis cyanellus as response variable
m_lcyanellus <- glm(`Lepomis cyanellus` ~ hfp2022,
                 data = df_deq_hfp,
                 family = "binomial")


summary(m_lcyanellus)

