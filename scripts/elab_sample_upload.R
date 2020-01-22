library(tidyverse)
library(lubridate)
library(googlesheets4)
library(here)
library(xlsx)

fish_f <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_field_data.csv", guess_max = 20000)
fish_l <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_lab_data.csv", guess_max = 10000)

## Carcasses -----------------------------------------------------------------------------------------------------------------------------
carcass_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "carcass_metadata") %>% 
  filter(is.na(elab))
carcass_bags <- read_csv("G:/Shared drives/Juvenile Salmon Program/Sample Management/eLab Container Upload/elab_jsp_carcass_bags.csv")

carcass_elab <- left_join(select(carcass_gs, ufn, sample_id, container_id),
                          select(carcass_bags, name, destination),
                          by = c("container_id" = "name")) %>% 
  mutate(location = paste(destination, container_id, sep=" / ")) %>% 
  filter(ufn %in% fish_l$ufn) %>% 
  select(sample_id, location)
write_csv(carcass_elab, "carcass_elab_upload.csv")

                          
## Scales  -----------------------------------------------------------------------------------------------------------------------------
scale_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "scale_metadata")
scale_books <- read_csv("G:/Shared drives/Juvenile Salmon Program/Sample Management/eLab Container Upload/elab_jsp_scales.csv")

# Run a final QC check on sample locations, starting from scratch
scale_db <- read_csv(here::here("data", "sample_inventory", "scale_samples.csv")) %>% 
  left_join(select(scale_gs, ufn, container_id, container_cell), by = "ufn") %>%
  filter(ufn %in% fish_l$ufn) %>% 
  mutate(location_qc = paste(container_id, container_cell, sep="-")) %>% 
  group_by(location_qc) %>%
  mutate(sample_quality_flag = case_when(n() != 1 ~ "SVD",
                                         n() == 1 ~ "AV")) %>% 
  ungroup() %>% 
  mutate(sample_quality_log = case_when(sample_quality_flag == "SVD" ~ paste("Transcribed duplicate location", location_qc))) %>%
  select(sample_id:analyzing_lab, sample_quality_flag, sample_quality_log)

write_csv(scale_db, here("data", "sample_inventory", "scale_samples.csv"))

scale_elab <- inner_join(scale_gs,
                         filter(scale_db,
                                sample_quality_flag == "AV"),
                         by = "ufn") %>%
  left_join(scale_books, by = c("container_id" = "name")) %>% 
  mutate(location = paste(destination, container_id, sep = " / "),
         position = as.numeric(container_cell)) %>% 
  select(sample_id, position, location) %>% 
  arrange(location, position)

write_csv(scale_elab, here("elab_temp", "elab_scale_upload.csv"))
