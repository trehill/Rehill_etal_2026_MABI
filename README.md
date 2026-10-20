# Grazing pressure limits giant kelp (*Macrocystis pyrifera*) recruitment and restoration potential in a temperate fjord

### This GitHub package contains data and scripts for producing the analyses and figures in the publication:

Rehill T, Dykman LN, Schuster JM, Baum JK (2026) Grazing pressure limits giant kelp (*Macrocystis pyrifera*) recruitment and restoration potential in a temperate fjord. Marine Biology. [ADD DOI] 

Archived version (data and scripts): [ADD DOI] 

### Software Versions:

R version 4.6.1 (2026-06-24) -- "Happy Hop" Copyright (C) 2026 The R Foundation for Statistical Computing. Platform: aarch64-apple-darwin23

### Folder Structure:

This GitHub package consists of four folders: 

1. raw_data - folder of raw data tables in .csv format (includes metadata/ with site coordinates)
2. processed_data - folder where cleaned and summarized data tables are written for use in other scripts 
3. figures - folder where figures produced by scripts are written 
4. scripts - folder of scripts 

### Data and Metadata Tables:

Raw and processed data tables are provided in the "raw_data" and "processed_data" folders in .csv format. Variable-level descriptions of every file are given in the data readme (0_ReadMe) deposited with the data. The data files are:

**Raw data (raw_data)**

- green_gravel_monitoring.csv - monthly plot-level monitoring of outplanted giant kelp on green gravel: number of gravels with live kelp, number of gravels remaining, kelp lengths, and counts of grazers in experimental plots.

- urchin_monitoring_transects.csv - quadrat-level counts of urchins, red turban snails, abalone and other invertebrates, with depth and substrate, from site-level transect surveys.

- ysi_measurement.csv - YSI ProDSS depth profiles (temperature, salinity, dissolved oxygen, pH) taken at 1 m increments at each site and monitoring period.

- metadata/site_coordinates_all.csv - latitude and longitude of the six study sites with site-level grazer density class and nearby kelp forest status.

- ENV/HOBO (raw logger files by site) - EnvLogger (temperature), HOBO Pendant (temperature and light) and drag-tilt (current) logger data from each site.

**Processed data (processed_data)**

- cleaned_data.csv - FINAL CLEAN DATA SHEET USED IN ANALYSIS. One row per plot per monitoring month (April to June 2024), combining plot-level kelp survival and growth, plot-level and site-level grazer densities, and site-level environmental variables.

- cleaned_green_gravel_monitoring.csv - cleaned plot-level monitoring data with August removed, including derived kelp survival, kelp growth and grazer densities.

- cleaned_green_gravel_monitoring_Aug.csv - the same cleaned plot-level data with August 2024 included (used for the supplement only).

- cleaned_monitoring_transects.csv - site-level grazer counts and densities (per square meter) by site and month from the transect surveys.

- cleaned_ysi_measurement.csv - bottom temperature, dissolved oxygen, salinity and pH by site and month.

- ENV/monitoring_periods.csv - start and end dates of the monitoring intervals at each site.

- ENV/combined_env.csv - all EnvLogger bottom temperature data combined across sites.

- ENV/HOBO/combined_hobo.csv - all HOBO bottom light and temperature data combined across sites.

- ENV/summary_hobo.csv - mean light and mean and maximum temperature per site and monitoring interval from HOBO loggers.

- ENV/HOBO/summary_hobo_light.csv - mean bottom light (lux) per site and monitoring interval.

- ENV/summary_env.csv - mean and maximum bottom temperature per site and monitoring interval from EnvLoggers.

- ENV/summary_temp.csv - final mean and maximum temperature per site and monitoring interval, combining HOBO and EnvLogger records.

- ENV/summary_tilt.csv - mean and maximum current speed (m/s) per site and monitoring interval from drag-tilt meters.


### Scripts and Workflow:

Scripts should be run in numerical order, as later scripts use files written by earlier ones. Note that the environmental data contain many missing values due to sensor issues, weather contingencies and aborted loggers.

#### 1. Run 1_Processing_Environmental_Data.Rmd

This script reads all raw logger files (HOBO, EnvLogger and tilt meter), combines them into one file per logger type, and creates plots of mean daily light (lux), mean daily temperature (degrees C) and mean daily current speed over time.

- Input:
	- all HOBO logger files (raw_data / ENV / HOBO)
	- all ENV logger files
	- all tilt meter files
- Output:
	- processed_data / ENV / HOBO / combined_hobo.csv
	- processed_data / ENV / combined_env.csv
	- processed_data / ENV / combined_tilt.csv
	- processed_data / ENV / tilt_summary.csv (current summarized by day, maximum and mean)
	- figures / meanlight.jpg
	- figures / meantemp_bysite.jpg
	- figures / meantemp.jpg
	- figures / current.jpg

#### 2. Run 2_QA_QC.Rmd

This script cleans the raw urchin transect, kelp outplant plot and environmental data (makes variables numeric, fixes data entry errors, creates new columns, renames sites for consistency, removes leading and trailing zeros). Logger data were summarized for the conditions between monitoring periods; data collected during monitoring periods were omitted. It creates the combined cleaned dataset for analysis and modelling, and determines the range of dissolved oxygen values for the supplemental table. Derived variables:

- Percent kelp survival = number of gravels with kelp / total number of gravels x 100
- Plot urchin density (individuals per square meter): open plots = total urchins / 1; caged plots = total urchins / 4.5 (the same calculation is used for red turban snails)
- Kelp growth = summed kelp length per plot


