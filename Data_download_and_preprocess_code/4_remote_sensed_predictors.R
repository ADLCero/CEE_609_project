
# DATA DOWNLOAD AND PRE-PROCESS CODE

################################################################################

# REMOTE-SENSED PREDICTORS

# IMPORTANT NOTE: This script will only work if the previous script on downloading watershed boundaries
# have been ran.


# Source: TerraClimate: Monthly Climate and Climatic Water Balance for Global 
# Terrestrial Surfaces, University of Idaho
# Reference: https://developers.google.com/earth-engine/datasets/catalog/IDAHO_EPSCOR_TERRACLIMATE#description

# "TerraClimate additionally produces monthly surface water balance datasets using 
# a water balance model that incorporates reference evapotranspiration, precipitation, 
# temperature, and interpolated plant extractable soil water capacity."

# The corresponding packages of the required libraries below may need to be 
# downloaded first using the install.packages("package") command or 
# by going to R Studio's Menu > Tools > Install packages

# LIBRARIES:        # not necessary to be re-ran since they have been loaded using the previous script

# library(tidyverse)
# library(rgee)      # Must be installed properly following: https://cran.r-project.org/web/packages/rgee/vignettes/rgee01.html
# library(sf)
# library(lubridate)

# Workflow reference:
# https://github.com/r-spatial/rgee

################################################################################

# FUNCTIONS:

# Assigning the water year to each date
# where: date = array/ column containing the date in YMD format produced using 
# lubridate package

# WaterYear <- function(date) {
#   ifelse (month(date) < 10, year(date), year(date) + 1)
# }

# Note: This function should already be available in the environment since it was used in a previous script

################################################################################

# Initialize the Earth Engine R API

# ee_Initialize() = needs to be only done once

################################################################################

# Oyster River, New Hampshire = OysterNH


# 1) PRECIPITATION ACCUMULATION

# Read the shapefile = no need to be ran if the shapefile is still in the environment

# OysterNH_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/OysterNH_ws/OysterNH.shp", quiet = TRUE)


# Map each image to extract the monthly precipitation accumulation
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pr")) %>% # Select only precipitation accumulation bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly precipitation accumulation values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

OysterNH_pr <- ee_extract(x = terraclimate, y = OysterNH_ws$geometry, sf = FALSE)

# Convert columns to rows

OysterNH_pr2 <- as.data.frame(t(OysterNH_pr))


# Convert row names into a column

OysterNH_pr2$time <- rownames(OysterNH_pr2)


# Remove the first row

OysterNH_pr2 <- as.data.frame(OysterNH_pr2[2:nrow(OysterNH_pr2), ])


# Rename column names

colnames(OysterNH_pr2) <- c("monthly_pr", "time")


# Make date column (assume that each month starts at 01)

OysterNH_pr2$time <- gsub('[X_pr]', '', OysterNH_pr2$time)  # removes unnecessary characters
OysterNH_pr2$date <- ym(OysterNH_pr2$time)


# Add water year

OysterNH_pr2$water_year <- WaterYear(OysterNH_pr2$date)


# Group by water year and summarize data

OysterNH_pr_summary <- OysterNH_pr2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pr = sum(monthly_pr, na.rm =TRUE),
            ave_monthly_pr = mean(monthly_pr, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 2) REFERENCE EVAPOTRANSPIRATION (mm, ASCE Penman-Montieth, pet)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pet")) %>% # Select only pet bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly pet values from the Terraclimate ImageCollection through ee_extract

OysterNH_pet <- ee_extract(x = terraclimate, y = OysterNH_ws$geometry, sf = FALSE)


# Convert columns to rows

OysterNH_pet2 <- as.data.frame(t(OysterNH_pet))


# Convert row names into a column

OysterNH_pet2$time <- rownames(OysterNH_pet2)


# Remove the first row

OysterNH_pet2 <- as.data.frame(OysterNH_pet2[2:nrow(OysterNH_pet2), ])


# Rename column names

colnames(OysterNH_pet2) <- c("monthly_pet", "time")


# Make date column (assume that each month starts at 01)

OysterNH_pet2$time <- gsub('[X_pet]', '', OysterNH_pet2$time)  # removes unnecessary characters
OysterNH_pet2$date <- ym(OysterNH_pet2$time)


# Add water year

OysterNH_pet2$water_year <- WaterYear(OysterNH_pet2$date)


# Group by water year and summarize data

OysterNH_pet_summary <- OysterNH_pet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pet = sum(monthly_pet, na.rm =TRUE),
            ave_monthly_pet = mean(monthly_pet, na.rm = TRUE))



#------------------------------------------------------------------------------#

# 3) SOIL MOISTURE (mm, derived using a one-dimensional soil water balance model)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("soil")) %>% # Select only soil moisture bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly soil moisture values from the Terraclimate ImageCollection through ee_extract

OysterNH_soil <- ee_extract(x = terraclimate, y = OysterNH_ws$geometry, sf = FALSE)


# Convert columns to rows

OysterNH_soil2 <- as.data.frame(t(OysterNH_soil))


# Convert row names into a column

OysterNH_soil2$time <- rownames(OysterNH_soil2)


# Remove the first row

OysterNH_soil2 <- as.data.frame(OysterNH_soil2[2:nrow(OysterNH_soil2), ])


