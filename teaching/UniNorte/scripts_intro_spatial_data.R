#######################################################################
#  Ciencia de Datos para la toma de decisiones en Economía
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################


#Load the required packages
require("tidyverse")
require("sf")
require("here")


bars<-st_read(here("egba/EGBa.shp"))

ggplot()+
  geom_sf(data=bars) +
  theme_bw() +
  theme(axis.title =element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(size=6))


ciclovias<-read_sf(here("Ciclovia/Ciclovia.shp"))

ggplot()+
  geom_sf(data=ciclovias) +
  theme_bw() +
  theme(axis.title =element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(size=6))

upla<-read_sf(here("upla/UPla.shp"))

ggplot()+
  geom_sf(data=upla, aes(fill = UPlArea)) +
  theme_bw() +
  theme(axis.title =element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(size=6))
# Creating Objects

db<-data.frame(place=c("Uniandes","Banco de La Republica"),lat=c(4.601590,4.602151), 
               long=c(-74.066391,-74.072350), 
               nudge_y=c(-0.001,0.001))

db<-db %>% mutate(latp=lat,longp=long)

db<-st_as_sf(db,coords=c('longp','latp'),
             crs=4326)



ggplot()+
  geom_sf(data=upla %>% filter(UPlNombre%in%c("LA CANDELARIA","LAS NIEVES")), fill = NA) +
  geom_sf(data=db, col="red") +
  geom_label(data = db, aes(x = long, y = lat, label = place), 
        size = 3, col = "black", fontface = "bold", nudge_y =db$nudge_y) +
  theme_bw() +
  theme(axis.title =element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(size=6))


# Projections


st_distance(db)


# Projections

st_distance(db,ciclovias)


st_crs(ciclovias)



ciclovias<-st_transform(ciclovias, 4686)
st_crs(ciclovias)



db<-st_transform(db, 4686)
st_distance(db,ciclovias)

ggplot()+
  geom_sf(data=ciclovias[8,], fill = NA) +
  geom_sf(data=db, col="red") +
  theme_bw() +
  theme(axis.title =element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(size=6))

