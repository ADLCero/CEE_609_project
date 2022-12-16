
MODEL TRAINING AND VALIDATION CODE

0_Important_changes.txt
= important changes on the methods for this section of the project

0_README.txt
= instructions

1_Model_training_OysterNH.R
= script for formulating the regression model for actual evapotranspiration, with the water balance ET as the predictand and precipitation, PET, soil moisture, maximum temperature, and maximum NDVI as the predictors.

For NDVI, annual maximum values were chosen instead of annual mean because there is a wider gap between the means from water years 1990-2000 (from LANDSAT) and 2001-2021 (from MODIS) compared to the gap between the annual maximums.

Scripts for each watershed were separated since model selection process greatly varies:

1_Model_training_OysterNH.R
2_Model_training_WappingerNY.R
3_Model_training_BrandywinePA.R
4_Model_training_MechumsVA.R
5_Model_training_FlatNC.R
6_Model_training_NorthForkSC.R
7_Model_training_IchawayGA.R


8_Other_statistics.R
= script for the other statistical tests done to describe the data



FOLDER/S:

1. data
= contains the .csv files of the model predictions and residuals

