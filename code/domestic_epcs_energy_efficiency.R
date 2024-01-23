# Domestic Energy Performance Certificates by Energy Efficiency Rating #

# Source: Ministry of Housing, Communities & Local Government 
# Publisher URL: https://www.gov.uk/government/collections/energy-performance-of-buildings-certificates
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(lubridate) ; library(readODS);

# Local authority lookup
lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

tmp <- tempfile(fileext = ".ods")
GET(url = "https://assets.publishing.service.gov.uk/media/65392230e6c968000daa9ad2/D1-_Domestic_Properties.ods",
    write_disk(tmp))

df <- read_ods(path = tmp, sheet = 8, 
                    col_names = TRUE, skip = 3) %>%
  select(area_code = `Local Authority Code`, area_name = `Region`, period = Quarter, A:G) %>%
  filter(area_code %in% lookup$area_code) %>% 
  group_by(area_code, area_name) %>%
  separate (period, c("Year","quarter"), sep = "/") %>%
  filter(as.numeric(Year) >= 2013) %>%
  filter(!(as.numeric(Year) == 2013 &  as.numeric(quarter) %in% c(1,2,3))) %>%
  summarise_at(vars(A:G), sum) %>%
  pivot_longer(names_to = "efficiency", values_to = "value", cols = A:G) %>%
  mutate(indicator = "Domestic EPCs by Energy Efficiency Rating",
         period = "2013/Q4 to 2023/Q3",
         measure = "Lodgements",
         unit = "Count") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, efficiency)


write_csv(df, "../data/domestic_epcs_energy_efficiency.csv")
