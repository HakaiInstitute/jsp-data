library(tidyverse)
library(lubridate)
library(googlesheets4)
library(here)
library(glmmTMB)
library(broom.mixed)
library(lme4)

# Combine motile sea lice counts from lab and field in 2022
lab_2022 <- read_sheet("11w3WJE491tou8FexQ4ya4PgaRTNJ09oG0KHjcTB-GW8", 
                      sheet = 'sealice_lab_motiles')
field_2022 <- read_sheet("1ezxMrD7g-0ExabJv6mLWg4gPthOSiEyLo5vi-D-BGxI", 
                        sheet = 'sealice_field_data')

field_2022 <- field_2022 %>% 
  mutate(total_count_field = cam + caf + cgf + lam + laf + lgf) %>%
  select(ufn, total_count_field)

motile_2022 <- left_join(lab_2022, field_2022, by = "ufn") %>%
  select(ufn, total_motile_field = total_count_field, total_motile_lab = total_count) |> 
  drop_na()

# Import 2018 sea lice inter comparison method exp. data

slug <- "1q-CqZvSf8iFTC_z_Qtn6kaisQ9rJPqxwye-Aq-uF7ZA"
# Compare total counts in lab vs. in field ------------------------------------
all_lab <- read_sheet(slug,
                      sheet = "sealice_fine_fieldcat") %>%
  select(ufn, total_attached_lab, total_motile_lab)

all_field <- read_sheet(slug, sheet = "sealice_field") %>%
  select(ufn, total_attached_field, total_motile_field)

lab_vs_field <- left_join(all_lab,all_field, by="ufn") |>
  drop_na() |> #removes one fish that was only sealiced in the lab not the field
  select(ufn, total_motile_lab, total_motile_field)

lab_vs_field <- bind_rows(lab_vs_field, motile_2022)

#check how many unique fish are in the dataset
length(unique(lab_vs_field$ufn))

write_csv(lab_vs_field, here("supplemental_materials", "scripts", "technical validation",
                             "motile_sealice_counts_validation.csv"))

lab_vs_field <- read_csv(here("supplemental_materials", "scripts", "technical validation",
                         "motile_sealice_counts_validation.csv"))


# Given we have collected counts of sea lice on salmon using two different
# methods to determine if the methods result in comparable data

# Calculate Spearman's correlation
cor.test(lab_vs_field$total_motile_field, lab_vs_field$total_motile_lab, method = "spearman")
# measures are related but offers a crude estimate due to overdispersion and zero inflation

# Test whether data are overdispersed
# Fit a basic Poisson model
poisson_model <- glm(total_motile_field ~ total_motile_lab, family = poisson, data = lab_vs_field)

# Calculate residual deviance and degrees of freedom
resid_dev <- poisson_model$deviance
df <- poisson_model$df.residual

# Compare
(overdispersion_ratio <- resid_dev / df)
# Doesn't appear to be overdispersed

# Check for zero inflation
# Predicted zeros based on Poisson model
predicted_zeros <- sum(predict(poisson_model, type = "response") == 0)

# Observed zeros
observed_zeros <- sum(lab_vs_field$total_motile_field == 0)

# Test if observed zeros are greater than expected zeros
(zero_inflation_test <- if (observed_zeros > predicted_zeros) TRUE else FALSE)
# Appears to be zero inflated

# Given that the data appear to be zero inflated but not overdispersed I will use a poisson model with zero inflation

# Fit the Zero-Inflated Poisson Model with a nested random effect for each fish to capture the paired nature of the measurements
# Load the glmmTMB package

# Assuming `pair_id` is a unique identifier for each pair in your data
zip_model_mixed <- glmmTMB(total_motile_lab ~ total_motile_field + (1|ufn),
                           ziformula = ~1, 
                           family = poisson(),
                           data = lab_vs_field,
                           na.action = na.omit,
                           control=glmmTMBControl(optimizer=optim,
                                                  optArgs=list(method="BFGS")))
# Summary of the model
summary(zip_model_mixed)
