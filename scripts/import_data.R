# This script reads in the Hakai Institute Juvenile Salmon Program data from the
# Hakai Ecological Information Management System Data Portal. The purpose is
# to create discrete versions of the data from the Portal, to track changes or
# additions, QC data, and release citable versions of our growing data set.

library(hakaiApi)
library(tidyverse)
library(lubridate)
library(here)

# Connect R and EIMS Portal using hakaiApi
client <- hakaiApi::Client$new() 

# Endpoints in Portal that can be downloaded (I got this list from Nate because
#   currently a list of endpoints isn't available in any documentation):

# jsp_survey
# jsp_bycatch_mort
# jsp_seine
# jsp_site_activity
# jsp_fish
# jsp_lice
# jsp_lice_finescale
# jsp_fin_clip
# jsp_dna
# jsp_otolith
# jsp_lice_sample
# jsp_fatty_acid
# jsp_scale
# jsp_stomach
# jsp_extra_muscle
# jsp_isotope
# jsp_rna_muscle
# jsp_rna_pathogen

# Download all data tables from data portal.
fish_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fish?limit=-1')

fish <- client$get(fish_endpoint)

write_csv(fish, here("data", "fish.csv"))

