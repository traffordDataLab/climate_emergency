# Domestic Energy Performance Certificates by Energy Efficiency Rating #

# Source: Ministry of Housing, Communities & Local Government 
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/live-tables-on-energy-performance-of-buildings-certificates
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/843274/D1_-_Domestic_EPCs.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 5) %>% 
  rename(variable = 1) %>% 
  mutate(area_name = variable,
         area_name = str_remove(area_name, "[[:digit:]]+"),
         area_name = str_remove(area_name, "Total"),
         area_name = na_if(area_name, "")) %>% 
  fill(area_name) %>% 
  filter(variable == "Total") %>% 
  select(area_name, 
         A = `...8`, B = `...10`, C = `...12`, D = `...14`, E = `...16`, `F` = `...18`, G = `...20`) %>% 
  gather(group, value, -area_name) %>% 
  mutate(indicator = "Domestic EPCs by Energy Efficiency Rating",
         period = "2008-01-01 to 2019-09-30",
         measure = "Lodgements",
         unit = "Count") %>% 
  select(area_name, indicator, period, measure, unit, value, group)

# Local authority lookup
lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

df <- left_join(df, lookup, by = "area_name") %>% 
  select(area_code, everything())

write_csv(df, "../data/domestic_epcs_energy_efficiency.csv")
