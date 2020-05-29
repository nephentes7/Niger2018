##################################################
#RUNNING RANDOM FOREST: SUPERVISED CLASSIFICATION - LAND COVER 2018
#links
#landcover directory

#landcover_dir <- paste0(rawimgdir,'/','landcover/')
#if(!dir.exists(landcover_dir)){dir.create(landcover_dir, recursive = T)}

##INPUT IMAGE (LANDSAT/SENTINEL) FOR CLASSIFICATION

#landcover directory #sentinel 2 and sentinel 1 data
#bgw stands for brighness greenest wetness   #there is a mistake in naming folder in sepal
wetdir_s2 <- paste0(landcover_dir,'/','ng_s2_tg15ago2018_wet_BGW_copy/')
wetdir_s2_bgw <- paste0(landcover_dir,'/','ng_s2_tg15ago2018_wet/')
drydir_s2 <- paste0(landcover_dir,'/','ng_s2_tg15feb2018_dry_allbands/')
drydir_s2_bgw <- paste0(landcover_dir,'/','ng_s2_tg15feb2018_fry_BGW')
dir_s1 <- paste0(landcover_dir,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier/')

#rasters
wetdir_s2_r  <- raster(paste0(wetdir_s2,'/',"ng_s2_tg15ago2018_wet_BGW_copy.vrt"))
drydir_s2_r <- raster(paste0(drydir_s2,'/','ng_s2_tg15feb2018_dry_allbands.vrt'))
wetdir_s2_bgw_r <- raster(paste0(wetdir_s2_bgw,'/','ng_s2_tg15ago2018_wet.vrt'))
drydir_s2_bgw_r <- raster(paste0(drydir_s2_bgw,'/','ng_s2_tg15feb2018_fry_BGW.vrt'))
dir_s1_r <- raster(paste0(dir_s1,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt'))

#BANDS SENTINEL 2 10m

#1 blue
#2 green
#3 red
#4 nir
#5 swir1
#6 swir2
#7 redge 4  #this is also called NIR narrow in articles
#8 redge 3
#9 redge 2
#10 redge 1

#BANDS SENTINEL 2 BGW  GREENNESS WETNESS 
#1 BRIGHTNESS
#2 GREENNESS
#3 WETNESS

#22 BANDS SENTINEL 1 10m

#1 VVmin
#2 VVmean
#3 VVmed
#4 VVmax
#5 VVsd
#6 VVcv
#7 VHmin
#8 VHmean
#9 VHmed
#10 VHmax
#11 VHsd
#12 VHcv
#13 VVconst
#14 VVt
#15 VVphase
#16 VVamp
#17 VVresiduals
#18 VHconst
#19 VHt
#20 VHphase
#21 VHAMP
#22 VHresiduals

#...RasterBrick is often more efficient and faster to process - which is important when working with larger files.
wetdir_s2_b <- brick(paste0(wetdir_s2,'/',"ng_s2_tg15ago2018_wet_BGW_copy.vrt"))
drydir_s2_b <- brick(paste0(drydir_s2,'/','ng_s2_tg15feb2018_dry_allbands.vrt'))
wetdir_s2_bgw_b <- brick(paste0(wetdir_s2_bgw,'/','ng_s2_tg15ago2018_wet.vrt'))
drydir_s2_bgw_b <- brick(paste0(drydir_s2_bgw,'/','ng_s2_tg15feb2018_fry_BGW.vrt'))
dir_s1_b <- (brick(paste0(dir_s1,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt')))

#s2 does not have thermal band
names(wetdir_s2_b) <- c('blue','green','red','NIR','SWIR1','SWIR2', 'redge4', 'redge3','redge2','redge1')
names(wetdir_s2_bgw_b) <- c('brightness','greenness','wetness')
names(drydir_s2_b) <- c('blue','green','red','NIR','SWIR1','SWIR2', 'redge4', 'redge3','redge2','redge1')
names(drydir_s2_bgw_b) <- c('brightness','greenness','wetness')
names(dir_s1_b) <- c('VVmin','VVmean','VVmed','VVmax','VVsd','VVcv','VHmin','VHmean','VHmed','VHmax','VHsd','VHcv','VVconst','VVt','VVphase','VVamp','VVresiduals', 'VHconst','VHt','VHphase','VHamp','VHresiduals')

################################################
#COMPUTATION OF SPECTRAL INDEXES FOR SUPERVISED CLASSIFICATION (RANDOM FOREST)
###################################################
#plot(wetdir_s2_b_ndmi)
#1
#ndvi-Normalized Difference Vegetation Index
wetdir_s2_b_ndvi <- (raster(wetdir_s2_b, "NIR"))-(raster(wetdir_s2_b, "red"))/(raster(wetdir_s2_b, "NIR"))+(raster(wetdir_s2_b, "red"))
drydir_s2_b_ndvi <- (raster(drydir_s2_b, "NIR"))-(raster(drydir_s2_b, "red"))/(raster(drydir_s2_b, "NIR"))+(raster(drydir_s2_b, "red"))
plot(wetdir_s2_b_swir2)
############################################
library(LSRS)
#2
#msavi-Modified Soil-adjusted Vegetation Index (MSAVI) https://rdrr.io/cran/LSRS/man/MSAVI.html #please not when run using utm data getting NANs values 
wetdir_s2_b_msavi <- MSAVI(a = (raster(wetdir_s2_b, "NIR")), b = (raster(wetdir_s2_b, "red")), Pixel.Depth=1) 
drydir_s2_b_msavi <-  MSAVI(a = (raster(drydir_s2_b, "NIR")), b = (raster(drydir_s2_b, "red")), Pixel.Depth=1) 
###########################################
#3
#ndmi-Normalized Difference Moisture (Water) Index
wetdir_s2_b_ndmi <- NDMI(a = (raster(wetdir_s2_b, "NIR")), b = (raster(wetdir_s2_b, "SWIR1")))
drydir_s2_ndmi <- NDMI(a = (raster(drydir_s2_b, "NIR")), b = (raster(drydir_s2_b, "SWIR1")))
###########################################
#4 ebbi not possible to compute since lack of thermal band
###########################################
#5
#evi-Enhanced Vegetation Index (EVI)
wetdir_s2_b_evi<- EVI(a = (raster(wetdir_s2_b, "NIR")), b=(raster(wetdir_s2_b, "red")), c=(raster(wetdir_s2_b, "blue")), Pixel.Depth=1)
drydir_s2_b_evi<- EVI(a =(raster(drydir_s2_b, "NIR")), b=(raster(drydir_s2_b, "red")), c=(raster(drydir_s2_b, "blue")), Pixel.Depth=1) 
#C.factor of RUSLE
#w_c <- C.factor(a =lswNIR, b = lswred, method="Knijff", na.rm = TRUE)
###########################################
#6
#dbsi-Dry Bareness Index (DBSI)  #NOTE: B6-B3/B6+B3-NDVI (LANDSAT8: B6: SWIR1 B3:GREEN while SENTINEL ....)
#Ref.: https://www.mdpi.com/2073-445X/7/3/81/htm "eq.for bareness area in dry climate is the inverse of the Modified Normalized Difference Water Index (MNDWI; [31])"
wetdir_s2_b_dbsi <-(raster(wetdir_s2_b, "SWIR1")) -(raster(wetdir_s2_b, "green"))/(raster(wetdir_s2_b, "SWIR1"))+(raster(wetdir_s2_b, "green"))- wetdir_s2_b_ndvi
drydir_s2_b_dbsi <-(raster(drydir_s2_b, "SWIR1")) -(raster(drydir_s2_b, "green"))/(raster(drydir_s2_b, "SWIR1"))+(raster(drydir_s2_b, "green"))- drydir_s2_b_ndvi
###########################################
#7
#ndwi-Normalized Difference Water Index (NDWI) #NDWI= GREEN-NIR/GREEN+NIR
wetdir_s2_b_ndwi <- ((raster(wetdir_s2_b, "green"))-(raster(wetdir_s2_b, "NIR")))/(raster(wetdir_s2_b, "green"))+(raster(wetdir_s2_b, "NIR"))
drydir_s2_b_ndwi <- ((raster(drydir_s2_b, "green"))-(raster(drydir_s2_b, "NIR")))/(raster(drydir_s2_b, "green"))+(raster(drydir_s2_b, "NIR"))
###########################################
#8 not possible to compute since lack of thermal band
#"dbi adjusted" as difference btw NDVI and DBI (as opposite suggested (ref below) index, to enhance pixels with high NDVI but lower in DBI) 
###########################################
#9 # IT IS THE SAME OF #15 INDEX?!
#ndbai-Normalised Difference Bareness Index reference (NDBaI)
#ref.https://www.researchgate.net/publication/4183057_Use_of_normalized_difference_bareness_index_in_quickly_mapping_bare_areas_from_TMETM 
#Not used NDBaI =[d(band5)âˆ’d(band6)]/[d(band5)+ d(band6)] where, d represents digital number value (DN) of corresponding bands, band 6 represents DN of ETM+/band61
#or TM/band6. The proposed index made it possible to distinguish primary bare lands, secondary bare lands and fallow lands.
wetdir_s2_b_ndbai<-((raster(wetdir_s2_b, "SWIR1"))-(raster(wetdir_s2_b, "SWIR2")))/(raster(wetdir_s2_b, "SWIR1"))+(raster(wetdir_s2_b, "SWIR2"))
drydir_s2_b_ndbai<-((raster(drydir_s2_b, "SWIR1"))-(raster(drydir_s2_b, "SWIR2")))/(raster(drydir_s2_b, "SWIR1"))+(raster(drydir_s2_b, "SWIR2"))                                                                                   
###########################################
#10 
#ndsi-Normalized difference soil index (NDSI)    (band5- band4)/(band5 + band4)
#To reduce signature variability in un-mixing coastal marsh...only soil is more reflective in band 5 than band 4 (Rogers, 2004)
wetdir_s2_b_ndsi <- ((raster(wetdir_s2_b, "SWIR1"))-(raster(wetdir_s2_b, "NIR")))/(raster(wetdir_s2_b, "SWIR1"))+(raster(wetdir_s2_b, "NIR"))
drydir_s2_b_ndsi <- ((raster(drydir_s2_b, "SWIR1"))-(raster(drydir_s2_b, "NIR")))/(raster(drydir_s2_b, "SWIR1"))+(raster(drydir_s2_b, "NIR"))
###########################################
#11 
#rdvi-Renormalized difference vegetation index (RDVI) https://moodle-arquivo.ciencias.ulisboa.pt/1213/pluginfile.php/50916/mod_folder/content/0/Mini-lesson08_Vegetation_indices.pdf?forcedownload=1
#https://rdrr.io/github/pieterbeck/CanHeMonR/man/RDVI.html The RDVI also linearises relationships with surface parameters that tend to be non-linear (Roujean and Breon, 1995). The index is computed as:
wetdir_s2_b_rdvi <- ((raster(wetdir_s2_b, "NIR"))-(raster(wetdir_s2_b, "red")))/sqrt((raster(wetdir_s2_b, "NIR"))+(raster(wetdir_s2_b, "red")))
drydir_s2_b_rdvi <- ((raster(drydir_s2_b, "NIR"))-(raster(drydir_s2_b, "red")))/sqrt((raster(drydir_s2_b, "NIR"))+(raster(drydir_s2_b, "red")))
###########################################
#12
##msr-Modified Simple Ratio (MSRor modified ratio vegetation index) 
#it can be an improvement over the RDVI in terms of linearising the relationships between the index and biophysical parameters (Chen, 1996). 
wetdir_s2_b_msr <- ((raster(wetdir_s2_b, "NIR"))/(raster(wetdir_s2_b, "red")) -1)/sqrt((raster(wetdir_s2_b, "NIR"))/(raster(wetdir_s2_b, "red")))+1
drydir_s2_b_msr <- ((raster(drydir_s2_b, "NIR"))/(raster(drydir_s2_b, "red")) -1)/sqrt((raster(drydir_s2_b, "NIR"))/(raster(drydir_s2_b, "red")))+1
###########################################
#13 
#rndvi-Relative Normalized Difference Vegetation Index (RNDVI)
#install_github("pieterbeck/CanHeMonR") 
#install.packages("devtools")
library(devtools)
wetdir_s2_b_rndvi <- ((raster(wetdir_s2_b, "NIR"))-(raster(wetdir_s2_b, "red")))/(raster(wetdir_s2_b, "NIR"))+(raster(wetdir_s2_b, "SWIR1"))
drydir_s2_b_rndvi <- ((raster(drydir_s2_b, "NIR"))-(raster(drydir_s2_b, "red")))/(raster(drydir_s2_b, "NIR"))+(raster(drydir_s2_b, "SWIR1"))
###########################################
#14
#ndii/nbr-Normalized Difference Infrared Index (NDII)as also Normalized burn ration (NBR) (NIR - SWIR) / (NIR + SWIR)
wetdir_s2_b_ndii <- ((raster(wetdir_s2_b, "NIR"))-(raster(wetdir_s2_b, "SWIR1")))/((raster(wetdir_s2_b, "NIR"))+(raster(wetdir_s2_b, "SWIR1")))
drydir_s2_b_ndii <- ((raster(drydir_s2_b, "NIR"))-(raster(drydir_s2_b, "SWIR1")))/((raster(drydir_s2_b, "NIR"))+(raster(drydir_s2_b, "SWIR1")))
###########################################
#15
#nbr2-Normalized Burn Ratio 2 (NBR2) is calculated as a ratio between the SWIR values, substituting #the SWIR1 band for the NIR band used in NBR to highlight sensitivity to water in vegetation.
#drydir_s2_b_ndbr2 <- (lsdSWIR-lsdSWIR2)/(lsdSWIR+lsdSWIR2)
###########################################
#16
#trvi-Total Ration Vegetation Index (ref. Fadaet et al., 2012)
wetdir_s2_b_trvi <- 4*((raster(wetdir_s2_b, "NIR"))-(raster(wetdir_s2_b, "red")))/((raster(wetdir_s2_b, "NIR"))+(raster(wetdir_s2_b, "red"))+(raster(wetdir_s2_b, "green"))+(raster(wetdir_s2_b, "blue")))
drydir_s2_b_trvi <- 4*((raster(drydir_s2_b, "NIR"))-(raster(drydir_s2_b, "red")))/((raster(drydir_s2_b, "NIR"))+(raster(drydir_s2_b, "red"))+(raster(drydir_s2_b, "green"))+(raster(drydir_s2_b, "blue")))

#RATIOS
#red
wetdir_s2_b_red1 <- (raster(wetdir_s2_b, "red")) / (raster(wetdir_s2_b, "NIR")) 
wetdir_s2_b_red2 <- (raster(wetdir_s2_b, "red")) / (raster(wetdir_s2_b, "SWIR1")) 
wetdir_s2_b_red3 <- (raster(wetdir_s2_b, "red")) / (raster(wetdir_s2_b, "SWIR2")) 
#nir
wetdir_s2_b_nir1 <- (raster(wetdir_s2_b, "NIR")) / (raster(wetdir_s2_b, "red")) 
wetdir_s2_b_nir2 <- (raster(wetdir_s2_b, "NIR")) / (raster(wetdir_s2_b, "SWIR1")) 
wetdir_s2_b_nir3 <- (raster(wetdir_s2_b, "NIR")) / (raster(wetdir_s2_b, "SWIR2")) 
#swir1
wetdir_s2_b_swir11 <- (raster(wetdir_s2_b, "SWIR1")) / (raster(wetdir_s2_b, "red")) 
wetdir_s2_b_swir12 <- (raster(wetdir_s2_b, "SWIR1")) / (raster(wetdir_s2_b, "NIR")) 
wetdir_s2_b_swir13 <- (raster(wetdir_s2_b, "SWIR1")) / (raster(wetdir_s2_b, "SWIR2")) 
#swir2
wetdir_s2_b_swir21 <- (raster(wetdir_s2_b, "SWIR2")) / (raster(wetdir_s2_b, "red")) 
wetdir_s2_b_swir22 <- (raster(wetdir_s2_b, "SWIR2")) / (raster(wetdir_s2_b, "NIR")) 
wetdir_s2_b_swir23 <- (raster(wetdir_s2_b, "SWIR2")) / (raster(wetdir_s2_b, "SWIR1")) 

#red
drydir_s2_b_red1 <- (raster(drydir_s2_b, "red")) / (raster(drydir_s2_b, "NIR")) 
drydir_s2_b_red2 <- (raster(drydir_s2_b, "red")) / (raster(drydir_s2_b, "SWIR1")) 
drydir_s2_b_red3 <- (raster(drydir_s2_b, "red")) / (raster(drydir_s2_b, "SWIR2")) 
#nir
drydir_s2_b_nir1 <- (raster(drydir_s2_b, "NIR")) / (raster(drydir_s2_b, "red")) 
drydir_s2_b_nir2 <- (raster(drydir_s2_b, "NIR")) / (raster(drydir_s2_b, "SWIR1")) 
drydir_s2_b_nir3 <- (raster(drydir_s2_b, "NIR")) / (raster(drydir_s2_b, "SWIR2")) 
#swir1
drydir_s2_b_swir11 <- (raster(drydir_s2_b, "SWIR1")) / (raster(drydir_s2_b, "red")) 
drydir_s2_b_swir12 <- (raster(drydir_s2_b, "SWIR1")) / (raster(drydir_s2_b, "NIR")) 
drydir_s2_b_swir13 <- (raster(drydir_s2_b, "SWIR1")) / (raster(drydir_s2_b, "SWIR2")) 
#swir2
drydir_s2_b_swir21 <- (raster(drydir_s2_b, "SWIR2")) / (raster(drydir_s2_b, "red")) 
drydir_s2_b_swir22 <- (raster(drydir_s2_b, "SWIR2")) / (raster(drydir_s2_b, "NIR")) 
drydir_s2_b_swir23 <- (raster(drydir_s2_b, "SWIR2")) / (raster(drydir_s2_b, "SWIR1")) 

#RED EDGE spectral indices
#Reference: https://reader.elsevier.com/reader/sd/pii/S0303243416300368?token=E0C34D874AE5A15DA7198A5B0551E4DD3CB05D543ECF661B719A9422EA0C54FA68140C87E3DCD0C28AF256153D7268EA
#NDVIre1
wetdir_s2_b_NDVIre1 <- (raster(wetdir_s2_b, "NIR"))-(raster(wetdir_s2_b, "redge1"))/(raster(wetdir_s2_b, "NIR"))+(raster(wetdir_s2_b, "redge1"))
drydir_s2_b_NDVIre1 <- (raster(drydir_s2_b, "NIR"))-(raster(drydir_s2_b, "redge1"))/(raster(drydir_s2_b, "NIR"))+(raster(drydir_s2_b, "redge1"))
#NDVIre1n
wetdir_s2_b_NDVIre1n <- (raster(wetdir_s2_b, "redge4"))-(raster(wetdir_s2_b, "redge1"))/(raster(wetdir_s2_b, "redge4"))+(raster(wetdir_s2_b, "redge1"))
drydir_s2_b_NDVIre1n <- (raster(drydir_s2_b, "redge4"))-(raster(drydir_s2_b, "redge1"))/(raster(drydir_s2_b, "redge4"))+(raster(drydir_s2_b, "redge1"))
#NDVIre2
wetdir_s2_b_NDVIre2 <- (raster(wetdir_s2_b, "NIR"))-(raster(wetdir_s2_b, "redge2"))/(raster(wetdir_s2_b, "NIR"))+(raster(wetdir_s2_b, "redge2"))
drydir_s2_b_NDVIre2 <- (raster(drydir_s2_b, "NIR"))-(raster(drydir_s2_b, "redge2"))/(raster(drydir_s2_b, "NIR"))+(raster(drydir_s2_b, "redge2"))
#NDVIre2n
wetdir_s2_b_NDVIre2n <- (raster(wetdir_s2_b, "redge4"))-(raster(wetdir_s2_b, "redge2"))/(raster(wetdir_s2_b, "redge4"))+(raster(wetdir_s2_b, "redge2"))
drydir_s2_b_NDVIre2n <- (raster(drydir_s2_b, "redge4"))-(raster(drydir_s2_b, "redge2"))/(raster(drydir_s2_b, "redge4"))+(raster(drydir_s2_b, "redge2"))
#NDVIre3
wetdir_s2_b_NDVIre3 <- (raster(wetdir_s2_b, "NIR"))-(raster(wetdir_s2_b, "redge3"))/(raster(wetdir_s2_b, "NIR"))+(raster(wetdir_s2_b, "redge3"))
drydir_s2_b_NDVIre3 <- (raster(drydir_s2_b, "NIR"))-(raster(drydir_s2_b, "redge3"))/(raster(drydir_s2_b, "NIR"))+(raster(drydir_s2_b, "redge3"))
#NDVIre3n
wetdir_s2_b_NDVIre3n <- (raster(wetdir_s2_b, "redge4"))-(raster(wetdir_s2_b, "redge3"))/(raster(wetdir_s2_b, "redge4"))+(raster(wetdir_s2_b, "redge3"))
drydir_s2_b_NDVIre3n <- (raster(drydir_s2_b, "redge4"))-(raster(drydir_s2_b, "redge3"))/(raster(drydir_s2_b, "redge4"))+(raster(drydir_s2_b, "redge3"))
#PSRI Plant Senescence Reflectance
wetdir_s2_b_psri <- (raster(wetdir_s2_b, "red"))-(raster(wetdir_s2_b, "green"))/(raster(wetdir_s2_b, "redge2"))
drydir_s2_b_psri <- (raster(drydir_s2_b, "red"))-(raster(drydir_s2_b, "green"))/(raster(drydir_s2_b, "redge2"))
#CIre Chlrophyll Index redg-edge
wetdir_s2_b_CIre <- ((raster(wetdir_s2_b, "redge3"))/(raster(wetdir_s2_b, "redge1")))-1
drydir_s2_b_CIre <- ((raster(drydir_s2_b, "redge3"))/(raster(drydir_s2_b, "redge1")))-1
#NDre1
wetdir_s2_b_NDre1 <- (raster(wetdir_s2_b, "redge2"))-(raster(wetdir_s2_b, "redge1"))/(raster(wetdir_s2_b, "redge2"))+(raster(wetdir_s2_b, "redge1"))
drydir_s2_b_NDre1 <- (raster(drydir_s2_b, "redge2"))-(raster(drydir_s2_b, "redge1"))/(raster(drydir_s2_b, "redge2"))+(raster(drydir_s2_b, "redge1"))
#NDre2
wetdir_s2_b_NDre2 <- (raster(wetdir_s2_b, "redge3"))-(raster(wetdir_s2_b, "redge1"))/(raster(wetdir_s2_b, "redge3"))+(raster(wetdir_s2_b, "redge1"))
drydir_s2_b_NDre2 <- (raster(drydir_s2_b, "redge3"))-(raster(drydir_s2_b, "redge1"))/(raster(drydir_s2_b, "redge3"))+(raster(drydir_s2_b, "redge1"))
#MSRre
wetdir_s2_b_MSRre <- ((raster(wetdir_s2_b, "NIR"))/(raster(wetdir_s2_b, "redge1"))-1)/(sqrt((raster(wetdir_s2_b, "NIR"))/(raster(wetdir_s2_b, "redge1"))+1))
drydir_s2_b_MSRre <-((raster(drydir_s2_b, "NIR"))/(raster(drydir_s2_b, "redge1"))-1)/(sqrt((raster(drydir_s2_b, "NIR"))/(raster(drydir_s2_b, "redge1"))+1))
#MSRren 
wetdir_s2_b_MSRren <- ((raster(wetdir_s2_b, "redge4"))/(raster(wetdir_s2_b, "redge1"))-1)/(sqrt((raster(wetdir_s2_b, "redge3"))/(raster(wetdir_s2_b, "redge1"))+1))
drydir_s2_b_MSRren <-((raster(drydir_s2_b, "redge4"))/(raster(drydir_s2_b, "redge1"))-1)/(sqrt((raster(drydir_s2_b, "redge3"))/(raster(drydir_s2_b, "redge1"))+1))
#####################################################################################################################################################################################################################
#RADAR INDEXES
#https://forum.step.esa.int/t/creating-radar-vegetation-index/12444/45
#Radar Vegetation Index (RVI) 4HV/HH+HV (reference: https://forum.step.esa.int/t/creating-radar-vegetation-index/12444/27)
dir_s1_b_RVI <- (4* (raster(dir_s1_b, "VHmean")))/ ((raster(dir_s1_b, "VVmean"))+(raster(dir_s1_b, "VHmean")))
#VV/VH
dir_s1_b_VVVH <- (4* (raster(dir_s1_b, "VHmean")))/ ((raster(dir_s1_b, "VVmean"))+(raster(dir_s1_b, "VHmean")))
#Radar Forest Degradation Index
dir_s1_b_RFDI <- (raster(dir_s1_b, "VVmean"))-(raster(dir_s1_b, "VHmean"))/((raster(dir_s1_b, "VVmean"))+(raster(dir_s1_b, "VHmean")))
###################################################################################################################################################################################################################################################


#CREATE ONE BIG STACK OF LAYERS WHICH INCLUDES ORIGINAL BANDS + INDECES 
#SENTINEL 2 
ws2_stack <- stack(wetdir_s2_b, wetdir_s2_bgw_b, wetdir_s2_b_ndvi, wetdir_s2_b_msavi, wetdir_s2_b_ndmi, wetdir_s2_b_evi, wetdir_s2_b_dbsi, wetdir_s2_b_ndwi, wetdir_s2_b_ndbai, wetdir_s2_b_ndsi, wetdir_s2_b_rdvi, wetdir_s2_b_msr, wetdir_s2_b_rndvi, wetdir_s2_b_ndii, wetdir_s2_b_trvi,
                    wetdir_s2_b_red1, wetdir_s2_b_red2, wetdir_s2_b_red3, wetdir_s2_b_nir1, wetdir_s2_b_nir2, wetdir_s2_b_nir3, wetdir_s2_b_swir11, wetdir_s2_b_swir12,wetdir_s2_b_swir13, wetdir_s2_b_swir21, wetdir_s2_b_swir22, wetdir_s2_b_swir23,
                    wetdir_s2_b_NDVIre1,wetdir_s2_b_NDVIre1n,wetdir_s2_b_NDVIre2,wetdir_s2_b_NDVIre2n,wetdir_s2_b_NDVIre3,wetdir_s2_b_NDVIre3n,wetdir_s2_b_psri,wetdir_s2_b_CIre,wetdir_s2_b_NDre1,wetdir_s2_b_NDre2,wetdir_s2_b_MSRre,wetdir_s2_b_MSRren)

#50 bands
ws2_brick <- brick(ws2_stack)
nlayers(ws2_brick)


names(ws2_stack) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2','w_redge4','w_redge3','w_redge2','w_redge1', 'wBRIGHTNESS', 'wGREENNESS', 'wWETNESS',
                       'w_ndvi', 'w_msavi', 'w_ndmi', 'w_evi','w_dbsi','w_ndwi', 'w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_trvi',
                      'wratiored1','wratiored2','wratiored3', 'wratio_nir1', 'wratio_nir2', 'wrationir3', 'wratioswir11','wratioswir12','wratioswir13', 'wratioswir21','wratioswir22','wratioswir23',
                       'wNDVIre1','wNDVIre1n','wNDVIre2','wNDVIre2n', 'wNDVIre3', 'wNDVIre3n', 'wpsri', 'wCIre', 'wNDre1', 'wNDre2','wMSRre','wMSRren')

  
ds2_stack <- stack(drydir_s2_b, drydir_s2_bgw_b, drydir_s2_b_ndvi, drydir_s2_b_msavi, drydir_s2_ndmi, drydir_s2_b_evi, drydir_s2_b_dbsi, drydir_s2_b_ndwi, drydir_s2_b_ndbai, drydir_s2_b_ndsi, drydir_s2_b_rdvi, drydir_s2_b_msr, drydir_s2_b_rndvi, drydir_s2_b_ndii, drydir_s2_b_trvi, 
                    drydir_s2_b_red1, drydir_s2_b_red2, drydir_s2_b_red3, drydir_s2_b_nir1, drydir_s2_b_nir2, drydir_s2_b_nir3, drydir_s2_b_swir11, drydir_s2_b_swir12, drydir_s2_b_swir13, drydir_s2_b_swir21, drydir_s2_b_swir22, 
                    drydir_s2_b_swir23,drydir_s2_b_NDVIre1,drydir_s2_b_NDVIre1n,drydir_s2_b_NDVIre2,drydir_s2_b_NDVIre2n,drydir_s2_b_NDVIre3,drydir_s2_b_NDVIre3n,drydir_s2_b_psri,drydir_s2_b_CIre,drydir_s2_b_NDre1,drydir_s2_b_NDre2,drydir_s2_b_MSRre,drydir_s2_b_MSRren)


ds2_brick <- brick(ds2_stack)
nlayers(ds2_brick)
names(ds2_stack) <- c('d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2','d_redge4','d_redge3','d_redge2','d_redge1', 'dBRIGHTNESS', 'dGREENNESS', 'dWETNESS',
                      'd_ndvi', 'd_msavi', 'd_ndmi', 'd_evi','d_dbsi','d_ndwi', 'd_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_trvi',
                      'dwratiored1','dratiored2','dratiored3', 'dratio_nir1', 'dratio_nir2', 'drationir3', 'dratioswir11','dratioswir12','dratioswir13', 'dratioswir21','dratioswir22','dratioswir23',
                       'dNDVIre1','dNDVIre1n','dNDVIre2','dNDVIre2n', 'dNDVIre3', 'dNDVIre3n', 'dpsri', 'dCIre', 'wNDre1', 'dNDre2','dMSRre','dMSRren')



#########################################################################################################
##EXPORT to raster
###########################################################################################################
ws2name <- "w_s2stack.tif"
ds2name <- "d_s2stack.tif"
#ws2_brick.e <- writeRaster(ws2_brick, filename = paste0(mosaicdir, ws2name),format="GTiff", overwrite=TRUE)
ws2_stack.e <- writeRaster(ws2_stack, filename = paste0(mosaicdir, ws2name),format="GTiff", overwrite=TRUE)
#ws2_stack.e <- writeRaster(w_stack, filename = paste0(mosaicdir, wname.s),format="GTiff", overwrite=TRUE)
names(ws2_brick.e) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2','w_redge4','w_redge3','w_redge2','w_redge1', 'wBRIGHTNESS', 'wGREENNESS', 'wWETNESS',
                       'w_ndvi', 'w_msavi', 'w_ndmi', 'w_evi','w_dbsi','w_ndwi', 'w_ndbai','w_ndsi', 'w_rndvi', 'w_ndii','w_trvi',
                       'wNDVIre1','wNDVIre1n','wNDVIre2','wNDVIre2n', 'wNDVIre3', 'wNDVIre3n', 'wpsri', 'wCIre', 'wNDre1', 'wNDre2','wMSRre','wMSRren')

ds2_stack.e <- writeRaster(ds2_stack, filename = paste0(mosaicdir, ds2name),format="GTiff", overwrite=TRUE)
#ws2_stack.e <- writeRaster(w_stack, filename = paste0(mosaicdir, wname.s),format="GTiff", overwrite=TRUE)
names(ds2_stack.e) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2','w_redge4','w_redge3','w_redge2','w_redge1', 'wBRIGHTNESS', 'wGREENNESS', 'wWETNESS',
                        'w_ndvi', 'w_msavi', 'w_ndmi', 'w_evi','w_dbsi','w_ndwi', 'w_ndbai','w_ndsi', 'w_rndvi', 'w_ndii','w_trvi',
                        'wNDVIre1','wNDVIre1n','wNDVIre2','wNDVIre2n', 'wNDVIre3', 'wNDVIre3n', 'wpsri', 'wCIre', 'wNDre1', 'wNDre2','wMSRre','wMSRren')
#######
##READ from the pc
#####
ws2_brick.ee <- brick(paste0(mosaicdir, ws2name))
#ws2_stack.ee <- brick(paste0(mosaicdir, ws2name))
ds2_brick.ee <- brick(paste0(mosaicdir, ds2name))
nlayers(ds2_brick.ee)
names(ws2_brick.ee) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2','w_redge4','w_redge3','w_redge2','w_redge1', 'wBRIGHTNESS', 'wGREENNESS', 'wWETNESS',
                         'w_ndvi', 'w_msavi', 'w_ndmi', 'w_evi','w_dbsi','w_ndwi', 'w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_trvi',
                         'wratiored1','wratiored2','wratiored3', 'wratio_nir1', 'wratio_nir2', 'wrationir3', 'wratioswir11','wratioswir12','wratioswir13', 'wratioswir21','wratioswir22','wratioswir23',
                         'wNDVIre1','wNDVIre1n','wNDVIre2','wNDVIre2n', 'wNDVIre3', 'wNDVIre3n', 'wpsri', 'wCIre', 'wNDre1', 'wNDre2','wMSRre','wMSRren')

nlayers(ds2_brick.ee)

names(ds2_brick.ee) <- c('d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2','d_redge4','d_redge3','d_redge2','d_redge1', 'dBRIGHTNESS', 'dGREENNESS', 'dWETNESS',
                      'd_ndvi', 'd_msavi', 'd_ndmi', 'd_evi','d_dbsi','d_ndwi', 'd_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_trvi',
                      'dwratiored1','dratiored2','dratiored3', 'dratio_nir1', 'dratio_nir2', 'drationir3', 'dratioswir11','dratioswir12','dratioswir13', 'dratioswir21','dratioswir22','dratioswir23',
                      'dNDVIre1','dNDVIre1n','dNDVIre2','dNDVIre2n', 'dNDVIre3', 'dNDVIre3n', 'dpsri', 'dCIre', 'wNDre1', 'dNDre2','dMSRre','dMSRren')


#stack
ws2_stack.ee <- brick(paste0(mosaicdir, ws2name.s))
d_stack.ee <- brick(paste0(mosaicdir, ds2name.s))
names(ws2_stack.ee) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2','w_redge4','w_redge3','w_redge2','w_redge1', 'wBRIGHTNESS', 'wGREENNESS', 'wWETNESS',
                         'w_ndvi', 'w_msavi', 'w_ndmi', 'w_evi','w_dbsi','w_ndwi', 'w_ndbai','w_ndsi', 'w_rndvi', 'w_ndii','w_trvi',
                         'wNDVIre1','wNDVIre1n','wNDVIre2','wNDVIre2n', 'wNDVIre3', 'wNDVIre3n', 'wpsri', 'wCIre', 'wNDre1', 'wNDre2','wMSRre','wMSRren')


names(ds2_stack.ee)  <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2','w_redge4','w_redge3','w_redge2','w_redge1', 'wBRIGHTNESS', 'wGREENNESS', 'wWETNESS',
                         'w_ndvi', 'w_msavi', 'w_ndmi', 'w_evi','w_dbsi','w_ndwi', 'w_ndbai','w_ndsi', 'w_rndvi', 'w_ndii','w_trvi',
                         'wNDVIre1','wNDVIre1n','wNDVIre2','wNDVIre2n', 'wNDVIre3', 'wNDVIre3n', 'wpsri', 'wCIre', 'wNDre1', 'wNDre2','wMSRre','wMSRren')

