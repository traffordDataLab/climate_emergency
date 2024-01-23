# Recycling #

library(tidyverse) ; library(httr) ; library(readxl) ; library(jsonlite) ; library(rvest)

lookup <- read_csv("../data/geospatial/local_authority_codes.csv")

# England ---------------------------
# Source: WasteDataFlow, Defra
# URL: https://www.gov.uk/government/statistical-data-sets/env18-local-authority-collected-waste-annual-results-tables
# Licence: Open Government Licence

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1144270/LA_and_Regional_Spreadsheet_202122.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

england <- read_xlsx(tmp, sheet = 8, skip = 3) %>% 
  rename(area_code = `ONS code`) %>% 
  filter(area_code %in% lookup$area_code,
         Year >= "2015-16",) %>%
  left_join(., lookup, by = "area_code") %>% 
  mutate(period = str_replace_all(Year, "-", "/"),
         value = `Percentage of household waste sent for reuse, recycling or composting (Ex NI192)`*100) %>% 
  select(area_code, area_name, period, value) %>% 
  mutate(indicator = "Recycling",
         measure = "Proportion",
         unit = "Percent") %>% 
  select(area_code, area_name, period, indicator, measure, unit, value) %>% 
  arrange(period)

# Wales ---------------------------
# Source: StatsWales
# URL: https://statswales.gov.wales/Catalogue/Environment-and-Countryside/Waste-Management/Local-Authority-Municipal-Waste?_ga=2.8735536.466877265.1566485268-90885788.1562851545
# Licence: Open Government Licence

variable <- "Measure_ItemName_ENG"
measure <- URLencode("Percentage of Waste Reused/Recycled/Composted (Statutory Target)")

query <- paste0("http://open.statswales.gov.wales/en-gb/dataset/envi0017?$filter=",
                variable, "%20eq%20%27", measure, "%27") 

wales <- fromJSON(query)[[2]] %>% 
  filter(Area_AltCode1 %in% lookup$area_code,
         Year_ItemName_ENG >= "2015-16") %>% 
  select(area_code = Area_AltCode1,
         area_name = Area_ItemName_ENG,
         period = Year_ItemName_ENG,
         value = Data) %>% 
  mutate(period = str_replace_all(period, "-", "/"),
         value = round(value,1), 
         indicator = "Recycling",
         measure = "Percentage",
         unit = "Waste") %>% 
  select(area_code, area_name, period, indicator, measure, unit, value) %>% 
  arrange(period)

# Scotland ---------------------------
# Scottish Environment Protection Agency 
# URL: https://www.sepa.org.uk/environment/waste/waste-data/waste-data-reporting/household-waste-data
# Licence: Open Government Licence

links <- c("https://www.sepa.org.uk/media/ekpbgrvk/scottish-household-waste-generated-and-managed-data-tables.xlsx",
           "https://www.sepa.org.uk/media/594460/2021-household-data-tables.xlsx",
           "https://www.sepa.org.uk/media/532206/2019-household-waste-data-tables.xlsx",
           "https://www.sepa.org.uk/media/469611/2018-household-waste-data-tables.xlsx",
           "https://www.sepa.org.uk/media/378875/2017-household-waste-summary-tables-final.xlsx",
           "https://www.sepa.org.uk/media/320743/household-waste-summary-2016.xlsx",
           "https://www.sepa.org.uk/media/219490/household-waste-summary-data-2015.xlsx"
           )

walk(links, ~{GET(url = .x,  write_disk(file.path(".", basename(.x))))})

scotland_22 <- read_xlsx("scottish-household-waste-generated-and-managed-data-tables.xlsx", sheet = 3, range = "B4:E36") %>% 
  mutate(period = "2022") %>% 
  select(area_name = 1, period, value = 4)

#revised
scotland_21 <- read_xlsx("scottish-household-waste-generated-and-managed-data-tables.xlsx", sheet = 3, range = "B4:L36") %>% 
  mutate(period = "2021") %>% 
  select(area_name = 1, period, value = 11)

#revised
scotland_20 <- read_xlsx("2021-household-data-tables.xlsx", sheet = 3, range = "B4:L36") %>% 
  mutate(period = "2020") %>% 
  select(area_name = 1, period, value = 11)