# Rename column names

colnames(OysterNH_soil2) <- c("monthly_soil", "time")


# Make date column (assume that each month starts at 01)

OysterNH_soil2$time <- gsub('[X_soil]', '', OysterNH_soil2$time)  # removes unnecessary characters
OysterNH_soil2$date <- ym(OysterNH_soil2$time)


# Add water year

OysterNH_soil2$water_year <- WaterYear(OysterNH_soil2$date)


# Group by water year and summarize data

OysterNH_soil_summary <- OysterNH_soil2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_soil = sum(monthly_soil, na.rm =TRUE),
            ave_monthly_soil = mean(monthly_soil, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 4) MAXIMUM TEMPERATURE (deg C)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("tmmx")) %>% # Select only maximum temperature bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly maximum temperature values from the Terraclimate ImageCollection through ee_extract

OysterNH_tmax <- ee_extract(x = terraclimate, y = OysterNH_ws$geometry, sf = FALSE)


# Convert columns to rows

OysterNH_tmax2 <- as.data.frame(t(OysterNH_tmax))


# Convert row names into a column

OysterNH_tmax2$time <- rownames(OysterNH_tmax2)


# Remove the first row

OysterNH_tmax2 <- as.data.frame(OysterNH_tmax2[2:nrow(OysterNH_tmax2), ])


# Rename column names

colnames(OysterNH_tmax2) <- c("monthly_tmax", "time")


# Make date column (assume that each month starts at 01)

OysterNH_tmax2$time <- gsub('[X_tmax]', '', OysterNH_tmax2$time)  # removes unnecessary characters
OysterNH_tmax2$date <- ym(OysterNH_tmax2$time)


# Add water year

OysterNH_tmax2$water_year <- WaterYear(OysterNH_tmax2$date)


# Group by water year and summarize data

OysterNH_tmax_summary <- OysterNH_tmax2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_tmax = sum(monthly_tmax, na.rm =TRUE),
            ave_monthly_tmax = mean(monthly_tmax, na.rm = TRUE))


################################################################################

# Wappinger Creek, New York = WappingerNY


# 1) PRECIPITATION ACCUMULATION

# Read the shapefile = no need to be ran if the shapefile is still in the environment

# WappingerNY_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/WappingerNY_ws/WappingerNY.shp", quiet = TRUE)


# Map each image to extract the monthly precipitation accumulation
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pr")) %>% # Select only precipitation accumulation bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly precipitation accumulation values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

WappingerNY_pr <- ee_extract(x = terraclimate, y = WappingerNY_ws$geometry, sf = FALSE)

# Convert columns to rows

WappingerNY_pr2 <- as.data.frame(t(WappingerNY_pr))


# Convert row names into a column

WappingerNY_pr2$time <- rownames(WappingerNY_pr2)


# Remove the first row

WappingerNY_pr2 <- as.data.frame(WappingerNY_pr2[2:nrow(WappingerNY_pr2), ])


# Rename column names

colnames(WappingerNY_pr2) <- c("monthly_pr", "time")


# Make date column (assume that each month starts at 01)

WappingerNY_pr2$time <- gsub('[X_pr]', '', WappingerNY_pr2$time)  # removes unnecessary characters
WappingerNY_pr2$date <- ym(WappingerNY_pr2$time)


# Add water year

WappingerNY_pr2$water_year <- WaterYear(WappingerNY_pr2$date)


# Group by water year and summarize data

WappingerNY_pr_summary <- WappingerNY_pr2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pr = sum(monthly_pr, na.rm =TRUE),
            ave_monthly_pr = mean(monthly_pr, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 2) REFERENCE EVAPOTRANSPIRATION (mm, ASCE Penman-Montieth, pet)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pet")) %>% # Select only pet bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly pet values from the Terraclimate ImageCollection through ee_extract

WappingerNY_pet <- ee_extract(x = terraclimate, y = WappingerNY_ws$geometry, sf = FALSE)


# Convert columns to rows

WappingerNY_pet2 <- as.data.frame(t(WappingerNY_pet))


# Convert row names into a column

WappingerNY_pet2$time <- rownames(WappingerNY_pet2)


# Remove the first row

WappingerNY_pet2 <- as.data.frame(WappingerNY_pet2[2:nrow(WappingerNY_pet2), ])


# Rename column names

colnames(WappingerNY_pet2) <- c("monthly_pet", "time")


# Make date column (assume that each month starts at 01)

WappingerNY_pet2$time <- gsub('[X_pet]', '', WappingerNY_pet2$time)  # removes unnecessary characters
WappingerNY_pet2$date <- ym(WappingerNY_pet2$time)


# Add water year

WappingerNY_pet2$water_year <- WaterYear(WappingerNY_pet2$date)


# Group by water year and summarize data

WappingerNY_pet_summary <- WappingerNY_pet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pet = sum(monthly_pet, na.rm =TRUE),
            ave_monthly_pet = mean(monthly_pet, na.rm = TRUE))



#------------------------------------------------------------------------------#

# 3) SOIL MOISTURE (mm, derived using a one-dimensional soil water balance model)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("soil")) %>% # Select only soil moisture bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly soil moisture values from the Terraclimate ImageCollection through ee_extract

