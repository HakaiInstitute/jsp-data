library(hakaiApi)
library(tidyverse)
library(lubridate)
library(here)

# Connect R and EIMS Portal using hakaiApi
client <- hakaiApi::Client$new() 

fish_meta_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fish?meta&limit=-1')

fish_meta <- client$get(fish_meta_endpoint)

cols_endpoint <- sprintf(
  "%s/%s", client$api_root,
  'eims/lookup_display_columns?limit=-1'
)
cols <- client$get(cols_endpoint)