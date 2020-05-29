################################################################################
###Selection of the indexes AND perform the mean value in a 3 by 3 pixels window
#Create a raster stack with the original bands for the wet and dry period as also the indexes generated for boht seasons

w_ndvi
d_ndvi 
w_msavi 
plot
d_msavi  
w_ndmi 
d_ndmi 
w_ebbi
d_ebbi 
w_evi
d_evi
w_dbsi 
d_dbsi 
w_ndwi 
d_ndwi
w_dbi 
d_dbi
w_dbiadj
d_dbiadj
w_ndbai
d_ndbai 
w_ndsi 
d_ndsi 
w_rdvi 
d_rdvi 
w_msr 
d_msr 
w_rndvi 
d_rndvi
w_ndii
d_ndii
w_ndbr2 
d_ndbr2 
w_trvi
d_trvi 
###########################
xw <- wetdir.r.b.7
xd <- drydir.r.b.7
w_stack <- stack(wetdir.r.b.7,w_ndvi,w_msavi, w_ndmi, w_ebbi, w_evi, w_dbsi, w_ndwi, w_dbi, w_dbiadj, w_ndbai, w_ndsi, w_rdvi, w_msr, w_rndvi, w_ndii, w_ndbr2, w_trvi)
w_brick <- brick(w_stack)
names(w_brick) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2', 'w_Thermal','w_ndvi', 'w_msavi', 'w_ndmi', 'w_ebbi','w_evi','w_dbsi','w_ndwi', 'w_dbi', 'w_dbiadj','w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_ndbr2','w_trvi')
nlayers(w_brick)
d_stack <- stack(drydir.r.b.7,d_ndvi,d_msavi,d_ndmi, d_ebbi, d_evi, d_dbsi, d_ndwi, d_dbi, d_dbiadj, d_ndbai, d_ndsi, d_rdvi, d_msr, d_rndvi, d_ndii, d_ndbr2, d_trvi)
d_brick <- brick(d_stack)
names(d_brick) <- c('d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2', 'd_Thermal','d_ndvi', 'd_msavi', 'd_ndmi', 'd_ebbi','d_evi','d_dbsi','d_ndwi', 'd_dbi', 'd_dbiadj','d_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_ndbr2','d_trvi')
nlayers(d_brick)


#########################################################################################################
##EXPORT to raster
###########################################################################################################
wname <- "w_brick.tif"
wname.s <- "s_stack.tif"
dname <- "d_brick.tif"
dname.s <- "d_stack.tif"
#w_brick.e <- writeRaster(w_brick, filename = paste0(mosaicdir, wname),format="GTiff", overwrite=TRUE)
#w_stack.e <- writeRaster(w_stack, filename = paste0(mosaicdir, wname.s),format="GTiff", overwrite=TRUE)

#names(w_brick.e) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2', 'w_Thermal','w_ndvi', 'w_msavi', 'w_ndmi', 'w_ebbi','w_evi','w_dbsi','w_ndwi', 'w_dbi', 'w_dbiadj','w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_ndbr2','w_trvi')
#names(w_stack.e) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2', 'w_Thermal','w_ndvi', 'w_msavi', 'w_ndmi', 'w_ebbi','w_evi','w_dbsi','w_ndwi', 'w_dbi', 'w_dbiadj','w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_ndbr2','w_trvi')
#d_brick.e <- writeRaster(d_brick, filename = paste0(mosaicdir, dname),format="GTiff", overwrite=TRUE)
#names(d_brick.e) <- c('d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2', 'd_Thermal','d_ndvi', 'd_msavi', 'd_ndmi', 'd_ebbi','d_evi','d_dbsi','d_ndwi', 'd_dbi', 'd_dbiadj','d_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_ndbr2','d_trvi')

#d_stack.e <- writeRaster(d_stack, filename = paste0(mosaicdir, dname.s),format="GTiff", overwrite=TRUE)
#names(d_stack.e) <- c('d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2', 'd_Thermal','d_ndvi', 'd_msavi', 'd_ndmi', 'd_ebbi','d_evi','d_dbsi','d_ndwi', 'd_dbi', 'd_dbiadj','d_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_ndbr2','d_trvi')

