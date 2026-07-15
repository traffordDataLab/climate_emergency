# Air Quality Management Area: 2026-06 #

# Source: Department for Environment Food & Rural Affairs
# Publisher URL: http://uk-air.defra.gov.uk/aqma/maps
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(sf)

# Create a string object with the name of your local authority
id <- "Trafford"

# Retrieve the local authority boundary projected in British National Grid (EPSG 27700)
# Source: ONS Open Geography Portal
la <- st_read(paste0("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_DEC_2025_Boundaries_UK_BFC/FeatureServer/0/query?where=UPPER(LAD25NM)%20like%20'%25", URLencode(toupper(id), reserved = TRUE), "%25'&outFields=*&outSR=27700&f=geojson"), quiet = TRUE) %>% 
  select(area_code = LAD25CD, area_name = LAD25NM)

# Download the AQMA dataset and unzip
#url <- "https://uk-air.defra.gov.uk/assets/documents/uk_aqma_July2020_Final.zip"
url <- "https://uk-air.defra.gov.uk/assets/documents/AQMA_ShapeFile.zip"
download.file(url, dest = "AQMA_ShapeFile.zip")
unzip("AQMA_ShapeFile.zip")
file.remove("AQMA_ShapeFile.zip")

sf <- st_read("All_pollutants.shp")  %>% 
  st_set_crs(st_crs(la))

# Intersect layers (and optionally simplify polygon)
aqma <- st_intersection(sf, la) %>% 
  #st_simplify(preserveTopology = TRUE, dTolerance = 10) %>% 
  st_transform(4326)

# Write results as a GeoJSON
st_write(aqma, "../data/aqma.geojson", driver = "GeoJSON")
