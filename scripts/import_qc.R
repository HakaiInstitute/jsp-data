library(hakaiApi)
library(tidyverse)
library(readxl)
library(here)

client <- hakaiApi::Client$new() 

# List of UFNs flagged in lab data (keep out of database)
ufn_flag <- c("U06", "U44", "U39", "U67_1", "U173", "U282", "U283", "U67_2", "U585", "U1719", "U2315", "U2318", "U2829", "U3201", "U3202", "U3203", "U2536")

fish_endpoint <- sprintf(
  "%s/%s", client$api_root,
  'eims/views/output/jsp_fish?limit=-1')
#
fish <- client$get(fish_endpoint) %>%
  select(ufn = hakai_id, semsp_id, survey_id = jsp_survey_id, seine_id, survey_date = date,
         everything(),
         -project, -action, -work_area, -survey)
# #   filter(!is.na(semsp_id))
# # 
# fish_gs <- read_excel("gsheets/Database WIP.xlsx", sheet = "fish_field_data") %>%
#   filter(ufn == "NA")
# 
# fish_diff <- anti_join(gs_fish, fish, by = "semsp_id")


survey_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_survey?limit=-1')

survey <- client$get(survey_endpoint) %>% 
  select(survey_id = jsp_survey_id)

survey_gs <- read_excel("gsheets/Database WIP.xlsx", sheet = "survey_data") %>% 
  select(survey_id)

diff_survey <- anti_join(survey, survey_gs)

# Found duplicate survey entries
survey_summ <- survey %>% 
  group_by(survey_id) %>% 
  summarize(count=n())


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


# rna_dna_endpoint <- sprintf(
#   "%s/%s", client$api_root, 
#   'eims/views/output/jsp_rna_muscle?limit=-1')
# 
# rna_dna <- client$get(rna_dna_endpoint) %>% 
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>% 
#   select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, -comments,
#          survey_id = jsp_survey_id, survey_date = date)
# 
# rna_m_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "rna-muscle_metadata")
# 
# rna_m_diff <- anti_join(rna_dna, rna_m_gs, by = "sample_id")


# rna_pathogen_endpoint <- sprintf(
#   "%s/%s", client$api_root, 
#   'eims/views/output/jsp_rna_pathogen?limit=-1')
# 
# rna_pathogen <- client$get(rna_pathogen_endpoint) %>% 
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>% 
#   select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, -comments,
#          survey_id = jsp_survey_id, survey_date = date, tissue_sampled = jsp_sample_type)
# 
# rna_path_gs <- rbind(
#   read_excel("gsheets/Sample Inventory.xlsx", sheet = "rna-gill_metadata"),
#   read_excel("gsheets/Sample Inventory.xlsx", sheet = "rna-brain_metadata"),
#   read_excel("gsheets/Sample Inventory.xlsx", sheet = "rna-spleen_metadata"),
#   read_excel("gsheets/Sample Inventory.xlsx", sheet = "rna-liver_metadata"),
#   read_excel("gsheets/Sample Inventory.xlsx", sheet = "rna-heart_metadata"),
#   read_excel("gsheets/Sample Inventory.xlsx", sheet = "rna-kidney_metadata"))
# 
# diff_rna_path <- anti_join(rna_pathogen, rna_path_gs, by = "sample_id")


# fa_endpoint <- sprintf(
#   "%s/%s", client$api_root,
#   'eims/views/output/jsp_fatty_acid?limit=-1')
# 
# fatty_acid <- client$get(fa_endpoint) %>%
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>%
#   select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, survey_id = jsp_survey_id, survey_date = date)
# 
# fatty_acid_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "fa_metadata")
# 
# diff_fa <- anti_join(fatty_acid_gs, fatty_acid, by = "sample_id") %>% 
#   filter(!ufn %in% ufn_flag)