###################################################################################
##focal#############################################################################
##########################
#run loop to create RasterStack with weighted mean of 
#neighbour values for each pixel and each band in raster file with several dates and bands for the same location
#m=matrix(c(1, 2, 1, 2, 0, 2, 1, 2, 1), ncol=3, nrow=3)
#not weighted 
m=matrix(c(1, 1, 1, 1, 1, 1, 1, 1, 1), ncol=3, nrow=3)
m
#wet 
w_rs_focal=focal(ws2_brick.ee[[1]], fun=mean, w=m, na.rm=TRUE)
for (i in 2:nlayers(ws2_brick.ee))
{
  rl=focal(ws2_brick.ee[[i]], fun=mean, w=m)  #fun=sd tp create RasterStack with standard deviation within band for a set of pixels for each band (takes time)  #na.rm=TRUE
  w_rs_focal=stack(w_rs_focal, rl)
}
names(w_rs_focal)=paste(names(ws2_brick.ee),"f", sep= "")
head(w_rs_focal)
plot(w_rs_focal)
#dry
#dry
d_rs_focal=focal(ds2_brick.ee[[1]], fun=mean, w=m)
for (i in 2:nlayers(ds2_brick.ee))
{
  rl=focal(ds2_brick.ee[[i]], fun=mean, w=m, na.rm=TRUE)
  d_rs_focal=stack(d_rs_focal, rl)
}
names(d_rs_focal)=paste(names(ds2_brick.ee),"f", sep= "")
head(d_rs_focal)
plot(d_rs_focal)
#export focal layers
wname.f <- "fws2_stack.tif"
dname.f <- "fds2_stack.tif"
#w_stack.f.e <- writeRaster(w_rs_focal, filename = paste0(mosaicdir, wname.f),format="GTiff", overwrite=TRUE)

