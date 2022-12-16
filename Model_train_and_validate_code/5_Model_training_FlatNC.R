
# MODEL TRAINING AND VALIDATION: Flat River, North Carolina

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

# Flat River, NC

# Read in data

data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/FlatNC_data.csv", header = T)

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


FlatNC_data2 <- data.frame(data$water_year,
                    data$WB_annual_total_aet,
                    data$RS_annual_total_precip,
                    (data$RS_annual_total_pet * 0.1),
                    (data$RS_annual_total_soil_moisture * 0.1),
                    (data$RS_ave_monthly_tmax * 0.1),
                    data$RS_max_NDVI)

# Rename columns

colnames(FlatNC_data2) <- c("water_year",
                              "WB_annual_total_aet",
                              "RS_annual_total_precip",
                              "RS_annual_total_pet",
                              "RS_annual_total_soil_moisture",
                              "RS_ave_monthly_tmax",
                              "RS_max_NDVI")


# Subset the data frame such that only water years 1990-2014 will be used for model training
# and water years 2015-2020 will be used for model testing

FlatNC_train <- FlatNC_data2[FlatNC_data2$water_year <= 2013, ]
FlatNC_test <- FlatNC_data2[FlatNC_data2$water_year >= 2014, ]


# Remove data in training set with negative AET

FlatNC_train <- FlatNC_train[FlatNC_train$WB_annual_total_aet > 0, ]


# Calculate the correlations between the y and the potential x variables

FlatNC_cor <- data.frame(cor(FlatNC_train[ , 2:7]))
plot(FlatNC_train[ , 2:7])

# There seems to be multicollinearity between PET and monthly maximum temperature
# To check:
cor(FlatNC_train$RS_annual_total_pet, FlatNC_train$RS_ave_monthly_tmax)

# Correlation is at 0.824912 which is high 


#------------------------------------------------------------------------------#

# Make model with all variables included

FlatNC_m1 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                    RS_annual_total_pet +
                    RS_annual_total_soil_moisture +
                    RS_ave_monthly_tmax +
                    RS_max_NDVI,
                  data = FlatNC_train)

# Get summary of the model
summary(FlatNC_m1)

# Check multicollinearity
vif(FlatNC_m1)   # no VIF > 5


# Make a model with only one variable included (this will be necessary for the stepAIC later)
# Based on the correlation data, precipitation is the "most" correlated with AET

FlatNC_m2 <- lm(WB_annual_total_aet ~ RS_annual_total_precip, data = FlatNC_train)

# Get summary of the model
summary(FlatNC_m2)

#------------------------------------------------------------------------------#

# DEALING WITH MULTICOLLINEARITY: which variable to omit

# Since PET and tmax are highly correlated, one of them has to be removed to prevent coming
# up with a model with inflated variance

# Based on the p-values of the coefficients in the regression model, tmax has a lower
# p-value than PET

# Based on correlation matrix with all predictors, PET has a higher correlation with
# water balance AET than tmax

# Based on the VIF of the model, nothing is highly concerning

# With all these, difficult to identify which variable has to be removed

# Try making a model without tmax

FlatNC_m3 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_pet +
                    RS_annual_total_soil_moisture +
                    RS_max_NDVI,
                  data = FlatNC_train)

# Get summary of the model
summary(FlatNC_m3)

# Check multicollinearity
vif(FlatNC_m3)  


#------------------------------------------------------------------------------#

# Perform best subset regression

# 1) Maximize the adjusted R2

FlatNC_leaps <- leaps(FlatNC_train[ ,3:7], FlatNC_train$WB_annual_total_aet, 
      method = "adjr2",
      names = names(FlatNC_train[ ,3:7]),
      nbest = 1)

FlatNC_leaps

# Note:
# method = adjr2 = sets the condition to look only at the adjusted R2
# nbest = how many best models per number of variables; when set as 1, the results will show
# which variable/s is/are best to be included in the model depending on how many variables
# the user wants to include

# RESULTS:
# See where "TRUE" occurs; this means that this is/are the variable/s that will be best included in the model

# if 1 variable only = RS_annual_total_precip
# Adjusted R2 = 0.1838236

# if 2 variables = RS_annual_total_precip + RS_annual_total_soil_moisture
# Adjusted R2 = 0.2068759

# if 3 variables = RS_annual_total_precip + RS_annual_total_soil_moisture + RS_ave_monthly_tmax
# Adjusted R2 = 0.1889724

# if 4 variables = all except RS_annual_total_pet
# Adjusted R2 = 0.1649166

# if all 5 variables
# Adjusted R2 = 0.1285943


# Results suggest that it should be PET eliminated, not tmax
# Highest adjusted R2 so far is for the model that contains two variables

FlatNC_m4 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_soil_moisture, 
                     data = FlatNC_train)

summary(FlatNC_m4)

# soil moisture is not significant in this model

# Try the model with three variables, since it has the next highest adjusted R2

FlatNC_m5 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                  RS_annual_total_soil_moisture +
                  RS_ave_monthly_tmax,
                data = FlatNC_train)

summary(FlatNC_m5)

# Both adjusted R2 and p-value did not improve; only precipitation is the significant variable
# But if only precipitation is in the model, the adjusted R2 is lower, even though its p-value is better

#------------------------------------------------------------------------------#

