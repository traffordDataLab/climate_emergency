# UK Wind Energy Locations #

# Source: Department for Business, Energy & Industrial Strategy
# Publisher URL: https://www.gov.uk/government/publications/renewable-energy-planning-database-monthly-extract
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(sf)

df <- read_csv("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/857611/renewable-energy-planning-database-december-2019.csv",
               skip = 1) %>% 
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
uk <- st_read("https://opendata.arcgis.com/datasets/16221426b9ee468d9c80f8398ded851f_0.geojson") %>% 
  select(area_code = LAD19CD, area_name = LAD19NM) %>% 
  st_transform(27700)

# Convert data to a spatial object and write results
df %>% 
  st_as_sf(crs = 27700, coords = c("X-coordinate", "Y-coordinate")) %>% 
  st_join(., uk, join = st_intersects) %>% 
  st_transform(4326) %>% 
  cbind(st_coordinates(.)) %>% 
  rename(lon = X, lat = Y) %>% 
  st_set_geometry(value = NULL) %>% 
  select(area_code, area_name, everything()) %>% 
  filter(!is.na(area_code)) %>%
  write_csv("../data/onshore_wind.csv")