names(w_stack.f.e) <- c('w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f','w_redge4f','w_redge3f','w_redge2f','w_redge1f', 'wBRIGHTNESSf', 'wGREENNESSf', 'wWETNESSf',
                      'w_ndvif', 'w_msavif', 'w_ndmif', 'w_evif','w_dbsif','w_ndwif', 'w_ndbaif','w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_trvif',
                      'wratiored1f','wratiored2f','wratiored3f', 'wratio_nir1f', 'wratio_nir2f', 'wrationir3f', 'wratioswir11f','wratioswir12f','wratioswir13f', 'wratioswir21f','wratioswir22f','wratioswir23f',
                      'wNDVIre1f','wNDVIre1nf','wNDVIre2f','wNDVIre2nf', 'wNDVIre3f', 'wNDVIre3nf', 'wpsrif', 'wCIref', 'wNDre1f', 'wNDre2f','wMSRref','wMSRrenf')


#check out output
plot(w_stack.f.e )
#d_stack.f.e  <- writeRaster(d_rs_focal, filename = paste0(mosaicdir, dname.f),format="GTiff", overwrite=TRUE)
names(d_stack.f.e)  <- c('w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f','w_redge4f','w_redge3f','w_redge2f','w_redge1f', 'wBRIGHTNESSf', 'wGREENNESSf', 'wWETNESSf',
                          'w_ndvif', 'w_msavif', 'w_ndmif', 'w_evif','w_dbsif','w_ndwif', 'w_ndbaif','w_ndsif', 'w_rndvif', 'w_ndiif','w_trvif',
                          'wNDVIre1f','wNDVIre1nf','wNDVIre2f','wNDVIre2nf', 'wNDVIre3f', 'wNDVIre3nf', 'wpsrif', 'wCIref', 'wNDre1f', 'wNDre2f','wMSRref','wMSRrenf')

