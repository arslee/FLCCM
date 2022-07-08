#---------------[   Purpose    ]--------------------
#
# construct dataset for random forest for 2014, 2016, and 2018 combined 
#
#---------------[ Pinned Notes ]--------------------
#
# bind data for prediction and training first and then split
# do this way to make factor classifications are consistent between data for prediction and training
#---------------[   Process    ]--------------------
select <- dplyr::select
rm(list=ls())

# construct data for prediction ------------------------------------------
#----@ input: "../Data/Prediction/MergedMetrics/" @----
df_pred <- list.files("../Data/Prediction/MergedMetrics/", full.names = T) %>%
  future_map(readRDS) %>%
  rbindlist() %>%  
  dplyr::rename(Acres = ACRES) %>% 
  mutate_if(is.factor, as.character) %>% 
  mutate(is_GT=F)


# construct table matching year-specific ID to county   -------------------------------------
#----@ input: "../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2018.RData" @----
load("../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2018.RData")
cty_ID_2018 <- df_2018 %>%
  dplyr::select(UniqueID, ACRES, COUNTY) %>% 
  st_make_valid()

#----@ input: "../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2014.RData" @----
load("../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2014.RData")
cty_ID_2014 <- df_2014 %>%
  dplyr::select(ID, Acres, County) %>% 
  st_make_valid()

#----@ input: "../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2016.RData" @----
load("../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2016.RData")
cty_ID_2016 <- df_2016 %>%
  dplyr::select(ID, Acres, County)%>% 
  st_make_valid()


ID2014_2018 <- st_centroid(cty_ID_2018) %>% 
  st_join(cty_ID_2014) %>% 
  dplyr::select(UniqueID,ID) %>% 
  st_drop_geometry() %>% 
  na.omit()

ID2016_2018 <- st_centroid(cty_ID_2018) %>% 
  st_join(cty_ID_2016) %>% 
  dplyr::select(UniqueID,ID) %>% 
  st_drop_geometry() %>% 
  na.omit()



# load crop book -------------------------------------
#----@ note: This is for 2018 @----
cropbook <- read_excel("../Data/Raw/CropCodeBook_SL.xlsx") %>%
  dplyr::select(LandIQID2018, ReclassifiedLandIQNames) %>%
  distinct() %>%
  drop_na()

# load computed variables  -------------------------------------
df_base_2014 <- readRDS("../Data/Train/MergedMetrics/LandIQ/df_base_2014.Rds")
df_spat_2014 <- readRDS("../Data/Train/MergedMetrics/LandIQ/df_spatial_2014.Rds") 
df_2014 <- Reduce(function(...) merge(..., all = TRUE), list(ID2014_2018,df_base_2014,df_spat_2014)) %>% data.table()


df_base_2016 <- readRDS("../Data/Train/MergedMetrics/LandIQ/df_base_2016.Rds")
df_spat_2016 <- readRDS("../Data/Train/MergedMetrics/LandIQ/df_spatial_2016.Rds") 
df_2016 <- Reduce(function(...) merge(..., all = TRUE), list(ID2016_2018,df_base_2016,df_spat_2016)) %>% data.table()


df_base_2018 <- readRDS("../Data/Train/MergedMetrics/LandIQ/df_base_2018.Rds")
df_spat_2018 <- readRDS("../Data/Train/MergedMetrics/LandIQ/df_spatial_2018.Rds")
df_2018 <- Reduce(function(...) merge(..., all = TRUE), list(df_base_2018,df_spat_2018))
#setcolorder(df_2018,c("UniqueID","year","ACRES","CROPTYP2"))



# make datasets consistent ------------------------------------------------
# 2014
df_2014 <- df_2014 %>%
  mutate_if(is.factor, as.character) %>%
  left_join(cty_ID_2014, by = c("ID", "Acres")) %>%
  dplyr::select(!ID) %>%
  dplyr::rename(Crop = Crop2014) %>% 
  mutate(is_GT=T, year=2014) 
sapply(df_2014, class)

# 2016
df_2016 <- df_2016 %>%
  mutate_if(is.factor, as.character) %>%
  left_join(cty_ID_2016, by = c("ID", "Acres")) %>%
  dplyr::select(!ID) %>%
  dplyr::rename(Crop = Crop2016) %>% 
  mutate(is_GT=T, year=2016)

sapply(df_2016, class)

# 2018
df_2018 <- df_2018 %>%
  mutate_if(is.factor, as.character) %>%
  left_join(cropbook, by = c("CROPTYP2" = "LandIQID2018")) %>%
  dplyr::rename(Crop = ReclassifiedLandIQNames) %>%
  left_join(cty_ID_2018, by = c("UniqueID", "ACRES")) %>%
  #dplyr::select(-c(UniqueID, CROPTYP2)) %>%
  dplyr::select(-c(CROPTYP2)) %>%
  dplyr::rename(Acres = ACRES, County = COUNTY) %>% 
  mutate(is_GT=T, year=2018)

setcolorder(df_2018,names(df_2014))
names(df_2014)
names(df_2016)
names(df_2018)
names(df_pred)

df_2014[, geometry:=NULL]
df_2016[, geometry:=NULL]
df_2018[, geometry:=NULL]
df_pred <- dplyr::select(df_pred,-c(mean.cec_050cm:mode.soilorder))

filter <- dplyr::filter
# bind and clean -------------------------------------
df <-  smartbind(
  df_2014,
  df_2016,
  df_2018,
  df_pred
) %>%
  filter(!(Crop %in% c(
    "Managed Wetland",
    "Urban",
    "new lands being prepared for crop production"
  )))


cols_factor <- c(
  "Crop",
  names(df) %>% grep("m[0-9]{1}", ., value = T)
  # ,
  # names(df) %>% grep("mode", ., value = T)
)

df <- df %>%
  mutate_at(cols_factor, as.factor) %>%
  dplyr::select(year, UniqueID, Acres, Crop, County, everything()) %>%
  data.table()


# export ------------------------------------------------------------------


df_GT <- df[is_GT==T]
set.seed(2022)
tr <- sample(1:nrow(df_GT),round(nrow(df_GT)*.8))

#----@ output: "../Data/Train/RandomForest/LandIQ/df_train.Rds" @----
saveRDS(df_GT[tr,], "../Data/Train/RandomForest/LandIQ/df_train.Rds")
#----@ output: "../Data/Train/RandomForest/LandIQ/df_test.Rds" @----
saveRDS(df_GT[-tr,], "../Data/Train/RandomForest/LandIQ/df_test.Rds")

df_pred <- df[is_GT==F]
#----@ input: ../Data/Prediction/RandomForest/df_pred.Rds" @----
saveRDS(df_pred, "../Data/Prediction/RandomForest/df_pred.Rds")
