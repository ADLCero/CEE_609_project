
# MODEL TRAINING AND VALIDATION: Brandywine Creek, PA

################################################################################

# Since data has been imported to .csv files, data from previous scripts can now be cleared
# from the environment
rm(list = ls())

# The corresponding packages of the required libraries below may need to be 
# downloaded first using the install.packages("package") command or 
# by going to R Studio's Menu > Tools > Install packages

# R will also prompt which packages need to be installed upon opening this script

# LIBRARIES:

library(car)      # for vif() function that will compute for the VIF of the model and check for multicollinearity
library(leaps)    # for performing subset regression
library(MASS)     # for performing stepwise regression

################################################################################

# Brandywine Creek, PA 

# Read in data

data <- read.csv("/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/BrandywinePA_data.csv", header = T)

# Make a new data frame that includes only the following variables as predictors:
# 1) RS_annual_total_precip = remote-sensed precipitation data (mm), total for the water year, from TerraClimate
# 2) RS_annual_total_pet = remote-sensed PET, total for the water year, from TerraClimate
# 3) RS_annual_total_soil_moisture = remote-sensed soil moisture (mm), total for the water year, from TerraClimate
# 4) RS_ave_monthly_tmax = maximum temperature (degC), monthly average, from TerraClimate
# 5) RS_ave_NDVI = average NDVI per water year, from LANDSAT and MODIS
# 6) RS_max_NDVI = maximum NDVI per water year, from LANDSAT and MODIS

# Multiply PET, soil moisture, and tmax by 0.1 since scale = 0.1, 
# according to https://developers.google.com/earth-engine/datasets/catalog/IDAHO_EPSCOR_TERRACLIMATE#bands

# NDVI values are already in properly scaled


BrandywinePA_data2 <- data.frame(data$water_year,
                    data$WB_annual_total_aet,
                    data$RS_annual_total_precip,
                    (data$RS_annual_total_pet * 0.1),
                    (data$RS_annual_total_soil_moisture * 0.1),
                    (data$RS_ave_monthly_tmax * 0.1),
                    data$RS_max_NDVI)

# Rename columns

colnames(BrandywinePA_data2) <- c("water_year",
                              "WB_annual_total_aet",
                              "RS_annual_total_precip",
                              "RS_annual_total_pet",
                              "RS_annual_total_soil_moisture",
                              "RS_ave_monthly_tmax",
                              "RS_max_NDVI")


# Subset the data frame such that only water years 1990-2014 will be used for model training
# and water years 2015-2020 will be used for model testing

BrandywinePA_train <- BrandywinePA_data2[BrandywinePA_data2$water_year <= 2013, ]
BrandywinePA_test <- BrandywinePA_data2[BrandywinePA_data2$water_year >= 2014, ]


# Remove data in training set with negative AET

BrandywinePA_train <- BrandywinePA_train[BrandywinePA_train$WB_annual_total_aet > 0, ]


# Calculate the correlations between the y and the potential x variables

BrandywinePA_cor <- data.frame(cor(BrandywinePA_train[ , 2:7]))
plot(BrandywinePA_train[ , 2:7])

# There seems to be multicollinearity between PET and monthly maximum temperature
# To check:
cor(BrandywinePA_train$RS_annual_total_pet, BrandywinePA_train$RS_ave_monthly_tmax)

# Correlation is at 0.9230162 which is very high and confirms collinearity in these predictor variables


#------------------------------------------------------------------------------#

# Make model with all variables included

BrandywinePA_m1 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                    RS_annual_total_pet +
                    RS_annual_total_soil_moisture +
                    RS_ave_monthly_tmax +
                    RS_max_NDVI,
                  data = BrandywinePA_train)

# Get summary of the model
summary(BrandywinePA_m1)

# Check multicollinearity
vif(BrandywinePA_m1)   # VIF > 5 for PET and tmax which confirms that they are highly correlated


# Make a model with only one variable included (this will be necessary for the stepAIC later)
# Based on the correlation data, precipitation is the "most" correlated with AET

BrandywinePA_m2 <- lm(WB_annual_total_aet ~ RS_annual_total_precip, data = BrandywinePA_train)

# Get summary of the model
summary(BrandywinePA_m2)

#------------------------------------------------------------------------------#

# DEALING WITH MULTICOLLINEARITY: which variable to omit

# Since PET and precipitation are highly correlated, one of them has to be removed to prevent coming
# up with a model with inflated variance

# Based on the p-values of the coefficients in the regression model, tmax has a lower
# p-value than PET

# Based on correlation matrix with all predictors, tmax has a slightly higher correlation with
# water balance AET than PET

# Based on the VIF of the model, PET has a slightly VIF than tmax

# With all these, PET has to be removed

# Make model without PET

BrandywinePA_m3 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                    RS_annual_total_soil_moisture +
                    RS_ave_monthly_tmax +
                    RS_max_NDVI,
                  data = BrandywinePA_train)

# Get summary of the model
summary(BrandywinePA_m3)

# Check multicollinearity
vif(BrandywinePA_m3)   # no more VIF > 5


#------------------------------------------------------------------------------#

# Perform best subset regression

# 1) Maximize the adjusted R2

BrandywinePA_leaps <- leaps(BrandywinePA_train[ ,3:7], BrandywinePA_train$WB_annual_total_aet, 
      method = "adjr2",
      names = names(BrandywinePA_train[ ,3:7]),
      nbest = 1)

BrandywinePA_leaps

# Note:
# method = adjr2 = sets the condition to look only at the adjusted R2
# nbest = how many best models per number of variables; when set as 1, the results will show
# which variable/s is/are best to be included in the model depending on how many variables
# the user wants to include

# RESULTS:
# See where "TRUE" occurs; this means that this is/are the variable/s that will be best included in the model

