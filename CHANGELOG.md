# CHANGELOG
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [1.3.0] - 2022-04-11

### Changed
- CTD data now only includes data from the downcast, and not the upcast
- Restructured the repository folders so that one flat and wide data file (jsp_catch_and_bio_data_complete.csv) is joined and available in the root of the repo.

### Added
- 2021 Field season data from field and lab
- Added fork length, weight, and bycatch to OBIS record
- Added scientific name of each species to bycatch_mort.csv file
- Added latitude and longitude for all sites in sites.csv

### Fixed
- Readme file's description of what the workflow is for progressing data through various folders and the function of each script
- Corrected Pacific Sand Lance scientific name from Ammodytes hexapterus to Ammodytes personatus

## [1.2.0] - 2021-03-22


### Added
- 2020 field data results
- 2020 fish dissection results
- RNA pathogen results data from Kristi Miller's lab  at DFO for 2015 and 2016 sockeye, pink, and chum
- New column added for sea lice presence absence in fish_field_data.
- All CTD data collected during juvenile salmon sampling
- 2018 and 2019 Genetic stock ID
- 2019 finclip dna sample inventory
- Data wrangling code and processed-data for OBIS (Ocean Biodiversity Information System)

### Fixed
- Species ID as sockeye was changed based on results of genetic stock ID for:
  - U16451: Coho
  - U17041: Coho
  - U17291: Pink
  - U20467: Coho
  - U20469: Chum
  - U20774: Chum
  - U20864: Chum

### Changed
- Combined the annual-observations-report (time-series) code and data into this repository and deprecated the `jsp-time-series` repo.

## [1.1.0] - 2020-02-14
### Added
- 2019 results to **fish_lab_data**
- Sockeye diet results (see: data/sample_results/sockeye_diets) from 302 sockeye caught in 2015 and 2016 from Sam James' MSc. thesis
- Sample inventory for all tissue samples collected from dissections: **RNA:DNA**,  **RNA-pathogens**, **fatty acid**, **stable isotope**, **stomach**, **scale**, **otolith**, **sea lice ID**, **sea lice microbiome**, **DNA**, **extra muscle**, and **carcass**. 
This is just the complete list of samples taken and does not contain any physical location data. Location data can be found on eLabJournal.
- Coarse taxonomic analysis of gut contents of some 2019 sockeye (see: data/sample_results/salmon_diets_coarse.csv)

### Fixed
- U20251 `species` corrected from "CO" to "CK"
- Updated seine DE607N1 to reflect change in species ID
- Used zooplankton tow coordinates for seine DE293N1 due to transcribed seine coordinates being on land
- Added missing `lat`/`long` for JE225N1
- Fixed incorrect `lat` value for DE526N1
- Incorrect DNA **sample_ids** for U3984-U3993 (changed from DH00041-DH00050 to DH00051-DH00060)
- **fish_lab_data** **comments_protocol** that U2208 has no otolith samples, not U2209

