# Domestic property build period #

# Source: Valuation Office Agency 
# Publisher URL: https://www.gov.uk/government/collections/valuation-office-agency-council-tax-statistics
# Licence: Open Government Licence 3.0

library(tidyverse)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1162254/CTSOP4.0_time_series.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 33, skip = 4) %>% 
  filter(band == "All", `ecode` %in% lookup) %>% 
  select(area_code = ecode, area_name, 6:30) %>% 
  gather(period, value, -area_code, -area_name) %>%
  mutate(period = str_replace(period, "bp_","")) %>%
  mutate(period = str_replace(period, "_","-")) %>%
  mutate(period = case_when(
    str_detect(period,"200") ~ "2000-2009",
    str_detect(period,"201") ~ "2010-2019",
    str_detect(period,"202") ~ "2020-2023",
    TRUE ~ period)) %>%
  group_by(area_code, area_name,period) %>%
  summarise(value = sum(as.numeric(value))) %>%
  ungroup() %>%
  mutate(
    indicator = "Domestic property build period",
    measure = "Count",
    unit = "Dwellings") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value)
         
         

write_csv(df, "../data/domestic_property_build_period.csv")
