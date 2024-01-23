# Ultra Low Emission Vehicles #

# Source: Department for Transport and Driver and Vehicle Licensing Agency 
# URL: https://www.gov.uk/government/statistical-data-sets/all-vehicles-veh01
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr);  library(readODS)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

# ULEVs
# NB Q4 is used as end of calendar year
url <- "https://assets.publishing.service.gov.uk/media/6537df8a1bf90d0013d84520/veh0132.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

ulev <- read_ods(tmp, sheet = 4, skip = 4) %>%  
  filter(`ONS Code [note 6]` %in% lookup, Fuel == "Total", Keepership == "Total") %>% 
  select(area_code = `ONS Code [note 6]`, area_name = `ONS Geography [note 6]`,
         ends_with("Q4")) %>% 
  gather(period, value, -area_code, -area_name) %>% 
  mutate(period = str_extract(period, "^.{4}"),
         indicator = "Ultra low emission vehicles",
         value = as.integer(value)) %>% 
  select(area_code, area_name, period, value, indicator)

# All licensed vehicles
url <- "https://assets.publishing.service.gov.uk/media/6537df8b3099f900117f3089/veh0105.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

all_vehicles <- %>%
  filter(`Fuel..note.2.` == "Total", `Keepership..note.3.` == "Total", BodyType == "Total") %>%
  select(area_code = `ONS.Code..note.6.`, area_name = `ONS.Geography..note.6.`, starts_with("X")) %>%
  filter(area_code %in% lookup) %>%
  gather(period, value, -area_code, -area_name) %>% 
  filter(str_detect(period, "Q4")) %>%
  mutate(period = str_sub(period, 2,5),
         indicator = "All licensed vehicles",
         value = as.integer(value)*1000) %>% 
  select(area_code, area_name, period, value, indicator)

df <- bind_rows(ulev, all_vehicles) %>% 
  mutate(measure = "Count",
         unit = "Vehicles") %>% 
  filter(period >= "2011") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value)

write_csv(df, "../data/ulev.csv")
