# Flood risk #

# Source: Environment Agency
# Publisher URL: https://data.gov.uk/dataset/risk-of-flooding-from-rivers-and-sea1
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(sf)

# Create a string object with the name of your local authority
id <- "Trafford"

# Retrieve the local authority boundary projected in British National Grid (EPSG 27700)
# Source: ONS Open Geography Portal
la <- st_read(paste0("https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Local_Authority_Districts_December_2018_Boundaries_UK_BGC/MapServer/0/query?where=UPPER(lad18nm)%20like%20'%25", URLencode(toupper(id), reserved = TRUE), "%25'&outFields=lad18cd,lad18nm,long,lat&outSR=27700&f=geojson"), quiet = TRUE) %>% 
  select(area_code = lad18cd, area_name = lad18nm, lon = long, lat)

# Download the Risk of Flooding from Rivers and Sea dataset as a shapefile and unzip
unzip("EA_RiskOfFloodingFromRiversAndSea_SHP_Full.zip", exdir = ".")
file.remove("EA_RiskOfFloodingFromRiversAndSea_SHP_Full.zip")
sf <- st_read("data/Risk_of_Flooding_from_Rivers_and_Sea.shp") %>% 
  st_set_crs(st_crs(la))

# Intersect layers (and optionally simplify polygon)
flood_risk <- st_intersection(sf, la) %>% 
  #st_simplify(preserveTopology = TRUE, dTolerance = 10) %>% 
  st_transform(4326)

# Write results as a GeoJSON
st_write(flood_risk, "../data/flood_risk.geojson", driver = "GeoJSON")
