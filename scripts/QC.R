# Data QC scripts

# Use this script to QC all data tables and write unit tests to check for errors.
# Any errors found should be corrected, tracked in the CHANGELOG,
# and the data re-uploaded to the portal, re-downloaded from the portal and
# run through QC scripts again


# Notes

# For sealice_field, check that cal_mot = cm_field + cpaf_field + caf_field
# Do fish that have a lice_id_protocol != NA have a value in lice?
#   Conversely, check that for each fish with field_licing_protocol, they have data in the corresponding table
# It seems inconsistent that licing_protocol_field is part of the lice dataset, but the lice_id_protocol and lice_collection_protocol is part of the fish dataset
#   Perhaps move licing_protocol_field to `fish`, and all fish that did not get field-loused have NA/null?
#   And then in the lice dataset (that gets distributed), can join lice_id_protocol

# QC flag columns for samples?

# Surveys - jsp_survey_id should be unique
# Seines - lat & long are swapped