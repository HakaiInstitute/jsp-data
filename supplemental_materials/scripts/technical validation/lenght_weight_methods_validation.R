# Setup

knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE, error = FALSE)
library(tidyverse)
library(lubridate)
library(here)

# Determine if weights measured in the field are the same as weights measured in the lab on paired measurements from same fish

fish_weights <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/jsp_catch_and_bio_data_complete.csv", guess_max = 20000) |> 
  dplyr::select("Date Caught" = survey_date, "Date Processed" = date_processed,
                species, weight_freezer = weight, weight_wet = weight_field, ufn) |> 
  drop_na(weight_freezer) |> 
  drop_na(weight_wet) |> 
  mutate(storage_time = ymd(`Date Processed`) - ymd(`Date Caught`)) %>% 
  mutate(weight_diff = weight_wet - weight_freezer) %>% 
  mutate(weight_diff_percent = (weight_wet - weight_freezer)/weight_freezer*100) %>%
  filter(!ufn %in% c("U17302", "U16916", "U10246", "U17739", "U17087", "U10247")) # Remove outliers where weight difference > 50%, which is more likely due to field measurement error than actual weight loss from the freezer


# Conduct a paired test to determine if there is a significant difference in weights between field weighed and lab weighed fish

hist(fish_weights$weight_freezer)
shapiro.test(fish_weights$weight_freezer)

hist(fish_weights$weight_wet)
shapiro.test(fish_weights$weight_wet)

# neither weights are normally distributed

result <- wilcox.test(fish_weights$weight_wet,fish_weights$weight_freezer, paired=TRUE, conf.int = TRUE, conf.level=0.95)

result # Reject the null hypothesis that the weights are the same.


# Shapiro test found that weight_wet and weight_freezer are not normally distributed and therefore a paired t-test would not be appropriate for this dataset. Non-parametric Wilcox Signed Rank Test found that the difference is significant. 


fish_lengths <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/jsp_catch_and_bio_data_complete.csv", guess_max = 20000) |> 
  dplyr::select("Date Caught" = survey_date, "Date Processed" = date_processed,
                species, fork_length_field, fork_length, ufn) |> 
  drop_na(fork_length) |> 
  drop_na(fork_length_field)

hist(fish_lengths$fork_length_field)
shapiro.test(fish_lengths$fork_length_field)

hist(fish_lengths$fork_length)
shapiro.test(fish_lengths$fork_length)

length_result <- wilcox.test(fish_lengths$fork_length_field, fish_lengths$fork_length, paired=TRUE, conf.int = TRUE, conf.level=0.95)

length_result

median(fish_lengths$fork_length)
median(fish_lengths$fork_length_field)

mean(fish_lengths$fork_length)
mean(fish_lengths$fork_length_field)
