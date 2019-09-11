# Residual fuel consumption #

# Source: Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/statistical-data-sets/estimates-of-non-gas-non-electricity-and-non-road-transport-fuels-at-regional-and-local-authority-level
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/743503/residual_fuels_2005-16.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

sheets <- excel_sheets(tmp) 
df <- set_names(sheets[3:14]) %>% 
  map_df(~ read_xlsx(path = tmp, sheet = .x, range = "A3:N412"), .id = "sheet") %>% 
  filter(`...1` %in% lookup) %>% 
  mutate(Petroleum = pmap_dbl(select(., c(4:9)), sum),
         Coal = pmap_dbl(select(., c(10:11)), sum),
         `Manufactured solid fuels` = pmap_dbl(select(., c(12:13)), sum)) %>% 
  select(period = sheet,
         area_code = `...1`,
         area_name = `...2`,
         Petroleum, Coal, `Manufactured solid fuels`,
         `Bioenergy and Waste` = `All Sources`,
         Total = `...14`) %>% 
  gather(group, value, -area_code, -area_name, -period) %>% 
  mutate(indicator = "Residual fuel consumption",
         period = ymd(str_c(period, "01-01", sep = "-")),
         measure = "Oil",
         unit = "Thousand tonnes") %>% 
  select(area_code, area_name, 
         indicator, period, measure, unit, value, group)

write_csv(df, "../data/residual_fuel_consumption.csv")
