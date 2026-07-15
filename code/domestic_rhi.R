# Domestic Renewable Heat Incentive #

# Source: Ofgem
# URL: https://www.gov.uk/government/collections/renewable-heat-incentive-statistics
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/media/661fb469ced96304c8757daf/RHI_monthly_official_stats_tables_March_2024.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = "2.4", skip = 10) %>% 
  filter(`Area Codes\r\n[note 1]` %in% lookup$area_code) %>% 
  mutate(area_name = case_when(is.na(`Local Authority Districts`) ~ `County or Unitary Authority`, TRUE ~ `Local Authority Districts`)) %>% 
  select(area_code = `Area Codes\r\n[note 1]`,
         area_name,
         value = `Number of accredited installations`) %>% 
  mutate(indicator = "Domestic Renewable Heat Incentive scheme",
         period = "2014-04 to 2024-03",
         measure = "Count",
         unit = "Accredited installations") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value) %>% 
  filter(!is.na(area_code))

write_csv(df, "../data/domestic_rhi.csv")
