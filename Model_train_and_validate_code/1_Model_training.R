
# MODEL TRAINING AND VALIDATION

################################################################################

# The corresponding packages of the required libraries below may need to be 
# downloaded first using the install.packages("package") command or 
# by going to R Studio's Menu > Tools > Install packages

# R will also prompt which packages need to be installed upon opening this script

# Libraries:

library(leaps)    # for performing subset regression
library(MASS)     # for performing stepwise regression

################################################################################

# Oyster River, New Hampshire = OysterNH

# Read in data

data <- read.csv("/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/OysterNH_data.csv", header = T)

# Make a new data frame that includes only the following variables as predictors:
# 1) RS_annual_total_precip = remote-sensed precipitation data (mm), total for the water year, from TerraClimate
# 2) RS_annual_total_pet = remote-sensed PET, total for the water year, from TerraClimate
# 3) RS_annual_total_soil_moisture = remote-sensed soil moisture (mm), total for the water year, from TerraClimate
# 4) RS_ave_monthly_tmax = maximum temperature (degC), monthly average, from TerraClimate

# Multiply PET, soil moisture, and tmax by 0.1 since scale = 0.1, 
# according to https://developers.google.com/earth-engine/datasets/catalog/IDAHO_EPSCOR_TERRACLIMATE#bands


OysterNH_data2 <- data.frame(data$water_year,
                    data$WB_annual_total_aet,
                    data$RS_annual_total_precip,
                    (data$RS_annual_total_pet * 0.1),
                    (data$RS_annual_total_soil_moisture * 0.1),
                    (data$RS_ave_monthly_tmax * 0.1))

# Rename columns

colnames(OysterNH_data2) <- c("water_year",
                              "WB_annual_total_aet",
                              "RS_annual_total_precip",
                              "RS_annual_total_pet",
                              "RS_annual_total_soil_moisture",
                              "RS_ave_monthly_tmax")


# Subset the data frame such that only water years 1990-2014 will be used for model training
# and water years 2015-2020 will be used for model testing

OysterNH_train <- OysterNH_data2[OysterNH_data2$water_year <= 2014, ]
OysterNH_test <- OysterNH_data2[OysterNH_data2$water_year >= 2015, ]


# Remove data in training set with negative AET

OysterNH_train <- OysterNH_train[OysterNH_train$WB_annual_total_aet > 0, ]


# Calculate the correlations between the y and the potential x variables

OysterNH_cor <- data.frame(cor(OysterNH_train[ , 2:6]))
plot(OysterNH_train[ , 2:6])


#------------------------------------------------------------------------------#

# Make model with all variables included

OysterNH_m1 <- lm(OysterNH_train$WB_annual_total_aet ~ OysterNH_train$RS_annual_total_precip +
                    OysterNH_train$RS_annual_total_pet +
                    OysterNH_train$RS_annual_total_soil_moisture +
                    OysterNH_train$RS_ave_monthly_tmax)


# Get summary of the model
summary(OysterNH_m1)

# Obtain model parameters
coef1 <- coef(OysterNH_m1)

# Obtain model predictions
pred1 <- predict(OysterNH_m1)

# Obtain model residuals
res1 <- residuals(OysterNH_m1)

# Obtain adjusted R2
adj_R2 <- summary(OysterNH_m1)$adj.r.squared



# Make a model with only one variable included (this will be necessary for the stepAIC later)
# Based on the correlation data, precipitation is the "most" correlated with AET

OysterNH_m2 <- lm(OysterNH_train$WB_annual_total_aet ~ OysterNH_train$RS_annual_total_precip)

# Get summary of the model
summary(OysterNH_m2)

# Obtain model parameters
coef1 <- coef(OysterNH_m2)

# Obtain model predictions
pred1 <- predict(OysterNH_m2)

# Obtain model residuals
res1 <- residuals(OysterNH_m2)

# Obtain adjusted R2
adj_R2 <- summary(OysterNH_m2)$adj.r.squared



#------------------------------------------------------------------------------#

# Perform best subset regression

# 1) Maximize the adjusted R2

OysterNH_leaps <- leaps(OysterNH_train[ ,3:6], OysterNH_train$WB_annual_total_aet, 
      method = "adjr2",
      names = names(OysterNH_train[ ,3:6]),
      nbest = 1)

# Note:
# method = adjr2 = sets the condition to look only at the adjusted R2
# nbest = how many best models per number of variables; when set as 1, the results will show
# which variable/s is/are best to be included in the model depending on how many variables
# the user wants to include

# RESULTS:
# See where "TRUE" occurs; this means that this is/are the variable/s that will be best included in the model

# if 1 variable only = RS_annual_total_precip 
# Adjusted R2 =
OysterNH_leaps$adjr2[1] # 0.07625194

# if 2 variables = RS_annual_total_precip, RS_annual_total_pet
# Adjusted R2 = 
OysterNH_leaps$adjr2[2] # 0.1101781

# if 3 variables = RS_annual_total_precip, RS_annual_total_pet, RS_ave_monthly_tmax
# Adjusted R2 =
OysterNH_leaps$adjr2[3] # 0.07378092

# if all four variables,
# Adjusted R2 =
OysterNH_leaps$adjr2[4] # 0.03319767

# Highest adjusted R2 so far is for the model that will contain two variables, precipitation and PET


#------------------------------------------------------------------------------#

