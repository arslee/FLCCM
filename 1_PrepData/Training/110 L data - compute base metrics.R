############## Documentation ###################
# ==========[       Purpose         ]==========#
# calculate metrics for fields
# ==========[       Inputs          ]==========#
load("../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2014.RData")
load("../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2016.RData")

# ==========[       Process         ]==========#
#
# ==========[       Outputs         ]==========#
#
# ==========[        Notes          ]==========#

# 2014 and 2016 -----------------------------------------------------------

#--- put data in a list ---#
LandIQ <- list(
  df_2014 = df_2014 %>% mutate(Crop = Crop2014),
  df_2016 = df_2016 %>% mutate(Crop = Crop2016)
)

#--- construct pairs to loop over  ---#
# ....all possible pairs....#
pairs_all <- unique(data.frame(year = c(2014, 2016), county = df_2014$County))

pairs_all <- rbind(
  data.table(county = LandIQ[["df_2014"]]$County, crop = LandIQ[["df_2014"]]$Crop2014, year = 2014),
  data.table(county = LandIQ[["df_2016"]]$County, crop = LandIQ[["df_2016"]]$Crop2016, year = 2016)
) %>%
  distinct() %>%
  as.data.frame(stringsAsFactors = F) %>%
  data.table()

rm(df_2014, df_2016)

# ....pairs already done....#
dir.create("../Data/Train/BaseMetrics/LandIQ/", recursive = T)
pairs_exist <- gsub("df_rf_LandIQ|_|.Rds", "", list.files("../Data/Train/BaseMetrics/LandIQ/")) # "./Data/LandIQ"
# ....pairs to work on....#
pairs_in <- pairs_all[!paste0(year, county, crop) %in% pairs_exist, ]

#--- loop ---#
options("future.globals.maxSize" = 4048 * 4048^2)
plan(multisession, workers = 6)

future_pmap(.progress = T, pairs_in, function(county, crop, year) {
  library(data.table)
  library(landscapemetrics)
  # ....export data to the global folder....#

  # dir.create(paste0("../Data/Train/BaseMetrics/LandIQ/"))
  path_data_out <- paste0("../Data/Train/BaseMetrics/LandIQ/df_rf_LandIQ_", year, "_", county, "_", crop, ".Rds")

  # ....compute metrics....#

  df <- LandIQ[[paste0("df_", year)]] %>%
    filter(County == county & Crop == crop) %>%
    mutate(pland = map(cdl, func$landscape[["lsm_c_pland"]])) %>%
    mutate(m1 = map_chr(pland, ~ .x[1, class])) %>%
    mutate(m2 = map_chr(pland, function(x) {
      ifelse(nrow(x) > 1, x[2, class], 0L)
    })) %>%
    mutate(m3 = map_chr(pland, function(x) {
      ifelse(nrow(x) > 2, x[3, class], 0L)
    })) %>%
    mutate(m4 = map_chr(pland, function(x) {
      ifelse(nrow(x) > 3, x[4, class], 0L)
    })) %>%
    mutate(m5 = map_chr(pland, function(x) {
      ifelse(nrow(x) > 4, x[5, class], 0L)
    })) %>%
    mutate(s1 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]), x[1, value], 0)
    })) %>%
    mutate(s2 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]) & nrow(x) > 1, x[2, value], 0)
    })) %>%
    mutate(s3 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]) & nrow(x) > 2, x[3, value], 0)
    })) %>%
    mutate(s4 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]) & nrow(x) > 3, x[4, value], 0)
    })) %>%
    mutate(s5 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]) & nrow(x) > 4, x[5, value], 0)
    }))

  # ....select columns....#
  cols <-
    c(
      "ID",
      grep("Crop20", names(df), value = T),
      "Acres",
      "m1", "m2", "m3", "m4", "m5",
      "s1", "s2", "s3", "s4", "s5"
    )

  # ....drop geometry and convert column class....#
  df_rf <- st_drop_geometry(df)[, cols] %>%
    mutate_if(is.character, as.factor)

  # ....export data....#
  saveRDS(df_rf, path_data_out)
})







# 2018 --------------------------------------------------------------------


load("../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2018.RData")


#--- put data in a list ---#
LandIQ <- list(
  df_2018 = df_2018
)


#--- construct pairs to loop over  ---#
# ....all possible pairs....#
pairs_all <- LandIQ$df_2018 %>%
  st_drop_geometry() %>%
  dplyr::select(COUNTY, CROPTYP2) %>%
  distinct() %>%
  rename(county = COUNTY, crop = CROPTYP2) %>%
  mutate(year = 2018)

# ....pairs already done....#
# pairs_exist <- gsub("df_rf_LandIQ|_|.Rds", "", list.files("./Data/LandIQ")) # "./Data/LandIQ"
# # ....pairs to work on....#
# pairs_in <- pairs_all[!paste0(pairs_all$year, pairs_all$county) %in% pairs_exist, ]


pairs_in <- pairs_all

#--- loop ---#
options("future.globals.maxSize" = 4048 * 4048^2)
plan(multisession, workers = 10)

future_pmap(pairs_in, function(county, crop, year) {
  library(data.table)
  library(landscapemetrics)
  # ....export data to the global folder....#

  # dir.create(paste0("../Data/Train/BaseMetrics/LandIQ/"))
  path_data_out <- paste0("../Data/Train/BaseMetrics/LandIQ/df_rf_LandIQ_", year, "_", county, "_", crop, ".Rds")


  # ....compute metrics....#

  df <- LandIQ[[paste0("df_", year)]] %>%
    filter(COUNTY == county & CROPTYP2 == crop) %>%
    mutate(pland = map(cdl, func$landscape[["lsm_c_pland"]])) %>%
    mutate(m1 = map_chr(pland, ~ .x[1, class])) %>%
    mutate(m2 = map_chr(pland, function(x) {
      ifelse(nrow(x) > 1, x[2, class], 0L)
    })) %>%
    mutate(m3 = map_chr(pland, function(x) {
      ifelse(nrow(x) > 2, x[3, class], 0L)
    })) %>%
    mutate(m4 = map_chr(pland, function(x) {
      ifelse(nrow(x) > 3, x[4, class], 0L)
    })) %>%
    mutate(m5 = map_chr(pland, function(x) {
      ifelse(nrow(x) > 4, x[5, class], 0L)
    })) %>%
    mutate(s1 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]), x[1, value], 0)
    })) %>%
    mutate(s2 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]) & nrow(x) > 1, x[2, value], 0)
    })) %>%
    mutate(s3 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]) & nrow(x) > 2, x[3, value], 0)
    })) %>%
    mutate(s4 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]) & nrow(x) > 3, x[4, value], 0)
    })) %>%
    mutate(s5 = map_dbl(pland, function(x) {
      ifelse(!is.nan(x[1, value]) & nrow(x) > 4, x[5, value], 0)
    }))


  # ....select columns....#
  cols <-
    c(
      "UniqueID",
      "CROPTYP2",
      "ACRES",
      "m1", "m2", "m3", "m4", "m5",
      "s1", "s2", "s3", "s4", "s5"
    )

  # ....drop geometry and convert column class....#
  df_rf <- st_drop_geometry(df)[, cols] %>%
    mutate_if(is.character, as.factor)


  # ....export data....#
  saveRDS(df_rf, path_data_out)
})
