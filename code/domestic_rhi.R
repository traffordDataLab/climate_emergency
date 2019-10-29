# Domestic Renewable Heat Incentive #

# Source: Ofgem
# URL: https://www.gov.uk/government/collections/renewable-heat-incentive-statistics
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/839469/RHI_monthly_official_stats_tables_sept_19_final.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 20, skip = 4) %>% 
  filter(`Area Codes` %in% lookup$area_code) %>% 
  select(area_code = `Area Codes`,
         area_name = `Area names`,
         value = `Number of accredited installations`) %>% 
  mutate(indicator = "Domestic Renewable Heat Incentive scheme",
         period = "2014-04 to 2019-09",
         measure = "Count",
         unit = "Accredited installations",
         value = case_when(value %in% c("#", "^") ~ "NA", TRUE ~ value)) %>% 
  select(area_code, area_name, indicator, period, measure, unit, value)

write_csv(df, "../data/domestic_rhi.csv")
