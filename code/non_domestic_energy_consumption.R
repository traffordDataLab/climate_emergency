# Non domestic energy consumption (2016) #

# Source: BEIS
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/total-final-energy-consumption-at-regional-and-local-authority-level
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/825965/Sub-national-total-final-energy-consumption-statistics-2005-2016-revised-19082019.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 26, skip = 3) %>% 
  filter(`LA Code (7)` %in% lookup$area_code) %>% 
  select(area_code = `LA Code (7)`,
         area_name = `Government Office Regions and LAU1 Areas`,
         Coal = `Industrial & Commercial...3`,
         `Manufactured fuels` = `Industrial`,
         `Petroleum products` = `Industrial & Commercial...12`,
         Gas = `Industrial & Commercial...18`,
         Electricity = `Industrial & Commercial...22`) %>% 
  gather(group, value, -area_code, -area_name) %>% 
  mutate(indicator = "Non domestic energy consumption",
         period = "2016-01-01",
         measure = "Energy",
         unit = "Gigawatt Hours (GWh") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/non_domestic_energy_consumption.csv")

