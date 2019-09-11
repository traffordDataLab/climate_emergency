# Local authority district codes #

# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/local-authority-districts-april-2019-names-and-codes-in-the-united-kingdom/geoservice
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(jsonlite)

fromJSON("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD_APR_2019_UK_NC/FeatureServer/0/query?where=1%3D1&outFields=LAD19CD,LAD19NM&outSR=4326&f=json") %>% 
  pluck("features", "attributes") %>% 
  as_tibble() %>% 
  rename(area_code = LAD19CD,
         area_name = LAD19NM) %>% 
  write_csv("local_authority_codes.csv")
