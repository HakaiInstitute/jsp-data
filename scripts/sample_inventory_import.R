library(tidyverse)
library(here)
library(googlesheets)

fish_f <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_field_data.csv", guess_max = 20000)
fish_l <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_lab_data.csv", guess_max = 20000)
fish <- full_join(fish_f, fish_l, by = "ufn")

inv <- gs_key("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", visibility = "private", lookup = FALSE)
fa <- gs_read(inv, ws = "fa_metadata", col_types = c("cccccccccccc"))
# fa <- read_csv(here("data", "unverified", "fatty_acid_samples.csv"), guess_max = 10000)

fa_qc <- left_join(fish_l, fa, by = "ufn") %>% 
  filter(is.na(sample_id))

fa_fish <- left_join(fa, select(fish_l, ufn, date_processed), by = "ufn") %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  # filter(is.na(date_processed)) %>% 
  select(ufn, sample_id, sample_comments = comments_sample)

write_csv(fa_fish,here("data","samples", "fatty_acid.csv"))
