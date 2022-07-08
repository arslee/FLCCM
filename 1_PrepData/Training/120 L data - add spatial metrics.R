plan(multisession, workers = 15)

cdl_files <- list.files("../Data/Train/MaskedCDL/LandIQ", full.names = T, pattern = ".Rds$", recursive = T)

cdl_files %>%
  future_map(.progress = T, function(x) {
    library(landscapemetrics)
    library(sf)
    df <- readRDS(x) %>%
      dplyr::select(contains("ID"), cdl) %>%
      mutate(
        ent = func$landscape[["lsm_l_ent"]](cdl),
        condent = func$landscape[["lsm_l_condent"]](cdl),
        joinent = func$landscape[["lsm_l_joinent"]](cdl),
        mutinf = func$landscape[["lsm_l_mutinf"]](cdl),
        division = func$landscape[["lsm_l_division"]](cdl),
        mesh = func$landscape[["lsm_l_mesh"]](cdl),
        pladj = func$landscape[["lsm_l_pladj"]](cdl)
      ) %>%
      st_drop_geometry() %>%
      dplyr::select(-cdl)

    saveRDS(df, paste0("../Data/Train/SpatialMetrics/LandIQ/", str_remove(basename(x), "df_maskedCDL_LandIQ")))
  })
