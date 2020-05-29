#######################################################################################################################
##RUNNING SUPERVISED CLASSIFICATION FOR CHANGE DETECTION USING IMAD wet and dry season + BFAST COMBINED (among others)
######################################################################################################################
#from script #3 taking only ndvi from time 1
#w: wet using wet season mosaic  while d: dry using dry season mosaic
#1
#ndvi-Normalized Difference Vegetation Index
w_ndvi <-(lswNIR-lswred)/(lswNIR+lswred)
plot(w_ndvi)
d_ndvi <-(lsdNIR-lsdred)/(lsdNIR+lsdred)
plot(d_ndvi)
#n_ndvi<- (w_ndvi-d_ndvi)/(w_ndvi+d_ndvi)
###############################################################################################################################################################################################
#set variable: the two mosaics (wet and dry period)
xw.2018 <- wetdir.r.b.7.2018
xd.2018 <- drydir.r.b.7.2018

#COMPUTATION OF SPECTRAL INDEXES FOR SUPERVISED CLASSIFICATION (RANDOM FOREST)
###################################################
#1ndvi #2msavi #3ndmi
#4ebbi #5evi #6dbsi
#7ndwi #8"dbi-adjusted" #9ndbai
#10ndsi #11rdvi #12msr
#13rndvi #14ndii/nbr
#15nbr2

#w: wet using wet season mosaic  while d: dry using dry season mosaic

#NDVI
#ndvi-Normalized Difference Vegetation Index

w_ndvi.2018 <-(lswNIR.2018-lswred.2018)/(lswNIR.2018+lswred.2018)
d_ndvi.2018 <-(lsdNIR.2018-lsdred.2018)/(lsdNIR.2018+lsdred.2018)

