
# DATA DOWNLOAD AND PRE-PROCESS CODE

################################################################################

# REMOTE-SENSED PREDICTORS - NDVI

# IMPORTANT NOTE: This script will only work if the previous script on downloading watershed boundaries
# have been ran and they are still in the environment. Otherwise, the watershed shapefiles have to be re-read in.


# Sources:

# For years 1989-10-01 to 2000-09-30 = MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km
# https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD13A2#bands

# For years 2000-10-01 to 2020-09-30 = Landsat 5 TM Collection 1 Tier 1 8-Day NDVI Composite
# https://developers.google.com/earth-engine/datasets/catalog/LANDSAT_LT05_C01_T1_8DAY_NDVI

# Alternative source: Landsat 5 TM Collection 1 Tier 1 32-Day NDVI Composite
# https://developers.google.com/earth-engine/datasets/catalog/LANDSAT_LT05_C01_T1_32DAY_NDVI#bands

# The corresponding packages of the required libraries below may need to be 
# downloaded first using the install.packages("package") command or 
# by going to R Studio's Menu > Tools > Install packages

# LIBRARIES:        # not necessary to be re-ran since they have been loaded using the previous script

library(tidyverse)
library(rgee)      # Must be installed properly following: https://cran.r-project.org/web/packages/rgee/vignettes/rgee01.html
library(sf)
library(lubridate)

# Workflow reference:
# https://github.com/r-spatial/rgee

################################################################################

# FUNCTIONS:

# Assigning the water year to each date
# where: date = array/ column containing the date in YMD format produced using 
# lubridate package

WaterYear <- function(date) {
  ifelse (month(date) < 10, year(date), year(date) + 1)
}

# Note: This function should already be available in the environment since it was used in a previous script

################################################################################

# Initialize the Earth Engine R API

# ee_Initialize() = needs to be only done once

################################################################################


# Oyster River, New Hampshire = OysterNH

# PERIOD: 1980-10-01 to 2000-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_1 <- ee$ImageCollection("LANDSAT/LT05/C01/T1_8DAY_NDVI") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2000-09-30") %>%
  # ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

OysterNH_NDVI1 <- ee_extract(x = NDVI_1, y = OysterNH_ws$geometry, sf = FALSE)


# Convert columns to rows

OysterNH_NDVI2 <- as.data.frame(t(OysterNH_NDVI1))


# Convert row names into a column

OysterNH_NDVI2$time <- rownames(OysterNH_NDVI2)


# Remove the first row

OysterNH_NDVI2 <- as.data.frame(OysterNH_NDVI2[2:nrow(OysterNH_NDVI2), ])


# Rename column names

colnames(OysterNH_NDVI2) <- c("NDVI", "time")


# Make date column

OysterNH_NDVI2$time <- gsub('[X_NDVI]', '', OysterNH_NDVI2$time)  # removes unnecessary characters
OysterNH_NDVI2$date <- ymd(OysterNH_NDVI2$time)


# Add water year

OysterNH_NDVI2$water_year <- WaterYear(OysterNH_NDVI2$date)


#------------------------------------------------------------------------------#

