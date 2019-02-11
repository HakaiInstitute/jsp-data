library(hakaiApi)
library(tidyverse)
library(readxl)
library(here)

client <- hakaiApi::Client$new() 

fish_endpoint <- sprintf(
  "%s/%s", client$api_root,
  'eims/views/output/jsp_fish?limit=-1')
#
fish <- client$get(fish_endpoint) %>%
  select(ufn = hakai_id, semsp_id, survey_id = jsp_survey_id, seine_id, survey_date = date,
         everything(),
         -project, -action, -work_area, -survey) %>%
# #   filter(!is.na(semsp_id))
# # 
# fish_gs <- read_excel("gsheets/Database WIP.xlsx", sheet = "fish_field_data") %>%
#   filter(ufn == "NA")
# 
# fish_diff <- anti_join(gs_fish, fish, by = "semsp_id")


# seine_endpoint <- sprintf(
#   "%s/%s", client$api_root, 
#   'eims/views/output/jsp_seine?limit=-1')
# 
# seine <- client$get(seine_endpoint) %>% 
#   select(seine_id, survey_id = jsp_survey_id, survey_date = date, site_id, 
#          everything(), lat = gather_lat, long = gather_long, 
#          -project, -action, -work_area, -survey, -pk)
# 
# seine_gs <- read_excel("gsheets/Database WIP.xlsx", sheet = "seine_data")


rna_dna_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_rna_muscle?limit=-1')

rna_dna <- client$get(rna_dna_endpoint) %>% 
  left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>% 
  select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
         everything(),
         -project, -action, -work_area, -survey, -comments,
         survey_id = jsp_survey_id, survey_date = date)

rna_m_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "rna-muscle_metadata")

rna_m_diff <- anti_join(rna_dna, rna_m_gs, by = "sample_id")


# stomach_endpoint <- sprintf(
#   "%s/%s", client$api_root, 
#   'eims/views/output/jsp_stomach?limit=-1')
# 
# stomach <- client$get(stomach_endpoint) %>% 
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>% 
#   select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, survey_id = jsp_survey_id, survey_date = date)
# 
# stomach_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "stomach_metadata")
# 
# stomach_diff <- anti_join(gs_stomach, stomach)
