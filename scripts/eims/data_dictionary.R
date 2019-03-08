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
  filter(!database_column %in% c("action", "work_area", "seines_included", "survey", "sampling_bout")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(survey_meta, "docs/survey_metadata.csv")


seine_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_seine?meta&limit=-1')

seine_meta <- client$get(seine_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "date", "work_area", "survey", "pk")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(seine_meta, "docs/seine_metadata.csv")


activity_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_site_activity?meta&limit=-1')

activity_meta <- client$get(activity_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(activity_meta, "docs/site_activity_metadata.csv")


bm_meta_endpoint <-  sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_bycatch_mort?meta&limit=-1')

bm_meta <- client$get(bm_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(bm_meta, "docs/bycatch_mort_metadata.csv")


fish_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fish?meta&limit=-1')

fish_meta <- client$get(fish_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(fish_meta, "docs/fish_metadata.csv")


lice_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_lice?meta&limit=-1')

lice_meta <- client$get(lice_meta_endpoint) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

sealice_field_meta <- lice_meta %>%
  filter(!database_column %in% c("project", "action", "work_area", "survey") & 
           !str_detect(database_column, "lab"))

write.csv(sealice_field_meta, "docs/sealice_field_metadata.csv")

sealice_lab_mot_meta <- lice_meta %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", 
                                 "chal_scar", "mot_scar", "pred_scar", "hemorrhaging", "eroded_gill_plate", "grazed_gill_plate", "mate_guarding", "pinched_belly") & 
           !str_detect(database_column, "field"))

write.csv(sealice_lab_mot_meta, "docs/sealice_lab_motiles_metadata.csv")


lice_finescale_meta_endpoint <- sprintf(
  "%s/%s", client$api_root,
  'eims/views/output/jsp_lice_finescale?meta&limit=-1')

lice_finescale_meta <- client$get(lice_finescale_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(lice_finescale_meta, "docs/sealice_lab_finescale_metadata.csv")


rna_dna_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_rna_muscle?meta&limit=-1')

rna_dna_meta <- client$get(rna_dna_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(rna_dna_meta, "docs/rna_dna_samples_metadata.csv")


rna_path_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_rna_pathogen?meta&limit=-1')

rna_path_meta <- client$get(rna_path_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(rna_path_meta, "docs/rna_pathogen_metadata.csv")


fa_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fatty_acid?meta&limit=-1')

fa_meta <- client$get(fa_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(fa_meta, "docs/fatty_acid_metadata.csv")


iso_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_isotope?meta&limit=-1')

iso_meta <- client$get(iso_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(iso_meta, "docs/isotope_metadata.csv")


xm_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_extra_muscle?meta&limit=-1')

xm_meta <- client$get(xm_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(xm_meta, "docs/extra_muscle_metadata.csv")


stomach_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_stomach?meta&limit=-1')

stomach_meta <- client$get(stomach_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(stomach_meta, "docs/stomach_metadata.csv")


oto_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_otolith?meta&limit=-1')

oto_meta <- client$get(oto_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(oto_meta, "docs/otolith_metadata.csv")


scale_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_scale?meta&limit=-1')

scale_meta <- client$get(scale_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(scale_meta, "docs/scale_metadata.csv")


stockid_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fin_clip?meta&limit=-1')

stockid_meta <- client$get(stockid_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(stockid_meta, "docs/stock_id_metadata.csv")


lice_sample_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_lice_sample?meta&limit=-1')

lice_sample_meta <- client$get(lice_sample_meta_endpoint) %>% 
  filter(!database_column %in% c("project", "action", "work_area", "survey", "comments")) %>% 
  select(database_column, display_column, type, unique_values, variable_units, variable_definition, variable_calculations)

write.csv(lice_sample_meta, "docs/sealice_sample_metadata.csv")
