# Renewable electricity generation, 2022 #

# Source: Department for Business, Energy & Industrial Strategy
# Publisher URL: https://www.gov.uk/government/statistics/regional-renewable-statistics
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/media/68da76d2c487360cc70c9e9d/Renewable_electricity_by_local_authority_2014_-_2024.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_excel(tmp, sheet = "LA - Generation, 2024", skip = 4) %>% 
  filter(`Local Authority Code [note 1]` %in% lookup) %>% 
  select(area_code = `Local Authority Code [note 1]`,
         area_name = `Local Authority Name  [note 5][note 6][note 7] [note 8][note 9]`,
         Photovoltaics:`Plant Biomass`) %>% 
  gather(group, value, -area_code, -area_name) %>% 
  mutate(value = as.numeric(value)) %>% #ifelse(value == "[X]", ))
  mutate(indicator = "Renewable electricity generation",
         period = "2024",
         measure = "Energy",
         unit = "MWh") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/renewable_electricity_generation.csv")
  