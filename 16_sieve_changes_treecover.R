###########################################################################################################################
##########################################################################################################################
#use the clump() function in the raster package to identify clumps of raster cells. This function arbitrarily assigns an ID to these clumps.
resultdir <- paste0(rootdir, 'results/')
BFAST_fnfu_mask <- paste0(resultdir, "BFAST_fnfu.tif")
BFAST_fnfu_mask.r <- raster(paste0(resultdir, "BFAST_fnfu.tif"))
BFAST_fnfu_mask_clump <- paste0(resultdir, "BFAST_fnfu_clump.tif")
## Group raster cells into clumps based on the Queen's Case (8*)
######TREE COVER
if(!file.exists(fn <- BFAST_fnfu_mask_clump)) {
  BFAST_fnfu_maskclumps <- clump(BFAST_fnfu_mask.r, directions=8, filename=fn)
} else {
  BFAST_fnfu_maskclumps <- raster(fn)
}
#plot(BFAST_fnfu_maskclumps)
#When we inspect the frequency table with freq(), we can see the number of raster cells included in each of these clump IDs.
## Assign freqency table to a matrix
clumpFreq <- freq(BFAST_fnfu_maskclumps)
## Coerce freq table to data.frame
clumpFreq <- as.data.frame(clumpFreq)
##########UNTIL HERE
BFAST_fnfu_mask_r_sieve_clump <- paste0(resultdir, "BFAST_fnfu_mask_sie1pixel_clump.tif")
#use this output to create a loss mask :  > 0.5 ha  (about 6 pixels being conserative in the estimates) is 1 and the rest is Zero

##############################################################################
excludeID <- clumpFreq$value[which(clumpFreq$count<= 6)]
BFAST_fnfu_mask_r_sieveABOVE_05 <- BFAST_fnfu_mask.r
BFAST_fnfu_mask_r_sieveABOVE_05[BFAST_fnfu_maskclump %in% excludeID] <- NA
BFAST_fnfu_mask_r_sieveABOVE_05.e <- writeRaster(BFAST_fnfu_mask_r_sieveABOVE_05, filename = paste0(resultdir, "BFAST_fnfu_mask_sie_above05.tif"),format="GTiff", overwrite=TRUE)
#use this output to crate a degradation mask: < 0.5 ha is 1 and rest is Zero. This layer will then be used to take only pixels with value 5/4 
#trees
excludeID <- clumpFreq$value[which(clumpFreq$count>= 6)]
BFAST_fnfu_mask.r_sieveLESS_05 <- BFAST_fnfu_mask.r
BFAST_fnfu_mask.r_sieveLESS_05[BFAST_fnfu_maskclumps %in% excludeID] <- NA
BFAST_fnfu_mask.r_sieveLESS_05.e <- writeRaster(BFAST_fnfu_mask.r_sieveLESS_05, filename = paste0(resultdir, "BFAST_fnfu_mask sie_below05.tif"),format="GTiff", overwrite=TRUE)
###############################################################################################################################################################################################
################loss
###############################################################################################################################################################################################
#BFASTfnfusieveABOVE05lyr <- paste0(resultdir, "BFAST_fnfu_mask_sie_above05.tif")
BFASTfnfu_above05 <- paste0(resultdir, "BFAST_fnfu_mask_sie_above05.tif")
#loss in trees areas above 0.5 ha
map_name_bfast_loss_trees <- "BFAST_LOSS_TREES.tif"
map_name_bfast_loss_trees_derad05 <- "BFAST_LOSS_TREES_DEGRA05_3.tif"
#if(!file.exists(BFASTsnsu_above05by)){
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
               BFASTfnfu_above05,
               paste0(bfast_dir, map_name_bfast_loss_trees_derad05),
               paste0("(A==4.0)+(A==5.0)               *1+", ### LOSS 
                      "(A==3.0)                         *3+", #DEGRADATION  
                      "(A>5.0)                        *0+",
                      "(A<2.0)                        *0"
               )
))
#}

