# Ultra Low Emission Vehicles #

# Source: Department for Transport and Driver and Vehicle Licensing Agency 
# URL: https://www.gov.uk/government/statistical-data-sets/all-vehicles-veh01
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr);  library(readODS)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

# ULEVs
# NB Q4 is used as end of calendar year
url <- "https://assets.publishing.service.gov.uk/media/69ef35519ca985145673b9d7/veh0132.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

ulev <- read_ods(tmp, sheet = "VEH0132", skip = 4) %>%  
  filter(`ONS Code` %in% lookup, Fuel == "Total", Keepership == "Total") %>% 
  select(area_code = `ONS Code`, area_name = `ONS Geography`,
         ends_with("Q4")) %>% 
  gather(period, value, -area_code, -area_name) %>% 
  mutate(period = str_extract(period, "^.{4}"),
         indicator = "Ultra low emission vehicles",
         value = as.integer(value)) %>% 
  select(area_code, area_name, period, value, indicator)

# All licensed vehicles
url <- "https://assets.publishing.service.gov.uk/media/69ef3553ed93f72cf81633fc/veh0105.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

all_vehicles <- read_ods(tmp, sheet = "VEH0105", skip = 4) %>%
  filter(`Fuel` == "Total", `Keepership` == "Total", BodyType == "Total") %>%
  select(area_code = `ONS Code`, area_name = `ONS Geography`, starts_with("20")) %>%
  filter(area_code %in% lookup) %>%
  gather(period, value, -area_code, -area_name) %>% 
  filter(str_detect(period, "Q4")) %>%
  mutate(period = str_sub(period, 1,4),
         indicator = "All licensed vehicles",
         value = round(as.numeric(value),3)*1000) %>% 
  select(area_code, area_name, period, value, indicator)

df <- bind_rows(ulev, all_vehicles) %>% 
  mutate(measure = "Count",
         unit = "Vehicles") %>% 
  filter(period >= "2011") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value)

write_csv(df, "../data/ulev.csv")
