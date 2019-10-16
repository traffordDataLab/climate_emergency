# Fuel poverty #

# Source: Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/statistics/sub-regional-fuel-poverty-data-2019
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)
source("https://github.com/traffordDataLab/assets/raw/master/theme/ggplot2/theme_lab.R")

tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/808294/Fuel_poverty_sub-regional_tables_2019.xlsx",
    write_disk(tmp))

df <- read_xlsx(tmp, sheet = 6, range = "A3:H32847") %>% 
  mutate(indicator = "Proportion of households in fuel poverty",
         period = "2017",
         measure = "Proportion",
         unit = "Households") %>% 
  select(lsoa11cd = `LSOA Code`, lsoa11nm = `LSOA Name`,
         area_code = `LA Code`, area_name = `LA Name`,
         indicator, period, measure, unit,
         value = `Proportion of households fuel poor (%)`) 
  
write_csv(df, "../data/fuel_poverty.csv")