WappingerNY_soil <- ee_extract(x = terraclimate, y = WappingerNY_ws$geometry, sf = FALSE)


# Convert columns to rows

WappingerNY_soil2 <- as.data.frame(t(WappingerNY_soil))


# Convert row names into a column

WappingerNY_soil2$time <- rownames(WappingerNY_soil2)


# Remove the first row

WappingerNY_soil2 <- as.data.frame(WappingerNY_soil2[2:nrow(WappingerNY_soil2), ])


# Rename column names

colnames(WappingerNY_soil2) <- c("monthly_soil", "time")


# Make date column (assume that each month starts at 01)

WappingerNY_soil2$time <- gsub('[X_soil]', '', WappingerNY_soil2$time)  # removes unnecessary characters
WappingerNY_soil2$date <- ym(WappingerNY_soil2$time)


# Add water year

WappingerNY_soil2$water_year <- WaterYear(WappingerNY_soil2$date)


# Group by water year and summarize data

WappingerNY_soil_summary <- WappingerNY_soil2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_soil = sum(monthly_soil, na.rm =TRUE),
            ave_monthly_soil = mean(monthly_soil, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 4) MAXIMUM TEMPERATURE (deg C)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("tmmx")) %>% # Select only maximum temperature bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly maximum temperature values from the Terraclimate ImageCollection through ee_extract

WappingerNY_tmax <- ee_extract(x = terraclimate, y = WappingerNY_ws$geometry, sf = FALSE)


# Convert columns to rows

WappingerNY_tmax2 <- as.data.frame(t(WappingerNY_tmax))


# Convert row names into a column

WappingerNY_tmax2$time <- rownames(WappingerNY_tmax2)


# Remove the first row

WappingerNY_tmax2 <- as.data.frame(WappingerNY_tmax2[2:nrow(WappingerNY_tmax2), ])


# Rename column names

colnames(WappingerNY_tmax2) <- c("monthly_tmax", "time")


# Make date column (assume that each month starts at 01)

WappingerNY_tmax2$time <- gsub('[X_tmax]', '', WappingerNY_tmax2$time)  # removes unnecessary characters
WappingerNY_tmax2$date <- ym(WappingerNY_tmax2$time)


# Add water year

WappingerNY_tmax2$water_year <- WaterYear(WappingerNY_tmax2$date)


# Group by water year and summarize data

WappingerNY_tmax_summary <- WappingerNY_tmax2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_tmax = sum(monthly_tmax, na.rm =TRUE),
            ave_monthly_tmax = mean(monthly_tmax, na.rm = TRUE))


################################################################################

# Brandywine Creek, Pennsylvania = BrandywinePA

# 1) PRECIPITATION ACCUMULATION

# Read the shapefile = no need to be ran if the shapefile is still in the environment

# BrandywinePA_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/BrandywinePA_ws/BrandywinePA.shp", quiet = TRUE)


# Map each image to extract the monthly precipitation accumulation
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pr")) %>% # Select only precipitation accumulation bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly precipitation accumulation values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

BrandywinePA_pr <- ee_extract(x = terraclimate, y = BrandywinePA_ws$geometry, sf = FALSE)

# Convert columns to rows

BrandywinePA_pr2 <- as.data.frame(t(BrandywinePA_pr))


# Convert row names into a column

BrandywinePA_pr2$time <- rownames(BrandywinePA_pr2)


# Remove the first row

BrandywinePA_pr2 <- as.data.frame(BrandywinePA_pr2[2:nrow(BrandywinePA_pr2), ])


# Rename column names

colnames(BrandywinePA_pr2) <- c("monthly_pr", "time")


# Make date column (assume that each month starts at 01)

BrandywinePA_pr2$time <- gsub('[X_pr]', '', BrandywinePA_pr2$time)  # removes unnecessary characters
BrandywinePA_pr2$date <- ym(BrandywinePA_pr2$time)


# Add water year

BrandywinePA_pr2$water_year <- WaterYear(BrandywinePA_pr2$date)


# Group by water year and summarize data

BrandywinePA_pr_summary <- BrandywinePA_pr2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pr = sum(monthly_pr, na.rm =TRUE),
            ave_monthly_pr = mean(monthly_pr, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 2) REFERENCE EVAPOTRANSPIRATION (mm, ASCE Penman-Montieth, pet)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pet")) %>% # Select only pet bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly pet values from the Terraclimate ImageCollection through ee_extract

BrandywinePA_pet <- ee_extract(x = terraclimate, y = BrandywinePA_ws$geometry, sf = FALSE)


# Convert columns to rows

BrandywinePA_pet2 <- as.data.frame(t(BrandywinePA_pet))


# Convert row names into a column

BrandywinePA_pet2$time <- rownames(BrandywinePA_pet2)


# Remove the first row

BrandywinePA_pet2 <- as.data.frame(BrandywinePA_pet2[2:nrow(BrandywinePA_pet2), ])


# Rename column names

colnames(BrandywinePA_pet2) <- c("monthly_pet", "time")


# Make date column (assume that each month starts at 01)

BrandywinePA_pet2$time <- gsub('[X_pet]', '', BrandywinePA_pet2$time)  # removes unnecessary characters
BrandywinePA_pet2$date <- ym(BrandywinePA_pet2$time)


# Add water year