#######
##READ from the pc
#####
w_brick.ee <- brick(paste0(mosaicdir, wname))
d_brick.ee <- brick(paste0(mosaicdir, dname))
nlayers(d_brick.ee)
names(w_brick.ee) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2', 'w_Thermal','w_ndvi', 'w_msavi', 'w_ndmi', 'w_ebbi','w_evi','w_dbsi','w_ndwi', 'w_dbi', 'w_dbiadj','w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_ndbr2','w_trvi')
d_brick.ee <- brick(paste0(mosaicdir, dname))
names(d_brick.ee) <- c('d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2', 'd_Thermal','d_ndvi', 'd_msavi', 'd_ndmi', 'd_ebbi','d_evi','d_dbsi','d_ndwi', 'd_dbi', 'd_dbiadj','d_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_ndbr2','d_trvi')
nlayers(d_brick.ee)


#stack
w_stack.ee <- brick(paste0(mosaicdir, wname.s))
d_stack.ee <- brick(paste0(mosaicdir, dname.s))
names(w_stack.ee ) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2', 'w_Thermal','w_ndvi', 'w_msavi', 'w_ndmi', 'w_ebbi','w_evi','w_dbsi','w_ndwi', 'w_dbi', 'w_dbiadj','w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_ndbr2','w_trvi')
names(d_stack.ee) <- c('d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2', 'd_Thermal','d_ndvi', 'd_msavi', 'd_ndmi', 'd_ebbi','d_evi','d_dbsi','d_ndwi', 'd_dbi', 'd_dbiadj','d_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_ndbr2','d_trvi')

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
w_rs_focal=focal(w_brick.ee[[1]], fun=mean, w=m, na.rm=TRUE)
for (i in 2:nlayers(w_brick.ee))
{
  rl=focal(w_brick.ee[[i]], fun=mean, w=m)  #fun=sd tp create RasterStack with standard deviation within band for a set of pixels for each band (takes time)  #na.rm=TRUE
  w_rs_focal=stack(w_rs_focal, rl)
}
names(w_rs_focal)=paste(names(w_brick.ee),"f", sep= "")
head(w_rs_focal)
plot(w_rs_focal)
#dry
#dry
d_rs_focal=focal(d_brick.ee[[1]], fun=mean, w=m)
for (i in 2:nlayers(d_brick.ee))
{
  rl=focal(d_brick.ee[[i]], fun=mean, w=m, na.rm=TRUE)
  d_rs_focal=stack(d_rs_focal, rl)
}
names(d_rs_focal)=paste(names(d_brick.ee),"f", sep= "")
head(d_rs_focal)
plot(d_rs_focal)


#export focal layers
wname.f <- "fw_stack.tif"
dname.f <- "fd_stack.tif"
w_stack.f.e <- writeRaster(w_rs_focal, filename = paste0(mosaicdir, wname.f),format="GTiff", overwrite=TRUE)
names(w_stack.f.e) <- c('w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f', 'w_Thermalf','w_ndvif', 'w_msavif', 'w_ndmif', 'w_ebbif','w_evif','w_dbsif','w_ndwif', 'w_dbif', 'w_dbiadjf','w_ndbaif','w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_ndbr2f','w_trvif')
d_stack.f.e  <- writeRaster(d_rs_focal, filename = paste0(mosaicdir, dname.f),format="GTiff", overwrite=TRUE)
names(d_stack.f.e) <- c('d_bluef','d_greenf','d_redf','d_NIRf','d_SWIR1f','d_SWIR2f', 'd_Thermalf','d_ndvif', 'd_msavif', 'd_ndmif', 'd_ebbif','d_evif','d_dbsif','d_ndwif', 'd_dbif', 'd_dbiadjf','d_ndbaif','d_ndsif', 'd_rdvif', 'd_msrf','d_rndvif', 'd_ndiif','d_ndbr2f','d_trvif')


##READ 

