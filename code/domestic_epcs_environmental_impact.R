# Domestic Energy Performance Certificates by Environmental Impact Rating, 2009-2018 #

# Source: Ministry of Housing, Communities & Local Government 
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/live-tables-on-energy-performance-of-buildings-certificates
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/821971/D2_-_Domestic_EPCs.xlsx"
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
         A = `...8`, B = `...9`, C = `...11`, D = `...13`, E = `...15`, `F` = `...17`, G = `...19`) %>% 
  gather(group, value, -area_name) %>% 
  mutate(indicator = "Domestic EPCs by Environmental Impact Rating",
         period = "2008-01-01 to 2019-09-30",
         measure = "Lodgements",
         unit = "Count") %>% 
  select(area_name, indicator, period, measure, unit, value, group)

# Local authority lookup
lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

df <- left_join(df, lookup, by = "area_name") %>% 
  select(area_code, everything())

write_csv(df, "../data/domestic_epcs_environmental_impact.csv")