#Layers for the RF classification 
#NDVI#############################################################################################################################################################################################
#1. Difference ndvi between 2013 and 2018 (normalized wet/dry) : [(ndvi_wet_2013+ndvi_dry_2013)/(ndvi_wet_2013-ndvi_dry_2013)] - [(ndvi_wet_2018+ndvi_dry_2018)/(ndvi_wet_2018-ndvi_dry_2018)]
#ndvi_change <- ((w_ndvi.2018+d_ndvi.2018)/(w_ndvi.2018-d_ndvi.2018))-((w_ndvi+d_ndvi)/(w_ndvi-d_ndvi))
#plot(ndvi_change)
#ndvi_change.e <- writeRaster(ndvi_change, filename = paste0(mosaicdir, "ndvi_change.tif"),format="GTiff", overwrite=TRUE)
#to check since it creates Inf results
#CLEAN THE DATABASE
#check if there are NA
#any(is.na(ndvi_change))  
#methods(is.na)
#remove Inf values and NA
#is.finite.data.frame <- function(ndvi_change){
#  sapply(ndvi_change,FUN = function(x) all(is.finite(x)))
#}
#r <- na.omit(ndvi_change)
#any(is.na(valuetable))
#ndvi_change.e <- any(is.infinite(r))
#ndvi_change.ee <- writeRaster(ndvi_change.e, filename = paste0(mosaicdir, "ndvi_change2.tif"),format="GTiff", overwrite=TRUE)
##################################################################################################################################################################################################
#2 Difference ndvi only wet
ndvi_change_wet <- (w_ndvi.2018-w_ndvi)
#3 Difference ndvi only dry
ndvi_change_dry <- (d_ndvi.2018-d_ndvi)
plot(ndvi_change_wet)
plot(ndvi_change_dry)
#IMAD#############################################################################################################################################################################################
#4 imad wet 8 bands
imad_wet <- (brick(paste0(imad_dir, "imad_wet.tif")))
names(imad_wet) <- c('imad_w1','imad_w2','imad_w3','imad_w4','imad_w5','imad_w6', 'imad_w7','imad_w8')
#plot(imad_wet)
#imad dry  8 bands
imad_dry <- (brick(paste0(imad_dir, "imad_dry.tif")))
names(imad_dry) <- c('imad_d1','imad_d2','imad_d3','imad_d4','imad_d5','imad_d6', 'imad_d7','imad_d8')
#Burn Ration#######################################################################################################################################################################################
#14
#ndii/nbr-Normalized Difference Infrared Index (NDII)as also Normalized burn ration (NBR) (NIR - SWIR) / (NIR + SWIR)
#As a proxy for soil moisture storage in hydrological modelling 
#from the original script #3 (2013)
w_ndii <- (lswNIR-lswSWIR)/(lswNIR+lswSWIR)
d_ndii <- (lsdNIR-lsdSWIR)/(lsdNIR+lsdSWIR)
w_ndii.2018 <- (lswNIR.2018-lswSWIR.2018)/(lswNIR.2018+lswSWIR.2018)
d_ndii.2018 <- (lsdNIR.2018-lsdSWIR.2018)/(lsdNIR.2018+lsdSWIR.2018)
#15
#nbr2-Normalized Burn Ratio 2 (NBR2) is calculated as a ratio between the SWIR values, substituting #the SWIR1 band for the NIR band used in NBR to highlight sensitivity to water in vegetation.
w_ndbr2 <- (lswSWIR-lswSWIR2)/(lswSWIR+lswSWIR2)
d_ndbr2 <- (lsdSWIR-lsdSWIR2)/(lsdSWIR+lsdSWIR2)
w_ndbr2.2018 <- (lswSWIR.2018-lswSWIR2.2018)/(lswSWIR.2018+lswSWIR2.2018)
d_ndbr2.2018 <- (lsdSWIR.2018-lsdSWIR2.2018)/(lsdSWIR.2018+lsdSWIR2.2018)
#BFAST###########################################################################################################################################################################################
#bfast_th2 <- raster(paste0(thres_dir,"bfast_mosaic_raw_final_final_threshold2.tif"))
#bfast_th <- raster(paste0(thres_dir,"bfast_mosaic_raw_final_final_threshold.tif"))
result <- paste0(thres_dir,'bfast_mosaic_raw_final_with_TSmask.tif')#with mask 
bfastout <-raster(paste0(bfast_dir,'bfast_mosaic_raw_final_final.tif'), band=2)
#################################################################################################################################################################################################
#focal moving window function: to compute standard deviation using ndvi 3by3 pixels window ( "it emphasizes small-scale changes")
#window <- matrix(1, nrow=3, ncol=3)
#ndvi_change_wet_sd <- focal(ndvi_change_wet, w=window, fun=sd)
##ndvi_change_wet_sd.e <- writeRaster(ndvi_change_wet_sd, filename = paste0(change_layers_dir, "ndvi_change_wet_sd.tif"),format="GTiff", overwrite=TRUE)
#ndvi_change_dry_sd <- focal(ndvi_change_dry, w=window, fun=sd,filename=paste0(change_layers_dir, "ndvi_change_dry_sd.tif"), overwrite=TRUE)

#w_ndii_sd <- focal(w_ndii, w=window, fun=sd,filename=paste0(change_layers_dir, "w_ndii_sd.tif"), overwrite=TRUE)
#d_ndii_sd <- focal(d_ndii, w=window, fun=sd,filename=paste0(change_layers_dir, "d_ndii_sd.tif"), overwrite=TRUE)
#w_ndii.2018_sd <- focal(w_ndii.2018, w=window, fun=sd, filename=paste0(change_layers_dir, "w_ndii_sd2018.tif"), overwrite=TRUE)
#d_ndii.2018_sd <- focal(d_ndii.2018, w=window, fun=sd,filename=paste0(change_layers_dir, "d_ndii_sd2018.tif"), overwrite=TRUE)