#####################################################################
##READ 

w_stack.f.ee  <- brick(paste0(mosaicdir, wname.f))
d_stack.f.ee <- brick(paste0(mosaicdir, dname.f))

names(w_stack.f.ee) <- c('w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f','w_redge4f','w_redge3f','w_redge2f','w_redge1f', 'wBRIGHTNESSf', 'wGREENNESSf', 'wWETNESSf',
                        'w_ndvif', 'w_msavif', 'w_ndmif', 'w_evif','w_dbsif','w_ndwif', 'w_ndbaif','w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_trvif',
                        'wratiored1f','wratiored2f','wratiored3f', 'wratio_nir1f', 'wratio_nir2f', 'wrationir3f', 'wratioswir11f','wratioswir12f','wratioswir13f', 'wratioswir21f','wratioswir22f','wratioswir23f',
                        'wNDVIre1f','wNDVIre1nf','wNDVIre2f','wNDVIre2nf', 'wNDVIre3f', 'wNDVIre3nf', 'wpsrif', 'wCIref', 'wNDre1f', 'wNDre2f','wMSRref','wMSRrenf')
#plot(w_stack.f.ee)
names(d_stack.f.ee) <- c('d_bluef','d_greenf','d_redf','d_NIRf','d_SWIR1f','d_SWIR2f','d_redge4f','d_redge3f','d_redge2f','d_redge1f', 'dBRIGHTNESSf', 'dGREENNESSf', 'dWETNESSf',
                         'd_ndvif', 'd_msavif', 'd_ndmif', 'd_evif','d_dbsif','d_ndwif', 'd_ndbaif','d_ndsif', 'd_rdvif', 'd_msrf','d_rndvif', 'd_ndiif','d_trvif',
                         'dratiored1f','dratiored2f','dratiored3f', 'dratio_nir1f', 'dratio_nir2f', 'drationir3f', 'dratioswir11f','dratioswir12f','dratioswir13f', 'dratioswir21f','dratioswir22f','dratioswir23f',
                         'dNDVIre1f','dNDVIre1nf','dNDVIre2f','dNDVIre2nf', 'dNDVIre3f', 'dNDVIre3nf', 'dpsrif', 'dCIref', 'dNDre1f', 'dNDre2f','dMSRref','dMSRrenf')
