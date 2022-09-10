#######################################################################
#  Ciencia de Datos para la toma de decisiones en Economía
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################


#Load the required packages
require("tidyverse")
require("sf")


dta<-readRDS("Barranquilla_properati.Rds")
table(dta$operation)


db<-data.frame(place=c("Estatua Simon Bolivar"),lat=c(10.9835633), 
               lon=c(-74.7774406))


db<-st_as_sf(db,coords=c('lon','lat'),crs=4326,remove=FALSE)


dta<- dta %>% mutate(distancia_bolivar=st_distance(dta,db,by_element = TRUE))

library("leaflet")

m<-leaflet() %>%
  #addTiles() %>%
  addProviderTiles("Esri.WorldImagery", group = "ESRI Aerial") %>%
  addCircleMarkers(data=dta[1:10,] , weight=.2 , col="red",popup=dta$description)
library(htmlwidgets)
saveWidget(m, file="m.html")



