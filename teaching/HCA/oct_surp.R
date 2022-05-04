##########################################################
# Sorpresa de Octubre
# Taller Haciendo Ciencia Abierta
# autor: Ignacio Sarmiento-Barbieri
# Basado en https://book.declaredesign.org/what-is-a-research-design.html
##########################################################


#Carga de Paquetes
require("tidyverse")
require("DeclareDesign")
require("modelr") 

set.seed(10101) 

# Carrera estable ---------------------------------------------------------


prefs_A <- 0.51
N <- 1000
tendencia<-0


modelo_carrera_estable <-declare_model(
    N = N,
    Y_time_1 = rbinom(N, size = 1, prob = prefs_A + 0 * tendencia),
    Y_time_2 = rbinom(N, size = 1, prob = prefs_A + 1 * tendencia),
    Y_time_3 = rbinom(N, size = 1, prob = prefs_A + 2 * tendencia)
  ) 


pregunta_carrera_estable <-declare_inquiry(A_voteshare = rnorm(n = 1, mean = prefs_A, sd = 0.01))


carrera_estable<- modelo_carrera_estable + pregunta_carrera_estable


una_encuesta_medicion <- declare_measurement(Y_obs = Y_time_1) 

una_encuesta_respuesta<-  declare_estimator(Y_obs ~ 1, model = lm_robust)


una_encuesta <- una_encuesta_medicion + una_encuesta_respuesta


diseno_carrera_estable <- carrera_estable +una_encuesta


diagnosands <- declare_diagnosands(
    correct_call_rate = mean((estimate > 0.5) == (estimand > 0.5))
  )


diagnostico_una_encuesta <-
  diagnose_design(design = diseno_carrera_estable,
                  diagnosands = diagnosands)


diagnostico_una_encuesta


# Sorpresa de octubre -----------------------------------------------------


prefs_A <- 0.51
tendencia <- -0.01 
N <- 1000

sorpresa_de_octubre <- 
  declare_model(
    N = N,
    Y_time_1 = rbinom(N, size = 1, prob = prefs_A + 0 * tendencia),
    Y_time_2 = rbinom(N, size = 1, prob = prefs_A + 1 * tendencia),
    Y_time_3 = rbinom(N, size = 1, prob = prefs_A + 2 * tendencia)
  ) +
  declare_inquiry(
    A_voteshare = 
      rnorm(n = 1, mean = prefs_A + 3 * tendencia, sd = 0.01))


tres_encuestas <-
  declare_assignment(time = complete_ra(N, conditions = 1:3)) +
  declare_measurement(Y_obs = reveal_outcomes(Y ~ time)) +
  declare_estimator(
    Y_obs ~ time,
    model = lm_robust,
    model_summary = ~add_predictions(model = ., 
                                     data = data.frame(time = 4), 
                                     var = "estimate")
  ) 


diseno_sorpresa <- sorpresa_de_octubre + tres_encuestas

diagnostico_tres_encuestas <-
  diagnose_design(design = diseno_sorpresa,
                  diagnosands = diagnosands)


diagnostico_tres_encuestas

# Comparacion -------------------------------------------------------------


diagnostico_multiple <- 
  diagnose_design(
    design_1 = carrera_estable + una_encuesta,
    design_2 = carrera_estable + tres_encuestas,
    design_3 = sorpresa_de_octubre + una_encuesta,
    design_4 = sorpresa_de_octubre + tres_encuestas,
    diagnosands = diagnosands
  )

diagnostico_multiple
