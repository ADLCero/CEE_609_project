
# DATA DOWNLOAD AND PRE-PROCESS CODE

################################################################################

# DISCHARGE DATA

# The corresponding packages of the required libraries below may need to be 
# downloaded first using the install.packages("package") command or 
# by going to R Studio's Menu > Tools > Install packages

# LIBRARIES:

library(dataRetrieval)
library(tidyverse)
library(lubridate)

# dataRetrieval is a package that allows the processing and downloading
# of hydrologic data from USGS into R
# Reference: https://cran.r-project.org/web/packages/dataRetrieval/vignettes/dataRetrieval.html

################################################################################

# FUNCTIONS:

# 1) Converting drainage area from square miles to square meters
# where area_mi2 is the area of the water shed in square miles
# Reference: https://www.metric-conversions.org/area/square-miles-to-square-meters.htm

m2 <- function(area_mi2){
  area_m2 <- area_mi2 * 2589988.10
}

# 2) Converting USGS discharge in cubic feet per second to cubic meter per second

# 1 cfs = 0.028316847 cubic meter per second
# Reference: https://www.convertunits.com/from/cubic+feet+per+second/to/cubic+meter+per+second
# where flow = discharge in cubic feet per second

m3s <- function(flow){
  flow * 0.028316847
}


# 3) Converting discharge to runoff depth in mm per day (normalizing using watershed area)
# where m3s = discharge in cubic meters per second
# A = area of the watershed in squared meters

RunoffDepth <- function(m3s, A){
  RD_ms <- m3s / A     # meters per second
  RD_mmd <- RD_ms * 1000 * 86400   # millimeters per day
}

# 4) Assigning the water year to each date
# where: date = array/ column containing the date in YMD format produced using 
# lubridate package

WaterYear <- function(date) {
  ifelse (month(date) < 10, year(date), year(date) + 1)
}


################################################################################

# WATERSHEDS

# Oyster River, New Hampshire = OysterNH
# Wappinger Creek, New York = WappingerNY
# Brandywine Creek, Pennsylvania = BrandywinePA
# Mechums River, Virginia = MechumsVA
# Flat River, North Carolina = FlatNC
# North Fork Edisto, South Carolina = NorthForkSC
# Ichawaynochaway, Georgia = IchawayGA


# Note: This code can be optimized by using loops but for the purpose of this project
# and ease in diagnosing potential errors, data download was done separately for
# each watershed and intermediate data frames are saved/ made available.


#------------------------------------------------------------------------------#

# Common parameters:

# Set parameter as daily discharge

parameterCd <- "00060"

# Set start date and end date

startDate <- "1989-10-01"    # October 1 = start of a water year
endDate <- "2020-09-30"      # September 30 = end of a water year

################################################################################

# Oyster River, New Hampshire = OysterNH

siteNumber <- "01073000"

# Get the drainage area in square miles

OysterNH_SiteInfo <- readNWISsite(siteNumber)
OysterNH_area_mi2 <- OysterNH_SiteInfo$drain_area_va

# Convert the drainage area to square meters

OysterNH_area_m2 <- m2(OysterNH_area_mi2)

# Get the discharge data

OysterNH <- readNWISdv(siteNumber,
                       parameterCd, 
                       startDate,
                       endDate)

# Remove unnecessary columns

OysterNH <- data.frame(OysterNH$Date, OysterNH$X_00060_00003)

# Rename columns

colnames(OysterNH) <- c("date", "flow_cfs")

# Check if the date is in correct R date format
# If not, use as.Date()

class(OysterNH$date)

# Convert discharge in cfs to cubic meter per second

OysterNH$flow_m3s <- m3s(OysterNH$flow_cfs)

# Add runoff in mm

OysterNH$runoff_mm <- RunoffDepth(OysterNH$flow_m3s, OysterNH_area_m2)

# Assign water year to each time step

OysterNH$water_year <- WaterYear(OysterNH$date)

# Group data by water year, summarize by getting the mean values per year

OysterNH_summary <- OysterNH %>% 
  group_by(water_year) %>% 
  summarize(ave_flow_cfs = mean(flow_cfs, na.rm = TRUE),
            ave_flow_m3s = mean(flow_m3s, na.rm = TRUE),
            ave_runoff_mm = mean(runoff_mm, na.rm = TRUE))


