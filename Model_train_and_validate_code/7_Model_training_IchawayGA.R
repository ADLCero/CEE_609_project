
# MODEL TRAINING AND VALIDATION: Ichawaynochaway, Georgia

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

# Ichawaynochaway, GA

# Read in data

data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/IchawayGA_data.csv", header = T)

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


IchawayGA_data2 <- data.frame(data$water_year,
                    data$WB_annual_total_aet,
                    data$RS_annual_total_precip,
                    (data$RS_annual_total_pet * 0.1),
                    (data$RS_annual_total_soil_moisture * 0.1),
                    (data$RS_ave_monthly_tmax * 0.1),
                    data$RS_max_NDVI)

# Rename columns

colnames(IchawayGA_data2) <- c("water_year",
                              "WB_annual_total_aet",
                              "RS_annual_total_precip",
                              "RS_annual_total_pet",
                              "RS_annual_total_soil_moisture",
                              "RS_ave_monthly_tmax",
                              "RS_max_NDVI")


# Subset the data frame such that only water years 1990-2014 will be used for model training
# and water years 2015-2020 will be used for model testing

IchawayGA_train <- IchawayGA_data2[IchawayGA_data2$water_year <= 2013, ]
IchawayGA_test <- IchawayGA_data2[IchawayGA_data2$water_year >= 2014, ]


# Remove data in training set with negative AET

IchawayGA_train <- IchawayGA_train[IchawayGA_train$WB_annual_total_aet > 0, ]


# Calculate the correlations between the y and the potential x variables

IchawayGA_cor <- data.frame(cor(IchawayGA_train[ , 2:7]))
plot(IchawayGA_train[ , 2:7])

# There seems to be multicollinearity between PET and monthly maximum temperature
# To check:
cor(IchawayGA_train$RS_annual_total_pet, IchawayGA_train$RS_ave_monthly_tmax)
# Correlation is at 0.8425007 which is high 

# precipitation and total moisture
cor(IchawayGA_train$RS_annual_total_precip, IchawayGA_train$RS_annual_total_soil_moisture)
# Correlation is at 0.900742 which is very high

# soil moisture and PET
cor(IchawayGA_train$RS_annual_total_soil_moisture, IchawayGA_train$RS_annual_total_pet)
# Correlation is at -0.70022072 which is slightly above the 0.7 threshold

#------------------------------------------------------------------------------#

# Make model with all variables included

IchawayGA_m1 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                    RS_annual_total_pet +
                    RS_annual_total_soil_moisture +
                    RS_ave_monthly_tmax +
                    RS_max_NDVI,
                  data = IchawayGA_train)

# Get summary of the model
summary(IchawayGA_m1)

# Check multicollinearity
vif(IchawayGA_m1)   # VIF > 5 = soil moisture


# Make a model with only one variable included (this will be necessary for the stepAIC later)
# Based on the correlation data, precipitation is the "most" correlated with AET

IchawayGA_m2 <- lm(WB_annual_total_aet ~ RS_annual_total_precip, data = IchawayGA_train)

# Get summary of the model
summary(IchawayGA_m2)

#------------------------------------------------------------------------------#

# DEALING WITH MULTICOLLINEARITY: which variable/s to omit

# Since PET and tmax are highly correlated, one of them has to be removed to prevent coming
# up with a model with inflated variance

# Based on the p-values of the coefficients in the regression model, PET is more significant than tmax

# Based on correlation matrix with all predictors, PET has a higher negative correlation with
# water balance AET than tmax

# On the other hand, between precipitation and soil moisture, precipitation has a smaller p-value

# Based on the VIF of the model, soil moisture is a source of concern

# Try making a model soil moisture

IchawayGA_m3 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_pet +
                     RS_ave_monthly_tmax +   
                    RS_max_NDVI,
                  data = IchawayGA_train)

# Get summary of the model
summary(IchawayGA_m3)

# Check multicollinearity
vif(IchawayGA_m3)  

# Tmax and NDVI are significant at at 0.10 level while precipitation and PET are significant at 0.05 level

#------------------------------------------------------------------------------#

# Perform best subset regression

# 1) Maximize the adjusted R2

IchawayGA_leaps <- leaps(IchawayGA_train[ ,3:7], IchawayGA_train$WB_annual_total_aet, 
      method = "adjr2",
      names = names(IchawayGA_train[ ,3:7]),
      nbest = 1)

IchawayGA_leaps

# Note:
# method = adjr2 = sets the condition to look only at the adjusted R2
# nbest = how many best models per number of variables; when set as 1, the results will show
# which variable/s is/are best to be included in the model depending on how many variables
# the user wants to include

# RESULTS:
# See where "TRUE" occurs; this means that this is/are the variable/s that will be best included in the model

# if 1 variable only = RS_annual_total_precip
# Adjusted R2 = 0.4252415 

# if 2 variables = RS_annual_total_precip + RS_max_NDVI
# Adjusted R2 = 0.4636924

