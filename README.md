# README

There are several codes I use in the assignment.
1. Files with suffix .do are the scripts or do-file in statistical programming software STATA
2. Files with suffix .R are the R scripts used to run combinatorial optimisation

The working steps are:
- Data cleaning using `cleaning_popistat.do` (for aggregate population statistics) and `cleaning_rcfl.do` (for ISTAT labour force survey)
- Combinatorial optimisation is then run using `optimisation.R`
- The resulting dataframe with reweighted individuals are then processed before visualised using ArcGIS through `post_reweighting.do`
- Validation is conducted using both `validation_external.do` and `validation_internal.do`
