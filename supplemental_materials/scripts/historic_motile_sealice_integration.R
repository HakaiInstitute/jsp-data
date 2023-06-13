# Sea lice

# Sea lice is probably the most complicated set of data to combine largely because 
# we used so many different methods. We counted lice in the field under different 
# protocols, and we counted them in the lab under different protocols as well. 
# Some methods produce a very fine level of resolution when it comes to species 
# and stage ID whereas other methods are more coarse and only focus on larger 
# 'motile' sealice that can be seen easier. 

# Our goal is to create a time series of motile (adult, not attached and easy to
# see and ID) sea lice counts that use methods that are reasonably similar enough
# to warrant combining observations to make interannual comparisons. The lowest 
# common denominator among all years is that motile sea lice were identified to 
# species. Thus the time series doesn't contain any stage or sex data.

# Each year a new table that contains the motile caligus and lep counts should 
# be added to the time series in a similar way to how the other sea lice tables 
# are combined. Alternatively, if the motile lab method stays the same, the data
# can just be added to JSP Master Data Tables google sheet and then exported as 
# a .csv and saved in this repository.

# This script deals with combining field observations with fine scale stage data,
# and coarser lab counts. Motile sea lice counted through each of these methods
# forms the basis of our time series. We are confident that identification
# accuracy between methods and years for motile sea lice is precise.

# History of sampling
# In 2015: 
# 
# In 2017, 2018, and 2019 we enumerated sea  lice in the field  using the salmon
# coast method which uses a hand lens to identify various stages of both attached 
# and motile sea lice. In 2017 we conducted two sets. The first one we counted sea attached sealice on 10 sockeye. 
# On the second set we counted sea lice on 10 sockeye, pink, and chum (and didn't retain anything unless our quota was not filld during seine 1.
# In 2018 we only enumerated 10 sockeye for attached stages and pink and chum were motile only. 
# In 2019 we enumerated 10 sockeye and 3 pink and 3 chum for attached stages. 
# For the time series, we only report motiles because that 
# is what was done consistently between all years.

# Summarize field counts of motile sea lice only

library(tidyverse)
library(here)
library(googlesheets4)

#mdt_slug is the id for the master data table google sheet
mdt_slug <- "1RLrGasI-KkF_h6O5TIEMoWawQieNbSZExR0epHa5qWI"
survey_data <- read_sheet(mdt_slug, sheet = "survey_data", na = c("NA", "")) 
# providng `1` fulfills auth request, assuming the correct gmail account is option 1
1

seine_data <- read_sheet(mdt_slug, sheet = "seine_data", na = c("NA", ""))

survey_seines_fish <- left_join(survey_data, seine_data, by = 'survey_id') %>% 
  right_join(fish_field_data, by = "seine_id") %>% 
  left_join(sites, by = "site_id")

field_lice <- read_csv(here("supplemental_materials", "raw_data", 
                            "sample_results", "sealice", "sealice_field.csv")) %>% 
  left_join(survey_seines_fish, by = "ufn") %>%
  drop_na(cal_mot_field) %>% 
  mutate(
    motile_caligus_field = rowSums(select(
      ., "cal_mot_field", "cgf_field"
    )),
    motile_lep_field = rowSums(
      select(
        .,
        "lpam_field",
        "lpaf_field",
        "lam_field",
        "laf_field",
        "lgf_field"
      ),
      na.rm = T
    )
  ) %>%
  select(
    ufn, site_id, species, survey_date, motile_caligus_field,
    motile_lep_field)

# Lauren Portner conducted some taxonomic identification of sea lice to a very
# fine level of stage data that was used in another study. We extract the motiles
# from that data set to combine with other  methods of ID to add to the time series

# To get all motile counts conducted in the lab, you need to join the results 
# from the lab_motile and lab_finescale tables. Stages in lab_finescale need to
#be summed so that they're at the same level of precision as lab_motiles

#sealice_lab_mot is motile counts of sealice conducted during fish dissections
# from 2015, 2016, 2017, and 2018
sealice_lab_mot <- read_csv(here("supplemental_materials", "raw_data", 
                                 "sample_results", "sealice", "sealice_lab_mot.csv")) 