# if 3 variables = RS_annual_total_precip + RS_annual_total_pet + RS_ave_monthly_tmax
# Adjusted R2 = 0.5042694

# if 4 variables = all except soil moisture; seems to confirm that it is good to take it out of the model
# Adjusted R2 = 0.5639704

# if all 5 variables
# Adjusted R2 = 0.5506409


# Highest adjusted R2 so far is for the model that contains the four variables
# But then PET and tmax are highly collinear, so the model must not have both of them

# Try a model with three variables

# PET is not significant in this model

# Try the model with three variables (without PET and tmax), since it has the next highest adjusted R2
# However, the model with three variables should contain both PET and Tmax to yield the best adjusted R2

# Try model with two variables only

IchawayGA_m4 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_max_NDVI,
                   data = IchawayGA_train)

summary(IchawayGA_m4)

# Adjust R2 decreased although p-value is still good

#------------------------------------------------------------------------------#

# Perform stepwise regression using an F test
# using dropterm = going backwards, starting with all variables

dropterm(IchawayGA_m1, test = "F", sorted = TRUE)  # m1 is the model that contains all the variables

# RESULTS:
# p-values: if greater than 0.05, the variable/s should not have been added to the model

# The only variables that are significant at alpha = 0.05 is PET
# The variables that are significant at alpha = 0.10 are NDVI and tmax

# Try making a model with these variables

IchawayGA_m5 <- lm(WB_annual_total_aet ~ RS_annual_total_pet +
                     RS_ave_monthly_tmax +
                     RS_max_NDVI,
                   data = IchawayGA_train)

summary(IchawayGA_m5)


#------------------------------------------------------------------------------#

# Perform stepwise regression using AIC

stepAIC(IchawayGA_m2,
        scope = list(upper = IchawayGA_m1, lower = ~1),
        direction = "both",
        trace = TRUE)


# RESULTS:
# Lowest AIC is 245.04 for the model containing RS_annual_total_precip + RS_max_NDVI + 
# RS_annual_total_pet + RS_ave_monthly_tmax


#------------------------------------------------------------------------------#

# Try model with three variables
# Recall:
# if 3 variables = RS_annual_total_precip + RS_annual_total_pet + RS_ave_monthly_tmax
# Adjusted R2 = 0.5042694

IchawayGA_m6 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_pet +
                     RS_ave_monthly_tmax,
                   data = IchawayGA_train)

summary(IchawayGA_m6)

# Tmax is only significant at 0.10 level


# Try removing Tmax

IchawayGA_m7 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_pet,
                   data = IchawayGA_train)

summary(IchawayGA_m7)

# Only precipitation becomes significant

# Try a different combination to improve adjusted R2

IchawayGA_m8 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_pet +
                     RS_max_NDVI,
                   data = IchawayGA_train)

summary(IchawayGA_m8)

#------------------------------------------------------------------------------#

# Check AIC
AIC(IchawayGA_m1)
AIC(IchawayGA_m2)
AIC(IchawayGA_m3)
AIC(IchawayGA_m4)
AIC(IchawayGA_m5)
AIC(IchawayGA_m6)
AIC(IchawayGA_m7)
AIC(IchawayGA_m8)

# Countercheck with BIC
# Bigger penalty for more complexity

BIC(IchawayGA_m1)
BIC(IchawayGA_m2)
BIC(IchawayGA_m3)
BIC(IchawayGA_m4)
BIC(IchawayGA_m5)
BIC(IchawayGA_m6)
BIC(IchawayGA_m7)
BIC(IchawayGA_m8)

# RESULTS: the model with the lowest AIC is Ichaway_m3
# Model with the lowest BIC is also Ichaway_m3

# At this point, it is the "best" model although it includes variables that are collinear

# Review models:
summary(IchawayGA_m3)
summary(IchawayGA_m4)
summary(IchawayGA_m8)

# p-values of both models are good. Adjusted R2 is higher in the model with four variables.
# But then again, it contains collinear predictors.

# Difficult to determine which model is best at this point.

#------------------------------------------------------------------------------#

# CHECK OLS ASSUMPTIONS for the IchawayGA_m8 model:

# 1. Linear relationship between dependent and independent variables
# 2. Variance of the residuals is constant
# 3. Residuals are normally distributed

# Plots of predictions and residuals

res <- residuals(IchawayGA_m8)
res

pred <- predict(IchawayGA_m8)
pred

par(mfrow = c(2,2))

# Observed values vs predicted values

plot(pred ~ IchawayGA_train$WB_annual_total_aet)
abline(0, 1)

# Model residuals vs predicted values

plot(res ~ pred)
lines(lowess(pred, res))

# Model residuals vs independent variables

plot(res ~ IchawayGA_train$RS_annual_total_precip)
lines(lowess(IchawayGA_train$RS_annual_total_precip, res))

