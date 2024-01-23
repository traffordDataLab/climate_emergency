# Fuel poverty #

# Source: Department for Business, Energy & Industrial Strategy
# URL: https://www.gov.uk/government/collections/fuel-poverty-statistics
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)
source("https://github.com/traffordDataLab/assets/raw/master/theme/ggplot2/theme_lab.R")

tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1153252/sub-regional-fuel-poverty-tables-2023-2021-data.xlsx",
    write_disk(tmp))

df <- read_xlsx(tmp, sheet = 7, range = "A3:H33758") %>% 
  mutate(indicator = "Proportion of households in fuel poverty",
         period = "2021",
         measure = "Proportion",
         unit = "Households") %>% 
  select(lsoa21cd = `LSOA Code`, lsoa21nm = `LSOA Name`,
         area_code = `LA Code`, area_name = `LA Name`,
         indicator, period, measure, unit,
         value = `Proportion of households fuel poor (%)`) 
  
write_csv(df, "../data/fuel_poverty.csv")
