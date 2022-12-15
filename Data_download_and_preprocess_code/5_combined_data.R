
# DATA DOWNLOAD AND PRE-PROCESS CODE

################################################################################

# COMBINED DATA

# This script compiles all the necessary data into a single data frame

################################################################################

# Oyster River, New Hampshire = OysterNH

OysterNH_data <- data.frame(OysterNH_WBET$water_year,
                            OysterNH_WBET$WBET_annual_total,
                            OysterNH_WBET$WBET_ave,
                            OysterNH_aet_summary$total_annual_aet,
                            OysterNH_aet_summary$ave_monthly_aet,
                            OysterNH_pr_summary$total_annual_pr,
                            OysterNH_pr_summary$ave_monthly_pr,
                            OysterNH_pet_summary$total_annual_pet,
                            OysterNH_pet_summary$ave_monthly_pet,
                            OysterNH_soil_summary$total_annual_soil,
                            OysterNH_soil_summary$ave_monthly_soil,
                            OysterNH_tmax_summary$ave_monthly_tmax,
                            OysterNH_NDVI_summary$ave_NDVI,
                            OysterNH_NDVI_summary$max_NDVI,
                            )

# Rename columns

colnames(OysterNH_data) <- c("water_year",
                             "WB_annual_total_aet",
                             "WB_ave_aet",
                             "RS_annual_total_aet",
                             "RS_ave_monthly_aet",
                             "RS_annual_total_precip",
                             "RS_ave_monthly_precip",
                             "RS_annual_total_pet",
                             "RS_ave_monthly_pet",
                             "RS_annual_total_soil_moisture",
                             "RS_ave_monthly_soil_moisture",
                             "RS_ave_monthly_tmax",
                             "RS_ave_NDVI",
                             "RS_max_NDVI")


################################################################################

# Wappinger Creek, New York = WappingerNY

WappingerNY_data <- data.frame(WappingerNY_WBET$water_year,
                            WappingerNY_WBET$WBET_annual_total,
                            WappingerNY_WBET$WBET_ave,
                            WappingerNY_aet_summary$total_annual_aet,
                            WappingerNY_aet_summary$ave_monthly_aet,
                            WappingerNY_pr_summary$total_annual_pr,
                            WappingerNY_pr_summary$ave_monthly_pr,
                            WappingerNY_pet_summary$total_annual_pet,
                            WappingerNY_pet_summary$ave_monthly_pet,
                            WappingerNY_soil_summary$total_annual_soil,
                            WappingerNY_soil_summary$ave_monthly_soil,
                            WappingerNY_tmax_summary$ave_monthly_tmax,
                            WappingerNY_NDVI_summary$ave_NDVI,
                            WappingerNY_NDVI_summary$max_NDVI)

# Rename columns

colnames(WappingerNY_data) <- c("water_year",
                                "WB_annual_total_aet",
                                "WB_ave_aet",
                                "RS_annual_total_aet",
                                "RS_ave_monthly_aet",
                                "RS_annual_total_precip",
                                "RS_ave_monthly_precip",
                                "RS_annual_total_pet",
                                "RS_ave_monthly_pet",
                                "RS_annual_total_soil_moisture",
                                "RS_ave_monthly_soil_moisture",
                                "RS_ave_monthly_tmax",
                                "RS_ave_NDVI",
                                "RS_max_NDVI")

################################################################################

# Brandywine Creek, Pennsylvania = BrandywinePA

BrandywinePA_data <- data.frame(BrandywinePA_WBET$water_year,
                               BrandywinePA_WBET$WBET_annual_total,
                               BrandywinePA_WBET$WBET_ave,
                               BrandywinePA_aet_summary$total_annual_aet,
                               BrandywinePA_aet_summary$ave_monthly_aet,
                               BrandywinePA_pr_summary$total_annual_pr,
                               BrandywinePA_pr_summary$ave_monthly_pr,
                               BrandywinePA_pet_summary$total_annual_pet,
                               BrandywinePA_pet_summary$ave_monthly_pet,
                               BrandywinePA_soil_summary$total_annual_soil,
                               BrandywinePA_soil_summary$ave_monthly_soil,
                               BrandywinePA_tmax_summary$ave_monthly_tmax,
                               BrandywinePA_NDVI_summary$ave_NDVI,
                               BrandywinePA_NDVI_summary$max_NDVI)