BrandywinePA_pet2$water_year <- WaterYear(BrandywinePA_pet2$date)


# Group by water year and summarize data

BrandywinePA_pet_summary <- BrandywinePA_pet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pet = sum(monthly_pet, na.rm =TRUE),
            ave_monthly_pet = mean(monthly_pet, na.rm = TRUE))



#------------------------------------------------------------------------------#

# 3) SOIL MOISTURE (mm, derived using a one-dimensional soil water balance model)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("soil")) %>% # Select only soil moisture bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly soil moisture values from the Terraclimate ImageCollection through ee_extract

BrandywinePA_soil <- ee_extract(x = terraclimate, y = BrandywinePA_ws$geometry, sf = FALSE)


# Convert columns to rows

BrandywinePA_soil2 <- as.data.frame(t(BrandywinePA_soil))


# Convert row names into a column

BrandywinePA_soil2$time <- rownames(BrandywinePA_soil2)


# Remove the first row

BrandywinePA_soil2 <- as.data.frame(BrandywinePA_soil2[2:nrow(BrandywinePA_soil2), ])


# Rename column names

colnames(BrandywinePA_soil2) <- c("monthly_soil", "time")


# Make date column (assume that each month starts at 01)

BrandywinePA_soil2$time <- gsub('[X_soil]', '', BrandywinePA_soil2$time)  # removes unnecessary characters
BrandywinePA_soil2$date <- ym(BrandywinePA_soil2$time)


# Add water year

BrandywinePA_soil2$water_year <- WaterYear(BrandywinePA_soil2$date)


# Group by water year and summarize data

BrandywinePA_soil_summary <- BrandywinePA_soil2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_soil = sum(monthly_soil, na.rm =TRUE),
            ave_monthly_soil = mean(monthly_soil, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 4) MAXIMUM TEMPERATURE (deg C)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("tmmx")) %>% # Select only maximum temperature bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly maximum temperature values from the Terraclimate ImageCollection through ee_extract

BrandywinePA_tmax <- ee_extract(x = terraclimate, y = BrandywinePA_ws$geometry, sf = FALSE)


# Convert columns to rows

BrandywinePA_tmax2 <- as.data.frame(t(BrandywinePA_tmax))


# Convert row names into a column

BrandywinePA_tmax2$time <- rownames(BrandywinePA_tmax2)


# Remove the first row

BrandywinePA_tmax2 <- as.data.frame(BrandywinePA_tmax2[2:nrow(BrandywinePA_tmax2), ])


# Rename column names

colnames(BrandywinePA_tmax2) <- c("monthly_tmax", "time")


# Make date column (assume that each month starts at 01)

BrandywinePA_tmax2$time <- gsub('[X_tmax]', '', BrandywinePA_tmax2$time)  # removes unnecessary characters
BrandywinePA_tmax2$date <- ym(BrandywinePA_tmax2$time)


# Add water year

BrandywinePA_tmax2$water_year <- WaterYear(BrandywinePA_tmax2$date)


# Group by water year and summarize data

BrandywinePA_tmax_summary <- BrandywinePA_tmax2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_tmax = sum(monthly_tmax, na.rm =TRUE),
            ave_monthly_tmax = mean(monthly_tmax, na.rm = TRUE))


################################################################################

# Mechums River, Virginia = MechumsVA


# 1) PRECIPITATION ACCUMULATION

# Read the shapefile = no need to be ran if the shapefile is still in the environment

# MechumsVA_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/MechumsVA_ws/MechumsVA.shp", quiet = TRUE)


# Map each image to extract the monthly precipitation accumulation
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pr")) %>% # Select only precipitation accumulation bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly precipitation accumulation values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

MechumsVA_pr <- ee_extract(x = terraclimate, y = MechumsVA_ws$geometry, sf = FALSE)

# Convert columns to rows

MechumsVA_pr2 <- as.data.frame(t(MechumsVA_pr))


# Convert row names into a column

MechumsVA_pr2$time <- rownames(MechumsVA_pr2)


# Remove the first row

MechumsVA_pr2 <- as.data.frame(MechumsVA_pr2[2:nrow(MechumsVA_pr2), ])


# Rename column names

colnames(MechumsVA_pr2) <- c("monthly_pr", "time")


# Make date column (assume that each month starts at 01)

MechumsVA_pr2$time <- gsub('[X_pr]', '', MechumsVA_pr2$time)  # removes unnecessary characters
MechumsVA_pr2$date <- ym(MechumsVA_pr2$time)


# Add water year

MechumsVA_pr2$water_year <- WaterYear(MechumsVA_pr2$date)


# Group by water year and summarize data

MechumsVA_pr_summary <- MechumsVA_pr2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pr = sum(monthly_pr, na.rm =TRUE),
            ave_monthly_pr = mean(monthly_pr, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 2) REFERENCE EVAPOTRANSPIRATION (mm, ASCE Penman-Montieth, pet)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pet")) %>% # Select only pet bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly pet values from the Terraclimate ImageCollection through ee_extract

MechumsVA_pet <- ee_extract(x = terraclimate, y = MechumsVA_ws$geometry, sf = FALSE)


# Convert columns to rows

MechumsVA_pet2 <- as.data.frame(t(MechumsVA_pet))


# Convert row names into a column

