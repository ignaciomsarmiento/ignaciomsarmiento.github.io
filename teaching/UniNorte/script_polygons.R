#######################################################################
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
# please do not cite or circulate without permission
#######################################################################


# Clean the workspace -----------------------------------------------------
rm(list=ls())
cat("\014")
local({r <- getOption("repos"); r["CRAN"] <- "http://cran.r-project.org"; options(repos=r)}) #set repo



# Load Packages -----------------------------------------------------------
require("sf")
require("tidyverse")
require("here")
require("spdep")
require("spatialreg")


# # -----------------------------------------------------------------------
# Italy -------------------------------------------------------------------
# # -----------------------------------------------------------------------

# Load data -----------------------------------------------------------
italy<-read_sf(here("italy/Reg2014_ED50g/Reg2014_ED50_g.shp"))
# plot(italy)
st_crs(italy)
dta<-openxlsx::read.xlsx(here("italy/okum.xlsx"))
View(dta)

italy<-italy %>% left_join(dta)


ggplot(italy,aes(x=P,y=U)) +
  geom_point()+
  geom_smooth(method="lm",se=FALSE) +
  theme_bw()


ols<-lm(U~P, data=dta)
summary(ols)

#distance
coord_regions<-st_centroid(st_geometry(italy))
View(coord_regions)
reg_nb_dist<-dnearneigh(coord_regions, 0,380000) #380km
View(reg_nb_dist )
W<-nb2listw(reg_nb_dist, glist=NULL, style="W")
W$neighbours

moran.lm<-lm.morantest(ols, W, alternative="two.sided")
moran.lm

#W_knn<-knearneigh(coord_regions, k=5, use_kd_tree=TRUE)

#Contiguity
reg_nb_queen<-poly2nb(italy, queen=TRUE) 
reg_nb_queen[[19]]<-as.integer(18)
reg_nb_queen[[20]]<-as.integer(12)
W_queen<-nb2listw(reg_nb_queen, style="W")

moran.lm<-lm.morantest(ols, W_queen, alternative="two.sided")
moran.lm

#SAR model
sar<-spautolm(P~1,dta,W_queen)
summary(sar)
?spautolm


# # -----------------------------------------------------------------------
# Chicago -----------------------------------------------------------------
# # -----------------------------------------------------------------------
chi.poly<-read_sf(here("foreclosures/foreclosures.shp"))
st_crs(chi.poly)
st_crs(chi.poly)<-4326 #WGS84 set it in the map
chi.poly<-st_transform(chi.poly,26916) #reproject planarly
list.queen<-poly2nb(chi.poly, queen=TRUE) 
W<-nb2listw(list.queen, style="W", zero.policy=TRUE) 
W

chi.ols<-lm(violent~est_fcs_rt+bls_unemp, data=chi.poly)


moran.lm<-lm.morantest(chi.ols, W, alternative="two.sided")
print(moran.lm)



errorsalm.chi<-errorsarlm(violent~est_fcs_rt+bls_unemp, data=chi.poly, W)
summary(errorsalm.chi)

sar.chi<-lagsarlm(violent~est_fcs_rt+bls_unemp, data=chi.poly, W)
summary(sar.chi)

impacts(sar.chi, listw=W)



LM<-lm.LMtests(chi.ols, W, test="all")
print(LM)
?sacsarlm
?lm.LMtests
sararlm<-sacsarlm(violent~est_fcs_rt+bls_unemp, data=chi.poly,listw=W)
summary(sararlm)
