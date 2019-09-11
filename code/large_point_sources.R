# Emissions from NAEI large point sources #

# Source: National Atmospheric Emissions Inventory
# URL: https://naei.beis.gov.uk/data/map-large-source
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate) ; library(sf)

url <- "https://naei.beis.gov.uk/mapping/mapping_2016/NAEIPointsSources_2016.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_excel(tmp, sheet = 2) %>% 
  setNames(tolower(names(.))) %>%
  filter(pollutant == "Carbon Dioxide as Carbon") %>% 
  mutate(period = ymd(str_c(year, "01-01", sep = "-")),
         operator = str_to_title(operator),
         indicator = "CO₂ emissions from point sources",
         measure = "CO₂",
         unit = "Tonnes") %>% 
  select(period, site, operator, operator, sector, indicator,
         value = emission, measure, unit,  easting, northing)

# Retrieve vector boundaries for local authority districts 
# Source: ONS Open Geography Portal
bdy <- st_read("https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Local_Authority_Districts_December_2018_Boundaries_UK_BGC/MapServer/0/query?where=1%3D1&outFields=lad18cd,lad18nm&outSR=4326&f=geojson") %>% 
  select(area_code = LAD18CD, area_name = LAD18NM)

sf <- df %>% 
  st_as_sf(crs = 27700, coords = c("easting", "northing")) %>% 
  st_transform(4326) %>% 
  st_join(bdy, join = st_within, left = FALSE) %>% 
  cbind(st_coordinates(.)) %>% 
  rename(lon = X, lat = Y)

write_csv(st_set_geometry(sf, NULL), "../data/large_point_sources.csv")

