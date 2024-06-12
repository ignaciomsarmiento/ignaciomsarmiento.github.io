##########################################################
# Analisis Zenodo
# Taller Haciendo Ciencia Abierta
# autor: Ignacio Sarmiento-Barbieri
# Basado en Lars Vihuber Tutorial
##########################################################




library(rjson)
library(tidyr)
library(dplyr)
  


zenodo.prefix <- "10.5072/zenodo"

zenodo.id <- "1058800"


zenodo.api = "https://sandbox.zenodo.org/api/records/"

paste0(zenodo.api,zenodo.id)


dataloc<-'~/Desktop/PruebaHCA/'
  
download.file(paste0(zenodo.api,zenodo.id),destfile=file.path(dataloc,"metadata.json"))

latest <- fromJSON(file=file.path(dataloc,"metadata.json"))
latest

file.list <- as.data.frame(latest$files) %>% select(starts_with("self")) %>% gather()
file.list


  
workpath<-'~/Desktop/PruebaHCA/'

for ( value in file.list$value ) {
  print(value)
  if ( grepl(".csv",value ) ) {
    print("Downloading...")
    file.name <- basename(value)
    download.file(value,destfile=file.path(workpath,basename(value)))
  } else {
    print("Skipping.")
  }
}


?read.csv  

browser_survey <- read.csv(file.path(workpath,"encuesta.csv"))


latest.doi <- latest$doi
latest.doi



tabla<-browser_survey %>% 
  group_by(Navegador) %>%
  summarize(Pestanas,.groups="drop") 

tabla

