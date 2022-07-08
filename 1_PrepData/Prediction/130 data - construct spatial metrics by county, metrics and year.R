############## Documentation ##################
# ==========[       Purpose         ]==========#
# Construct spatial metrics

# ==========[       Inputs         ]==========#
# metrics to add
metrics_list <-
  list(
    ent = func$landscape[["lsm_l_ent"]],
    condent = func$landscape[["lsm_l_condent"]],
    joinent = func$landscape[["lsm_l_joinent"]],
    mutinf = func$landscape[["lsm_l_mutinf"]],
    division = func$landscape[["lsm_l_division"]],
    mesh = func$landscape[["lsm_l_mesh"]],
    pladj = func$landscape[["lsm_l_pladj"]]
  )


# county list
maskedCDL <- readRDS("../Data/Prediction/MaskedCDL/AfterMerge/df_maskedCDL_2007.Rds")
cty_list <- maskedCDL$COUNTY %>% unique()
rm(maskedCDL)

# year list
yrs <- parse_number(list.files("../Data/Prediction/MaskedCDL/AfterMerge/"))
# ==========[       Process         ]==========#

dir.create("../Data/Prediction/SpatialMetrics/BeforeMerge/", recursive = T)

for (yr in yrs) {
  print(yr)
  maskedCDL <- readRDS(paste0("../Data/Prediction/MaskedCDL/AfterMerge/df_maskedCDL_", yr, ".Rds"))
  year <- yr

  # ....compute metrics....#

  grids <- expand.grid(county = cty_list, metrics = names(metrics_list), stringsAsFactors = F)
  options("future.globals.maxSize" = 10000 * 1042^2)
  plan(multisession, workers = 10)

  future_pmap(.progress = T, grids, function(county, metrics) {
    print(county)
    library(landscapemetrics)
    library(dplyr)

    df <- maskedCDL %>%
      filter(COUNTY == county) %>%
      mutate(value = map_dbl(cdl, metrics_list[[metrics]])) %>%
      st_drop_geometry() %>%
      dplyr::select(UniqueID, value) %>%
      mutate(variable = metrics, year = year)

    path_data_out <- paste0("../Data/Prediction/SpatialMetrics/BeforeMerge/df_spatial_", year, "_", county, "_", metrics, ".Rds")

    saveRDS(df, path_data_out)
  })
}
