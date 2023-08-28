library(tidyverse)
library(here)
library(googlesheets4)
# In 2017 we loused and retained 10 sockeye from the first set, and then conducted another set to louse 10 sockeye, 10 pink and 10 chum. Fish from the second set were anaesthetized, live-liced and released (unless we hadn't hit quota from the first set in which case some fish were retained)

# In 2018 we didn't do attached stage licing in the field on pink or chum. only 10 sockeye. So, do we have any attached stage lice data from the lab in 2018??? - No, it appears not

# In 2019 we field liced (including attached stages) 10 sockeye, and only 3 pink and 3 chum from every seine

mdt_slug <- "1RLrGasI-KkF_h6O5TIEMoWawQieNbSZExR0epHa5qWI"

sites <- read_sheet(mdt_slug, sheet = "sites", na = c("NA", "")) %>% 
  write_csv(here("supplemental_materials", "raw_data", "sites.csv"))
1
catch_data <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/jsp_catch_and_bio_data_complete.csv", guess_max = 20000) |> left_join(sites, by = "site_id")

# Define sites that can be compared between years
consistent_sites <-  c("D07","D09","D22","D27","D10","D08","D34","D35",
                       "D20","J03","J02","J09","J11")

# build table for attached stage lice

sites <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/supplemental_materials/tidy_data/sites.csv")

#TODO: Update the field_data_url annually with the current years google sheet URL
field_data_url <- "https://docs.google.com/spreadsheets/d/1Y8Nw82hHSb_GDXYzwg5hKI34bYlFnkLsir_V_fGdVCw/edit#gid=364784709"
# Read in current year lice data

surveys_2023 <- read_sheet(field_data_url, sheet = "survey_data") |> 
  drop_na(survey_id) |> 
  mutate(sampling_week = as.numeric((yday(survey_date) + 4) %/% 7))

surveys_2023$sampling_week <- recode_factor(surveys_2023$sampling_week, 
                                            `18` = "May 5",
                                            `19` = "May 12" ,
                                            `20` = "May 19", 
                                            `21` = "May 26",
                                            `22` = "June 2",
                                            `23` = "June 9", 
                                            `24` = "June 16", 
                                            `25` = "June 23",
                                            `26` = "June 30", 
                                            `27` = "July 6", 
                                            `28` = "July 13")

seines_2023 <- read_sheet(field_data_url, sheet = "seine_data") |> 
  drop_na(seine_id)

ss_2023 <- left_join(surveys_2023, seines_2023, by = "survey_id") |> 
  left_join(select(sites, site_id, zone), by = "site_id") |> 
  mutate(year = year(survey_date)) |> 
  drop_na(survey_id)

fish_field_2023 <- read_sheet(field_data_url, sheet = "fish_field_data") |> 
  drop_na(ufn) |> 
  mutate(region = "DI")

ss_fish_2023 <- left_join(fish_field_2023, ss_2023)

current_lice <- read_sheet(field_data_url, sheet = "sealice_field_data") |> 
  # Join sea lice data to seine and survey_data by ufn and seine id
  right_join(ss_fish_2023, by = c('ufn', 'seine_id')) |> 
  # select relevant columns and all sea lice counts
  select(survey_date, seine_id, ufn, species, lep_cope, lam, laf, lgf, cal_cope, cam, caf, cgf,
         chal_a_b, unid_cope, unid_chal) |> 
  # Get rid of fish that were not loused
  drop_na() |> 
  # Calculate total leps and cals to get ratio to infer to chalimus stages
  mutate(leps = lep_cope + lam + laf + lgf,
         cal = cal_cope + cam + caf + cgf,
         unk = chal_a_b + unid_cope + unid_chal,
         ratio = sum(leps, na.rm = TRUE) / sum(cal, na.rm = TRUE),
         inferred_leps = unk * ratio,
         inferred_cal = unk * (1-ratio)) |>
  # Remove intermediate cols
  select(survey_date, seine_id, ufn, species,lep_cope, lam, laf, lgf, cal_cope,
         cam, caf, cgf, inferred_leps, inferred_cal) |> 
  # Make 1 row an observation of one louse
  pivot_longer(cols = lep_cope:inferred_cal, names_to = "louse_species", 
               values_to = "count") |> 
  # Assign stages
  mutate(life_stage = if_else(louse_species %in% c("cal_cope", "lep_cope", "inferred_leps", "inferred_cal"), "attached", "motile"),
         # Assign species
         louse_species = if_else(louse_species %in% c("cal_cope", 
                                                      "inferred_cal", "cam",
                                                      "caf", "cgf"), 
                                 "Caligus clemensi",
                                 "Lepeophtheirus salmonis")) |> 
  # Total up all sea lice by fish, louse species and lifestage
  group_by(survey_date, seine_id, species, ufn, louse_species, life_stage) |> 
  summarize(count = sum(count)) |> 
  ungroup() |> 
  mutate(origin = "current_lice")

