
# MODEL TRAINING AND VALIDATION

# Other statistical tests

################################################################################

# Since data has been imported to .csv files, data from previous scripts can now be cleared
# from the environment
rm(list = ls())

################################################################################

# Read in data

OysterNH_data <- read.csv("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/OysterNH_data.csv", header = T)
