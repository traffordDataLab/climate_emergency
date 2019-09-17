# Cycling # 

# Source: Department for Transport
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/walking-and-cycling-statistics-cw
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readODS) ; library(janitor)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/821812/CW0302.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

df <- read_ods(tmp, sheet = 1, skip = 7) %>%
  clean_names() %>%
  filter(la_code %in% lookup) %>% 
  select(area_code = la_code,
         area_name = local_authority4,
         4:7) %>% 
  gather(group, value, -area_code, -area_name) %>% 
  mutate(period = "2017-11-15 - 2018-11-15",
         indicator = "Proportion of adults cycling",
         measure = "Persons",
         unit = "Percentage",
         group = str_replace_all(str_to_title(group), "_", " ")) %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/cycling.csv")
