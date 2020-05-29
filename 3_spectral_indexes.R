####################################################################################
####### The spectral indexes 
####### based wet and dry season mosaics           
####################################################################################
#set variable: the two mosaics (wet and dry period)
#bands renaming
#xw <- wetdir.r.b.7.utm
#xd <- drydir.r.b.7.utm

xw <- wetdir.r.b.7
xd <- drydir.r.b.7

#bands wet season
#ls = landsat w/d = wet/dry
lswblue <- raster(xw,"blue")
lswgreen <- raster(xw,"green")
lswred <- raster(xw,"red")
lswNIR <- raster(xw,"NIR")
lswSWIR <- raster(xw,"SWIR1")
lswSWIR2 <- raster(xw,"SWIR2")
lswthermal <- raster(xw,"thermal")
xd <- drydir.r.b.7
nlayers(xw)
xw
#bands dry season
lsdblue <- raster(xd,"blue")
lsdgreen <- raster(xd,"green")
lsdred <- raster(xd,"red")
lsdNIR <- raster(xd,"NIR")
lsdSWIR <- raster(xd,"SWIR1")
lsdSWIR2 <- raster(xd,"SWIR2")
lsdthermal <- raster(xd,"thermal")  
nlayers(xd)
xd


#COMPUTATION OF SPECTRAL INDEXES FOR SUPERVISED CLASSIFICATION (i.e. RANDOM FOREST)
###################################################
#1ndvi #2msavi #3ndmi
#4ebbi #5evi #6dbsi
#7ndwi #8"dbi-adjusted" #9ndbai
#10ndsi #11rdvi #12msr
#13rndvi #14ndii/nbr
#15nbr2

#w: wet using wet season mosaic  while d: dry using dry season mosaic

#1
#ndvi-Normalized Difference Vegetation Index
w_ndvi <-(lswNIR-lswred)/(lswNIR+lswred)
plot(w_ndvi)
d_ndvi <-(lsdNIR-lsdred)/(lsdNIR+lsdred)
plot(d_ndvi)
#n_ndvi<- (w_ndvi-d_ndvi)/(w_ndvi+d_ndvi)

