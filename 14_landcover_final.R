#RUN SUPERVISED CLASSIFICATION USING COMBINED BANDS/INDEXES S1 and S2
###################################################################

#importing trainig dataset
polystats.pathsel <- paste0(training_dir_local, "ts_data_f_1cl_urbncorrREVIEW4LC2018USEDSEPALLC2018_withIDandSTATSzerolinkedRADAR_1100CORRECTbalancedimp_sel2.csv")
spect_stat.csvsel <- read.csv(polystats.pathsel)
spect_stat.csvsel$recl_2019 <- factor(spect_stat.csvsel$recl_2019, levels = c(1:7))
train_change_df <- spect_stat.csvsel

#
vv_tmp <- train_change_df

any(is.na(train_change_df))
#train_change_df <- na.omit(vv_tmp)
train_change_df$recl_2019 <- factor(train_change_df$recl_2019, levels = c(1:7))
#library(tidyverse)
#check how many polygons (training data) per land cover class
#legend 1:tree cover 2: water 3: bare 4: shrub 5:agri 6:urban 7:agri+trees
count(train_change_df$recl_2019)
############################################################################################################################
system(sprintf("gdal_translate -ot Float32 -co COMPRESS=LZW -co BIGTIFF=YES  -projwin %s %s %s %s -tr %s %s %s %s" ,
              extent(raster(paste0(dir_s1,'/',"s1_clp2.tif")))@xmin,
              extent(raster(paste0(dir_s1,'/',"s1_clp2.tif")))@ymax,
              extent(raster(paste0(dir_s1,'/',"s1_clp2.tif")))@xmax,
              extent(raster(paste0(dir_s1,'/',"s1_clp2.tif")))@ymin,
              res(raster(paste0(dir_s1,'/',"s1_clp2.tif")))[1],
              res(raster(paste0(dir_s1,'/',"s1_clp2.tif")))[2],
              #dir_s1_b,
              paste0(mosaicdir, "wdfs2_stack.tif"),
              paste0(mosaicdir, "wdfs2_stack_clpfinal_flt.tif")

))

#optical1 <-  stack(paste0(mosaicdir, "wdfs2_stack.tif"))
dataType(optical2)
#a <- raster(stack(paste0(mosaicdir, "wdfs2_stack.tif")))
b <- optical1[[1]]
#nbands(b)
bb <- optical1[[35]] #band 35 of 100 
plot(bb)

optical <-  stack(paste0(mosaicdir, "wdfs2_stack_clpfinal_flt.tif")) 
#2 radar
s1b_clp <- brick(paste0(dir_s1,'/',"s1_clp2.tif"))
#names(s1b_clp) <- c('VVmin','VVmean','VVmed','VVmax','VVsd','VVcv','VHmin','VHmean','VHmed','VHmax','VHsd','VHcv','VVconst','VVt','VVphase','VVamp','VVresiduals', 'VHconst','VHt','VHphase','VHamp','VHresiduals')
#stack together sentinel 1 and 2 
s1s2_stack <- stack(optical,s1b_clp)
tail(s1s2_stack)
#modify stack names in line with shapefile
names(s1s2_stack) <- c('w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f','w_redge4f','w_redge3f','w_redge2f','w_redge1f', 
                       'wBRIGHTNES', 'wGREENNESS', 'wWETNESSf','w_ndvif', 'w_msavif', 'w_ndmif', 'w_evif','w_dbsif','w_ndwif', 'w_ndbaif',
                       'w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_trvif','wratiored1','wratiored2','wratiored3', 'wratio_nir',
                       'wratio_n_1', 'wrationir3', 'wratioswir','wratiosw_1','wratiosw_2', 'wratiosw_3','wratiosw_4','wratiosw_5', 'wNDVIre1f','wNDVIre1nf',
                       'wNDVIre2f','wNDVIre2nf', 'wNDVIre3f', 'wNDVIre3nf', 'wpsrif', 'wCIref', 'wNDre1f', 'wNDre2f','wMSRref','wMSRrenf',
                       'd_bluef','d_greenf','d_redf','d_NIRf','d_SWIR1f','d_SWIR2f','d_redge4f','d_redge3f','d_redge2f','d_redge1f',
                       'dBRIGHTNES', 'dGREENNESS', 'dWETNESSf', 'd_ndvif', 'd_msavif', 'd_ndmif', 'd_evif','d_dbsif','d_ndwif', 'd_ndbaif',
                       'd_ndsif', 'd_rdvif', 'd_msrf','d_rndvif', 'd_ndiif','d_trvif', 'dratiored1','dratiored2','dratiored3', 'dratio_nir', 
                       'dratio_n_1', 'drationir3', 'dratioswir','dratioswir_1','dratiosw_2','dratiosw_3','dratiosw_4','dratiosw_5', 'dNDVIre1f','dNDVIre1nf',
                       'dNDVIre2f','dNDVIre2nf', 'dNDVIre3f', 'dNDVIre3nf', 'dpsrif', 'dCIref', 'dNDre1f', 'dNDre2f','dMSRref','dMSRrenf',
                       'VVmin','VVmean','VVmed','VVmax','VVsd','VVcv','VHmin','VHmean','VHmed','VHmax','VHsd','VHcv','VVconst','VVt','VVphase_1',
                       'VVamp','VVresiduals', 'VHconst','VHt','VHphase_2','VHamp','VHresidual')



#spect_stat.csvsel2 <- spect_stat.csvsel[,-(1:2),drop=FALSE]  # still a data.frame
#Data <- Data[,-2, drop=FALSE]