MechumsVA_pet2$time <- rownames(MechumsVA_pet2)


# Remove the first row

MechumsVA_pet2 <- as.data.frame(MechumsVA_pet2[2:nrow(MechumsVA_pet2), ])


# Rename column names

colnames(MechumsVA_pet2) <- c("monthly_pet", "time")


# Make date column (assume that each month starts at 01)

MechumsVA_pet2$time <- gsub('[X_pet]', '', MechumsVA_pet2$time)  # removes unnecessary characters
MechumsVA_pet2$date <- ym(MechumsVA_pet2$time)


# Add water year

MechumsVA_pet2$water_year <- WaterYear(MechumsVA_pet2$date)


# Group by water year and summarize data

MechumsVA_pet_summary <- MechumsVA_pet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pet = sum(monthly_pet, na.rm =TRUE),
            ave_monthly_pet = mean(monthly_pet, na.rm = TRUE))



#------------------------------------------------------------------------------#

# 3) SOIL MOISTURE (mm, derived using a one-dimensional soil water balance model)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("soil")) %>% # Select only soil moisture bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly soil moisture values from the Terraclimate ImageCollection through ee_extract

MechumsVA_soil <- ee_extract(x = terraclimate, y = MechumsVA_ws$geometry, sf = FALSE)


# Convert columns to rows

MechumsVA_soil2 <- as.data.frame(t(MechumsVA_soil))


# Convert row names into a column

MechumsVA_soil2$time <- rownames(MechumsVA_soil2)


# Remove the first row

MechumsVA_soil2 <- as.data.frame(MechumsVA_soil2[2:nrow(MechumsVA_soil2), ])


# Rename column names

colnames(MechumsVA_soil2) <- c("monthly_soil", "time")


# Make date column (assume that each month starts at 01)

MechumsVA_soil2$time <- gsub('[X_soil]', '', MechumsVA_soil2$time)  # removes unnecessary characters
MechumsVA_soil2$date <- ym(MechumsVA_soil2$time)


# Add water year

MechumsVA_soil2$water_year <- WaterYear(MechumsVA_soil2$date)


# Group by water year and summarize data

MechumsVA_soil_summary <- MechumsVA_soil2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_soil = sum(monthly_soil, na.rm =TRUE),
            ave_monthly_soil = mean(monthly_soil, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 4) MAXIMUM TEMPERATURE (deg C)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("tmmx")) %>% # Select only maximum temperature bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly maximum temperature values from the Terraclimate ImageCollection through ee_extract

MechumsVA_tmax <- ee_extract(x = terraclimate, y = MechumsVA_ws$geometry, sf = FALSE)


# Convert columns to rows

MechumsVA_tmax2 <- as.data.frame(t(MechumsVA_tmax))


# Convert row names into a column

MechumsVA_tmax2$time <- rownames(MechumsVA_tmax2)


# Remove the first row

MechumsVA_tmax2 <- as.data.frame(MechumsVA_tmax2[2:nrow(MechumsVA_tmax2), ])


# Rename column names

colnames(MechumsVA_tmax2) <- c("monthly_tmax", "time")


# Make date column (assume that each month starts at 01)

MechumsVA_tmax2$time <- gsub('[X_tmax]', '', MechumsVA_tmax2$time)  # removes unnecessary characters
MechumsVA_tmax2$date <- ym(MechumsVA_tmax2$time)


# Add water year

MechumsVA_tmax2$water_year <- WaterYear(MechumsVA_tmax2$date)


# Group by water year and summarize data

MechumsVA_tmax_summary <- MechumsVA_tmax2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_tmax = sum(monthly_tmax, na.rm =TRUE),
            ave_monthly_tmax = mean(monthly_tmax, na.rm = TRUE))


################################################################################

# Flat River, North Carolina = FlatNC

# 1) PRECIPITATION ACCUMULATION

# Read the shapefile = no need to be ran if the shapefile is still in the environment

# FlatNC_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/FlatNC_ws/FlatNC.shp", quiet = TRUE)


# Map each image to extract the monthly precipitation accumulation
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pr")) %>% # Select only precipitation accumulation bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly precipitation accumulation values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

FlatNC_pr <- ee_extract(x = terraclimate, y = FlatNC_ws$geometry, sf = FALSE)

# Convert columns to rows

FlatNC_pr2 <- as.data.frame(t(FlatNC_pr))


# Convert row names into a column

FlatNC_pr2$time <- rownames(FlatNC_pr2)


# Remove the first row

FlatNC_pr2 <- as.data.frame(FlatNC_pr2[2:nrow(FlatNC_pr2), ])


# Rename column names

colnames(FlatNC_pr2) <- c("monthly_pr", "time")


# Make date column (assume that each month starts at 01)

FlatNC_pr2$time <- gsub('[X_pr]', '', FlatNC_pr2$time)  # removes unnecessary characters
FlatNC_pr2$date <- ym(FlatNC_pr2$time)


# Add water year

FlatNC_pr2$water_year <- WaterYear(FlatNC_pr2$date)


# Group by water year and summarize data

FlatNC_pr_summary <- FlatNC_pr2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pr = sum(monthly_pr, na.rm =TRUE),
            ave_monthly_pr = mean(monthly_pr, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 2) REFERENCE EVAPOTRANSPIRATION (mm, ASCE Penman-Montieth, pet)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pet")) %>% # Select only pet bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly pet values from the Terraclimate ImageCollection through ee_extract

