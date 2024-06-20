
# Carga de paquetes
require("here")
require("lme4")
require("lmerTest")
require("MuMIn")
require("modelsummary")

# carga de la info
load(here("02_analysis/","01_input/","pnas_light_ineq.RData"))

# Primer modelo sin controles
mod_1 <- lmer(Gini ~ Light_Gini + 
                (1 | Year), 
              data = df_nat)
summary(mod_1)
r.squaredGLMM(mod_1)[2]
AIC(mod_1)
AICc(mod_1)

# Se agrega control por log población
mod_2 <- lmer(Gini ~ Light_Gini +  
                log(POP) +
                (1 | Year), 
              data = df_nat)
summary(mod_2)
r.squaredGLMM(mod_2)[2]
AIC(mod_2)
AICc(mod_2)

# Se agrega control por log población y por log GDO
mod_3 <- lmer(Gini ~ Light_Gini +  
                log(POP) +
                log(GDP) + 
                (1 | Year), 
              data = df_nat)
summary(mod_3)
r.squaredGLMM(mod_3)[2]
AIC(mod_3)
AICc(mod_3)

# No se usan efectos aleatorios
mod_4 <- lm(Gini ~ Light_Gini +  
              log(POP) +
              log(GDP), 
            data = df_nat)
summary(mod_4)
r.squaredGLMM(mod_4)[2]
AIC(mod_4)
AICc(mod_4)

modelsummary(list(mod_1,mod_2,mod_3,mod_4), "html")

modelsummary(list(mod_1,mod_2,mod_3,mod_4), 
             fmt=2,
             estimate  = "{estimate}{stars} ({std.error})",
             statistic=NULL,
             stars = c('***' = .001, '**' = .05,"*" =0.1), 
             "html")

sessionInfo()
