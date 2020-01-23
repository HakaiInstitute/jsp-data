library(tidyverse)
library(lubridate)
library(googlesheets4)
library(here)
library(xlsx)
library(gtools)
library(naturalsort)

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


## Otoliths  -----------------------------------------------------------------------------------------------------------------------------
oto_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "otolith_metadata")
oto_boxes <- read_csv("G:/Shared drives/Juvenile Salmon Program/Sample Management/eLab Container Upload/elab_jsp_otoliths.csv")
oto_ship <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "otolith")

oto_db <- read_csv(here::here("data", "sample_inventory", "otolith_samples.csv"), guess_max = 10000) %>% 
  left_join(select(oto_gs, ufn, container_id, container_cell)) %>% 
  filter(ufn %in% fish_l$ufn &
           container_cell != "NA") %>% 
  mutate(location_qc = paste(container_id, container_cell, sep = "-")) %>% 
  group_by(location_qc) %>% 
  mutate(sample_quality_flag = case_when(n() != 1 ~ "SVC",
                                         n() == 1 ~ "AV")) %>% 
  ungroup() %>% 
  mutate(analyzing_lab = ifelse(container_id %in% oto_ship$container_id, "UBC_Hunt", NA),
         sample_quality_log = case_when(sample_quality_flag == "SVC" ~ paste("Cannot be verified. Transcribed duplicate location", location_qc))) %>% 
  select(sample_id:analyzing_lab, sample_quality_flag, sample_quality_log)

write_csv(oto_db, here("data", "sample_inventory", "otolith_samples.csv"))

convert <- read_csv(here("elab_temp", "convert_5Ax20N.csv"))

oto_elab <- inner_join(oto_gs,
                       filter(oto_db,
                              sample_quality_flag == "AV"),
                       by = "sample_id") %>% 
  left_join(oto_boxes, by = c("container_id" = "name")) %>% 
  left_join(convert) %>% 
  mutate(location = paste(destination, container_id, sep = " / "),
         position = as.numeric(ifelse(str_detect(container_cell, "[:alpha:]"), elab,
                                      container_cell))) %>% 
  select(sample_id, position, location) %>% 
  arrange(location, position)

# oto_elab <- oto_elab[mixedorder(oto_elab$position),] %>% 
#   arrange(location)

write_csv(oto_elab, here("elab_temp", "elab_oto_upload.csv"))

## Sea Lice Microbiome -----------------------------------------------------------------------------------------------------------------------------
sl_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "sealice_metadata")
slmb_gs <- sl_gs %>% 
  filter(str_detect(sample_type, "cryo"))
sl_ship <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "sea_lice")

slmb_db <- read_csv(here("data", "sample_inventory", "sea_lice_microbiome_samples.csv"), guess_max = 10000) %>%
  full_join(select(slmb_gs,
                   ufn, sample_id, container_id, container_cell)
            ) %>% 
  mutate(location_qc = paste(container_id, container_cell, sep = "-")) %>% 
  group_by(location_qc) %>% 
  mutate(sample_quality_flag = case_when(location_qc == "NA-NA" ~ "AV",
                                         n() != 1 ~ "SVC",
                                         n() == 1 ~ "AV")
         ) %>% 
  ungroup() %>%
  arrange(location_qc) %>%
  mutate(sample_type = "sealice_microbiome",
         sample_subtype = case_when(str_detect(sample_id, "LC") ~ "mot_cal",
                                    str_detect(sample_id, "LL") ~ "mot_lep",
                                    str_detect(sample_id, "SL1") ~ "mot_pool"
                                    ),
         sample_quality_log = case_when(sample_quality_flag == "SVC" ~ paste("Cannot be verified. Transcribed duplicate location", location_qc)),
         analyzing_lab = case_when(container_id %in% sl_ship$container_id ~ "UBC_Suttle", 
                                   location_qc == "NA-NA" ~ "UBC_Suttle")
         ) %>% 
  select(sample_id, sample_type, sample_subtype, ufn, sample_comments, analyzing_lab, sample_quality_flag, sample_quality_log)

write_csv(slmb_db, here("data", "sample_inventory", "sea_lice_microbiome_samples.csv"))
