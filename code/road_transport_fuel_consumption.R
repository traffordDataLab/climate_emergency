# Road transport energy consumption #

# Source: Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/statistical-data-sets/road-transport-energy-consumption-at-regional-and-local-authority-level
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/812411/Road_Transport_fuel_consumption_tables_2005-2017.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

sheets <- excel_sheets(tmp) 
df <- set_names(sheets[2:14]) %>% 
  map_df(~ read_xlsx(path = tmp, sheet = .x, range = "A4:AG413"), .id = "sheet") %>% 
  filter(`...1` %in% lookup) %>% 
  select(period = sheet,
         area_code = `...1`,
         area_name = `...2`,
         Buses = `Total consumption...6`,
         `Diesel cars` = `Total consumption...10`,
         `Petrol cars` = `Total consumption...14`,
         Motorcycles = `Total consumption...18`,
         HGV = `Total consumption...22`,
         `Diesel LGV` = `Total consumption...26`,
         `Petrol LGV` = `Total consumption...30`) %>% 
  gather(group, value, -area_code, -area_name, -period) %>% 
  mutate(indicator = "Road transport fuel consumption",
         period = ymd(str_c(period, "01-01", sep = "-")),
         measure = "Oil",
         unit = "Tonnes") %>% 
  select(area_code, area_name, 
         indicator, period, measure, unit, value, group)

write_csv(df, "../data/road_transport_fuel_consumption.csv")
