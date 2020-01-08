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
         analyzing_lab,
         quality_level,
         quality_log)

write_csv(fa_fish,here("data","samples", "fatty_acid.csv"))


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
         analyzing_lab,
         quality_level,
         quality_log)

write_csv(iso_fish, here::here("data", "sample_results", "isotope_samples.csv"))

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
         analyzing_lab,
         quality_level,
         quality_log)

write_csv(xm_fish, here::here("data", "sample_results", "extra_muscle_samples.csv"))

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
         analyzing_lab,
         quality_level,
         quality_log)

write_csv(stom_fish, here::here("data", "sample_results", "stomach_samples.csv"))

# DNA --------------------------------------------------------------
dna_gs <- read_sheet("1Ti5gGvakA4DUTjCUZ_VYHULU_FJCK05-zdly5E80Tzs", sheet = "dna_metadata")
dna_ship_log <- read_sheet("1RF5yuH5bZj4fGrdXEdxgqCkr1MD2YaPX7UzS-MywhDQ", sheet = "dna_finclip") 

stock_id <- read_csv("https://raw.githubusercontent.com/HakaiInstitute/jsp-data/master/data/sample_results/stock_id.csv", guess_max = 2000)