### Changed
- Folder sample_results contains **sockeye_diets**, **sealice_lab_fs**, and **stock_id**
- Added prefixes to `quality_flag` and `quality_log` in **seine_data**, **fish_field_data**, and **fish_lab_data** so they don't conflict when merging tables
- Dissection protocol categories in **fish_lab_data** renamed for better readibility (also updated in data dictionary)
- UFN assignment of undissected fish from 2015-2016 now follow the relative order of the SEMSP IDs
- Updated `comments_protocol` for: U17095 & U17096 in **fish_lab_data** to state that these fish do not have gill samples;
U5030 has no RNA-muscle sample;
U13005 has no RNA-kidney sample
- `quality_level` categories now conform with [Hakai Data Standards draft document](https://docs.google.com/document/d/1lxCjpDwCmuC-3M45_t7ULQEVH8RNQ_VmD2jnXQ06GTc/edit#heading=h.pw951oeyk6om)

### Removed
- Deleted seine with no data due to being botched: JE304N1
- UFNs from **stock_id** with no results; those samples can now be found in data/sample_inventory/dna_samples.csv
- Fish SEMSP IDs 2016-06-22-D21-SO-31 to SO-60 and U19102-U19131 because these were trainer fish and not part of the standard processing stream
- `ufn` and `tissue_type` columns from **stock_id**

----------

## [1.0.2] - 2019-10-24
### Fixed
- Fish U20181 species changed from "CO" to "CK"
- Updated catch statistics for seine DE617N1 to reflect change to U20181 species ID

### Added
- Chum retained for GM that wasn't originally entered into **fish_field_data** (U22681, JE524N2)

### Changed
- Updated `cu_retained` for JE524N2 to reflect GM CU added
- U20841 & U20844 given new package ID because they were pink that were originally packaged with chum

----------

## [1.0.1] - 2019-10-21
### Fixed
- Fish U20371 species changed from "CU" to "SO"
- Updated catch statistics for seine DE612N1 to reflect change to U20371 species ID

----------

## [1.0.0] - 2019-10-08
### Added
- 2019 field collection data
- New tables **sites** and **site_coordinates** that contain geographic metadata
- 2018 fish dissections and sea-louse enumeration
- Fish that previously did not have `fork_length_lab` measurements now have a modeled value generated from `standard_length_lab` measurements using lab data from 2015 to February 2019 (**juvenile-salmon** repository release 2019-02-21)
- In **site_activity**, surveys with no observations (ie., no activity sighted) have a single record where `school_number` == 0
- New column 'lice_id_protocol_field' to **fish_field_data**
- New table **zoop_tax** for zooplankton taxonomy samples
- Added additional metadata to **zoop_tows**: `cast_num`, `tow_type`, `line_out`, `flow_flag`, `solo_id`,	`solo_depth`,	`tow_split`, `sample_collected`, `zoop_tow_comments`
- Added 2018 zooplankton tow & sample metadata
- Added `ctd_drop` to **survey_data**
- Added more sampling metadata to **ysi**, updated all records from the EIMS data portal

### Changed
- Species in **bycatch_mort** no longer use four-letter codes; instead, their common names are fully spelled out 
- In **sites**, site "J09" renamed to "Bauza Cove"
- All timestamps reformatted to "yyyy-mm-dd hh:mm Z"
- In **survey_data**, renamed "ebb tide" to "ebb" for consistency
- All fish with only SEMSP IDs (undissected specimens from 2015-16) have now been retroactively assigned
UFNs for database consistency

### Fixed
- In **survey_data**, blank cells for DFO surveys changed to NA (no data)
- Surveys DE278, DE289, DE293, DE321, DE334, DE348, and DE360 incorrectly had their `zone` listed as "E"; corrected to "W"
- In **sealice_field**, replaced cal & mot counts from 0 to NA for all fish with `lice_id_protocol_field` == "salmoncoast_motiles"
- In **fish_lab_data**, `sealice_protocol_lab` changed to NA for 2015/2016 fish dissected 2018-07 only for DNA collection

### Removed
- Geographic site metadata from **survey_data** (migrated to new tables)
- Removed the following records from **sealice_finescale** due to no results: U41, U148, U150, U1189, U1375, U1393, U1397, U1411 
- `preservation_status` no longer an attribute of **seine_data**, and is being migrated to **package_data** upon next release
- In **survey_data**, `ysi_cast_id`, `ctd_cast_id`, `secchi`, and `zoop_sample_id` columns (must manually join oceanography data by date, site, etc)
- `photo_number` from **fish_lab_data**
- 1 chum from seine DE371N1 with no UFN or SEMSP ID (trainer fish)
- `dissection_status` from **fish_field_data** (can determine if a fish has been dissected by joining it with fish_lab_data to see if it has a `date_processed` value
- Removed from **sealice_lab_fs** any UFNs that do not exist in **fish_lab_data** (discarded due to qc) or do not have results (i.e., unprocessed samples)
- Removed zooplankton sample IDs from **zoop_tows** and placed in new table with associated tow IDs
- `ctd_cast_id` no longer part of **survey_data**

----------

## [0.2.0] - 2018-10-15
### Added
- 2017 fish dissections and 2018 field collection data
- New dataset **sealice_lab_finescale** for sea lice taxonomy data that includes very detailed species, life stages, and sex data, contributed by Sean Godwin and Lauren Portner

### Changed
- Sea licing protocol categories expanded for added clarity of protocol, such as differentiating "lab_finescale" from "lab_motiles"
- In **zoop_tows**, `volume` renamed to `corrected_volume` to reflect that the volume has been corrected for flowmeter calibrations.
- `seine_id` format for a few seine records changed to become more consistent

### Removed
- Sample inventory information, due to becoming quickly outdated.

----------

## [0.1.2] - 2018-?-?
### Changed
- In **fish_field_data**, 'analysis_planned' for fish in packages JP49 and JP50 set to "field loused only" due to fish no longer being available for laboratory dissections

----------

## [0.1.1] - 2018-04-19 (?)
### Added
- New dataset **surface_activity** that quantifies visual observations of fish-related surface activity for 2017 surveys.
- New records to **fish_field_data** of fish caught in 2017 that were field liced, but not retained, 
- New column in **fish_field_data** called 'analysis_planned' to denote whether a fish had been field loused only (and not retained for further analysis), were retained for Sam James's UBC diet study, or were retained for standard SEMSP lab analysis
- New records in **package_data** of undissected 2015 non-core pink, chum, coho, and herring that were inventoried in -80 Freezer 1, shelf 2, on 2018-02-05/06
- New records in **sealice_lab_motiles** of fish that received finescale motile enumeration and identification Lauren Portner in winter 2018

### Changed
- In **fish_lab_data**, `dissection_protocol` of fish U2256-U2260 changed from "lice enumeration only" to "irregular work-up"
- In **fish_field_data**, `dissection_status` of 2015 & 2016-caught sockeye updated to be current as of 2017-12-08, wherein we completed dissections of core site subsamples for 2015/2016
- In **fish_field_data**, **fish_lab_data**, **stock_id**, and **sealice_lab_motiles, 2-character UFNs now have leading zeroes before the number, e.g. "U1" -> "U01"
- Updated records in **stock_id** with proper `sample_id` and `ufn` associations (no change to results)

### Fixed
- In **survey_data**, assigned mixing 'ctd_cast_id' to survyes DE340, DE341, and DE329
- In **stock_id**, re-assignment of results due to PBS "off by 1" data entry error for the following records:
  - U515, U299, U300, U307, U308, U317, U318, U319, U328, U331, U332, U333, U408, U409, U410, U466, U467, U468, U470, U491, U492, and U482

----------

## [0.1.0] - 2018-?-?
- This was the first version of the data package and did not receive a hakaisalmon R package version number. The dataset, however, can be found at http://dx.doi.org/10.21966/1.566666 or in the commit history of this package.