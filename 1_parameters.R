####################################################################################
####### setting parameters            
####### Update:  2018/03/04  
####################################################################################
# make sure all the parameters are set
library(raster)
library(rgdal)
library(igraph)
library(rgeos)
library(sp)
library(rgeos)
library(dplyr)
library(stringr) # for working with strings (pattern matching)
library(randomForest)
library(RCurl)
library(bitops)
library(hddtools)
library(XML)
library(zoo)
library(dismo)
library(maptools)


SEPALhome <- '~'
setwd(SEPALhome)
SEPALhome <- getwd()

####################################################################################
#######          SET PARAMETERS FOR THE IMAGES OF INTEREST
####################################################################################
####### SET WHERE YOUR SCRIPTS ARE CLONED

#clonedir  <- paste0("~/nig_seg/")
clonedir  <- paste0(SEPALhome,'/',"3_niger_beta/nig_seg/")
setwd(clonedir)


####### DATA WILL BE CREATED AND STORED HERE
dir.create("nig/data")
setwd("nig/data")
getwd()

#######DATA FOR MOSAICS (SENTINEL/LANDSAT)
dir.create("nig/data/mosaics")

#training data folder
#dir.create("nig/data/training_data/")
root <- paste0("/home/daietti/3_niger_beta/nig_seg/")
rootdir <- paste0(getwd(),"/")
mosaicdir <- paste0(rootdir, 'mosaics/')
change_layers_dir <- paste0(rootdir, 'mosaics/change_stack/')
resultdir <- paste0(rootdir, 'results/')
mapdir <- paste0(resultdir , 'maps/')
shpdir <- paste0(rootdir, 'shp/')
scriptdir <- paste0(root, 'scripts/')
scriptdirmisc <- paste0(root, 'scripts/scripts_misc')

####### SET WHERE YOUR IMAGE DIRECTORY IS
#dir.create("raw_img/")
rawimgdir   <- paste0(rootdir,"raw_img")

#separate mosaics for forest mask (creating the forest mask) and for the land cover map
yearforestmask <- 2013 #year time1
year_time2 <-2018
rawimgdir_fomask_wet <- paste0(rawimgdir,'/', 'ng_ls_20134oct_w_aoifinal/')
rawimgdir_fomask_wet <- paste0(rawimgdir,'/', 'ng_ls_20131jan_d_aoifinal/')
rawimgdir_fomask_wet2018 <- paste0(rawimgdir,'/','ng_ls_20189_15agow_aoif/')
rawimgdir_fomask_wet2018 <- paste0(rawimgdir,'/','ng_ls_20131jan_d_aoifinal/')

#names of the mosaics
mosaic_name
#mosaic_name_fomask_wet <- "mosaic_name_fomask_wet.tif"
mosaic_name_fomask_wet    <- paste0('fomask_', yearforestmask, '_wet.tif')
mosaic_name_fomask_dry <- paste0('fomask_', yearforestmask, '_dry.tif')
#mosaic_name_lc_wet <- "mosaic_name_fomask_dry.tif"
#mosaic_name_lc_dry <-"mosaic_name_fomask_dry.tif"
#mosaic_name_fomask_wet2018    <- paste0('fomask_', year_time2, '_wet.tif')
#mosaic_name_fomask_dry2018 <- paste0('fomask_', year_time2, '_dry.tif')

mosaic_name_fomask_wet2018    <- "ng_ls_20189_15agow_aoif.vrt"
mosaic_name_fomask_dry2018 <- "ng_ls_20181jand_aoif.vrt"

####### SET WHERE YOUR TRAINING DIRECTORY IS
dir.create("training/")
training_dir_local <- paste0(rootdir,'training/23082019/')
#training_dir_local <- paste0(rootdir,'/', 'training')
training_dir_local
## TRAINING DATA
#upload the shapefile where you have stored your training data
#csv file
#t1_train <- paste0(training_dir_local,'/',"training_points_7_4.csv")
#shape file
#original
t1_train <- paste0(training_dir_local,'/',"ts_data_f.shp")
#attempt to add more training poly under urban+trees areas 
t1_train <- paste0(training_dir_local,'/',"ts_data_f_1cl_urbncorr.shp")
aoi.shp <- paste0(shpdir,'/',"ZONEGENERAL2_WGS.shp")


