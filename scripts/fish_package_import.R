library(tidyverse)
library(googlesheets4)
library(here)
library(lubridate)

surveys <- read_csv(here::here("data", "survey_data.csv"))
seines <- read_csv(here::here("data", "seine_data.csv"))
ss <- left_join(seines, surveys, by = "survey_id")

# package_metadata <- read_csv("package_metadata.csv")
# 
# pkg_db_gs <- read_sheet("https://docs.google.com/spreadsheets/d/1hTC60Nc60k23rMMzcV9clPo4mcR1iqQYgKR2zD6nOfQ/edit#gid=1779412410", sheet = 'package_data')
# pkg_db <- pkg_db_gs %>%
#   select(package_id, seine_id, pkg_species, n_fish = number_of_fish, field_liced_status, preservation_status = pkg_preservation_status, pkg_comments) %>% 
#   filter(!package_id %in% package_metadata$package_id) %>% 
#   mutate(n_fish = as.numeric((n_fish)))
# 
# pkg_2018_f1_gs <- read_sheet("https://docs.google.com/spreadsheets/d/1v0MVKUKd526wOUXNSHsKNr1a9xLqRywfrs22smnpk2Y/edit#gid=1001866053", sheet = 'inv2018F1')
# pkg_2018_f1 <- pkg_2018_f1_gs %>% 
#   filter(!`package id` %in% pkg_db$package_id) %>% 
#   filter(!`package id` %in% package_metadata$package_id)
# 
# pkg_2018_f3_gs <- read_sheet("https://docs.google.com/spreadsheets/d/1v0MVKUKd526wOUXNSHsKNr1a9xLqRywfrs22smnpk2Y/edit#gid=1001866053", sheet = 'inv2018F3')
# pkg_2018_f3 <- pkg_2018_f3_gs %>% 
#   filter(!`package num` %in% pkg_db$package_id) %>% 
#   filter(!`package num` %in% package_metadata$package_id) %>% 
#   select(package_id = `package num`, seine_id = seine, pkg_species = species, n_fish = number) %>% 
#   drop_na(package_id)
# 
# pkg_add <- bind_rows(pkg_db, pkg_2018_f3)
# 
# write_csv(pkg_add, "temp_add_packages.csv")



inv2019 <- read_sheet("https://docs.google.com/spreadsheets/d/1v0MVKUKd526wOUXNSHsKNr1a9xLqRywfrs22smnpk2Y/edit#gid=1034160785", sheet = 'Fish')
pkg_db_gs <- read_sheet("https://docs.google.com/spreadsheets/d/1hTC60Nc60k23rMMzcV9clPo4mcR1iqQYgKR2zD6nOfQ/edit#gid=1779412410", sheet = 'package_data')


pkgs_ubc <- pkg_db_gs %>%  # This filters out all packages in the DB WIP file that are currently at UBC
  filter(pkg_location == "UBC Hunt Lab") %>% 
  filter(freezer_type != "NA")

pkgs_all <- read_csv("package_metadata.csv") %>%  # This file contains all package IDs ever assigned. It is filtered to select any package ID NOT currently in eLab, and isn't Sam's fish (which do not get tracked)
  filter(!package_id %in% inv2019$`Package ID`) %>% 
  filter(pkg_type != "SJ_UBC")

pkgs_ubc_elab <- left_join(pkgs_all, 
                           select(pkgs_ubc, package_id, pkg_location, freezer_shelf)) %>% 
  drop_na(pkg_location) %>% 
  mutate(type = "Fish Package",
         destination = paste(pkg_location, "JSP Undissected Fish Packages", freezer_shelf, sep=" / ")) %>% 
  select(name = package_id, type, destination) # This file is of fish packages currently in storage at UBC. This, combined with inv_2019, is the list of all fish packages currently inventoried in eLab.
write_csv(pkgs_ubc_elab, "eLab_JSP_New_Fish_Packages_UBC_Dec2019.csv")


pkgs_remaining <- pkgs_all %>%  
  filter(!package_id %in% pkgs_ubc_elab$name) # This should be all of the remaining package IDs that have yet to be inventoried in eLab (i.e., they are neither on Quadra nor UBC and have likely been dissected)

lab_2018 <- read_sheet("https://docs.google.com/spreadsheets/d/1qxzeH3F1z66QT8fGWH8aSLhK5c_41F18vaXabjnib6k/edit#gid=0", sheet = 'dissected_fish')
lab_pkgs_2018 <- lab_2018 %>% 
  group_by(package_id) %>% 
  summarize(count=n())
pkgs_2018 <- pkgs_remaining %>% 
  filter(package_id %in% lab_pkgs_2018$package_id) # These would be all the fish packages processed in the 2018-19 lab season (e.g. VF's fish, 2018 core JSP fish)

pkgs_remaining_elab <- left_join(pkgs_remaining,
                                 select(lab_2018, package_id, container_id),
                                 by = "package_id") %>% 
  distinct(package_id, .keep_all = TRUE)


fish <- read_csv(here::here("data", "fish_field_data.csv"), guess_max = 20000)

# missing_pkgs <- lab_2018 %>%
#   filter(!package_id %in% pkgs_2018$package_id) %>%
#   left_join(select(fish,
#                    ufn, seine_id, species),
#             by = "ufn") %>%
#   group_by(package_id, seine_id, species) %>%
#   summarize(count=n())



fish_lab_2018 <- read_sheet("https://docs.google.com/spreadsheets/d/1qxzeH3F1z66QT8fGWH8aSLhK5c_41F18vaXabjnib6k/edit#gid=0", sheet = 'fish_lab_data') %>% 
  drop_na(semsp_id)
  