############################################
library(LSRS)
#2
#msavi-Modified Soil-adjusted Vegetation Index (MSAVI) https://rdrr.io/cran/LSRS/man/MSAVI.html 
w_msavi <- MSAVI(a = lswNIR, b = lswred, Pixel.Depth=1) 
plot(w_msavi)
d_msavi <-  MSAVI(a = lsdNIR, b = lsdred, Pixel.Depth=1) 
crs(w_msavi)
plot(d_msavi)
###########################################
#3
#ndmi-Normalized Difference Moisture (Water) Index
w_ndmi <- NDMI(a = lswNIR, b = lswSWIR)
plot(w_ndmi)
d_ndmi <- NDMI(a = lsdNIR, b = lsdSWIR)
plot(d_ndmi)
###########################################
#4
#ebbi-Enhanced Built-Up and Bareness Index (EBBI) 
w_ebbi <- (lswSWIR - lswNIR)/10*sqrt(lswSWIR+lswthermal)
plot(w_ebbi)
d_ebbi <- (lsdSWIR - lsdNIR)/10*sqrt(lsdSWIR+lsdthermal)
plot(d_ebbi)
###########################################
#5
#evi-Enhanced Vegetation Index (EVI)
w_evi<- EVI(a =lswNIR, b=lswred, c=lswblue,Pixel.Depth=1) 
plot(w_evi)
d_evi<- EVI(a =lsdNIR, b=lsdred, c=lsdblue,Pixel.Depth=1) 
plot(d_evi)
#C.factor of RUSLE
#w_c <- C.factor(a =lswNIR, b = lswred, method="Knijff", na.rm = TRUE)
###########################################
#6
#dbsi-Dry Bareness Index (DBSI)  #NOTE: B6-B3/B6+B3-NDVI 
#Ref.: https://www.mdpi.com/2073-445X/7/3/81/htm "eq.for bareness area in dry climate is the inverse of the Modified Normalized Difference Water Index (MNDWI; [31])"
w_dbsi <-((lswSWIR -lswgreen)/(lswSWIR+lswgreen))-w_ndvi
plot(w_dbsi)
d_dbsi <-((lsdSWIR -lsdgreen)/(lsdSWIR+lsdgreen))-d_ndvi
plot(d_dbsi)
###########################################
#7
#ndwi-Normalized Difference Water Index (NDWI) #NDWI= GREEN-NIR/GREEN+NIR
w_ndwi <- (lswgreen-lswNIR)/(lswgreen+lswNIR)
d_ndwi <- (lsdgreen-lsdNIR)/(lsdgreen+lsdNIR)
###########################################
#8
#"dbi adjusted" as difference btw NDVI and DBI (as opposite suggested (ref below) index, to enhance pixels with high NDVI but lower in DBI) 
#ref. https://www.mdpi.com/2073-445X/7/3/81/ht
w_dbi <- (lswblue-lswthermal)/(lswblue+lswthermal)
plot(w_dbi)
d_dbi <- (lsdblue-lsdthermal)/(lsdblue+lsdthermal)
plot(d_dbi)
#NDVI-DBI 
w_dbiadj <-((lswNIR-lswred)/(lswNIR+lswred))-landsat2013dbi
w_dbiadj <- w_ndvi - w_dbi
plot(w_dbiadj)
d_dbiadj <- d_ndvi - d_dbi
plot(d_dbiadj)
###########################################
#9 
#ndbai-Normalised Difference Bareness Index reference (NDBaI)
#ref.https://www.researchgate.net/publication/4183057_Use_of_normalized_difference_bareness_index_in_quickly_mapping_bare_areas_from_TMETM 
#Not used NDBaI =[d(band5)âˆ’d(band6)]/[d(band5)+ d(band6)] where, d represents digital number value (DN) of corresponding bands, band 6 represents DN of ETM+/band61
#or TM/band6. The proposed index made it possible to distinguish primary bare lands, secondary bare lands and fallow lands.
w_ndbai<-((lswSWIR-lswSWIR2)/(lswSWIR+lswSWIR2))
plot(w_ndbai)
d_ndbai <-((lsdSWIR-lsdSWIR2)/(lsdSWIR+lsdSWIR2))
plot(d_ndbai)
###########################################
#10 
#ndsi-Normalized difference soil index (NDSI)    (band5- band4)/(band5 + band4)
#To reduce signature variability in un-mixing coastal marsh...only soil is more reflective in band 5 than band 4 (Rogers, 2004)
w_ndsi <- (lswSWIR-lswNIR)/(lswSWIR+lswNIR)
plot(w_ndsi)
d_ndsi <- (lsdSWIR-lsdNIR)/(lsdSWIR+lsdNIR)
plot(d_ndsi)
###########################################
#11 
#rdvi-Renormalized difference vegetation index (RDVI) https://moodle-arquivo.ciencias.ulisboa.pt/1213/pluginfile.php/50916/mod_folder/content/0/Mini-lesson08_Vegetation_indices.pdf?forcedownload=1
#https://rdrr.io/github/pieterbeck/CanHeMonR/man/RDVI.html The RDVI also linearises relationships with surface parameters that tend to be non-linear (Roujean and Breon, 1995). The index is computed as:
w_rdvi <- (lswNIR-lswred)/sqrt(lswNIR+lswred)
plot(w_rdvi)
d_rdvi <- (lsdNIR-lsdred)/sqrt(lsdNIR+lsdred)
plot(d_rdvi)
###########################################
#12
##msr-Modified Simple Ratio (MSRor modified ratio vegetation index) 
#it can be an improvement over the RDVI in terms of linearising the relationships between the index and biophysical parameters (Chen, 1996). 
w_msr <- (lswNIR/lswred -1)/sqrt(lswNIR/lswred)+1
plot(w_msr)
d_msr <- (lsdNIR/lsdred -1)/sqrt(lsdNIR/lsdred)+1
plot(d_msr)
###########################################
#13 
#rndvi-Relative Normalized Difference Vegetation Index (RNDVI)
#install_github("pieterbeck/CanHeMonR") 
#install.packages("devtools")
library(devtools)
w_rndvi <- (lswNIR-lswred)/(lswNIR+lswSWIR)
plot(w_rndvi)
d_rndvi <- (lsdNIR-lsdred)/(lsdNIR+lsdSWIR)
plot(d_rndvi)
###########################################
#14
#ndii/nbr-Normalized Difference Infrared Index (NDII)as also Normalized burn ration (NBR) (NIR - SWIR) / (NIR + SWIR)
#As a proxy for soil moisture storage in hydrological modelling 
d_ndii <- (lsdNIR-lsdSWIR)/(lsdNIR+lsdSWIR)
###########################################
#15
#nbr2-Normalized Burn Ratio 2 (NBR2) is calculated as a ratio between the SWIR values, substituting #the SWIR1 band for the NIR band used in NBR to highlight sensitivity to water in vegetation.
w_ndbr2 <- (lswSWIR-lswSWIR2)/(lswSWIR+lswSWIR2)
plot(w_ndbr2)
d_ndbr2 <- (lsdSWIR-lsdSWIR2)/(lsdSWIR+lsdSWIR2)
plot(d_ndbr2)
###########################################
#16
#trvi-Total Ration Vegetation Index (ref. Fadaet et al., 2012)
w_trvi <- 4*((lswNIR-lswred)/(lswNIR+lswred+lswgreen+lswblue))
plot(w_trvi)
d_trvi <- 4*((lsdNIR-lsdred)/(lsdNIR+lsdred+lsdgreen+lsdblue))
plot(d_trvi)


######################################
###EXPORTING TO RASTERS###############
######################################

################
#stack_indexes <- stack(paste0(mosaicdir, mosaic_name_fomask_wet))

#two options
#create one stack and wrtie only one big raster
#create several rasters and stack them afterwords

##system("
##       for month in w_ndvi d_ndvi; do 
#       for band in 1; do 
#       gdal_translate -b $band sentinel2/s2_321_${month}_crop.tif sentinel2/${month}/s2_321_${month}_band${band}.tif
#       done
#       done
#       ")

#14 <- w_ndii
###144 <- d_ndii
#15 <- w_ndbr2
#155 <-d_ndbr2
#16 <- w_trvi
#166 <- d_trvi 
#mosaic_name_fomask_wet    <- paste0('fomask_', yearforestmask, '_wet.tif')
#mosaic_name_fomask_dry <- paste0('fomask_', yearforestmask, '_dry.tif')

#wetdir.r <- raster(paste0(mosaicdir, mosaic_name_fomask_wet))