# Perform stepwise regression using an F test
# using dropterm = going backwards, starting with all variables

dropterm(FlatNC_m1, test = "F", sorted = TRUE)  # m1 is the model that contains all the variables

# RESULTS:
# p-values: if greater than 0.05, the variable/s should not have been added to the model

# The only variable significant is precipitation

#------------------------------------------------------------------------------#

# Perform stepwise regression using AIC

stepAIC(FlatNC_m2,
        scope = list(upper = FlatNC_m1, lower = ~1),
        direction = "both",
        trace = TRUE)


# RESULTS:
# Lowest AIC is 241.86 for the model containing precipitation only, closely followed by the model with two variables (+ RS_annual_total_soil_moisture)


#------------------------------------------------------------------------------#

# Check AIC
AIC(FlatNC_m1)
AIC(FlatNC_m2)
AIC(FlatNC_m3)
AIC(FlatNC_m4)
AIC(FlatNC_m5)

# Countercheck with BIC
# Bigger penalty for more complexity

BIC(FlatNC_m1)
BIC(FlatNC_m2)
BIC(FlatNC_m3)
BIC(FlatNC_m4)
BIC(FlatNC_m5)

# RESULTS: the model with the lowest AIC and BIC is FlatNC_m2. 

# At this point, it is the "best" model is either the one with only one variable and the one
# with two variables.

# Review model:
summary(FlatNC_m2)
summary(FlatNC_m4)

# Soil moisture is not significant in the model but since it has a slightly higher adjusted R2,
# this will be the "best" model that will be considered.

#------------------------------------------------------------------------------#

# CHECK OLS ASSUMPTIONS for the "best" model:

# 1. Linear relationship between dependent and independent variables
# 2. Variance of the residuals is constant
# 3. Residuals are normally distributed

# Plots of predictions and residuals

res <- residuals(FlatNC_m4)
res

pred <- predict(FlatNC_m4)
pred

par(mfrow = c(2,2))

# Observed values vs predicted values

plot(pred ~ FlatNC_train$WB_annual_total_aet)
abline(0, 1)

# Model residuals vs predicted values

plot(res ~ pred)
lines(lowess(pred, res))

# Model residuals vs independent variables

plot(res ~ FlatNC_train$RS_annual_total_precip)
lines(lowess(FlatNC_train$RS_annual_total_precip, res))

plot(res ~ FlatNC_train$RS_annual_total_soil_moisture)
lines(lowess(FlatNC_train$RS_annual_total_soil_moisture, res))

# Are residuals normally distributed:
# Probability plot correlation test for normal distribution

r <- cor(res, qnorm((rank(res)-(3/8))/(length(res)+(1/4))))
r

# r alpha = 0.05 at N = 24 is between 0.9503 and 0.9639
# H0 = residuals are normally distributed; Ha = residuals are not normally distributed
# r = 0.9756 is greater than both values, therefore, fail to reject H0, residuals are normally distributed

# Shapiro Wilk test
shapiro.test(res)

# p-value is > 0.05, fail to reject Ho. Residuals are normally distributed.


# Check autocorrelation function of residuals

acf(res) # all lines are within the threshold lines

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 1990-2013

# Get coefficients

coef <- coef(FlatNC_m4)
coef

pred_FlatNC_aet <- (coef[1] + (coef[2] * FlatNC_train$RS_annual_total_precip) +
                      (coef[3] * FlatNC_train$RS_annual_total_soil_moisture))
pred_FlatNC_aet

# Compare predicted values vs training data

pred_FlatNC_aet
FlatNC_train$WB_annual_total_aet

# Check averages and standard deviation

mean(pred_FlatNC_aet)
mean(FlatNC_train$WB_annual_total_aet)

sd(pred_FlatNC_aet)
sd(FlatNC_train$WB_annual_total_aet)

# Check residuals, where residuals = predicted - fitted

residuals <- pred_FlatNC_aet - FlatNC_train$WB_annual_total_aet
residuals
hist(residuals)

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 2014-2020 (testing data set)

pred_FlatNC_aet2 <- (coef[1] + (coef[2] * FlatNC_test$RS_annual_total_precip) +
                      (coef[3] * FlatNC_test$RS_annual_total_soil_moisture))

pred_FlatNC_aet2

# Compare predicted values vs testing data

pred_FlatNC_aet2
FlatNC_test$WB_annual_total_aet   

# Check averages and standard deviation

mean(pred_FlatNC_aet2)
mean(FlatNC_test$WB_annual_total_aet)
sd(pred_FlatNC_aet2)
sd(FlatNC_test$WB_annual_total_aet)


residuals2 <- pred_FlatNC_aet2 - FlatNC_test$WB_annual_total_aet
residuals2
hist(residuals2)

shapiro.test(residuals2)

# Shapiro-Wilk test indicates that residuals are normally distributed

#------------------------------------------------------------------------------#

# FILE OUTPUT:

FlatNC_pred <- data.frame(water_year = FlatNC_train$water_year,
                             obs_wbet = FlatNC_train$WB_annual_total_aet,
                             pred_wbet = pred_FlatNC_aet,
                             residuals = residuals(FlatNC_m4))

write.csv(FlatNC_pred, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/FlatNC_pred.csv",
          row.names = FALSE)
