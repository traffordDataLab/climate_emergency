# Domestic energy consumption (2017) #

# Source: BEIS
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/total-final-energy-consumption-at-regional-and-local-authority-level
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833987/Sub-national-total-final-energy-consumption-statistics_2005-2017.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 28, skip = 3) %>% 
  filter(`LA Code` %in% lookup$area_code) %>% 
  select(area_code = `LA Code`,
         area_name = `Government Office Regions and LAU1 Areas`,
         Coal = `Domestic...4`,
         `Manufactured fuels` = `Domestic...9`,
         `Petroleum products` = `Domestic...13`,
         Gas = `Domestic...21`,
         Electricity = `Domestic...25`) %>% 
  gather(group, value, -area_code, -area_name) %>% 
  mutate(indicator = "Domestic energy consumption",
         period = "2017-01-01",
         measure = "Energy",
         unit = "Gigawatt hours (GWh") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/domestic_energy_consumption.csv")

