# Emissions from NAEI large point sources #

# Source: National Atmospheric Emissions Inventory
# URL: https://naei.beis.gov.uk/data/map-large-source
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate) ; library(sf)

#url: https://naei.energysecurity.gov.uk/data/maps/emissions-point-sources
url <- "https://naei.energysecurity.gov.uk/sites/default/files/2025-09/NAEIPointsSources_2023.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))



df <- read_excel(tmp, sheet = 4) 
dftest <- df %>% 
  setNames(tolower(names(.))) %>%
  filter(pollutant_name == "Carbon Dioxide as Carbon", year == 2023) %>% 
  mutate(indicator = "CO₂ emissions from point sources",
         measure = "CO₂") %>% 
  select(period = year, site, operator, sector, indicator,
         value = emission, measure, unit,  easting, northing)

# Retrieve vector boundaries for local authority districts 
# Source: ONS Open Geography Portal

bdy <- st_read("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_DEC_2025_Boundaries_UK_BFC/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=27700&f=geojson", quiet = TRUE) 
bdy2 <- bdy %>% 
  select(area_code = LAD25CD, area_name = LAD25NM)


sf <- dftest %>% 
  st_as_sf(crs = 27700, coords = c("easting", "northing")) %>% 
  st_join(bdy2, join = st_within, left = FALSE) 

sf2 <- sf %>% 
  st_transform(crs = 4326) %>%
  cbind(st_coordinates(.)) %>% 
  rename(lon = X, lat = Y) %>%
  st_set_geometry(., NULL)

write_csv(sf2, "../data/large_point_sources.csv")

