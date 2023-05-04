## Eduard Martinez
## update: 13-10-2022
rm(list=ls())

## **[0.] Configuración inicial**

#### **0.1 Instalar/llamar las librerías de la clase**
require(pacman) 
p_load(tidyverse,rio,skimr,viridis,
       gstat, #variogram
       sf, # Leer/escribir/manipular datos espaciales
       leaflet, # Visualizaciones dinámicas
       tmaptools, # geocode_OSM()
       nngeo, # st_nn function
       spdep, # Construct neighbours list from polygon list 
       osmdata) # Get OSM's data

#### **0.2 Importar conjuntos de datos**

## Inmuebles
houses <- import("input/house_prices.rds")
class(houses)
skim(houses)

## dataframe to sf
houses <- st_as_sf(x = houses, ## datos
                   coords=c("lon","lat"), ## coordenadas
                   crs=4326) ## CRS
class(houses)

leaflet() %>% addTiles() %>% addCircleMarkers(data=houses[1:100,])

## Censo
mnz <- import("input/mgn_censo_2018.rds")

mnz

leaflet() %>% addTiles() %>% addPolygons(data=mnz[1:100,])

## Colegios
browseURL("https://datosabiertos.bogota.gov.co/dataset/resultados-pruebas-saber-11-bogota-d-c")

colegio <- st_read("input/col_saber_11.shp") %>% select(COD_DANE12,COLEGIO_SE,P_PUNTAJE)

colegio

summary(colegio$P_PUNTAJE)

colegio <- colegio %>% subset(P_PUNTAJE>=quantile(P_PUNTAJE,0.9))

## CBD de Bogota
cbd <- geocode_OSM("Centro Internacional, Bogotá", as.sf=T) 

cbd

#### **0.3 Descargar datos de OSM**

## parques
parques <- opq(bbox = getbb("Bogota Colombia")) %>%
           add_osm_feature(key = "leisure", value = "park") %>%
           osmdata_sf() %>% .$osm_polygons %>% select(osm_id,name)

leaflet() %>% addTiles() %>% addPolygons(data=parques)

## restaurantes
restaurantes <- opq(bbox = getbb("Bogota Colombia")) %>%
                add_osm_feature(key = "amenity", value = "restaurant") %>%
                osmdata_sf() %>% .$osm_points %>% select(osm_id,name)

leaflet() %>% addTiles() %>% addCircles(data=restaurantes)

## bancos
bancos <- opq(bbox = getbb("Bogota Colombia")) %>%
          add_osm_feature(key = "amenity", value = "bank") %>%
          osmdata_sf() %>% .$osm_points %>% select(osm_id,name)

leaflet() %>% addTiles() %>% addCircles(data=bancos)

## malls
mall <- opq(bbox = getbb("Bogota Colombia")) %>%
        add_osm_feature(key = "shop", value = "mall") %>%
        osmdata_sf() %>% .$osm_polygons %>% select(osm_id,name)

leaflet() %>% addTiles() %>% addPolygons(data=mall)

## **[1.] Operaciones geometrías**
print("Puede acceder a las viñetas de la librería [sf](https://github.com/r-spatial/sf) así:")

## Help
vignette("sf3")
vignette("sf4")

### **1.0. Afine transformations**
st_crs(mnz) == st_crs(colegio) 
st_crs(mnz) == st_crs(houses)

### **1.1. Filtrar datos**

## usando los valores de una variable
houses1 <- houses %>% subset(l3=="Bogotá D.C") %>% subset(l4=="Zona Chapinero")

leaflet() %>% addTiles() %>% addCircles(data=houses1)

## usando la geometría
chapinero <- getbb(place_name = "UPZ Chapinero, Bogota", 
                   featuretype = "boundary:administrative", 
                   format_out = "sf_polygon") %>% .$multipolygon

leaflet() %>% addTiles() %>% addPolygons(data=chapinero)

## crop puntos con poligono (opcion 1)
house_chapi <- st_crop(x = houses , y = chapinero) 

leaflet() %>% addTiles() %>% addPolygons(data=chapinero,col="red") %>% addCircles(data=house_chapi)

## crop puntos con poligono (opcion 2)
house_chapi <- st_intersection(x = houses , y = chapinero)

leaflet() %>% addTiles() %>% addPolygons(data=chapinero,col="red") %>% addCircles(data=house_chapi)

## crop puntos con poligono (opcion 3)
house_chapi <- houses[chapinero,]

leaflet() %>% addTiles() %>% addPolygons(data=chapinero,col="red") %>% addCircles(data=house_chapi)

## crop poligonos con poligono
mnz_chapi <- mnz[chapinero,]

leaflet() %>% addTiles() %>% addPolygons(data=chapinero,col="red") %>% addPolygons(data=mnz_chapi)

### **1.2. Distancia a amenities**

## Distancia a un punto
house_chapi$dist_cbd <- st_distance(x=house_chapi , y=cbd)

house_chapi$dist_cbd %>% hist()

## Distancia a muchos puntos
matrix_dist_cole <- st_distance(x=house_chapi , y=colegio)

matrix_dist_cole %>% head()

min_dist_cole <- apply(matrix_dist_cole , 1 , min)

min_dist_cole %>% hist()

house_chapi$dist_cole = min_dist_cole

## Distancia a muchos polygonos
matrix_dist_parque <- st_distance(x=house_chapi , y=parques)

matrix_dist_parque %>% head()

mean_dist_parque <- apply(matrix_dist_parque , 1 , mean)

mean_dist_parque %>% hist()

house_chapi$dist_parque = mean_dist_parque

### **3.3. Unir objetos usando la geometría**

## definir sub-muestra
new_chapi <- house_chapi[st_buffer(house_chapi[100,],200),]

