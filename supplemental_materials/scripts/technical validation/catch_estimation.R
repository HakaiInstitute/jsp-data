library(tidyverse)
library(googlesheets4)
library(here)

# Read google sheet in and write out to csv to read static file for reproducibility
census <- read_sheet('1PfbS_hhGlTeil2N_C9HUxDa3ZT_-CpcWrodQgUlHLQM', sheet = "Sheet1")
write_csv(census, here("supplemental_materials", "scripts", "technical validation", "census_vs_estimate.csv"))

census <- read_csv(here("supplemental_materials", "scripts", "technical validation", "census_vs_estimate.csv"))
# plot linear regression of estimate vs census
linear_plot <- ggplot(data = census, mapping = aes(x = census_in_net, y = estimate_in_net))+
  #add point to plot
  geom_point() + 
  coord_cartesian(ylim = c(0,2000), xlim = c(0,2000)) +
  geom_smooth(method = "lm") +
  xlab("Census count") +
  ylab("Visual estimate") +
  scale_x_continuous(breaks = c(0, 500, 1000, 1500, 2000))

linear_plot

ggsave('linear_regression.png')

# Estimate error, interecept, r2
lm <- lm(estimate_in_net~census_in_net, data=census)
summary(lm)
