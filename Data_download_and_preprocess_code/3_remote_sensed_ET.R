
# DATA DOWNLOAD AND PRE-PROCESS CODE

################################################################################

# REMOTE-SENSED EVAPOTRANSPIRATION

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

# LIBRARIES:

library(tidyverse)
library(rgee)      # Must be installed properly following: https://cran.r-project.org/web/packages/rgee/vignettes/rgee01.html
library(sf)
library(lubridate)

# Workflow reference:
# https://github.com/r-spatial/rgee

################################################################################

# FUNCTIONS:

# Convert monthly AET to daily AET

DailyAET <- function(date, aet){
  
  ifelse(((month(date) == 02) & (leap_year(date) == TRUE)), (aet / 28), 
         ifelse(((month(date) == 02) & (leap_year(date) == FALSE)), (aet / 29),
                ifelse((month(date) %in% c(01, 03, 05, 07, 08, 10, 12)), (aet / 31), (aet / 30))))
  
}


# Assigning the water year to each date
# where: date = array/ column containing the date in YMD format produced using 
# lubridate package

WaterYear <- function(date) {
  ifelse (month(date) < 10, year(date), year(date) + 1)
}

# Note: This function should already be available in the environment since it was used in a previous script

################################################################################

# Initialize the Earth Engine R API

ee_Initialize()

################################################################################

# Oyster River, New Hampshire = OysterNH

# Read the shapefile

OysterNH_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/OysterNH_ws/OysterNH.shp", quiet = TRUE)


# Map each image to extract the monthly actual evapotranspiration 
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("aet")) %>% # Select only actual evapotranspiration bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly actual evapotranspiration values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

OysterNH_aet <- ee_extract(x = terraclimate, y = OysterNH_ws$geometry, sf = FALSE)

# Convert columns to rows

OysterNH_aet2 <- as.data.frame(t(OysterNH_aet))


# Convert row names into a column

OysterNH_aet2$time <- rownames(OysterNH_aet2)


# Remove the first row

OysterNH_aet2 <- as.data.frame(OysterNH_aet2[2:nrow(OysterNH_aet2), ])


# Rename column names

colnames(OysterNH_aet2) <- c("monthly_aet", "time")


# Make date column (assume that each month starts at 01)

OysterNH_aet2$time <- gsub('[X_aet]', '', OysterNH_aet2$time)  # removes unnecessary characters
OysterNH_aet2$date <- ym(OysterNH_aet2$time)


# Add water year

OysterNH_aet2$water_year <- WaterYear(OysterNH_aet2$date)


# Convert monthly aet to daily aet

OysterNH_aet2$daily_aet <- DailyAET(OysterNH_aet2$date, OysterNH_aet2$monthly_aet)


# Group by water year and summarize data

OysterNH_aet_summary <- OysterNH_aet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_aet = sum(monthly_aet, na.rm =TRUE),
            ave_monthly_aet = mean(monthly_aet, na.rm = TRUE),
            ave_daily_aet = mean(daily_aet, na.rm = TRUE))


################################################################################

# Wappinger Creek, New York = WappingerNY

# Read the shapefile

WappingerNY_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/WappingerNY_ws/WappingerNY.shp", quiet = TRUE)


# Map each image to extract the monthly actual evapotranspiration 
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("aet")) %>% # Select only actual evapotranspiration bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly actual evapotranspiration values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

WappingerNY_aet <- ee_extract(x = terraclimate, y = WappingerNY_ws$geometry, sf = FALSE)

# Convert columns to rows

WappingerNY_aet2 <- as.data.frame(t(WappingerNY_aet))


# Convert row names into a column

WappingerNY_aet2$time <- rownames(WappingerNY_aet2)


# Remove the first row

WappingerNY_aet2 <- as.data.frame(WappingerNY_aet2[2:nrow(WappingerNY_aet2), ])


# Rename column names

colnames(WappingerNY_aet2) <- c("monthly_aet", "time")


# Make date column (assume that each month starts at 01)

WappingerNY_aet2$time <- gsub('[X_aet]', '', WappingerNY_aet2$time)  # removes unnecessary characters
WappingerNY_aet2$date <- ym(WappingerNY_aet2$time)


# Add water year

WappingerNY_aet2$water_year <- WaterYear(WappingerNY_aet2$date)


# Convert monthly aet to daily aet

WappingerNY_aet2$daily_aet <- DailyAET(WappingerNY_aet2$date, WappingerNY_aet2$monthly_aet)


# Group by water year and summarize data

WappingerNY_aet_summary <- WappingerNY_aet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_aet = sum(monthly_aet, na.rm =TRUE),
            ave_monthly_aet = mean(monthly_aet, na.rm = TRUE),
            ave_daily_aet = mean(daily_aet, na.rm = TRUE))


################################################################################

# Brandywine Creek, Pennsylvania = BrandywinePA

