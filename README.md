# Grazing pressure limits giant kelp (*Macrocystis pyrifera*) recruitment and restoration potential in a temperate fjord

### This GitHub package contains data and scripts for producing the analyses and figures in the publication:

Rehill T, Dykman LN, Schuster JM, Baum JK (2026) Grazing pressure limits giant kelp (*Macrocystis pyrifera*) recruitment and restoration potential in a temperate fjord. Marine Biology. [accepted: 2026-10-10] DOI: 10.1007/s00227-026-04977-5

### Software Versions:

R version 4.6.1 (2026-06-24) \-- "Happy Hop" Copyright (C) 2026 The R Foundation for Statistical Computing. Platform: aarch64-apple-darwin23

### Folder Structure:

This GitHub package consists of four folders:

1. raw\_data \- folder of raw data tables in .csv format (includes metadata/ with site coordinates)  
2. processed\_data \- folder where cleaned and summarized data tables are written for use in other scripts  
3. figures \- folder where figures produced by scripts are written  
4. scripts \- folder of scripts

### Data and Metadata Tables:

Raw and processed data tables are provided in the "raw\_data" and "processed\_data" folders in .csv format. Data are also permanently stored in the repository Borealis (https://borealisdata.ca/) in the "Kelp Rescue Initiative" collection associated with the above publication [DOI: https://doi.org/10.5683/SP4/CATTWB]. It is recommended to source data from Borealis because it includes comprehensive metadata and additional raw data files that were too large to upload to GitHub. The data files are:

**Raw data (raw\_data)**

- YSI\_measurement.csv \- YSI ProDSS depth profiles (temperature, salinity, dissolved oxygen, pH) taken at 1 m increments at each site and monitoring period.

- green\_gravel\_monitoring.csv \- monthly plot-level monitoring of outplanted giant kelp on green gravel: number of gravels with live kelp, number of gravels remaining, kelp lengths, and counts of grazers in experimental plots.

- urchin\_monitoring\_transects.csv \- quadrat-level counts of urchins, red turban snails, abalone and other invertebrates, with depth and substrate, from site-level transect surveys.

- ENV \- folder of raw EnvLogger (temperature) data files from each site.

- HOBO \- folder of raw HOBO Pendant (temperature and light) logger data files from each site.

- metadata / site\_coordinates\_all.csv \- latitude and longitude of the six study sites with site-level grazer density class and nearby kelp forest status.

- TILT  \- Files too large to upload \- available in Borealis [DOI: https://doi.org/10.5683/SP4/CATTWB] or by author upon request ([laurenndykman@gmail.com](mailto:laurenndykman@gmail.com))

**Processed data (processed\_data)**

- cleaned\_data.csv \- FINAL CLEAN DATA SHEET USED IN ANALYSIS. One row per plot per monitoring month (April to June 2024), combining plot-level kelp survival and growth, plot-level and site-level grazer densities, and site-level environmental variables.

- cleaned\_green\_gravel\_monitoring.csv \- cleaned plot-level monitoring data with August removed, including derived kelp survival, kelp growth and grazer densities.

- cleaned\_green\_gravel\_monitoring\_Aug.csv \- the same cleaned plot-level data with August 2024 included (used for the supplement only).

- cleaned\_monitoring\_transects.csv \- site-level grazer counts and densities (per square meter) by site and month from the transect surveys.

- cleaned\_ysi\_measurement.csv \- bottom temperature, dissolved oxygen, salinity and pH by site and month.

- ENV / combined\_env.csv \- all EnvLogger bottom temperature data combined across sites.
  
- ENV / combined\_tilt.csv \- All tilt current data combined across sites - file too large to upload - available in Borealis [DOI: https://doi.org/10.5683/SP4/CATTWB] or by author upon request ([laurenndykman@gmail.com](mailto:laurenndykman@gmail.com))

- ENV / monitoring\_periods.csv \- start and end dates of the monitoring intervals at each site.

- ENV / summary\_env.csv \- mean and maximum bottom temperature per site and monitoring interval from EnvLoggers.

- ENV / summary\_temp.csv \- final mean and maximum temperature per site and monitoring interval, combining HOBO and EnvLogger records.

- ENV / summary\_tilt.csv \- mean and maximum current speed (m/s) per site and monitoring interval from drag-tilt meters.

- ENV / HOBO / combined\_hobo.csv \- all HOBO bottom light and temperature data combined across sites.

- ENV / HOBO / summary\_hobo.csv \- mean light and mean and maximum temperature per site and monitoring interval from HOBO loggers.

- ENV / HOBO / summary\_hobo\_light.csv \- mean bottom light (lux) per site and monitoring interval.

### Scripts and Workflow:

Scripts should be run in numerical order, as later scripts use files written by earlier ones. Note that the environmental data contain many missing values due to sensor issues, weather contingencies and aborted loggers.

#### 1\. Run 1\_Processing\_Environmental\_Data.Rmd

This script reads all raw logger files (HOBO, EnvLogger and tilt meter), combines them into one file per logger type, and creates plots of mean daily light (lux), mean daily temperature (degrees C) and mean daily current speed over time.

- Input:

  - all HOBO logger files (raw\_data / HOBO)  
  - all ENV logger files (raw\_data / ENV)  
  - all tilt meter files (raw\_data / TILT) - files too large to upload - available in Borealis [DOI: https://doi.org/10.5683/SP4/CATTWB] or by author upon request ([laurenndykman@gmail.com](mailto:laurenndykman@gmail.com))
 
- Output:

  - processed\_data / ENV / HOBO / combined\_hobo.csv  
  - processed\_data / ENV / combined\_env.csv  
  - processed\_data / ENV / combined\_tilt.csv - file too large to upload - available in Borealis [DOI: https://doi.org/10.5683/SP4/CATTWB] or by author upon request ([laurenndykman@gmail.com](mailto:laurenndykman@gmail.com))
  - plots / environmental\_supps / current.jpg  
  - plots / environmental\_supps / meanlight.jpg  
  - plots / environmental\_supps / meantemp.jpg  
  - plots / environmental\_supps / meantemp\_bysite.jpg

#### 2\. Run 2\_QA\_QC.Rmd

This script cleans the raw urchin transect, kelp outplant plot and environmental data (makes variables numeric, fixes data entry errors, creates new columns, renames sites for consistency, removes leading and trailing zeros). Logger data were summarized for the conditions between monitoring periods; data collected during monitoring periods were omitted. It creates the combined cleaned dataset for analysis and modelling, and determines the range of dissolved oxygen values for the supplemental table.

- Derived variables:

  - kelp\_survival \= percent kelp survival \= number of gravels with kelp / total number of gravels x 100  
  - urchin\_density \= individuals per square meter in plots  
    - open plots \= total urchins / 1  
    - caged plots \= total urchins / 4.5  
    - the same calculation is used for red turban snails  
  - kelp\_growth \= summed kelp length per plot
 
- Input:

  - raw\_data / green\_gravel\_monitoring.csv  
  - raw\_data / urchin\_monitoring\_transects.csv  
  - raw\_data / YSI\_measurement.csv  
  - processed\_data / ENV / HOBO / combined\_hobo.csv  
  - processed\_data / ENV / combined\_env.csv  
  - processed\_data / ENV / monitoring\_periods.csv  
  - processed\_data / ENV / combined\_tilt.csv - file too large to upload - available in Borealis [DOI: https://doi.org/10.5683/SP4/CATTWB] or by author upon request ([laurenndykman@gmail.com](mailto:laurenndykman@gmail.com))

- Output:

  - processed\_data / cleaned\_data.csv  
  - processed\_data / cleaned\_green\_gravel\_monitoring.csv  
  - processed\_data / cleaned\_monitoring\_transects.csv  
  - processed\_data / cleaned\_ysi\_measurement.csv  
  - processed\_data / ENV / HOBO / summary\_hobo.csv  
  - processed\_data / ENV / HOBO / summary\_hobo\_light.csv  
  - processed\_data / ENV / summary\_env.csv  
  - processed\_data / ENV / summary\_temp.csv  
  - processed\_data / ENV / summary\_tilt.csv

#### 3\. Run 3\_Density\_Analysis.Rmd

This script determines the mean depth of the sites (including the shallowest and deepest) and the number of each urchin species observed across sites. It produces bar plots of mean urchin and red turban snail densities across treatments and over time, baseline urchin densities, and stacked bar plots of species abundances at each site.

- Input:

  - processed\_data / cleaned\_monitoring\_transects.csv  
  - processed\_data / cleaned\_green\_gravel\_monitoring.csv
 
- Output:

  - plots / grazer\_densities / grazer\_counts.png  
  - plots / urchin\_densities / baseline\_densities.png  
  - plots / urchin\_densities / bwbar\_treatment.png  
  - plots / urchin\_densities / bwdensity\_site\_month.png  
  - plots / urchin\_densities / col\_box\_densities\_by\_site.png  
  - plots / urchin\_densities / densities\_month\_site\_col.png  
  - plots / urchin\_densities / legend\_densities.png

#### 4\. Run 4\_Kelp\_Analysis.Rmd

This script plots mean kelp survival and growth at each site and month by treatment (caged vs. open) and by gravel size (small vs. large). It performs t-tests for the caged vs. open effect on survival and growth, and tests whether kelp survival and growth differ among sites, among months, and between gravel sizes.

- Input:

  - processed\_data / cleaned\_green\_gravel\_monitoring.csv
  
- Output:

  - plots / gravel\_size / bwbar\_growth\_smallvlarge.png  
  - plots / gravel\_size / bwbar\_surv\_smallvlarge.png  
  - plots / gravel\_size / bwgrwt\_gravel\_site\_month.png  
  - plots / gravel\_size / bwsurv\_gravel\_site\_month.png  
  - plots / kelp\_growth / bwbar\_grwt\_open\_v\_caged.png  
  - plots / kelp\_growth / bwgrowth\_site\_month.png  
  - plots / kelp\_survival / bwbar\_surv\_open\_v\_caged.png  
  - plots / kelp\_survival / bwbar\_surv\_open\_v\_caged\_august.png  
  - plots / kelp\_survival / bwsurvival\_site\_month.png  
  - plots / kelp\_survival / summary\_plot.png

#### 5\. Run 5\_Experiment\_GLMM.Rmd

This script runs generalized linear mixed-effects models for kelp survival (binomial) and kelp growth (Gamma), with treatment as a fixed effect and site as a random effect. Best models were selected by stepwise forward and backward selection based on AIC, model fit was evaluated with the DHARMa package, and variance inflation factors (VIF) of the selected predictors were assessed. Predictors tested: urchin site density, urchin plot density, red turban snail site density, red turban snail plot density, gravel size, mean and maximum temperature, mean current, mean light (lux), bottom dissolved oxygen and bottom salinity. The script also creates a correlation plot of the abiotic predictors and an estimate plot for both models.

- Input:

  - processed\_data / cleaned\_data.csv
 
- Output:

  - plots / models / abiotic\_correlation\_plot.png&nbsp;  
  - plots / models / survival\_residuals\_plot.png&nbsp;  
  - plots / models / survival\_QQ\_plot.png  
  - plots / models / survival\_testDispersion\_plot.png  
  - plots / models / survival\_residuals\_vs\_predictor.png  
  - plots / models / length\_plot\_QQ\_plot.png  
  - plots / models / length\_plot\_residuals\_vs\_predictor.png  
  - plots / models / length\_plot\_testDispersion\_plot.png

#### 6\. Run 6\_Urchin\_GLMM.Rmd

This script runs a generalized linear mixed-effects model (Tweedie distribution) for urchin density within plots, with forward and backward selection based on AIC. Predictors: mean and maximum temperature, mean current, bottom dissolved oxygen, bottom salinity, and the interaction between treatment and site density.

- Input:

  - processed\_data / cleaned\_data.csv

- Output:

  - plots / models / urchin\_residuals\_plot.png&nbsp;  
  - plots / models / urchin\_QQ\_plot.png  
  - plots / models / urchin\_residuals\_vs\_predictor.png  
  - plots / models / urchin\_testDispersion\_plot.png

#### 7\. Run 7\_Regressions.Rmd

This script creates a pairwise correlation plot among environmental variables with linear trend lines, and runs linear regressions of the response variables (urchin density, kelp survival, kelp growth) against environmental and other predictors.

- Input:

  - processed\_data / cleaned\_data.csv

- Output:

  - figures / environmental\_supps / environmental\_scatterplot\_matrix.png

#### 8\. Run 8\_site\_maps.Rmd

This script makes a map of the study sites, coloured by low, medium and high urchin density.

- Input:

  - raw\_data / metadata / site\_coordinates\_all.csv

- Output:

  - plots / maps / canada.png  
  - plots / maps / sites.png  
  - plots / maps / vancouver\_island.png

#### 9\. Run august\_data.R

This script plots the August 2024 survival and growth data for the supplement. August data were not analyzed in the main paper because storms damaged or displaced many plots.

- Input:

  - raw\_data / green\_gravel\_monitoring.csv  
  - raw\_data / urchin\_monitoring\_transects.csv  
  - processed\_data / ENV / monitoring\_periods.csv
 
- Output:

  - plots / kelp\_survival / bwgrowth\_site\_august.png  
  - plots / kelp\_survival / bwsurvival\_site\_august.png
