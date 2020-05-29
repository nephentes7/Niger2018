# Niger2018
Land cover mapping and change detection around Diffa-SAFE project

Prerequisites
These scripts run best through RStudio in SEPAL, although it is possible to run the scripts on a Linux system.

Dependencies include: GDAL

Use SEPAL to download your single year mosaics (sentinel 1 and 2).
Set your custom parameters in the first script and follow the order to run the other scripts, line by line. 

*********************************************************************************************
Methodology/Approach:
The following scripts serve to: 
1. create a vegetation (shurbs + tree cover) mask year 2013 to be used/applied over the changes.
		based on Sentinel images 
		combined list of indexes and normalized bands (for both wet and dry seasons)
		by computing  mean of a weighted 3 by 3 pixels window

2. create a change detection map as result of the integration of: 
  		reclassified BFAST magnitude (thresholds have been compared: from statistics (i.e. mediam values on loss training polygons) vs visual asssessment (pixels values 
					      across validated loss) and based on patch size as follow
								     > 0.5 ha loss (for class 4 and 5 of the magnitude of change output), 
								     > 0.5 class 3, degradation
 								     < 0.5 ha (3 -5) degradation.
  		 supervised change detection using different input layers of change and the standard deviation of a weighted window of 3 by 3 pixels.
		(e.g. Burnt ration, NDVI difference, IMAD for wet and dry season, BFAST raw data and
			).
 his with a RF result of change input layers
 	using: bfast (raw data) + IMAD raw data (wet and dry) + NDII- Normalized Difference Infrared Index (wet and dry) + NBR (Normalized BUrn Ratio) 
	and ther difference indexes  in NDVI (〖[(NDVI"humide" -NDVI"sèche" )/ (NDVI"humide" +NDVI"sèche" )]〗^2013- 〖[(NDVI"humide" -NDVI"sèche" )/ (NDVI"humide" +NDVI"sèche" )]〗^2018  

3.  Land cover 2018 (similar approach use in point 1.) based on Sentinel 2 and 1 
