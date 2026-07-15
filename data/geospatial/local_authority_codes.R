# Local authority district codes #

# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/local-authority-districts-april-2019-names-and-codes-in-the-united-kingdom/geoservice
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(jsonlite)

fromJSON("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD24_CTRY24_UK_LU/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson") %>% 
  pluck("features", "properties") %>% 
  #pluck("features", "attributes") %>% 
  as_tibble() %>% 
  select(area_code = LAD24CD,
         area_name = LAD24NM) %>% 
  write_csv("local_authority_codes.csv")
