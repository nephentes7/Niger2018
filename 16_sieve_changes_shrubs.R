#Sieving 
#use the clump() function in the raster package to identify clumps of raster cells. 
#This function arbitrarily assigns an ID to these clumps.

resultdir <- paste0(rootdir, 'results/')
BFAST_snsu_mask <- paste0(resultdir, "BFAST_snsu.tif")
BFAST_snsu_mask.r <- raster(paste0(resultdir, "BFAST_snsu.tif"))
#plot(BFAST_snsu_mask.r)
BFAST_snsu_mask_clump <- paste0(resultdir, "BFAST_snsu_clump.tif")
## Group raster cells into clumps based on the Queen's Case (8*)

######SHRUB COVER
if(!file.exists(fns <- BFAST_snsu_mask_clump)) {
  BFAST_snsu_maskclumps <- clump(BFAST_snsu_mask.r, directions=8, filename=fns)
} else {
  BFAST_snsu_maskclumps <- raster(fns)
}
clumpFreqs <- freq(BFAST_snsu_maskclumps)
clumpFreqs <- as.data.frame(clumpFreqs)
BFAST_snsu_mask_r_sieve_clump <- paste0(resultdir, "BFAST_snsu_mask sie1pixel_clump.tif")

excludeIDs <- clumpFreqs$value[which(clumpFreqs$count<= 6)]
BFAST_snsu_mask_r_sieveABOVE_05s <- BFAST_snsu_mask.r
BFAST_snsu_mask_r_sieveABOVE_05s[BFAST_snsu_maskclumps %in% excludeIDs] <- NA
BFAST_snsu_mask_r_sieveABOVE_05.e <- writeRaster(BFAST_snsu_mask_r_sieveABOVE_05s, filename = paste0(resultdir, "BFAST_snsu_mask_sie_above05.tif"),format="GTiff", overwrite=TRUE)
#use this output to crate a degradation mask: < 0.5 ha is 1 and rest is Zero. This layer will then be used to take only pixels with value 5/4 
#shrubs
excludeIDs <- clumpFreqs$value[which(clumpFreqs$count>= 6)]
BFAST_snsu_mask.r_sieveLESS_05 <- BFAST_snsu_mask.r
BFAST_snsu_mask.r_sieveLESS_05[BFAST_snsu_maskclumps %in% excludeIDs] <- NA
BFAST_snsu_mask.r_sieveLESS_05.e <- writeRaster(BFAST_snsu_mask.r_sieveLESS_05, filename = paste0(resultdir, "BFAST_snsu_mask_sieclp_below05.tif"),format="GTiff", overwrite=TRUE)

BFASTsnsu_above05 <- paste0(resultdir, "BFAST_snsu_mask_sie_above05.tif")
#BFASTsnsu_above05_r <- raster(paste0(resultdir, "BFAST_snsu_mask_sie_above05.tif"))
#convert floating to byte
#system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
#               BFASTsnsu_above05,
#               #all_sg_km
#               paste0(resultdir,"/","BFAST_snsu_mask_sie_above05_by.tif")))

#BFASTsnsu_above05by <- paste0(resultdir, "BFAST_snsu_mask_sie_above05_by.tif")
#BFASTsnsu_above05byr <- raster(paste0(resultdir, "BFAST_snsu_mask_sie_above05_by.tif"))

#loss in shrubs above 0.5 ha
#Reclassify the result of > 0.5 ha layer: values 4 and 5 th are considered as LOSS
map_name_bfast_loss_shrub_degra05 <- "BFAST_LOSS_SHRUBS_DEGRAD05.tif"
#if(!file.exists(BFASTsnsu_above05by)){
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
               #paste0(bfast_dir, map_name_f),
               #lc2017.aligned,
               #BFASTsnsu_above05by,
               BFASTsnsu_above05,
               paste0(bfast_dir, map_name_bfast_loss_shrub_degra05),
               paste0("(A==4.0)+(A==5.0)               *1+", ### LOSS 
                      "(A==3.0)                         *2+", #DEGRADATION  
                      "(A>5.0)                          *0+",
                      "(A<2.0)                          *0"
               )
))
#}