#w_ndbr2_sd <- focal(w_ndbr2, w=window, fun=sd, filename=paste0(change_layers_dir, "w_ndbr2_sd.tif"), overwrite=TRUE)
#d_ndbr2_sd <- focal(d_ndbr2, w=window, fun=sd,filename=paste0(change_layers_dir, "d_ndbr2_sd.tif"), overwrite=TRUE)
#w_ndbr2.2018_sd <- focal(w_ndbr2.2018, w=window, fun=sd, filename=paste0(change_layers_dir, "w_ndbr2_2018sd.tif"), overwrite=TRUE)
#d_ndbr2.2018_sd <- focal(d_ndbr2.2018, w=window, fun=sd,filename=paste0(change_layers_dir, "d_ndbr2_2018sd.tif"), overwrite=TRUE)


#Once run focal the first time, next just import the rasters
ndvi_change_wet_sd <- raster(paste0(change_layers_dir, "ndvi_change_wet_sd.tif"))
ndvi_change_dry_sd <- raster(paste0(change_layers_dir, "ndvi_change_dry_sd.tif"))
w_ndii_sd <- raster(paste0(change_layers_dir, "w_ndii_sd.tif"))
d_ndii_sd <- raster(paste0(change_layers_dir, "d_ndii_sd.tif")) 
w_ndii.2018_sd <- raster(paste0(change_layers_dir, "w_ndii_sd2018.tif"))    
d_ndii.2018_sd <- raster(paste0(change_layers_dir, "d_ndii_sd2018.tif"))    
w_ndbr2_sd <- raster(paste0(change_layers_dir, "w_ndbr2_sd.tif")) 
d_ndbr2_sd <- raster(paste0(change_layers_dir, "d_ndbr2_sd.tif")) 
w_ndbr2.2018_sd <- raster(paste0(change_layers_dir, "w_ndbr2_2018sd.tif"))     
d_ndbr2.2018_sd <- raster(paste0(change_layers_dir, "d_ndbr2_2018sd.tif"))  

#it would be better to remove NAs windows, where cells shows NAs
#https://stackoverflow.com/questions/41554006/r-focal-raster-conditional-filter-only-run-if-window-center-is-value-1

#Stack layers

#using raw data from bfast (withouth mask)
##change_stack=stack(ndvi_change_wet,ndvi_change_dry,imad_wet,imad_dry,w_ndii,d_ndii,w_ndii.2018,d_ndii.2018,w_ndbr2,d_ndbr2,w_ndbr2.2018,d_ndbr2.2018,bfastout)
change_stack_withSD=stack(ndvi_change_wet,ndvi_change_wet_sd,ndvi_change_dry,ndvi_change_dry_sd,imad_wet,imad_dry,w_ndii,w_ndii_sd,d_ndii,d_ndii_sd,w_ndii.2018,w_ndii.2018_sd,d_ndii.2018,d_ndii.2018_sd,w_ndbr2,w_ndbr2_sd, d_ndbr2,d_ndbr2_sd, w_ndbr2.2018,w_ndbr2.2018_sd, d_ndbr2.2018,d_ndbr2.2018_sd,bfastout)

#bands total 27: rename bands
##names(change_stack)<- c('ndvi_change_wet','ndvi_change_dry','imad_w1','imad_w2','imad_w3','imad_w4','imad_w5','imad_w6', 'imad_w7','imad_w8','imad_d1','imad_d2','imad_d3','imad_d4','imad_d5','imad_d6', 'imad_d7','imad_d8','w_ndii','d_ndii','w_ndii2018','d_ndii2018','w_ndbr2','d_ndbr2','w_ndbr22018','d_ndbr2.2018', 'bfastb2')
names(change_stack_withSD)<- c('ndvi_change_wet','ndvi_change_wet_sd','ndvi_change_dry','ndvi_change_dry_sd','imad_w1','imad_w2','imad_w3','imad_w4','imad_w5','imad_w6', 'imad_w7','imad_w8','imad_d1','imad_d2','imad_d3','imad_d4','imad_d5','imad_d6', 'imad_d7','imad_d8','w_ndii','w_ndii_sd','d_ndii','d_ndii_sd', 'w_ndii2018', 'w_ndii_2018_sd', 'd_ndii2018','d_ndii_2018_sd', 'w_ndbr2','w_ndbr2','d_ndbr2','d_ndbr2_sd','w_ndbr22018','w_ndbr2_2018_sd', 'd_ndbr2_2018', 'd_ndbr2_2018','bfastb2')