################################################################################

# Wappinger Creek, New York = WappingerNY

siteNumber <- "01372500"

# Get the drainage area in square miles

WappingerNY_SiteInfo <- readNWISsite(siteNumber)
WappingerNY_area_mi2 <- WappingerNY_SiteInfo$drain_area_va

# Convert the drainage area to square meters

WappingerNY_area_m2 <- m2(WappingerNY_area_mi2)

# Get the discharge data

WappingerNY <- readNWISdv(siteNumber,
                       parameterCd, 
                       startDate,
                       endDate)

# Remove unnecessary columns

WappingerNY <- data.frame(WappingerNY$Date, WappingerNY$X_00060_00003)

# Rename columns

colnames(WappingerNY) <- c("date", "flow_cfs")

# Check if the date is in correct R date format
# If not, use as.Date()

class(WappingerNY$date)

# Convert discharge in cfs to cubic meter per second

WappingerNY$flow_m3s <- m3s(WappingerNY$flow_cfs)

# Add runoff in mm

WappingerNY$runoff_mm <- RunoffDepth(WappingerNY$flow_m3s, WappingerNY_area_m2)

# Assign water year to each time step

WappingerNY$water_year <- WaterYear(WappingerNY$date)

# Group data by water year, summarize by getting the mean values per year

WappingerNY_summary <- WappingerNY %>% 
  group_by(water_year) %>% 
  summarize(ave_flow_cfs = mean(flow_cfs, na.rm = TRUE),
            ave_flow_m3s = mean(flow_m3s, na.rm = TRUE),
            ave_runoff_mm = mean(runoff_mm, na.rm = TRUE))

################################################################################

# Brandywine Creek, Pennsylvania = BrandywinePA

siteNumber <- "01481000"

# Get the drainage area in square miles

BrandywinePA_SiteInfo <- readNWISsite(siteNumber)
BrandywinePA_area_mi2 <- BrandywinePA_SiteInfo$drain_area_va

# Convert the drainage area to square meters

BrandywinePA_area_m2 <- m2(BrandywinePA_area_mi2)

# Get the discharge data

BrandywinePA <- readNWISdv(siteNumber,
                          parameterCd, 
                          startDate,
                          endDate)

# Remove unnecessary columns

BrandywinePA <- data.frame(BrandywinePA$Date, BrandywinePA$X_00060_00003)

# Rename columns

colnames(BrandywinePA) <- c("date", "flow_cfs")

# Check if the date is in correct R date format
# If not, use as.Date()

class(BrandywinePA$date)

# Convert discharge in cfs to cubic meter per second

BrandywinePA$flow_m3s <- m3s(BrandywinePA$flow_cfs)

# Add runoff in mm

BrandywinePA$runoff_mm <- RunoffDepth(BrandywinePA$flow_m3s, BrandywinePA_area_m2)

# Assign water year to each time step

BrandywinePA$water_year <- WaterYear(BrandywinePA$date)

# Group data by water year, summarize by getting the mean values per year

BrandywinePA_summary <- BrandywinePA %>% 
  group_by(water_year) %>% 
  summarize(ave_flow_cfs = mean(flow_cfs, na.rm = TRUE),
            ave_flow_m3s = mean(flow_m3s, na.rm = TRUE),
            ave_runoff_mm = mean(runoff_mm, na.rm = TRUE))

################################################################################

# Mechums River, Virginia = MechumsVA

siteNumber <- "02031000"

# Get the drainage area in square miles

MechumsVA_SiteInfo <- readNWISsite(siteNumber)
MechumsVA_area_mi2 <- MechumsVA_SiteInfo$drain_area_va

# Convert the drainage area to square meters

MechumsVA_area_m2 <- m2(MechumsVA_area_mi2)

# Get the discharge data

MechumsVA <- readNWISdv(siteNumber,
                           parameterCd, 
                           startDate,
                           endDate)

# Remove unnecessary columns

MechumsVA <- data.frame(MechumsVA$Date, MechumsVA$X_00060_00003)

# Rename columns

colnames(MechumsVA) <- c("date", "flow_cfs")

# Check if the date is in correct R date format
# If not, use as.Date()

class(MechumsVA$date)

