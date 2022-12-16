
# MODEL TRAINING AND VALIDATION: North Fork Edisto, South Carolina

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

# North Fork Edisto, SC

# Read in data

data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/NorthForkSC_data.csv", header = T)

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


NorthForkSC_data2 <- data.frame(data$water_year,
                    data$WB_annual_total_aet,
                    data$RS_annual_total_precip,
                    (data$RS_annual_total_pet * 0.1),
                    (data$RS_annual_total_soil_moisture * 0.1),
                    (data$RS_ave_monthly_tmax * 0.1),
                    data$RS_max_NDVI)

# Rename columns

colnames(NorthForkSC_data2) <- c("water_year",
                              "WB_annual_total_aet",
                              "RS_annual_total_precip",
                              "RS_annual_total_pet",
                              "RS_annual_total_soil_moisture",
                              "RS_ave_monthly_tmax",
                              "RS_max_NDVI")


# Subset the data frame such that only water years 1990-2014 will be used for model training
# and water years 2015-2020 will be used for model testing

NorthForkSC_train <- NorthForkSC_data2[NorthForkSC_data2$water_year <= 2013, ]
NorthForkSC_test <- NorthForkSC_data2[NorthForkSC_data2$water_year >= 2014, ]


# Remove data in training set with negative AET

NorthForkSC_train <- NorthForkSC_train[NorthForkSC_train$WB_annual_total_aet > 0, ]


# Calculate the correlations between the y and the potential x variables

NorthForkSC_cor <- data.frame(cor(NorthForkSC_train[ , 2:7]))
plot(NorthForkSC_train[ , 2:7])

# There seems to be multicollinearity between PET and monthly maximum temperature
# To check:
cor(NorthForkSC_train$RS_annual_total_pet, NorthForkSC_train$RS_ave_monthly_tmax)

# Correlation is at 0.8014721 which is high 


#------------------------------------------------------------------------------#

# Make model with all variables included

NorthForkSC_m1 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                    RS_annual_total_pet +
                    RS_annual_total_soil_moisture +
                    RS_ave_monthly_tmax +
                    RS_max_NDVI,
                  data = NorthForkSC_train)

# Get summary of the model
summary(NorthForkSC_m1)

# Check multicollinearity
vif(NorthForkSC_m1)   # no VIF > 5


# Make a model with only one variable included (this will be necessary for the stepAIC later)
# Based on the correlation data, precipitation is the "most" correlated with AET

NorthForkSC_m2 <- lm(WB_annual_total_aet ~ RS_annual_total_precip, data = NorthForkSC_train)

# Get summary of the model
summary(NorthForkSC_m2)

#------------------------------------------------------------------------------#

# DEALING WITH MULTICOLLINEARITY: which variable to omit

# Since PET and tmax are highly correlated, one of them has to be removed to prevent coming
# up with a model with inflated variance

# Based on the p-values of the coefficients in the regression model, PET has a lower
# p-value than tmax and is significant, indicating its importance to be included

# Based on correlation matrix with all predictors, PET has a higher correlation with
# water balance AET than tmax

# Based on the VIF of the model, nothing is highly concerning

# With all these, tmax seems to be the one to be removed

# Try making a model without tmax

NorthForkSC_m3 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_pet +
                    RS_annual_total_soil_moisture +
                    RS_max_NDVI,
                  data = NorthForkSC_train)

# Get summary of the model
summary(NorthForkSC_m3)

# Check multicollinearity
vif(NorthForkSC_m3)  


#------------------------------------------------------------------------------#

# Perform best subset regression

# 1) Maximize the adjusted R2

NorthForkSC_leaps <- leaps(NorthForkSC_train[ ,3:7], NorthForkSC_train$WB_annual_total_aet, 
      method = "adjr2",
      names = names(NorthForkSC_train[ ,3:7]),
      nbest = 1)

NorthForkSC_leaps

# Note:
# method = adjr2 = sets the condition to look only at the adjusted R2
# nbest = how many best models per number of variables; when set as 1, the results will show
# which variable/s is/are best to be included in the model depending on how many variables
# the user wants to include

# RESULTS:
# See where "TRUE" occurs; this means that this is/are the variable/s that will be best included in the model

# if 1 variable only = RS_annual_total_precip
# Adjusted R2 = 0.6691108

# if 2 variables = RS_annual_total_precip + RS_annual_total_soil_moisture
# Adjusted R2 = 0.7694740

# if 3 variables = RS_annual_total_precip + RS_annual_total_soil_moisture + RS_max_NDVI
# Adjusted R2 = 0.7830231

# if 4 variables = all except RS_ave_monthly_tmax
# Adjusted R2 = 0.7939582

# if all 5 variables
# Adjusted R2 = 0.7992850


# Results suggest that it is correct to eliminate tmax
# Highest adjusted R2 so far is for the model that contains all variables
# But then PET and tmax are highly collinear, so it will be better if one of them is not in the model

# Review: 

summary(NorthForkSC_m3)

# PET is not significant in this model

# Try the model with three variables (without PET and tmax), since it has the next highest adjusted R2

NorthForkSC_m4 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                  RS_annual_total_soil_moisture +
                    RS_max_NDVI,
                data = NorthForkSC_train)

summary(NorthForkSC_m4)

# Adjust R2 decreased slightly and total soil moisture is not a significant variable

# Try the model with two variables only

NorthForkSC_m5 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                       RS_max_NDVI,
                     data = NorthForkSC_train)

summary(NorthForkSC_m5)

# Good adjusted R2 although lower than the others; all variables are also significant

#------------------------------------------------------------------------------#

