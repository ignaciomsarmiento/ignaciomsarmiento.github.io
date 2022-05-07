##########################################################
# Diseño experimento Baru
# Taller Haciendo Ciencia Abierta
# autor: Ignacio Sarmiento-Barbieri
##########################################################


library(tidyverse)
library(DeclareDesign)

# En stata los comentarios son con *, */ /*
# en python
import pandas as pd

# help paquete
?fabricatr

# help de alguna funcion
?fabricate

prob_periodo<-0.08

#fabriquemos datos (db)
db<-fabricate(
  nina=add_level(
    N=1000 #asumo 1000 niñas que hay en Barú
  ),
  dias_clase=add_level(
    N=180, # 180 dias de clase
    U=runif(N,min= -0.01,max=0.01),
    periodo=rbinom(N,size=1,prob=0.08),
    asistio=rbinom(N,size=1,prob=0.85-0.05*periodo+U)
  )
)

View(db) #para ver los datos
180*mean(db$periodo)
mean(db$asistio)

db_resumen<- db %>% 
              group_by(nina) %>% 
              summarize(mean_periodo=mean(periodo), 
                      mean_asistencia=mean(asistio),
                      n=n())

db_resumen

producto<-0.1 #el producto aumenta la probabilidad de ir (me edue la de faltar)
#fabriquemos datos con el mundo de resultados potenciales (db)
db_pot<-fabricate(
  nina=add_level(
    N=1000 #asumo 1000 niñas que hay en Barú
  ),
  dias_clase=add_level(
    N=180, # 180 dias de clase
    #U=runif(N,min= -0.01,max=0.01),
    U=rnorm(N,mean = 0,sd = 0.01),
    periodo=rbinom(N,size=1,prob=0.08),
    Y_Z_0=rbinom(N,size=1,prob=0.85-0.05*periodo+U),
    Y_Z_1=rbinom(N,size=1,prob=0.85-(0.05-producto)*periodo+U)
  )
) %>% group_by(nina) %>% summarize(Y_Z_0=sum(Y_Z_0),
                                   Y_Z_1=sum(Y_Z_1))



#Entramos en el marco MIDA
#comenzamos declarando el modelo (M)
modelo<-declare_model(db_pot)

#Inquiry es el ATE
inquiry<-declare_inquiry(ATE = mean(Y_Z_1 - Y_Z_0))

#Experimento

#sampling
sampling<-declare_sampling(S = complete_rs(N, n = 200))

#como vamos?
m<-draw_data(modelo+inquiry+sampling)

#assignment
assignment<-declare_assignment(Z = complete_ra(N, prob = 0.5))

#como vamos?
m<-draw_data(modelo+inquiry+sampling+assignment)

# measurement Yobs=Z*Y_Z_1 + (1-Z) *Y_Z_0
measurement <- 
  declare_measurement(Y = reveal_outcomes(Y ~ Z)) 

#estimator Answer strategy
estimator <- 
  declare_estimator(
    Y ~ Z, model = difference_in_means, inquiry = "ATE"
  )

#design completo
design <- 
  modelo + inquiry + sampling + assignment + measurement + estimator

#simulo
simulation_df <- simulate_design(design)

#Defino los diagnosticos
study_diagnosands <- declare_diagnosands(
  bias = mean(estimate - estimand),
  power = mean(p.value <= 0.05)
)

#corro el diagnostico
diag_output<-diagnose_design(simulation_df, diagnosands = study_diagnosands)

#ver resultado de diagnostico
View(diag_output$diagnosands_df)