- Input:
	- raw_data / urchin_monitoring_transects.csv
	- raw_data / green_gravel_monitoring.csv
	- raw_data / ysi_measurement.csv
	- processed_data / ENV / HOBO / combined_hobo.csv
	- processed_data / ENV / monitoring_periods.csv
	- processed_data / ENV / combined_env.csv
	- processed_data / ENV / tilt_summary.csv
- Output:
	- processed_data / cleaned_green_gravel_monitoring.csv
	- processed_data / cleaned_monitoring_transects.csv
	- processed_data / cleaned_ysi_measurement.csv
	- processed_data / ENV / HOBO / summary_hobo.csv
	- processed_data / ENV / HOBO / summary_hobo_light.csv
	- processed_data / ENV / summary_env.csv
	- processed_data / ENV / summary_temp.csv
	- processed_data / ENV / summary_tilt.csv
	- processed_data / cleaned_data.csv

#### 3. Run 3_Density_Analysis.Rmd

This script determines the mean depth of the sites (including the shallowest and deepest), the number of each urchin species observed across sites, and produces bar plots of mean urchin and red turban snail densities across treatments and over time, baseline urchin densities, and stacked bar plots of species abundances at each site.

- Input:
	- processed_data / cleaned_monitoring_transects.csv
	- processed_data / cleaned_green_gravel_monitoring.csv
- Output:
	- figures / baseline_densities.png
	- figures / col_box_densities_by_site.png
	- figures / legend_densities.png
	- figures / densities_month_site_col.png
	- figures / bwbar_treatment.png
	- figures / bwdensity_site_month.png
	- figures / grazer_counts.png

#### 4. Run 4_Kelp_Analysis.Rmd

This script plots mean kelp survival and growth at each site and month by treatment (caged vs. open) and by gravel size (small vs. large). It performs t-tests for the caged vs. open effect on survival and growth, and tests whether kelp survival and growth differ among sites, among months, and between gravel sizes.

- Input:
	- processed_data / cleaned_monitoring_transects.csv [CONFIRM: this may be cleaned_data.csv or cleaned_green_gravel_monitoring.csv]
- Output:
	- figures / bwsurvival_site_month.png
	- figures / bwgrowth_site_month.png
	- figures / bwsurv_gravel_site_month.png
	- figures / bwgrwt_gravel_site_month.png
	- figures / bwbar_surv_open_v_caged.png
	- figures / bwbar_grwt_open_v_caged.png
	- figures / bwbar_surv_smallvlarge.png
	- figures / bwbar_growth_smallvlarge.png
	- figures / bwbar_surv_open_v_caged_august.png
	- figures / summary_plot.png

#### 5. Run 5_Experiment_GLMM.Rmd

This script runs generalized linear mixed-effects models for kelp survival (binomial) and kelp growth (Gamma), with treatment as a fixed effect and site as a random effect. Best models were selected by stepwise forward and backward selection based on AIC, model fit was evaluated with the DHARMa package, and variance inflation factors (VIF) of the selected predictors were assessed. Predictors tested: urchin site density, urchin plot density, red turban snail site density, red turban snail plot density, gravel size, mean and maximum temperature, mean current, mean light (lux), bottom dissolved oxygen and bottom salinity. The script also creates a correlation plot of the abiotic predictors and an estimate plot for both models.

- Input:
	- processed_data / cleaned_data.csv
- Output:
	- figures / abiotic_correlation_plot.png
	- figures / survival_testDispersion_plot.png
	- figures / survival_QQ_plot.png
	- figures / survival_residuals_vs_predictor.png
	- figures / growth_plot_testDispersion_plot.png
	- figures / growth_plot_QQ_plot.png
	- figures / growth_plot_residuals_vs_predictor.png
	- figures / combined_dot_and_whisker_plot.png

#### 6. Run 6_Urchin_GLMM.Rmd

This script runs a generalized linear mixed-effects model (Tweedie distribution) for urchin density within plots, with forward and backward selection based on AIC. Predictors: mean and maximum temperature, mean current, bottom dissolved oxygen, bottom salinity, and the interaction between treatment and site density. [CONFIRM: the scripts notes say site was a fixed effect; the paper uses site as a random effect]

- Input:
	- processed_data / cleaned_data.csv
- Output:
	- figures / ploturchin_testDispersion_plot.png
	- figures / ploturchin_QQ_plot.png
	- figures / ploturchin_residuals_vs_predictor.png

#### 7. Run 7_Regressions.Rmd

This script creates a pairwise correlation plot among environmental variables with linear trend lines, and runs linear regressions of the response variables (urchin density, kelp survival, kelp growth) against environmental and other predictors.

- Input:
	- processed_data / cleaned_data.csv
- Output:
	- figures / environmental_scatterplot_matrix.png

#### 8. Run 8_site_maps.Rmd

This script makes a map of the study sites, coloured by low, medium and high urchin density.

- Input:
	- raw_data / metadata / site_coordinates_all.csv
- Output:
	- figures / vancouver_island.png
	- figures / canada.png
	- figures / sites.png

#### 9. Run august_data.R

This script plots the August 2024 survival and growth data for the supplement. August data were not analyzed in the main paper because storms damaged or displaced many plots.

- Input:
	- raw_data / urchin_monitoring_transects.csv
	- raw_data / green_gravel_monitoring.csv
	- processed_data / ENV / monitoring_periods.csv
- Output:
	- figures / bwsurvival_site_august.png
	- figures / bwgrowth_site_august.png
