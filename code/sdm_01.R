pacman::p_load(tidyverse,
               terra,
               tidyterra,
               mapview,
               stars,
               sf,
               here,
               ggeffects,
               exactextractr)

## Species Distribution Modeling

# How does temperature affect presence of Lepomis auritis?
# Hypothesis: significant positive correlation between
# temperature and L. auritis presence

# Preparing ecological data -------------------------------------------------

# Loading data
df_finsync <- read_csv(here("data/data_finsync_nc.csv"))

# Looking at structure: each row is one site-species, not one site
# Only presence data, not absence, is explicitly recorded
df_st1 <- df_finsync %>% 
  filter(site_id == "finsync_nrs_nc-10013")

# Reformat so one row is one site, with columns for all species
df_finsync %>% 
  pivot_wider(id_cols = c(site_id, lon, lat), # Retain these columns
              names_from = latin, # New columns for each fish name
              values_from = presence, # with their values from presence
              values_fill = 0) # replace NA's in presence column with 0s

# Reduce to focal species (redbreast sunfish)
df_rbs <- df_finsync %>% 
  pivot_wider(id_cols = c(site_id, lon, lat), # Retain these columns
              names_from = latin, # New columns for each fish name
              values_from = presence, # with their values from presence
              values_fill = 0) %>% # replace NA's in presence column with 0s
  select(site_id,
         lon,
         lat,
         "Lepomis auritus") %>% # select site-locating columns and focal species
  rename(y = "Lepomis auritus") # rename species name column to 'y'


# Linking sites to environmental data -------------------------------------

# Put data frame into spatial format
sf_rbs <- df_rbs %>% 
  st_as_sf(coords = c("lon","lat"),
           crs = 4326)

# Read in temperature raster
spr_tmp_nc <- rast(here("data/spr_tmp_nc.tif"))
spr_tmp_nc # Check that it uses the same CRS as the site data!


# Associate temp values with survey sites
sf_rbs_tmp <- extract(x = spr_tmp_nc,
                      y = sf_rbs,
                      bind = TRUE) %>% 
  st_as_sf() # puts into sf format rather than terra's spatvector

# Return to non-spatial format for ease of analysis
df_rbs_tmp <- as_tibble(sf_rbs_tmp) %>% 
  select(-geometry) # remove spatial information


# Visualization -----------------------------------------------------------

# On a map
ggplot() +
  geom_spatraster(data = spr_tmp_nc) + # display temperature data
  geom_sf(data = sf_rbs, # display sites
          aes(color = factor(y))) + # color sites by presence/absence
  scale_fill_viridis_c() +
  theme_bw()

# On a graph
df_rbs_tmp %>% 
  ggplot(aes(y = y,
             x = temperature)) +
  geom_point() +
  labs(x = "Air temperature",
       y = "Presence of Lepomis auritis") +
  theme_bw()


# Analysis ----------------------------------------------------------------

# Logistic regression model (appropriate for binary response variable)
m_rbs <- glm(y ~ temperature,
         data = df_rbs_tmp,
         family = "binomial")
summary(m_rbs)

# Visualization
# Prediction of probability of presence by temperature
df_pred <- ggpredict(m_rbs,
                     terms = "temperature [all]") # "... [all]" tells the
                                                  # function to predict over the
                                                  # whole range of temperatures;
                                                  # for a range e.g. 0-10:
                                                  # "temperature [0:10]"
# Plot with data, relationship, and confidence interval
ggplot() +
  geom_point(data = df_rbs_tmp, # observed presence/absence
             aes(x = temperature,
                 y = y)) + 
  geom_line(data = df_pred,
            aes(x = x,
                y = predicted)) + # probability prediction from ggpredict()
  geom_ribbon(data = df_pred,
              aes(x = x,
                  ymin = conf.low,
                  ymax = conf.high), # 95% confidence interval
              fill = "grey",
              alpha = 0.2) +
  labs(x = "Air temperature",
       y = "Probability of occurrence") +
  theme_bw()
