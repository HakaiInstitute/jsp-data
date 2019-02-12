# CHANGELOG
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added


### Changed
- Species in `bycatch_mort` no longer use four-letter codes; instead, their common names are fully spelled out 

### Fixed
- Surveys DE278, DE289, DE293, DE321, DE334, DE348, and DE360 incorrectly had their zone listed as "E"; corrected to "W"


## [0.2.0] - 2018-10-15
### Added
- 2017 fish dissections and 2018 field collection data
- New dataset `sealice_lab_finescale` for sea lice taxonomy data that includes very detailed species, life stages, and sex data , contributed by Sean Godwin and Lauren Portner

### Changed
- Sea licing protocol categories expanded for added clarity of protocol, such as differentiating "lab_finescale" from "lab_motiles"
- In `zoop_tows`, 'volume' renamed to 'corrected_volume' to reflect that the volume has been corrected for flowmeter calibrations.
- 'seine_id' format for a few seine records changed to become more consistent

### Removed
- Sample inventory information, due to becoming quickly outdated.


## [0.1.2] - 2018-?-?
### Changed
- In `fish_field_data`, 'analysis_planned' for fish in packages JP49 and JP50 set to "field loused only" due to fish no longer being available for laboratory dissections


## [0.1.1] - 2018-04-19 (?)
### Added
- New dataset `surface_activity` that quantifies visual observations of fish-related surface activity for 2017 surveys.
- New records to `fish_field_data` of fish caught in 2017 that were field liced, but not retained, 
- New column in `fish_field_data` called 'analysis_planned' to denote whether a fish had been field loused only (and not retained for further analysis), were retained for Sam James's UBC diet study, or were retained for standard SEMSP lab analysis
- New records in `package_data` of undissected 2015 non-core pink, chum, coho, and herring that were inventoried in -80 Freezer 1, shelf 2, on 2018-02-05/06
- New records in `sealice_lab_motiles` of fish that received finescale motile enumeration and identification Lauren Portner in winter 2018

### Changed
- In `fish_lab_data`, 'dissection_protocol' of fish U2256-U2260 changed from "lice enumeration only" to "irregular work-up"
- In `fish_field_data`, 'dissection_status' of 2015 & 2016-caught sockeye updated to be current as of 2017-12-08, wherein we completed dissections of core site subsamples for 2015/2016
- In `fish_field_data`, `fish_lab_data`, `stock_id`, and `sealice_lab_motiles, 2-character UFNs now have leading zeroes before the number, e.g. "U1" -> "U01"
- Updated records in `stock_id` with proper 'sample_id' and 'ufn' associations (no change to results)

### Fixed
- In `survey_data`, assigned mixing 'ctd_cast_id' to survyes DE340, DE341, and DE329
- In `stock_id`, re-assignment of results due to PBS "off by 1" data entry error for the following records:
  - U515, U299, U300, U307, U308, U317, U318, U319, U328, U331, U332, U333, U408, U409, U410, U466, U467, U468, U470, U491, U492, and U482


## [0.1.0] - 2018-?-?
- This was the first version of the data package and did not receive a hakaisalmon R package version number. The dataset, however, can be found at http://dx.doi.org/10.21966/1.566666 or in the commit history of this package.