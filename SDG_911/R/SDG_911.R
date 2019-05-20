### Load packages
# raster processing
library(raster)
# Simple Features for spatial manipulation
library(sf)
# GDAL for R
library(rgdal)
# GEOS 
library(rgeos)
# Reprojecting and transforming
library(lwgeom)
#Tidyverse
library(tidyverse)
# data.table
library(data.table)

# Set working directory
setwd()
# Load functions
source("R/SDG_911_functions.R")

### Load previously downloaded road and population data
# load GRIP data
grip <- st_read("data/roads/GRIP4_Region3_vector_fgdb/GRIP4_region3.gdb")
# load population raster
GHS_POP <- raster("data/raster/GHS_POP_GPW42015_GLOBE_R2015A_54009_1k_v1_0.tif")
# load urban / rural raster
GHS_SMOD <- raster("data/raster/GHS_SMOD_POP2015_GLOBE_R2016A_54009_1k_v1_0.tif")
# Set coordinate system for the project
project_crs <- as.character(crs(GHS_POP))

################## Run these in a consecutive order ################## 

# 1. Search for the country you want to process
# To see all countries run it with "" only 
country <- country_finder("")

# 2. Download boundary from GADM - leave blank
boundary <- boundary_downloader()

# 3. Extract and buffer roads
# Set seasonal access to TRUE to ONLY use all-season roads
# Set seasonal access to FALSE to use ALL roads
# !!! Quality of this classification varies between countries and should be treated as experimental !!!
buffered_roads <- road_finder(seasonal_access = TRUE)

# 4. Calculate 9.1.1
result <- calculate_911(write_result = TRUE)

################## END ################## 
