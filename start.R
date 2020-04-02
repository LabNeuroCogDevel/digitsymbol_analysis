#!/usr/bin/env Rscript

# 20200402WF - init
#   starting script for exploring digit symbol task



# install the pacman package if we don't have it.
# pacman provies p_load, it's like 'library()'
# but fetches package if they aren't installed
if (! "pacman" %in% dimnames(installed.packages())[[1]]) {
   install.packages("pacman")
}

# N.B. --- READ ME
# should maybe log transform RT. ask BTC

# load up packages
library(pacman)
# this will take forever the first time it is run
p_load("tidyverse") # dplyr (group_by, summarise, mutate)
p_load("ggplot2")   # ggplot, aes, geom_*
p_load("cowplot")   # plot_grid, cowplot_theme
p_load("lme4")   # plot_grid, cowplot_theme
theme_set(theme_cowplot())

# get the data into dataframe d
d <- read.table("txt/all_long.txt", header=T)

#inspect
head(d)

# plot all (slow)
ggplot(d) +
   aes(x=age, y=speed.RT, color=Running, group=id) +
   geom_boxplot()

# summarise
#  want to remove trials where they got it wrong (correct speed.ACC must be 1, or mem.ACC is 1)
#  (ACC is accuracy)
s_wide <-
   d %>%
   group_by(id, vdate, age) %>%
   summarise(speed.RT=mean(speed.RT[speed.ACC==1], na.rm=T),
             speed.ncorr=length(which(speed.ACC==1)),
             mem.RT=mean(mtrace.RT[mtrace.ACC==1], na.rm=T),
             mem.ncorr=length(which(mtrace.ACC==1)))
s_long <-
   s_wide %>%
   gather(measure, value, -id, -age, -vdate) %>%
   separate(measure, c("trialtype", "measure")) %>%
   spread(measure, value)

# see per person averages (sized by number of trials correct)
ggplot(s_long) +
   aes(x=age, y=RT, size=ncorr, color=trialtype) +
   geom_point() +
   stat_smooth()


# reformat the data - one line per trial with the 4 speed.* & mtrace.*
# collapsed into just 2 columns: ACC & RT
d_long <-
   d %>% group_by(id,vdate) %>% mutate(trialno=1:n()) %>%
   select(id, age, vdate, trialno, speed.RT, speed.ACC, mtrace.RT, mtrace.ACC) %>%
   gather(measure, value, -id, -age, -vdate, -trialno) %>%
   na.omit() %>%
   separate(measure, c("trialtype", "measure")) %>%
   spread(measure, value)

# model
m_speed <- lmer(RT ~ age + (1|id), d_long %>% filter(trialtype=="speed"))
summary(m_speed)