#plot(d_stack.f.ee)


##create final stack with focal (wet and dry) and radar data
#wdf_s1_name <- "wdf_s1brick.tif"
#wdf_stack=stack(w_stack,d_stack, w_rs_focal,d_rs_focal)
#stack focal wet and dry 100 layers
wdfs2_stack=stack(w_stack.f.ee,d_stack.f.ee)
#wdfs2_stack.e <- writeRaster(wdfs2_stack, filename = paste0(mosaicdir, "wdfs2_stack.tif"),format="GTiff", overwrite=TRUE)
extent(w_stack.f.ee)
wdfs2_stack_sameext <- "wdfs2_stack_sameext.tif"
#d_stack.f.ee_ext <- (brick(paste0(mosaic_dir,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt')))
wdfs2_stack.sameext.ext <- paste0(mosaicdir, wdfs2_stack_sameext)
#s1sameextent <- paste0(dir_s1, 's1sameext.tif')
#dir_s1 <- paste0(dir_s1,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt')
names(wdfs2_stack) <- c('w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f','w_redge4f','w_redge3f','w_redge2f','w_redge1f', 
                        'wBRIGHTNESSf', 'wGREENNESSf', 'wWETNESSf','w_ndvif', 'w_msavif', 'w_ndmif', 'w_evif','w_dbsif','w_ndwif', 'w_ndbaif',
                        'w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_trvif','wratiored1f','wratiored2f','wratiored3f', 'wratio_nir1f',
                        'wratio_nir2f', 'wrationir3f', 'wratioswir11f','wratioswir12f','wratioswir13f', 'wratioswir21f','wratioswir22f','wratioswir23f', 'wNDVIre1f','wNDVIre1nf',
                        'wNDVIre2f','wNDVIre2nf', 'wNDVIre3f', 'wNDVIre3nf', 'wpsrif', 'wCIref', 'wNDre1f', 'wNDre2f','wMSRref','wMSRrenf',
                         'd_bluef','d_greenf','d_redf','d_NIRf','d_SWIR1f','d_SWIR2f','d_redge4f','d_redge3f','d_redge2f','d_redge1f',
                        'dBRIGHTNESSf', 'dGREENNESSf', 'dWETNESSf', 'd_ndvif', 'd_msavif', 'd_ndmif', 'd_evif','d_dbsif','d_ndwif', 'd_ndbaif',
                        'd_ndsif', 'd_rdvif', 'd_msrf','d_rndvif', 'd_ndiif','d_trvif', 'dratiored1f','dratiored2f','dratiored3f', 'dratio_nir1f', 
                        'dratio_nir2f', 'drationir3f', 'dratioswir11f','dratioswir12f','dratioswir13f','dratioswir21f','dratioswir22f','dratioswir23f', 'dNDVIre1f','dNDVIre1nf',
                        'dNDVIre2f','dNDVIre2nf', 'dNDVIre3f', 'dNDVIre3nf', 'dpsrif', 'dCIref', 'dNDre1f', 'dNDre2f','dMSRref','dMSRrenf')
