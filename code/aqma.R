# Air Quality Management Area #

# Source: Department for Environment Food & Rural Affairs
# Publisher URL: http://uk-air.defra.gov.uk/aqma/maps
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(sf)

# Create a string object with the name of your local authority
id <- "Trafford"

# Retrieve the local authority boundary projected in British National Grid (EPSG 27700)
# Source: ONS Open Geography Portal
la <- st_read(paste0("https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Local_Authority_Districts_December_2018_Boundaries_UK_BGC/MapServer/0/query?where=UPPER(lad18nm)%20like%20'%25", URLencode(toupper(id), reserved = TRUE), "%25'&outFields=lad18cd,lad18nm,long,lat&outSR=27700&f=geojson"), quiet = TRUE) %>% 
  select(area_code = lad18cd, area_name = lad18nm, lon = long, lat)

# Download the AQMA dataset and unzip
url <- "https://uk-air.defra.gov.uk/assets/documents/uk_aqma_July2019_final.zip"
download.file(url, dest = "uk_aqma_July2019_final.zip")
unzip("uk_aqma_July2019_final.zip")
file.remove("uk_aqma_July2019_final.zip")

sf <- st_read("uk_aqma_July2019_final.shp")  %>% 
  st_set_crs(st_crs(la))

# Intersect layers (and optionally simplify polygon)
aqma <- st_intersection(sf, la) %>% 
  #st_simplify(preserveTopology = TRUE, dTolerance = 10) %>% 
  st_transform(4326)

# Write results as a GeoJSON
st_write(aqma, "../data/aqma.geojson", driver = "GeoJSON")
