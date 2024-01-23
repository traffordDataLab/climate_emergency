# Domestic energy consumption (2021) #

# Source: DESNZ, BEIS
# Publisher URL: https://www.gov.uk/government/collections/total-final-energy-consumption-at-sub-national-level
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1187087/Subnational_total_final_consumption_2005_2021.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 19, skip = 5) %>% 
  filter(`Code` %in% lookup$area_code) %>% 
  select(area_code = `Code`,
         area_name = `Local authority`,
         Coal = `Coal:\r\nDomestic`,
         `Manufactured fuels` = `Manufactured\r\nfuels:\r\nDomestic\r\n[note 3]`,
         `Petroleum products` = `Petroleum:\r\nDomestic`,
         Gas = `Gas:\r\nDomestic`,
         Electricity = `Electricity:\r\nDomestic`,
         `Bioenergy and wastes` = `Bioenergy \r\nand wastes:\r\nDomestic\r\n`) %>% 
  gather(group, value, -area_code, -area_name) %>% 
  mutate(indicator = "Domestic energy consumption",
         period = "2021",
         measure = "Energy",
         unit = "Thousands of tonnes of oil equivalent (ktoe)",
         value = as.numeric(value)) %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)



write_csv(df, "../data/domestic_energy_consumption.csv")

