
########################################################################################## 
#Modified from script  BY remi.dannunzio@fao.org
# Clipping ESACCI map using the aoi boundary shapefile - used to create a buildup mask
##########################################################################################

time_start  <- Sys.time()

####################################################################################
####### GET COUNTRY BOUNDARIES
####################################################################################
#aoi <- getData('GADM',path=gadm_dir, country= countrycode, level=1)
#crs(aoi.utm)
#aoi.utm <- readOGR(aoi.shp)

aoi.shp <- paste0(shpdir,'/',"ZONEGENERAL2_WGS.shp")


aoi <- readOGR(aoi.shp)
#aoi=spTransform(aoi.utm,CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")) # To convert it to WGS84
#crs(aoi)
##  Add a numerical unique identifier and Export the SpatialPolygonDataFrame as a ESRI Shapefile
aoi$OBJECTID <- row(aoi)[,1]
writeOGR(aoi,
         paste0(gadm_dir,"gadm_",countrycode,"_l1.shp"),
         paste0("gadm_",countrycode,"_l1"),
         "ESRI Shapefile",
         overwrite_layer = T)


####################################################################################
####### DOWNLOAD THE ESA MAP FROM ESA-CCI WEBSITE
####################################################################################
if(!file.exists(paste0(esastore_dir,"ESACCI-LC-L4-LC10-Map-20m-P1Y-2016-v1.0.tif"))){
  source(paste0(scriptdir,"scripts_masks/download_ESA_CCI_map.R"),echo=T)
}


####################################################################################
####### CLIP ESA MAP TO COUNTRY BOUNDING BOX
####################################################################################
if(!file.exists(paste0(esa.downloaddir,"esa_crop.tif"))){
  
  bb <- extent(aoi)
  
  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 paste0(esastore_dir,"ESACCI-LC-L4-LC10-Map-20m-P1Y-2016-v1.0.tif"),
                 paste0(esa.downloaddir,"/tmp_esa.tif")
  )
  )
}



#############################################################
### CROP TO COUNTRY BOUNDARIES
if(!file.exists(paste0(esa.downloaddir,"esa_crop.tif"))){
  system(sprintf("python %s/oft-cutline_crop.py -v %s -i %s -o %s -a %s",
                 paste0(scriptdir,"scripts_misc/"),
                 #paste0(gadm_dir,"gadm_",countrycode,"_l1.shp"),
                 aoi.shp,
                 paste0(esa.downloaddir,"tmp_esa.tif"),
                 paste0(esa.downloaddir,"esa_crop3.tif"),
                 #"OBJECTID"
                 "tmp"
  ))
  
}

#############################################################
### CREATE A FOREST MASK FOR BFAST ANALYSIS
#if(!file.exists(paste0(esa_dir,"esa_fnf.tif"))){
#  
#  system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
#                 paste0(esa_dir,"esa_crop.tif"),
#                 paste0(esa_dir,"esa_fnf.tif"),
#                 paste0("(A==0)*0 + ((A==1)+(A==2))*1 + (A>2)*0")
#  )
#  )
#}

#############################################################
### CREATE A build-up  MASK FOR BFAST ANALYSIS (to improve the results of the forest mask e.g. trees in urban/village areas should be masked out)


##paste0("(A==0)*0 + ((A==1)+(A==2))*1 + (A>2)*0") 

if(!file.exists(paste0(esa.downloaddir,"esa_buildup_msk.tif"))){
  
  system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
                 paste0(esa.downloaddir,"esa_crop3.tif"),
                 paste0(esa.downloaddir,"esa_buildup_msk2.tif"),
                 paste0("(A<8)*0 + (A==8)*1+(A>8)*0")
  )
  )
}


#set to zero areas urban-build up
if(!file.exists(paste0(esa.downloaddir,"esa_buildup_msk.tif"))){
  
  system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
                 paste0(esa.downloaddir,"esa_crop3.tif"),
                 paste0(esa.downloaddir,"esa_buildup_msk2_zerobuildup.tif"),
                 paste0("(A<8)*1 + (A==8)*0+(A>8)*1")
                 
  )
  )
}


time_products_global <- Sys.time() - time_start