# Rename columns

colnames(BrandywinePA_data) <- c("water_year",
                                 "WB_annual_total_aet",
                                 "WB_ave_aet",
                                 "RS_annual_total_aet",
                                 "RS_ave_monthly_aet",
                                 "RS_annual_total_precip",
                                 "RS_ave_monthly_precip",
                                 "RS_annual_total_pet",
                                 "RS_ave_monthly_pet",
                                 "RS_annual_total_soil_moisture",
                                 "RS_ave_monthly_soil_moisture",
                                 "RS_ave_monthly_tmax",
                                 "RS_ave_NDVI",
                                 "RS_max_NDVI")


################################################################################

# Mechums River, Virginia = MechumsVA

MechumsVA_data <- data.frame(MechumsVA_WBET$water_year,
                                MechumsVA_WBET$WBET_annual_total,
                                MechumsVA_WBET$WBET_ave,
                                MechumsVA_aet_summary$total_annual_aet,
                                MechumsVA_aet_summary$ave_monthly_aet,
                                MechumsVA_pr_summary$total_annual_pr,
                                MechumsVA_pr_summary$ave_monthly_pr,
                                MechumsVA_pet_summary$total_annual_pet,
                                MechumsVA_pet_summary$ave_monthly_pet,
                                MechumsVA_soil_summary$total_annual_soil,
                                MechumsVA_soil_summary$ave_monthly_soil,
                                MechumsVA_tmax_summary$ave_monthly_tmax,
                             MechumsVA_NDVI_summary$ave_NDVI,
                             MechumsVA_NDVI_summary$max_NDVI)

# Rename columns

colnames(MechumsVA_data) <- c("water_year",
                              "WB_annual_total_aet",
                              "WB_ave_aet",
                              "RS_annual_total_aet",
                              "RS_ave_monthly_aet",
                              "RS_annual_total_precip",
                              "RS_ave_monthly_precip",
                              "RS_annual_total_pet",
                              "RS_ave_monthly_pet",
                              "RS_annual_total_soil_moisture",
                              "RS_ave_monthly_soil_moisture",
                              "RS_ave_monthly_tmax",
                              "RS_ave_NDVI",
                              "RS_max_NDVI")


################################################################################

# Flat River, North Carolina = FlatNC

FlatNC_data <- data.frame(FlatNC_WBET$water_year,
                             FlatNC_WBET$WBET_annual_total,
                             FlatNC_WBET$WBET_ave,
                             FlatNC_aet_summary$total_annual_aet,
                             FlatNC_aet_summary$ave_monthly_aet,
                             FlatNC_pr_summary$total_annual_pr,
                             FlatNC_pr_summary$ave_monthly_pr,
                             FlatNC_pet_summary$total_annual_pet,
                             FlatNC_pet_summary$ave_monthly_pet,
                             FlatNC_soil_summary$total_annual_soil,
                             FlatNC_soil_summary$ave_monthly_soil,
                             FlatNC_tmax_summary$ave_monthly_tmax,
                          FlatNC_NDVI_summary$ave_NDVI,
                          FlatNC_NDVI_summary$max_NDVI)

# Rename columns

colnames(FlatNC_data) <- c("water_year",
                           "WB_annual_total_aet",
                           "WB_ave_aet",
                           "RS_annual_total_aet",
                           "RS_ave_monthly_aet",
                           "RS_annual_total_precip",
                           "RS_ave_monthly_precip",
                           "RS_annual_total_pet",
                           "RS_ave_monthly_pet",
                           "RS_annual_total_soil_moisture",
                           "RS_ave_monthly_soil_moisture",
                           "RS_ave_monthly_tmax",
                           "RS_ave_NDVI",
                           "RS_max_NDVI")


################################################################################

# North Fork Edisto, South Carolina = NorthForkSC

