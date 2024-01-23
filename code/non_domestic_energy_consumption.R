# Non domestic energy consumption (2017) #

# Source: BEIS
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/total-final-energy-consumption-at-regional-and-local-authority-level
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

#url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833987/Sub-national-total-final-energy-consumption-statistics_2005-2017.xlsx"

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1187087/Subnational_total_final_consumption_2005_2021.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

dfr <- read_xlsx(tmp, sheet = 19, skip = 5) 

df <- dfr %>% 
  filter(`Code` %in% lookup$area_code) %>% 
  mutate(Coal = `Coal:\r\nIndustrial\r\n[note 2]`+ `Coal:\r\nCommercial`,
         `Manufactured fuels` = `Manufactured fuels:\r\nIndustrial\r\n[note 3]`,
         `Petroleum products` = `Petroleum:\r\nIndustrial` + `Petroleum: \r\nCommercial`,
         Gas = `Gas:\r\nIndustrial,\r\nCommercial\r\nand other`,
         Electricity = `Electricity:\r\nIndustrial,\r\nCommercial\r\nand other`,
         `Bioenergy and wastes` = `Bioenergy \r\nand wastes:\r\nIndustrial and\r\nCommercial`) %>%
  select(area_code = `Code`,
         area_name = `Local authority`,
         Coal, `Manufactured fuels`, `Petroleum products`, Gas, Electricity, `Bioenergy and wastes`) %>%
  gather(group, value, -area_code, -area_name) %>% 
  mutate(indicator = "Industrial and commercial energy consumption",
         period = "2021",
         measure = "Energy",
         unit = "Thousands of tonnes of oil equivalent (ktoe)",
         value = as.numeric(value)) %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/non_domestic_energy_consumption.csv")

