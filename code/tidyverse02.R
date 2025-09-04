
# swirl ------------------------------------------------------------------

library(swirl)
swirl()


# ggplot exercises --------------------------------------------------------
data(iris)

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
