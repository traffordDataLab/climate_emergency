# Green belt #

# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/collections/green-belt-statistics
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readODS)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

tmp <- tempfile(fileext = ".ods")
GET(url = "https://assets.publishing.service.gov.uk/media/68e619b3ef1c2f72bc1e4ebd/Live_Tables_-_Green_Belt_Statistics_2024-25.ods",
    write_disk(tmp))

df <- read_ods(tmp, sheet = "Area_by_LA", skip = 2) %>%
  select(area_code = `Authority code`, area_name = `Authority name`,
         `Green Belt area` = `Area of land designated as Green Belt`,
         `Total area` = `Total area as at 31 December 2023 [note 5]`
         ) %>%
  filter(area_code %in% lookup) %>%
  mutate(`Green Belt area` = as.numeric(`Green Belt area`), `Total area` = as.numeric(`Total area`)) %>%
  pivot_longer(c("Green Belt area", "Total area"), names_to =  "indicator", values_to = "value") %>%
  mutate(period = "2024/25",
         measure = "Area",
         unit = "Hectares") %>%
  select(area_code, area_name, indicator, period, measure, unit, value)

write_csv(df, "../data/green_belt.csv")