FlatNC_pet <- ee_extract(x = terraclimate, y = FlatNC_ws$geometry, sf = FALSE)


# Convert columns to rows

FlatNC_pet2 <- as.data.frame(t(FlatNC_pet))


# Convert row names into a column

FlatNC_pet2$time <- rownames(FlatNC_pet2)


# Remove the first row

FlatNC_pet2 <- as.data.frame(FlatNC_pet2[2:nrow(FlatNC_pet2), ])


# Rename column names

colnames(FlatNC_pet2) <- c("monthly_pet", "time")


# Make date column (assume that each month starts at 01)

FlatNC_pet2$time <- gsub('[X_pet]', '', FlatNC_pet2$time)  # removes unnecessary characters
FlatNC_pet2$date <- ym(FlatNC_pet2$time)


# Add water year

FlatNC_pet2$water_year <- WaterYear(FlatNC_pet2$date)


# Group by water year and summarize data

FlatNC_pet_summary <- FlatNC_pet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pet = sum(monthly_pet, na.rm =TRUE),
            ave_monthly_pet = mean(monthly_pet, na.rm = TRUE))



#------------------------------------------------------------------------------#

# 3) SOIL MOISTURE (mm, derived using a one-dimensional soil water balance model)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("soil")) %>% # Select only soil moisture bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly soil moisture values from the Terraclimate ImageCollection through ee_extract

FlatNC_soil <- ee_extract(x = terraclimate, y = FlatNC_ws$geometry, sf = FALSE)


# Convert columns to rows

FlatNC_soil2 <- as.data.frame(t(FlatNC_soil))


# Convert row names into a column

FlatNC_soil2$time <- rownames(FlatNC_soil2)


# Remove the first row

FlatNC_soil2 <- as.data.frame(FlatNC_soil2[2:nrow(FlatNC_soil2), ])


# Rename column names

colnames(FlatNC_soil2) <- c("monthly_soil", "time")


# Make date column (assume that each month starts at 01)

FlatNC_soil2$time <- gsub('[X_soil]', '', FlatNC_soil2$time)  # removes unnecessary characters
FlatNC_soil2$date <- ym(FlatNC_soil2$time)


# Add water year

FlatNC_soil2$water_year <- WaterYear(FlatNC_soil2$date)


# Group by water year and summarize data

FlatNC_soil_summary <- FlatNC_soil2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_soil = sum(monthly_soil, na.rm =TRUE),
            ave_monthly_soil = mean(monthly_soil, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 4) MAXIMUM TEMPERATURE (deg C)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("tmmx")) %>% # Select only maximum temperature bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly maximum temperature values from the Terraclimate ImageCollection through ee_extract

FlatNC_tmax <- ee_extract(x = terraclimate, y = FlatNC_ws$geometry, sf = FALSE)


# Convert columns to rows

FlatNC_tmax2 <- as.data.frame(t(FlatNC_tmax))


# Convert row names into a column

FlatNC_tmax2$time <- rownames(FlatNC_tmax2)


# Remove the first row

FlatNC_tmax2 <- as.data.frame(FlatNC_tmax2[2:nrow(FlatNC_tmax2), ])


# Rename column names

colnames(FlatNC_tmax2) <- c("monthly_tmax", "time")


# Make date column (assume that each month starts at 01)

FlatNC_tmax2$time <- gsub('[X_tmax]', '', FlatNC_tmax2$time)  # removes unnecessary characters
FlatNC_tmax2$date <- ym(FlatNC_tmax2$time)


# Add water year

FlatNC_tmax2$water_year <- WaterYear(FlatNC_tmax2$date)


# Group by water year and summarize data

FlatNC_tmax_summary <- FlatNC_tmax2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_tmax = sum(monthly_tmax, na.rm =TRUE),
            ave_monthly_tmax = mean(monthly_tmax, na.rm = TRUE))



################################################################################

# North Fork Edisto, South Carolina = NorthForkSC

# 1) PRECIPITATION ACCUMULATION

# Read the shapefile = no need to be ran if the shapefile is still in the environment

# NorthForkSC_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/NorthForkSC_ws/NorthForkSC.shp", quiet = TRUE)


# Map each image to extract the monthly precipitation accumulation
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pr")) %>% # Select only precipitation accumulation bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly precipitation accumulation values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

NorthForkSC_pr <- ee_extract(x = terraclimate, y = NorthForkSC_ws$geometry, sf = FALSE)

# Convert columns to rows

NorthForkSC_pr2 <- as.data.frame(t(NorthForkSC_pr))


# Convert row names into a column

NorthForkSC_pr2$time <- rownames(NorthForkSC_pr2)


# Remove the first row

NorthForkSC_pr2 <- as.data.frame(NorthForkSC_pr2[2:nrow(NorthForkSC_pr2), ])


# Rename column names

colnames(NorthForkSC_pr2) <- c("monthly_pr", "time")


# Make date column (assume that each month starts at 01)

NorthForkSC_pr2$time <- gsub('[X_pr]', '', NorthForkSC_pr2$time)  # removes unnecessary characters
NorthForkSC_pr2$date <- ym(NorthForkSC_pr2$time)