# Perform stepwise regression using an F test
# using dropterm = going backwards, starting with all variables

dropterm(NorthForkSC_m1, test = "F", sorted = TRUE)  # m1 is the model that contains all the variables

# RESULTS:
# p-values: if greater than 0.05, the variable/s should not have been added to the model

# The only variables that are significant at alpha = 0.05 are NDVI and precipitation,
# suggesting that the model with these two is the "best"

#------------------------------------------------------------------------------#

# Perform stepwise regression using AIC

stepAIC(NorthForkSC_m2,
        scope = list(upper = NorthForkSC_m1, lower = ~1),
        direction = "both",
        trace = TRUE)


# RESULTS:
# Lowest AIC is 232.23 for the model containing precipitation precipitation, NDVI, soil moisture, and PET


#------------------------------------------------------------------------------#

# Check AIC
AIC(NorthForkSC_m1)
AIC(NorthForkSC_m2)
AIC(NorthForkSC_m3)
AIC(NorthForkSC_m4)
AIC(NorthForkSC_m5)

# Countercheck with BIC
# Bigger penalty for more complexity

BIC(NorthForkSC_m1)
BIC(NorthForkSC_m2)
BIC(NorthForkSC_m3)
BIC(NorthForkSC_m4)
BIC(NorthForkSC_m5)

# RESULTS: the model with the lowest AIC and BIC is NorthForkSC_m3, which is the model with four variables
# But then again, these has variables that are not significant

# At this point, it is the "best" model is either this or the one with two variables

# Review models:
summary(NorthForkSC_m3)
summary(NorthForkSC_m5)

# p-values of both models are good. Adjusted R2 is higher in the model with four variables,
# but the model with only two variables is the one with all predictors significant.
# This will be the "best" model that will be considered.

#------------------------------------------------------------------------------#

# CHECK OLS ASSUMPTIONS for the "best" model:

# 1. Linear relationship between dependent and independent variables
# 2. Variance of the residuals is constant
# 3. Residuals are normally distributed

# Plots of predictions and residuals

res <- residuals(NorthForkSC_m5)
res

pred <- predict(NorthForkSC_m5)
pred

par(mfrow = c(2,2))

# Observed values vs predicted values

plot(pred ~ NorthForkSC_train$WB_annual_total_aet)
abline(0, 1)

# Model residuals vs predicted values

plot(res ~ pred)
lines(lowess(pred, res))

# Model residuals vs independent variables

plot(res ~ NorthForkSC_train$RS_annual_total_precip)
lines(lowess(NorthForkSC_train$RS_annual_total_precip, res))

plot(res ~ NorthForkSC_train$RS_max_NDVI)
lines(lowess(NorthForkSC_train$RS_max_NDVI, res))

# Are residuals normally distributed:
# Probability plot correlation test for normal distribution

r <- cor(res, qnorm((rank(res)-(3/8))/(length(res)+(1/4))))
r

# r alpha = 0.05 at N = 24 is between 0.9503 and 0.9639
# H0 = residuals are normally distributed; Ha = residuals are not normally distributed
# r = 0.9777031 is greater than both values, therefore, fail to reject H0, residuals are normally distributed

# Shapiro Wilk test
shapiro.test(res)

# p-value is > 0.05, fail to reject Ho. Residuals are normally distributed.


# Check autocorrelation function of residuals

acf(res) # all lines are within the threshold lines except for one (but is not overly out of the threshold)

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 1990-2013

# Get coefficients

coef <- coef(NorthForkSC_m5)
coef

pred_NorthForkSC_aet <- (coef[1] + (coef[2] * NorthForkSC_train$RS_annual_total_precip) +
                      (coef[3] * NorthForkSC_train$RS_max_NDVI))
pred_NorthForkSC_aet

# Compare predicted values vs training data

pred_NorthForkSC_aet
NorthForkSC_train$WB_annual_total_aet

# Check averages and standard deviation

mean(pred_NorthForkSC_aet)
mean(NorthForkSC_train$WB_annual_total_aet)

sd(pred_NorthForkSC_aet)
sd(NorthForkSC_train$WB_annual_total_aet)

# Check residuals, where residuals = predicted - fitted

residuals <- pred_NorthForkSC_aet - NorthForkSC_train$WB_annual_total_aet
residuals
hist(residuals)

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 2014-2020 (testing data set)

pred_NorthForkSC_aet2 <- (coef[1] + (coef[2] * NorthForkSC_test$RS_annual_total_precip) +
                           (coef[3] * NorthForkSC_test$RS_max_NDVI))

pred_NorthForkSC_aet2

# Compare predicted values vs testing data

pred_NorthForkSC_aet2
NorthForkSC_test$WB_annual_total_aet   

# Check averages and standard deviation

mean(pred_NorthForkSC_aet2)
mean(NorthForkSC_test$WB_annual_total_aet)
sd(pred_NorthForkSC_aet2)
sd(NorthForkSC_test$WB_annual_total_aet)


residuals2 <- pred_NorthForkSC_aet2 - NorthForkSC_test$WB_annual_total_aet
residuals2
hist(residuals2)

shapiro.test(residuals2)

# Shapiro-Wilk test indicates that residuals are normally distributed

#------------------------------------------------------------------------------#

# FILE OUTPUT:

NorthForkSC_pred <- data.frame(water_year = NorthForkSC_train$water_year,
                          obs_wbet = NorthForkSC_train$WB_annual_total_aet,
                          pred_wbet = pred_NorthForkSC_aet,
                          residuals = residuals(NorthForkSC_m5))

write.csv(NorthForkSC_pred, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/NorthForkSC_pred.csv",
          row.names = FALSE)

