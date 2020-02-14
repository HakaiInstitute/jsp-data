library(tidyverse)
library(lubridate)
library(googlesheets4)
library(here) # Open file within jsp-data project to use here::here()

fish_l <- read_csv(here("data", "fish_lab_data.csv"), guess_max = 10000)
fish_f <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_field_data.csv", guess_max = 20000)

# I manually cut & copied columns from Google sheets for rna_path, fatty_acid, and extra_muscle
# before appending data in R. The process is the same.

## RNA:DNA Update --------------------------------------------------------------
list20190726 <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/juvenile-salmon/master/Sample%20Requests/RNA-DNA/2019-07-26_cjanusson_2017-18_D09_SO_subsample.csv?token=AHVGT6W4N6CQNSPCKITM5IS6JLU6C") %>% 
  select(ufn) %>% 
  mutate(date_requested = "2019-07-26")
list20190813 <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/juvenile-salmon/master/Sample%20Requests/RNA-DNA/2019-08-13_cjanusson_RNA-DNA_2019_D09_SO.csv?token=AHVGT6TSEZB5L5IFUQDPJJ26JLVAI") %>% 
  select(ufn) %>% 
  mutate(date_requested = "2019-08-13")
list20190814 <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/juvenile-salmon/master/Sample%20Requests/RNA-DNA/2019-08-14_cjanusson_2017-18_D09_SO_subsample2.csv?token=AHVGT6RO4W7IHUMI6KYHS7C6JLVAK") %>% 
  select(ufn) %>% 
  mutate(date_requested = "2019-08-14")
list20190830 <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/juvenile-salmon/master/Sample%20Requests/RNA-DNA/2019-08-30_cjanusson_RNA-DNA_2019_D09_SO.csv?token=AHVGT6VM3F5Y3E63TXYF5E26JLVAO") %>% 
  select(ufn) %>% 
  mutate(date_requested = "2019-08-30")

rna_subsamples <- bind_rows(list20190726,list20190813,list20190814,list20190830)

rna_dna <- read_csv(here("data", "sample_inventory", "rna_dna_samples.csv")) %>% 
  mutate(analyzing_lab = case_when(ufn %in% rna_subsamples$ufn ~ "Hakai",
                                    TRUE ~ as.character(analyzing_lab)))
write_csv(rna_dna, here("data", "sample_inventory", "rna_dna_samples.csv"))

rna_fish <- anti_join(fish_l, rna_dna, by = "ufn")



## DNA Update ------------------------------------------------------------------
dna_db <- read_csv(here("data", "sample_inventory", "dna_samples.csv"))
dna_2019 <- read_sheet("144T4uYN55sY4FHRt7h6QzvvAVrgXc6biFnbxZd_g4z4", sheet = "DNA") %>% 
  mutate(sample_type = "DNA",
         sample_subtype = "muscle",
         sample_quality_flag = "AV") %>% 
  select(sample_id, sample_type, sample_subtype, ufn, sample_comments, sample_quality_flag)

dna_new <- bind_rows(dna_db, dna_2019)
write_csv(dna_new, here("data", "sample_inventory", "dna_samples.csv"))

## Scale Update ------------------------------------------------------------------
scale_db <- read_csv(here("data", "sample_inventory", "scale_samples.csv"), guess_max = 10000)
scale_2019 <- read_sheet("144T4uYN55sY4FHRt7h6QzvvAVrgXc6biFnbxZd_g4z4", sheet = "scale") %>% 
  mutate(sample_type = "scale",
         sample_quality_flag = "AV") %>% 
  select(sample_id, sample_type, ufn, sample_comments, sample_quality_flag)

scale_new <- bind_rows(scale_db, scale_2019)

write_csv(scale_new, here("data", "sample_inventory", "scale_samples.csv"))

## Sea Lice Microbiome Update --------------------------------------------------
slmb_db <- read_csv(here("data", "sample_inventory", "sea_lice_microbiome_samples.csv"))
slmb_2019 <- read_sheet("144T4uYN55sY4FHRt7h6QzvvAVrgXc6biFnbxZd_g4z4", sheet = "sea_lice") %>% 
  mutate(sample_type = "sealice_microbiome",
         sample_subtype = "mot_pool",
         sample_quality_flag = "AV",
         analyzing_lab = "UBC_Suttle") %>% 
  select(sample_id, sample_type, sample_subtype, ufn, sample_comments, analyzing_lab, sample_quality_flag)

slmb_new <- bind_rows(slmb_db, slmb_2019)

write_csv(slmb_new, here("data", "sample_inventory", "sea_lice_microbiome_samples.csv"))

## Stomach Update --------------------------------------------------------------
stomach_db <- read_csv(here("data", "sample_inventory", "stomach_samples.csv"), guess_max = 10000)
stomach_unp_2019 <- read_sheet("144T4uYN55sY4FHRt7h6QzvvAVrgXc6biFnbxZd_g4z4", sheet = "stomach_unprocessed")
stomach_prc_2019 <- read_sheet("144T4uYN55sY4FHRt7h6QzvvAVrgXc6biFnbxZd_g4z4", sheet = "stomach_processed") 

stomach_unp_2019_tidy <- stomach_unp_2019 %>% 
  mutate(sample_type = "stomach",
         sample_subtype = "gut_whole",
         analyzing_lab = case_when(sample_id_1 %in% stomach_prc_2019$sample_id_1 ~ "Hakai")) %>% 
  select(sample_id = sample_id_1, sample_type, sample_subtype, ufn, sample_comments, analyzing_lab)

stomach_prc_2019_tidy <- stomach_unp_2019 %>% 
  drop_na(sample_id_2) %>%
  filter(sample_id_2 != "noid") %>% 
  mutate(sample_type = "stomach",
         sample_subtype = "gut_contents") %>% 
  select(sample_id = sample_id_2, sample_type, sample_subtype, ufn)

stomach_2019 <- bind_rows(stomach_unp_2019_tidy, stomach_prc_2019_tidy) %>% 
  mutate(sample_quality_flag = "AV")

stomach_new <- bind_rows(stomach_db, stomach_2019) %>% 
  mutate(sample_subtype = replace_na(sample_subtype, "gut_whole")) %>% 
  select(sample_id, sample_type, sample_subtype, ufn, 4:7)

write_csv(stomach_new, here("data", "sample_inventory", "stomach_samples.csv"))


## Stomach Contents Results ----------------------------------------------------
sto_conts <- read_csv(here("data", "sample_results", "salmon_diets_coarse.csv")) %>%
  # filter(!sample_id %in% stomach_new$sample_id) %>% 
  mutate(total = rowSums(.[6:13]),
         quality_level = "level1",
         quality_flag = case_when(total == 100 ~ "AV",
                                  dominant_taxa == "empty" & total == 0 ~ "AV",
                                  total != 100 ~ "SVC"),
         quality_log = case_when(quality_flag == "SVC" ~ "Sum of taxa proportions does not equal 100")
  ) %>% 
  select(-total)
write_csv(sto_conts, here("data", "sample_results", "salmon_diets_coarse.csv"))
         