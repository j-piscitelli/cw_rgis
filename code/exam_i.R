# Tidyverse Exam – Data Manipulation in R (using `mtcars` dataset)

# tidyverse ---------------------------------------------------------------

# Use `df_mtcars` for Questions 1 - 10
library(tidyverse)
df_mtcars <- as_tibble(mtcars,
                       rownames = "model")

# 1. Filter rows where number of cylinders (`cyl`) is 6
# Write code to create a new data frame that only includes rows where `cyl == 6`.
# Assign to: `mtcars_cyl6`
mtcars_cyl6 <- filter(df_mtcars, cyl == 6)

# 2. Filter rows where number of gears (`gear`) is either 3 or 5
# Use `%in%` to filter the `df_mtcars` dataset for these two `gear` values.
# Assign to: `mtcars_g35`

mtcars_g35 <- filter(df_mtcars, gear %in% c(3,5))

# 3. Filter rows where miles per gallon (`mpg`) is greater than 25
# Create a subset of `df_mtcars` where `mpg > 25`.
# Assign to: `mtcars_mpg25`

mtcars_mpg25 <- filter(df_mtcars, mpg > 25)

# 4. Filter rows where weight (`wt`) is less than 2.5 AND number of cylinders (`cyl`) is 4
# Combine logical conditions using `&`.
# Assign to: `mtcars_light_cyl4`

mtcars_light_cyl4 <- filter(df_mtcars, wt < 2.5 & cyl ==4)

# 5. Sort `df_mtcars` by horsepower (`hp`) in ascending order
# Use `arrange()` to sort the data.
# Assign to: `mtcars_hp`

mtcars_hp <- arrange(df_mtcars, hp)

# 6. Sort `df_mtcars` by quarter mile time (`qsec`) in descending order
# Use `desc()` inside `arrange()`.
# Assign to: `mtcars_qsec`

mtcars_qsec <- arrange(df_mtcars, desc(qsec))

# 7. Exclude the `drat` column
# Use `select()` with `-` (minus sign) to remove the column.
# Assign to: `mtcars_no_drat`

mtcars_no_drat <- select(df_mtcars, -drat)

# 8. Add a new column `ptw` that equals the ratio of horsepower (`hp`) to weight (`wt`) (`hp / wt`)
# Use `mutate()` to add the new column.
# Assign to: `mtcars_with_ptw`

mtcars_with_ptw <- mutate(df_mtcars, ptw = hp/wt)

# 9. Identify the car `model` with the highest `ptw` among cars with six cylinders (`cyl == 6`).
# Hint: Use `mtcars_with_ptw` and a chain of `filter()` and `arrange()` with `%>%`.
mtcars_with_ptw %>% 
  filter(cyl == 6) %>% 
  arrange(desc(ptw))

# Write the car model here: FERRARI DINO

# 10. Group by number of gears (`gear`) and summarize minimum & maximum values of `mpg`
# Use `group_by()` and `summarize()` to calculate minimum & maximum values of `mpg` within each group.
# Minimum and maximum values of each group should be represented as separate columns.
# Function `min()` returns the minimum value in a vector.
# Function `max()` returns the maximum value in a vector.
# Assign to: `mtcars_mpg_by_gear`

mtcars_mpg_by_gear <- df_mtcars %>% 
  group_by(gear) %>% 
  summarize(min(mpg), max(mpg))


# ggplot ------------------------------------------------------------------

# Visualization in R (using `iris` dataset)

## before you begin with the following questions, type the following code to check column names in the dataframe
colnames(iris) # output from this code is the column names that can be used in figures

# 11. Simple scatter plot of `Sepal.Length` vs `Sepal.Width` using `ggplot()`
# Assign to: `g_scat`
# Create a scatter plot with `Sepal.Width` on the x-axis and `Sepal.Length` on the y-axis.

g_scat <- iris %>% 
  ggplot(aes(x=Sepal.Width, y=Sepal.Length)) + 
  geom_point()

# 12. Scatter plot with points colored by `Species`
# Assign to: `g_scat_col`
# Create a scatter plot with `Petal.Width` on the x-axis and `Petal.Length` on the y-axis,
# coloring points by `Species`.

g_scat_col <- iris %>% 
  ggplot(aes(x=Petal.Width, y=Petal.Length, colour = Species)) + 
  geom_point()


# 13. Histogram of `Petal.Width` with `binwidth = 0.5`
# Assign to: `g_hist`
# Create a histogram of `Petal.Width` with `binwidth` set to 0.5.

g_hist <- iris %>% 
  ggplot(aes(x=Petal.Width))+
  geom_histogram(binwidth=0.5)


# Visualization in R (using `PlantGrowth` dataset)

## before you begin with the following questions, type the following code to check column names in the dataframe
colnames(PlantGrowth) # output from this code is the column names that can be used in figures

# 14. Boxplot of `weight` grouped and filled by `group`
# Assign to: `g_bplot1`
# Create a boxplot of `weight` by `group`, filling boxes by `group`.
g_bplot1 <- PlantGrowth %>% 
  ggplot(aes(x=group,y=weight, fill = group))+
  geom_boxplot()


# 15. Boxplot + scatter plot of `weight` by `group`
# Assign to: `g_bplot2`
# Create a boxplot of `weight` by `group`, then overlay points showing individual observations.
g_bplot2 <- PlantGrowth %>% 
  ggplot(aes(x=group,y=weight, fill = group))+
  geom_boxplot() +
  geom_point()