###########################################################
#CLEAN SINGLE PIXELS 
  bfast_loss_trees_degra05_sieve1pi <- paste0(bfast_dir, "BFAST_loss_trees_degra05_sieve1pi.tif")
  if(!file.exists(fn <- bfast_loss_trees_degra05_sieve1pi)) {
    BFAST_fnfu_maskclumps <- clump((raster(paste0(bfast_dir, map_name_bfast_loss_trees_derad05))), directions=8, filename=fn)
  } else {
    BFAST_fnfu_maskclumps <- raster(fn)
  }


  #When we inspect the frequency table with freq(), we can see the number of raster cells included in each of these clump IDs.
  ## Assign freqency table to a matrix
  clumpFreq <- freq(BFAST_fnfu_maskclumps)

  #head(BFAST_fnfu_maskclumps)
  #tail(BFAST_fnfu_maskclumps)
  #Use the count column of this frequency table to select clump IDs with only 1 pixel - these are the pixel "islands" that we want to remove from our original result.
  ## Coerce freq table to data.frame
  clumpFreq <- as.data.frame(clumpFreq)
  ## which rows of the data.frame are only represented by one cell?
  str(which(clumpFreq$count==1))
  ## which values do these correspond to?
  str(clumpFreq$value[which(clumpFreq$count==1)])
  ## Put these into a vector of clump ID's to be removed
  excludeID <- clumpFreq$value[which(clumpFreq$count==1)]
  ## Make a new forest mask to be sieved
  BFAST_fnfu_mask_r_sieve_f <- raster(paste0(bfast_dir, map_name_bfast_loss_trees_derad05))
  ## Assign NA to all clumps whose IDs are found in excludeID
  #library(sp)
  #library(raster)
  BFAST_fnfu_mask_r_sieve_f[BFAST_fnfu_maskclumps %in% excludeID] <- NA
  #BFAST_fnfu_mask.r_sieve.ename <- "BFAST_fnfu_mask sieclp.tif"
  BFAST_fnfu_mask_r_sieve_e <- writeRaster(BFAST_fnfu_mask_r_sieve_f, filename = bfast_loss_trees_degra05_sieve1pi,format="GTiff", overwrite=TRUE)
 
###############################################################################################################################################################################################
################degradation
###############################################################################################################################################################################################
BFASTfnfu_below05 <- paste0(resultdir, "BFAST_fnfu_masksie_below05.tif")
#smaller size (less than 0.5ha)
#values medium th (3) > degradation
#values high/very high  (4 and 5) > degradation 
map_name_bfast_trees_degra2 <- "BFAST_DEGRAD_TREES.tif" 
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
                      #paste0(bfast_dir, map_name_f),
                      #lc2017.aligned,
                      #BFASTsnsu_above05by,
                      BFASTfnfu_below05,
                      paste0(bfast_dir, map_name_bfast_trees_degra2),
                      paste0("(A>3)*(A<5)                        *2+", ### DEGRADATION
                             # "(A==3.0)                         *2+" #DEGRADATION  
                             "(A>5)                        *0+",
                             "(A<2)                        *0"
                      )
               ))
       
##########################################

#################
#compute stats of the results over pixels of loss
#bfast_RF <- paste0(bfast_dir, "bfast_changeRF.tif")
#bfast_RF.r <- raster(paste0(bfast_dir, "bfast_changeRF.tif"))
#a <- raster(paste0(bfast_dir, "bfast_changeRF.tif"))
#compute statistics using tree loss mask
#create a stack and extract the values of the first raster (BFAST RF layer) on the loss pixels layer
#compute statistics median and max value
#create a reclassify mask
#loss_msk <- raster(paste0(bfast_dir, map_name_bfast_loss_trees))
#b <- raster(paste0(bfast_dir, map_name_bfast_loss_trees))
#summary(bfast_RF.r)
#s <- stack(loss_msk,bfast_RF.r)
#s
#v <- as.data.frame(s)
#tail(v,150)
#v[v[,2] == 1, 1]
#selectedvaluesovermsk <- data.frame(a[b==1])              
#stat<- summary(selectedvaluesovermsk)
#results 
#Min.   :0.0000  
#1st Qu.:0.0333  
#Median :0.0889  
#Mean   :0.1264  
#3rd Qu.:0.1811  
#Max.   :0.8578  
#NA's   :730     
#reclassification based on the median value (0.088)
#bfast_RF_recl0088 <- "bfast_changeRFrecl0088.tif"
#system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
#               #paste0(bfast_dir, map_name_f),
#               #lc2017.aligned,
#               #BFASTsnsu_above05by,
#               bfast_RF,
#               paste0(bfast_dir, bfast_RF_recl0088),
#               paste0("(A>0.088)                 *0+", ### LOSS from RF bfast 
#                      "(A<0.088)                 *1"
#               )
#))
#1st Qu.:0.0333  
#bfast_RF_recl0033 <- "bfast_changeRFrecl0033.tif"
#system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
#               #paste0(bfast_dir, map_name_f),
#               #lc2017.aligned,
#               #BFASTsnsu_above05by,
#               bfast_RF,
#               paste0(bfast_dir, bfast_RF_recl0033),
#               paste0("(A>0.033)                 *0+", ### LOSS from RF bfast 
#                      "(A<0.033)                 *1"
#               )
#))
#bfast_RF_recl0088.e <- writeRaster(raster(paste0(bfast_dir, bfast_RF_recl0088)), filename = paste0(bfast_dir, "bfast_RF_recl0088.tif"),format="GTiff", overwrite=TRUE)
#bfast_RF_recl0033.e <- writeRaster(raster(paste0(bfast_dir, bfast_RF_recl0033)), filename = paste0(bfast_dir, "bfast_RF_recl0033.tif"),format="GTiff", overwrite=TRUE)
#first comparison of the above results
#Careful validation of the changes detected using the range of values 0.001 up to 0.004
#according to the visual assessment with VHRI, the threshold is 0.0035 (from 0.001) >those pixels will be considered LOSS and integrated in the original layer
#stat <- stats(bfast_RF.r,loss_msk, fun= max, na.rm=TRUE)
#reclassification of the RF bfast results