#Read training data
train_change <- readOGR(paste0(training_dir_local,'/',"ts_data_f_1cl_urbncorrREVIEW4LC2018USEDSEPALLC2018.shp"))   #last version 23.07
spect_stat_cha <- as.data.frame(extract(wdfs2_stack, train_change, fun=mean, na.rm=TRUE, df=FALSE, sp=TRUE))  #sp to keep spatial information
vv_tmp <- spect_stat_cha
head(spect_stat_cha)
spect_stat_cha_ORI <- spect_stat_cha
any(is.na(spect_stat_cha))  
any(is.na(vv_tmp))  
#methods(is.na)
#remove Inf values and NA
is.finite.data.frame <- function(vv_tmp){
  sapply(vv_tmp,FUN = function(x) all(is.finite(x)))
}
valuetable <- na.omit(vv_tmp)
any(is.na(valuetable))

##########################################################################################
valuetable$id <- row(valuetable)[,1]
head(valuetable)
valuetable$recl_2019 <- as.factor(train_change$recl_2019[valuetable$id])
#vv_tmp$recl_2019 <- as.factor(train_change$recl_2019[vv_tmp$id])
#colnames(vv_tmp)
#vv_tmp8$recl_code <- factor(vv_tmp8$recl_code, levels = c(1:2))
#head(vv_tmp)
tail(valuetable, n = 10)
#1 trees
#2 water
#3 bare
#4 arbustive
#5 agriculture
#6 urban
#9 ? fire
#17 agriculture with trees, water with trees
valuetable$recl_2019 <- factor(valuetable$recl_2019, levels = c(1:17))
#Let's visualize the distribution of some of these covariates for each class. To make this easier, we will create 3 different data.frames for each of the classes. This is just for plotting purposes, and we will not use these in the actual classification.
#val_crop <- subset(valuetable, recl_2019 == 5)
#val_forest <- subset(valuetable, recl_2019 == 1)
#val_water <- subset(valuetable, recl_2019 == 2)
#val_bare <- subset(valuetable, recl_2019 == 3)
#val_croptrees <- subset(valuetable, recl_2019 == 17)
#val_shrubs <- subset(valuetable, recl_2019 == 4)
## NDVI
#par(mfrow = c(3, 1))
#hist(val_crop$d_trvif, main = "cropland", xlab = "d_trvif", xlim = c(0, 1), ylim = c(0, 1000), col = "orange")
#hist(val_forest$d_trvif, main = "forest", xlab = "d_trvif", xlim = c(0, 1), ylim = c(0, 1000), col = "dark green")
#hist(val_water$d_trvif, main = "wetland", xlab = "d_trvif", xlim = c(0, 1), ylim = c(0, 1000), col = "light blue")
#par(mfrow = c(1, 1))
## 3. Bands 3 and 4 (scatterplots)
#plot(dGREENNESSf ~ dWETNESSf, data = val_crop, pch = ".", col = "orange", xlim = c(0, 0.2), ylim = c(0, 0.5))
#plot(dGREENNESSf ~ dWETNESSf, data = val_crop, pch = ".", col = "orange")
#points(dGREENNESSf ~ dWETNESSf, data = val_forest, pch = ".", col = "dark green")
#points(dGREENNESSf ~ d_msavif, data = val_water, pch = ".", col = "light blue")
#legend("topright", legend=c("cropland", "forest", "water"), fill=c("orange", "dark green", "light blue"), bg="white")
library(dplyr)
#vv_tmp_sel <- select (vv_tmp,-c(Name_12,descri2018))
#keep same name 
#valuetable <- vv_tmp_sel
class(valuetable) #check the object class
#valuetable <- as.data.frame(valuetable)
#head(valuetable, n = 20)
#tail(valuetable, n = 10)
#ncol(valuetable)
#Convert the class column into a factor (since the values as integers don't really have a meaning)
#Choose the code to be used 
#valuetable$ch_code <- factor(valuetable$ch_code, levels = c(8:14))   # levels of a factor are an attribute of the variable in this case 1, 4, 13
write.table(valuetable, file = "spect_stat_optical", append = FALSE, quote = TRUE, sep = " ",
            na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")

write.csv(valuetable, file = "spect_stat_opticalv2.csv", row.names = FALSE)   #move file in the training folder
#write.csv(vv_tmp, file = "vv_tmp_ch.csv", row.names = FALSE)
polystats.path <- paste0(training_dir_local, "spect_stat_opticalv2.csv")
polystats.pathsel <- paste0(training_dir_local, "spect_stat_opticalv2_toimport_selindex_orderednozero.csv")
spect_stat.csvsel <- read.csv(polystats.pathsel)
spect_stat.csvsel$recl_2019 <- factor(spect_stat.csvsel$recl_2019, levels = c(1:7))
#spect_stat.csv <- read.csv(polystats.path)
#head(spect_stat.csv)

spect_stat.csvsel$recl_2019 <- as.factor(spect_stat.csvsel$recl_2019)
library(randomForest)
#modelRF1 <- randomForest(x=spect_stat.csv[ ,c(2:100)], ntree=900,mtry=6, y=spect_stat.csv$recl_2019,   #7:96
#                         importance = TRUE)
############################
#wdfs2_stack_sel <- wdfs2_stack[1,3]
#wdfs2_stack_sel <- wdfs2_stack[['w_bluef','w_greenf']]
#SEL BY PATTERN
#all_GAM <- raster::subset(wdfs2_stack, grep('SWIR1f', names(wdfs2_stack), value = T))
#selected 13 "most important" layers
#names      :       w_trvif,   wratiored2f, wratioswir21f, wratioswir22f, wratioswir23f,       d_bluef,   dGREENNESSf,     dWETNESSf,       d_rdvif, dratioswir13f, dratioswir23f,        dCIref,       dMSRref 
wdfs2_stack_sel <- wdfs2_stack[[which(c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,
                                        FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,
                                        FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,TRUE,FALSE,FALSE,
                                        FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,FALSE,FALSE,
                                        FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,
                                        
                                        TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,
                                        FALSE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,
                                        FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,
                                        FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,TRUE,FALSE,FALSE,
                                        FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,TRUE,FALSE))]]
