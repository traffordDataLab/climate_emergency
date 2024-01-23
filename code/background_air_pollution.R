# Background air pollution: 2021 # 

# Source: Department for Environment, Food and Rural Affairs (Defra) 
# Publisher URL: https://uk-air.defra.gov.uk/data/pcm-data
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(sf)

# PM2.5 (2021)
pm25 <- read_csv("https://uk-air.defra.gov.uk/datastore/pcm/mappm252022g.csv", skip = 5)

# PM10 (2021)
pm10 <- read_csv("https://uk-air.defra.gov.uk/datastore/pcm/mappm102022g.csv", skip = 5)

# NO2 (2021)
no2 <- read_csv("https://uk-air.defra.gov.uk/datastore/pcm/mapno22022.csv", skip = 5)

# Group pollutants into a single dataframe
df <- left_join(pm25, pm10, by = c("gridcode","x","y")) %>% 
  left_join(., no2, by = c("gridcode","x","y")) %>% 
  select(-gridcode)

# Retrieve UK local authority boundaries
# Source: ONS Open Geography Portal
# NB: ensure CRS = 27700. (BUC) Ultra generalised (500m)
uk <- st_read("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_December_2021_UK_BUC_2022/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=27700&f=json") %>% 
  select(area_code = LAD21CD, area_name = LAD21NM)

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
  st_transform(4326)

# Write results and then simplify geometry using https://mapshaper.org
st_write(grid, "../data/background_air_pollution2022.shp")
