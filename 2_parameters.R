# ################################################################################
## Parameters/directories for classification 

## create all needed directories
seg_dir_local <- paste0(rootdir,'/',"seg/tiles")#"training_manual/")
if(!dir.exists(seg_dir_local)){dir.create(seg_dir_local, recursive = T)}
outdir <- paste0(rootdir,'/',"example1")
if(!dir.exists(outdir)){dir.create(outdir, recursive = T)}
outdir.tiles <- paste0(rootdir,'/tiles')
if(!dir.exists(outdir.tiles)){dir.create(outdir.tiles, recursive = T)}
outdir.prob <- paste0(outdir,'/',"probability")
if(!dir.exists(outdir.prob)){dir.create(outdir.prob, recursive = T)}
outdir.class <- paste0(outdir,'/',"class")
if(!dir.exists(outdir.class)){dir.create(outdir.class, recursive = T)}
outdir.class.shp <- paste0(outdir,'/',"class_shp")
if(!dir.exists(outdir.class)){dir.create(outdir.class, recursive = T)}
outdir.training <- paste0(outdir,'/',"training_outputs")
if(!dir.exists(outdir.training)){dir.create(outdir.training, recursive = T)}

outdir.training <- paste0(outdir,'/',"training_outputs")
if(!dir.exists(outdir.training)){dir.create(outdir.training, recursive = T)}

#data download directory (e.g. esacii)
esa.downloaddir <- paste0(rootdir, 'download/ESA_2016/')
if(!dir.exists(esa.downloaddir)){dir.create(esa.downloaddir, recursive = T)}

#dir where shapefiles (.e.g admin, boundaries etc.)
shpdir <- paste0(rootdir, 'shp/')
if(!dir.exists(shpdir)){dir.create(shpdir, recursive = T)}
#change layers directory
change_layers_dir_local <- paste0(rootdir, 'mosaics/change_stack/')
if(!dir.exists(change_layers_dir_local)){dir.create(change_layers_dir_local, recursive = T)}
#IMAD directory
imad_dir_local <- paste0(rootdir,'/',"mosaics/IMAD/")
if(!dir.exists(imad_dir_local)){dir.create(imad_dir_local, recursive = T)}


shpdir <- paste0(rootdir, 'shp/')

#landcover directory
landcover_dir <- paste0(rawimgdir,'/','landcover/')
if(!dir.exists(landcover_dir)){dir.create(landcover_dir, recursive = T)}


#final results of change detection
finalch_dir <- paste0(bfast_dir,'/','final/')
if(!dir.exists(finalch_dir)){dir.create(finalch_dir, recursive = T)}


##INPUT IMAGE (LANDSAT/SENTINEL) FOR CLASSIFICATION
getwd()
#virtual raster
#wetdir.r <- raster(t1_file_wet)
#no virtual raster
#wetdir.r <- raster(paste0(mosaicdir, mosaic_name_fomask_wet))
#n.b. if you use raster() you'll only get one layer read
#use stack
#wetdir.r <- stack(t1_file_wet)
wetdir.r <- stack(paste0(mosaicdir, mosaic_name_fomask_wet))
drydir.r <- stack(paste0(mosaicdir, mosaic_name_fomask_dry))
#wetdir.r.2018 <- stack(paste0(mosaicdir, mosaic_name_fomask_wet2018))
#drydir.r.2018 <- stack(paste0(mosaicdir, mosaic_name_fomask_dry2018))
wetdir.r.2018 <- stack(paste0(wetdir2018, mosaic_name_fomask_wet2018))
drydir.r.2018 <- stack(paste0(drydir2018, mosaic_name_fomask_dry2018))
#2018 landsat images have 7 bands

