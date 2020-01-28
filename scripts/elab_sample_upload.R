library(tidyverse)
library(lubridate)
library(googlesheets4)
library(here)
#library(xlsx)
library(gtools)

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
  # filter(!ufn %in% fish_l$ufn) %>% # There are 2019 samples that are not in fish_l
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


## Sea Lice ID -----------------------------------------------------------------------------------------------------------------------------
slid_gs <- sl_gs %>% 
  filter(!str_detect(sample_type, "cryo")) %>% 
  filter(ufn %in% fish_l$ufn) %>% 
  arrange(container_id)
write_csv(slid_gs, here("elab_temp", "elab_slid_upload.csv"))


## Extra Muscle -----------------------------------------------------------------------------------------------------------------------------
xm_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "xm_metadata")
xm_db <- read_csv(here("data", "sample_inventory", "extra_muscle_samples.csv"), guess_max = 10000) %>% 
  full_join(xm_gs) %>% 
  mutate(location_qc = paste(container_id, container_cell, sep = "-")) %>% 
  group_by(location_qc) %>% 
  mutate(sample_quality_flag = case_when(container_id == "UNKNOWN" ~ "MV",
                                         n() != 1 ~ "SVC",
                                         n() == 1 ~ "AV")
  ) %>% 
  ungroup() %>%
  mutate(sample_quality_log = NA) %>% 
  select(sample_id:analyzing_lab, sample_quality_flag, sample_quality_log)

write_csv(xm_db, here("data", "sample_inventory", "extra_muscle_samples.csv"))

freezer <- read_sheet("1v0MVKUKd526wOUXNSHsKNr1a9xLqRywfrs22smnpk2Y", sheet = "RNA, FA, XM, SL") %>% 
  mutate(location = paste(destination, name, sep = " / ")) %>% 
  select(container_id = name, location)

xm_boxes <- freezer %>% 
  filter(str_detect(container_id, "BXM"))

xm_elab <- xm_db %>% 
  filter(sample_quality_flag == "AV") %>% 
  left_join(select(xm_gs, sample_id, container_cell, container_id)) %>% 
  left_join(xm_boxes) %>% 
  mutate(container_cell = as.numeric(container_cell)) %>% 
  arrange(container_id, container_cell)
xm_elab <- xm_elab[mixedorder(xm_elab$container_id),]
  
write_csv(xm_elab, here("elab_temp", "elab_xm_upload.csv"))


## DNA -----------------------------------------------------------------------------------------------------------------------------

dna_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "dna_metadata") 
whatman_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "whatman_ids")
stock_id <- read_csv(here::here("data", "sample_results", "stock_id.csv"))
dna_ship <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "dna_finclip")

dna <- dna_gs %>%
  filter(str_detect(ufn, "U")) %>%
  filter(ufn %in% fish_f$ufn) %>%
  mutate(container_cell = as.character(container_cell),
         sample_type = "DNA",) %>% 
  select(
    sample_id,
    sample_type,
    sample_subtype = tissue_type,
    ufn,
    container_id,
    container_cell,
    sample_comments = comments_sample
  )

whatman <- whatman_gs %>% 
  select(-ufn) %>% 
  left_join(select(fish_f, semsp_id, ufn)) %>% 
  filter(ufn %in% fish_f$ufn) %>% 
  filter(!stock_id %in% dna$sample_id) %>% 
  mutate(sample_comments = "NA",
         sample_type = "DNA",
         sample_subtype = "fin_clip",
         container_cell = "NA") %>% 
  select(sample_id = stock_id,
         sample_type,
         sample_subtype,
         ufn,
         container_id = whatman_sheet,
         container_cell,
         sample_comments)

