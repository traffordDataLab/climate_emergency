# Domestic Energy Performance Certificates by Environmental Impact Rating, 2009-2018 #

# Source: Ministry of Housing, Communities & Local Government 
# Publisher URL: https://www.gov.uk/government/statistical-data-sets/live-tables-on-energy-performance-of-buildings-certificates
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(httr) ; library(readxl) ; library(lubridate)

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/821971/D2_-_Domestic_EPCs.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 5) %>% 
  rename(area_name = `D2 - All Dwellings in England & Wales - Number of Energy Performance Certificates lodged on the Register by Local Authority and Environmental Impact Rating - in each Year/Quarter to 30/06/2019`) %>% 
  mutate(period = case_when(`...2` == "Year Total" ~ area_name, TRUE ~ ""),
         period = ymd(str_c(period, "01-01", sep = "-")),
         area_name = str_remove(area_name, "[[:digit:]]+"),
         area_name = str_remove(area_name, "Total"),
         area_name = na_if(area_name, "")) %>% 
  fill(area_name) %>% 
  filter(period >= "2009-01-01", period < "2019-01-01") %>% 
  select(area_name, period, 
         A = `...8`, B = `...9`, C = `...11`, D = `...13`, E = `...15`, 
         `F` = `...17`, G = `...19`) %>% 
  gather(group, value, -area_name, -period) %>% 
  mutate(indicator = "Domestic EPCs by Environmental Impact Rating",
         measure = "Lodgements",
         unit = "Count	") %>% 
  select(area_name, indicator, period, measure, unit, value, group)

write_csv(df, "../data/domestic_epcs.csv")
