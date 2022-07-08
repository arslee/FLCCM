############## Documentation ##################
# ==========[       Purpose         ]==========#
# calculate metrics for fields
# ==========[       Inputs          ]==========#
filelist_LandIQ.base.metrics.by.year.county <- list.files("../Data/Train/BaseMetrics/LandIQ/", full.names = T)

# ==========[       Process         ]==========#
# Combine separately-saved base metrics for landIQ
# Append columns for county and ID
# ==========[       Outputs         ]==========#
df_rf_LandIQ2014 <- "../Data/Train/MergedMetrics/LandIQ/df_base_2014.Rds"
df_rf_LandIQ2016 <- "../Data/Train/MergedMetrics/LandIQ/df_base_2016.Rds"
df_rf_LandIQ2018 <- "../Data/Train/MergedMetrics/LandIQ/df_base_2018.Rds"
# ==========[        Notes          ]==========#

dir.create("../Data/Train/MergedMetrics/LandIQ/",recursive=T)

# 2014 --------------------------------------------------------------------

df_LandIQ2014_base_metrics <- lapply(grep(value = T, "2014", filelist_LandIQ.base.metrics.by.year.county), readRDS) %>% rbindlist(fill = T)
saveRDS(df_LandIQ2014_base_metrics, file = df_rf_LandIQ2014)

# 2016 --------------------------------------------------------------------

df_LandIQ2016_base_metrics <- lapply(grep(value = T, "2016", filelist_LandIQ.base.metrics.by.year.county), readRDS) %>% rbindlist(fill = T)
saveRDS(df_LandIQ2016_base_metrics, file = df_rf_LandIQ2016)


# 2018 --------------------------------------------------------------------

df_LandIQ2018_base_metrics <- lapply(grep(value = T, "2018", filelist_LandIQ.base.metrics.by.year.county), readRDS) %>% rbindlist(fill = T)
saveRDS(df_LandIQ2018_base_metrics, file = df_rf_LandIQ2018)