#1 blue
#2 green
#3 red
#4 nir
#5 swir1
#6 swir2
#7 thermal
dir_s1 <- paste0(landcover_dir,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier/')



mosaic_name_fomask_wet2018    <- "ng_ls_20189_15agow_aoif.vrt"
mosaic_name_fomask_dry2018 <- "ng_ls_20189_15agow_aoif.vrt"




nlayers(wetdir.r)
nlayers(drydir.r)
#drydir.r <- raster(t1_file_dry)
#...RasterBrick is often more efficient and faster to process - which is important when working with larger files.
wetdir.r.b <- brick(wetdir.r)
drydir.r.b <- brick(drydir.r)
wetdir.r.b.2018 <- brick(wetdir.r.2018)
drydir.r.b.2018 <- brick(drydir.r.2018)
#wetdir.r.s <- stack(wetdir.r)
#nlayers(wetdir.r.s)
#drydir.r.s <- stack(drydir.r)
#names(wetdir.r.b) <- c('blue','green','red','NIR','SWIR1','SWIR2', 'thermal', 'thermal2','x')
#9 bands landsat: 
#1 blue
#2 green
#3 red
#4 nir
#5 swir1
#6 swir2
#7 thermal
#8 thermal2 
#9 ?

#take first 7 bands
#raslist <- paste0("ng_ls_20134oct_w_aoifinal-000000", 1:7, ".tif")
#test<- raster(paste0(wetdir,'/','ng_ls_20134oct_w_aoifinal-0000008192-0000008192.tif'))
#drydir <- paste0(rawimgdir,'/','ng_ls_20131jan_d_aoifinal')
#raslist <- paste0("ng_ls_20134oct_w_aoifinal-000000", 1:7, ".tif")

wetdir.r.b.7 <- subset(wetdir.r.b, 1:7)
drydir.r.b.7 <- subset(drydir.r.b, 1:7)
wetdir.r.b.7.2018 <- wetdir.r.b.2018
drydir.r.b.7.2018 <- drydir.r.b.2018

# Number of bands in  new dataset
nlayers(wetdir.r.b.7)
nlayers(drydir.r.b.7)
names(wetdir.r.b.7) <- c('blue','green','red','NIR','SWIR1','SWIR2', 'thermal')
names(drydir.r.b.7) <- c('blue','green','red','NIR','SWIR1','SWIR2', 'thermal')
xw <- wetdir.r.b.7

names(wetdir.r.b.7.2018) <- c('blue','green','red','NIR','SWIR1','SWIR2', 'thermal')
names(drydir.r.b.7.2018) <- c('blue','green','red','NIR','SWIR1','SWIR2', 'thermal')
xw.2018 <- wetdir.r.b.7.2018

#ls = landsat w/d = wet/dry
#lsw...
lswblue <- raster(xw,"blue")
lswgreen <- raster(xw,"green")
lswred <- raster(xw,"red")
lswNIR <- raster(xw,"NIR")
lswSWIR <- raster(xw,"SWIR1")
lswSWIR2 <- raster(xw,"SWIR2")
lswthermal <- raster(xw,"thermal")
xd <- drydir.r.b.7

xd.2018 <- drydir.r.b.7.2018
nlayers(xd)
#lsd...
lsdblue <- raster(xd,"blue")
lsdgreen <- raster(xd,"green")
lsdred <- raster(xd,"red")
lsdNIR <- raster(xd,"NIR")
lsdSWIR <- raster(xd,"SWIR1")
lsdSWIR2 <- raster(xd,"SWIR2")
lsdthermal <- raster(xd,"thermal")  


######################2018
#lsw2018
lswblue.2018 <- raster(xw.2018,"blue")
lswgreen.2018 <- raster(xw.2018,"green")
lswred.2018 <- raster(xw.2018,"red")
lswNIR.2018 <- raster(xw.2018,"NIR")
lswSWIR.2018 <- raster(xw.2018,"SWIR1")
lswSWIR2.2018 <- raster(xw.2018,"SWIR2")
lswthermal.2018 <- raster(xw.2018,"thermal")

nlayers(xd)
#lsd2018
lsdblue.2018 <- raster(xd.2018,"blue")
lsdgreen.2018 <- raster(xd.2018,"green")
lsdred.2018 <- raster(xd.2018,"red")
lsdNIR.2018 <- raster(xd.2018,"NIR")
lsdSWIR.2018 <- raster(xd.2018,"SWIR1")
lsdSWIR2.2018 <- raster(xd.2018,"SWIR2")
lsdthermal.2018 <- raster(xd.2018,"thermal") 

################################################



#projection and same spatial resolution as also extent
#check projections
crs(wetdir.r.b.7)
crs(drydir.r.b.7)
#check resolution
res(wetdir.r.b.7)
res(drydir.r.b.7)
extent(wetdir.r.b.7)
extent(drydir.r.b.7)
extent(drydir.r.b.7.2018)


#reproject (in case needed)
#utm <- "+proj=utm +zone=31 ellps=WGS84"    #WGS 84 / UTM zone 31N - EPSG:32631 - EPSG.io
#wetdir.r.b.7.utm <- projectRaster(wetdir.r.b.7, crs = utm)
#drydir.r.b.7.utm <- projectRaster(drydir.r.b.7, crs = utm)
#ewet <- extent(wetdir.r.b.7.utm)
#extent(wetdir.r.b.7.utm)
#extent(drydir.r.b.7.utm)
#res(wetdir.r.b.7.utm)
#res(drydir.r.b.7.utm)

#to wgs
#wgs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
#xdwgs <- projectRaster(drydir.r.b.7.utm, crs=wgs)


###########################################################################

train_shp <-  paste0(training_dir_local,'/',substr(basename(t1_train), 1, nchar(basename(t1_train))-4),'.shp')
#train_shp <- paste0(training_dir_local,'/',"ts_data_f.shp")
train_rst <- paste0(outdir.training,'/',substr(basename(t1_train), 1, nchar(basename(t1_train))-4),'.tif')

#stack of wet and dry
#im_input <-t1_file
