
MODEL TRAINING AND VALIDATION CODE

0_Important_changes.txt
= important changes on the methods for this section of the project

0_README.txt
= instructions

1_Model_training.R
= script for formulating the regression model for actual evapotranspiration, with the water balance ET as the predictand and precipitation, PET, soil moisture, maximum temperature, and (NDVI) as the predictors

(Note: As of November 27, 2022, I'm still having troubles getting NDVI through rgee package in R and completing values for 1990-2020. Routine is for a single watershed only for now, as NDVI will have to be added in the model as a predictand. However, it is expected that the same approach/ sequence will be used for all the watersheds.)


FOLDER/S:

1. data
= contains the .csv files of the predictand and predictors for each of the seven watersheds; this will allow the user to proceed to model training and validation without running the prior scripts under data download and pre-process code

