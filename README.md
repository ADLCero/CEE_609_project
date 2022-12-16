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

_**Figure 1.** Conceptual framework of the study_



### Research Questions:

1. How does the annual actual evapotranspiration (ET) calculated using the water balance approach compare to remotely-sensed evapotranspiration?
2. What are the trends in ET that are revealed by these data sets?
3. Is ET dependent on the following potential controls: 
    - precipitation;
    - atmospheric demand and energy availability (quantified through potential evapotranspiration (PET));
    - soil moisture;
    - average monthly maximum temperature;
    - vegetation activity (Normalized Difference Vegetation Index (NDVI))?


# Data and methods

To represent different regions in the eastern side of the continental US, the following watersheds were selected for this project:

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

For each variable, 31 water years (1990-2020) of data were obtained. A water year is defined as the 12-month period from October 1st to September 30th of the following year (ex. October 1, 2021 to September 30, 2022 belongs to water year 2022). This is mostly used in the analysis of hydrological data to take into account that fall season is consistently the driest period and when interannual variations in storage will be the smallest. Table 2 and Figure 2 summarizes the different data that were used in this project and the corresponding R package that were used to access and download them.

### Water-balance evapotranspiration

#### _Discharge_

Records of discharge from the United States Geological Survey (USGS) gauge site of each watershed were downloaded using the `dataRetrieval` package in R, which was created to retrieve hydrologic data from the USGS and Water Quality Portal (WQP) and load into R. With the aid of the `tidyverse` package, data were transformed, converted to appropriate units, and summarized per water year. The data were normalized by drainage area and expressed as basin runoff (mm).

#### _Precipitation_

Records of precipitation that will represent each watershed were downloaded using the `rnoaa` package in R, an interface to many of the National Oceanic and Atmospheric Administration (NOAA) data sources. For each of the watershed, the closest monitoring station with complete data from 1989-10-01 to 2020-09-30 was selected. Similar to the discharge data, data were transformed, converted to appropriate scale, and summarized per water year with the aid of the `tidyverse` package.

#### _Computation of water-balance ET_

Given the discharge data expressed as basin runoff (mm) and the precipitation data (mm), water-balance evapotranspiration was computed by simply subtracting the annual total runoff from the annual total precipitation per water year.

### Watershed boundaries

In order to filter the boundaries for the remote-sensed data that would be downloaded via Google Earth Engine, the shapefile of the boundaries of each watershed were downloaded using the `streamstats` package in R. 

### Remote-sensed predictors: ET, PET, soil moisture, monthly maximum temperature

For these remote-sensed predictors, the `rgee` package was used to access their data from Google Earth Engine using the R interface. These were all retrieved from TerraClimate: Monthly Climate and Climatic Water Balance for Global Terrestrial Surfaces, University of Idaho (Abatzoglou et al., 2018). TerraClimate provides monthly data on climatic water balance for global terrestrial surfaces at a resolution of 4638.3 meters. The data set has 14 bands corresponding to different meteorological parameters.

### Remote-sensed predictors: Normalized Difference Vegetation Index (NDVI)

For the NDVI, two sources were used: data that covers 1989-10-01 to 2000-09-30 were obtained from Landsat 5 TM Collection 1 Tier 1 8-Day NDVI Composite (courtesy of the U.S. Geological Survey) while data that covers 2020-10-01 to 2020-09-30 were obained from MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km. Both image collections have a band corresponding to the NDVI which were extracted using the `rgee` package in R.

For all the remote-sensed data, the `tidyverse` package was used to transform them and make necessary scaling prior to summarizing them per water year. A final data frame for each watershed consisting the predictand and predictors were created and exported as .csv files.

&nbsp;

_**Table 2.** Sources of other data used in this project and the corresponding R package available to download them_

