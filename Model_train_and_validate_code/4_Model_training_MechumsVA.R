
# MODEL TRAINING AND VALIDATION: Mechums River, VA

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

# Mechums River, VA

# Read in data

data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/MechumsVA_data.csv", header = T)

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


MechumsVA_data2 <- data.frame(data$water_year,
                    data$WB_annual_total_aet,
                    data$RS_annual_total_precip,
                    (data$RS_annual_total_pet * 0.1),
                    (data$RS_annual_total_soil_moisture * 0.1),
                    (data$RS_ave_monthly_tmax * 0.1),
                    data$RS_max_NDVI)

# Rename columns

colnames(MechumsVA_data2) <- c("water_year",
                              "WB_annual_total_aet",
                              "RS_annual_total_precip",
                              "RS_annual_total_pet",
                              "RS_annual_total_soil_moisture",
                              "RS_ave_monthly_tmax",
                              "RS_max_NDVI")


# Subset the data frame such that only water years 1990-2014 will be used for model training
# and water years 2015-2020 will be used for model testing

MechumsVA_train <- MechumsVA_data2[MechumsVA_data2$water_year <= 2013, ]
MechumsVA_test <- MechumsVA_data2[MechumsVA_data2$water_year >= 2014, ]


# Remove data in training set with negative AET

MechumsVA_train <- MechumsVA_train[MechumsVA_train$WB_annual_total_aet > 0, ]


# Calculate the correlations between the y and the potential x variables

MechumsVA_cor <- data.frame(cor(MechumsVA_train[ , 2:7]))
plot(MechumsVA_train[ , 2:7])

# There seems to be multicollinearity between PET and monthly maximum temperature
# To check:
cor(MechumsVA_train$RS_annual_total_pet, MechumsVA_train$RS_ave_monthly_tmax)

# Correlation is at 0.8681724 which is high 


#------------------------------------------------------------------------------#

# Make model with all variables included

MechumsVA_m1 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                    RS_annual_total_pet +
                    RS_annual_total_soil_moisture +
                    RS_ave_monthly_tmax +
                    RS_max_NDVI,
                  data = MechumsVA_train)

# Get summary of the model
summary(MechumsVA_m1)

# Check multicollinearity
vif(MechumsVA_m1)   # VIF > 5 in PET only


# Make a model with only one variable included (this will be necessary for the stepAIC later)
# Based on the correlation data, precipitation is the "most" correlated with AET

MechumsVA_m2 <- lm(WB_annual_total_aet ~ RS_annual_total_precip, data = MechumsVA_train)

# Get summary of the model
summary(MechumsVA_m2)

#------------------------------------------------------------------------------#

# DEALING WITH MULTICOLLINEARITY: which variable to omit

# Since PET and tmax are highly correlated, one of them has to be removed to prevent coming
# up with a model with inflated variance

# Based on the p-values of the coefficients in the regression model, PET has a lower
# p-value than tmax

# Based on correlation matrix with all predictors, PET has a higher correlation with
# water balance AET than tmax

# Based on the VIF of the model, PET has a higher VIF than tmax

# With all these, difficult to identify which variable has to be removed

# Try making a model without tmax

MechumsVA_m3 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_pet +
                    RS_annual_total_soil_moisture +
                    RS_max_NDVI,
                  data = MechumsVA_train)

# Get summary of the model
summary(MechumsVA_m3)

# Check multicollinearity
vif(MechumsVA_m3)   # no more VIF > 5


#------------------------------------------------------------------------------#

# Perform best subset regression

# 1) Maximize the adjusted R2

MechumsVA_leaps <- leaps(MechumsVA_train[ ,3:7], MechumsVA_train$WB_annual_total_aet, 
      method = "adjr2",
      names = names(MechumsVA_train[ ,3:7]),
      nbest = 1)

MechumsVA_leaps

# Note:
# method = adjr2 = sets the condition to look only at the adjusted R2
# nbest = how many best models per number of variables; when set as 1, the results will show
# which variable/s is/are best to be included in the model depending on how many variables
# the user wants to include

# RESULTS:
# See where "TRUE" occurs; this means that this is/are the variable/s that will be best included in the model

# if 1 variable only = RS_annual_total_precip
# Adjusted R2 = 0.3618769

# if 2 variables = RS_annual_total_precip + RS_annual_total_soil_moisture
# Adjusted R2 = 0.3798338

# if 3 variables = RS_annual_total_precip + RS_annual_total_pet + RS_annual_total_soil_moisture
# Adjusted R2 = 0.3782985

# if 4 variables = all except RS_ave_monthly_tmax = so it seems correct that tmax is not an important variable
# Adjusted R2 = 0.3645168

# if all 5 variables
# Adjusted R2 = 0.3383764


# Highest adjusted R2 so far is for the model that contains two variables, followed closely by the model with three variables

MechumsVA_m4 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_soil_moisture, 
                     data = MechumsVA_train)

summary(MechumsVA_m4)

# soil moisture is not significant in this model

# Try the model with three variables

MechumsVA_m5 <- lm(WB_annual_total_aet ~ RS_annual_total_precip +
                     RS_annual_total_pet +
                     RS_annual_total_soil_moisture, 
                   data = MechumsVA_train)

summary(MechumsVA_m5)