# Read the shapefile

BrandywinePA_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/BrandywinePA_ws/BrandywinePA.shp", quiet = TRUE)


# Map each image to extract the monthly actual evapotranspiration 
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("aet")) %>% # Select only actual evapotranspiration bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly actual evapotranspiration values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

BrandywinePA_aet <- ee_extract(x = terraclimate, y = BrandywinePA_ws$geometry, sf = FALSE)

# Convert columns to rows

BrandywinePA_aet2 <- as.data.frame(t(BrandywinePA_aet))


# Convert row names into a column

BrandywinePA_aet2$time <- rownames(BrandywinePA_aet2)


# Remove the first row

BrandywinePA_aet2 <- as.data.frame(BrandywinePA_aet2[2:nrow(BrandywinePA_aet2), ])


# Rename column names

colnames(BrandywinePA_aet2) <- c("monthly_aet", "time")


# Make date column (assume that each month starts at 01)

BrandywinePA_aet2$time <- gsub('[X_aet]', '', BrandywinePA_aet2$time)  # removes unnecessary characters
BrandywinePA_aet2$date <- ym(BrandywinePA_aet2$time)


# Add water year

BrandywinePA_aet2$water_year <- WaterYear(BrandywinePA_aet2$date)


# Convert monthly aet to daily aet

BrandywinePA_aet2$daily_aet <- DailyAET(BrandywinePA_aet2$date, BrandywinePA_aet2$monthly_aet)


# Group by water year and summarize data

BrandywinePA_aet_summary <- BrandywinePA_aet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_aet = sum(monthly_aet, na.rm =TRUE),
            ave_monthly_aet = mean(monthly_aet, na.rm = TRUE),
            ave_daily_aet = mean(daily_aet, na.rm = TRUE))


################################################################################

# Mechums River, Virginia = MechumsVA

# Read the shapefile

MechumsVA_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/MechumsVA_ws/MechumsVA.shp", quiet = TRUE)


# Map each image to extract the monthly actual evapotranspiration 
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("aet")) %>% # Select only actual evapotranspiration bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly actual evapotranspiration values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

MechumsVA_aet <- ee_extract(x = terraclimate, y = MechumsVA_ws$geometry, sf = FALSE)

# Convert columns to rows

MechumsVA_aet2 <- as.data.frame(t(MechumsVA_aet))


# Convert row names into a column

MechumsVA_aet2$time <- rownames(MechumsVA_aet2)


# Remove the first row

MechumsVA_aet2 <- as.data.frame(MechumsVA_aet2[2:nrow(MechumsVA_aet2), ])


# Rename column names

colnames(MechumsVA_aet2) <- c("monthly_aet", "time")


# Make date column (assume that each month starts at 01)

MechumsVA_aet2$time <- gsub('[X_aet]', '', MechumsVA_aet2$time)  # removes unnecessary characters
MechumsVA_aet2$date <- ym(MechumsVA_aet2$time)


# Add water year

MechumsVA_aet2$water_year <- WaterYear(MechumsVA_aet2$date)


# Convert monthly aet to daily aet

MechumsVA_aet2$daily_aet <- DailyAET(MechumsVA_aet2$date, MechumsVA_aet2$monthly_aet)


# Group by water year and summarize data

MechumsVA_aet_summary <- MechumsVA_aet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_aet = sum(monthly_aet, na.rm =TRUE),
            ave_monthly_aet = mean(monthly_aet, na.rm = TRUE),
            ave_daily_aet = mean(daily_aet, na.rm = TRUE))


################################################################################

# Flat River, North Carolina = FlatNC

# Read the shapefile

FlatNC_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/FlatNC_ws/FlatNC.shp", quiet = TRUE)


# Map each image to extract the monthly actual evapotranspiration 
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("aet")) %>% # Select only actual evapotranspiration bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly actual evapotranspiration values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

FlatNC_aet <- ee_extract(x = terraclimate, y = FlatNC_ws$geometry, sf = FALSE)

# Convert columns to rows

FlatNC_aet2 <- as.data.frame(t(FlatNC_aet))


# Convert row names into a column

FlatNC_aet2$time <- rownames(FlatNC_aet2)


# Remove the first row

FlatNC_aet2 <- as.data.frame(FlatNC_aet2[2:nrow(FlatNC_aet2), ])


# Rename column names

colnames(FlatNC_aet2) <- c("monthly_aet", "time")


# Make date column (assume that each month starts at 01)

FlatNC_aet2$time <- gsub('[X_aet]', '', FlatNC_aet2$time)  # removes unnecessary characters
FlatNC_aet2$date <- ym(FlatNC_aet2$time)


# Add water year

FlatNC_aet2$water_year <- WaterYear(FlatNC_aet2$date)


# Convert monthly aet to daily aet

