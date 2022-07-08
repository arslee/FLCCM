# 
# # file --------------------------------------------------------------------
# # load CDL data and LandIQ data to file list. 
# # CDL: 2007 - 2019
# # LandIQ: 2014, 2015, 2016
 file <- list()
# 
for (y in par$cdl_years) {
  file[[paste0("cdl", y)]] <- paste0("../Data/Raw/CDL/CDL_", y, "_06/CDL_", y, "_06.tif")
}
# 
file$LandIQ2014 <- "../Data/Raw/LandIQ/2014/i15_Crop_Mapping_2014_Final_LandIQonAtlas.shp"
file$LandIQ2016 <- "../Data/Raw/LandIQ/2016/i15_Crop_Mapping_2016.shp"
file$LandIQ2018 <- "../Data/Raw/LandIQ/2018/i15_Crop_Mapping_2018.shp"
st_read(file$LandIQ2014)
# 
# 
# # path --------------------------------------------------------------------
# 
# dir <- list()
# dir$project_data                         <- "./Data"
# dir$global_data_train_masked_CDL         <- "../../Data/Train/MaskedCDL"
# 
# #dir.create(dir$global_data_train_masked_CDL)
# 
# 

 
 
 