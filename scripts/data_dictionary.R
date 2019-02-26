library(hakaiApi)
library(tidyverse)
library(lubridate)
library(here)

# Connect R and EIMS Portal using hakaiApi
client <- hakaiApi::Client$new() 

survey_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_survey?meta&limit=-1')

survey_meta <- client$get(survey_meta_endpoint) %>% 
  mutate(table = "survey") %>% 
  filter(!database_column %in% c("action", "work_area", "seines_included", "survey", "sampling_bout"))


seine_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_seine?meta&limit=-1')

seine_meta <- client$get(seine_meta_endpoint) %>% 
  mutate(table = "seine") %>% 
  filter(!database_column %in% c("project", "action", "date", "work_area", "survey", "pk"))


activity_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_site_activity?meta&limit=-1')

activity_meta <- client$get(activity_meta_endpoint) %>% 
  mutate(table = "site_activity") %>% 
  filter(!database_column %in% c("project", "action", "work_area"))


bm_meta_endpoint <-  sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_bycatch_mort?meta&limit=-1')

bm_meta <- client$get(bm_meta_endpoint) %>% 
  mutate(table = "bycatch_mort") %>% 
  filter(!database_column %in% c("project", "action", "work_area"))


fish_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fish?meta&limit=-1')

fish_meta <- client$get(fish_meta_endpoint) %>% 
  mutate(table = "fish") %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey"))


lice_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_lice?meta&limit=-1')

lice_meta <- client$get(lice_meta_endpoint)

sealice_field_meta <- lice_meta %>%
  mutate(table = "sealice_field") %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey") & 
           !str_detect(database_column, "lab"))

sealice_lab_mot_meta <- lice_meta %>% 
  mutate(table = "sealice_lab_motiles") %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", 
                                 "chal_scar", "mot_scar", "pred_scar", "hemorrhaging", "eroded_gill_plate", "grazed_gill_plate", "mate_guarding", "pinched_belly") & 
           !str_detect(database_column, "field"))


lice_finescale_meta_endpoint <- sprintf(
  "%s/%s", client$api_root,
  'eims/views/output/jsp_lice_finescale?meta&limit=-1')

lice_finescale_meta <- client$get(lice_finescale_meta_endpoint) %>% 
  mutate(table = "sealice_lab_finescale") %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey"))


all_meta <- rbind(survey_meta, seine_meta, activity_meta, bm_meta, fish_meta, sealice_field_meta, sealice_lab_mot_meta, lice_finescale_meta)



write.csv(all_meta, "data_dictionary.csv")

# cols_endpoint <- sprintf(
#   "%s/%s", client$api_root,
#   'eims/lookup_display_columns?limit=-1'
# )
# cols <- client$get(cols_endpoint)