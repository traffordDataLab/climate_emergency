# UK Wind Energy Locations #

# Source: Department for Business, Energy & Industrial Strategy
# Publisher URL: https://www.gov.uk/government/publications/renewable-energy-planning-database-monthly-extract
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(sf)

df <- read_csv("https://assets.publishing.service.gov.uk/media/69fc56908cc72d2f863ea58d/REPD_publication_Q1_2026.csv") %>% 
  filter(!is.na(`X-coordinate`),
         `Technology Type` == "Wind Onshore",
         `Development Status` == "Operational") %>% 
  select(name = `Site Name`,
         operator = `Operator (or Applicant)`,
         type = `Technology Type`,
         turbines = `No. of Turbines`,
         capacity = `Turbine Capacity (MW)`,
         address = Address,
         county = County,
         `X-coordinate`, `Y-coordinate`)

# Retrieve UK local authority boundaries
# Source: ONS Open Geography Portal
uk <- st_read("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_DEC_2025_Boundaries_UK_BFC/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=27700&f=geojson", quiet = TRUE) %>% 
  select(area_code = LAD25CD, area_name = LAD25NM)

# Convert data to a spatial object and write results
df <- df %>% 
  st_as_sf(crs = 27700, coords = c("X-coordinate", "Y-coordinate")) %>% 
  st_join(., uk, join = st_intersects) %>% 
  st_transform(4326) %>% 
  cbind(st_coordinates(.)) %>% 
  rename(lon = X, lat = Y) %>% 
  st_set_geometry(value = NULL) %>% 
  select(area_code, area_name, everything()) %>% 
  filter(!is.na(area_code)) %>%
  write_csv("../data/onshore_wind.csv")