leaflet() %>% addTiles() %>%
addPolygons(data=mnz_chapi[new_chapi,],col="red") %>%
addCircles(data=new_chapi)

## unir dos conjuntos de datos basados en la distancia
new_chapi <- st_join(x = new_chapi , y = mnz_chapi[new_chapi,] , join = st_nn , maxdist = 20 , k = 1)

new_chapi

leaflet() %>% addTiles() %>% 
addPolygons(data=mnz_chapi[new_chapi,] , col="red" , label=mnz_chapi[new_chapi,]$MANZ_CCNCT) %>% 
addCircles(data=new_chapi , label=new_chapi$MANZ_CCNCT)

## unir dos conjuntos de datos basados en la geometría
house_chapi <- st_join(x=house_chapi , y=mnz_chapi)

house_chapi %>% head()

## **[2.] Recuperar información de las covariables**

## stringr
browseURL("https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_strings.pdf")

## example
word = "Hola mundo, hoy es 19 de julio de 2022"

## Detect Matches
str_detect(string = word , pattern = "19") ## Detect the presence of a pattern match

str_locate(string = word , pattern = "19") ##  Locate the positions of pattern matches in a string

str_count(string = word , pattern = "o") ## Count the number of matches in a string

## Subset Strings
str_extract(string = word , pattern = "19") ## Return the first pattern match found in each strin

str_match(string = word , pattern = "19") ## Return the first pattern match found in each string

str_sub(string = word , start = 1, end = 4)

## Mutate Strings
str_replace(string = word , pattern = "19" , replacement = "10+9")

str_to_lower(string = word)

str_to_upper(string = word)

## Regular Expressions
str_replace_all(string = word , pattern = " " , replacement = "-")

str_replace_all(string = word , "[:blank:]" , replacement = "-")

str_replace_all(string = word , "19|2022" , replacement = "-")

str_replace_all(string = word , "[0-9]" , replacement = "-")

## aplicacion
house_chapi$description <- str_to_lower(house_chapi$description)

house_chapi$surface_total[49] ## not surface_total

house_chapi$surface_covered[49] ## not surface_covered

house_chapi$description[49] ## explore description

x <- "[:space:]+[:digit:]+[:space:]+mts" ## pattern

str_locate_all(string = house_chapi$description[49] , pattern = x) ## detect pattern

str_extract(string=house_chapi$description[49] , pattern= x) ## extrac pattern

## make new var
house_chapi <- house_chapi %>% 
               mutate(new_surface = str_extract(string=house_chapi$description , pattern= x))
table(house_chapi$new_surface)

## another pattern
y = "[:space:]+[:digit:]+[:space:]+m2"
house_chapi = house_chapi %>% 
              mutate(new_surface = ifelse(is.na(new_surface)==T,
                                          str_extract(string=description , pattern= y),
                                          new_surface))
table(house_chapi$new_surface)

## **[3.] Dependencia espacial**

## motivacion
import("output/variograma.rds")

## sf to sp
house_chapi_sp <- house_chapi %>% as_Spatial()
house_chapi_sp

## estimations
variogram(price/1000000 ~ 1, house_chapi_sp , cloud = F , cressie=T) %>% plot()

house_chapi_sp$normal <- rnorm(n = nrow(house_chapi_sp),
                               mean = mean(house_chapi_sp$price/1000000),
                               sd = 1000)
  
db_plot = left_join(x = variogram(price/1000000 ~ 1, house_chapi_sp, cloud = F , cressie=T) %>% mutate(estimate=gamma) %>% select(dist,estimate),
                    y = variogram(normal ~ 1, house_chapi_sp, cloud = F , cressie=T) %>% mutate(normal=gamma) %>% select(dist,normal),"dist") 

db_plot %>% head()

plot = ggplot(db_plot) + 
geom_point(aes(x=dist, y=normal , fill="Datos aleatorios (Dist. Normal)"), shape=21, alpha=0.5, size=5 ) +
geom_point(aes(x=dist, y=estimate , fill="Precio de la vivienda (properati)"), shape=21, alpha=0.5, size=5 ) +
labs(caption = "Fuente: Properati", y = "Semivariograma", x = "Distancia de separación entre inmuebles", fill = "") + theme_bw()
plot
export(plot,"output/variograma.rds")

## **[4.] Vecinos espaciales**

### **4.1 vecinos en la manzana**
house_chapi = house_chapi %>%
              group_by(MANZ_CCNCT) %>%
              mutate(new_surface_2=median(surface_total,na.rm=T))

table(is.na(house_chapi$surface_total))

table(is.na(house_chapi$surface_total),
      is.na(house_chapi$new_surface_2)) # ahora solo tenemos menos missing values

### **4.2 Vecinos mas cercanos**

## definir submuestra
new_chapi <- house_chapi[st_buffer(house_chapi[100,],200),]

new_chapi

## obtener objeto sp
house_chapi_poly <- new_chapi %>% st_buffer(20) %>% as_Spatial() # poligonos

## obtener vecinos
nb_chapi = poly2nb(pl=house_chapi_poly , queen=T) # opcion reina

## vecinos del inmueble 29
nb_chapi[[29]]

leaflet() %>% addTiles() %>% 
addCircles(data=new_chapi[29,],col="red") %>% 
addCircles(data=new_chapi[nb_chapi[[29]],]) %>% 
addCircles(data=new_chapi[-nb_chapi[[29]],],col="green")

## hacer ejemplo para un vecino y comparar resultados
st_geometry(new_chapi) = NULL
vecinos = new_chapi[nb_chapi[[32]],]
yo = new_chapi[32,]

yo$surface_total
vecinos$surface_total
mean(vecinos$surface_total , na.rm=T)


