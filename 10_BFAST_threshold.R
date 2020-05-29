###############################################
## Identifying patterns in BFAST output/results
###############################################
## load parameters

#source('~/3_niger_beta/nig_seg/scripts/1_parameters1.R')
#source('~/3_niger_beta/nig_seg/scripts/2_parameters2.R')


# input files
bfastout <-paste0(bfast_dir,'bfast_mosaic_raw_final_final.tif')
#masks
FNF_mask_u <- paste0(resultdir, fnf_mask_u)
SNS_mask_u <- paste0(resultdir, sns_mask_u)

# output file names
result <- paste0(thres_dir,'bfast_mosaic_raw_final_with_TSmask.tif')
#forestmask <- paste0(lc_dir,'veg_msk_v2_01.tif')
#forestmask.albertine <- paste0(lc_dir,'THF_mask2017_albertine.tif')

## parameters
# factor to divide standard deviation
divide_sd <- 4


#check extents
extent(raster(finalmask))
extent(raster(bfastout))
#no need to clip bfast since same extent
# clip bfast output to mask
#system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -tr %s %s -co COMPRESS=LZW %s %s",
#               extent(raster(bfastout))@xmin,
#               extent(raster(bfastout))@ymax,
#               extent(raster(bfastout))@xmax,
#               extent(raster(bfastout))@ymin,
#               res(raster(bfastout))[1],
#               res(raster(bfastout))[2],
               
#               paste0(thres_dir,"tmp_proj.tif"),
#               forestmask.albertine
#))

# apply mask
system(sprintf("gdal_calc.py -A %s -B %s --B_band=2 --co COMPRESS=LZW --overwrite --outfile=%s --calc=\"%s\"",
               finalmask,
               bfastout,
               result,
               paste0("A*B")
))



## Post-processing ####
# calculate the mean, standard deviation, minimum and maximum of the magnitude band
# reclass the image into 10 classes
# 0 = no data
# 1 = no change (mean +/- 1 standard deviation)
# 2 = negative small magnitude change      (mean - 2 standard deviations)
# 3 = negative medium magnitude change     (mean - 3 standard deviations)
# 4 = negative large magnitude change      (mean - 4 standard deviations)
# 5 = negative very large magnitude change (mean - 4+ standard deviations)
# 6 = postive small magnitude change       (mean + 2 standard deviations)
# 7 = postive medium magnitude change      (mean + 3 standard deviations)
# 8 = postive large magnitude change       (mean + 4 standard deviations)
# 9 = postive very large magnitude change  (mean + 4+ standard deviations)
#################### SET NODATA TO NONE IN THE TIME SERIES STACK

tryCatch({
  
  outputfile   <- paste0(thres_dir,  substr(basename(bfastout), 1, nchar(basename(bfastout))-4),'_threshold.tif')
  # r <- raster(result)
  # NAvalue(r) <- 0
  means_b2 <- cellStats( raster(result) , na.rm=TRUE, "mean") 
  mins_b2 <- cellStats( raster(result) , na.rm=TRUE,"min")
  maxs_b2 <- cellStats(  raster(result) ,na.rm=TRUE, "max")
  stdevs_b2 <- cellStats(  raster(result) ,na.rm=TRUE, "sd")/divide_sd
  system(sprintf("gdal_calc.py -A %s --co=COMPRESS=LZW --type=Byte --outfile=%s --calc='%s'
                 ",
                 result,
                 paste0(thres_dir,"tmp_threshold.tif"),
                 paste0('(A<=',(maxs_b2),")*",
                        '(A>',(means_b2+(stdevs_b2*4)),")*9+",
                        '(A<=',(means_b2+(stdevs_b2*4)),")*",
                        '(A>',(means_b2+(stdevs_b2*3)),")*8+",
                        '(A<=',(means_b2+(stdevs_b2*3)),")*",
                        '(A>', (means_b2+(stdevs_b2*2)),")*7+",
                        '(A<=',(means_b2+(stdevs_b2*2)),")*",
                        '(A>', (means_b2+(stdevs_b2)),")*6+",
                        '(A<=',(means_b2+(stdevs_b2)),")*",
                        '(A>', (means_b2-(stdevs_b2)),")*1+",
                        '(A>=',(mins_b2),")*",
                        '(A<', (means_b2-(stdevs_b2*4)),")*5+",
                        '(A>=',(means_b2-(stdevs_b2*4)),")*",
                        '(A<', (means_b2-(stdevs_b2*3)),")*4+",
                        '(A>=',(means_b2-(stdevs_b2*3)),")*",
                        '(A<', (means_b2-(stdevs_b2*2)),")*3+",
                        '(A>=',(means_b2-(stdevs_b2*2)),")*",
                        '(A<', (means_b2-(stdevs_b2)),")*2")
                 
  ))
  
}, error=function(e){})

####################  CREATE A PSEUDO COLOR TABLE


####################  CREATE A PSEUDO COLOR TABLE
cols <- col2rgb(c("white","beige","yellow","orange","red","darkred","palegreen","green2","forestgreen",'darkgreen'))


pct <- data.frame(cbind(c(0:9),
                        cols[1,],
                        cols[2,],
                        cols[3,]
))


write.table(pct,paste0(thres_dir,"color_table.txt"),row.names = F,col.names = F,quote = F)



################################################################################
## Add pseudo color table to result
system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(thres_dir,"color_table.txt"),
               paste0(thres_dir,"tmp_threshold.tif"),
               paste0(thres_dir,"/","tmp_colortable.tif")
))
## Compress final result
system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(thres_dir,"/","tmp_colortable.tif"),
               outputfile
))
# gdalinfo(outputfile,hist = T)
## Clean all
system(sprintf(paste0("rm ",thres_dir,"/","tmp*.tif")))


#
#apply the mask > tree cover masks
#apply the maks > shrub cover mask



#mask with urban applied
FNF_mask_u <- paste0(resultdir, fnf_mask_u)
FNF_mask_u.r <- raster(paste0(resultdir, fnf_mask_u))
SNS_mask_u <- paste0(resultdir, sns_mask_u)
#to
outputfile   <- paste0(thres_dir,  substr(basename(bfastout), 1, nchar(basename(bfastout))-4),'_threshold.tif')


BFAST_fnfu_mask <- paste0(resultdir, "BFAST_fnfu.tif")
BFAST_snsu_mask <- paste0(resultdir, "BFAST_snsu.tif")

#FNFu mask over bfast
system(sprintf("gdal_calc.py -A %s -B %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               #paste0(resultdir, map_name),
               paste0(FNF_mask_u),
               outputfile,
               #paste0(bfast_dir,"/",bfast_hansenmask),
               BFAST_fnfu_mask,
               "\"(A*B)\""))

#SNSu mask over bfast
system(sprintf("gdal_calc.py -A %s -B %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               #paste0(resultdir, map_name),
               paste0(SNS_mask_u),
               outputfile,
               #paste0(bfast_dir,"/",bfast_hansenmask),
               BFAST_snsu_mask,
               "\"(A*B)\""))