# Both adjusted R2 and p-value did not improve; only precipitation is the significant variable

#------------------------------------------------------------------------------#

# Perform stepwise regression using an F test
# using dropterm = going backwards, starting with all variables

dropterm(MechumsVA_m1, test = "F", sorted = TRUE)  # m1 is the model that contains all the variables

# RESULTS:
# p-values: if greater than 0.05, the variable/s should not have been added to the model

# The only variable significant is precipitation

#------------------------------------------------------------------------------#

# Perform stepwise regression using AIC

stepAIC(MechumsVA_m2,
        scope = list(upper = MechumsVA_m1, lower = ~1),
        direction = "both",
        trace = TRUE)


# RESULTS:
# Lowest AIC is 234.48 for the model containing precipitation only, closely followed by the model with two variables (+ RS_annual_total_soil_moisture)


#------------------------------------------------------------------------------#

# Check AIC
AIC(MechumsVA_m1)
AIC(MechumsVA_m2)
AIC(MechumsVA_m3)
AIC(MechumsVA_m4)
AIC(MechumsVA_m5)

# Countercheck with BIC
# Bigger penalty for more complexity

BIC(MechumsVA_m1)
BIC(MechumsVA_m2)
BIC(MechumsVA_m3)
BIC(MechumsVA_m4)
BIC(MechumsVA_m5)

# RESULTS: the model with the lowest AIC and BIC is BrandywinePA_m2. 

# At this point, it is the "best" model is either the one with only one variable and the one
# with two variables.

# Review model:
summary(MechumsVA_m2)
summary(MechumsVA_m4)

# Since soil moisture is not significant in the model even though it has a slightly higher adjusted R2,
# the "best" model that will be considered is the one with precipitation only. Besides,
# it has a lower p-value.

#------------------------------------------------------------------------------#

# CHECK OLS ASSUMPTIONS for the "best" model:

# 1. Linear relationship between dependent and independent variables
# 2. Variance of the residuals is constant
# 3. Residuals are normally distributed

# Plots of predictions and residuals

res <- residuals(MechumsVA_m2)
res

pred <- predict(MechumsVA_m2)
pred

par(mfrow = c(2,2))

# Observed values vs predicted values

plot(pred ~ MechumsVA_train$WB_annual_total_aet)
abline(0, 1)

# Model residuals vs predicted values

plot(res ~ pred)
lines(lowess(pred, res))

# Model residuals vs independent variables

plot(res ~ MechumsVA_train$RS_annual_total_precip)
lines(lowess(MechumsVA_train$RS_annual_total_precip, res))


# Are residuals normally distributed:
# Probability plot correlation test for normal distribution

r <- cor(res, qnorm((rank(res)-(3/8))/(length(res)+(1/4))))
r

# r alpha = 0.05 at N = 24 is between 0.9503 and 0.9639
# H0 = residuals are normally distributed; Ha = residuals are not normally distributed
# r = 0.9868604 is greater than both values, therefore, fail to reject H0, residuals are normally distributed

# Shapiro Wilk test
shapiro.test(res)

# p-value is > 0.05, fail to reject Ho. Residuals are normally distributed.


# Check autocorrelation function of residuals

acf(res) # all lines are within the threshold lines

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 1990-2013

# Get coefficients

coef <- coef(MechumsVA_m2)
coef

pred_MechumsVA_aet <- (coef[1] + (coef[2] * MechumsVA_train$RS_annual_total_precip))
pred_MechumsVA_aet

# Compare predicted values vs training data

pred_MechumsVA_aet
MechumsVA_train$WB_annual_total_aet

# Check averages and standard deviation

mean(pred_MechumsVA_aet)
mean(MechumsVA_train$WB_annual_total_aet)

sd(pred_MechumsVA_aet)
sd(MechumsVA_train$WB_annual_total_aet)

# Check residuals, where residuals = predicted - fitted

residuals <- pred_MechumsVA_aet - MechumsVA_train$WB_annual_total_aet
residuals
hist(residuals)

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 2014-2020 (testing data set)

pred_MechumsVA_aet2 <- (coef[1] + (coef[2] * MechumsVA_test$RS_annual_total_precip))

pred_MechumsVA_aet2

# Compare predicted values vs testing data

pred_MechumsVA_aet2
MechumsVA_test$WB_annual_total_aet   

# Check averages and standard deviation

mean(pred_MechumsVA_aet2)
mean(MechumsVA_test$WB_annual_total_aet)
sd(pred_MechumsVA_aet2)
sd(MechumsVA_test$WB_annual_total_aet)


residuals2 <- pred_MechumsVA_aet2 - MechumsVA_test$WB_annual_total_aet
residuals2
hist(residuals2)

shapiro.test(residuals2)

# Shapiro-Wilk test indicates that residuals are normally distributed

#------------------------------------------------------------------------------#

# FILE OUTPUT:

MechumsVA_pred <- data.frame(water_year = MechumsVA_train$water_year,
                                obs_wbet = MechumsVA_train$WB_annual_total_aet,
                                pred_wbet = pred_MechumsVA_aet,
                                residuals = residuals(MechumsVA_m2))

write.csv(MechumsVA_pred, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/MechumsVA_pred.csv",
          row.names = FALSE)