#CLEAN SINGLE PIXELS 
bfast_loss_shrub_degra05_sieve1pi <- paste0(bfast_dir, "BFAST_loss_shrub_degra05_sieve1pi.tif")  

######SHRUB COVER
if(!file.exists(fns <- bfast_loss_shrub_degra05_sieve1pi)) {
  BFAST_snsu_maskclumps <- clump((raster(paste0(bfast_dir, map_name_bfast_loss_shrub_degra05))), directions=8, filename=fns)
} else {
  BFAST_snsu_maskclumps <- raster(fns)
}

clumpFreqs <- freq(BFAST_snsu_maskclumps)
clumpFreqs <- as.data.frame(clumpFreqs)
str(which(clumpFreqs$count==1))
str(clumpFreqs$value[which(clumpFreqs$count==1)])
excludeIDs <- clumpFreqs$value[which(clumpFreqs$count==1)]
BFAST_snsu_mask_r_sieve_f <- raster(paste0(bfast_dir, map_name_bfast_loss_shrub_degra05))
BFAST_snsu_mask_r_sieve_f[BFAST_snsu_maskclumps %in% excludeIDs] <- NA
BFAST_snsu_mask_r_sieve_e <- writeRaster(BFAST_snsu_mask_r_sieve_f, filename = bfast_loss_shrub_degra05_sieve1pi,format="GTiff", overwrite=TRUE)

###################################################
#DEGRADATION
BFASTsnsu_below05 <- paste0(resultdir, "BFAST_snsu_mask_sie_below05.tif")

###########################################################
#DEGRADATION on shrubland
map_name_bfast_shrubs_degra2 <- "BFAST_DEGRAD_SHRUBS2.tif"  
#if(!file.exists(BFASTsnsu_above05by)){
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
               #paste0(bfast_dir, map_name_f),
               #lc2017.aligned,
               #BFASTsnsu_above05by,
               BFASTsnsu_below05,
               paste0(bfast_dir, map_name_bfast_shrubs_degra2),
               paste0("(A>3)*(A<5)                        *2+", ### DEGRADATION 
                      # "(A==3.0)                         *2+" #DEGRADATION  
                      "(A>5)                        *0+",
                      "(A<2)                        *0"
               )
))

#########################################
#final results: integration loss and degradation 
loss_tree_degra05final_rcl_degrabelow <- "BFAST_LOSS_SHRUBS_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT.tif"
system(sprintf("gdal_calc.py -A %s -B %s --type=Byte --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               paste0(bfast_dir, "BFAST_loss_shrub_degra05_sieve1pi.tif"), #loss value == 1 degra==2
               paste0(bfast_dir, map_name_bfast_shrubs_degra2), #degradation value == 2 
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow),
               "\"(A+B)\""))



#reclassify 
loss_tree_degra05final_rcl_degrabelow_recl <- "BFAST_LOSS_SHRUBS_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl67.tif"
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
               #paste0(bfast_dir, map_name_f),
               #lc2017.aligned,
               #BFASTsnsu_above05by,
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow),
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_recl),
               paste0("(A==1)                               *6+",   #loss on shrubs
                      "(A==-32768)                          *0+",  ### 
                      "(A==2)                                *7"   ### DEGRADATION on shrubs
               )
))






#integration with the degradation less than 0.5 ha

loss_shrubs_degra05final_rcl_degrabelow <- "BFAST_LOSS_SHRUBS_DEGRA05_DEGRAbelowFINALRESULT.tif"

system(sprintf("gdal_calc.py -A %s -B %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               bfast_loss_shrub_degra05_sieve1pi, #loss value == 1 
               paste0(bfast_dir, map_name_bfast_shrubs_degra2), #degradation value == 2 
               paste0(finalch_dir, loss_shrubs_degra05final_rcl_degrabelow),
               "\"(A+B)\""))

#remove single pixels
mmu = 1
system(sprintf("gdal_sieve.py -st %s %s %s",
               mmu,
               paste0(finalch_dir,"/","BFAST_LOSS_SHRUBS_DEGRA05_DEGRAbelowFINALRESULT.tif"),
               paste0(finalch_dir,"/","BFAST_LOSS_SHRUBS_DEGRA05_DEGRAbelowFINALRESULT_1pi.tif")
))


