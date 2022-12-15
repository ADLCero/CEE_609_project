### Repository for CEE 609: Environmental Data Science project, Fall 2022

This project was created using [R programming language](https://www.r-project.org/).

All scripts are provided with instructions on which packages and libraries are necessary to be downloaded and used. These are also listed in the R_packages_libraries.txt file.

**Important warning:** do not clear the environment in R as each subsequent script relies on the dataframes produced in the previous script.


### Contents (Folders):

1. **Data_download_and_preprocess_code**: R scripts for downloading data; shapefiles of watershed boundaries
2. **Model_train_and_validate_code**: R script and data for formulating, fitting, and testing models for predicting evapotranspiration; dataframes (in .csv file) of predictand and predictors
3. **Figures_and_figure_code**: markdown file showing the process of creating figures of the data and results; graphical representations of results

Each folder has their corresponding "data" folder where the outputs are stored. Each also has a readme.txt file for the instructions on how to run the scripts. Scripts are arranged and have to be run according to their sequence.

&nbsp;

# Analysis of potential controls on evapotranspiration across watersheds in eastern US

# Introduction

![Intro](https://user-images.githubusercontent.com/95758941/207928238-02a77db6-31ab-4d58-8436-7121d1437a2a.png)

_**Figure 1.** Framework of the study_


## Research Questions:

1. How does the annual actual evapotranspiration (ET) calculated using the water balance approach compare to remotely-sensed evapotranspiration?
2. What are the trends in ET that are revealed by these data sets?
3. Is ET dependent on the following potential controls: 
    - precipitation;
    - atmospheric demand and energy availability (quantified through PET);
    - soil moisture;
    - average monthly maximum temperature;
    - vegetation activity (NDVI)?


# Data and methods

**Table 1.** Selected watersheds that represent areas from north to south of US' eastern region

| Watershed  | USGS Site Number | Drainage area (km<sup>2</sup>) |
| ------------- | ------------- | ------------- |
| Oyster River, New Hampshire  | 01073000  | 31.39  |
| Wappinger Creek, New York  | 01372500  | 468.79  |
| Brandywine Creek, Pennsylvania  | 01481000  |  743.33  |
| Mechums River, Virginia  | 02031000  |  246.83  |
| Flat River, North Carolina  | 02085500  |  385.91  |
| North Fork Edisto, South Carolina  | 02173500  |  1768.96  |
| Ichawaynochaway, Georgia  | 02353500  |  1605.79  |

## Data download and pre-processing

For each variable, 31 water years (1990-2020) of data were obtained. A water year is defined as the 12-month period from October 1st to September 30th of the following year (ex. October 1, 2021 to September 30, 2022 belongs to water year 2022). This is mostly used in the analysis of hydrological data to take into account that fall season is consistently the driest period and when interannual variations in storage will be the smallest. 

## Model training and validation

The final dataframe containing 31 water years of the water-balance ET and the predictors were divided into training and validation data set (1990-2013, 25 years) for fitting the model and 20% of the data (2014-2020, 7 years) were separated and not processed for use in testing and evaluation of the model fit.

![Data_Methods](https://user-images.githubusercontent.com/95758941/207945922-fae54e3a-9391-4032-8915-c5e35e07635d.png)

_**Figure 2.** Methodological framework of the study. Important R packages used are in the orange rectangles._

# Results

# Discussion

# Conclusion

# Moving forward

# References

# R packages
