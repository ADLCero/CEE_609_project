
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


#------------------------------------------------------------------------------#

# Perform best subset regression

# 1) Maximize the adjusted R2

leaps(OysterNH_train[ ,3:6], OysterNH_train$WB_annual_total_aet, 
      method = "adjr2",
      names = names(OysterNH_train[ ,3:6]),
      nbest = 1)

# Note:
# method = adjr2 = sets the condition to look only at the adjusted R2
# nbest = how many best models per number of variables; when set as 1, the results will show
# which variable/s is/are best to be included in the model depending on how many variables
# the user wants to include

# RESULTS:
# See where "TRUE" occurs; this means that this is the variables that will be best included in the model

# if 1 variable only = RS_annual_total_precip
# if 2 variables = RS_annual_total_precip, RS_annual_total_pet
# if 3 variables = RS_annual_total_precip, RS_annual_total_pet, RS_ave_monthly_tmax


#------------------------------------------------------------------------------#