# Add water year

NorthForkSC_pr2$water_year <- WaterYear(NorthForkSC_pr2$date)


# Group by water year and summarize data

NorthForkSC_pr_summary <- NorthForkSC_pr2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pr = sum(monthly_pr, na.rm =TRUE),
            ave_monthly_pr = mean(monthly_pr, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 2) REFERENCE EVAPOTRANSPIRATION (mm, ASCE Penman-Montieth, pet)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pet")) %>% # Select only pet bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly pet values from the Terraclimate ImageCollection through ee_extract

NorthForkSC_pet <- ee_extract(x = terraclimate, y = NorthForkSC_ws$geometry, sf = FALSE)


# Convert columns to rows

NorthForkSC_pet2 <- as.data.frame(t(NorthForkSC_pet))


# Convert row names into a column

NorthForkSC_pet2$time <- rownames(NorthForkSC_pet2)


# Remove the first row

NorthForkSC_pet2 <- as.data.frame(NorthForkSC_pet2[2:nrow(NorthForkSC_pet2), ])


# Rename column names

colnames(NorthForkSC_pet2) <- c("monthly_pet", "time")


# Make date column (assume that each month starts at 01)

NorthForkSC_pet2$time <- gsub('[X_pet]', '', NorthForkSC_pet2$time)  # removes unnecessary characters
NorthForkSC_pet2$date <- ym(NorthForkSC_pet2$time)


# Add water year

NorthForkSC_pet2$water_year <- WaterYear(NorthForkSC_pet2$date)


# Group by water year and summarize data

NorthForkSC_pet_summary <- NorthForkSC_pet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pet = sum(monthly_pet, na.rm =TRUE),
            ave_monthly_pet = mean(monthly_pet, na.rm = TRUE))



#------------------------------------------------------------------------------#

# 3) SOIL MOISTURE (mm, derived using a one-dimensional soil water balance model)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("soil")) %>% # Select only soil moisture bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly soil moisture values from the Terraclimate ImageCollection through ee_extract

NorthForkSC_soil <- ee_extract(x = terraclimate, y = NorthForkSC_ws$geometry, sf = FALSE)


# Convert columns to rows

NorthForkSC_soil2 <- as.data.frame(t(NorthForkSC_soil))


# Convert row names into a column

NorthForkSC_soil2$time <- rownames(NorthForkSC_soil2)


# Remove the first row

NorthForkSC_soil2 <- as.data.frame(NorthForkSC_soil2[2:nrow(NorthForkSC_soil2), ])


# Rename column names

colnames(NorthForkSC_soil2) <- c("monthly_soil", "time")


# Make date column (assume that each month starts at 01)

NorthForkSC_soil2$time <- gsub('[X_soil]', '', NorthForkSC_soil2$time)  # removes unnecessary characters
NorthForkSC_soil2$date <- ym(NorthForkSC_soil2$time)


# Add water year

NorthForkSC_soil2$water_year <- WaterYear(NorthForkSC_soil2$date)


# Group by water year and summarize data

NorthForkSC_soil_summary <- NorthForkSC_soil2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_soil = sum(monthly_soil, na.rm =TRUE),
            ave_monthly_soil = mean(monthly_soil, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 4) MAXIMUM TEMPERATURE (deg C)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("tmmx")) %>% # Select only maximum temperature bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly maximum temperature values from the Terraclimate ImageCollection through ee_extract

NorthForkSC_tmax <- ee_extract(x = terraclimate, y = NorthForkSC_ws$geometry, sf = FALSE)


# Convert columns to rows

NorthForkSC_tmax2 <- as.data.frame(t(NorthForkSC_tmax))


# Convert row names into a column

NorthForkSC_tmax2$time <- rownames(NorthForkSC_tmax2)


# Remove the first row

NorthForkSC_tmax2 <- as.data.frame(NorthForkSC_tmax2[2:nrow(NorthForkSC_tmax2), ])


# Rename column names

colnames(NorthForkSC_tmax2) <- c("monthly_tmax", "time")


# Make date column (assume that each month starts at 01)

NorthForkSC_tmax2$time <- gsub('[X_tmax]', '', NorthForkSC_tmax2$time)  # removes unnecessary characters
NorthForkSC_tmax2$date <- ym(NorthForkSC_tmax2$time)


# Add water year

NorthForkSC_tmax2$water_year <- WaterYear(NorthForkSC_tmax2$date)


# Group by water year and summarize data

NorthForkSC_tmax_summary <- NorthForkSC_tmax2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_tmax = sum(monthly_tmax, na.rm =TRUE),
            ave_monthly_tmax = mean(monthly_tmax, na.rm = TRUE))



################################################################################

# Ichawaynochaway, Georgia = IchawayGA

# 1) PRECIPITATION ACCUMULATION

# Read the shapefile = no need to be ran if the shapefile is still in the environment

# IchawayGA_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/IchawayGA_ws/IchawayGA.shp", quiet = TRUE)


# Map each image to extract the monthly precipitation accumulation
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pr")) %>% # Select only precipitation accumulation bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly precipitation accumulation values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

IchawayGA_pr <- ee_extract(x = terraclimate, y = IchawayGA_ws$geometry, sf = FALSE)

