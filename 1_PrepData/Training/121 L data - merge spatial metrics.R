filelist_LandIQ.spat.metrics.by.year.county <- list.files("../Data/Train/SpatialMetrics/LandIQ/", full.names = T)



# Append columns for county and ID
# ==========[       Outputs         ]==========#
df_rf_LandIQ2014 <- "../Data/Train/MergedMetrics/LandIQ/df_spatial_2014.Rds"
df_rf_LandIQ2016 <- "../Data/Train/MergedMetrics/LandIQ/df_spatial_2016.Rds"
df_rf_LandIQ2018 <- "../Data/Train/MergedMetrics/LandIQ/df_spatial_2018.Rds"
# ==========[        Notes          ]==========#



# 2014 --------------------------------------------------------------------

df_LandIQ2014_spat_metrics <- lapply(grep(value = T, "2014", filelist_LandIQ.spat.metrics.by.year.county), readRDS) %>% rbindlist(fill = T)
saveRDS(df_LandIQ2014_spat_metrics, file = df_rf_LandIQ2014)
df_LandIQ2014_spat_metrics
# 2016 --------------------------------------------------------------------

df_LandIQ2016_spat_metrics <- lapply(grep(value = T, "2016", filelist_LandIQ.spat.metrics.by.year.county), readRDS) %>% rbindlist(fill = T)
df_LandIQ2016_spat_metrics[,`:=`(OBJECTID_1=NULL,GlobalID=NULL)]
saveRDS(df_LandIQ2016_spat_metrics, file = df_rf_LandIQ2016)


# 2018 --------------------------------------------------------------------

df_LandIQ2018_spat_metrics <- lapply(grep(value = T, "2018", filelist_LandIQ.spat.metrics.by.year.county), readRDS) %>% rbindlist(fill = T)
saveRDS(df_LandIQ2018_spat_metrics, file = df_rf_LandIQ2018)

