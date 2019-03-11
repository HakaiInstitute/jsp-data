library(tidyverse)
library(lubridate)
library(here)
library(RSQLite)
library(dbplyr)

surveys <- read_csv("data/surveys.csv")
seines <- read_csv("data/seines.csv")
site_activity <- read_csv("data/site_activity.csv")
bycatch_mort <- read_csv("data/bycatch_mort.csv")
fish <- read_csv("data/fish.csv")
stock_id <- read_csv("data/stock_id_samples.csv")

# These tables still need reformatting
# rna_dna <- read_csv("data/rna_dna_samples.csv")
# rna_pathogens <- read_csv("data/rna_pathogen_samples.csv")
# fatty_acids <- read_csv("data/fatty_acid_samples.csv")
# isotopes <- read_csv("data/isotope_samples.csv")
# extra_muscle <- read_csv("data/extra_muscle_samples.csv")
# stomachs <- read_csv("data/stomach_samples.csv")
# otoliths <- read_csv("data/otolith_samples.csv")
# scales <- read_csv("data/scale_samples.csv")

jsp_db_file <- "database/jsp_database.sqlite"
jsp_db <- src_sqlite(jsp_db_file, create = TRUE)

# Completed
# copy_to(jsp_db, surveys)
# copy_to(jsp_db, seines)
# copy_to(jsp_db, site_activity)
# copy_to(jsp_db, bycatch_mort)
# copy_to(jsp_db, fish)
# copy_to(jsp_db, stock_id)

