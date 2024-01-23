# Domestic Energy Performance Certificates by Environmental Impact Rating #

# Source: Ministry of Housing, Communities & Local Government 
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/live-tables-on-energy-performance-of-buildings-certificates
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readODS) ; library(lubridate)

# Local authority lookup
lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

tmp <- tempfile(fileext = ".ods")
GET(url = "https://assets.publishing.service.gov.uk/media/65392240d10f3500139a6935/D2-_Domestic_Properties.ods",
    write_disk(tmp))

df <- read_ods(path = tmp, sheet = 8, 
               col_names = TRUE, skip = 3) %>%
  select(area_code = `Local.Authority.Code`, area_name = `Region`, period = Quarter, A:G) %>%
  filter(area_code %in% lookup$area_code) %>% 
  group_by(area_code, area_name) %>%
  separate (period, c("Year","quarter"), sep = "/") %>%
  filter(as.numeric(Year) >= 2013) %>%
  filter(!(as.numeric(Year) == 2013 &  as.numeric(quarter) %in% c(1,2,3))) %>%
  summarise_at(vars(A:G), sum) %>%
  pivot_longer(names_to = "impact", values_to = "value", cols = A:G) %>%
  mutate(indicator = "Domestic EPCs by Environmental Impact Rating",
         period = "2013/Q4 to 2023/Q3",
         measure = "Lodgements",
         unit = "Count") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, impact)

write_csv(df, "../data/domestic_epcs_environmental_impact.csv")