NorthForkSC_data <- data.frame(NorthForkSC_WBET$water_year,
                          NorthForkSC_WBET$WBET_annual_total,
                          NorthForkSC_WBET$WBET_ave,
                          NorthForkSC_aet_summary$total_annual_aet,
                          NorthForkSC_aet_summary$ave_monthly_aet,
                          NorthForkSC_pr_summary$total_annual_pr,
                          NorthForkSC_pr_summary$ave_monthly_pr,
                          NorthForkSC_pet_summary$total_annual_pet,
                          NorthForkSC_pet_summary$ave_monthly_pet,
                          NorthForkSC_soil_summary$total_annual_soil,
                          NorthForkSC_soil_summary$ave_monthly_soil,
                          NorthForkSC_tmax_summary$ave_monthly_tmax,
                          NorthForkSC_NDVI_summary$ave_NDVI,
                          NorthForkSC_NDVI_summary$max_NDVI)

# Rename columns

colnames(NorthForkSC_data) <- c("water_year",
                                "WB_annual_total_aet",
                                "WB_ave_aet",
                                "RS_annual_total_aet",
                                "RS_ave_monthly_aet",
                                "RS_annual_total_precip",
                                "RS_ave_monthly_precip",
                                "RS_annual_total_pet",
                                "RS_ave_monthly_pet",
                                "RS_annual_total_soil_moisture",
                                "RS_ave_monthly_soil_moisture",
                                "RS_ave_monthly_tmax",
                                "RS_ave_NDVI",
                                "RS_max_NDVI")


################################################################################

# Ichawaynochaway, Georgia = IchawayGA

IchawayGA_data <- data.frame(IchawayGA_WBET$water_year,
                               IchawayGA_WBET$WBET_annual_total,
                               IchawayGA_WBET$WBET_ave,
                               IchawayGA_aet_summary$total_annual_aet,
                               IchawayGA_aet_summary$ave_monthly_aet,
                               IchawayGA_pr_summary$total_annual_pr,
                               IchawayGA_pr_summary$ave_monthly_pr,
                               IchawayGA_pet_summary$total_annual_pet,
                               IchawayGA_pet_summary$ave_monthly_pet,
                               IchawayGA_soil_summary$total_annual_soil,
                               IchawayGA_soil_summary$ave_monthly_soil,
                               IchawayGA_tmax_summary$ave_monthly_tmax,
                             IchawayGA_NDVI_summary$ave_NDVI,
                             IchawayGA_NDVI_summary$max_NDVI)

# Rename columns

colnames(IchawayGA_data) <- c("water_year",
                              "WB_annual_total_aet",
                              "WB_ave_aet",
                              "RS_annual_total_aet",
                              "RS_ave_monthly_aet",
                              "RS_annual_total_precip",
                              "RS_ave_monthly_precip",
                              "RS_annual_total_pet",
                              "RS_ave_monthly_pet",
                              "RS_annual_total_soil_moisture",
                              "RS_ave_monthly_soil_moisture",
                              "RS_ave_monthly_tmax",
                              "RS_ave_NDVI",
                              "RS_max_NDVI")


################################################################################

# EXPORT FILES AS .csv
# Note: not a necessary step but will be done for this project
# for the purpose of making the script for model training and validation able to run
# without running scripts under the data download and pre-process code

# USERS MAY NEED TO CHANGE FILE PATHS

# OysterNH

write.csv(OysterNH_data, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/OysterNH_data.csv",
          row.names = FALSE)


# WappingerNY

write.csv(WappingerNY_data, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/WappingerNY_data.csv",
          row.names = FALSE)


# BrandywinePA

write.csv(BrandywinePA_data, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/BrandywinePA_data.csv",
          row.names = FALSE)


# MechumsVA

write.csv(MechumsVA_data, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/MechumsVA_data.csv",
          row.names = FALSE)


# FlatNC

write.csv(FlatNC_data, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/FlatNC_data.csv",
          row.names = FALSE)


# NorthForkSC

write.csv(NorthForkSC_data, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/NorthForkSC_data.csv",
          row.names = FALSE)


# IchawayGA

write.csv(IchawayGA_data, "/Users/amyeldalecero/CEE_609_project/Model_train_and_validate_code/data/IchawayGA_data.csv",
          row.names = FALSE)