# Convert columns to rows

IchawayGA_pr2 <- as.data.frame(t(IchawayGA_pr))


# Convert row names into a column

IchawayGA_pr2$time <- rownames(IchawayGA_pr2)


# Remove the first row

IchawayGA_pr2 <- as.data.frame(IchawayGA_pr2[2:nrow(IchawayGA_pr2), ])


# Rename column names

colnames(IchawayGA_pr2) <- c("monthly_pr", "time")


# Make date column (assume that each month starts at 01)

IchawayGA_pr2$time <- gsub('[X_pr]', '', IchawayGA_pr2$time)  # removes unnecessary characters
IchawayGA_pr2$date <- ym(IchawayGA_pr2$time)


# Add water year

IchawayGA_pr2$water_year <- WaterYear(IchawayGA_pr2$date)


# Group by water year and summarize data

IchawayGA_pr_summary <- IchawayGA_pr2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pr = sum(monthly_pr, na.rm =TRUE),
            ave_monthly_pr = mean(monthly_pr, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 2) REFERENCE EVAPOTRANSPIRATION (mm, ASCE Penman-Montieth, pet)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("pet")) %>% # Select only pet bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly pet values from the Terraclimate ImageCollection through ee_extract

IchawayGA_pet <- ee_extract(x = terraclimate, y = IchawayGA_ws$geometry, sf = FALSE)


# Convert columns to rows

IchawayGA_pet2 <- as.data.frame(t(IchawayGA_pet))


# Convert row names into a column

IchawayGA_pet2$time <- rownames(IchawayGA_pet2)


# Remove the first row

IchawayGA_pet2 <- as.data.frame(IchawayGA_pet2[2:nrow(IchawayGA_pet2), ])


# Rename column names

colnames(IchawayGA_pet2) <- c("monthly_pet", "time")


# Make date column (assume that each month starts at 01)

IchawayGA_pet2$time <- gsub('[X_pet]', '', IchawayGA_pet2$time)  # removes unnecessary characters
IchawayGA_pet2$date <- ym(IchawayGA_pet2$time)


# Add water year

IchawayGA_pet2$water_year <- WaterYear(IchawayGA_pet2$date)


# Group by water year and summarize data

IchawayGA_pet_summary <- IchawayGA_pet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_pet = sum(monthly_pet, na.rm =TRUE),
            ave_monthly_pet = mean(monthly_pet, na.rm = TRUE))



#------------------------------------------------------------------------------#

# 3) SOIL MOISTURE (mm, derived using a one-dimensional soil water balance model)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("soil")) %>% # Select only soil moisture bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly soil moisture values from the Terraclimate ImageCollection through ee_extract

IchawayGA_soil <- ee_extract(x = terraclimate, y = IchawayGA_ws$geometry, sf = FALSE)


# Convert columns to rows

IchawayGA_soil2 <- as.data.frame(t(IchawayGA_soil))


# Convert row names into a column

IchawayGA_soil2$time <- rownames(IchawayGA_soil2)


# Remove the first row

IchawayGA_soil2 <- as.data.frame(IchawayGA_soil2[2:nrow(IchawayGA_soil2), ])


# Rename column names

colnames(IchawayGA_soil2) <- c("monthly_soil", "time")


# Make date column (assume that each month starts at 01)

IchawayGA_soil2$time <- gsub('[X_soil]', '', IchawayGA_soil2$time)  # removes unnecessary characters
IchawayGA_soil2$date <- ym(IchawayGA_soil2$time)


# Add water year

IchawayGA_soil2$water_year <- WaterYear(IchawayGA_soil2$date)


# Group by water year and summarize data

IchawayGA_soil_summary <- IchawayGA_soil2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_soil = sum(monthly_soil, na.rm =TRUE),
            ave_monthly_soil = mean(monthly_soil, na.rm = TRUE))


#------------------------------------------------------------------------------#

# 4) MAXIMUM TEMPERATURE (deg C)

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("tmmx")) %>% # Select only maximum temperature bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly maximum temperature values from the Terraclimate ImageCollection through ee_extract

IchawayGA_tmax <- ee_extract(x = terraclimate, y = IchawayGA_ws$geometry, sf = FALSE)


# Convert columns to rows

IchawayGA_tmax2 <- as.data.frame(t(IchawayGA_tmax))


# Convert row names into a column

IchawayGA_tmax2$time <- rownames(IchawayGA_tmax2)


# Remove the first row

IchawayGA_tmax2 <- as.data.frame(IchawayGA_tmax2[2:nrow(IchawayGA_tmax2), ])


# Rename column names

colnames(IchawayGA_tmax2) <- c("monthly_tmax", "time")


# Make date column (assume that each month starts at 01)

IchawayGA_tmax2$time <- gsub('[X_tmax]', '', IchawayGA_tmax2$time)  # removes unnecessary characters
IchawayGA_tmax2$date <- ym(IchawayGA_tmax2$time)


# Add water year

IchawayGA_tmax2$water_year <- WaterYear(IchawayGA_tmax2$date)


# Group by water year and summarize data

IchawayGA_tmax_summary <- IchawayGA_tmax2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_tmax = sum(monthly_tmax, na.rm =TRUE),
            ave_monthly_tmax = mean(monthly_tmax, na.rm = TRUE))

