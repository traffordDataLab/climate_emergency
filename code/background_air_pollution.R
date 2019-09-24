# Background air pollution #

# Source: Department for Environment, Food and Rural Affairs (Defra) 
# Publisher URL: https://uk-air.defra.gov.uk/data/laqm-background-home
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(sf)

# PM2.5 (2017)
setwd("PM25")
pm25 <- dir(pattern = "*.csv") %>% 
  map(read_csv, skip = 5) %>%
  reduce(rbind) %>% 
  select(Local_Auth_Code, `PM2.5` = Total_PM2.5_17, x, y) %>% 
  unite(coords, x, y, sep = ",", remove = FALSE)

# PM10 (2017)
setwd("PM10")
pm10 <- dir(pattern = "*.csv") %>% 
  map(read_csv, skip = 5) %>%
  reduce(rbind) %>% 
  select(`PM10` = Total_PM10_17, x, y) %>% 
  unite(coords, x, y, sep = ",", remove = TRUE)

# NO2 (2017)
setwd("NO2")
no2 <- dir(pattern = "*.csv") %>% 
  map(read_csv, skip = 5) %>%
  reduce(rbind) %>% 
  select(`NO2` = Total_NO2_17, x, y) %>% 
  unite(coords, x, y, sep = ",", remove = TRUE)

# Group pollutants into a single dataframe
df <- left_join(pm25, pm10, by = "coords") %>% 
  left_join(., no2, by = "coords") %>% 
  select(-coords)

# Retrieve UK local authority boundaries
# Source: ONS Open Geography Portal
uk <- st_read("https://opendata.arcgis.com/datasets/bbb0e58b0be64cc1a1460aa69e33678f_0.geojson") %>% 
  select(area_code = lad19cd, area_name = lad19nm) %>% 
  st_transform(27700)

# Convert pollution data to a spatial object
sf <- df %>% 
  st_as_sf(crs = 27700, coords = c("x", "y")) %>% 
  st_join(., uk, join = st_intersects) %>% 
  select(area_code, area_name, everything())

# Create 1km x 1km grid squares for the UK
cellsize = 1000
grid <- st_make_grid(
  st_as_sfc(
    st_bbox(sf) + 
      c(-cellsize/2, -cellsize/2, cellsize/2, cellsize/2),
    precision = 100),
  what = "polygons", cellsize = cellsize) %>% 
  st_sf(id = 1:length(.)) %>% 
  st_cast("MULTIPOLYGON") %>% 
  st_join(., sf, join = st_intersects) %>% 
  filter(., !is.na(area_code)) %>% 
  select(-Local_Auth_Code) %>% 
  st_transform(4326)

# Write results and then simplify geometry using https://mapshaper.org
st_write(grid, "background_air_pollution.geojson")