#######################################################################
#  Ciencia de Datos para la toma de decisiones en Economía
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################


#Load the required packages
require("tidyverse")
require("sf")


dta0<-readRDS("Barranquilla_properati.Rds")
table(dta$operation)

#quita duplicados
dta0<- dta0 %>% distinct(price,lat,lon,start_date,.keep_all = TRUE)

dta<-dta0
#distribucion
quantile(dta$price)

#histograma
plot(hist(dta$price))


dta<- dta %>% mutate(casa=ifelse(grepl("[Cc][Aa][Ss][Aa]",title)==TRUE,1,0))
table(dta$casa)

dta<-dta %>% mutate(description=tolower(description))

#eliminar tildes
dta<-dta %>% mutate(description=iconv(description, from = "UTF-8", to = "ASCII//TRANSLIT"))


dta<- dta %>% mutate(elevadores=ifelse(grepl("ascensor",title)==TRUE,1,0))
table(dta$elevadores)
dta <- dta %>% mutate(piscina=ifelse(grepl("piscina",title)==TRUE,1,0))
table(dta$piscina)

dta <- dta %>% mutate(banos=ifelse(grepl("bañ?os",title)==TRUE,1,0))
table(dta$banos)


dta <- dta %>% mutate(estrato=ifelse(grepl("estrato",title)==TRUE,1,0))
table(dta$estrato)

require("osmdata")

available_tags("leisure")


parques <- opq(bbox = getbb("Barranquilla Colombia")) %>%
  add_osm_feature(key = "leisure" , value = "park")

parques_sf <- osmdata_sf(parques)


parques_geometria <- parques_sf$osm_polygons %>% 
  select(osm_id, name)

require("leaflet")
leaflet(parques_geometria) %>% 
  addTiles() %>% 
  addPolygons(col="green")

#Solo un parque
parque1<-parques_geometria[316,]
leaflet(parque1) %>% 
  addTiles() %>% 
  addPolygons(col="red")

#Centroide de ese parque
centroids<-st_centroid(parque1,of_largest_polygon=TRUE)

leaflet(parque1) %>% 
  addTiles() %>% 
  addCircleMarkers(data=centroids,col="blue") %>% 
  addPolygons(col="red")

parque1<-parques_geometria[3,]

leaflet(parque1) %>% 
  addTiles() %>% 
  addPolygons(col="red")

#todos los centroides
centroids_all<-st_centroid(parques_geometria)

leaflet(parques_geometria) %>% 
  addTiles() %>% 
  addCircleMarkers(data=centroids_all,col="red") %>% 
  addPolygons(col="green")


#Distancias de las propiedades a los parques
dist_matrix <- st_distance(x = dta, y = centroids_all)

# Encontramos la distancia mínima a un parque
dist_min <- apply(dist_matrix, 1, min)
dta$distancia_parque <- dist_min

leaflet(parques_geometria) %>% 
  addTiles() %>% 
  addCircleMarkers(data=dta[2,],col="red") %>% 
  addPolygons(col="green")

dta<-dta %>% mutate(dp_km=distancia_parque/1000)

dta<-dta %>% mutate(cmtrs=ifelse(distancia_parque<300,1,0))
reg1<-lm(lnprice~cmtrs,dta)
stargazer::stargazer(reg1,type="text")
