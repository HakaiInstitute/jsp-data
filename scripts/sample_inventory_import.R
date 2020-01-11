library(tidyverse)
library(here)
library(googlesheets4)
library(lubridate)

fish_f <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_field_data.csv", guess_max = 20000)
fish_l <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_lab_data.csv", guess_max = 20000)
fish <- full_join(fish_f, fish_l, by = "ufn")

# Fatty Acid --------------------------------------------------------------

fattyacid_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "fa_metadata")
fa_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "fatty_acid")

fa_qc <- left_join(fish_l, fattyacid_gs, by = "ufn") %>% 
  filter(is.na(sample_id))

fa_fish <- left_join(fattyacid_gs, select(fish_l, ufn, date_processed), by = "ufn") %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  mutate(analyzing_lab = ifelse(container_id %in% fa_ship_log$container_id, "JGarzke_UBC", NA),
         quality_level = "raw",
         quality_log = NA) %>% 
  select(ufn,
         sample_type,
         sample_id,
         sample_comments = comments_sample,
         analyzing_lab)

write_csv(fa_fish,here("data","sample_inventory", "fatty_acid.csv"))


# Test for missing samples

fa_GH <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/sample_results/fatty_acid_samples.csv")
fa_GS_flag <- fattyacid_gs %>% 
  filter(sample_qc_flag == "Y")
fa_GH_flag <- fa_GH %>% 
  filter(ufn %in% fa_GS_flag$ufn)

# Isotope --------------------------------------------------------------
iso_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "iso_metadata")
iso_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "isotope")

iso_qc <- left_join(fish_l, iso_gs, by = "ufn") %>% 
  filter(is.na(sample_id))

iso_fish <- left_join(iso_gs, select(fish_l, ufn, date_processed), by = "ufn") %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  mutate(analyzing_lab = ifelse(container_id %in% iso_ship_log$container_id, "DCostalago_UBC", NA),
         sample_type = ifelse(endsWith(sample_id, "IS2"), "isotope_CSIA", "isotope"),
         quality_level = "raw",
         quality_log = NA) %>% 
  select(sample_id,
         sample_type,
         ufn,
         sample_comments = comments_sample,
         analyzing_lab)

write_csv(iso_fish, here::here("data", "sample_inventory", "isotope_samples.csv"))

# Extra Muscle --------------------------------------------------------------
xm_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "xm_metadata")

xm_qc <- left_join(fish_l, xm_gs, by = "ufn") %>% 
  filter(is.na(sample_id)) %>% 
  filter(dissection_protocol == "irregular" | dissection_protocol == "full_2")

xm_fish <- left_join(xm_gs, select(fish_l, ufn, date_processed), by = "ufn") %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  mutate(analyzing_lab = NA,
         quality_level = "raw",
         quality_log = NA) %>% 
  select(sample_id,
         sample_type,
         ufn,
         sample_comments = comments_sample,
         analyzing_lab)

write_csv(xm_fish, here::here("data", "sample_inventory", "extra_muscle_samples.csv"))

# Stomachs --------------------------------------------------------------
stom_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "stomach_metadata")
stom_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "stomach")

stom_qc <- left_join(fish_l, stom_gs, by = "ufn") %>% 
  filter(is.na(sample_id)) %>% 
  filter(dissection_protocol == "irregular" | dissection_protocol == "full_1")
  # group_by(dissection_protocol) %>% 
  # summarize(count=n())

stom_fish <- left_join(stom_gs, select(fish_l, ufn, date_processed), by = "ufn") %>%
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  left_join(select(stom_ship_log, container_id, destination), by = "container_id") %>% 
  mutate(analyzing_lab = ifelse(container_id %in% stom_ship_log$container_id, "UBC", NA),
         quality_level = "raw",
         quality_log = NA) %>% 
  select(sample_id,
         sample_type,
         ufn,
         sample_comments = comments_sample,
         analyzing_lab)

write_csv(stom_fish, here::here("data", "sample_inventory", "stomach_samples.csv"))

# DNA --------------------------------------------------------------
dna_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "dna_metadata")
dna_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "dna_finclip") 

stock_id <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/sample_results/stock_id.csv", guess_max = 2000)

dna_qc <- dna_gs %>% 
  filter(!ufn %in% stock_id$ufn) %>% 
  filter(ufn %in% fish_f$ufn)

dna_fish <- stock_id %>% 
  mutate(sample_type = "DNA") %>% 
  select(sample_id, sample_type, ufn, tissue_type, sample_comments, analyzing_lab)

write_csv(dna_fish, here::here("data", "sample_inventory", "dna_samples.csv"))

stock_id_results <- stock_id %>% 
  drop_na(stock_1)

write_csv(stock_id_results, here::here("data", "sample_results", "stock_id.csv"))

dna_fish <- read_csv(here::here("data", "sample_inventory", "dna_samples.csv"), guess_max = 2000) %>% 
  left_join(select(stock_id_results, sample_id, quality_log), by = "sample_id")
write_csv(dna_fish, here::here("data", "sample_inventory", "dna_samples.csv"))
dna_fish <- read_csv(here::here("data", "sample_inventory", "dna_samples.csv"), guess_max = 10000)