#export selected otpical layers
nlayers(wdfs2_stack_sel)
library(randomForest)
#wdfs2_stack_sel_e <- writeRaster(wdfs2_stack_sel, filename = paste0(mosaicdir, "wdfs2_stack_sel.tif"),format="GTiff", overwrite=TRUE)
#plot(brick(paste0(mosaicdir,"ds2stackext.tif")))
##########################################
polystats.path_sel <- paste0(training_dir_local, "spect_stat_opticalv2_toimport_selindex.csv")

modelRF1sel <- randomForest(x=spect_stat.csvsel[ ,c(1:13)], ntree=900,mtry=6, y=spect_stat.csvsel$recl_2019,   #7:96
                         importance = TRUE)





#paste0(mosaicdir, "wdfs2_stack_sel.tif")
#details
importance(modelRF1sel)
modelRF1sel$confusion
varImpPlot(modelRF1sel)
?importance()
#filter and subset stack considering only selected (most important) layers
## Double-check layer and column names to make sure they match
colnames(spect_stat.csvsel)
names(wdfs2_stack_sel)
names(valuetable)

predLC <- predict(wdfs2_stack_sel, model=modelRF1sel, na.rm=TRUE)
plot(predLC)
writeRaster(predLC,filename = paste0(resultdir, "hopefinal.tif"), format = "GTiff", overwrite = TRUE)


resultssel <- predict(modelRF1sel,wdfs2_stack_sel)
## Predict land cover using the RF model
resultssel <- predict(wdfs2_stack_sel, model=modelRF1sel, na.rm=TRUE)
writeRaster(resultssel,filename = "ld2019.tif", format = "GTiff", overwrite = TRUE)



