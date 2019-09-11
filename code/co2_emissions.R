# CO₂ emissions #

# Source: Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/statistics/uk-local-authority-and-regional-carbon-dioxide-emissions-national-statistics-2005-to-2017
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/812142/2005-17_UK_local_and_regional_CO2_emissions_tables.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_excel(tmp, sheet = 2, skip = 1) %>% 
  filter(!is.na(LAD14CD)) %>% 
  select(area_code = LAD14CD,
         area_name = LAD14NM,
         period = Year, 
         `Industry & Commercial Electricity` = `A. Industry and Commercial Electricity`,
         `Industry & Commercial Gas` = `B. Industry and Commercial Gas`,
         `Large Industrial Installations` = `C. Large Industrial Installations`,
         `Industrial & Commercial Other Fuels` = `D. Industrial and Commercial Other Fuels`,
         `Agricultural Combustion` = `E. Agriculture`,
         `Domestic Electricity` = `F. Domestic Electricity`,
         `Domestic Gas` = `G. Domestic Gas`,
         `Domestic Other Fuels` = `H. Domestic 'Other Fuels'`,
         `Road Transport (A roads)` = `I. Road Transport (A roads)`,
         `Road Transport (Motorways)` = `J. Road Transport (Motorways)`,
         `Road Transport (Minor roads)` = `K. Road Transport (Minor roads)`,
         `Diesel Railways` = `L. Diesel Railways`,
         `Transport Other` = `M. Transport Other`,
         `LULUCF Net Emissions` = `N. LULUCF Net Emissions`,
         `Domestic total` = `Domestic Total`,
         `Industry and commercial total` = `Industry and Commercial Total`,
         `Transport total` = `Transport Total`,
         `Total for all sectors` = `Grand Total`) %>% 
  gather(group, value, -area_code, -area_name, -period) %>% 
  mutate(indicator = "CO₂ emissions",
         period = ymd(str_c(period, "01-01", sep = "-")),
         measure = "CO₂",
         unit = "CO₂ (kt)") %>% 
  select(area_code, area_name, 
         indicator, period, measure, unit, value, group)

write_csv(df, "../data/co2_emissions.csv")
