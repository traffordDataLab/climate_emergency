# Recycling #

# Source: Department for Environment, Food & Rural Affairs
# URL: https://www.gov.uk/government/statistical-data-sets/env18-local-authority-collected-waste-annual-results-tables
# Licence: Open Government Licence

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/766014/LA_and_Regional_Spreadsheet_201718_rev2.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 8, skip = 3) %>% 
  filter(`ONS code` %in% lookup$area_code) %>%
  rename(area_code = `ONS code`) %>% 
  left_join(., lookup, by = "area_code") %>% 
  select(area_code, area_name,
         period = Year, 
         value = `Percentage of household waste sent for reuse, recycling or composting (Ex NI192)`) %>% 
  mutate(indicator = "Recycling",
         measure = "Percentage",
         unit = "Waste") %>% 
  select(area_code, area_name, period, indicator, measure, unit, value) %>% 
  arrange(period)

write_csv(df, "../data/recycling.csv")

