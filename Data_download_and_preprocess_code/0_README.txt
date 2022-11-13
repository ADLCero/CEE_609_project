
CEE 609 Project
FILE STRUCTURE

0_README.txt
= instructions

1_water_balance_ET.R
= R script for the data download and pre-process code for computing evapotranspiration using water balance method

2_watershed_boundaries.R
= R script for extracting the watershed boundaries of the study areas

3_remote_sensed_ET.R
= R script for the data download and pre-process code for remote-sensed evapotranspiration and other variables

4_remote_sensed_data.ipynb
= Jupyter notebook for downloading PET data and other remote-sensed data

5_combined_data
= Jupyter notebook of the final data frames


Others:
6_Sample_code_EE
= sample Java script for accessing evapotranspiration data through code.earthengine.google.com
*** does not work as intended yet


NOTES:

1. These R scripts must be ran in order so that the variables/dataframes created are available in the environment for the next step of pre-processing.

2. Precipitation data

Precipitation data was obtained using the R package rnoaa
Reference: https://docs.ropensci.org/rnoaa/
Metadata: https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt

Initially, gridded precipitation data from remote-sensed products were intended to be used.
However, it was decided to use data from weather stations such that the evapotranspiration computed using water balance method relies on data measured on ground.

Ideally, data from the station nearest to the USGS gauge will be used. However, it is highly likely that the data does not cover the entire time period that the discharge data does. While using combination of data from different stations is an option, for now, the nearest station with the most complete data was chosen. Initially, 20 of the nearest stations were explored. This number was increased if none of the stations yielded complete data.

This step can later on be refined to improve estimates of ET.

