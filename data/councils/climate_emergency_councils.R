# Councils declaring a climate emergency #

# Source: Declare a Climate Emergency
# Publisher URL: https://www.climateemergency.uk/blog/list-of-councils/
# Licence: data derived from open sources

library(tidyverse) ; library(rvest) ; library(sf) ; library(leaflet) 
library(htmltools) ; library(htmlwidgets)

# retrieve UK local authorities
uk <- st_read("https://opendata.arcgis.com/datasets/cec4f9cf783a47bab9295b2e513dd342_0.geojson") %>% 
  select(area_code = LAD19CD, area_name = LAD19NM)

# retrieve declarations and join to UK data
df <- read_html("https://www.climateemergency.uk/blog/list-of-councils/") %>% 
  html_node("table") %>%
  html_table() %>% 
  select(council = Council, region = Region, type = Type, date = `Date passed`, target = `Target Date`) %>% 
  filter(!type %in% c("City Region", "Combined Authority", "County")) %>% 
  mutate(area_name = str_trim(council),
         area_name = str_replace_all(area_name, "&", "and"),
         area_name = case_when(
           council == "Bath & NES" ~ "Bath and North East Somerset",
           council == "Blackburn-with-Darwen" ~ "Blackburn with Darwen",
           council == "Bristol" ~ "Bristol, City of",
           council == "City of York" ~ "York",
           council == "Derry & Strabane" ~ "Derry City and Strabane",
           council == "Dundee" ~ "Dundee City",
           council == "Durham" ~ "County Durham",
           council == "Edinburgh" ~ "City of Edinburgh",
           council == "Glasgow" ~ "Glasgow City",
           council == "Herefordshire" ~ "Herefordshire, County of",
           council == "Hull" ~ "Kingston upon Hull, City of",
           council == "Kingston-upon-Thames" ~ "Kingston upon Thames",
           council == "Liverpool City" ~ "Liverpool",
           council == "Orkney" ~ "Orkney Islands",
           council == "Richmond-upon-Thames" ~ "Richmond upon Thames",
           council == "Scilly Isles" ~ "Isles of Scilly",
           council == "St Alban's" ~ "St Albans",
           council == "St. Helen's" ~ "St. Helens",
           council == "Uttesford" ~ "Uttlesford",
           TRUE ~ area_name)) %>% 
  left_join(st_set_geometry(uk, NULL), df, by = "area_name")

# clean data
sf <- left_join(uk, select(df, -area_name), by = "area_code") %>% 
  mutate(status = case_when(
    !is.na(council) ~ "Declared", TRUE ~ "Undeclared"
  )) %>% 
  select(area_code, area_name, everything())

# write results
st_write(sf, "climate_emergency_councils.geojson")
