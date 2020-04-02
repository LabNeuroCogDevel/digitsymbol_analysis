
# install the pacman package if we don't have it.
# pacman provies p_load, it's like 'library()' but fetches package if they aren't installed
if (! "pacman" %in% dimnames(installed.packages())[[1]]) {
   install.packages("pacman")
}

# load up packages
library(pacman)
# this will take forever the first time it is run
p_load("tidyverse") # dplyr, tidyr

# get the data into dataframe d
d <- read.table("txt/all_long.txt", header=T)

#inspect
head(d)
