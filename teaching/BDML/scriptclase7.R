####################################
#Script Clase 7
# Author: ISB
# Date: 10/31/2023
####################################


# Cargamos paquetes -------------------------------------------------------
require("pacman")
p_load("tidyverse","stargazer")



# Cargar los datos --------------------------------------------------------
houses<-readRDS(url("https://github.com/ignaciomsarmiento/datasets/raw/main/data_houses_inmob.Rds"))


# Partir la muestra en entrenamiento y prueba -----------------------------

sample_test<- sample(nrow(houses), size=nrow(houses)*0.3)

prueba<-houses[sample_test,]

entrenamiento<-houses[-sample_test,]



# Regresion lineal --------------------------------------------------------

lr_model<-lm(log(price)~.,data=entrenamiento)
stargazer(lr_model,type="text")

# Lasso -------------------------------------------------------------------
# el paquete de lasso y ridge se llama glmnet
p_load("glmnet")


X<- entrenamiento %>% select(-price) 
X<- model.matrix(price~.-1,entrenamiento)
y<- log(entrenamiento$price)

lasso<-glmnet(X, #predictores
              y, #target (precio)
              alpha=1, #alpha =1 es un modelo de Lasso, 0 es Ridge
              lambda=0.03
              )
round(coef(lasso),6)



lasso_lambdas<-glmnet(X, #predictores
              y, #target (precio)
              alpha=1 #alpha =1 es un modelo de Lasso, 0 es Ridge
)

plot(lasso_lambdas,xvar="lambda")


cv_lasso<-cv.glmnet(X, #predictores
                    y, #target (precio)
                    alpha=1 #alpha =1 es un modelo de Lasso, 0 es Ridge
                    )

plot(cv_lasso)


X2<- model.matrix(price~.+ poly(rooms,2):poly(surface_total,2):poly(bathrooms,2) + dist_cole:dist_park -1,entrenamiento)




cv_lasso2<-cv.glmnet(X2, #predictores
                    y, #target (precio)
                    alpha=1 #alpha =1 es un modelo de Lasso, 0 es Ridge
)

plot(cv_lasso2)

coef(cv_lasso2, s = "lambda.min")



# Tarea para la casa es implementar Ridge ---------------------------------




cv_ridge<-cv.glmnet(X2, #predictores
                     y, #target (precio)
                     alpha=0 #alpha =1 es un modelo de Lasso, 0 es Ridge
)

plot(cv_ridge)

coef(cv_ridge, s = "lambda.min")
