#code from terminal
#1 set zero value to no data gdal_translate -of GTIFF -scale -a_nodata 0 bfast_changeRF.tif bfast_changeRF_nodata.tif
#2 reclassification gdal_calc.py -A bfast_changeRF_nodata.tif  --outfile=bfast_changeRF_LOSSversionefinale7.tif --co COMPRESS=LZW --type=Float64  --calc="1*logical_or(A>=0.001111111, A<=0.0035)" --NoDataValue=0 
#
#bfast_RF_recl00035 <- "bfast_changeRFrecl00035.tif"
bfast_changeRFr <- raster(paste0(bfast_dir, "bfast_changeRF.tif"))
#bfast_changeRF_nodatarecl <- paste0(bfast_dir, "bfast_changeRF_nodata.tif")
bfast_changeRF_nodatarecl_f <- "bfast_changeRF_nodata_recl.tif"

#noworking 
#if(!file.exists(paste0(bfast_dir, bfast_changeRF_nodatarecl_f))){
#  system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --outfile=%s --type=Float64 --calc=\"%s\"--overwrite --NoDataValue=0",
#                 bfast_changeRF_nodatarecl,
#                 #lc2017.aligned,
#                 paste0(bfast_dir, bfast_changeRF_nodatarecl_f),
#                 paste0("(A<0.001111111)*(A>0.0035)         * 0+",         ### no shrub
#                        "(A>0.001111111))*(A<0.0035)+(A==0.0035)+(A==0.001111111)       * 1" ###
#                        
#                 )
#  ))
#}
#reclassification with reclassify
threshold <- 0.0035
mforest <- c(0.001111111, threshold, 1, threshold, 0.9911111, 0) #the values to be stored in the matrix. The first two columns 
Frclmat <- matrix(mforest, ncol=3, byrow=TRUE) #construct the matrix
bfast_changeRF_recl <- reclassify(bfast_changeRFr, Frclmat, paste0(bfast_dir, filename='bfast_changeRF_recl.tif'))
bfast_RF_recl00035 <- bfast_changeRF_recl #renaming old version

bfast_RF_recl00035 <- paste0(bfast_dir, "bfast_changeRF_recl.tif")
bfast_RF_recl00035name <- "bfast_changeRF_recl.tif"
#merge the two layers #INCLUDE THE BFAST RF RESULT to the loss bfast layer
loss_tree_degra05final <- "BFAST_LOSS_TREES_DEGRA05_RFfinal.tif"
#using degradation = 3

system(sprintf("gdal_calc.py -A %s -B %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",   #type=Int16
               paste0(bfast_dir, map_name_bfast_loss_trees_derad05),
               paste0(bfast_dir, bfast_RF_recl00035name),
               paste0(bfast_dir, loss_tree_degra05final),
               "\"(A+B)\""))


#results 1+1= 2 loss 1+0=1 loss 3+1 =4 recl degra (below) 3+0=3 degradation


loss_tree_degra05final2 <- "BFAST_LOSS_TREES_DEGRA05_RFfinal022.tif"
#if(!file.exists(BFASTsnsu_above05by)){
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
               #paste0(bfast_dir, map_name_f),
               #lc2017.aligned,
               #BFASTsnsu_above05by,
               paste0(bfast_dir, loss_tree_degra05final),
               paste0(bfast_dir, loss_tree_degra05final2),
               paste0("(A==3)              *2+", #DEGRADATION
                       "(A==4)*2+",
                       "(A==1)*1+",
                      "(A==2)               *1"    #LOSS 
                    #  "(A>5.0)                        *0+",
               )
))



