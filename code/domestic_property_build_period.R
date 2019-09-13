# Domestic property build period #

# Source: Valuation Office Agency 
# Publisher URL: https://www.gov.uk/government/statistics/council-tax-stock-of-properties-2018
# Licence: Open Government Licence 3.0

library(tidyverse)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

df <- read_csv("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/759805/Table_CTSOP4.0_2018.csv") %>% 
  filter(ECODE %in% lookup,
         BAND == "All") %>% 
  select(area_code = ECODE, area_name = AREA_NAME, 6:17) %>% 
  gather(group, value, -area_code, -area_name) %>% 
  mutate(group = case_when(
    group == "BP_PRE_1900" ~ "pre-1900",
    group == "BP_1900_1918" ~ "1900-1918",
    group == "BP_1919_1929" ~ "1919-1929",
    group == "BP_1930_1939" ~ "1930-1939",
    group == "BP_1945_1954" ~ "1945-1954",
    group == "BP_1955_1964" ~ "1955-1964",
    group == "BP_1965_1972" ~ "1965-1972",
    group == "BP_1973_1982" ~ "1973-1982",
    group == "BP_1983_1992" ~ "1983-1992",
    group == "BP_1993_1999" ~ "1993-1999",
    group == "BP_2000_2009" ~ "2000-2009",
    group == "BP_2010_2018" ~ "2010-2018"),
    indicator = "Domestic property build period",
    period = "2018-01-01",
    measure = "Dwellings",
    unit = "Count") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/domestic_property_build_period.csv")
