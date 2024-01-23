# Non-domestic Renewable Heat Incentive #

# Source: Ofgem
# URL: https://www.gov.uk/government/collections/renewable-heat-incentive-statistics
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1151594/RHI_monthly_official_stats_tables_Mar_23.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 9, skip = 10) %>% 
  filter(`Area Codes\r\n[note 1]` %in% lookup$area_code) %>% 
  mutate(area_name = case_when(is.na(`Local Authority Districts`) ~ `County or Unitary Authority`, TRUE ~ `Local Authority Districts`)) %>% 
  select(area_code = `Area Codes\r\n[note 1]`,
         area_name,
         value = `Number of accredited full applications`) %>% 
  mutate(indicator = "Non-domestic Renewable Heat Incentive sheme",
         period = "2011-11 to 2023-03",
         measure = "Count",
         unit = "Accredited applications",
         value = case_when(value %in% c("#", "^") ~ "NA", TRUE ~ value)) %>% 
  select(area_code, area_name, indicator, period, measure, unit, value) 

write_csv(df, "../data/non-domestic_rhi.csv")