# Perform stepwise regression using an F test
# using dropterm = going backwards, starting with all variables

dropterm(OysterNH_m1, test = "F", sorted = TRUE)  # m1 is the model that contains all the variables

# RESULTS:
# p-values: if greater than 0.05, the variable/s should not have been added to the model

# All p-values are greater than 0.05 but the variables with the lowest p-values are
# precipitation and PET


#------------------------------------------------------------------------------#

# Perform stepwise regression using AIC

stepAIC(OysterNH_m2,
        scope = list(upper = OysterNH_m1, lower = ~1),
        direction = "both",
        trace = TRUE)


# RESULTS:
# Lowest AIC is 234.21 for model with precipitation and PET,
# followed by AIC = 234.22 for model with precipitation only


#------------------------------------------------------------------------------#

# Based on the results so far, a model with two variables: precipitation, and PET,
# seems to be the "best" fit

#------------------------------------------------------------------------------#

# Make model with the two variables

OysterNH_m3 <- lm(OysterNH_train$WB_annual_total_aet ~ OysterNH_train$RS_annual_total_precip +
                    OysterNH_train$RS_annual_total_pet)


# Get summary of the model
summary(OysterNH_m3)

# Obtain model parameters
coef1 <- coef(OysterNH_m3)

# Obtain model predictions
pred1 <- predict(OysterNH_m3)

# Obtain model residuals
res1 <- residuals(OysterNH_m3)

# Obtain adjusted R2
adj_R2 <- summary(OysterNH_m3)$adj.r.squared

# RESULTS:
# In this model, precipitation is significant at alpha = 0.1 but not at alpha = 0.05
# It has the "best" adjusted R2 so far at 0.1102 (not good but the best that can be obtained,
# as verified in the leaps)

#------------------------------------------------------------------------------#

# Countercheck with BIC
# Bigger penalty for more complexity

BIC(OysterNH_m1)
BIC(OysterNH_m2)
BIC(OysterNH_m3)

# RESULTS: The model with the lowest BIC is the model with the least variables (only one variable)
# but this model did not have a good adjusted R2


#------------------------------------------------------------------------------#

# CHECK OLS ASSUMPTIONS for the "best" model:

# 1. Linear relationship between dependent and independent variables
# 2. Variance of the residuals is constant
# 3. Residuals are normally distributed

# Plots of predictions and residuals

res <- residuals(OysterNH_m3)
res

pred <- predict(OysterNH_m3)
pred

par(mfrow = c(2,2))

# Observed values vs predicted values

plot(pred ~ OysterNH_train$WB_annual_total_aet)
abline(0, 1)

# Model residuals vs predicted values

plot(res ~ pred)
lines(lowess(pred, res))

# Model residuals vs independent variables

plot(res ~ OysterNH_train$RS_annual_total_precip)
lines(lowess(OysterNH_train$RS_annual_total_precip, res))

plot(res ~ OysterNH_train$RS_annual_total_pet)
lines(lowess(OysterNH_train$RS_annual_total_pet, res))

# Are residuals normally distributed

r <- cor(res, qnorm((rank(res)-(3/8))/(length(res)+(1/4))))
r

# r alpha = 0.05 at N = 24 is between 0.9503 and 0.9639
# H0 = residuals are normally distributed; Ha = residuals are not normally distributed
# r = 0.9857579 is greater than both values, therefore, fail to reject H0, residuals are normally distributed


# Check autocorrelation function of residuals

acf(res)

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 1990-2014

# Get coefficients

coef <- coef(OysterNH_m3)
coef

pred_OysterNH_aet <- (coef[1] + (coef[2] * OysterNH_train$RS_annual_total_precip) +
                        (coef[3] * OysterNH_train$RS_annual_total_pet))
pred_OysterNH_aet

# Compare predicted values vs training data

pred_OysterNH_aet
OysterNH_train$WB_annual_total_aet

# Check averages and standard deviation

mean(pred_OysterNH_aet)
mean(OysterNH_train$WB_annual_total_aet)

sd(pred_OysterNH_aet)
sd(OysterNH_train$WB_annual_total_aet)

# Check residuals, where residuals = predicted - fitted

residuals <- pred_OysterNH_aet - OysterNH_train$WB_annual_total_aet
residuals
hist(residuals)

#------------------------------------------------------------------------------#

# USE THE "BEST" MODEL TO MAKE A PREDICTION FOR ACTUAL EVAPOTRANSPIRATION
# For water years 2015-2020 (testing data set)

pred_OysterNH_aet2 <- (coef[1] + (coef[2] * OysterNH_test$RS_annual_total_precip) +
                         (coef[3] * OysterNH_test$RS_annual_total_pet))

pred_OysterNH_aet2

# Compare predicted values vs testing data

pred_OysterNH_aet2
OysterNH_test$WB_annual_total_aet

# Check averages and standard deviation

mean(pred_OysterNH_aet2)
mean(OysterNH_test$WB_annual_total_aet)
sd(pred_OysterNH_aet2)
sd(OysterNH_test$WB_annual_total_aet)

# The mean of the predicted data is higher than the mean AET of the testing data set.
# However, its standard deviation is lower than the standard deviation of the testing data

residuals2 <- pred_OysterNH_aet2 - OysterNH_test$WB_annual_total_aet
residuals2
hist(residuals2)

# Residuals are mostly positive, indicating that the model is overpredicting AET