# if 1 variable only = RS_annual_total_precip
# Adjusted R2 = 0.1030110

# if 2 variables = RS_annual_total_precip + RS_max_NDVI
# Adjusted R2 = 0.3045540

# if 3 variables = RS_annual_total_precip + RS_ave_monthly_tmax + RS_max_NDVI
# Adjusted R2 = 0.2910950

# if 4 variables = RS_annual_total_precip + RS_annual_total_pet + RS_ave_monthly_tmax + RS_max_NDVI
# Adjusted R2 = 0.2751270

# if all 5 variables
# Adjusted R2 = 0.2353143

# Highest adjusted R2 so far is for the model that contains two variables.

BrandywinePA_m4 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                       RS_max_NDVI, 
                     data = BrandywinePA_train)

summary(BrandywinePA_m4)

#------------------------------------------------------------------------------#

# Perform stepwise regression using an F test
# using dropterm = going backwards, starting with all variables

dropterm(BrandywinePA_m1, test = "F", sorted = TRUE)  # m1 is the model that contains all the variables

# RESULTS:
# p-values: if greater than 0.05, the variable/s should not have been added to the model

# Variables that are significant = precipitation and NDVI = consistent with previous results

#------------------------------------------------------------------------------#

# Perform stepwise regression using AIC

stepAIC(BrandywinePA_m2,
        scope = list(upper = BrandywinePA_m1, lower = ~1),
        direction = "both",
        trace = TRUE)


# RESULTS:
# Lowest AIC is 236.13 for the model containing RS_annual_total_precip + RS_max_NDVI
# Results are consistent so far that these are the two "best" predictors


#------------------------------------------------------------------------------#

# Check AIC
AIC(BrandywinePA_m1)
AIC(BrandywinePA_m2)
AIC(BrandywinePA_m3)
AIC(BrandywinePA_m4)

# Countercheck with BIC
# Bigger penalty for more complexity

BIC(BrandywinePA_m1)
BIC(BrandywinePA_m2)
BIC(BrandywinePA_m3)
BIC(BrandywinePA_m4)

# RESULTS: the model with the lowest AIC and BIC is BrandywinePA_m4. 

# At this point, it is the "best" model.

#------------------------------------------------------------------------------#

# CHECK OLS ASSUMPTIONS for the "best" model:

# 1. Linear relationship between dependent and independent variables
# 2. Variance of the residuals is constant
# 3. Residuals are normally distributed

# Plots of predictions and residuals

res <- residuals(BrandywinePA_m4)
res

pred <- predict(BrandywinePA_m4)
pred

par(mfrow = c(2,2))

# Observed values vs predicted values

plot(pred ~ BrandywinePA_train$WB_annual_total_aet)
abline(0, 1)

# Model residuals vs predicted values

plot(res ~ pred)
lines(lowess(pred, res))

# Model residuals vs independent variables

plot(res ~ BrandywinePA_train$RS_annual_total_precip)
lines(lowess(BrandywinePA_train$RS_annual_total_precip, res))

plot(res ~ BrandywinePA_train$RS_max_NDVI)
lines(lowess(BrandywinePA_train$RS_max_NDVI, res))

# Are residuals normally distributed:
# Probability plot correlation test for normal distribution

r <- cor(res, qnorm((rank(res)-(3/8))/(length(res)+(1/4))))
r

# r alpha = 0.05 at N = 24 is between 0.9503 and 0.9639
# H0 = residuals are normally distributed; Ha = residuals are not normally distributed
# r = 0.9814148 is greater than both values, therefore, fail to reject H0, residuals are normally distributed

# Shapiro Wilk test
shapiro.test(res)

# p-value is > 0.05, fail to reject Ho. Residuals are normally distributed.


# Check autocorrelation function of residuals

acf(res) # all lines are within the threshold lines

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 1990-2013

# Get coefficients

coef <- coef(BrandywinePA_m4)
coef

pred_BrandywinePA_aet <- (coef[1] + (coef[2] * BrandywinePA_train$RS_annual_total_precip) +
                        (coef[3] * BrandywinePA_train$RS_max_NDVI))
pred_BrandywinePA_aet

# Compare predicted values vs training data

pred_BrandywinePA_aet
BrandywinePA_train$WB_annual_total_aet

# Check averages and standard deviation

mean(pred_BrandywinePA_aet)
mean(BrandywinePA_train$WB_annual_total_aet)

sd(pred_BrandywinePA_aet)
sd(BrandywinePA_train$WB_annual_total_aet)

# Check residuals, where residuals = predicted - fitted

residuals <- pred_BrandywinePA_aet - BrandywinePA_train$WB_annual_total_aet
residuals
hist(residuals)

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 2014-2020 (testing data set)

pred_BrandywinePA_aet2 <- (coef[1] + (coef[2] * BrandywinePA_test$RS_annual_total_precip) +
                            (coef[3] * BrandywinePA_test$RS_max_NDVI))

pred_BrandywinePA_aet2

# Compare predicted values vs testing data

pred_BrandywinePA_aet2
BrandywinePA_test$WB_annual_total_aet   # has negative values, so not really appropriate to compare

# Check averages and standard deviation

mean(pred_BrandywinePA_aet2)
mean(BrandywinePA_test$WB_annual_total_aet)
sd(pred_BrandywinePA_aet2)
sd(BrandywinePA_test$WB_annual_total_aet)

# There are negative values in the testing data so it is not really appropriate to compare

residuals2 <- pred_BrandywinePA_aet2 - BrandywinePA_test$WB_annual_total_aet
residuals2
hist(residuals2)

shapiro.test(residuals2)

# Residuals are mostly negative, indicating that the model is underpredicting AET
# Shapiro-Wilk test indicates that residuals are normally distributed
