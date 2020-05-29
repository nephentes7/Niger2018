#########################################
#Run the algorithm Random Forest 
#devtools::install_github('cran/ggplot2')
#training data
plot(training_no0)
crs(training_no0)

#CLEAN THE DATABASE
#check if there are NA
any(is.na(spect_stat))  
#methods(is.na)
spect_stat -> vv_tmp
#remove Inf values and NA
is.finite.data.frame <- function(vv_tmp){
  sapply(vv_tmp,FUN = function(x) all(is.finite(x)))
}
valuetable <- na.omit(vv_tmp)
any(is.na(valuetable))
any(is.infinite(valuetable))   
#valuetable <- as.data.frame(valuetable)

class(valuetable) #check the object class
valuetable <- as.data.frame(valuetable)
head(valuetable, n = 20)
tail(valuetable, n = 10)
#Convert the class column into a factor (since the values as integers don't really have a meaning)
#Choose the code to be used 
valuetable$X2013_msk <- factor(valuetable$X2013_msk, levels = c(1:13))   
getwd()


#READINING TRAINING DATA

#polystats <- "spect_stat.csv"
polystats <- "spect_statNEWURB.csv"
#export the results in a txt or csv file
#write.table(valuetable, file = "spect_stat", append = FALSE, quote = TRUE, sep = " ",
#            na = "NA", dec = ".", row.names = TRUE,
#            col.names = TRUE, qmethod = c("escape", "double"),
#            fileEncoding = "")

#write.csv(valuetable, file = "spect_stat.csv", row.names = FALSE)
#a <- write.csv(valuetable, file = paste0(training_dir_local, polystats), row.names = FALSE)

#valuetable.cl <- droplevels(valuetable[valuetable$X2013_msk,])
#valuetable.cl$X2013_msk

#If you want to drop missing levels when subsetting, wrap your subset operation in droplevels()
polystats.path <- paste0(training_dir_local, polystats)
spect_stat.csv <- read.csv(polystats.path)


#select only focal columns and drop the rest
#spect_stat.csv.f <- read.csv(polystats.path)[ ,c('X2013_msk','w_bluef','w_greenf','w_redf','w_NIRf','w_SWIR1f','w_SWIR2f', 'w_Thermalf','w_ndvif', 'w_msavif', 'w_ndmif', 'w_ebbif','w_evif','w_dbsif','w_ndwif', 'w_dbif', 'w_dbiadjf','w_ndbaif','w_ndsif', 'w_rdvif', 'w_msrf','w_rndvif', 'w_ndiif','w_ndbr2f','w_trvif','d_bluef','d_greenf','d_redf','d_NIRf','d_SWIR1f','d_SWIR2f', 'd_Thermalf','d_ndvif', 'd_msavif', 'd_ndmif', 'd_ebbif','d_evif','d_dbsif','d_ndwif', 'd_dbif', 'd_dbiadjf','d_ndbaif','d_ndsif', 'd_rdvif', 'd_msrf','d_rndvif', 'd_ndiif','d_ndbr2f','d_trvif')]
#spect_stat.csv.f$X2013_msk <- as.factor(spect_stat.csv.f$X2013_msk)

spect_stat.csv$X2013_msk <- as.factor(spect_stat.csv$X2013_msk)
#1
modelRF1 <- randomForest(x=spect_stat.csv[ ,c(7:96)], y=spect_stat.csv$X2013_msk,   #7:96
                        importance = TRUE)

#2
#modelRF2 <- randomForest(x=spect_stat.csv[ ,c(7:96)],ntree=1000,mtry=6, y=spect_stat.csv$X2013_msk,
#                        importance = TRUE)

#3 only using focal data stats


#modelRF3 <- randomForest(x=spect_stat.csv.f[ ,c(2:48)],ntree=800,mtry=6, y=spect_stat.csv.f$X2013_msk,
#                         importance = TRUE)



#results.prob       <- predict(fit,img_segs_spec,keep.forest=TRUE, type = "prob")
#head(results.prob[,1])

#model
importance(modelRF1)
print(modelRF1)
class(modelRF2)
str(modelRF1)
names(modelRF1)
modelRF2$confusion
# to make the confusion matrix more readable
colnames(modelRF1$confusion) <- c("forest", "shrubs", "no_forest","class_error")
rownames(modelRF1$confusion) <- c("forest", "shrubs", "no_forest")
modelRF1$confusion
#variable "importance"
varImpPlot(modelRF1)

map.r <- predict(wdf_brick.ee, model=modelRF1, type="prob", na.rm=TRUE)   #keep.forest=TRUE  #keep.forest: If set to FALSE, the forest will not be retained in the output object. If xtest is given, defaults to FALSE.    #  results<-predict(fit,img_segs_spec,keep.forest=TRUE)

#map.r2 <- predict(modelRF,wdf_brick.ee,keep.forest=TRUE, type = "prob",na.rm=TRUE)

map.r2 <- predict(modelRF1,wdf_brick.ee,keep.forest=TRUE)
plot(map.r2)
head(map.r[,1])

plot(map.r)

####EXPORT MAP
outdir <- paste0(rootdir,'/',"results")
if(!dir.exists(outdir)){dir.create(outdir, recursive = T)}
resultdir.maps <- paste0(resultdir,'/maps')
if(!dir.exists(resultdir.maps)){dir.create(resultdir.maps, recursive = T)}
map_name <- "2013_mask_v2final19062019.tif"

writeRaster(map.r,filename = paste0(resultdir, map_name), format = "GTiff", overwrite = TRUE)

classification <- raster(paste0(resultdir, map_name))







