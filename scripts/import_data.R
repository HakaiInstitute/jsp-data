# This script reads in the Hakai Institute Juvenile Salmon Program data from the
# Hakai Ecological Information Management System Data Portal. The purpose is
# to create discrete versions of the data from the Portal, to track changes or
# additions, QC data, and release citable versions of our growing data set.

library(hakaiApi)
library(tidyverse)
library(lubridate)
library(here)

# Connect R and EIMS Portal using hakaiApi
client <- hakaiApi::Client$new() 

# Endpoints in Portal that can be downloaded (I got this list from Nate because
#   currently a list of endpoints isn't available in any documentation):

# jsp_survey+
# jsp_bycatch_mort+
# jsp_seine+
# jsp_site_activity+
# jsp_fish+
# jsp_lice+
# jsp_lice_finescale+
# jsp_fin_clip+
# jsp_dna+
# jsp_otolith+
# jsp_lice_sample
# jsp_fatty_acid+
# jsp_scale+
# jsp_stomach+
# jsp_extra_muscle+
# jsp_isotope+
# jsp_rna_muscle+
# jsp_rna_pathogen+

# Download all data tables from data portal.
fish_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fish?limit=-1')

fish <- client$get(fish_endpoint) %>% 
  select(hakai_id, semsp_id, jsp_survey_id, seine_id, date, 
         everything(), 
         -project, -action, -work_area, -survey)

write_csv(fish, here("data", "fish.csv"))


survey_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_survey?limit=-1')

survey <- client$get(survey_endpoint) %>% 
  select(-action, -work_area, -seines_included, -survey, -sampling_bout)

write_csv(survey, here("data", "surveys.csv"))


seine_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_seine?limit=-1')

seine <- client$get(seine_endpoint) %>% 
  select(seine_id, jsp_survey_id, date, site_id, 
         everything(), gather_lat, gather_long, 
         -project, -action, -work_area, -survey, -pk)

write_csv(seine, here("data", "seines.csv"))


bm_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_bycatch_mort?limit=-1')

bycatch_mort <- client$get(bm_endpoint) %>%
  left_join(select(survey, jsp_survey_id, site_id)) %>% 
  select(seine_id, jsp_survey_id, date, site_id, 
         everything(), 
         -project, -action, seine_id, -work_area)

write_csv(bycatch_mort, here("data", "bycatch_mort.csv"))


activity_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_site_activity?limit=-1')

site_activity <- client$get(activity_endpoint) %>% 
  select(jsp_survey_id, date, site_id, everything(), -project, -action, -work_area) %>% 
  mutate(school_number = as.character(school_number), 
         school_sliders = as.factor(school_sliders), 
         school_poppers = as.factor(school_poppers), 
         school_dimpling = as.factor(school_dimpling))

write.csv(site_activity, here("data", "site_activity.csv"))


lice_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_lice?limit=-1')

lice <- client$get(lice_endpoint) %>% 
  select(-action)

sealice_field <- lice %>%
  select(hakai_id, seine_id, jsp_survey_id, date,
         everything(),
         -ends_with("lab"), -starts_with("lab"), -project, -work_area, -survey) %>% 
  filter(!is.na(licing_protocol_field)) %>% 
  select(1:10, 29:31, everything()) %>%  #This removes all lab observations
  mutate(unid_cope_field = as.numeric(unid_cope_field),
         unid_chal_field = as.numeric(unid_chal_field),
         pinched_belly = as.numeric(pinched_belly))

write.csv(sealice_field, here("data", "sealice_field.csv"))

sealice_lab_motiles <- lice %>%
  select(hakai_id, seine_id, jsp_survey_id, date,
         everything(),
         -(8:30), -project, -work_area, -survey) %>%  #This removes the lice counts & body abnormality observations recorded in the field 
  filter(!is.na(lab_count_motiles))  #Filtering out fish that received field enumeration only

write.csv(sealice_lab_motiles, here("data", "sealice_lab_motiles.csv"))


lice_finescale_endpoint <- sprintf(
  "%s/%s", client$api_root,
  'eims/views/output/jsp_lice_finescale?limit=-1')

lice_finescale <- client$get(lice_finescale_endpoint) %>% 
  select(hakai_id, seine_id, jsp_survey_id, date,
         everything(),
         -project, -action, -work_area, -survey)
  
write.csv(lice_finescale, here("data", "sealice_lab_finescale.csv"))


rna_dna_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_rna_muscle?limit=-1')

rna_dna <- client$get(rna_dna_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(rna_dna, here("data", "rna_dna_samples.csv"))


rna_pathogen_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_rna_pathogen?limit=-1')

rna_pathogen <- client$get(rna_pathogen_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(rna_pathogen, here("data", "rna_pathogen_samples.csv"))


fa_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fatty_acid?limit=-1')

fatty_acid <- client$get(fa_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(fatty_acid, here("data", "fatty_acid_samples.csv"))


isotope_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_isotope?limit=-1')

isotope <- client$get(isotope_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(isotope, here("data", "isotope_samples.csv"))


xm_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_extra_muscle?limit=-1')

extra_muscle <- client$get(xm_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(extra_muscle, here("data", "extra_muscle_samples.csv"))


dna_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_dna?limit=-1')

finclip_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fin_clip?limit=-1')

dna <- client$get(dna_endpoint)

fin_clip <- client$get(finclip_endpoint)

stock_id <- rbind(dna,fin_clip) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(stock_id, here("data", "stock_id_samples.csv"))


stomach_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_stomach?limit=-1')

stomach <- client$get(stomach_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(stomach, here("data", "stomach_samples.csv"))


otolith_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_otolith?limit=-1')

otolith <- client$get(otolith_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(otolith, here("data", "otolith_samples.csv"))


scale_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_scale?limit=-1')

scale <- client$get(scale_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(scale, here("data", "scale_samples.csv"))


lice_sample_endpoint <- sprintf(
  "%s/%s", client$api_root,
  'eims/views/output/jsp_lice_sample?limit=-1')

lice_sample <- client$get(lice_sample_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

write.csv(lice_sample, here("data", "sealice_samples.csv"))


# TODO:

# Package data is missing from data portal - should migrate timeout/dewar values to individual fish records and leave package data as inventory only
# Download YSI & zoop data
