library(tidyverse)

# ggplot exercises --------------------------------------------------------

# Draw a scatter plot of Petal.Width (x) and Petal.Length (y)
# and assign to g_petal
g_petal <- ggplot(iris, aes(x=Petal.Width,y=Petal.Length))+
  geom_point()

# Draw a boxplot between Species and Petal.Length

g_petal_box <- iris %>% 
  ggplot(aes(x=Species,y=Petal.Length, fill = Species)) +
  geom_boxplot()

# Add a new layer of points
g_petal_box + geom_point()

# Change axis labels
g_petal_box + labs(x = "Plant species", y = "Petal length")


# Refresher exercises ---------------------------------------------------------------
df_mtcars <- as_tibble(mtcars)

# select rows where cyl is 4

filter(df_mtcars, cyl==4)

# select columns mpg, disp, cyl, wt, vs, carb
select(df_mtcars, c(mpg,disp,cyl,wt,vs,carb))

# select rows where cyl is greater than 4
# then select the same columns as above
# and assign to 'df_sub'

df_sub <- df_mtcars %>% 
  filter(cyl>4) %>% 
  select(mpg,disp,cyl,wt,vs,carb)

# type the following code and run
v_car <- rownames(mtcars)

# add a new column called "car" to df_mtcars
# and update the original with it

df_mtcars <- mutate(df_mtcars, car=v_car)

# identify the lightest car (by weight, 'wt') with cyl = 8
df_mtcars %>% 
  filter(cyl==8) %>% 
  filter(wt==min(wt)) %>% 
  select(car)
# or to show the whole dataframe (where cyl = 8) arranged by weight
df_mtcars %>% 
  filter(cyl==8) %>% 
  arrange(wt)

# average weight of cars by gear number ('gear') and assign to df_mean
df_mean <- df_mtcars %>% 
  group_by(gear) %>% 
  summarize(mean_weight_by_gear_number = mean(wt))

# Using dplyr and ggplot together
# draw a figure showing the relationship between wt and qsec, but only for cars 
# with cyl=6
df_mtcars %>%
  filter(cyl==6) %>% 
  ggplot(aes(x=wt,y=qsec)) +
  geom_point()

# draw a figure between mean wt and mean qsec for each gear number
df_mtcars %>% 
  group_by(gear) %>% 
  summarize(mean_wt = mean(wt), mean_qsec = mean(qsec)) %>% 
  ggplot(aes(x=mean_wt, y=mean_qsec)) +
  geom_point()

