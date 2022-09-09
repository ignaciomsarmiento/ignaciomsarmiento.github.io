#######################################################################
#  Ciencia de Datos para la toma de decisiones en Economía
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################


#Load the required packages
library("dplyr") #for data wrangling
library("caret") #ML

data(swiss) #loads the data set

set.seed(123) #set the seed for replication purposes
str(swiss) #conmpact display





ols <- train(Fertility ~ .,   # model to fit
                     data = swiss,                        
                     trControl = trainControl(method = "cv", number = 10),     # Method: crossvalidation, 10 folds
                     method = "lm")                      # specifying regression model

ols






lambda <- 10^seq(-2, 3, length = 100)
lasso <- train(
  Fertility ~., data = swiss, method = "glmnet",
  trControl = trainControl("cv", number = 10),
  tuneGrid = expand.grid(alpha = 1, lambda=lambda), preProcess = c("center", "scale")
  )
lasso





ridge <- train(
  Fertility ~., data = swiss, method = "glmnet",
  trControl = trainControl("cv", number = 10),
  tuneGrid = expand.grid(alpha = 0,lambda=lambda), preProcess = c("center", "scale")
  )
ridge






models <- list(ridge = ridge, lasso = lasso)
resamples(models) %>% summary( metric = "RMSE")



coef_lasso<-predict(lasso$finalModel, type = "coef", mode = "fraction", s = as.numeric(lasso$bestTune))

coef_ridge<-predict(ridge$finalModel, type = "coef", mode = "fraction", s = as.numeric(ridge$bestTune))

#coef_el<-predict(el$finalModel, type = "coef", mode = "fraction", s = as.numeric(el$bestTune))





ols <- train(Fertility ~ ., data = swiss,
                 method="lm",
                trControl=trainControl("none"),
                preProcess = c("center", "scale"))

coef_ols<-ols$finalModel$coefficients




cl<-data.frame(name=rownames(coef_lasso),coef=as.matrix(coef_lasso)[,1],model="Lasso")
cr<-data.frame(name=rownames(coef_ridge),coef=as.matrix(coef_ridge)[,1],model="Ridge")
#cel<-data.frame(name=rownames(coef_el),coef=as.matrix(coef_el)[,1],model="Elastic")
ols<-data.frame(name=rownames(coef_lasso),coef=as.matrix(coef_ols)[,1],model="OLS")

db_coefs<-rbind(cl,cr,ols)




db_coefs<- db_coefs %>% filter(grepl("Intercept",name)==FALSE)

ggplot(db_coefs, aes(x=name,y=coef,group=model,col=model)) +
  geom_point( alpha = 0.5, size = 10) +
  geom_hline(yintercept = 0, lty="dashed", col="black") +
  xlab("Predictor") +
  theme_bw() +
  theme(legend.title= element_blank() ,
        legend.position="bottom",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        axis.text.x =element_text( angle=45, vjust = .6, hjust=0.5),
        text =element_text( size=22),
        rect = element_rect(colour = "transparent", fill = "white")

        ) 