current_lice_n <- current_lice |> 
  distinct(ufn, species) |> 
  group_by(species) |> 
  tally() |> 
  mutate(year = 2023,
         n_hosts_attached = n,
         n_hosts_motile = n,
         origin = "current_lice")

# import time series attached stage lice
# first read in sealice lab finescale
sealice_lab_fs <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/supplemental_materials/raw_data/sample_results/sealice/sealice_lab_fs.csv") |>
  # Join to catch data only by UFN 
  left_join(catch_data, by = c("ufn")) |> 
  # Include only fish from Discovery Islands
  filter(region == "DI",
         site_id %in% consistent_sites) |> 
  # Make one row equal to one louse observation
  pivot_longer(cols = lep_cop:cal_mot_unid, names_to = "louse_species", values_to = "count") |> 
  drop_na(count) |>
  select(survey_date, seine_id, ufn, species, louse_species, count) |> 
  # name louse stage based on original columns
  mutate(life_stage = if_else(louse_species %in% c("lep_cop", "lep_cunifer_cop", "lep_chal_a", "lep_chal_b", "cal_cop", "cal_chal_a_1", "cal_chal_a_2", "cal_chal_b_3", "cal_chal_b_4_f", "cal_chal_b_4_m", "cal_chal_4_unid", "cal_chal_a_unid", "cal_chal_b_unid"), "attached", "motile"),
         louse_species = if_else(louse_species %in% c("lep_cop", "lep_cunifer_cop", "lep_chal_a", "lep_chal_b", "lep_pa_m_1", "lep_pa_m_2", "lep_pa_f_1", "lep_pa_f_2", "lep_pa_unid", "lep_a_m", "lep_a_f", "lep_grav_f"), "Lepeophtheirus salmonis", "Caligus clemensi")) |> 
  group_by(survey_date, seine_id, species, ufn, louse_species, life_stage) |> 
  summarize(count = sum(count)) |> 
  ungroup() |> 
  #Remove motile sealice because those observations are included in lab_mots_ts
  filter(life_stage == "attached") |> 
  mutate(origin = "sealice_lab_fs")

sealice_lab_fs_n <- sealice_lab_fs |>
  mutate(year = year(survey_date)) |> 
  distinct(ufn, species, .keep_all = TRUE) |> 
  group_by(year, species) |> 
  tally() |> 
  mutate(n_hosts_attached = n,
         n_hosts_motile = 0,
         origin = "sealice_lab_fs")

# second, read in time series lice data
#need to attach seine number first
seine_ids <- catch_data |> 
  select(seine_id, ufn)

# Note 
lab_mots_ts <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/supplemental_materials/report_data/sealice_time_series.csv") |> 
  filter(region == "DI", 
         year == year(survey_date),
         !louse_species == "all_lice") |> 
  mutate(louse_species = if_else(louse_species == "motile_caligus", "Caligus clemensi", "Lepeophtheirus salmonis" ),
         life_stage = "motile") |> 
  left_join(seine_ids, by = 'ufn') |> 
  select(survey_date, seine_id, species, ufn, louse_species, life_stage, 
         count = n_lice) |> 
  mutate(origin = "mots_ts") 

lab_mots_ts_n <- lab_mots_ts |> 
  mutate(year = year(survey_date)) |> 
  distinct(ufn, species, .keep_all = TRUE) |> 
  group_by(year, species) |> 
  tally() |> 
  mutate(n_hosts_attached = 0,
         n_hosts_motile = n,
         origin = "mots_ts")


