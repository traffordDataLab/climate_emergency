# Domestic Renewable Heat Incentive #

# Source: Ofgem
# URL: https://www.gov.uk/government/collections/renewable-heat-incentive-statistics
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1151594/RHI_monthly_official_stats_tables_Mar_23.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

area_name_match <- read_xlsx(tmp, sheet = 7, skip = 10) %>% 
  filter(`Area Codes` %in% lookup$area_code) %>% 
  mutate(area_name = case_when(is.na(`...4`) ~ `...3`, TRUE ~ `...4`)) %>% 
  select(area_code = `Area Codes`, area_name)

df <- read_xlsx(tmp, sheet = 27, skip = 10) %>% 
  filter(`Area Codes\r\n[note 1]` %in% lookup$area_code) %>% 
  mutate(area_name = case_when(is.na(`Local Authority Districts`) ~ `County or Unitary Authority`, TRUE ~ `Local Authority Districts`)) %>% 
  select(area_code = `Area Codes\r\n[note 1]`,
         area_name,
         value = `Number of accredited installations`) %>% 
  mutate(indicator = "Domestic Renewable Heat Incentive scheme",
         period = "2014-04 to 2023-03",
         measure = "Count",
         unit = "Accredited installations") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value) %>% 
  filter(!is.na(area_code))

write_csv(df, "../data/domestic_rhi.csv")