# PERIOD: 2000-10-01 to 2020-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_2 <- ee$ImageCollection("MODIS/006/MOD13A2") %>%
  ee$ImageCollection$filterDate("2000-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

OysterNH_NDVI3 <- ee_extract(x = NDVI_2, y = OysterNH_ws$geometry, sf = FALSE)


# Convert columns to rows

OysterNH_NDVI4 <- as.data.frame(t(OysterNH_NDVI3))


# Convert row names into a column

OysterNH_NDVI4$time <- rownames(OysterNH_NDVI4)


# Remove the first row

OysterNH_NDVI4 <- as.data.frame(OysterNH_NDVI4[2:nrow(OysterNH_NDVI4), ])


# Rename column names

colnames(OysterNH_NDVI4) <- c("NDVI", "time")


# Make date column

OysterNH_NDVI4$time <- gsub('[X_NDVI]', '', OysterNH_NDVI4$time)  # removes unnecessary characters
OysterNH_NDVI4$date <- ymd(OysterNH_NDVI4$time)


# Adjust values of NDVI since MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km is at Scale = 0.0001

OysterNH_NDVI4$NDVI <- OysterNH_NDVI4$NDVI * 0.0001


# Add water year

OysterNH_NDVI4$water_year <- WaterYear(OysterNH_NDVI4$date)


#------------------------------------------------------------------------------#

# COMBINE THE TWO DATA FRAMES

OysterNH_NDVI <- bind_rows(OysterNH_NDVI2, OysterNH_NDVI4)


# Group by water year and summarize data

OysterNH_NDVI_summary <- OysterNH_NDVI %>% 
  group_by(water_year) %>% 
  summarize(ave_NDVI = mean(NDVI, na.rm =TRUE),
            max_NDVI = max(NDVI, na.rm = TRUE))


################################################################################

# Wappinger Creek, New York = WappingerNY


# PERIOD: 1980-10-01 to 2000-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_1 <- ee$ImageCollection("LANDSAT/LT05/C01/T1_8DAY_NDVI") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2000-09-30") %>%
  # ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

WappingerNY_NDVI1 <- ee_extract(x = NDVI_1, y = WappingerNY_ws$geometry, sf = FALSE)


# Convert columns to rows

WappingerNY_NDVI2 <- as.data.frame(t(WappingerNY_NDVI1))


# Convert row names into a column

WappingerNY_NDVI2$time <- rownames(WappingerNY_NDVI2)


# Remove the first row

WappingerNY_NDVI2 <- as.data.frame(WappingerNY_NDVI2[2:nrow(WappingerNY_NDVI2), ])


# Rename column names

colnames(WappingerNY_NDVI2) <- c("NDVI", "time")


# Make date column

WappingerNY_NDVI2$time <- gsub('[X_NDVI]', '', WappingerNY_NDVI2$time)  # removes unnecessary characters
WappingerNY_NDVI2$date <- ymd(WappingerNY_NDVI2$time)


# Add water year

WappingerNY_NDVI2$water_year <- WaterYear(WappingerNY_NDVI2$date)


#------------------------------------------------------------------------------#

# PERIOD: 2000-10-01 to 2020-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_2 <- ee$ImageCollection("MODIS/006/MOD13A2") %>%
  ee$ImageCollection$filterDate("2000-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

WappingerNY_NDVI3 <- ee_extract(x = NDVI_2, y = WappingerNY_ws$geometry, sf = FALSE)


# Convert columns to rows

WappingerNY_NDVI4 <- as.data.frame(t(WappingerNY_NDVI3))


# Convert row names into a column

WappingerNY_NDVI4$time <- rownames(WappingerNY_NDVI4)


# Remove the first row

WappingerNY_NDVI4 <- as.data.frame(WappingerNY_NDVI4[2:nrow(WappingerNY_NDVI4), ])


# Rename column names

colnames(WappingerNY_NDVI4) <- c("NDVI", "time")


# Make date column

WappingerNY_NDVI4$time <- gsub('[X_NDVI]', '', WappingerNY_NDVI4$time)  # removes unnecessary characters
WappingerNY_NDVI4$date <- ymd(WappingerNY_NDVI4$time)


# Adjust values of NDVI since MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km is at Scale = 0.0001

WappingerNY_NDVI4$NDVI <- WappingerNY_NDVI4$NDVI * 0.0001


# Add water year

WappingerNY_NDVI4$water_year <- WaterYear(WappingerNY_NDVI4$date)


#------------------------------------------------------------------------------#

# COMBINE THE TWO DATA FRAMES

WappingerNY_NDVI <- bind_rows(WappingerNY_NDVI2, WappingerNY_NDVI4)


# Group by water year and summarize data

WappingerNY_NDVI_summary <- WappingerNY_NDVI %>% 
  group_by(water_year) %>% 
  summarize(ave_NDVI = mean(NDVI, na.rm =TRUE),
            max_NDVI = max(NDVI, na.rm = TRUE))


################################################################################

# Brandywine Creek, Pennsylvania = BrandywinePA

# PERIOD: 1980-10-01 to 2000-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_1 <- ee$ImageCollection("LANDSAT/LT05/C01/T1_8DAY_NDVI") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2000-09-30") %>%
  # ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

BrandywinePA_NDVI1 <- ee_extract(x = NDVI_1, y = BrandywinePA_ws$geometry, sf = FALSE)


# Convert columns to rows

BrandywinePA_NDVI2 <- as.data.frame(t(BrandywinePA_NDVI1))


# Convert row names into a column

BrandywinePA_NDVI2$time <- rownames(BrandywinePA_NDVI2)


# Remove the first row

BrandywinePA_NDVI2 <- as.data.frame(BrandywinePA_NDVI2[2:nrow(BrandywinePA_NDVI2), ])


# Rename column names

colnames(BrandywinePA_NDVI2) <- c("NDVI", "time")


# Make date column

BrandywinePA_NDVI2$time <- gsub('[X_NDVI]', '', BrandywinePA_NDVI2$time)  # removes unnecessary characters
BrandywinePA_NDVI2$date <- ymd(BrandywinePA_NDVI2$time)


# Add water year

BrandywinePA_NDVI2$water_year <- WaterYear(BrandywinePA_NDVI2$date)


#------------------------------------------------------------------------------#

# PERIOD: 2000-10-01 to 2020-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_2 <- ee$ImageCollection("MODIS/006/MOD13A2") %>%
  ee$ImageCollection$filterDate("2000-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

BrandywinePA_NDVI3 <- ee_extract(x = NDVI_2, y = BrandywinePA_ws$geometry, sf = FALSE)


# Convert columns to rows

BrandywinePA_NDVI4 <- as.data.frame(t(BrandywinePA_NDVI3))


# Convert row names into a column

BrandywinePA_NDVI4$time <- rownames(BrandywinePA_NDVI4)


# Remove the first row

BrandywinePA_NDVI4 <- as.data.frame(BrandywinePA_NDVI4[2:nrow(BrandywinePA_NDVI4), ])


# Rename column names

colnames(BrandywinePA_NDVI4) <- c("NDVI", "time")


# Make date column

BrandywinePA_NDVI4$time <- gsub('[X_NDVI]', '', BrandywinePA_NDVI4$time)  # removes unnecessary characters
BrandywinePA_NDVI4$date <- ymd(BrandywinePA_NDVI4$time)


# Adjust values of NDVI since MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km is at Scale = 0.0001

BrandywinePA_NDVI4$NDVI <- BrandywinePA_NDVI4$NDVI * 0.0001


# Add water year

BrandywinePA_NDVI4$water_year <- WaterYear(BrandywinePA_NDVI4$date)


#------------------------------------------------------------------------------#

# COMBINE THE TWO DATA FRAMES

BrandywinePA_NDVI <- bind_rows(BrandywinePA_NDVI2, BrandywinePA_NDVI4)


# Group by water year and summarize data

BrandywinePA_NDVI_summary <- BrandywinePA_NDVI %>% 
  group_by(water_year) %>% 
  summarize(ave_NDVI = mean(NDVI, na.rm =TRUE),
            max_NDVI = max(NDVI, na.rm = TRUE))


################################################################################

# Mechums River, Virginia = MechumsVA

# PERIOD: 1980-10-01 to 2000-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_1 <- ee$ImageCollection("LANDSAT/LT05/C01/T1_8DAY_NDVI") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2000-09-30") %>%
  # ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

MechumsVA_NDVI1 <- ee_extract(x = NDVI_1, y = MechumsVA_ws$geometry, sf = FALSE)


# Convert columns to rows

MechumsVA_NDVI2 <- as.data.frame(t(MechumsVA_NDVI1))


# Convert row names into a column

MechumsVA_NDVI2$time <- rownames(MechumsVA_NDVI2)


# Remove the first row

MechumsVA_NDVI2 <- as.data.frame(MechumsVA_NDVI2[2:nrow(MechumsVA_NDVI2), ])


# Rename column names

colnames(MechumsVA_NDVI2) <- c("NDVI", "time")


# Make date column

MechumsVA_NDVI2$time <- gsub('[X_NDVI]', '', MechumsVA_NDVI2$time)  # removes unnecessary characters
MechumsVA_NDVI2$date <- ymd(MechumsVA_NDVI2$time)


# Add water year

MechumsVA_NDVI2$water_year <- WaterYear(MechumsVA_NDVI2$date)


#------------------------------------------------------------------------------#

# PERIOD: 2000-10-01 to 2020-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_2 <- ee$ImageCollection("MODIS/006/MOD13A2") %>%
  ee$ImageCollection$filterDate("2000-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

MechumsVA_NDVI3 <- ee_extract(x = NDVI_2, y = MechumsVA_ws$geometry, sf = FALSE)


# Convert columns to rows

MechumsVA_NDVI4 <- as.data.frame(t(MechumsVA_NDVI3))


# Convert row names into a column

MechumsVA_NDVI4$time <- rownames(MechumsVA_NDVI4)


# Remove the first row

MechumsVA_NDVI4 <- as.data.frame(MechumsVA_NDVI4[2:nrow(MechumsVA_NDVI4), ])


# Rename column names

colnames(MechumsVA_NDVI4) <- c("NDVI", "time")


# Make date column

MechumsVA_NDVI4$time <- gsub('[X_NDVI]', '', MechumsVA_NDVI4$time)  # removes unnecessary characters
MechumsVA_NDVI4$date <- ymd(MechumsVA_NDVI4$time)


# Adjust values of NDVI since MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km is at Scale = 0.0001

MechumsVA_NDVI4$NDVI <- MechumsVA_NDVI4$NDVI * 0.0001


# Add water year

MechumsVA_NDVI4$water_year <- WaterYear(MechumsVA_NDVI4$date)


#------------------------------------------------------------------------------#

# COMBINE THE TWO DATA FRAMES

MechumsVA_NDVI <- bind_rows(MechumsVA_NDVI2, MechumsVA_NDVI4)


# Group by water year and summarize data

MechumsVA_NDVI_summary <- MechumsVA_NDVI %>% 
  group_by(water_year) %>% 
  summarize(ave_NDVI = mean(NDVI, na.rm =TRUE),
            max_NDVI = max(NDVI, na.rm = TRUE))


################################################################################

# Flat River, North Carolina = FlatNC

# PERIOD: 1980-10-01 to 2000-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_1 <- ee$ImageCollection("LANDSAT/LT05/C01/T1_8DAY_NDVI") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2000-09-30") %>%
  # ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

FlatNC_NDVI1 <- ee_extract(x = NDVI_1, y = FlatNC_ws$geometry, sf = FALSE)


# Convert columns to rows

FlatNC_NDVI2 <- as.data.frame(t(FlatNC_NDVI1))


# Convert row names into a column

FlatNC_NDVI2$time <- rownames(FlatNC_NDVI2)


# Remove the first row

FlatNC_NDVI2 <- as.data.frame(FlatNC_NDVI2[2:nrow(FlatNC_NDVI2), ])


# Rename column names

colnames(FlatNC_NDVI2) <- c("NDVI", "time")


# Make date column

FlatNC_NDVI2$time <- gsub('[X_NDVI]', '', FlatNC_NDVI2$time)  # removes unnecessary characters
FlatNC_NDVI2$date <- ymd(FlatNC_NDVI2$time)


# Add water year

FlatNC_NDVI2$water_year <- WaterYear(FlatNC_NDVI2$date)


#------------------------------------------------------------------------------#

# PERIOD: 2000-10-01 to 2020-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_2 <- ee$ImageCollection("MODIS/006/MOD13A2") %>%
  ee$ImageCollection$filterDate("2000-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

FlatNC_NDVI3 <- ee_extract(x = NDVI_2, y = FlatNC_ws$geometry, sf = FALSE)


# Convert columns to rows

FlatNC_NDVI4 <- as.data.frame(t(FlatNC_NDVI3))


# Convert row names into a column

FlatNC_NDVI4$time <- rownames(FlatNC_NDVI4)


# Remove the first row

FlatNC_NDVI4 <- as.data.frame(FlatNC_NDVI4[2:nrow(FlatNC_NDVI4), ])


# Rename column names

colnames(FlatNC_NDVI4) <- c("NDVI", "time")


# Make date column

FlatNC_NDVI4$time <- gsub('[X_NDVI]', '', FlatNC_NDVI4$time)  # removes unnecessary characters
FlatNC_NDVI4$date <- ymd(FlatNC_NDVI4$time)


# Adjust values of NDVI since MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km is at Scale = 0.0001

FlatNC_NDVI4$NDVI <- FlatNC_NDVI4$NDVI * 0.0001


# Add water year

FlatNC_NDVI4$water_year <- WaterYear(FlatNC_NDVI4$date)


#------------------------------------------------------------------------------#

# COMBINE THE TWO DATA FRAMES

FlatNC_NDVI <- bind_rows(FlatNC_NDVI2, FlatNC_NDVI4)


# Group by water year and summarize data

FlatNC_NDVI_summary <- FlatNC_NDVI %>% 
  group_by(water_year) %>% 
  summarize(ave_NDVI = mean(NDVI, na.rm =TRUE),
            max_NDVI = max(NDVI, na.rm = TRUE))


################################################################################

# North Fork Edisto, South Carolina = NorthForkSC


# PERIOD: 1980-10-01 to 2000-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_1 <- ee$ImageCollection("LANDSAT/LT05/C01/T1_8DAY_NDVI") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2000-09-30") %>%
  # ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

NorthForkSC_NDVI1 <- ee_extract(x = NDVI_1, y = NorthForkSC_ws$geometry, sf = FALSE)


# Convert columns to rows

NorthForkSC_NDVI2 <- as.data.frame(t(NorthForkSC_NDVI1))


# Convert row names into a column

NorthForkSC_NDVI2$time <- rownames(NorthForkSC_NDVI2)


# Remove the first row

NorthForkSC_NDVI2 <- as.data.frame(NorthForkSC_NDVI2[2:nrow(NorthForkSC_NDVI2), ])


# Rename column names

colnames(NorthForkSC_NDVI2) <- c("NDVI", "time")


# Make date column

NorthForkSC_NDVI2$time <- gsub('[X_NDVI]', '', NorthForkSC_NDVI2$time)  # removes unnecessary characters
NorthForkSC_NDVI2$date <- ymd(NorthForkSC_NDVI2$time)


# Add water year

NorthForkSC_NDVI2$water_year <- WaterYear(NorthForkSC_NDVI2$date)


#------------------------------------------------------------------------------#

# PERIOD: 2000-10-01 to 2020-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_2 <- ee$ImageCollection("MODIS/006/MOD13A2") %>%
  ee$ImageCollection$filterDate("2000-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

NorthForkSC_NDVI3 <- ee_extract(x = NDVI_2, y = NorthForkSC_ws$geometry, sf = FALSE)


# Convert columns to rows

NorthForkSC_NDVI4 <- as.data.frame(t(NorthForkSC_NDVI3))


# Convert row names into a column

NorthForkSC_NDVI4$time <- rownames(NorthForkSC_NDVI4)


# Remove the first row

NorthForkSC_NDVI4 <- as.data.frame(NorthForkSC_NDVI4[2:nrow(NorthForkSC_NDVI4), ])


# Rename column names

colnames(NorthForkSC_NDVI4) <- c("NDVI", "time")


# Make date column

NorthForkSC_NDVI4$time <- gsub('[X_NDVI]', '', NorthForkSC_NDVI4$time)  # removes unnecessary characters
NorthForkSC_NDVI4$date <- ymd(NorthForkSC_NDVI4$time)


# Adjust values of NDVI since MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km is at Scale = 0.0001

NorthForkSC_NDVI4$NDVI <- NorthForkSC_NDVI4$NDVI * 0.0001


# Add water year

NorthForkSC_NDVI4$water_year <- WaterYear(NorthForkSC_NDVI4$date)


#------------------------------------------------------------------------------#

# COMBINE THE TWO DATA FRAMES

NorthForkSC_NDVI <- bind_rows(NorthForkSC_NDVI2, NorthForkSC_NDVI4)


# Group by water year and summarize data

NorthForkSC_NDVI_summary <- NorthForkSC_NDVI %>% 
  group_by(water_year) %>% 
  summarize(ave_NDVI = mean(NDVI, na.rm =TRUE),
            max_NDVI = max(NDVI, na.rm = TRUE))


################################################################################

# Ichawaynochaway, Georgia = IchawayGA

# PERIOD: 1980-10-01 to 2000-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_1 <- ee$ImageCollection("LANDSAT/LT05/C01/T1_8DAY_NDVI") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2000-09-30") %>%
  # ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

IchawayGA_NDVI1 <- ee_extract(x = NDVI_1, y = IchawayGA_ws$geometry, sf = FALSE)


# Convert columns to rows

IchawayGA_NDVI2 <- as.data.frame(t(IchawayGA_NDVI1))


# Convert row names into a column

IchawayGA_NDVI2$time <- rownames(IchawayGA_NDVI2)


# Remove the first row

IchawayGA_NDVI2 <- as.data.frame(IchawayGA_NDVI2[2:nrow(IchawayGA_NDVI2), ])


# Rename column names

colnames(IchawayGA_NDVI2) <- c("NDVI", "time")


# Make date column

IchawayGA_NDVI2$time <- gsub('[X_NDVI]', '', IchawayGA_NDVI2$time)  # removes unnecessary characters
IchawayGA_NDVI2$date <- ymd(IchawayGA_NDVI2$time)


# Add water year

IchawayGA_NDVI2$water_year <- WaterYear(IchawayGA_NDVI2$date)


#------------------------------------------------------------------------------#

# PERIOD: 2000-10-01 to 2020-09-30

setTimeLimit(1000)   # set time limit so that process doesn't time-out until download is complete

NDVI_2 <- ee$ImageCollection("MODIS/006/MOD13A2") %>%
  ee$ImageCollection$filterDate("2000-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("NDVI")) %>% # Select only NDVI bands
  ee$ImageCollection$toBands()


# Extract bands using the watershed geometry 

IchawayGA_NDVI3 <- ee_extract(x = NDVI_2, y = IchawayGA_ws$geometry, sf = FALSE)


# Convert columns to rows

IchawayGA_NDVI4 <- as.data.frame(t(IchawayGA_NDVI3))


# Convert row names into a column

IchawayGA_NDVI4$time <- rownames(IchawayGA_NDVI4)


# Remove the first row

IchawayGA_NDVI4 <- as.data.frame(IchawayGA_NDVI4[2:nrow(IchawayGA_NDVI4), ])


# Rename column names

colnames(IchawayGA_NDVI4) <- c("NDVI", "time")


# Make date column

IchawayGA_NDVI4$time <- gsub('[X_NDVI]', '', IchawayGA_NDVI4$time)  # removes unnecessary characters
IchawayGA_NDVI4$date <- ymd(IchawayGA_NDVI4$time)


# Adjust values of NDVI since MOD13A2.061 Terra Vegetation Indices 16-Day Global 1km is at Scale = 0.0001

IchawayGA_NDVI4$NDVI <- IchawayGA_NDVI4$NDVI * 0.0001


# Add water year

IchawayGA_NDVI4$water_year <- WaterYear(IchawayGA_NDVI4$date)


#------------------------------------------------------------------------------#

# COMBINE THE TWO DATA FRAMES

IchawayGA_NDVI <- bind_rows(IchawayGA_NDVI2, IchawayGA_NDVI4)


# Group by water year and summarize data

IchawayGA_NDVI_summary <- IchawayGA_NDVI %>% 
  group_by(water_year) %>% 
  summarize(ave_NDVI = mean(NDVI, na.rm =TRUE),
            max_NDVI = max(NDVI, na.rm = TRUE))

