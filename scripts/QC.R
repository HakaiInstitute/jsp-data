library(googlesheets)
library(tidyverse)
library(here)
library(hakaiApi)

survey_data <- read_csv(here("data", "survey_data.csv"), col_types = cols(zoop_bout = col_character()))
seine_data <- read_csv(here("data", "seine_data.csv"))
bycatch_mort <- read_csv(here("data", "bycatch_mort.csv"))
ysi <- read_csv(here("data", "ysi.csv"))
zoop_tows <- read_csv(here("data", "zoop_tows.csv"))
zoop_tax <- read_csv(here("data", "zoop_tax.csv"))
fish <- read_csv(here("data", "fish_field_data.csv"), guess_max = 10000)
sealice <- read_csv(here("data", "sealice_field.csv"))


# field_2019 <- gs_key("1cHgZszv--FlV207cwSpe9hFJipb7HhS4IW9vVrUNg8M", visibility = "private", lookup = FALSE)
# survey_2019 <- gs_read(field_2019, ws = "survey_data")

survey_2019 <- survey_data %>% 
  filter(survey_date > as.Date("2019-01-01")) %>% 
  drop_na(ctd_bout) %>% 
  mutate(hakai_id = paste(site_id, survey_date, ctd_bout, sep="_")) %>% 
  select(survey_id, survey_date, site_id, hakai_id, secchi) %>% 
  # Finding most mismatches are due to the wrong sampling bout being entered into the portal, so create a more general linkage of date_site
  mutate(date_site = paste(survey_date, site_id, sep="_"))

client <- hakaiApi::Client$new()
endpoint = sprintf("%s/%s", client$api_root, 'eims/views/output/secchi?date>=2019-01-01&date<2019-09-01&survey&&{"DISOCKEYE","JSSOCKEYE"}&limit=-1')
data <- client$get(endpoint)

secchi <- data %>% 
  mutate(date_site = paste(date, site_id, sep="_"))

survey_secchi <- full_join(survey_2019,secchi, by = "date_site")

data_err <- survey_secchi %>% 
  # filter(is.na(pk) | is.na(survey_id) & miscast != "TRUE") # For CTD
  filter(is.na(event_pk) | is.na(survey_id)) # For Secchi

