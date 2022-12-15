
# DATA DOWNLOAD AND PRE-PROCESS CODE

################################################################################

# WATERSHED BOUNDARIES

# The corresponding packages of the required libraries below may need to be 
# downloaded first using the install.packages("package") command or 
# by going to R Studio's Menu > Tools > Install packages

# Main package to be used:
# streamstats: an R package for using the USGS Streamstats API
# Source: https://github.com/markwh/streamstats

# Streamstats provides access to spatial analytical tools that are can be used on USGS
# water resources data
# Reference: https://www.usgs.gov/mission-areas/water-resources/science/streamstats-streamflow-statistics-and-spatial-analysis-tools

# install.packages("devtools")
devtools::install_github("markwh/streamstats")

# Note: There may be other dependencies that will be asked to be installed first.

# LIBRARIES from previous scripts (no need to be re-ran unless R restarted):

library(dataRetrieval)
library(tidyverse)
library(lubridate)

# ADDITIONAL LIBRARIES:

library(streamstats)

################################################################################

# Note: crs = 4326 (World Geodetic System 1984)

# Using the downloaded site information from 1_water_balance_ET.R

################################################################################

# Oyster River, New Hampshire = OysterNH

OysterNH_ws <- delineateWatershed(xlocation = OysterNH_SiteInfo$dec_long_va, 
                                  ylocation = OysterNH_SiteInfo$dec_lat_va, 
                                  crs = 4326, 
                                  includeparameters = "true", 
                                  includeflowtypes = "true")

# Visualize

leafletWatershed(OysterNH_ws)

# Write shapefile

writeShapefile(watershed = OysterNH_ws, layer = "OysterNH", 
               dir = "OysterNH_ws", # saves the shapefile in the user's home folder
               what = "boundary")


################################################################################

# Wappinger Creek, New York = WappingerNY

setTimeout(1000) # in seconds; can be set when timeout is reached before a result is returned

WappingerNY_ws <- delineateWatershed(xlocation = WappingerNY_SiteInfo$dec_long_va, 
                                  ylocation = WappingerNY_SiteInfo$dec_lat_va, 
                                  crs = 4326, 
                                  includeparameters = "true", 
                                  includeflowtypes = "true")

# Visualize

leafletWatershed(WappingerNY_ws)

# Write shapefile

writeShapefile(watershed = WappingerNY_ws, layer = "WappingerNY", 
               dir = "WappingerNY_ws", # saves the shapefile in the home folder of the user or in the set working directory
               what = "boundary")


################################################################################

# Brandywine Creek, Pennsylvania = BrandywinePA

setTimeout(1000) # in seconds; can be set when timeout is reached before a result is returned

BrandywinePA_ws <- delineateWatershed(xlocation = BrandywinePA_SiteInfo$dec_long_va, 
                                     ylocation = BrandywinePA_SiteInfo$dec_lat_va, 
                                     crs = 4326, 
                                     includeparameters = "true", 
                                     includeflowtypes = "true")

# Visualize

leafletWatershed(BrandywinePA_ws)

# Write shapefile

writeShapefile(watershed = BrandywinePA_ws, layer = "BrandywinePA", 
               dir = "BrandywinePA_ws", # saves the shapefile in the home folder of the user or in the set working directory
               what = "boundary")


################################################################################

# Mechums River, Virginia = MechumsVA

setTimeout(1000) # in seconds; can be set when timeout is reached before a result is returned

MechumsVA_ws <- delineateWatershed(xlocation = MechumsVA_SiteInfo$dec_long_va, 
                                      ylocation = MechumsVA_SiteInfo$dec_lat_va, 
                                      crs = 4326, 
                                      includeparameters = "true", 
                                      includeflowtypes = "true")

# Visualize

leafletWatershed(MechumsVA_ws)

# Write shapefile

writeShapefile(watershed = MechumsVA_ws, layer = "MechumsVA", 
               dir = "MechumsVA_ws", # saves the shapefile in the home folder of the user or in the set working directory
               what = "boundary")


################################################################################

# Flat River, North Carolina = FlatNC

setTimeout(1000) # in seconds; can be set when timeout is reached before a result is returned

FlatNC_ws <- delineateWatershed(xlocation = FlatNC_SiteInfo$dec_long_va, 
                                   ylocation = FlatNC_SiteInfo$dec_lat_va, 
                                   crs = 4326, 
                                   includeparameters = "true", 
                                   includeflowtypes = "true")


# Visualize

leafletWatershed(FlatNC_ws)

# Write shapefile

writeShapefile(watershed = FlatNC_ws, layer = "FlatNC", 
               dir = "FlatNC_ws", # saves the shapefile in the home folder of the user or in the set working directory
               what = "boundary")


################################################################################

# North Fork Edisto, South Carolina = NorthForkSC       

# WARNING:
# DOES NOT WORK PROPERLY FOR SOME REASON (as of Nov 13, 2022; still not working as of Nov 26, 2022)
# Please see text NorthForkSC_watershed_download.txt for alternative way to obtain the watershed boundary of this site

setTimeout(1000) # in seconds; can be set when timeout is reached before a result is returned

NorthForkSC_ws <- delineateWatershed(xlocation = NorthForkSC_SiteInfo$dec_long_va, 
                                ylocation = NorthForkSC_SiteInfo$dec_lat_va, 
                                crs = 4326, 
                                includeparameters = "true", 
                                includeflowtypes = "true")

# Visualize

leafletWatershed(NorthForkSC_ws)

# Write shapefile

writeShapefile(watershed = NorthForkSC_ws, layer = "NorthForkSC", 
               dir = "NorthForkSC_ws", # saves the shapefile in the home folder of the user or in the set working directory
               what = "boundary")


################################################################################

# Ichawaynochaway, Georgia = IchawayGA

setTimeout(1000) # in seconds; can be set when timeout is reached before a result is returned

IchawayGA_ws <- delineateWatershed(xlocation = IchawayGA_SiteInfo$dec_long_va, 
                                     ylocation = IchawayGA_SiteInfo$dec_lat_va, 
                                     crs = 4326, 
                                     includeparameters = "true", 
                                     includeflowtypes = "true")

# setTimeout(1000) # in seconds; can be set when timeout is reached before a result is returned

# Visualize

leafletWatershed(IchawayGA_ws)

# Write shapefile

writeShapefile(watershed = IchawayGA_ws, layer = "IchawayGA", 
               dir = "IchawayGA_ws", # saves the shapefile in the home folder of the user or in the set working directory
               what = "boundary")

