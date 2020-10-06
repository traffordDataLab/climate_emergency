# Background air pollution: 2019 # 

# Source: Department for Environment, Food and Rural Affairs (Defra) 
# Publisher URL: https://uk-air.defra.gov.uk/data/laqm-background-home
# Licence: Open Government Licence 3.0

# NB: Cycle through "Download Data Sets for regions" by pollutant

library(tidyverse) ; library(sf)

# PM2.5 (2019)
setwd("PM25")
pm25 <- dir(pattern = "*.csv") %>% 
  map(read_csv, skip = 5) %>%
  reduce(rbind) %>% 
  select(Local_Auth_Code, `PM25` = Total_PM2.5_19, x, y) %>% 
  unite(coords, x, y, sep = ",", remove = FALSE)

# PM10 (2019)
setwd("../PM10")
pm10 <- dir(pattern = "*.csv") %>% 
  map(read_csv, skip = 5) %>%
  reduce(rbind) %>% 
  select(`PM10` = Total_PM10_19, x, y) %>% 
  unite(coords, x, y, sep = ",", remove = TRUE)

# NO2 (2019)
setwd("../NO2")
no2 <- dir(pattern = "*.csv") %>% 
  map(read_csv, skip = 5) %>%
  reduce(rbind) %>% 
  select(`NO2` = Total_NO2_19, x, y) %>% 
  unite(coords, x, y, sep = ",", remove = TRUE)

# Group pollutants into a single dataframe
df <- left_join(pm25, pm10, by = "coords") %>% 
  left_join(., no2, by = "coords") %>% 
  select(-coords)

# Retrieve UK local authority boundaries
# Source: ONS Open Geography Portal
# NB: ensure CRS = 27700 and precision = 3
uk <- st_read("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_May_2020_UK_BGC_V3/FeatureServer/0/query?where=1%3D1&outFields=LAD20CD,LAD20NM&outSR=27700&geometryPrecision=3&f=geojson") %>% 
  select(area_code = LAD20CD, area_name = LAD20NM)

# Convert pollution data to a spatial object
sf <- df %>% 
  st_as_sf(crs = 27700, coords = c("x", "y")) %>% 
  st_join(., uk, join = st_intersects) %>% 
  select(area_code, area_name, everything())

# Create 1km x 1km grid squares for the UK
cellsize <- 1000
grid <- st_make_grid(
  st_as_sfc(
    st_bbox(sf) + 
      c(-cellsize/2, -cellsize/2, cellsize/2, cellsize/2),
    precision = 10),
  what = "polygons", cellsize = cellsize) %>% 
  st_sf(index = 1:length(lengths(.)), .) %>% 
  st_join(., sf, join = st_intersects) %>% 
  filter(., !is.na(area_code)) %>% 
  select(-Local_Auth_Code) %>% 
  st_transform(4326)

# Write results and then simplify geometry using https://mapshaper.org
st_write(t, "background_air_pollution.shp")