wname.f.ee <- brick(paste0(mosaicdir, wname.f))
dname.f.ee <- brick(paste0(mosaicdir, dname.f))
names(wname.f.ee) <- c('w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f', 'w_Thermalf','w_ndvif', 'w_msavif', 'w_ndmif', 'w_ebbif','w_evif','w_dbsif','w_ndwif', 'w_dbif', 'w_dbiadjf','w_ndbaif','w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_ndbr2f','w_trvif')
names(dname.f.ee) <- c('d_bluef','d_greenf','d_redf','d_NIRf','d_SWIR1f','d_SWIR2f', 'd_Thermalf','d_ndvif', 'd_msavif', 'd_ndmif', 'd_ebbif','d_evif','d_dbsif','d_ndwif', 'd_dbif', 'd_dbiadjf','d_ndbaif','d_ndsif', 'd_rdvif', 'd_msrf','d_rndvif', 'd_ndiif','d_ndbr2f','d_trvif')

wdfname <- "wdf_brick.tif"
#wdf_stack=stack(w_stack,d_stack, w_rs_focal,d_rs_focal)
wdf_stack=stack(w_stack.e,d_stack.e, w_stack.f.e,d_stack.f.e)
wdf_brick <- brick(wdf_stack)
names(wdf_brick) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2', 'w_Thermal','w_ndvi', 'w_msavi', 'w_ndmi', 'w_ebbi','w_evi','w_dbsi','w_ndwi', 'w_dbi', 'w_dbiadj','w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_ndbr2','w_trvi','w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f', 'w_Thermalf','w_ndvif', 'w_msavif', 'w_ndmif', 'w_ebbif','w_evif','w_dbsif','w_ndwif', 'w_dbif', 'w_dbiadjf','w_ndbaif','w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_ndbr2f','w_trvif','d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2', 'd_Thermal','d_ndvi', 'd_msavi', 'd_ndmi', 'd_ebbi','d_evi','d_dbsi','d_ndwi', 'd_dbi', 'd_dbiadj','d_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_ndbr2','d_trvi','d_bluef','d_greenf','d_redf','d_NIRf','d_SWIR1f','d_SWIR2f', 'd_Thermalf','d_ndvif', 'd_msavif', 'd_ndmif', 'd_ebbif','d_evif','d_dbsif','d_ndwif', 'd_dbif', 'd_dbiadjf','d_ndbaif','d_ndsif', 'd_rdvif', 'd_msrf','d_rndvif', 'd_ndiif','d_ndbr2f','d_trvif')
labels(wdf_brick)


##Read file 
############################################################################
###EXPORT FINAL STACK 
#f_brick.e <- writeRaster(wdf_brick, filename = paste0(mosaicdir, wdfname),format="GTiff", overwrite=TRUE)
##READ
##READ from the pc
#####
wdfname <- "wdf_brick.tif"
wdf_brick.ee <- brick(paste0(mosaicdir, wdfname))
nlayers(wdf_brick.ee)   #96 layers  #24+24f (wet) + 24+24f (dry)
names(wdf_brick.ee) <- c('w_blue','w_green','w_red','w_NIR','w_SWIR1','w_SWIR2', 'w_Thermal','w_ndvi', 'w_msavi', 'w_ndmi', 'w_ebbi','w_evi','w_dbsi','w_ndwi', 'w_dbi', 'w_dbiadj','w_ndbai','w_ndsi', 'w_rdvi', 'w_msr','w_rndvi', 'w_ndii','w_ndbr2','w_trvi','w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f', 'w_Thermalf','w_ndvif', 'w_msavif', 'w_ndmif', 'w_ebbif','w_evif','w_dbsif','w_ndwif', 'w_dbif', 'w_dbiadjf','w_ndbaif','w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_ndbr2f','w_trvif','d_blue','d_green','d_red','d_NIR','d_SWIR1','d_SWIR2', 'd_Thermal','d_ndvi', 'd_msavi', 'd_ndmi', 'd_ebbi','d_evi','d_dbsi','d_ndwi', 'd_dbi', 'd_dbiadj','d_ndbai','d_ndsi', 'd_rdvi', 'd_msr','d_rndvi', 'd_ndii','d_ndbr2','d_trvi','d_bluef','d_greenf','d_redf','d_NIRf','d_SWIR1f','d_SWIR2f', 'd_Thermalf','d_ndvif', 'd_msavif', 'd_ndmif', 'd_ebbif','d_evif','d_dbsif','d_ndwif', 'd_dbif', 'd_dbiadjf','d_ndbaif','d_ndsif', 'd_rdvif', 'd_msrf','d_rndvif', 'd_ndiif','d_ndbr2f','d_trvif')
labels(wdf_brick.ee)