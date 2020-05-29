###################################################################
#1. buildup areas from ESACCI Map - maksed out 
#2. reclassification of the Random Forest results 
####################################################################


#names 
map_name <- "2013_mask_v2final19062019.tif"
#names of the masks
#savanna arborees ("tree cover"> 10%) forest-non forest mask
fnf_mask <- "2013_fnf_MSK.tif"
fnf_mask_u <- "2013_fnf_MSK_u.tif"
#savanna arbustive ("shrub cover"> 10%) shrub-non shrub mask
sns_mask <- "2013_sns_MSK.tif"
sns_mask_u <- "2013_sns_MSK_u.tif"

FNF_mask <- paste0(resultdir, fnf_mask)
SNS_mask <- paste0(resultdir, sns_mask)

FNF_mask_u <- paste0(resultdir, fnf_mask_u)
SNS_mask_u <- paste0(resultdir, sns_mask_u)

SNS_mask.name <- "sns_mask.tif"
RF_results <- "2013_mask_v2final19062019.tif"
RF_results.r <- raster(paste0(resultdir, RF_results))
RF_results.path <- paste0(resultdir, RF_results)
urbanmsk.r <- raster(paste0(esa.downloaddir,urbanmsk))

## match the extent of the 2 LC maps -- using the extent of 2015
## match the extent of the two layers (urban from ESACCI map and RFresults)

bb<- extent(RF_results.r)
extent(RF_results.r)
extent(urbanmsk.r)
crs(RF_results.r)
crs(urbanmsk.r)

###reclassify the RF results
# 0.25 ==0
# 0.25 ==0.45 shrub mask
#> 0.45 (0.733) tree cover mask (max value 0.976)


#RESULTS give 2:shrubs mask and :the rest
####shrub mask
if(!file.exists(SNS_mask)){
  system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
                 paste0(resultdir, map_name),
                 #lc2017.aligned,
                 SNS_mask,
                 paste0("(A<0.26)*(A>0.46)         * 0+", ### no shrub
                        "(A==0.26)                 *0+",
                        "(A>0.26)*(A<0.46)+(A==0.46)        * 1" ### shrub 
                        
                        )
  ))
}


####tree cover mask 
if(!file.exists(FNF_mask)){
  system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
                 paste0(resultdir, map_name),
                 #lc2017.aligned,
                 FNF_mask,
                 paste0("(A<0.46)*(A==0.44)         * 0+", 
                        "(A==0.45)                 *1+",
                        "(A>0.45)        * 1" ### shrub 
                        
                 )
  ))
}

#SNS_mask.name.e <- writeRaster(raster(SNS_mask),filename = paste0(resultdir, SNS_mask.name), format = "GTiff", overwrite = TRUE)


#APPLY URBAN MASKS to the shrubland/tree cover masks

ee.sns_msk <- extent(raster(paste0(SNS_mask)))
ee.fnf_msk <- extent(raster(paste0(FNF_mask)))

urbanmsk <- "esa_buildup_msk2_zerobuildup.tif"
urbanmsk.path <- paste0(esa.downloaddir,"/", urbanmsk)

urbanmsk.aligned <- "esa_buildup_msk2_zerobuildup_aligned.tif"
urbanmsk.aligned.path <- paste0(esa.downloaddir,'/', urbanmsk.aligned)


####
#urbanmsk.r.crop <- crop(urbanmsk.r, bb)
urbanmsk.crop.name <- "urbanmsk_crop.tif"
#urbanmsk.r.crop.e <- writeRaster(urbanmsk.r.crop ,filename = paste0(resultdir, urbanmsk.crop.name), format = "GTiff", overwrite = TRUE)
#extent(urbanmsk.r.crop)
urbanmsk.r.crop.e.path <- paste0(resultdir, urbanmsk.crop.name)


#OK HARMONIZE RANDOM FOREST RESULTS AND THE URBAN MASK 

system(sprintf("gdalwarp -te %s %s %s %s -tr %s %s -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW -overwrite %s %s",
               extent(RF_results.r)[1],
               extent(RF_results.r)[3],
               extent(RF_results.r)[2],
               extent(RF_results.r)[4],
               res(raster(RF_results.r))[1],
               res(raster(RF_results.r))[2],
               paste0(esa.downloaddir,"/",urbanmsk),
               paste0(esa.downloaddir,'/',urbanmsk.crop.name)
))

#CHECK EXTENT ALL FILES
extent(RF_results.r)

extent(raster(paste0(esa.downloaddir,'/',urbanmsk.crop.name)))

#APPLY URBAN MASK OVER SNS MASK


FNF_mask_u <- paste0(resultdir, fnf_mask_u)
SNS_mask_u <- paste0(resultdir, sns_mask_u)


#apply urban mask to shrub mask
system(sprintf("gdal_calc.py -A %s -B %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               #paste0(resultdir, map_name),
               paste0(SNS_mask),
               paste0(esa.downloaddir,'/',urbanmsk.crop.name),
               SNS_mask_u,
               "\"(A*B)\""))


#apply urban mask to forest mask
system(sprintf("gdal_calc.py -A %s -B %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               #paste0(resultdir, map_name),
               paste0(FNF_mask),
               paste0(esa.downloaddir,'/',urbanmsk.crop.name),
               FNF_mask_u,
               "\"(A*B)\""))

extent(raster(FNF_mask_u))
extent(raster(SNS_mask_u))
#MERGE THE TWO MASKS

system(sprintf("gdal_calc.py -A %s -B %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               paste0(FNF_mask),
               paste0(SNS_mask),
               SNS_FNF_mask_u,
                "\"(A+B)\""))

#some pixels have value 2 >>> should be reclassified as 1
####################RECLASSIFY (FIRST OPTION)
#system(sprintf("gdal_calc.py -A %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
#               SNS_FNF_mask_u,
               
               
               ##paste0(bfast_dir,"/",bfast_hansenmask),
#               finalmask,
#               "\"(A/A)*1\""))


####################RECLASSIFY (SECOND OPTION)
system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               SNS_FNF_mask_u,
               finalmask,
               paste0("((A==1)+(A==2))*1")
))

