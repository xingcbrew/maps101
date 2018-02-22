library(ggplot2)
library(dplyr)
library(reshape2)
library(maptools)
library(tidyr)
library(sp)
library(leaflet)

#set working directory
setwd("/Users/xing/Documents/maps101")

# import data (strip.white removes leading and trailing whitespace)
dat1 <- read.csv("/Users/xing/Documents/maps101/data.csv", strip.white = TRUE)

# clean data
dat1 <- subset(dat1, select = c("Name.in.English", "Countries", "Country.codes.alpha.3", "Degree.of.endangerment",
                        "Number.of.speakers", "Latitude", "Longitude"))

names(dat1) <- c("language", "country", "country_code", "degree_endanger", "speakers", "lat", "long")

# where number of speakers is 0, make degree endangered 'extinct'
dat1$degree_endanger[dat1$speakers == 0] <- 'Extinct'

# disable scientific notation
options(scipen = 999)

# extract data on north america
namer <- dat1[dat1$country_code == "CAN" | dat1$country_code == "CAN, USA" | dat1$country_code == "USA" |
                dat1$country_code == "MEX",]

### make map using leaflet

# relevel factors so that colors match and legend ordered correctly
namer$degree_endanger <- factor(namer$degree_endanger, levels = c("Vulnerable", 
                                                                  "Definitely endangered", "Critically endangered",
                                                                  "Severely endangered", "Extinct"))
# make colour palette
pal <- colorFactor(c("#FFC300", "#FF5733", "#C70039", "#900C3F", "#808B96"), namer$degree_endanger)

# pop-up information
lab <- paste(namer$language,"|", "Speakers:", namer$speakers, sep = " ")

# make the map
m <- leaflet(data = namer) %>% setView(lng = -79.38318, lat= 43.65323, zoom = 3)

lang_map <- m %>% addProviderTiles("CartoDB.Positron", options = providerTileOptions(opacity = 0.35)) %>%
  addCircleMarkers(~long, ~lat, popup = ~as.character(lab),
                   radius = 5,
                   stroke = FALSE, fillOpacity = 0.5,
                   color = ~pal(degree_endanger)) %>%
  addLegend("topright", pal = pal, values = ~degree_endanger,
            title = "Degree Endangered", opacity = 0.6)

