# Local authority district codes #

# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/local-authority-districts-april-2019-names-and-codes-in-the-united-kingdom/geoservice
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(jsonlite)

#test <- fromJSON("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD_APR_2019_UK_NC/FeatureServer/0/query?where=1%3D1&outFields=LAD19CD,LAD19NM&outSR=4326&f=json") %>% 

#test2 <- fromJSON("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD19_CTRY19_UK_LU_688c3656d56749c3924e787ed9f5bf44/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson") 
#%>% 
fromJSON("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD21_CTRY21_UK_LU_032ca4db66204b8c94cda6355f28fb08/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson") %>% 
  
#test3 <- fromJSON("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD22_CTRY22_UK_LU/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json") %>% 
  pluck("features", "properties") %>% 
  #pluck("features", "attributes") %>% 
  as_tibble() %>% 
  select(area_code = LAD21CD,
         area_name = LAD21NM) %>% 
  write_csv("local_authority_codes.csv")
