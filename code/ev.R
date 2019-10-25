# Electric vehicles #

# Source: Department for Transport and Driver and Vehicle Licensing Agency 
# URL: https://www.gov.uk/government/statistical-data-sets/all-vehicles-veh01
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr);  library(readODS)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv") %>% 
  pull(area_code)

# EVs (cars and vans)
# NB Q4 is used as end of calendar year
url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/794447/veh0131.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

ev <- read_ods(tmp, skip = 6)  %>%  
  filter(`ONS LA Code` %in% lookup) %>% 
  select(area_code = `ONS LA Code`, area_name = `Region/Local Authority`,
         ends_with("Q4")) %>% 
  gather(period, value, -area_code, -area_name) %>% 
  mutate(period = str_extract(period, "^.{4}"),
         group = "Electric cars and vans",
         value = as.integer(value)) %>% 
  select(area_code, area_name, period, value, group)

# All licensed vehicles with cars and vans subset
url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/794433/veh0105.ods"
GET(url, write_disk(tmp <- tempfile(fileext = ".ods")))

sheets <- tmp %>%
  ods_sheets() %>%
  set_names() %>% 
  map_df(~ read_ods(path = tmp, sheet = .x, 
                    col_names = TRUE, col_types = NA, skip = 7), .id = "sheet")

all <- sheets %>% 
  filter(`ONS LA Code` %in% lookup) %>% 
  mutate(period = sheet,
         `All cars and vans` = as.numeric(Cars)+as.numeric(`Light Goods Vehicles`),
         `All licensed vehicles` = as.numeric(Total)) %>% 
  select(area_code = `ONS LA Code`, area_name = `Region/Local Authority`, 
         period, `All cars and vans`, `All licensed vehicles`) %>% 
  gather(group, value, -area_name, -area_code, -period)

all$value <- all$value*1000

df <- bind_rows(ev, all) %>% 
  mutate(indicator = "Electric vehicles",
         measure = "Count",
         unit = "Vehicles")  %>% 
  filter(period >= "2011") %>% 
  select(area_code, area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/ev.csv")
