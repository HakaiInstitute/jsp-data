library(hakaiApi)
library(tidyverse)
library(datamodelr)
library(DiagrammeR)

client <- hakaiApi::Client$new() 


# Download all data tables
fish_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fish?limit=-1')

fish <- client$get(fish_endpoint) %>% 
  select(hakai_id, semsp_id, jsp_survey_id, seine_id, date, 
         everything(), 
         -project, -action, -work_area, -survey)

survey_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_survey?limit=-1')

survey <- client$get(survey_endpoint) %>% 
  select(-action, -work_area, -seines_included, -survey, -sampling_bout)

seine_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_seine?limit=-1')

seine <- client$get(seine_endpoint) %>% 
  select(seine_id, jsp_survey_id, date, site_id, 
         everything(), gather_lat, gather_long, 
         -project, -action, -work_area, -survey, -pk)

bm_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_bycatch_mort?limit=-1')

bycatch_mort <- client$get(bm_endpoint) %>%
  left_join(select(survey, jsp_survey_id, site_id)) %>% 
  select(seine_id, jsp_survey_id, date, site_id, 
         everything(), 
         -project, -action, seine_id, -work_area)

activity_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_site_activity?limit=-1')

site_activity <- client$get(activity_endpoint) %>% 
  select(jsp_survey_id, date, site_id, everything(), -project, -action, -work_area) %>% 
  mutate(school_number = as.character(school_number), 
         school_sliders = as.factor(school_sliders), 
         school_poppers = as.factor(school_poppers), 
         school_dimpling = as.factor(school_dimpling))

lice_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_lice?limit=-1')

lice <- client$get(lice_endpoint) %>% 
  select(-action)

sealice_field <- lice %>%
  select(hakai_id, seine_id, jsp_survey_id, date,
         everything(),
         -ends_with("lab"), -starts_with("lab"), -project, -work_area, -survey) %>% 
  filter(!is.na(licing_protocol_field)) %>% 
  select(1:10, 29:31, everything()) %>%  #This removes all lab observations
  mutate(unid_cope_field = as.numeric(unid_cope_field),
         unid_chal_field = as.numeric(unid_chal_field),
         pinched_belly = as.numeric(pinched_belly))

sealice_lab_motiles <- lice %>%
  select(hakai_id, seine_id, jsp_survey_id, date,
         everything(),
         -(8:30), -project, -work_area, -survey) %>%  #This removes the lice counts & body abnormality observations recorded in the field 
  filter(!is.na(lab_count_motiles))  #Filtering out fish that received field enumeration only

sealice_finescale_endpoint <- sprintf(
  "%s/%s", client$api_root,
  'eims/views/output/jsp_lice_finescale?limit=-1')

sealice_finescale <- client$get(sealice_finescale_endpoint) %>% 
  select(hakai_id, seine_id, jsp_survey_id, date,
         everything(),
         -project, -action, -work_area, -survey)

rna_dna_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_rna_muscle?limit=-1')

rna_dna <- client$get(rna_dna_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

rna_pathogen_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_rna_pathogen?limit=-1')

rna_pathogen <- client$get(rna_pathogen_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)

fa_endpoint <- sprintf(
  "%s/%s", client$api_root, 
  'eims/views/output/jsp_fatty_acid?limit=-1')

fatty_acid <- client$get(fa_endpoint) %>% 
  left_join(select(fish, hakai_id), by = c("fish_id" = "hakai_id")) %>% 
  select(fish_id, hakai_id,
         everything(),
         -project, -action, -work_area, -survey, -comments)


# Create data model

dm <- dm_from_data_frames(survey, seine, site_activity, bycatch_mort, 
                          fish, rna_dna, rna_pathogen, fatty_acid,
                          sealice_field, sealice_finescale, sealice_lab_motiles)
graph <- dm_create_graph(dm, rankdir = "BT", col_attr = c("column"))
dm_render_graph(graph)

# Add references and primary keys

dm_erd <- dm_add_references(
  dm,
  
  seine$jsp_survey_id == survey$jsp_survey_id,
  bycatch_mort$seine_id == seine$seine_id,
  site_activity$jsp_survey_id == survey$jsp_survey_id,
  sealice_field$hakai_id == fish$hakai_id,
  sealice_finescale$hakai_id == fish$hakai_id,
  sealice_lab_motiles$hakai_id == fish$hakai_id,
  fish$seine_id == seine$seine_id,
  rna_dna$fish_id == fish$hakai_id,
  rna_pathogen$fish_id == fish$hakai_id,
  fatty_acid$fish_id == fish$hakai_id
)

graph <- dm_create_graph(dm_erd, rankdir = "RL", columnArrows = TRUE,  view_type = "keys_only",graph_attrs = "splines=polyline")
dm_render_graph(graph)