scotland_19 <- read_xlsx("2019-household-waste-data-tables.xlsx", sheet = 3, range = "B4:L36") %>% 
  mutate(period = "2019") %>% 
  select(area_name = 1, period, value = 4)

scotland_18 <- read_xlsx("2018-household-waste-data-tables.xlsx", sheet = 3, range = "B4:E36") %>% 
  mutate(period = "2018") %>% 
  select(area_name = 1, period, value = 4)

#revised
scotland_17 <- read_xlsx("2018-household-waste-data-tables.xlsx", sheet = 3, range = "B4:L36") %>%
  mutate(period = "2017") %>% 
  select(area_name = 1, period, value = 11)

#revised
scotland_16 <- read_xlsx("2017-household-waste-summary-tables-final.xlsx", sheet = 2, range = "B4:L36") %>% 
  mutate(period = "2016") %>% 
  select(area_name = 1, period, value = 11)

scotland_15 <- read_xlsx("household-waste-summary-data-2015.xlsx", sheet = 1, range = "A2:D34") %>% 
  mutate(period = "2015") %>% 
  select(area_name = 1, period, value = 4)

scotland <- bind_rows(scotland_22, scotland_21, scotland_20, scotland_19, scotland_18, scotland_17, scotland_16, scotland_15) %>% 
  mutate(area_name = gsub("†|‡","", area_name),
         area_name = case_when(
           area_name == "Argyll & Bute" ~ "Argyll and Bute",
           area_name == "Dumfries & Galloway" ~ "Dumfries and Galloway",
           area_name == "Edinburgh, City of" ~ "City of Edinburgh",
           area_name == "Eilean Siar" ~ "Na h-Eileanan Siar",
           area_name == "Perth & Kinross" ~ "Perth and Kinross",
           TRUE ~ area_name),
  ) %>% 
  left_join(., lookup, by = "area_name") %>% 
  mutate(value = round(value,1), 
         indicator = "Recycling",
         measure = "Percentage",
         unit = "Waste") %>% 
  select(area_code, area_name, period, indicator, measure, unit, value) %>% 
  arrange(period)

# Northern Ireland ---------------------------
# Department of Agriculture, Environment and Rural Affairs
# URL: https://www.daera-ni.gov.uk/publications/northern-ireland-local-authority-collected-municipal-waste-management-statistics-time-series-data
# Licence: Open Government Licence

northern_ireland <- read_csv("https://www.daera-ni.gov.uk/sites/default/files/publications/daera/lac-municipal-waste-timeseries-csv_20.csv") %>% 
  select(area_name = AreaName, period = FinancialYear,
         household_waste = `Household waste arisings (tonnes)`,
         recycled_household_waste = `Household waste preparing for reuse, dry recycling and composting (tonnes)`) %>% 
  mutate(recycled_household_waste = parse_number(recycled_household_waste)) %>% 
  filter(period >= "2015/16", period < "2022/23", area_name != "Northern Ireland") %>% 
  mutate(area_name = case_when(
    area_name == "Antrim & Newtownabbey" ~ "Antrim and Newtownabbey",
    area_name == "Armagh City, Banbridge & Craigavon" ~ "Armagh City, Banbridge and Craigavon",
    area_name == "Causeway Coast & Glens" ~ "Causeway Coast and Glens",
    area_name == "Derry City & Strabane" ~ "Derry City and Strabane",
    area_name == "Fermanagh & Omagh" ~ "Fermanagh and Omagh",
    area_name == "Lisburn & Castlereagh" ~ "Lisburn and Castlereagh",
    area_name == "Mid & East Antrim" ~ "Mid and East Antrim",
    area_name == "Newry, Mourne & Down" ~ "Newry, Mourne and Down",
    area_name == "Ards & North Down" ~ "Ards and North Down",
    TRUE ~ area_name)) %>% 
  left_join(., lookup, by = "area_name") %>% 
  group_by(period, area_code, area_name) %>% 
  summarise(total_household_waste = sum(household_waste),
            total_recycled_household_waste = sum(recycled_household_waste),
            value = round(total_recycled_household_waste/total_household_waste*100,1)) %>% 
  mutate(indicator = "Recycling",
         measure = "Percentage",
         unit = "Waste") %>% 
  select(area_code, area_name, period, indicator, measure, unit, value) %>% 
  arrange(period)

df <- bind_rows(england, wales, scotland, northern_ireland)

write_csv(df, "../data/recycling.csv")
