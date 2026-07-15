# CO₂ emissions #

# Source: Department for Energy Security and Net Zero and Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/collections/uk-local-authority-and-regional-greenhouse-gas-emissions-national-statistics
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

df <- read_csv("https://assets.publishing.service.gov.uk/media/6a3bacc9d52550a19950f2f5/2005-24-local-authority-ghg-emissions-csv-dataset.csv") 

df1 <- df %>% 
  filter(`Local Authority Code` %in% lookup, `Greenhouse gas` == "CO2") %>% 
  select(area_code = `Local Authority Code`,
         area_name = `Local Authority`,
         period = `Calendar Year`, 
         value = `Territorial emissions (kt CO2e)`,
         sector = `LA GHG Sector`) %>%
  group_by(sector, period, area_name,area_code) %>%
  summarise(value = sum(value)) %>%
  mutate(indicator = "Territorial CO₂ emissions",
         measure = "CO₂",
         unit = "kt") %>%
  select(area_code, area_name,
         indicator, period, measure, unit, value, sector)

write_csv(df1, "../data/co2_emissions.csv")
