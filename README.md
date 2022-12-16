### Repository for CEE 609: Environmental Data Science project, Fall 2022

This project was created using [R programming language](https://www.r-project.org/).

All scripts are provided with instructions on which packages and libraries are necessary to be downloaded and used. These are also listed in the R_packages_libraries.txt file.

**Important warning:** do not clear the environment in R as each subsequent script relies on the dataframes produced in the previous script.


### Contents (Folders):

1. **Data_download_and_preprocess_code**: R scripts for downloading data; shapefiles of watershed boundaries and .csv files of the output dataframes of the predictand and predictors for each watershed
2. **Model_train_and_validate_code**: R script and data for formulating, fitting, and testing models for predicting evapotranspiration; .csv files of the model predictions for each watershed
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

_**Table 1.** Selected watersheds that represent areas from north to south of US' eastern region_

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

![Data_Methods2](https://user-images.githubusercontent.com/95758941/207957835-3d0b4660-fedd-4046-8d24-31f1ef72f52c.png)
_**Figure 2.** Methodological framework of the study. Important R packages used are in the orange rectangles._

# Results

![predictors](https://user-images.githubusercontent.com/95758941/208009974-56da6ee2-ea50-4b7d-8b01-82d5220e4467.png)
_**Figure .** Annual total precipitation, total potential evapotranspiration, total soil moisture, average monthly maximum temperature, and maximum NDVI from water years 1990-2020_

&nbsp;

![annual_WB_ET](https://user-images.githubusercontent.com/95758941/208010232-923119f8-486d-4c04-92d2-fc6dbc3f5e74.png)
_**Figure .** Annual evapotranspiration from water years 1990-2020 computed using water balance method_


&nbsp;

![ET_comparison](https://user-images.githubusercontent.com/95758941/208010476-4a8f8888-03da-452a-af52-ef0ed332883a.png)
_**Figure .** Comparison of evapotranspiration computed using water balance method and evapotranspiration from remote-sensed data_

&nbsp;


_**Table .** Predictor variables and their corresponding coefficient estimates and p-values in multiple linear regression model wherein all predictors are regressed against the water-balance evapotranspiration. Cells in light blue are the variables that are significant at alpha = 0.05_

![Screenshot 2022-12-15 at 20 50 51](https://user-images.githubusercontent.com/95758941/208003548-668b20f4-826d-4b02-b219-b1805fae8a59.png)


&nbsp;

_**Table .** Final regression model of each watershed_
![Screenshot 2022-12-15 at 20 58 29](https://user-images.githubusercontent.com/95758941/208004549-51b71f50-47ab-41a5-a239-398cfd31ab44.png)

\* Only precipitation is the significant variable

&nbsp;

![precip_AET_comparison](https://user-images.githubusercontent.com/95758941/208030702-81b7e757-d825-42cb-b3f7-fc9051ea3f3e.png)
_**Figure .** Trends in remote-sensed precipitation and water-balance evapotranspiration._

&nbsp;

![predictions](https://user-images.githubusercontent.com/95758941/208029377-ead17096-f412-49f8-816b-502226b6bce5.png)
_**Figure .** Predicted versus observed (water balance) annual evapotranspiration. Points in black are the computed water balance ET while points in color are the predicted values using the "best" regression model for each watershed._



&nbsp;

# Discussion

# Conclusion

# Moving forward

# References

# R packages

Aybar C (2022). _rgee: R Bindings for Calling the 'Earth Engine' API_. R package version 1.1.5,
  <https://CRAN.R-project.org/package=rgee>.

Chamberlain S (2021). _rnoaa: 'NOAA' Weather Data from R_. R package version 1.3.8,
  <https://CRAN.R-project.org/package=rnoaa>.

De Cicco, L.A., Hirsch, R.M., Lorenz, D., Watkins, W.D., 2022, dataRetrieval: R packages for discovering and
  retrieving water data available from Federal hydrologic web services, v.2.7.11, doi:10.5066/P9X4L3GE

Garrett Grolemund, Hadley Wickham (2011). Dates and Times Made Easy with lubridate. Journal of Statistical
  Software, 40(3), 1-25. URL https://www.jstatsoft.org/v40/i03/.

Hagemann M (2022). _streamstats: R bindings to the USGS Streamstats API_. R package version 0.0.3.

Henry L, Wickham H (2022). _purrr: Functional Programming Tools_. R package version 0.3.5,
  <https://CRAN.R-project.org/package=purrr>.
  
Fox, J. and Weisberg, S. (2019). An {R} Companion to Applied Regression, Third Edition. Thousand Oaks CA:
  Sage. URL: https://socialsciences.mcmaster.ca/jfox/Books/Companion/
  
Kassambara A (2022). _ggpubr: 'ggplot2' Based Publication Ready Plots_. R package version 0.5.0,
  <https://CRAN.R-project.org/package=ggpubr>.

Miller TLboFcbA (2020). _leaps: Regression Subset Selection_. R package version 3.1,
  <https://CRAN.R-project.org/package=leaps>.

Müller K, Wickham H (2022). _tibble: Simple Data Frames_. R package version 3.1.8,
  <https://CRAN.R-project.org/package=tibble>.
  
Pebesma, E., 2018. Simple Features for R: Standardized Support for Spatial Vector Data. The R Journal 10 (1),
  439-446, https://doi.org/10.32614/RJ-2018-009

R Core Team (2022). R: A language and environment for statistical computing. R Foundation for Statistical
  Computing, Vienna, Austria. URL https://www.R-project.org/.

Spinu V (2022). _timechange: Efficient Manipulation of Date-Times_. R package version 0.1.1,
  <https://CRAN.R-project.org/package=timechange>.
  
Venables, W. N. & Ripley, B. D. (2002) Modern Applied Statistics with S. Fourth Edition. Springer, New York.
  ISBN 0-387-95457-0

Wickham H, François R, Henry L, Müller K (2022). _dplyr: A Grammar of Data Manipulation_. R package version
  1.0.10, <https://CRAN.R-project.org/package=dplyr>.

Wickham H (2022). _forcats: Tools for Working with Categorical Variables (Factors)_. R package version 0.5.2,
  <https://CRAN.R-project.org/package=forcats>.

Wickham H. ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York, 2016.

Wickham H, Hester J, Bryan J (2022). _readr: Read Rectangular Text Data_. R package version 2.1.3,
  <https://CRAN.R-project.org/package=readr>.

Wickham H (2022). _stringr: Simple, Consistent Wrappers for Common String Operations_. R package version 1.4.1,
  <https://CRAN.R-project.org/package=stringr>.
  
Wickham H, Girlich M (2022). _tidyr: Tidy Messy Data_. R package version 1.2.1,
  <https://CRAN.R-project.org/package=tidyr>.
  