## INPUT IMAGE FOR CLASSIFICATION
#wet
wetdir <- paste0(rawimgdir,'/','ng_ls_20134oct_w_aoifinal')
drydir <- paste0(rawimgdir,'/','ng_ls_20131jan_d_aoifinal')
wetdir2018 <- paste0(rawimgdir,'/','ng_ls_20189_15agow_aoif/')
drydir2018 <- paste0(rawimgdir,'/','ng_ls_20181jand_aoif/')
#wet
t1_file_wet  <- paste0(wetdir,'/',"ng_ls_20134oct_w_aoifinal.vrt")
t1_file_wet2018  <- paste0(wetdir,'/',"ng_ls_20189_15agow_aoif.vrt")
#dry
t1_file_dry  <- paste0(drydir,'/',"ng_ls_20131jan_d_aoifinal.vrt")
# t1_file  <- paste0(rootdir,'/',"lsat_s1_alos_srtm.vrt")
t1_file_dry2018  <- paste0(drydir,'/',"ng_ls_20181jand_aoif.vrt")

#IMAD directory
imad_dir <- paste0(rootdir,'/',"mosaics/IMAD/")

####### other directories
#data download directories
esa.downloaddir <- paste0(rootdir, 'download/ESA_2016/')


#names 
map_name <- "2013_mask_v2final19062019.tif"
#names of the masks
#savanna arborees ("tree cover"> 10%) forest-non forest mask
fnf_mask <- "2013_fnf_MSK.tif"
fnf_mask_u <- "2013_fnf_MSK_u.tif"
#savanna arbustive ("shrub cover"> 10%) shrub-non shrub mask
sns_mask <- "2013_sns_MSK.tif"
sns_mask_u <- "2013_sns_MSK_u.tif"
sns_fnf_mask <- "2013_sns_fnf_MSK_u.tif"
sns_fnf_mask_f <- "2013_sns_fnf_MSK_u_final.tif"

fnf_sns_mask <- "2013_fnf_sns_MSK.tif"
FNF_SNS_mask <- paste0(resultdir, fnf_sns_mask)

FNF_mask <- paste0(resultdir, fnf_mask)
SNS_mask <- paste0(resultdir, sns_mask)
SNS_mask2 <- paste0(resultdir, sns_mask2)

fnf_sns_mask <- "2013_fnf_sns_MSK.tif"

#with urban applied
FNF_mask_u <- paste0(resultdir, fnf_mask_u)
SNS_mask_u <- paste0(resultdir, sns_mask_u)
SNS_FNF_mask_u <- paste0(resultdir, sns_fnf_mask)
SNS_FNF_mask_u.f <- paste0(resultdir, sns_fnf_mask_f)

mask_name1 <- "finalmask1.tif"
mask_name <- "finalmask.tif"
finalmask <- paste0(resultdir, mask_name)
finalmask1 <- paste0(resultdir, mask_name1)

#urban mask
urbanmsk <- "esa_buildup_msk2_zerobuildup.tif"
urbanmsk.path <- paste0(esa.downloaddir,"/", urbanmsk)

urbanmsk.aligned <- "esa_buildup_msk2_zerobuildup_aligned.tif"
urbanmsk.aligned.path <- paste0(esa.downloaddir,'/', urbanmsk.aligned)

#BFAST
bfast_dir <- paste0(rootdir, 'results/bfast/')
thres_dir <- paste0(rootdir, 'results/bfast/threshold/')


#landcover directory #sentinel 2 and sentinel 1 data

landcover_dir <- paste0(rawimgdir,'/','landcover/')
#bgw stands for brighness greenest wetness
wetdir_s2 <- paste0(landcover_dir,'/','ng_s2_tg15ago2018_wet/')
drydir_s2 <- paste0(landcover_dir,'/','ng_s2_tg15feb2018_dry_allbands/')
wetdir_s2_bgw <- paste0(landcover_dir,'/','ng_s2_tg15ago2018_wet_BGW_copy/')
drydir_s2_bgw <- paste0(landcover_dir,'/','ng_s2_tg15feb2018_fry_BGW')
dir_s1 <- paste0(landcover_dir,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier')

#rasters
wetdir_s2_r  <- raster(paste0(wetdir_s2,'/',"ng_s2_tg15ago2018_wet.vrt"))
drydir_s2_r <- raster(paste0(drydir_s2,'/','ng_s2_tg15feb2018_dry_allbands.vrt'))
wetdir_s2_bgw_r <- raster(paste0(wetdir_s2_bgw,'/','ng_s2_tg15ago2018_wet_BGW_copy.vrt'))
drydir_s2_bgw_r <- raster(paste0(drydir_s2_bgw,'/','ng_s2_tg15feb2018_fry_BGW.vrt'))
dir_s1_r <- raster(paste0(dir_s1,'/','r_ng_2019_01012018_19062019_ab_10m_nooutlier.vrt'))




