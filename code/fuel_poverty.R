# Fuel poverty #

# Source: Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/collections/fuel-poverty-statistics
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)

tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://assets.publishing.service.gov.uk/media/6a02febf81a251700a20b42a/fuel-poverty-sub-regional-2026-2024-data-tables.xlsx",
    write_disk(tmp))

df <- read_xlsx(tmp, sheet = "Table 4", skip = 2) %>% 
  mutate(indicator = "Proportion of households in fuel poverty",
         period = "2024",
         measure = "Proportion",
         unit = "Households") %>% 
  select(lsoa21cd = `LSOA Code`, lsoa21nm = `LSOA Name`,
         area_code = `Local Authority Code`, area_name = `Local Authority Name`,
         indicator, period, measure, unit,
         value = `Proportion of households fuel poor (%)`) %>%
  filter(!is.na(area_name))
test <- df %>% select(area_name) %>% unique()
  
write_csv(df, "../data/fuel_poverty.csv")
