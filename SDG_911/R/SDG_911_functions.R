country_finder <- function(x) {
  # This function searches for an ISO-3 code by country name
  # and downloads the matching rds from GADM
  # Load ISO lookup sourced from https://www.gov.uk/government/publications/iso-country-codes--2
  lookup <- tryCatch({
    readRDS("data/lookup/iso_lookup.RDS")
  },
  error = function(cond) {
    message("--- ISO_LOOKUP.RDS not found - make sure it's in the 'data' folder")
    return(NULL)
  })
  # Load name of country being searched
  country_name <- str_to_upper(x)
  # Find matches in lookup file
  result <-
    lookup[which(str_to_upper(lookup$NAME) %like% country_name),]
  # Number of matches
  result_length <- nrow(result)
  # If length is 0 no matches were found - resubmit query
  if (result_length == 0) {
    stop("--- No countries match your query - please try again")
  }
  # If results greater than 1 multiple matches found - resubmit query
  else if (result_length > 1) {
    message(
      "--- ",
      result_length,
      " countries match your query - view the results and specify which country you want"
    )
    print(result)
    ISO3_input <-
      str_to_upper(readline(prompt = "--- Enter country's ISO3 code here ---> "))
    result <- result[which(result$ISO3 == ISO3_input), ]
    print(result)
  }
  # Otherwise only 1 country matched - result returned to country
  else {
    message("--- ", result_length, " country matches your query")
    print(result)
  }
  return(result)
}

boundary_downloader <- function() {
  if (dir.exists("data/boundaries") == FALSE) {
    dir.create("data/boundaries")
    message("--- Folder boundaries created in data directory")
  } else {
    message("--- GADM boundaries can be found in data/boundaries folder")
  }
  if (any(grepl(country$ISO3, list.files("data/boundaries"))) == TRUE) {
    message("--- GADM boundaries for ",
            country$NAME,
            " have already been downloaded")
    boundary <-
      readRDS(list.files("data/boundaries", full.names = TRUE)[grep(country$ISO3, list.files("data/boundaries"))]) %>%
      spTransform(., project_crs) %>%
      st_as_sf()
    return(boundary)
  } else{
    message("--- Downloading GADM boundaries for ", country$NAME)
    boundary <-
      getData("GADM",
              country = country$ISO3,
              level = 0,
              path = "data/boundaries") %>% spTransform(., project_crs) %>% st_as_sf
    return(boundary)
    
  }
}

road_finder <- function(seasonal_access = FALSE) {
  message("--- Road processing started at ", Sys.time())
  if (missing(seasonal_access) == TRUE) {
    message("--- Seasonal_access parameter not specified - defaulting to FALSE")
  }
  # UN Code of country defined earlier
  un_code <- country$UN.CODE
  # Check if UN code is in GRP_RCY - STOP if not
  if (any(un_code == grip$GP_RCY) != TRUE) {
    stop(
      "--- UN 3 digit code ",
      un_code,
      " not found in the grip dataset. Make sure you're using the correct GRIP region"
    )
  }
  # If seasonal access TRUE select GP_RAV 2
  if (seasonal_access == TRUE) {
    message(
      "--- Seasonal access is not provided for all countries\n--- Consult the frequency table before use"
    )
    message("--- Selecting all accessible roads in ",
            country$NAME,
            " UN Code: ",
            un_code)
    # Frequency table of accessibility - if 2 is small/not present set to FALSE
    access_lookup <-
      data.frame(
        ID = c(0, 1, 2),
        Access = c("Unspecified %", "Seasonal %", "All Year Access %"),
        stringsAsFactors = FALSE
      )
    access_frequency <- grip %>% dplyr::filter(GP_RCY == un_code) %>% 
                                  st_set_geometry(.,NULL) %>% 
                                  group_by(GP_RAV) %>% 
                                  summarise(Road.Network.Length = sum(Shape_Leng)) %>% 
                                  mutate(Proportion.of.road.network = round(100*prop.table(Road.Network.Length),2)) %>% 
                                  select(-Road.Network.Length)
    
    access_frequency$GP_RAV <- access_frequency$GP_RAV %>%
                               recode('0' = "Unspecified", '1' = "Seasonal", '2' = "All year")  
 
    message("--- Proportion of accessibility classes by road length")
    print(access_frequency)
    proceed <- readline(prompt = "Do you want to use the accessibility measure? (TRUE/FALSE) ---> ")
    if (str_to_upper(proceed) == TRUE){
    roads <- dplyr::filter(grip, GP_RCY == un_code, GP_RAV == 2)
  } else(stop("Use seasonal_access = FALSE"))
  }
  else if (seasonal_access == FALSE) {
    message("--- Selecting all roads in ",
            country$NAME,
            " UN Code: ",
            un_code)
    roads <- dplyr::filter(grip, GP_RCY == un_code)
  }
  roads <- st_transform(roads, crs = project_crs)
  buffer_start <- Sys.time()
  message("--- Road buffering started at ", buffer_start)
  roads <- st_buffer(roads, 2000)
  buffer_end <- Sys.time()
  message("--- Road buffering completed at ", buffer_end)
  print(difftime(buffer_end, buffer_start))
  return(roads)
  
}

calculate_911 <- function(write_result = FALSE) {
  # Crop population and rural/urban rasters to outline of the country
  message("--- Extracting population at ", Sys.time())
  population <-
    raster::crop(GHS_POP, as(boundary, "Spatial")) %>% 
      raster::mask(as(boundary, "Spatial"))
  message("--- Extracting rural areas at ", Sys.time())
  area_type <-
    raster::crop(GHS_SMOD, as(boundary, "Spatial")) %>% 
      raster::mask(as(boundary, "Spatial"))
  
  # Turn all cells not equal to 1 to NA - rural only
  area_type[area_type != 1] <- NA
  
  # Multiply population by area_type to only keep populated rural cells
  rural_population <- population * area_type
  rural_population[rural_population == 0] <- NA
  
  # extract cell centroids
  message("--- Converting raster to points at ",
          Sys.time())
  rural_population_points <-
    as.data.frame(rasterToPoints(rural_population))
  total_rural_population <- 
    round(sum(rural_population_points[, 3]))
  
  # turn to SF and remove all points with no po
  raster_points_sf <-
    st_as_sf(rural_population_points,
             coords = c("x", "y"),
             crs = st_crs(GHS_POP))
  
  # only keep points within 2km
  message("--- Joining population points to buffered roads ",
          Sys.time())
  rural_population_in_buffer <-
    raster_points_sf[buffered_roads, op = st_within]
  rural_population_in_buffer <-
    round(sum(rural_population_in_buffer$layer))
  # calculate SDG 9.1.1 
  sdg_911 <- round(100 * (rural_population_in_buffer / total_rural_population),2)
  
  message(
    "--- Sustainable Development goal 9.1.1 for ",
    country$NAME,
    " :\n",
    "--- People living in rural areas: ",
    total_rural_population,
    "\n",
    "--- People living in rural areas and within 2km of a road: ",
    rural_population_in_buffer,
    "\n",
    "--- Indicator 9.1.1: ",
    sdg_911,
    "%"
  )
  # full output
  SDG_output <- data.frame(country,
                RURAL.POP.2KM = rural_population_in_buffer, 
                RURAL.POP = total_rural_population,
                SDG.9.1.1 = sdg_911)
  if (write_result == TRUE ){
  message("--- Write_result == TRUE: saving output to data/results")
  write_csv(SDG_output,paste0("data/results/",SDG_output$NAME,"_",SDG_output$UN.CODE,"_",Sys.Date(),".csv"))
  }
  return(SDG_output)
}

