#---------------[   Purpose    ]--------------------
#
# Post process crop2 to construct crop3
#
#---------------[   Process    ]--------------------
# load ground-truth data --------------------------------------------------
#----@ note: ground-truth data(train+test) needed to calculate overall accuracy for post processing @----
df_train <- readRDS("../Data/Train/RandomForest/LandIQ/df_train.Rds") %>%
  mutate(is_test = F)
#----@ note: test data is needed for producer and user accuracy of crop1,crop2,crop3 @----
df_test <- readRDS("../Data/Train/RandomForest/LandIQ/df_test.Rds") %>%
  mutate(is_test = T)
df_GT <- rbind(df_train, df_test) %>%
  .[!is.na(UniqueID)] %>%
  .[, .(year, UniqueID, Crop, is_test)]

setnames(df_GT, "Crop", "ref")



# load prediction data ----------------------------------------------------
df <- readRDS("../Data/Prediction/RandomForest/df_pred.Rds")
df$year <- as.integer(df$year)
df[, `:=`(Crop = NULL, County = NULL)]
df <- na.omit(df)

load("RF Result/rf_crop2.Rdata")
prob2 <- predictions(predict(rf_crop2, data = df))
df$crop2 <- apply(prob2, 1, function(x) colnames(prob2)[which.max(x)])
df$prob2 <- apply(prob2, 1, function(x) max(x))

load("RF Result/rf_crop1.Rdata")
prob1 <- predictions(predict(rf_crop1, data = df))
df$crop1 <- apply(prob1, 1, function(x) colnames(prob1)[which.max(x)])
df$prob1 <- apply(prob1, 1, function(x) max(x))


my_mode <- function(x) { # Create mode function
  unique_x <- unique(x)
  tabulate_x <- tabulate(match(x, unique_x))
  unique_x[tabulate_x == max(tabulate_x)]
}

df[, mode := my_mode(crop2)[1], UniqueID]
df[, N_mode := sum(mode == crop2), UniqueID]


df <- df[, .(UniqueID, year, Acres, crop2, prob2, crop1, prob1, mode, N_mode)]
#----@ note: merge ground-truth data with df @----
df <- df_GT[df, on = c("UniqueID", "year")]



#----@ note: post processing @----
crops <- list(
  p = list("Almonds", "Grapes", "Walnuts", "Pistachios"),
  i = list("Idle")
)

grid <- expand_grid(cr = names(crops), pr = seq(0, 1, .1), n = 1:14)
options(future.globals.maxSize = 50000 * 1024^2)
plan(multisession, workers = 5)

df_res <- future_pmap(.progress = T, grid, function(cr, pr, n) {
  print(cr)


  #--- refinement ---#  
  df_temp <- copy(df)
  df_temp[mode %in% crops[[cr]] & prob2 < pr & N_mode >= n, crop3 := mode]
  df_temp[is.na(crop3), crop3 := crop2]

  #--- accuracy ---#
  #----@ note: based on fields that exist in all years @----
  df_GT <- df_temp[year %in% c(2014, 2016, 2018), ]
  df_GT <- df_GT[!is.na(ref)]
  df_GT <- df_GT[, N := .N, UniqueID][N == max(N)]


  #--- confusion matrix  ---#
  M <- df_GT[, table(ref, crop3)]
  oa <- sum(diag(M)) / sum(M) %>% as.numeric()

  list(cr = cr, pr = pr, n = n, oa = oa)
}) %>% bind_rows()

# save optimal grid
grid_opt <- data.table(df_res)[, m_oa := max(oa), cr][m_oa == oa]
grid_opt <- grid_opt[, m_n := min(n), cr][m_n == n]
grid_opt
saveRDS(grid_opt, "../Data/Misc/grid_opt.rds")


# do refinement -----------------------------------------------------------
df_rf <- pmap(grid_opt[, 1:3], function(cr, pr, n) {
  print(cr)
  df_temp <- copy(df)
  df_temp[mode %in% crops[[cr]] & prob2 < pr & N_mode >= n, crop3 := mode]
  df_temp[!is.na(crop3)]
}) %>%
  bind_rows() %>%
  distinct()
df_rf <- df_rf[df, on = c("UniqueID", "year", "Acres", "ref", "crop2", "prob2", "mode", "N_mode", "crop1", "prob1", "is_test")]
df_rf[is.na(crop3), crop3 := crop2]

df_rf[crop2 == crop3, prob3 := prob2]
df_rf[crop2 != crop3, prob3 := NA]


# construct release layers -------------------------------------------------------
## accuracy by size, year, prediction methods -----------
df_GT <- df_rf[is_test == T]
df_GT <- df_GT[, N := .N, UniqueID][N == max(N)]

