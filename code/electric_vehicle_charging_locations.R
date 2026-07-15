## Electric vehicle charging locations ##

# Source: Open Charge Map
# Publisher URL: https://map.openchargemap.io
# Licence: Creative Commons Attribution-ShareAlike 4.0 International

library(tidyverse) ; library(sf) ; library(httr) ; library(jsonlite) ; library(janitor)
library(osmdata)

# Create a string object with the name of your local authority
id <- "Trafford"

osm_charger <- opq(bbox = c(-2.478454,53.35742,-2.253022,53.48037)) %>%
  add_osm_feature(key = "amenity", value = "charging_station") %>%
  osmdata_sf() 

osm_df <- osm_charger %>% 
  magrittr::extract2("osm_polygons") %>%

# Retrieve the local authority boundary projected in British National Grid (EPSG 27700)
# Source: ONS Open Geography Portal
la <- st_read(paste0("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_DEC_2025_Boundaries_UK_BFC/FeatureServer/0/query?where=UPPER(LAD25NM)%20like%20'%25", URLencode(toupper(id), reserved = TRUE), "%25'&outFields=*&outSR=4326&f=geojson"), quiet = TRUE) %>% 
  select(area_code = LAD25CD, area_name = LAD25NM)

la <- st_read("../data/geospatial/local_authority.geojson") %>%
  filter(area_name == "Trafford")
  

# Submit request to API
request <- GET(url = "https://api.openchargemap.io/v3/poi/?",
               query = list(
                 output = "json",
                 countrycode = "GB",
                 boundingbox = paste0("(", st_bbox(la)[2], ",", st_bbox(la)[1], "),", "(", st_bbox(la)[4], ",", st_bbox(la)[3], ")"),
                 opendata = TRUE,
                 compact = FALSE,
                 verbose = TRUE,
                 comments = FALSE,
                 camelcase = TRUE,
                 key = "e0d25adb-38d5-413b-90c3-60624c6251b1")
)

# Parse the response and convert to a data frame
response <- content(request, as = "text", encoding = "UTF-8") %>%
  fromJSON(flatten = TRUE) %>%
  as_tibble(.name_repair = make_clean_names)   %>%
  select(-id) %>% 
  unnest(connections)

# Convert to spatial data, clip by boundary and rename variables
points <- response %>% 
  st_as_sf(crs = 4326, coords = c("address_info_longitude", "address_info_latitude"))  %>% 
  st_intersection(la) %>% 
  mutate_if(is.character, str_trim) %>% 
  mutate(lon = map_dbl(geometry, ~st_coordinates(.x)[[1]]),
         lat = map_dbl(geometry, ~st_coordinates(.x)[[2]])) %>% 
  unite(address, c("address_info_address_line1", "address_info_address_line2", "address_info_town", "address_info_state_or_province"), sep = ", ") %>% 
  mutate(address = str_replace_all(address, ", NA", ""),
         address = str_replace_all(address, ", , ", ", "),
         cost = str_replace_all(usage_cost, "Â", "")) %>% 
  select(name = address_info_title, 
         points = number_of_points,
         connection_type = connectionType.title,
         kW = powerKW,
         cost,
         address,
         postcode = address_info_postcode,
         operator = operator_info_title,
         website = operator_info_website_url,
         email = operator_info_contact_email,
         updated = date_last_status_update,
         area_code, 
         area_name, 
         lon, lat)

# Write results as a CSV
write_csv(st_set_geometry(points, value = NULL), "../data/electric_vehicle_charging_locations.csv")
