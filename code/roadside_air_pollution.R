# Roadside air pollution #
# 1-hour mean NO2 concentrations from Ricardo EE managed roadside monitoring stations

# Source: Ricardo EE
# Publisher URL: https://www.airqualityengland.co.uk/
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(lubridate) ; library(rvest)

# Visit the Air Quality England site, select a local authority and then choose a monitoring station

# Identify the station's AQE id from the page's URL
site_id <- "TRF2" # e.g.https://www.airqualityengland.co.uk/site/latest?site_id=TRF2

# Choose a start and end data (e.g. last 12 months)
start_date <- as.Date(Sys.time()) %m-% months(12)
end_date <- Sys.Date()

# Return 1-hour mean NO2 concentrations for station site
url <- paste0("http://www.airqualityengland.co.uk/local-authority/data.php?site_id=", site_id, "&parameter_id%5B%5D=NO2&f_query_id=920788&data=%3C%3Fphp+print+htmlentities%28%24data%29%3B+%3F%3E&f_date_started=", start_date, "&f_date_ended=", end_date, "&la_id=368&action=download&submit=Download+Data")
readings <- read_html(url) %>% 
  html_node("a.b_xls.valignt") %>% 
  html_attr('href') %>% 
  read_csv(skip = 5) %>% 
  mutate(`End Date` = as.Date(`End Date`, format = "%d/%m/%Y"),
         date_hour = as.POSIXct(paste(`End Date`, `End Time`), format = "%Y-%m-%d %H:%M:%S"),
         value = as.double(NO2)) %>% 
  select(date_hour:value) %>%
  arrange(date_hour)

# Write results as a CSV
write_csv(readings, "../data/roadside_air_pollution.csv")