loss_tree_degra05final_rcl <- "BFAST_LOSS_TREES_DEGRA05_RFfinal_rcl.tif"

#########################################
#final results
#integration with the degradation less than 0.5 ha

loss_tree_degra05final_rcl_degrabelow <- "BFAST_LOSS_TREES_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT.tif"
system(sprintf("gdal_calc.py -A %s -B %s --type=Int16 --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               paste0(bfast_dir, loss_tree_degra05final2), #loss value == 1 degra==2
               paste0(bfast_dir, map_name_bfast_trees_degra2), #degradation value == 2 
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow),
               "\"(A+B)\""))



#reclassify values ==3 as 1 (loss)
loss_tree_degra05final_rcl_degrabelow_recl <- "BFAST_LOSS_TREES_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl.tif"
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
               #paste0(bfast_dir, map_name_f),
               #lc2017.aligned,
               #BFASTsnsu_above05by,
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow),
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_recl),
               paste0("(A==1)                          *1+",
                      "(A==3)                          *1+",  ### LOSS from RF bfast 
                      "(A==2)                                 *2"   ### DEGRADATION
               )
))

#reclassification GAIN


#RESULTS give 2:shrubs mask and :the rest
####shrub mask
#if(!file.exists()){
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
                 paste0(bfast_dir, "bfast_changeRF.tif"),
                 #lc2017.aligned,
                 paste0(finalch_dir, "reclass_gain.tif"),
                 paste0("(A>0.770000)*(A<0.9911111)         *5+", ### gain
                        "(A==0.770000)                      *5+",
                        "(A>0)*(A<0.770000)                 *0" ### no gain 
                        
                 )
  ))
#}

#integration gain in loss layer

#set nodata value to zero
#gdal_translate -of GTiff -a_nodata 0 input.tif output.tif

system(sprintf("gdal_translate -of GTiff  -a_nodata 0 %s  %s",     #--NoDataValue=0   --type=Int16 
               paste0(finalch_dir, "BFAST_LOSS_TREES_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl.tif"), #loss and degra
               paste0(finalch_dir, "BFAST_LOSS_TREES_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl_nodata.tif")
               #paste0(finalch_dir, loss_gain),
               #"\"(A+B)\""))
))


loss_gain <- "BFAST_LOSS_TREES_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_GAIN6.tif"
system(sprintf("gdal_calc.py -A %s -B %s  --NoDataValue=0 --type=Byte --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",     #--NoDataValue=0   --type=Int16 
               paste0(finalch_dir, "BFAST_LOSS_TREES_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl_nodata.tif"), #loss and degra
               paste0(finalch_dir, filename='reclass_gain.tif'), #gain 
               paste0(finalch_dir, loss_gain),
               "\"(B+A)\""))


#final reclassification 


#reclassify values ==3 as 1 (loss)
loss_tree_degra05final_rcl_degrabelow_recl_final <- "loss_gain_ontreecover.tif"
system(sprintf("gdal_calc.py -A %s  --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
               paste0(finalch_dir, loss_gain),
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_recl_final),
               paste0("(A==1)                          *1+", #loss
                      "(A==2)                          *2+", #degradation  
                      "(A==4)                          *5+", #gain 
                      "(A==6)                          *1+", #loss
                      "(A==7)                          *2+" #degradation  
               )
))


#reclassify values ==3 as 1 (loss)
loss_tree_degra05final_rcl_degrabelow_recl_final <- "loss_gain_ontreecover.tif"
system(sprintf("gdal_calc.py -A %s  --NoDataValue=255 --co COMPRESS=LZW --type=Byte --outfile=%s --calc=\"%s\"",
               paste0(finalch_dir, loss_gain),
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_recl_final),
               paste0("(A==1)                          *1+", #loss
                      "(A==2)                           *2+", #degradation  
                      "(A==4)                          *5+", #gain 
                    "(A==6)                          *1+", #loss
                     "(A==7)                          *2" #degradation  

               )
))




#############################################################################

#CLEAN SINGLE PIXELS 

mmu <- 1
loss_tree_degra05final_rcl_degrabelow_recl_sieved <- "BFAST_LOSS_TREES_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl_sieved.tif"
system(sprintf("gdal_sieve.py -st %s %s %s",
               1,
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_recl),
               paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_recl_sieved)
))