## Whatman IDs
whatman_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "whatman_ids")

whatman_fish <- whatman_gs %>%   
  filter(ufn == "NA") %>%
  select(-ufn) %>%
  left_join(select(fish_f, ufn, semsp_id)) %>%
  mutate(
    sample_type = "DNA",
    tissue_type = "fin_clip",
    sample_comments = NA,
    analyzing_lab = ifelse(stock_id %in% stock_id_results$sample_id, "PBS", NA)) %>% 
  select(sample_id = stock_id,
         sample_type,
         ufn,
         tissue_type,
         sample_comments,
         analyzing_lab)

dna_fish_all <- bind_rows(whatman_fish,dna_fish)
write_csv(dna_fish_all, here::here("data", "sample_inventory", "dna_samples.csv"))


# Otolith --------------------------------------------------------------
oto_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "otolith_metadata")
oto_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "otolith")

oto_qc <- left_join(fish_l, oto_gs, by = "ufn") %>% 
  filter(is.na(sample_id)) %>% 
  filter(dissection_protocol == "irregular" | dissection_protocol == "full_1" | dissection_protocol == "full_2")

oto_fish <- left_join(oto_gs, select(fish_l, ufn, date_processed), by = "ufn") %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  left_join(select(oto_ship_log, container_id, destination), by = "container_id") %>% 
  mutate(analyzing_lab = ifelse(container_id %in% oto_ship_log$container_id, "YKuzmenko_UBC", NA)) %>% 
  select(sample_id,
         sample_type,
         ufn,
         sample_comments = comments_sample,
         analyzing_lab)

write_csv(oto_fish, here::here("data", "sample_inventory", "otolith_samples.csv"))

# Sea lice --------------------------------------------------------------

sl_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "sealice_metadata")
sl_fs <- sl_gs %>% 
  filter(sample_type == "sealice_finescale")

sl_fs_dp <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/sample_results/sealice_lab_fs.csv", guess_max = 1000) %>% 
  drop_na(sample_id)

sl_fs_qc <- sl_fs %>% 
  filter(!sample_id %in% sl_fs_dp$sample_id)
# The extra sample IDs are from fish that were deleted from the database

sl_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "sea_lice")

sl_id_gs <- sl_gs %>% 
  filter(sample_type == "sealice_finescale" | sample_type == "sealice_eth") %>% 
  mutate(sample_type = case_when(sample_type == "sealice_finescale" ~ "sealice_id_fs",
                                 sample_type == "sealice_eth" ~ "sealice_id_mot"))

sl_id_fish <- left_join(sl_id_gs, select(fish_l, ufn, date_processed), by = "ufn") %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  left_join(select(sl_ship_log, container_id, destination), by = "container_id") %>% 
  mutate(analyzing_lab = ifelse(container_id %in% sl_ship_log$container_id, "LPortner", NA)) %>% 
  select(sample_id,
         sample_type,
         ufn,
         sample_comments = comments_sample,
         analyzing_lab)

write_csv(sl_id_fish, here::here("data", "sample_inventory", "sea_lice_id_samples.csv"))
sl_id_fish <- read_csv(here::here("data", "sample_inventory", "sea_lice_id_samples.csv")) %>% 
  mutate(sample_subtype = case_when(sample_type == "sealice_id_fs" ~ "finescale",
                                    str_detect(sample_id, "LC") ~ "mot_cal",
                                    str_detect(sample_id, "LL") ~ "mot_lep",
                                    str_detect(sample_id, "SL1") ~ "mot_pool"),
         sample_type = "sealice_id") %>% 
  select(sample_id,
         sample_type,
         sample_subtype,
         ufn,
         sample_comments,
         analyzing_lab)
write_csv(sl_id_fish, here::here("data", "sample_inventory", "sea_lice_id_samples.csv"))


# Scales --------------------------------------------------------------
scales_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "scale_metadata")
scales_fish <- left_join(scales_gs, select(fish_l, ufn, date_processed), by = "ufn") %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  mutate(sample_id = paste("S", substr(ufn,2,8),"SC1", sep=""),
         sample_type = "scale",
         analyzing_lab = NA) %>% 
  select(sample_id,
         sample_type,
         ufn,
         sample_comments = comments_sample,
         analyzing_lab)

write_csv(scales_fish, here::here("data", "sample_inventory", "scale_samples.csv"))

# Carcass/Dissected Fish --------------------------------------------------------------
carc_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "carcass_metadata")
carc_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "carcass")
        
carc_qc <- left_join(fish_l, carc_gs, by = "ufn") %>% 
  filter(is.na(sample_id))

carc_fish <- left_join(carc_gs, select(fish_l, ufn, date_processed)) %>% 
  filter(!str_detect(sample_id, "U")) %>% 
  mutate(sample_type = "carcass",
         sample_subtype = ifelse(date_processed > as.Date("2018-01-08"), "muscle", "whole")) %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  select(sample_id,
         sample_type,
         sample_subtype,
         ufn,
         sample_comments = comments_sample)