#sealice_lab_fs_mot are the data from Lauren Portner's fine scale taxonomic id
# that includes chalimus stages etc. It's mostly from 2015 fish (642 fish), 
# and some from 2017 (63 fish)
sealice_lab_fs_mot <- read_csv(here("supplemental_materials", "raw_data", 
                                    "sample_results", "sealice", 
                                    "sealice_lab_fs.csv")) %>%
  #combine stages 1 and 2 or pre adults
  mutate(lpam_lab = lep_pa_m_1 + lep_pa_m_2,
         lpaf_lab = lep_pa_f_1 + lep_pa_f_2,
         cm_lab = cal_pa_m + cal_a_m) %>% 
  select(ufn,
         cm_lab,
         cpaf_lab = cal_pa_f, # renaming variables to be consistent...
         caf_lab = cal_a_f,
         cgf_lab = cal_grav_f,
         ucal_lab = cal_mot_unid,
         lpam_lab,
         lpaf_lab,
         laf_lab = lep_a_f,
         lam_lab = lep_a_m,
         lgf_lab = lep_grav_f,
         ulep_lab = lep_pa_unid)

sealice_lab_motiles <- bind_rows(sealice_lab_mot, sealice_lab_fs_mot)
rm(sealice_lab_mot, sealice_lab_fs_mot) # cleans up intermediate tables

# add catch metadata to sealice counts
lab_lice <- survey_seines_fish %>%
  right_join(sealice_lab_motiles, by = "ufn") %>%
  # lump all sexes and stages of adult caligus
  mutate(
    motile_caligus_lab = rowSums(
      select(., "cm_lab", "cpaf_lab", "caf_lab", "cgf_lab", "ucal_lab"),
      na.rm = T
    ),
    # lump all sexes and stages of adult leps
    motile_lep_lab = rowSums(
      select(
        .,
        "lpam_lab",
        "lpaf_lab",
        "lam_lab",
        "laf_lab",
        "lgf_lab",
        "ulep_lab"
      ),
      na.rm = T
    )
  ) %>%
  select(
    ufn,
    site_id,
    species,
    survey_date,
    motile_caligus_lab,
    motile_lep_lab
  )
rm(sealice_lab_motiles)

# In 2020 the stages were not identified in the lab but just counts of motile leps, or caligus  were conducted.
sealice_current <- read_sheet("1RLrGasI-KkF_h6O5TIEMoWawQieNbSZExR0epHa5qWI", sheet = "sealice_lab_motiles_simple", guess_max = 500) %>%
  rename(motile_caligus_lab = cal_count, motile_lep_lab = lep_count) %>% 
  left_join(survey_seines_fish) %>% 
  select(ufn, site_id, species, survey_date, motile_caligus_lab, 
         motile_lep_lab) %>% 
  mutate(motile_caligus_lab = as.numeric(motile_caligus_lab), 
         motile_lep_lab = as.numeric(motile_lep_lab)) 

full_lab_lice <- bind_rows(lab_lice, sealice_current)

rm(lab_lice, sealice_current)

combined_motile_lice <- full_join(full_lab_lice, field_lice) %>%
  # with preference to lab ID, combine field and lab ID columns into one column
  mutate(motile_caligus = coalesce(motile_caligus_lab, motile_caligus_field)) %>%
  mutate(motile_lep = coalesce(motile_lep_lab, motile_lep_field)) %>%
  mutate(all_lice = motile_caligus + motile_lep) %>%
  select(ufn,
         survey_date,
         site_id,
         species,
         motile_lep,
         motile_caligus,
         all_lice) 


# Include data from when we switched back to sealice ID in the field using a modified salmon coast protocol
sealice_mod_sc <- read_sheet("1RLrGasI-KkF_h6O5TIEMoWawQieNbSZExR0epHa5qWI", sheet = "sealice_field", guess_max = 500) |> 
  mutate(motile_caligus = cam + caf + cgf,
         motile_lep = lam + laf + lgf,
         all_lice = motile_caligus + motile_lep) |> 
  left_join(survey_seines_fish, by = 'ufn') |> 
  select(ufn, survey_date, site_id, species, motile_lep, motile_caligus, all_lice)

combined_motile_lice <- bind_rows(combined_motile_lice, sealice_mod_sc)

write_csv(combined_motile_lice, here::here("supplemental_materials", "tidy_data", "combined_motile_lice.csv"))

rm(field_lice, full_lab_lice, survey_seines_fish)
