# Background air pollution #

# Source: Department for Environment, Food and Rural Affairs (Defra) 
# Publisher URL: https://uk-air.defra.gov.uk/data/laqm-background-home
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(sf)

# Download NO2, PM10 or PM2.5 background concentrations for your local authority
# Source: https://uk-air.defra.gov.uk/data/laqm-background-maps?year=2017

# Create a string object with the name of your local authority
id <- "Trafford"

# Retrieve the local authority boundary projected in British National Grid (EPSG 27700)
# Source: ONS Open Geography Portal
la <- st_read(paste0("https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Local_Authority_Districts_December_2018_Boundaries_UK_BGC/MapServer/0/query?where=UPPER(lad18nm)%20like%20'%25", URLencode(toupper(id), reserved = TRUE), "%25'&outFields=lad18cd,lad18nm,long,lat&outSR=27700&f=geojson"), quiet = TRUE) %>% 
  select(area_code = lad18cd, area_name = lad18nm, lon = long, lat)

# Read pollution data, choose variables (including pollutant) and convert to a spatial object
sf <- read_csv("286-pm25-2017.csv", skip = 5) %>% 
  select(Local_Auth_Code, 
         value = Total_PM2.5_17, 
         x, y) %>% 
  st_as_sf(crs = 27700, coords = c("x", "y")) 

# Create 1 km x 1 km grid squares for the local authority
cellsize = 1000
grid <- st_make_grid(
  st_as_sfc(
    st_bbox(sf) + 
      c(-cellsize/2, -cellsize/2, cellsize/2, cellsize/2)),
  what = "polygons", cellsize = cellsize) %>% 
  st_sf(id = 1:length(.)) %>% 
  st_cast("MULTIPOLYGON") %>% 
  st_join(., sf, join = st_intersects) %>% 
  filter(., !is.na(Local_Auth_Code)) %>% 
  select(-Local_Auth_Code) %>% 
  st_transform(4326)

# Write results as a GeoJSON
st_write(grid, "../data/background_air_pollution.geojson")
