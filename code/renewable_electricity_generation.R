# Renewable electricity generation, 2017 #

# Source: Department for Business, Energy & Industrial Strategy
# Publisher URL: https://www.gov.uk/government/statistics/regional-renewable-statistics
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/834142/Renewable_electricity_by_local_authority_2014_to_2018.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_excel(tmp, sheet = 12, skip = 2) %>% 
  filter(`Local Authority Code4` %in% lookup) %>% 
  select(area_code = `Local Authority Code4`,
         area_name = `Local Authority Name`,
         6:17) %>% 
  gather(group, value, -area_code, -area_name) %>% 
  mutate(indicator = "Renewable electricity generation",
         period = "2018-01-01",
         measure = "Energy",
         unit = "MWh") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/renewable_electricity_generation.csv")
  