#ori system(sprintf("gdal_sieve.py -st %s -8 %s %s",
#mmu <- mmu *2

#remove single pixels 
#system(sprintf("gdal_sieve.py -st %s -4 %s %s",
#               mmu,
#               paste0(finalch_dir,"CHANGES_TREES_UTM.tif"),
#               paste0(finalch_dir,"/","CHANGES_TREES_UTM_S.tif")
#))

## Sieve results with a 8 connected component rule: 
#mmu <- 1
#mmu <- mmu *2
system(sprintf("gdal_sieve.py -st %s %s %s",
               mmu,
               paste0(finalch_dir,"/","BFAST_LOSS_TREES_DEGRA05_RFfinal_rcl_DEGRAbelowFINALRESULT_rcl_F.tif"),
               paste0(finalch_dir,"/","BFAST_LOSS_TREES_DEGRA05_RFfinal_rcl_DEGRAbelowFINALRESULT_rcl_F2.tif")
))


system(sprintf("gdal_sieve.py -st %s %s %s",
               2,
               paste0(finalch_dir,"/","BFAST_LOSS_TREES_DEGRA05_RFfinal_rcl_DEGRAbelowFINALRESULT_rcl_F.tif"),
               paste0(finalch_dir,"/","BFAST_LOSS_TREES_DEGRA05_RFfinal_rcl_DEGRAbelowFINALRESULT_rcl_FINAL2.tif")
))


#mmu <- mmu *2
#system(sprintf("gdal_sieve.py -st %s -8 %s %s",
#               mmu,
#               paste0(finalch_dir,"/","CHANGES_TREES_UTM_S2.tif"),
#               paste0(finalch_dir,"/","CHANGES_TREES_UTM_S3.tif")
#))

#system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
#               paste0(outdir,"/","tmp_sieve_km_se.tif"),
#               all_sg_km))
#system(sprintf(paste0("rm ",outdir,"/","tmp_*.tif")))


sr <- "+proj=utm +zone=31 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"    #WGS_1984_UTM_Zone_31N  EPSG:32631
#sr <- "+proj=utm +zone=15 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" 

loss_tree_degra05final_rcl_degrabelow_rcl_clump_name <- "loss_tree_degra05final_rcl_degrabelow_rcl_clumped.tif"
loss_tree_degra05final_rcl_degrabelow_rcl_clumped <- (paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_rcl_clump_name))

if(!file.exists(fn <- loss_tree_degra05final_rcl_degrabelow_rcl_clumped)) {
  BFAST_lossclumps <- clump(raster(paste0(finalch_dir, "BFAST_LOSS_TREES_DEGRA05_RFfinal_rcl_DEGRAbelowFINALRESULT_rcl_F.tif")), directions=8, filename=fn)
} else {
  BFAST_lossclumps <- raster(fn)
}

#plot(BFAST_fnfu_maskclumps)
#When we inspect the frequency table with freq(), we can see the number of raster cells included in each of these clump IDs.
## Assign freqency table to a matrix
clumpFreq <- freq(BFAST_lossclumps)
#head(BFAST_fnfu_maskclumps)
#tail(BFAST_fnfu_maskclumps)
#Use the count column of this frequency table to select clump IDs with only 1 pixel - these are the pixel "islands" that we want to remove from our original result.
## Coerce freq table to data.frame
clumpFreq <- as.data.frame(clumpFreq)
str(which(clumpFreq$count==1))
str(clumpFreq$value[which(clumpFreq$count==1)])
## Put these into a vector of clump ID's to be removed
excludeID <- clumpFreq$value[which(clumpFreq$count==1)]
## Make a new forest mask to be sieved
BFAST_lossclumps2 <- raster(paste0(finalch_dir, "BFAST_LOSS_TREES_DEGRA05_RFfinal_rcl_DEGRAbelowFINALRESULT_rcl_F.tif"))
## Assign NA to all clumps whose IDs are found in excludeID
#library(sp)
#library(raster)
BFAST_lossclumps2[BFAST_lossclumps2 %in% excludeID] <- NA
#BFAST_fnfu_mask.r_sieve.ename <- "BFAST_fnfu_mask sieclp.tif"
s<- paste0(finalch_dir, "final_change_trees.tif")

BFAST_lossclumps2_e <- writeRaster(BFAST_lossclumps2, filename = s,format="GTiff", overwrite=TRUE)



