# Domestic property build period #

# Source: Valuation Office Agency 
# Publisher URL: https://www.gov.uk/government/collections/valuation-office-agency-council-tax-statistics
# Licence: Open Government Licence 3.0

library(tidyverse)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)


url <- "https://assets.publishing.service.gov.uk/media/6a0ad479f7c2e79c33db907d/CTSOP4.1.zip"
download.file(url, dest = "CTSOP4.1.zip")
unzip("CTSOP4.1.zip")
file.remove("CTSOP4.1.zip")

CTSOP4_1_2025_03_31


df <- read_csv("CTSOP4.1/CTSOP4_1_2025_03_31.csv") %>% 
  filter(band == "All", `ecode` %in% lookup) %>% 
  select(area_code = ecode, area_name, 6:33) %>% 
  gather(period, value, -area_code, -area_name) %>%
  mutate(period = str_replace(period, "bp_","")) %>%
  mutate(period = str_replace(period, "_","-")) %>%
  mutate(period = case_when(
    str_detect(period,"200") ~ "2000-2009",
    str_detect(period,"201") ~ "2010-2019",
    str_detect(period,"202") ~ "2020-2025",
    TRUE ~ period)) %>%
  group_by(area_code, area_name,period) %>%
  summarise(value = sum(as.numeric(value), na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(
    indicator = "Domestic property build period",
    measure = "Count",
    unit = "Dwellings") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value)
         
         

write_csv(df, "../data/domestic_property_build_period.csv")
