##########################################################
# Diseño experimento Baru
# Taller Haciendo Ciencia Abierta
# autor: Ignacio Sarmiento-Barbieri
##########################################################

# Algunos datos interesantes
#Población de cartagena en2020 
pob<- 1028736
#De las cuales el 16% son niñas entre 10 y 19 años, para ser conservador voy a tomar que es el 15% hasta los 18
porc<-.15
#Es decir hay casi 154.311 niñas en Cartagena
ceiling(pob*porc)
#El ministerio de educacion busca que haya 180 dias de clases


library(tidyverse)
library(DeclareDesign)
set.seed(1010101)

efect_mc<- -0.003

modelo<-declare_model(
  nina = add_level(
    N = 1000
  ),
  dias_clase = add_level(
    N = 180,
    U=rnorm(N,sd=0.001),
    periodo= rbinom(N, size = 1, prob = 0.08),
    Y_Z_0 = rbinom(N, size = 1, prob = 0.85-0.025*periodo+U),
    Y_Z_1 = rbinom(N, size = 1, prob = 0.85-(0.025+efect_mc)*periodo+U)
  )
)

m<-modelo()




inquiry<-declare_inquiry(PATE = mean(Y_Z_1 - Y_Z_0))

#Experimento

#sampling
sampling<-declare_sampling(S = complete_rs(N, n = 50))

#assignment

assignment<-declare_assignment(Z = complete_ra(N, prob = 0.5))

# measurement
measurement <- 
  declare_measurement(Y = reveal_outcomes(Y ~ Z)) 

#estimator
estimator <- 
  declare_estimator(
    Y ~ Z, model = difference_in_means, estimand = "PATE"
  )

design <- 
  modelo + inquiry + sampling + assignment + measurement + estimator


simulation_df <- simulate_design(design)


study_diagnosands <- declare_diagnosands(
  bias = mean(estimate - estimand),
  power = mean(p.value <= 0.05)
)

diagnose_design(simulation_df, diagnosands = study_diagnosands)