dna_all <- bind_rows(dna,whatman) %>% 
  mutate(location_qc = paste(container_id, container_cell, sep = "-")) %>% 
  group_by(location_qc) %>% 
  mutate(analyzing_lab = case_when(container_id %in% dna_ship$container_id ~ "PBS",
                                   sample_id %in% stock_id$sample_id ~ "PBS"),
         sample_quality_flag = ifelse(container_cell == "UNKNOWN", "MV", "AV"),
         sample_quality_log = case_when(sample_quality_flag == "MV" ~ paste("Sample location unknown & cannot be verified"))) %>% 
  ungroup() %>% 
  select(-container_id, container_cell, location_qc)

write_csv(dna_all, here::here("data", "sample_inventory", "dna_samples.csv"))


stockid_position_convert <- read_csv(here::here("elab_temp", "stockid_position_convert.csv")) %>% 
  select(-species)
dna <- read_csv(here::here("data", "sample_inventory", "dna_samples.csv"))

elab_finclip_2015_2016 <- dna %>% 
  left_join(stockid_position_convert) %>% 
  drop_na(container_id) %>% 
  mutate(location = paste("Prep Salmon Shelves / JSP Fin Clip Binder 2016 / ", container_id, sep="")) %>% 
  select(sample_id, position, location) %>% 
  arrange(position)

elab_finclip_2015_2016 <- elab_finclip_2015_2016[mixedorder(elab_finclip_2015_2016$location),]
write_csv(elab_finclip_2015_2016, here::here("elab_temp", "elab_finclip2015-16_upload.csv"))  


dna_containers <- read_csv("G:/Shared drives/Juvenile Salmon Program/Sample Management/eLab Container Upload/elab_jsp_dna.csv") %>% 
  select(-tray)
dna_remaining <- dna %>% 
  filter(!sample_id %in% elab_finclip_2015_2016$sample_id) %>% 
  left_join(select(dna_gs, sample_id, container_id, container_cell)) %>% 
  left_join(dna_containers, by = c("container_id" = "name"))

elab_dna_boxes <- dna_remaining[mixedorder(dna_remaining$location),] %>% 
  filter(sample_subtype != "fin_clip" & !is.na(location)) %>% 
  mutate(container_cell = as.numeric(ifelse(container_cell == "NA", "", container_cell))) %>% 
  select(sample_id, position = container_cell, location)
write_csv(elab_dna_boxes, here::here("elab_temp", "elab_dna_box_upload.csv"))

elab_finclip_2017_2018 <- dna %>% 
  filter(!sample_id %in% elab_finclip_2015_2016$sample_id & !sample_id %in% elab_dna_boxes$sample_id & sample_subtype == "fin_clip") %>% 
  left_join(select(dna_gs, sample_id, container_id, container_cell))

fc2018_convert <- read_sheet("1AXbYFbl52gXBeCxdMGyG1vNThQMV3TnhicQb_753qsY", sheet = "Sheet5") %>% 
  uncount(weights = 30, .id = "position", .remove = F) %>% 
  mutate(location = paste(container_id, 1:n(), sep="-"))

elab_finclip_2018 <- elab_finclip_2017_2018 %>% 
  filter(str_detect(container_id, "BWS")) %>% 
  mutate(location = paste(container_id, container_cell, sep="-")) %>% 
  left_join(select(fc2018_convert, position, location)) %>% 
  arrange(position)
elab_finclip_2018 <- elab_finclip_2018[mixedorder(elab_finclip_2018$container_id),] %>% 
  select(sample_id, position, container_id)
write_csv(elab_finclip_2018, here::here("elab_temp", "elab_finclip2018_upload.csv"))

whatman_2017_convert <- stockid_position_convert %>% 
  filter(container_id == "DW1" & position <= 30) %>% 
  select(position, whatman_cell)

elab_finclip_2017 <- elab_finclip_2017_2018 %>% 
  filter(str_detect(container_id, "DW") | str_detect(container_id, "JW")) %>% 
  mutate(container_cell = as.character(container_cell)) %>% 
  left_join(whatman_2017_convert, by = c("container_cell" = "whatman_cell")) %>% 
  select(sample_id, position, container_id)
write_csv(elab_finclip_2017, here::here("elab_temp", "elab_finclip2017_upload.csv"))
