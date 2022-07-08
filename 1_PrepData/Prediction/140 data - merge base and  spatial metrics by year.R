#---------------[   Purpose    ]--------------------
#
# Merge base and spatial metrics by year and save
#
#---------------[   Process    ]--------------------


# base metrics ------------------------------------------------------------

base_list <- list.files("../Data/Prediction/BaseMetrics/BeforeMerge/",full.names = T)
df_base <- lapply(base_list, 
                  function(x){readRDS(x) %>% 
                      mutate(year=parse_number(basename(x)))}) %>% 
  bind_rows() %>% 
  data.table()

# #--- soil ---#
# load("../Data/Train/MergedMetrics/LandIQ/df_soil_2018.RData")
# df_soil <- df_soil_2018 %>% dplyr::select(UniqueID,contains("mean"),contains("mode")) %>% data.table()
# 
# 
# #--- merge base and soil ---#
# df_base <- df_soil[df_base, on=c("UniqueID")]

# spatial metrics ---------------------------------------------------------

spatial_list <- list.files("../Data/Prediction/SpatialMetrics/BeforeMerge/",full.names = T)
df_spatial <- lapply(spatial_list, readRDS) %>% 
  bind_rows() %>% 
  spread(variable,value) %>% 
  data.table()


# merge -------------------------------------------------------------------

df <- df_spatial[df_base, on=c("year","UniqueID")]



# export ------------------------------------------------------------------

dir.create("../Data/Prediction/MergedMetrics/")
year_list <- unique(df$year)
lapply(year_list, function(yr){
  df_year <- df[year==yr,]
  saveRDS(df_year, file= paste0("../Data/Prediction/MergedMetrics/", "df_rf_",yr,".Rds"))
})
