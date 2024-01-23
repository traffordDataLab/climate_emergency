# UK Wind Energy Locations #

# Source: Department for Business, Energy & Industrial Strategy
# Publisher URL: https://www.gov.uk/government/publications/renewable-energy-planning-database-monthly-extract
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(sf)

df <- read_csv("https://assets.publishing.service.gov.uk/media/65491f5a2f045e001214dc9d/repd-october-2023.csv") %>% 
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
uk <- st_read("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_December_2021_UK_BFE_2022/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=27700&f=json") %>% 
  select(area_code = LAD21CD, area_name = LAD21NM) 

# Convert data to a spatial object and write results
df <- df %>% 
  st_as_sf(crs = 27700, coords = c("X-coordinate", "Y-coordinate")) %>% 
  st_join(., uk, join = st_intersects) %>% 
  st_transform(4326) %>% 
  cbind(st_coordinates(.)) %>% 
  rename(lon = X, lat = Y) %>% 
  st_set_geometry(value = NULL) %>% 
  select(area_code, area_name, everything()) %>% 
  filter(!is.na(area_code)) 
%>%
  write_csv("../data/onshore_wind.csv")