#Load training data of change
train_change <- readOGR(paste0(training_dir_local,'/',"validation_bfast2andtrainingpolyofchangevalidation_bfastpolygon_validated.shp"))
crs(train_change)
#aoi.shp <- paste0(shpdir,'/',"ZONEGENERAL2_WGS.shp")

#Extraction of spectral info using the training poly 
spect_stat_cha <- as.data.frame(extract(change_stack_withSD, train_change, fun=mean, na.rm=TRUE, df=FALSE, sp=TRUE))  #sp to keep spatial information
spect_stat_cha_ORI <- spect_stat_cha 
#Clean 
#check if there are NA
any(is.na(spect_stat_cha))  
any(is.na(vv_tmp))  
#methods(is.na)
spect_stat_cha -> vv_tmp
#remove Inf values and NA
is.finite.data.frame <- function(vv_tmp){
  sapply(vv_tmp,FUN = function(x) all(is.finite(x)))
}
valuetable <- na.omit(vv_tmp)
any(is.na(valuetable))
###NOTE: NAs in the first and second cols (just remove the first two cols - )
#drop first and second cols
library(dplyr)
vv_tmp_sel <- select (vv_tmp,-c(Name_12,descri2018))
any(is.na(vv_tmp_sel)) 
#keep same name 
valuetable <- vv_tmp_sel
class(valuetable) #check the object class
valuetable <- as.data.frame(valuetable)
head(valuetable, n = 20)
tail(valuetable, n = 10)
#Convert the class column into a factor (since the values as integers don't really have a meaning)
#Choose the code to be used 

#valuetable$ch_code <- factor(valuetable$ch_code, levels = c(8:14))   # levels of a factor are an attribute of the variable in this case 1, 4, 13

#write.table(valuetable, file = "spect_stat_ch", append = FALSE, quote = TRUE, sep = " ",
#            na = "NA", dec = ".", row.names = TRUE,
#            col.names = TRUE, qmethod = c("escape", "double"),
#            fileEncoding = "")

write.csv(valuetable, file = "spect_stat_ch_sel_FINAL.csv", row.names = FALSE)   #move file in the training folder
#write.csv(vv_tmp, file = "vv_tmp_ch.csv", row.names = FALSE)

##############read statistics
#polystats <- "spect_stat_ch_sel_20CODE.csv"
polystats <- "spect_stat_ch_sel_FINAL.csv"
polystats.path <- paste0(training_dir_local, polystats)
spect_stat.csv <- read.csv(polystats.path)
#Choose the code to be used 
#valuetable$X2013_msk <- factor(valuetable$X2013_msk, levels = c(20:23))
spect_stat.csv$ch_code <- factor(spect_stat.csv$ch_code,levels = c(20:23))

#spect_stat.csv$ch_code <- as.factor(spect_stat.csv$CH_CODE2)
#spect_stat.csv$ch_code <- factor(spect_stat.csv$ch_code, levels = c(7:14)) 
#Model 
modelRF2 <- randomForest(x=spect_stat.csv[ ,c(3:39)], y=spect_stat.csv$ch_code,   
                         importance = TRUE, ntree= 900, mtry= 6)

modelRF2

print(modelRF1)
str(modelRF1)
names(modelRF1)
modelRF1$confusion
importance(modelRF2)
varImpPlot(modelRF2)
map.r2 <- predict(modelRF2,change_stack_withSD,keep.forest=TRUE)
map.r2 <- predict(modelRF2,change_stack_withSD)