# Third read in the field data to pull out 
sealice_field <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/supplemental_materials/raw_data/sample_results/sealice/sealice_field.csv") |> 
  # Join to catch data just by ufn
  left_join(catch_data, by = 'ufn') |>
  filter(region == "DI",
         site_id %in% consistent_sites) |> 
  mutate(year = year(survey_date)) |> 
  mutate(leps = lep_cope_field + lpam_field + lpaf_field + lam_field +
           laf_field + lgf_field,
         cal = cal_cope_field + cal_mot_field + cgf_field,
         unk = chal_a_field + chal_b_field + unid_cope_field + 
           unid_chal_field) |>
  select(seine_id, survey_date, ufn, year, species,
         cal_cope_field:unid_chal_field, leps, cal, unk) |> 
  group_by(year) |> 
  mutate(ratio = sum(leps, na.rm = TRUE) / sum(cal, na.rm = TRUE)) |> 
  ungroup() |> 
  # NOTE: inferring the species of chalimus based on ratio of copes and adults
  mutate(inferred_leps = unk * ratio,
         inferred_cal = unk * (1-ratio)) |> 
  select(-c(year, unk, ratio, leps, cal, chal_a_field, chal_b_field, unid_cope_field, unid_chal_field)) |> 
  pivot_longer(cols = cal_cope_field:inferred_cal, 
               names_to = "louse_species", values_to = "count") |> 
  drop_na(count) |> 
  mutate(life_stage = if_else(louse_species %in% c("cal_cope_field", "lep_cope_field", "inferred_leps", "inferred_cal"), "attached", "motile"),
         louse_species = if_else(louse_species %in% c("cal_cope_field", "cal_mot_field", "inferred_cal", "cgf_field"), "Caligus clemensi", "Lepeophtheirus salmonis"))|> 
  group_by(survey_date, seine_id, species, ufn, louse_species, life_stage) |> 
  summarize(count = sum(count)) |> 
  filter(life_stage == "attached") |> 
  mutate(origin = "sealice_field") |> 
  ungroup()

#check for duplicates in fs an field data
dups <- bind_rows(sealice_lab_fs, sealice_field) |> 
  mutate(qc_check = paste(ufn, louse_species, life_stage)) |> 
  group_by(qc_check) |> 
  filter(n() > 1) |> 
  ungroup() |> 
  distinct(ufn) 

dups <- dups$ufn

sealice_field <- sealice_field |> 
  filter(!ufn %in% dups) 

sealice_field_n <- sealice_field |> 
  ungroup() |> 
  mutate(year = year(survey_date)) |> 
  distinct(ufn, species, life_stage, .keep_all = TRUE) |> 
  group_by(year, species) |> 
  tally() |> 
  mutate(n_hosts_attached = n,
         n_hosts_motile = 0,
         origin = "sealice_field")

hosts <- bind_rows(current_lice_n, sealice_lab_fs_n, lab_mots_ts_n, sealice_field_n) |> 
  group_by(species, year) |> 
  summarize(n_hosts_attached = sum(n_hosts_attached),
            n_hosts_motile = sum(n_hosts_motile)) |> 
  pivot_longer(cols = n_hosts_attached:n_hosts_motile, names_to = "life_stage",
               values_to = "n_hosts") |> 
  mutate(life_stage = if_else(life_stage == "n_hosts_motile", "motile", "attached"))

sealice_df_long <- bind_rows(sealice_lab_fs, current_lice, sealice_field, lab_mots_ts) |>
  filter(!species == "CO") |> 
  drop_na(count) |>
  mutate(year = year(survey_date)) |> 
  left_join(hosts, by = c("species", "year", "life_stage")) |> 
  ungroup()

write_csv(sealice_df_long, here("supplemental_materials", "tidy_data", "sealice_all_stages_ts_long.csv"))

sealice_df <- sealice_df_long |> 
  dplyr::group_by(year, species, louse_species, life_stage) |> 
  dplyr::summarize(mean_abundance = mean(count, na.rm = TRUE),
                   sd = sd(count),
                   se = sd/sqrt(n_hosts),
                   n_hosts = n_hosts) |> 
  distinct() |> 
  filter(!n_hosts < 3) |> 
  mutate(life_stage = if_else(life_stage == "motile", "Motile", "Attached"))

sealice_df$species <- recode(sealice_df$species, SO = "Sockeye",
                             PI = "Pink", CU = "Chum")

sealice_df$species <- factor(sealice_df$species) |> 
  fct_relevel("Sockeye", "Pink", "Chum")

write_csv(sealice_df, here("supplemental_materials", "tidy_data", "sealice_all_stages_ts.csv"))

# Remove all objects from .GlobalEnv
rm(list = ls())
