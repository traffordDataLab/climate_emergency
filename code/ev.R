# Electric vehicles #

# Source: Department for Transport and Driver and Vehicle Licensing Agency 
# URL: https://www.gov.uk/government/statistical-data-sets/all-vehicles-veh01
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr);  library(readODS)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

# EVs (cars and vans)
# NB Q4 is used as end of calendar year
url <- "https://assets.publishing.service.gov.uk/media/6537df8b3099f900117f308a/veh0142.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

ev <- read_ods(tmp, sheet = 4, skip = 4) %>%
  filter(BodyType %in% c("Light goods vehicles", "Cars"), `Keepership..note.3.` == "Total", Fuel == "Total") %>%
  select(area_code = `ONS.Code..note.6.`, area_name = `ONS.Geography..note.6.`, starts_with("X")) %>%
  filter(area_code %in% lookup) %>%
  gather(period, value, -area_code, -area_name) %>% 
  filter(str_detect(period, "Q4")) %>%
  group_by(area_code, area_name, period) %>%
  summarise(value = sum(as.integer(value))) %>%
  ungroup() %>%
  mutate(period = str_sub(period, 2,5),
         indicator = "Electric cars and vans") %>% 
  select(area_code, area_name, period, value, indicator)

# All licensed vehicles with cars and vans subset
url <- "https://assets.publishing.service.gov.uk/media/6537df8b3099f900117f3089/veh0105.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

all_and_subset <- read_ods(tmp, col_names = TRUE, sheet = 4, skip = 4) %>%
  filter(BodyType %in% c("Light goods vehicles", "Cars", "Total"), `Keepership..note.3.` == "Total", `Fuel..note.2.` == "Total") %>%
  select(area_code = `ONS.Code..note.6.`, area_name = `ONS.Geography..note.6.`, BodyType, starts_with("X")) %>%
  filter(area_code %in% lookup) %>%
  gather(period, value, -area_code, -area_name, -BodyType) %>% 
  filter(str_detect(period, "Q4")) %>%
  mutate(indicator = ifelse(BodyType %in% c("Light goods vehicles", "Cars"), "All cars and vans", "All licensed vehicles")) %>%
  group_by(area_code, area_name, period, indicator) %>%
  summarise(value = sum(as.integer(value))) %>%
  ungroup() %>%
  mutate(period = str_sub(period, 2,5),
         value = as.integer(value)*1000) %>% 
  select(area_code, area_name, period, value, indicator)

df <- bind_rows(ev, all_and_subset) %>% 
  mutate(
         measure = "Count",
         unit = "Vehicles")  %>% 
  filter(period >= "2011") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value)

write_csv(df, "../data/ev.csv")
