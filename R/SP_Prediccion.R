library(climaemet)
library(tidyverse)
library(xlsx)

# Codigos Municipios ------------------------------------------------------

CodigosMunicipios <- c("30016","30024","30030","30035","30037","30902","03012","02009","03140")

# Api Key obtenida en aemet.es

api_key <- "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtaWd1ZWwuYmxheWFAZ21haWwuY29tIiwianRpIjoiMDliMzk1YmUtYjNjYi00YzdhLWJiYzAtMTNkMjAzYTE0NTdiIiwiaXNzIjoiQUVNRVQiLCJpYXQiOjE2MzIzMzYxNDIsInVzZXJJZCI6IjA5YjM5NWJlLWIzY2ItNGM3YS1iYmMwLTEzZDIwM2ExNDU3YiIsInJvbGUiOiIifQ.Jirz8RGo67ytmg5RA89tpt4Dv-8FNlpO1cefhGZhi_8"

aemet_api_key(api_key, install = TRUE,overwrite = TRUE)


# Capturar Primera Prediccion de la lista ---------------------------------

url <- "/api/prediccion/especifica/municipio/diaria/"
url <- paste(url,CodigosMunicipios[1],sep="")
prediccion <- get_data_aemet(url)
Municipio<- prediccion$nombre
prediccion <- as.data.frame(prediccion$prediccion[[1]])
prediccion <- cbind(prediccion,Municipio)

# Recorrer del segundo Municipio hasta fin y agregar prediccion -----------

for (i in 2:length(CodigosMunicipios)){
        url <- "/api/prediccion/especifica/municipio/diaria/"
        url <- paste(url,CodigosMunicipios[i],sep="")
        prediccionnueva <- get_data_aemet(url)
        Municipio<- prediccionnueva$nombre
        prediccionnueva <- as.data.frame(prediccionnueva$prediccion[[1]])
        prediccionnueva <- cbind(prediccionnueva,Municipio)
        prediccion <- prediccion %>% union_all(prediccionnueva)
}

totalpredicciones <- as.integer(count(prediccion))

for(i in 1:totalpredicciones){
        prediccion$Lluvia[i] <- max(prediccion$probPrecipitacion[[i]]$value)
}

for(i in 1:totalpredicciones){
        prediccion$Viento[i] <- max(prediccion$viento[[i]]$velocidad)
}

prediccion$TemperaturaMax <- prediccion$temperatura$maxima
prediccion$TemperaturaMin <- prediccion$temperatura$minima
prediccion$HumedadMax <- prediccion$humedadRelativa$maxima
prediccion$HumedadMin <- prediccion$humedadRelativa$minima

rm(prediccionnueva)

RM_Meteo <- prediccion %>% 
        
        select(fecha,
               Municipio,
               Lluvia,
               Viento,
               TemperaturaMax,
               TemperaturaMin,
               HumedadMax,
               HumedadMin)


rm(prediccion)

url <- "C:/Users/mblaya/VERDIMED, SA/Intranet de Verdimed - ALMACEN/00 General/00001 Datos/RM_Meteo.xlsx"
write.xlsx(RM_Meteo,url,sheetName = "RM_Meteo",  row.names = FALSE,append = FALSE)

q()
