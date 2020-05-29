#############################################################
#RANDOM FOREST USING SENTINEL 1 data

#crop the layers 
#need to have same extent radar and optical, for some reason are not

#sentinel2 full data 
#optical <-  paste0(mosaicdir, "wdfs2_stack.tif")
#s2 <-  (brick(optical))

#sentinel1
s1 <- (brick(paste0(dir_s1,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt')))
s1_brick.e <- writeRaster(s1, filename = paste0(dir_s1, "s1.tif"),format="GTiff", overwrite=TRUE)

#convert to tif and reduce size
system(sprintf("gdalwarp  -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW -overwrite %s %s",
               paste0(dir_s1,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt'),
               paste0(dir_s1,'/',"s1.tif")
))


s1b <- (brick(paste0(dir_s1,'/',"s1.tif")))
s1 <- paste0(dir_s1,'/',"s1.tif")
s1b_clp <- brick(paste0(dir_s1,'/',"s1_clp2.tif"))
names(s1b_clp) <- c('VVmin','VVmean','VVmed','VVmax','VVsd','VVcv','VHmin','VHmean','VHmed','VHmax','VHsd','VHcv','VVconst','VVt','VVphase','VVamp','VVresiduals', 'VHconst','VHt','VHphase','VHamp','VHresiduals')
aoi_shp <- paste0(shpdir,"ZONEGENERAL2_WGS.shp")
#crop 
system(sprintf("gdalwarp  -cutline  %s -crop_to_cutline -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW  -overwrite  %s %s ",    #-dstalpha This will add an alpha band to the output tiff which masks out the area falling outside the cutline. 
               aoi_shp,
               #paste0(mosaicdir, "r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt"),
               s1,
               s1b_clp,
               "tmp"
))
#clip base on radar otherwise not same extent (even if using shame shapefile aoi_shp)
#system(sprintf("gdalwarp  -cutline  %s -crop_to_cutline -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW  -overwrite  %s %s ",    #-dstalpha This will add an alpha band to the output tiff which masks out the area falling outside the cutline. 
#               aoi_shp,
#               #paste0(mosaicdir, "r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt"),
#               paste0(mosaicdir, "wdfs2_stack_sel.tif"),
#               paste0(mosaicdir, "wdfs2_stack_sel_clp2.tif"),
#               "tmp"
#))

system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -tr %s %s -co COMPRESS=LZW %s %s",
               extent(raster(paste0(dir_s1,'/',"s1_clp2.tif")))@xmin,
               extent(raster(paste0(dir_s1,'/',"s1_clp2.tif")))@ymax,
               extent(raster(paste0(dir_s1,'/',"s1_clp2.tif")))@xmax,
               extent(raster(paste0(dir_s1,'/',"s1_clp2.tif")))@ymin,
               res(raster(paste0(dir_s1,'/',"s1_clp2.tif")))[1],
               res(raster(paste0(dir_s1,'/',"s1_clp2.tif")))[2],
               #dir_s1_b,
               paste0(mosaicdir, "wdfs2_stack_sel.tif"),
               paste0(mosaicdir, "wdfs2_stack_sel_clp3.tif")
         
))
#check extents the same
paste0(mosaicdir, "wdfs2_stack_sel_clp3.tif")
extent(s1b_clp)
extent(raster(paste0(mosaicdir, "wdfs2_stack_sel_clp3.tif")))
wdf2_brick <- brick(paste0(mosaicdir,'/',"wdfs2_stack_sel_clp3.tif"))
#stack together sentinel 1 and 2 
s1s2_stack <- stack(wdf2_brick,s1b_clp)

#names      :             
names(s1s2_stack) <- c('w_trvif', 'wratiored2f', 'wratioswir21f', 'wratioswir22f', 'wratioswir23f', 'd_bluef', 'dGREENNESSf', 'dWETNESSf', 'd_rdvif', 'dratioswir13f', 'dratioswir23f', 'dCIref','dMSRref', 'VVmin','VVmean','VVmed','VVmax','VVsd','VVcv','VHmin','VHmean','VHmed','VHmax','VHsd','VHcv','VVconst','VVt','VVphase','VVamp','VVresiduals', 'VHconst','VHt','VHphase','VHamp','VHresiduals')
train_change <- readOGR(paste0(training_dir_local,'/',"integrated_final2407.shp"))   #last version 24.07  #1137 no zero class 17 < 7 class no class9 fire
#extract statistics 
#spect_stat_s1s2 <- as.data.frame(extract(s1s2_stack, train_change, fun=mean, na.rm=TRUE, df=FALSE, sp=TRUE))  #sp to keep spatial information
#export

   #move file in the training folder

spect_stat_s1s2_ori <- spect_stat_s1s2 
vv_tmps1 <- spect_stat_s1s2
spect_stat_cha_ORIs1 <- spect_stat_s1s2
any(is.na(spect_stat_s1s2))  
any(is.na(vv_tmps1)) 
#remove Inf values and NA
is.finite.data.frame <- function(vv_tmps1){
  sapply(vv_tmps1,FUN = function(x) all(is.finite(x)))
}
valuetables1 <- na.omit(vv_tmps1)
any(is.na(valuetables1))
valuetables1$id <- row(valuetables1)[,1]
head(valuetables1)
valuetables1$recl_2019 <- as.factor(train_change$recl_2019[valuetables1$id])
valuetables1$recl_2019 <- factor(valuetables1$recl_2019, levels = c(1:7))

write.table(valuetable, file = "spect_stat_optical", append = FALSE, quote = TRUE, sep = " ",
            na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")
#backup stats
write.csv(valuetables1, file = "spect_stat_s1s2_2.csv", row.names = FALSE)  
write.csv(spect_stat_s1s2 , file = "spect_stat_s1s2_2final.csv", row.names = FALSE)  

#move file in the training folder
polystats.pathsel <- paste0(training_dir_local, "spect_stat_s1s2_2.csv")
spect_stat.csvsel <- read.csv(polystats.pathsel)
spect_stat.csvsel$recl_2019 <- factor(spect_stat.csvsel$recl_2019, levels = c(1:7))

spect_stat.csvsel$recl_2019 <- as.factor(spect_stat.csvsel$recl_2019)
library(randomForest)
spect_stat.csvsel

spect_stat.csvsel2 <- spect_stat.csvsel[,-(1:2),drop=FALSE]  # still a data.frame
Data <- Data[,-2, drop=FALSE]

modelRF1sel <- randomForest(x=spect_stat.csvsel[ ,c(1:13)], ntree=900,mtry=6, y=spect_stat.csvsel$recl_2019,   #7:96
                            importance = TRUE)






