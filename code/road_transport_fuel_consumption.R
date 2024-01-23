# Road transport energy consumption #

# Source: Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/collections/road-transport-consumption-at-regional-and-local-level
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1165225/road-transport-fuel-consumption-tables-2005-2021.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

sheets <- excel_sheets(tmp) 
df <- set_names(sheets[3:19]) %>% 
  map_df(~ read_xlsx(path = tmp, sheet = .x, range = "A4:AI397"), .id = "sheet") %>% 
  filter(`Local Authority Code` %in% lookup) %>% 
  select(period = sheet,
         area_code = `Local Authority Code`,
         area_name = `Local Authority [Note 4]`,
         Buses = `Buses total`,
         `Diesel cars` = `Diesel cars total`,
         `Petrol cars` = `Petrol cars total`,
         Motorcycles = `Motorcycles total`,
         HGV = `HGV total`,
         `Diesel LGV` = `Diesel LGV total`,
         `Petrol LGV` = `Petrol LGV total`) %>% 
  gather(group, value, -area_code, -area_name, -period) %>% 
  mutate(indicator = "Road transport energy consumption",
         period = ymd(str_c(period, "01-01", sep = "-")),
         measure = "Count",
         unit = "Thousand tonnes of oil equivalent (ktoe)") %>% 
  select(area_code, area_name, 
         indicator, period, measure, unit, value, group)

write_csv(df, "../data/road_transport_fuel_consumption.csv")
