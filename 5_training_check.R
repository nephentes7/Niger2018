####################################################################################
#Import collected training dataset (polygons)
################################################################################


#train_shp (parameter set)
training <- readOGR(train_shp)
#check out the code = recl_2013 to classify 2013 mosaics 
#code [2013_msk] for the forest/shrub mask: 1 sav. arboree 4. sav. arbustive 13. others 0. no data of interest
## plot the histogram
head(training@data)
# how many attributes 
length(training@data)
names(training@data)
training$X2013_msk
# view unique values within the selected attribute
levels(training$X2013_msk)
#subset  and save it as object
#training[training$training == "...",]
training[training$X2013_msk != "0",]
# save an object with only footpath lines
training_no0 <-training[training$X2013_msk != "0",]
training
training_no0
# how many features are in our new object
length(training)
length(training_no0)
#summary(training$X2013_msk)
w = table(training_no0$X2013_msk)
w
tr_code <- training_no0$X2013_msk
#training dataset by class (code)
val_forest <- subset(training, tr_code == 1)
val_nonforest <- subset(training, tr_code == 13)
val_shrub <- subset(training, tr_code == 4)
head(val_shrub )
#val_wetland <- subset(training, tr_code == 3)

## 1. NDVI
#hist(val_nonforest$b21, main = "nonforest", xlab = "b21", xlim = c(min(val_crop$b21), max(val_crop$b21)), ylim = c(0, NROW(val_crop)), col = "orange")
#hist(val_forest$b21, main = "forest", xlab = "b21", xlim = c(0, max(val_forest$b21)+1000), ylim = c(0, NROW(val_forest)), col = "dark green")
## 3. Bands 3 and 4 (scatterplots)
#plot(b21 ~ b20, data = val_nonforest, pch = ".", col = "orange", xlim = c(0, 0.2), ylim = c(0, 0.5))
#points(band4 ~ band3, data = val_forest, pch = ".", col = "dark green")
#points(band4 ~ band3, data = val_wetland, pch = ".", col = "light blue")
#legend("topright", legend=c("nonforest", "forest", "wetland"), fill=c("orange", "dark green", "light blue"), bg="white")
