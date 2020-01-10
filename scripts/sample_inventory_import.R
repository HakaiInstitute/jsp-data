library(tidyverse)
library(here)
library(googlesheets4)

fish_f <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_field_data.csv", guess_max = 20000)
fish_l <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/fish_lab_data.csv", guess_max = 20000)
fish <- full_join(fish_f, fish_l, by = "ufn")



# RNA:DNA -----------------------------------------------------------------





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

