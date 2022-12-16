
# MODEL TRAINING AND VALIDATION

# Other statistical tests

################################################################################

# Since data has been imported to .csv files, data from previous scripts can now be cleared
# from the environment
rm(list = ls())

# LIBRARIES:
library(tidyverse)

################################################################################

# Read in data

OysterNH_data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/OysterNH_data.csv", header = T)
WappingerNY_data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/WappingerNY_data.csv", header = T)
BrandywinePA_data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/BrandywinePA_data.csv", header = T)
MechumsVA_data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/MechumsVA_data.csv", header = T)
FlatNC_data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/FlatNC_data.csv", header = T)
NorthForkSC_data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/NorthForkSC_data.csv", header = T)
IchawayGA_data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/IchawayGA_data.csv", header = T)


# Remove negative water balance AET

OysterNH_data2 <- OysterNH_data %>% 
  filter(WB_annual_total_aet > 0)

WappingerNY_data2 <- WappingerNY_data %>% 
  filter(WB_annual_total_aet > 0)

################################################################################

# SUMMARY STATISTICS

summary(OysterNH_data2)
summary(WappingerNY_data2)
summary(BrandywinePA_data)
summary(MechumsVA_data)
summary(FlatNC_data)
summary(NorthForkSC_data)
summary(IchawayGA_data)


# COMPARISON OF WATER BALANCE ET and REMOTE SENSED ET
# Compare means of two groups

# Oyster NH

# Check normality of data
shapiro.test(OysterNH_data2$WB_annual_total_aet)  # normal
shapiro.test(OysterNH_data2$RS_annual_total_aet)  # normal

# Test for equality of variances
var.test(OysterNH_data2$WB_annual_total_aet,
       OysterNH_data2$RS_annual_total_aet)  # p < 0 0.5, reject HO, variances are not equal

# Independent samples test; paired = FALSE since variances are unequal
t.test(OysterNH_data2$WB_annual_total_aet,
       OysterNH_data2$RS_annual_total_aet,
       paired = FALSE)                      # p < 0.05, reject HO, means are significantly different

#------------------------------------------------------------------------------#

# WappingerNY

# Check normality of data
shapiro.test(WappingerNY_data2$WB_annual_total_aet)  # normal
shapiro.test(WappingerNY_data2$RS_annual_total_aet)  # normal

# Test for equality of variances
var.test(WappingerNY_data2$WB_annual_total_aet,
         WappingerNY_data2$RS_annual_total_aet)  # p < 0 0.5, reject HO, variances are not equal

# Independent samples test; paired = FALSE since variances are unequal
t.test(WappingerNY_data2$WB_annual_total_aet,
       WappingerNY_data2$RS_annual_total_aet,
       paired = FALSE)                      # p < 0.05, reject HO, means are significantly different


#------------------------------------------------------------------------------#

# BrandywinePA

# Check normality of data
shapiro.test(BrandywinePA_data$WB_annual_total_aet)  # normal
shapiro.test(BrandywinePA_data$RS_annual_total_aet)  # normal

# Test for equality of variances
var.test(BrandywinePA_data$WB_annual_total_aet,
         BrandywinePA_data$RS_annual_total_aet)  # p < 0 0.5, reject HO, variances are not equal

# Independent samples test; paired = FALSE since variances are unequal
t.test(BrandywinePA_data$WB_annual_total_aet,
       BrandywinePA_data$RS_annual_total_aet,
       paired = FALSE)                      # p < 0.05, reject HO, means are significantly different


#------------------------------------------------------------------------------#

# MechumsVA

# Check normality of data
shapiro.test(MechumsVA_data$WB_annual_total_aet)  # normal
shapiro.test(MechumsVA_data$RS_annual_total_aet)  # normal

# Test for equality of variances
var.test(MechumsVA_data$WB_annual_total_aet,
         MechumsVA_data$RS_annual_total_aet)  # p < 0 0.5, reject HO, variances are not equal

# Independent samples test; paired = FALSE since variances are unequal
t.test(MechumsVA_data$WB_annual_total_aet,
       MechumsVA_data$RS_annual_total_aet,
       paired = FALSE)                      # p < 0.05, reject HO, means are significantly different

#------------------------------------------------------------------------------#

# FlatNC

# Check normality of data
shapiro.test(FlatNC_data$WB_annual_total_aet)  # normal
shapiro.test(FlatNC_data$RS_annual_total_aet)  # normal

# Test for equality of variances
var.test(FlatNC_data$WB_annual_total_aet,
         FlatNC_data$RS_annual_total_aet)  # p < 0 0.5, reject HO, variances are not equal

# Independent samples test; paired = FALSE since variances are unequal
t.test(FlatNC_data$WB_annual_total_aet,
       FlatNC_data$RS_annual_total_aet,
       paired = FALSE)                      # p < 0.05, reject HO, means are significantly different


#------------------------------------------------------------------------------#

# NorthForkSC

# Check normality of data
shapiro.test(NorthForkSC_data$WB_annual_total_aet)  # normal
shapiro.test(NorthForkSC_data$RS_annual_total_aet)  # normal

# Test for equality of variances
var.test(NorthForkSC_data$WB_annual_total_aet,
         NorthForkSC_data$RS_annual_total_aet)  # p < 0 0.5, reject HO, variances are not equal

# Independent samples test; paired = FALSE since variances are unequal
t.test(NorthForkSC_data$WB_annual_total_aet,
       NorthForkSC_data$RS_annual_total_aet,
       paired = FALSE)                      # p < 0.05, reject HO, means are significantly different

#------------------------------------------------------------------------------#

# IchawayGA

# Check normality of data
shapiro.test(IchawayGA_data$WB_annual_total_aet)  # normal
shapiro.test(IchawayGA_data$RS_annual_total_aet)  # normal

# Test for equality of variances
var.test(IchawayGA_data$WB_annual_total_aet,
         IchawayGA_data$RS_annual_total_aet)  # p < 0 0.5, reject HO, variances are not equal

# Independent samples test; paired = FALSE since variances are unequal
t.test(IchawayGA_data$WB_annual_total_aet,
       IchawayGA_data$RS_annual_total_aet,
       paired = FALSE)                      # p < 0.05, reject HO, means are significantly different


################################################################################

# Average water balance ET

mean(OysterNH_data2$WB_annual_total_aet)
mean(WappingerNY_data2$WB_annual_total_aet)
mean(BrandywinePA_data$WB_annual_total_aet)
mean(MechumsVA_data$WB_annual_total_aet)
mean(FlatNC_data$WB_annual_total_aet)
mean(NorthForkSC_data$WB_annual_total_aet)
mean(IchawayGA_data$WB_annual_total_aet)
