#MERGE SHRUB TREE COVER CHANGES
##################################
#tree cover change layer
loss_tree_degra05final_rcl_degrabelow_recl_final <- "loss_gain_ontreecover.tif"
r1 <- paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_recl_final) #1 loss #2 degradation # 5 gain
#shrub layer 

final2 <- "final.tif"

#set no data t0 zero (shrub layer)

system(sprintf("gdal_translate -of GTiff  -a_nodata 0 %s  %s",     #--NoDataValue=0   --type=Int16 
               paste0(finalch_dir, "BFAST_LOSS_SHRUBS_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl67.tif"), #loss and degra
               paste0(finalch_dir, "BFAST_LOSS_SHRUBS_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl67_nodata.tif")
))

loss_tree_degra05final_rcl_degrabelow_recl <- "BFAST_LOSS_SHRUBS_DEGRA05_RFfinal022_rcl_DEGRAbelowFINALRESULT_rcl67_nodata.tif"
r2 <-paste0(finalch_dir, loss_tree_degra05final_rcl_degrabelow_recl) #6 loss #7 degradation

system(sprintf("gdal_calc.py -A %s -B %s --type=Byte --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               r1, #loss value == 1 degra==2
               r2, #degradation value == 2 
               paste0(finalch_dir, final2),
               "\"B*(A==0)+A*(A>0)\""))
                       #)))