write_csv(carc_fish, here::here("data", "sample_inventory", "carcasses_samples.csv"))

# RNA:DNA --------------------------------------------------------------
rd_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "rna-muscle_metadata")
rd_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "rna_dna")

rd_qc <- left_join(fish_l, rd_gs, by = "ufn") %>% 
  filter(is.na(sample_id)) %>% 
  # group_by(dissection_protocol) %>% 
  # summarize(count=n()) %>% 
  filter(dissection_protocol == "full1")

rd_fish <- left_join(rd_gs, select(fish_l, ufn, date_processed), by = "ufn") %>% 
  drop_na(date_processed) %>% 
  filter(sample_id != "UNKNOWN") %>% 
  left_join(select(rd_ship_log, container_id, destination), by = "container_id") %>% 
  mutate(analyzing_lab = case_when(destination == "UBC Hunt Lab (Jessica Garzke)" ~ "JGarzke_UBC",
                                   destination == "Hakai Marna Lab" ~ "Hakai",
                                   sample_id %in% list1$sample_id ~ "Hakai",
                                   sample_id %in% list2$sample_id ~ "Hakai",
                                   sample_id %in% list3$sample_id ~ "Hakai",
                                   ufn %in% list4$ufn ~ "Hakai")) %>% 
  select(ufn,
         sample_type,
         sample_id,
         sample_comments = comments_sample,
         analyzing_lab)

list1 <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/juvenile-salmon/master/Sample%20Requests/RNA-DNA/2019-07-26_cjanusson_2017-18_D09_SO_subsample.csv?token=AHVGT6WQTSLZCFCJJGPUGGS6EI3JA")
list2 <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/juvenile-salmon/master/Sample%20Requests/RNA-DNA/2019-08-13_cjanusson_RNA-DNA_2019_D09_SO.csv?token=AHVGT6V7RDEURBAZNNQH3MC6EI75Y")
list3 <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/juvenile-salmon/master/Sample%20Requests/RNA-DNA/2019-08-14_cjanusson_2017-18_D09_SO_subsample2.csv?token=AHVGT6SE6S3RUQNRFNXS62C6EI75U")
list4 <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/juvenile-salmon/master/Sample%20Requests/RNA-DNA/2019-08-30_cjanusson_RNA-DNA_2019_D09_SO.csv?token=AHVGT6UUPAOTSVQVO3C37I26EI75S")

write_csv(rd_fish, here::here("data", "sample_inventory", "rna_dna_samples.csv"))
# Make sure to update samples with 2019 data, and that some exist in list 1-4 that need to have their analyzing lab set to 'Hakai'

# RNA-Pathogen --------------------------------------------------------------
rna_gill <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "rna-gill_metadata")
rna_brain <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "rna-brain_metadata")
rna_spleen <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "rna-spleen_metadata")
rna_liver <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "rna-liver_metadata")
rna_heart <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "rna-heart_metadata")
rna_kidney <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "rna-kidney_metadata")

rna_containers <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "sample_container_inventory") %>% 
  filter(str_detect(container_type, "pathogens"))

rna_gill <- rna_gill %>% 
  mutate(sample_type = "RNA_pathogens",
         sample_subtype = "gill",
         sample_id = paste("U", substr(ufn, 2,8), "RG1", sep=""))

rna_brain <- rna_brain %>% 
  mutate(sample_type = "RNA_pathogens",
         sample_subtype = "brain",
         sample_id = paste("U", substr(ufn, 2,8), "RB1", sep=""))

rna_spleen <- rna_spleen %>% 
  mutate(sample_type = "RNA_pathogens",
         sample_subtype = "spleen",
         sample_id = paste("U", substr(ufn, 2,8), "RS1", sep=""))

rna_liver <- rna_liver %>% 
  mutate(sample_type = "RNA_pathogens",
         sample_subtype = "liver",
         sample_id = paste("U", substr(ufn, 2,8), "RL1", sep=""))

rna_heart <- rna_heart %>% 
  mutate(sample_type = "RNA_pathogens",
         sample_subtype = "heart",
         sample_id = paste("U", substr(ufn, 2,8), "RH1", sep=""))

rna_kidney <- rna_kidney %>% 
  mutate(sample_type = "RNA_pathogens",
         sample_subtype = "kidney",
         sample_id = paste("U", substr(ufn, 2,8), "RK1", sep=""))

rna_path <- bind_rows(rna_gill, rna_brain, rna_spleen, rna_liver, rna_heart, rna_kidney) %>% 
  left_join(rna_containers, by = "container_id") %>% 
  left_join(fish_l) %>% 
  drop_na(sample_id) %>% 
  mutate(analyzing_lab = case_when(current_location == "Hakai Quadra Marna Lab" ~ "PBS",
                                   current_location == "Pacific Biological Station" ~ "PBS")) %>% 
  select(sample_id,
         sample_type,
         sample_subtype,
         ufn,
         sample_comments = comments_sample,
         analyzing_lab)

write_csv(rna_path, here::here("data", "sample_inventory", "rna_pathogen_samples.csv"))