df_pa <- df_GT[, .(type = "pa1", acc = sum(ref == crop1, na.rm = T) / .N), .(crop = ref, acr_gr_15 = Acres > 15, before_2018 = year < 2018)]
df_ua <- df_GT[, .(type = "ua1", acc = sum(ref == crop1, na.rm = T) / .N), .(crop = crop1, acr_gr_15 = Acres > 15, before_2018 = year < 2018)]
df_acc1 <- rbind(df_pa, df_ua) %>%
  spread(type, acc)

df_pa <- df_GT[, .(type = "pa2", acc = sum(ref == crop2, na.rm = T) / .N), .(crop = ref, acr_gr_15 = Acres > 15, before_2018 = year < 2018)]
df_ua <- df_GT[, .(type = "ua2", acc = sum(ref == crop2, na.rm = T) / .N), .(crop = crop2, acr_gr_15 = Acres > 15, before_2018 = year < 2018)]
df_acc2 <- rbind(df_pa, df_ua) %>%
  spread(type, acc)

df_pa <- df_GT[, .(type = "pa3", acc = sum(ref == crop3, na.rm = T) / .N), .(crop = ref, acr_gr_15 = Acres > 15, before_2018 = year < 2018)]
df_ua <- df_GT[, .(type = "ua3", acc = sum(ref == crop3, na.rm = T) / .N), .(crop = crop3, acr_gr_15 = Acres > 15, before_2018 = year < 2018)]
df_acc3 <- rbind(df_pa, df_ua) %>%
  spread(type, acc) #


#--- prep ---#
df_out <- df_rf[order(UniqueID, year), .(UniqueID, year, Acres, crop1, prob1, crop2, prob2, crop3, prob3, crop_LandIQ = ref, acr_gr_15 = Acres > 15, before_2018 = year < 2018)]
df_out <- df_acc1[df_out, on = c("crop" = "crop1", "acr_gr_15", "before_2018")][, crop1 := crop][, crop := NULL]
df_out <- df_acc2[df_out, on = c("crop" = "crop2", "acr_gr_15", "before_2018")][, crop2 := crop][, crop := NULL]
df_out <- df_acc3[df_out, on = c("crop" = "crop3", "acr_gr_15", "before_2018")][, crop3 := crop][, crop := NULL]
df_out <- df_out[, .(
  UniqueID, year, Acres,
  crop1, prob1, pa1, ua1,
  crop2, prob2, pa2, ua2,
  crop3, prob3, pa3, ua3,
  crop_LandIQ
)]

#--- centroid ---#

landIQ <- st_read("../Data/Raw/LandIQ/2018/i15_Crop_Mapping_2018.shp")
cents <- st_centroid(landIQ$geometry %>% st_make_valid()) %>%
  unlist() %>%
  matrix(ncol = 2, byrow = T)
landIQ$lng <- cents[, 1]
landIQ$lat <- cents[, 2]


df_out_asis <- landIQ %>%
  dplyr::select(UniqueID, COUNTY, lng, lat) %>%
  right_join(df_out, landIQ2018, by = c("UniqueID")) %>%
  st_as_sf()

df_out_asis <- df_out_asis %>%
  dplyr::select(UniqueID, year, lng, lat,
    county = COUNTY,
    acres = Acres,
    everything()
  )

#----@ output: csv @----

fwrite(
  df_out_asis %>% st_drop_geometry() %>% dplyr::rename(uid = UniqueID, cropLIQ = crop_LandIQ),
  "Release/CropMap2007_2021.csv"
)
#----@ output: rds @----
saveRDS(
  df_out_asis %>% dplyr::rename(uid = UniqueID, cropLIQ = crop_LandIQ),
  "Release/CropMap2007_2021.rds"
)
# writeOGR(as(df_out_asis,"Spatial"), ".", "Release/CropMap2007_2020.shp",
#          driver = "ESRI Shapefile")

# df_out_simple <-st_read("../Data/Raw/LandIQ/2018/i15_Crop_Mapping_2018.shp")%>%
#   dplyr::select(UniqueID, COUNTY) %>%
#   st_make_valid(.) %>%
#   st_simplify(.,dTolerance = 30) %>%
#   st_make_valid(.) %>%
#   right_join(df_out,landIQ2018,by=c("UniqueID")) %>%
#   st_as_sf() %>%
#   filter(!st_is_empty(.))

# plot(st_simplify(df_out_asis[df_out_asis$UniqueID=="3100095","geometry"],dTolerance=30,preserveTopology=T))
# ?st_simplify
#----@ output: shapefile @----
plan(multisession, workers = 5)
future_map(unique(df_out$year), function(yr) {
  library(sf)
  library(rgdal)
  library(dplyr)
  library(sp)
  out <- df_out_asis %>%
    dplyr::filter(year == yr) %>%
    dplyr::rename(uid = UniqueID, cropLIQ = crop_LandIQ)
  out <- as(st_zm(out), "Spatial")

  writeOGR(out,
    dsn = paste0("Release/CropMap", yr), layer = "map",
    driver = "ESRI Shapefile",
    overwrite_layer = T,
  )
  print(yr)
})

