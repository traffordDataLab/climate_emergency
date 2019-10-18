# Green belt #

# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/collections/green-belt-statistics
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr) ; library(readxl)

tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/840241/Live_Tables_Green_Belt_Statistics_2018-19.xlsx",
    write_disk(tmp))

df <- read_xlsx(tmp, sheet = 4, range = "A4:G193") %>% 
  select(area_code = `ONS code`, area_name = `Local planning authority`,
         green_belt_area = `Designated Green Belt area`,
         total_area = `Total area as at 31 December 2018`
         ) %>% 
  filter(!is.na(area_code), 
         green_belt_area != "-") %>% 
  arrange(area_name) %>% 
  mutate(green_belt_area = as.integer(green_belt_area),
         period = "2019-03-31 ",
         indicator = "Green belt land",
         measure = "Area",
         unit = "Hectares") %>%
  select(area_code, area_name, indicator, period, measure, unit, green_belt_area, total_area)

write_csv(df, "../data/green_belt.csv")
