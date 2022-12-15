
CEE 609 Project
FILE STRUCTURE

0_Important_changes.txt
= important changes in the project

0_README.txt
= instructions


1_water_balance_ET.R
= R script for the data download and pre-process code for computing evapotranspiration using water balance method


2_watershed_boundaries.R
= R script for extracting the watershed boundaries of the study areas


3_remote_sensed_ET.R
= R script for the data download and pre-process code of remote-sensed evapotranspiration 


4_remote_sensed_predictors_1.R
= R script for the data download and pre-process code of predictors, except NDVI


4_remote_sensed_predictors_NDVI.R
= R script for the data download and pre-process code of NDVI


5_combined_data.R
= R script for combining the necessary data into a single data frame



Others:

6_NorthForkSC_watershed_download.txt
= the package used (USGS StreamStats) to download the watershed boundaries does not work (for some unknown reasons) for this site. This .txt file contains the instructions on how to download the shape file from the USGS StreamStats website.



NOTES:

1. These R scripts must be ran in order so that the variables/data frames/functions created are available in the environment for the next step of pre-processing.


2. Precipitation data for water balance ET

Precipitation data was obtained using the R package rnoaa
Reference: https://docs.ropensci.org/rnoaa/
Metadata: https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt

Initially, gridded precipitation data from remote-sensed products were intended to be used.
However, it was decided to use data from weather stations such that the evapotranspiration computed using water balance method relies on data measured on ground.

Ideally, data from the station nearest to the USGS gauge will be used. However, it is highly likely that the data does not cover the entire time period that the discharge data does. While using combination of data from different stations is an option, for now, the nearest station with the most complete data was chosen. Initially, 20 of the nearest stations were explored. This number was increased if none of the stations yielded complete data.

This step can later on be refined to improve estimates of ET.


3. NDVI values were obtained from two different data sets:
For 1989-10-01 to 2000-09-30,
Landsat 5 TM Collection 1 Tier 1 8-Day NDVI Composite

For 2000-10-01 to 2020-09-30,
MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km

Annual averages from Landsat are lower than the annual averages from MODIS.

