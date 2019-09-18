# Green spaces #

# Source: OS Open Greenspace, Ordnance Survey
# Publisher URL: https://www.ordnancesurvey.co.uk/business-and-government/products/os-open-greenspace.html
# Licence: Open Government Licence (OGL)

library(tidyverse) ; library(sf)

# Create a string object with the name of your local authority
id <- "Trafford"

# Retrieve the local authority boundary projected in British National Grid (EPSG 27700)
# Source: ONS Open Geography Portal
la <- st_read(paste0("https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Local_Authority_Districts_December_2018_Boundaries_UK_BGC/MapServer/0/query?where=UPPER(lad18nm)%20like%20'%25", URLencode(toupper(id), reserved = TRUE), "%25'&outFields=lad18cd,lad18nm,long,lat&outSR=4326&f=geojson"), quiet = TRUE) %>% 
  select(area_code = lad18cd, area_name = lad18nm) 

# Download OS Open Greenspace for Great Britain as a shapefile and unzip
unzip("opgrsp_essh_gb.zip", exdir = ".")
sf <- st_read("OS Open Greenspace (ESRI Shape File) GB/data/GB_GreenspaceSite.shp") %>% 
  st_transform(4326) %>% 
  st_zm() 

# Intersect greenspaces sites with local authority boundary
greenspaces <- st_intersection(sf, la)  %>% 
  mutate(site_type = fct_recode(`function.`,
                                "Sports" = "Bowling Green",
                                "Sports" = "Other Sports Facility",
                                "Sports" = "Tennis Court",
                                "Religious Ground and Cemetries" = "Religious Grounds",
                                "Religious Ground and Cemetries" = "Cemetery")) %>% 
  select(site_type, site_name = distName1, area_code, area_name)

# Write results as a GeoJSON
st_write(greenspaces, "../data/greenspaces.geojson")
