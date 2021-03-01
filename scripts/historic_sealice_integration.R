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
# species. Thus the time series doesn't contain any stage data.

# Each year a new table that contains the motile caligus and lep counts should be added to the time series in a similar way to how the other sea lice tables are combined. Alternatively, if the motile lab method stays the same, the data can just be added to JSP Master Data Tables google sheet and then exported as a .csv and saved in this repository.

# This script deals with combining field observations with fine scale stage data,
# and coarser lab counts. Motile sea lice counted through each of these methods
# forms the basis of our time series. We are confident that identification
# accuracy between methods and years for motile sea lice is precise.

# Summarize field counts of motile sea lice only

library(tidyverse)
library(here)

survey_seines_fish <- left_join(survey_data, seine_data, by = 'survey_id') %>% 
  left_join(fish_field_data, by = "seine_id")
# In 2017, 2018, and 2019 we enumerated sea  lice in the field  using the salmon
# coast method which uses a hand lens to identify various stages of both attached 
# and motile sea lice. For the time series, we only report motiles because that 
# is what was done consistently between all years.
field_lice <- read_csv(here("raw_data", "sample_results", "sealice", "sealice_field.csv")) %>% 
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
sealice_lab_mot <- read_csv(here("raw_data", "sample_results", "sealice", "sealice_lab_mot.csv"))

#sealice_lab_fs_mot are the data from Lauren Portner's fine scale taxonomic id
# that includes chalimus stages etc. It's mostly from 2015 fish (642 fish), 
# and some from 2017 (63 fish)
sealice_lab_fs_mot <- read_csv(here("raw_data", "sample_results", "sealice", "sealice_lab_fs.csv")) %>%
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
  inner_join(sealice_lab_motiles, by = "ufn") %>%
  #drop_na(cm_lab) %>% 
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

# In 2020 the stages were not identified in the lab but just counts of motile leps, or caligus  were conducted. So I just downloaded the google sheet manually to jsp-data and import that table here separately and combine with lab_lice before joining with field_lice to produce the time series. In 2021 if the sea lice data are added to the JSP Master Data Tables googlesheet, just change the name of the .csv file when it's exported from googlesheets to indicate 2021 is included in that file as well, and then update the read_csv code below to refelect the name of the file.
sealice_current <- read_csv(here("raw_data", "sealice_lab_mots_simple.csv")) %>%
  rename(motile_caligus_lab = cal_count, motile_lep_lab = lep_count) %>% 
  left_join(survey_seines_fish) %>% 
  select(ufn, site_id, species, survey_date, motile_caligus_lab, 
         motile_lep_lab)

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

write_csv(combined_motile_lice, here::here("tidy_data", "combined_motile_lice.csv"))

rm(field_lice, full_lab_lice)
