# Boiler Upgrade Scheme #

# Source: DESNZ
# URL: https://www.gov.uk/government/collections/boiler-upgrade-scheme-statistics
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/media/6a3a620f30b491f55b3c477a/Boiler_Upgrade_Scheme_BUS_Statistics_May_2026.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = "A1.7", skip = 11) %>% 
  filter(`Area Codes` %in% lookup$area_code) %>%
  mutate(area_name = case_when(is.na(`Local Authority Districts`) ~ `County or Unitary Authority`, TRUE ~ `Local Authority Districts`)) %>% 
  select(area_code = `Area Codes`,area_name,starts_with("20")) %>%
  pivot_longer(3:6, names_to = "period", values_to = "value") %>%
  mutate(period = sub(":.*", "", period) ) %>%
  mutate(value = as.numeric(value)) %>%
  mutate(indicator = "Boiler Upgrade Scheme redemptions paid",
         measure = "Count",
         unit = "Heat pump technologies") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value) %>%
  filter(!is.na(area_code))

write_csv(df, "../data/boiler_upgrade_scheme.csv")