| Data  | Source/Description | R package |URL |
| ------------- | ------------- | ------------- |------------- |
| discharge | United States Geological Survey (USGS)| dataRetrieval  | https://cran.r-project.org/web/packages/dataRetrieval/vignettes/dataRetrieval.html |
| precipitation (gauge) | National Oceanic and Atmospheric Administration (NOAA)| rnoaa  | https://cran.r-project.org/web/packages/rnoaa/index.html|
| watershed boundary | United States Geological Survey (USGS)| streamstats  | https://github.com/markwh/streamstats |
| evapotranspiration | TerraClimate: Monthly Climate and Climatic Water Balance for Global Terrestrial Surfaces, University of Idaho |   | https://developers.google.com/earth-engine/datasets/catalog/IDAHO_EPSCOR_TERRACLIMATE |
| potential evapotranspiration, precipitation (gridded), soil moisture, monthly maximum temperature  |^ | rgee  | https://github.com/r-spatial/rgee |
| NDVI  | Landsat 5 TM Collection 1 Tier 1 8-Day NDVI Composite |^| https://developers.google.com/earth-engine/datasets/catalog/LANDSAT_LT05_C01_T1_8DAY_NDVI#description |
|^  | MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km |^|https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD13A2#description |


&nbsp;

## Model training and validation

Following the process of supervised learning (VanderPlas, 2016) and to evaluate the roles of the potential controls on evapotranspiration, a multiple linear regression relationship was fit between these predictors and the annual water balance ET for each site:

![Screenshot 2022-12-16 at 05 51 55](https://user-images.githubusercontent.com/95758941/208082759-e5e6be73-5e06-4b40-ae52-81ce10bd0c6c.png)

where Y is the dependent variable (water-balance ET); β<sub>0</sub> is the intercept; β<sub>i</sub> is the slope of the X<sub>i</sub> independent variables; and ϵ is the model's error term. 


The final dataframe containing 31 water years of the water-balance ET and the predictors were divided into training and validation data set (1990-2013, 25 years) for fitting the model and 20% of the data (2014-2020, 7 years) were separated and not processed for use in testing and evaluation of the model fit. 


Prior to making the regression models, the data set were inspected for multicollinearity by making a correlation plot and checking the corrrelation between predictors. A threshold of | > 0.7 | was used to determine if variables have high correlation or not. Regression models were created using the `lm()` function from the `stats` package in R. Initially, a model with all the predictor variables and a model with single predictor variable (precipitation, based on its consistent good linear relationship with the water balance ET) were made. The `vif()` function from the `car` package was used to check for the Variance Inflation Factor (VIF) of the model's parameters in order to detect multicollinearity. 

To check model performance, the adjusted R<sup>2</sup> and p-values of the model and each variable in it were considered. Subset regression using `leaps`, which identifies the best combination of variables that will give the highest adjusted R<sup>2</sup>, was used to create models. To further aid in identifying the "best" model,  stepwise regression using an F test using `MASS` and `stepAIC` were also done. The AIC and BIC of each model were also assessed. In the end, the goal was to select a model that gives the highest adjusted R<sup>2</sup> with, as much as possible, all variables significant at alpha = 0.05 level. 

The selected "best" model was also checked for violations of ordinary least squares assumptions by inspecting plots of predictions versus residuals, observed values versus predicted values, and model residuals and predicted values. The model's residuals were also tested for normality using probability plot correlation test statistic (also known as Ryan Joiner test for normality) and Shapiro-Wilk test for normality using the `shapiro.test()` from the base `stats` package in R. Autocorrelation among the residuals were also checked using the `acf()` function. After confirming that the selected model's residuals are normal, this was used to predict for the ET using the training data set and the testing data set.


## Other statistical analysis

In order to compare the water balance ET and remote-sensed ET, normality and equality of variances of the data were checked first using `shapiro.test()` and `var.test()` functions, respectively. An independent samples test was then done using `t.test()` to determine if the means of the two data sets are significantly different.


&nbsp;

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

Carter, E., Hain, C., Anderson, M., & Steinschneider, S. (2018). A Water Balance–Based, Spatiotemporal Evaluation of Terrestrial Evapotranspiration Products across the Contiguous United States. Journal of Hydrometeorology, 19(5), 891–905. https://doi.org/10.1175/JHM-D-17-0186.1

VanderPlas, J. (2016, November). What Is Machine Learning? | Python Data Science Handbook. https://jakevdp.github.io/PythonDataScienceHandbook/05.01-what-is-machine-learning.html


# Data sources

Abatzoglou, J.T., S.Z. Dobrowski, S.A. Parks, K.C. Hegewisch, 2018, Terraclimate, a high-resolution global dataset of monthly climate and climatic water balance from 1958-2015, Scientific Data 5:170191, doi:10.1038/sdata.2017.191

MOD13A2 v061. https://doi.org/10.5067/MODIS/MOD13A2.061

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
  
