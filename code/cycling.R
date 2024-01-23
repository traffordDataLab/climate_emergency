# Cycling # 

# Source: Department for Transport
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/walking-and-cycling-statistics-cw
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readODS) ; 
library(janitor)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/media/64ee10386bc96d000d4ed24f/cw0302-proportion-of-adults-that-cycle-by-frequency-purpose-and-local-authority.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

df <- read_ods(tmp, sheet = 4, skip = 4) %>%
  filter(ONS.Code %in% lookup) %>% 
  select(area_code = ONS.Code,
         area_name = Area.name,
         value = X2022,
         frequency = Frequency,
         ) %>% 
  #gather(Frequency, value, -area_code, -area_name) %>% 
  mutate(period = "2022",
         indicator = "Proportion of adults cycling",
         measure = "Proportion",
         unit = "Percentage",
         value = round(as.numeric(value),1)) %>% 
  select(area_code, area_name, indicator, frequency, period, measure, unit, value)

write_csv(df, "../data/cycling.csv")