# Convert discharge in cfs to cubic meter per second

MechumsVA$flow_m3s <- m3s(MechumsVA$flow_cfs)

# Add runoff in mm

MechumsVA$runoff_mm <- RunoffDepth(MechumsVA$flow_m3s, MechumsVA_area_m2)

# Assign water year to each time step

MechumsVA$water_year <- WaterYear(MechumsVA$date)

# Group data by water year, summarize by getting the mean values per year

MechumsVA_summary <- MechumsVA %>% 
  group_by(water_year) %>% 
  summarize(ave_flow_cfs = mean(flow_cfs, na.rm = TRUE),
            ave_flow_m3s = mean(flow_m3s, na.rm = TRUE),
            ave_runoff_mm = mean(runoff_mm, na.rm = TRUE))

################################################################################

# Flat River, North Carolina = FlatNC

siteNumber <- "02085500"

# Get the drainage area in square miles

FlatNC_SiteInfo <- readNWISsite(siteNumber)
FlatNC_area_mi2 <- FlatNC_SiteInfo$drain_area_va

# Convert the drainage area to square meters

FlatNC_area_m2 <- m2(FlatNC_area_mi2)

# Get the discharge data

FlatNC <- readNWISdv(siteNumber,
                        parameterCd, 
                        startDate,
                        endDate)

# Remove unnecessary columns

FlatNC <- data.frame(FlatNC$Date, FlatNC$X_00060_00003)

# Rename columns

colnames(FlatNC) <- c("date", "flow_cfs")

# Check if the date is in correct R date format
# If not, use as.Date()

class(FlatNC$date)

# Convert discharge in cfs to cubic meter per second

FlatNC$flow_m3s <- m3s(FlatNC$flow_cfs)

# Add runoff in mm

FlatNC$runoff_mm <- RunoffDepth(FlatNC$flow_m3s, FlatNC_area_m2)

# Assign water year to each time step

FlatNC$water_year <- WaterYear(FlatNC$date)

# Group data by water year, summarize by getting the mean values per year

FlatNC_summary <- FlatNC %>% 
  group_by(water_year) %>% 
  summarize(ave_flow_cfs = mean(flow_cfs, na.rm = TRUE),
            ave_flow_m3s = mean(flow_m3s, na.rm = TRUE),
            ave_runoff_mm = mean(runoff_mm, na.rm = TRUE))

################################################################################

# North Fork Edisto, South Carolina = NorthForkSC

siteNumber <- "02173500"

# Get the drainage area in square miles

NorthForkSC_SiteInfo <- readNWISsite(siteNumber)
NorthForkSC_area_mi2 <- NorthForkSC_SiteInfo$drain_area_va

# Convert the drainage area to square meters

NorthForkSC_area_m2 <- m2(NorthForkSC_area_mi2)

# Get the discharge data

NorthForkSC <- readNWISdv(siteNumber,
                     parameterCd, 
                     startDate,
                     endDate)

# Remove unnecessary columns

NorthForkSC <- data.frame(NorthForkSC$Date, NorthForkSC$X_00060_00003)

# Rename columns

colnames(NorthForkSC) <- c("date", "flow_cfs")

# Check if the date is in correct R date format
# If not, use as.Date()

class(NorthForkSC$date)

# Convert discharge in cfs to cubic meter per second

NorthForkSC$flow_m3s <- m3s(NorthForkSC$flow_cfs)

# Add runoff in mm

NorthForkSC$runoff_mm <- RunoffDepth(NorthForkSC$flow_m3s, NorthForkSC_area_m2)

# Assign water year to each time step

NorthForkSC$water_year <- WaterYear(NorthForkSC$date)

# Group data by water year, summarize by getting the mean values per year

NorthForkSC_summary <- NorthForkSC %>% 
  group_by(water_year) %>% 
  summarize(ave_flow_cfs = mean(flow_cfs, na.rm = TRUE),
            ave_flow_m3s = mean(flow_m3s, na.rm = TRUE),
            ave_runoff_mm = mean(runoff_mm, na.rm = TRUE))

################################################################################

# Ichawaynochaway, Georgia = IchawayGA

siteNumber <- "02353500"

# Get the drainage area in square miles

