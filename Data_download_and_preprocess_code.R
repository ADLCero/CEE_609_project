
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

#------------------------------------------------------------------------------#

# FUNCTIONS:

# 1) Assigning the water year to each date
# where: date = array/ column containing the date in YMD format produced using 
# lubridate package

WaterYear <- function(date) {
  ifelse (month(date) < 10, year(date), year(date) + 1)
}


# 2) Converting USGS discharge in cubic feet per second to cubic meter per second

# 1 cfs = 0.028316847 cubic meter per second
# Reference: https://www.convertunits.com/from/cubic+feet+per+second/to/cubic+meter+per+second
# where flow = discharge in cubic feet per second

m3s <- function(flow){
  flow * 0.028316847
}


# 3) Converting discharge to runoff depth in mm per day (normalizing using watershed area)
# where A = area of the watershed in squared meters
# m3s = discharge in cubic meters per second

RunoffDepth <- function(A, m3s){
  
  
  
}





#------------------------------------------------------------------------------#
# WATERSHEDS

# Oyster River, New Hampshire = OysterNH
# Wappinger Creek, New York = WappingerNY
# Brandywine Creek, Pennsylvania = BrandywinePA
# Mechums River, Virginia = MechumsVA
# Flat River, North Carolina = FlatNC
# North Fork Edisto, South Carolina = NorthForkSC
# Ichawaynochaway, Georgia = IchawayGA

#------------------------------------------------------------------------------#

# Common parameters:

# Set parameter as daily discharge

parameterCd <- "00060"

# Set start date and end date

startDate <- "1989-10-01"    # October 1 = start of a water year
endDate <- "2020-09-30"      # September 30 = end of a water year

#------------------------------------------------------------------------------#

# Oyster River, New Hampshire = OysterNH

siteNumber <- "01073000"

OysterNH <- readNWISdv(siteNumber,
                       parameterCd, 
                       startDate,
                       endDate)

# Remove unnecessary columns

# Rename columns

# Convert date to date format in R