plot(res ~ IchawayGA_train$RS_annual_total_pet)
lines(lowess(IchawayGA_train$RS_annual_total_pet, res))

plot(res ~ IchawayGA_train$RS_max_NDVI)
lines(lowess(IchawayGA_train$RS_max_NDVI, res))


# Are residuals normally distributed:
# Probability plot correlation test for normal distribution

r <- cor(res, qnorm((rank(res)-(3/8))/(length(res)+(1/4))))
r

# r alpha = 0.05 at N = 24 is between 0.9503 and 0.9639
# H0 = residuals are normally distributed; Ha = residuals are not normally distributed
# r = 0.956464 is close to both values; residuals may not be normally distributed

# Shapiro Wilk test
shapiro.test(res)

# p-value is 0.05621 > 0.05, fail to reject Ho. Residuals are normally distributed.


# Check autocorrelation function of residuals

acf(res) # all lines are within the threshold lines except for one (but is not overly out of the threshold)


#------------------------------------------------------------------------------#

# CHECK OLS ASSUMPTIONS for the IchawayGA_m4 model:

# 1. Linear relationship between dependent and independent variables
# 2. Variance of the residuals is constant
# 3. Residuals are normally distributed

# Plots of predictions and residuals

res <- residuals(IchawayGA_m4)
res

pred <- predict(IchawayGA_m4)
pred

par(mfrow = c(2,2))

# Observed values vs predicted values

plot(pred ~ IchawayGA_train$WB_annual_total_aet)
abline(0, 1)

# Model residuals vs predicted values

plot(res ~ pred)
lines(lowess(pred, res))

# Model residuals vs independent variables

plot(res ~ IchawayGA_train$RS_annual_total_precip)
lines(lowess(IchawayGA_train$RS_annual_total_precip, res))

plot(res ~ IchawayGA_train$RS_max_NDVI)
lines(lowess(IchawayGA_train$RS_max_NDVI, res))


# Are residuals normally distributed:
# Probability plot correlation test for normal distribution

r <- cor(res, qnorm((rank(res)-(3/8))/(length(res)+(1/4))))
r

# r alpha = 0.05 at N = 24 is between 0.9503 and 0.9639
# H0 = residuals are normally distributed; Ha = residuals are not normally distributed
# r = 0.9653298 is higher than both values; residuals are normally distributed

# Shapiro Wilk test
shapiro.test(res)

# p-value is 0.1256 > 0.05, fail to reject Ho. Residuals are normally distributed.
# This p-value is much higher than the p-value for the IchawayGA_m8 model


# Check autocorrelation function of residuals

acf(res) # all lines are within the threshold lines except for one (but is not overly out of the threshold)

#------------------------------------------------------------------------------#
# At this point, the "best" model is IchawayGA_m4

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 1990-2013

# Get coefficients

coef <- coef(IchawayGA_m4)
coef

pred_IchawayGA_aet <- (coef[1] + (coef[2] * IchawayGA_train$RS_annual_total_precip) +
                      (coef[3] * IchawayGA_train$RS_max_NDVI))
pred_IchawayGA_aet

# Compare predicted values vs training data

pred_IchawayGA_aet
IchawayGA_train$WB_annual_total_aet

# Check averages and standard deviation

mean(pred_IchawayGA_aet)
mean(IchawayGA_train$WB_annual_total_aet)

sd(pred_IchawayGA_aet)
sd(IchawayGA_train$WB_annual_total_aet)

# Check residuals, where residuals = predicted - fitted

residuals <- pred_IchawayGA_aet - IchawayGA_train$WB_annual_total_aet
residuals
hist(residuals)

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 2014-2020 (testing data set)

pred_IchawayGA_aet2 <- (coef[1] + (coef[2] * IchawayGA_test$RS_annual_total_precip) +
                           (coef[3] * IchawayGA_test$RS_max_NDVI))

pred_IchawayGA_aet2

# Compare predicted values vs testing data

pred_IchawayGA_aet2
IchawayGA_test$WB_annual_total_aet   

# Check averages and standard deviation

mean(pred_IchawayGA_aet2)
mean(IchawayGA_test$WB_annual_total_aet)
sd(pred_IchawayGA_aet2)
sd(IchawayGA_test$WB_annual_total_aet)


residuals2 <- pred_IchawayGA_aet2 - IchawayGA_test$WB_annual_total_aet
residuals2
hist(residuals2)

shapiro.test(residuals2)

# Shapiro-Wilk test indicates that residuals are normally distributed

#------------------------------------------------------------------------------#

# FILE OUTPUT:

IchawayGA_pred <- data.frame(water_year = IchawayGA_train$water_year,
                               obs_wbet = IchawayGA_train$WB_annual_total_aet,
                               pred_wbet = pred_IchawayGA_aet,
                               residuals = residuals(IchawayGA_m4))

write.csv(IchawayGA_pred, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/IchawayGA_pred.csv",
          row.names = FALSE)

