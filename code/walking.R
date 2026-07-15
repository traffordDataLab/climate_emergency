# Walking # 

# Source: Department for Transport
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/walking-and-cycling-statistics-cw
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readODS) ; library(janitor)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/media/66ceee8f68c68ce5dc8b21fc/cw0303.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

df <- read_ods(tmp, sheet = 4, skip = 4) %>%
  filter(`ONS Code` %in% lookup,
         Purpose == "Any") %>% 
  select(area_code = `ONS Code`,
         area_name = `Area name`,
         value = `2023`,
         frequency = Frequency,
         )%>% 
  mutate(period = "2023",
         indicator = "Proportion of adults walking",
         measure = "Proportion",
         unit = "Percentage",
         value = round(as.numeric(value),1)) %>% 
  select(area_code, area_name, indicator, frequency, period, measure, unit, value)

write_csv(df, "../data/walking.csv")