# iso_endpoint <- sprintf(
#   "%s/%s", client$api_root,
#   'eims/views/output/jsp_isotope?limit=-1')
# 
# isotope <- client$get(iso_endpoint) %>%
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>%
#   select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, survey_id = jsp_survey_id, survey_date = date)
# 
# isotope_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "iso_metadata")
# 
# diff_iso <- anti_join(isotope_gs, isotope, by = "sample_id") %>% 
#   filter(!ufn %in% ufn_flag)


# xm_endpoint <- sprintf(
#   "%s/%s", client$api_root,
#   'eims/views/output/jsp_extra_muscle?limit=-1')
# 
# xm <- client$get(xm_endpoint) %>%
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>%
#   select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, survey_id = jsp_survey_id, survey_date = date)
# 
# xm_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "xm_metadata")
# 
# diff_xm <- anti_join(xm_gs, xm, by = "sample_id") %>% 
#   filter(!ufn %in% ufn_flag)


# dna_endpoint <- sprintf(
#   "%s/%s", client$api_root, 
#   'eims/views/output/jsp_dna?limit=-1')
# 
# finclip_endpoint <- sprintf(
#   "%s/%s", client$api_root, 
#   'eims/views/output/jsp_fin_clip?limit=-1')
# 
# dna <- client$get(dna_endpoint) %>% 
#   mutate(tissue_sampled = "muscle/liver")
# 
# fin_clip <- client$get(finclip_endpoint) %>% 
#   mutate(tissue_sampled = "fin clip")
# 
# dna_fc <- rbind(dna,fin_clip) %>% 
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>% 
#   select(ufn = fish_id, sample_id = hakai_id, tissue_sampled, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, survey_id = jsp_survey_id, survey_date = date)
# 
# dna_fc_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "dna_metadata")
# 
# diff_dna <- anti_join(dna_fc_gs, dna_fc, by = "sample_id") %>% 
#   filter(!ufn %in% ufn_flag)


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
# diff_stomach <- anti_join(stomach_gs, stomach) %>% 
#   filter(!ufn %in% ufn_flag)


# otolith_endpoint <- sprintf(
#   "%s/%s", client$api_root, 
#   'eims/views/output/jsp_otolith?limit=-1')
# 
# otolith <- client$get(otolith_endpoint) %>% 
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>% 
#   select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, survey_id = jsp_survey_id, survey_date = date)
# 
# otolith_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "otolith_metadata")
# 
# diff_otolith <- anti_join(otolith_gs, otolith, by = "sample_id") %>% 
#   filter(!ufn %in% ufn_flag)


# scale_endpoint <- sprintf(
#   "%s/%s", client$api_root, 
#   'eims/views/output/jsp_scale?limit=-1')
# 
# scale <- client$get(scale_endpoint) %>% 
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>% 
#   select(ufn = fish_id, sample_id = hakai_id, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, survey_id = jsp_survey_id, survey_date = date)
# 
# scale_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "scale_metadata")
# 
# diff_scale <- anti_join(scale_gs, scale, by = "sample_id") %>% 
#   filter(!ufn %in% ufn_flag)


# lice_sample_endpoint <- sprintf(
#   "%s/%s", client$api_root,
#   'eims/views/output/jsp_lice_sample?limit=-1')
# 
# lice_sample <- client$get(lice_sample_endpoint) %>% 
#   left_join(select(fish, ufn, date_processed), by = c("fish_id" = "ufn")) %>% 
#   select(ufn = fish_id, sample_id = hakai_id, louse_sample_type = jsp_sample_type, date_collected = date_processed,
#          everything(),
#          -project, -action, -work_area, -survey, survey_id = jsp_survey_id, survey_date = date)
# 
# lice_gs <- read_excel("gsheets/Sample Inventory.xlsx", sheet = "sealice_metadata")
# 
# diff_lice <- anti_join(lice_gs, lice_sample, by = "sample_id") %>% 
#   filter(!ufn %in% ufn_flag)
# 
# write.csv(diff_lice, "diff_lice.csv")


ctd_endpoint <- 