library(randomForest) #2nd col (first recl_2019)
modelRF1 <- randomForest(x=train_change_df[ ,c(1:122)], ntree=900,mtry=6, y=train_change_df$recl_2019,   #7:96
                         importance = TRUE)
#build model only using the "important" layers out of the first run (using all 122 layers)
modelRF1 <- randomForest(x=train_change_df[ ,c(1:31)], ntree=900,mtry=6, y=train_change_df$recl_2019,   #7:96
                         importance = TRUE)

#Check model
print(modelRF1)
importance(modelRF1)
modelRF1$confusion
varImpPlot(modelRF1)

predLC <- predict(s1s2_stack_sel, model=modelRF1)
writeRaster(predLC,filename = paste0(resultdir, "hfinal_AUG.tif"), format = "GTiff", overwrite = TRUE)
#map_r <- predict(s1s2_stack_sel, model=modelRF1, type="prob", na.rm=TRUE)

#
#P2 <- predict(m2, newdata = nd2, type = "probs")
plot(predLC)
writeRaster(predLC,filename = paste0(resultdir, "hfinal_AUG.tif"), format = "GTiff", overwrite = TRUE)
#########################
#names      :       w_trvif,   wratiored2f, wratioswir21f, wratioswir22f, wratioswir23f,       d_bluef,   dGREENNESSf,     dWETNESSf,       d_rdvif, dratioswir13f, dratioswir23f,        dCIref,       dMSRref 
s1s2_stack_sel <- s1s2_stack[[which(c(FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE, 
                                      FALSE, FALSE, FALSE,FALSE, FALSE, FALSE, FALSE,FALSE,FALSE, FALSE,
                                      FALSE, TRUE, FALSE,FALSE, FALSE,FALSE,FALSE,FALSE,FALSE, FALSE,
                                      FALSE, FALSE, FALSE,FALSE,TRUE, TRUE,TRUE,FALSE, FALSE,FALSE,
                                      FALSE,FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,FALSE,FALSE,
                                      FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,
                                      FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE,FALSE,FALSE, TRUE,
                                      FALSE, TRUE, FALSE,FALSE, FALSE,TRUE, FALSE,FALSE,TRUE, FALSE, 
                                      FALSE, FALSE, FALSE,FALSE,FALSE,TRUE,FALSE,FALSE, FALSE,FALSE,
                                      FALSE,FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,FALSE,FALSE,
                                      TRUE,TRUE,TRUE,FALSE,TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE,
                                      TRUE,TRUE, TRUE,TRUE,TRUE,TRUE,TRUE
                                     ))]]
#LIST FROM THE CSV FILE (MAKE SURE NAMES ARE IDENTICAL TO THE STACK)
#w_SWIR2f	w_rdvif	wratiosw_2	wratiosw_3	wratiosw_4	d_SWIR2f	dGREENNESS	d_evif	d_ndbaif	d_rdvif	d_trvif	dratiored3	dratiosw_3	VVmin	VVmean	VVmed	VVsd	VVcv	VHmin	VHmean	VHmed	VHsd	VHcv	VVphase_1	VVamp	VVresidual	VHconst	VHt	VVphase_2	VHamp	VHresidual


names(s1s2_stack_sel) <- c('w_SWIR2f','w_rdvif', 'wratiosw_2', 'wratiosw_3','wratiosw_4','d_SWIR2f','dGREENNESS','d_evif','d_ndbaif',
                       'd_rdvif', 'd_trvif', 'dratiored3', 'dratiosw_3','VVmin','VVmean','VVmed','VVsd','VVcv','VHmin','VHmean','VHmed','VHsd','VHcv','VVphase_1',
                       'VVamp','VVresidual', 'VHconst','VHt','VHphase_2','VHamp','VHresidual')


#######################################
train_change_df$recl_2019 <- factor(train_change_df$recl_2019, levels = c(1:7))
#Let's visualize the distribution of some of these covariates for each class. To make this easier, we will create 3 different data.frames for each of the classes. This is just for plotting purposes, and we will not use these in the actual classification.
val_crop <- subset(train_change_df, recl_2019 == 5)
val_forest <- subset(train_change_df, recl_2019 == 1)
val_water <- subset(train_change_df, recl_2019 == 2)
val_bare <- subset(train_change_df, recl_2019 == 3)s
val_croptrees <- subset(train_change_df, recl_2019 == 7)
val_shrubs <- subset(train_change_df, recl_2019 == 4)
val_urban <- subset(train_change_df, recl_2019 == 6)
## NDVI
par(mfrow = c(3, 1))
hist(val_crop$d_trvif, main = "cropland", xlab = "d_trvif", xlim = c(0, 1), ylim = c(0, 100), col = "orange")
hist(val_forest$d_trvif, main = "forest", xlab = "d_trvif", xlim = c(0, 1), ylim = c(0, 100), col = "dark green")
hist(val_croptrees$d_trvif, main = "croptrees", xlab = "d_trvif", xlim = c(0, 1), ylim = c(0, 100), col = "light blue")
par(mfrow = c(1, 1))
## 3. Bands 3 and 4 (scatterplots)
plot(dGREENNESS ~ dWETNESSf, data = val_crop, pch = ".", col = "orange", xlim = c(0, 0.2), ylim = c(0, 0.5))
plot(dGREENNESS ~ dWETNESSf, data = val_crop, pch = ".", col = "orange")
#points(dGREENNESSf ~ dWETNESSf, data = val_forest, pch = ".", col = "dark green")
#points(dGREENNESSf ~ d_msavif, data = val_water, pch = ".", col = "light blue")
#legend("topright", legend=c("cropland", "forest", "water"), fill=c("orange", "dark green", "light blue"), bg="white")
library(dplyr)

