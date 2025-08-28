if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse)

library(tidyverse)

set.seed(123)

iris_sub <- as_tibble(iris) %>% 
  group_by(Species) %>% 
  sample_n(3) %>% 
  ungroup()

print(iris_sub)



# Exercises ----------------------------------------------------------------

# filter 'iris_sub' to contain only Species virginica

filter(iris_sub,Species=="virginica")

# select 'iris_sub' column Sepal.Width

select(iris_sub,Sepal.Width)

# filter 'iris_sub' to contain only virginica, then select Sepal.Width
# then create column 'sw3' that is 3 times Sepal.Width
# and assign to df0

df0<-iris_sub %>% 
  filter(Species=="virginica") %>% 
  select(Sepal.Width) %>% 
  mutate(sw3=Sepal.Width*3)



