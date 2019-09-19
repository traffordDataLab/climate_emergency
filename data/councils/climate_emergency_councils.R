# Councils declaring a climate emergency #

# Source: Declare a Climate Emergency
# Publisher URL: https://www.climateemergency.uk/blog/list-of-councils/
# Licence: data derived from open sources

library(tidyverse) ; library(rvest) ; library(sf)

uk <- st_read("https://opendata.arcgis.com/datasets/bbb0e58b0be64cc1a1460aa69e33678f_0.geojson") %>% 
  select(area_code = lad19cd, area_name = lad19nm)

url <- "https://www.climateemergency.uk/blog/list-of-councils/"

df <- read_html(url) %>% 
  html_node("table") %>%
  html_table() %>% 
  select(council = Council, region = Region, type = Type, url = 8) %>% 
  distinct(council, region, type, url) %>% 
  filter(!type %in% c("City Region", "Combined Authority", "County")) %>% 
  mutate(area_name = str_trim(council),
         area_name = str_replace_all(area_name, "&", "and"),
         area_name = case_when(
           council == "Bath & NES" ~ "Bath and North East Somerset",
           council == "Blackburn-with-Darwen" ~ "Blackburn with Darwen",
           council == "Bristol" ~ "Bristol, City of",
           council == "Derry & Strabane" ~ "Derry City and Strabane",
           council == "Dundee" ~ "Dundee City",
           council == "Durham" ~ "County Durham",
           council == "Edinburgh" ~ "City of Edinburgh",
           council == "Glasgow" ~ "Glasgow City",
           council == "Herefordshire" ~ "Herefordshire, County of",
           council == "Hull" ~ "Kingston upon Hull, City of",
           council == "Kingston-upon-Thames" ~ "Kingston upon Thames",
           council == "Orkney" ~ "Orkney Islands",
           council == "Richmond-upon-Thames" ~ "Richmond upon Thames",
           council == "Scilly Isles" ~ "Isles of Scilly",
           council == "St Alban's" ~ "St Albans",
           council == "St. Helen's" ~ "St. Helens",
           TRUE ~ area_name)) %>% 
  left_join(st_set_geometry(uk, NULL), df, by = "area_name")

sf <- left_join(uk, select(df, -area_name), by = "area_code") %>% 
  mutate(status = case_when(
    !is.na(council) ~ "Declared", TRUE ~ "Undeclared"
  )) %>% 
  select(area_code, area_name, everything())

st_write(sf, "climate_emergency_councils.geojson")

ggplot() + 
  geom_sf(data = sf, aes(fill = status), 
          color = "#212121", size = 0.1) +
  labs(x = NULL, y = NULL,
       title = "UK councils declaring a climate emergency",
       subtitle = "as of 15 July 2019",
       caption = "Contains Ordnance Survey data © Crown copyright and database right 2019\nData: climateemergency.uk",
       fill = NULL) +
  scale_fill_manual(values = c("#FFE800", "#13B3E5"), 
                    labels = c("Declared", "Undeclared")) +
  coord_sf(datum = NA) +
  theme_x() +
  theme(plot.caption = element_text(size = 8, hjust = 0),
        legend.position = "right",
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 8))

ggsave("climate_emergency_councils.png", dpi = 300, scale = 1)