IchawayGA_SiteInfo <- readNWISsite(siteNumber)
IchawayGA_area_mi2 <- IchawayGA_SiteInfo$drain_area_va

# Convert the drainage area to square meters

IchawayGA_area_m2 <- m2(IchawayGA_area_mi2)

# Get the discharge data

IchawayGA <- readNWISdv(siteNumber,
                          parameterCd, 
                          startDate,
                          endDate)

# Remove unnecessary columns

IchawayGA <- data.frame(IchawayGA$Date, IchawayGA$X_00060_00003)

# Rename columns

colnames(IchawayGA) <- c("date", "flow_cfs")

# Check if the date is in correct R date format
# If not, use as.Date()

class(IchawayGA$date)

# Convert discharge in cfs to cubic meter per second

IchawayGA$flow_m3s <- m3s(IchawayGA$flow_cfs)

# Add runoff in mm

IchawayGA$runoff_mm <- RunoffDepth(IchawayGA$flow_m3s, IchawayGA_area_m2)

# Assign water year to each time step

IchawayGA$water_year <- WaterYear(IchawayGA$date)

# Group data by water year, summarize by getting the mean values per year

IchawayGA_summary <- IchawayGA %>% 
  group_by(water_year) %>% 
  summarize(ave_flow_cfs = mean(flow_cfs, na.rm = TRUE),
            ave_flow_m3s = mean(flow_m3s, na.rm = TRUE),
            ave_runoff_mm = mean(runoff_mm, na.rm = TRUE))



################################################################################

# PRECIPITATION DATA

# The corresponding packages of the required libraries below may need to be 
# downloaded first using the install.packages("package") command or 
# by going to R Studio's Menu > Tools > Install packages

# ADDITIONAL LIBRARIES:

library(rnoaa)

# rnoaa is an R interface to many NOAA data sources
# Reference: https://docs.ropensci.org/rnoaa/

# Workflow reference:
# https://stackoverflow.com/questions/68878571/how-to-download-precipitation-data-using-rnoaa

# Metadata:
# https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt
# Note: PRCP = Precipitation (tenths of mm)

################################################################################

# Oyster River, New Hampshire = OysterNH

# Create a data frame of the latitude and longitude of the watershed
lat_lon_df <- data.frame(id = "OysterNH",
                         lat = OysterNH_SiteInfo$dec_lat_va,
                         lon = OysterNH_SiteInfo$dec_long_va)

# Find the 10 closest monitoring stations

mon_near <- meteo_nearby_stations(
  lat_lon_df = lat_lon_df,
  lat_colname = "lat",
  lon_colname = "lon",
  var = "PRCP",
  year_min = 1989,
  year_max = 2021,
  limit = 10
)

# Select nearest station (first on the list)

OysterNH_precip <- meteo_pull_monitors(
  monitors = mon_near$OysterNH$id[1],
  date_min = startDate,    # to be same with the starting and ending date of discharge
  date_max = endDate,
  var = "PRCP"
)

# Convert precipitation from tenths of mm to mm

OysterNH_precip$prcp_mm <- OysterNH_precip$prcp / 10

# Add water year to each time step

OysterNH_precip$water_year <- WaterYear(OysterNH_precip$date)

# Group data by water year, summarize by getting the mean values per year

OysterNH_precip_summary <- OysterNH_precip %>% 
  group_by(water_year) %>% 
  summarize(ave_prcp = mean(prcp, na.rm = TRUE),
            ave_prcp_mm = mean(prcp_mm, na.rm = TRUE))


################################################################################

# COMPUTATION OF EVAPOTRANSPIRATION USING WATER-BALANCE APPROACH

# mean basin precipitation (mm) minus basin runoff (mm, normalized by drainage area)


################################################################################

# Oyster River, New Hampshire = OysterNH

# Make a data frame containing all necessary variables

OysterNH_WBET <- data.frame(OysterNH_summary$water_year,
                            OysterNH_precip_summary$ave_prcp_mm,
                            OysterNH_summary$ave_runoff_mm)

# Rename columns

colnames(OysterNH_WBET) <- c("water_year",
                             "ave_prcp_mm",
                             "ave_runoff_mm")

# Compute for the ET

OysterNH_WBET$WBET <- OysterNH_WBET$ave_prcp_mm - OysterNH_WBET$ave_runoff_mm


