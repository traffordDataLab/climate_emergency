# CO₂ emissions #

# Source: Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/statistics/uk-local-authority-and-regional-carbon-dioxide-emissions-national-statistics-2005-to-2017
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/812142/2005-17_UK_local_and_regional_CO2_emissions_tables.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_excel(tmp, sheet = 3, skip = 1) %>% 
  filter(LAD14CD %in% lookup | LAD14NM == "National Total") %>% 
  select(area_code = LAD14CD,
         area_name = LAD14NM,
         period = Year, 
         `Domestic` = `Domestic Total`,
         `Industry and commercial` = `Industry and Commercial Total`,
         `Transport` = `Transport Total`) %>% 
  mutate(area_name = 
           case_when(area_name == "National Total" ~ "UK", TRUE ~ area_name)
         ) %>% 
  gather(group, value, -area_code, -area_name, -period) %>% 
  mutate(indicator = "CO₂ emissions",
         period = ymd(str_c(period, "01-01", sep = "-")),
         measure = "CO₂",
         unit = "CO₂ (kt)") %>% 
  select(area_code, area_name, 
         indicator, period, measure, unit, value, group)

write_csv(df, "../data/co2_emissions.csv")