FlatNC_aet2$daily_aet <- DailyAET(FlatNC_aet2$date, FlatNC_aet2$monthly_aet)


# Group by water year and summarize data

FlatNC_aet_summary <- FlatNC_aet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_aet = sum(monthly_aet, na.rm =TRUE),
            ave_monthly_aet = mean(monthly_aet, na.rm = TRUE),
            ave_daily_aet = mean(daily_aet, na.rm = TRUE))


################################################################################

# North Fork Edisto, South Carolina = NorthForkSC

# Read the shapefile

NorthForkSC_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/NorthForkSC_ws/NorthForkSC.shp", quiet = TRUE)


# Map each image to extract the monthly actual evapotranspiration
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("aet")) %>% # Select only actual evapotranspiration bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly actual evapotranspiration values from the Terraclimate ImageCollection through ee_extract
# Need to define:
# the ImageCollection object (x),
# the geometry (y), and
# a function to summarize the values (fun).

NorthForkSC_aet <- ee_extract(x = terraclimate, y = NorthForkSC_ws$geometry, sf = FALSE)

# Convert columns to rows

NorthForkSC_aet2 <- as.data.frame(t(NorthForkSC_aet))


# Convert row names into a column

NorthForkSC_aet2$time <- rownames(NorthForkSC_aet2)


# Remove the first row

NorthForkSC_aet2 <- as.data.frame(NorthForkSC_aet2[2:nrow(NorthForkSC_aet2), ])


# Rename column names

colnames(NorthForkSC_aet2) <- c("monthly_aet", "time")


# Make date column (assume that each month starts at 01)

NorthForkSC_aet2$time <- gsub('[X_aet]', '', NorthForkSC_aet2$time)  # removes unnecessary characters
NorthForkSC_aet2$date <- ym(NorthForkSC_aet2$time)


# Add water year

NorthForkSC_aet2$water_year <- WaterYear(NorthForkSC_aet2$date)


# Convert monthly aet to daily aet

NorthForkSC_aet2$daily_aet <- DailyAET(NorthForkSC_aet2$date, NorthForkSC_aet2$monthly_aet)


# Group by water year and summarize data

NorthForkSC_aet_summary <- NorthForkSC_aet2 %>%
  group_by(water_year) %>%
  summarize(total_annual_aet = sum(monthly_aet, na.rm =TRUE),
            ave_monthly_aet = mean(monthly_aet, na.rm = TRUE),
            ave_daily_aet = mean(daily_aet, na.rm = TRUE))


################################################################################

# Ichawaynochaway, Georgia = IchawayGA

# Read the shapefile

IchawayGA_ws <- st_read("/Users/amyeldalecero/CEE_609_project/Data_download_and_preprocess_code/data/IchawayGA_ws/IchawayGA.shp", quiet = TRUE)


# Map each image to extract the monthly actual evapotranspiration 
# derived using one-dimensional soil water balance model
# from the Terraclimate dataset

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("1989-10-01", "2020-09-30") %>%
  ee$ImageCollection$map(function(x) x$select("aet")) %>% # Select only actual evapotranspiration bands
  ee$ImageCollection$toBands() # from imagecollection to image


# Extract monthly actual evapotranspiration values from the Terraclimate ImageCollection through ee_extract
# Need to define: 
# the ImageCollection object (x), 
# the geometry (y), and 
# a function to summarize the values (fun).

IchawayGA_aet <- ee_extract(x = terraclimate, y = IchawayGA_ws$geometry, sf = FALSE)

# Convert columns to rows

IchawayGA_aet2 <- as.data.frame(t(IchawayGA_aet))


# Convert row names into a column

IchawayGA_aet2$time <- rownames(IchawayGA_aet2)


# Remove the first row

IchawayGA_aet2 <- as.data.frame(IchawayGA_aet2[2:nrow(IchawayGA_aet2), ])


# Rename column names

colnames(IchawayGA_aet2) <- c("monthly_aet", "time")


# Make date column (assume that each month starts at 01)

IchawayGA_aet2$time <- gsub('[X_aet]', '', IchawayGA_aet2$time)  # removes unnecessary characters
IchawayGA_aet2$date <- ym(IchawayGA_aet2$time)


# Add water year

IchawayGA_aet2$water_year <- WaterYear(IchawayGA_aet2$date)


# Convert monthly aet to daily aet

IchawayGA_aet2$daily_aet <- DailyAET(IchawayGA_aet2$date, IchawayGA_aet2$monthly_aet)


# Group by water year and summarize data

IchawayGA_aet_summary <- IchawayGA_aet2 %>% 
  group_by(water_year) %>% 
  summarize(total_annual_aet = sum(monthly_aet, na.rm =TRUE),
            ave_monthly_aet = mean(monthly_aet, na.rm = TRUE),
            ave_daily_aet = mean(daily_aet, na.rm = TRUE))
