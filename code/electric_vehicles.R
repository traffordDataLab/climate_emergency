# Electric vehicles #

# Source: Department for Transport and Driver and Vehicle Licensing Agency 
# URL: https://www.gov.uk/government/statistical-data-sets/all-vehicles-veh01
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr);  library(readODS)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/794447/veh0131.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

df <- read_ods(tmp, skip = 6)  %>%  
  filter(`ONS LA Code` %in% lookup) %>% 
  rename(area_code = `ONS LA Code`, area_name = `Region/Local Authority`) %>% 
  gather(period, value, -area_code, -area_name) %>% 
  mutate(quarter = 
           case_when(
             str_detect(period, "Q1") ~ "01-01",
             str_detect(period, "Q2") ~ "04-01",
             str_detect(period, "Q3") ~ "07-01",
             str_detect(period, "Q4") ~ "10-01"),
         period = parse_number(period),
         value = as.numeric(na_if(value, "c")),
         group = "Electric vehicles") %>% 
  unite(period, c("period", "quarter"), sep = "-") %>% 
  mutate(period = as.Date(period, format = "%Y-%m-%d"),
         indicator = "Electric vehicles",
         measure = "Vehicle",
         unit = "Count") %>% 
  select(area_code, area_name, 
         indicator, period, measure, unit, value, group)

write_csv(df, "../data/electric_vehicles.csv")

