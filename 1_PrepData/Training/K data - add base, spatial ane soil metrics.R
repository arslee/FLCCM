############## Documentation ##################
# ==========[       Purpose         ]==========#
# construct field-level data for Kern county for 2007 and 2019

# ==========[       Inputs          ]==========#
# masked CDL : ../../Data/Train/MaskedCDL/Kern
# soil characteristics: Data/Raw/Soil/ISSR400/
# ==========[       Process         ]==========#
# 1. add base metrics
# 2. add spatial metrics
# 3. add soil characteristics
# 4. merge base, spatial, and soil characteristics
# 5. clean commodities and convert minor crops to others
# ==========[       Outputs         ]==========#
# intermediate data for spatial metrics : ../../Data/Train/SpatialMetrics/Kern/df_", x, ".rds
# final data for training :  ../../Data/Train/MergedMetrics/Kern/df_rf_kern.Rds
# ==========[        Notes          ]==========#




# base and spatial metrics ------------------------------------------------

# load data
filelist <- grep("masked",
  list.files("../Data/Train/MaskedCDL/Kern", full.names = T),
  value = T
)

df_kern <- lapply(filelist, function(x) {
  df <- readRDS(x)
  df$ACRES <- as.double(df$ACRES)
  if ("COMM_CODE" %in% names(df)) {
    df$COMM_CODE <- as.double(df$COMM_CODE)
  }
  df
}) %>% bind_rows()

# calculate acreage
df_kern$acres <- sapply(df_kern$geometry, st_area) / 4046.86


# loop by year
years <- df_kern$PMT_YEAR %>% unique()


options("future.globals.maxSize" = 40000 * 1042^2)
plan(multisession, workers = 8)

future_map(.progress = T, years, function(x) {
  print(x)
  library(landscapemetrics)
  library(dplyr)
  library(data.table)
  df_out <- df_kern[df_kern$PMT_YEAR == x, ] %>%
    mutate(pland = map(cdl, func$landscape[["lsm_c_pland"]])) %>%
    mutate(
      m1 = map_chr(pland, ~ .x[1, class]),
      m2 = map_chr(pland, function(x) {
        ifelse(nrow(x) > 1, x[2, class], 0L)
      }),
      m3 = map_chr(pland, function(x) {
        ifelse(nrow(x) > 2, x[3, class], 0L)
      }),
      m4 = map_chr(pland, function(x) {
        ifelse(nrow(x) > 3, x[4, class], 0L)
      }),
      m5 = map_chr(pland, function(x) {
        ifelse(nrow(x) > 4, x[5, class], 0L)
      }),
      s1 = map_dbl(pland, function(x) {
        ifelse(!is.nan(x[1, value]), x[1, value], 0)
      }),
      s2 = map_dbl(pland, function(x) {
        ifelse(!is.nan(x[1, value]) & nrow(x) > 1, x[2, value], 0)
      }),
      s3 = map_dbl(pland, function(x) {
        ifelse(!is.nan(x[1, value]) & nrow(x) > 2, x[3, value], 0)
      }),
      s4 = map_dbl(pland, function(x) {
        ifelse(!is.nan(x[1, value]) & nrow(x) > 3, x[4, value], 0)
      }),
      s5 = map_dbl(pland, function(x) {
        ifelse(!is.nan(x[1, value]) & nrow(x) > 4, x[5, value], 0)
      }),
      ent = map(cdl, ~ func$landscape[["lsm_l_ent"]](.x)),
      condent = map(cdl, ~ func$landscape[["lsm_l_condent"]](.x)),
      joinent = map(cdl, ~ func$landscape[["lsm_l_joinent"]](.x)),
      mutinf = map(cdl, ~ func$landscape[["lsm_l_mutinf"]](.x)),
      division = map(cdl, ~ func$landscape[["lsm_l_division"]](.x)),
      mesh = map(cdl, ~ func$landscape[["lsm_l_mesh"]](.x)),
      pladj = map(cdl, ~ func$landscape[["lsm_l_pladj"]](.x))
    ) %>%
    st_drop_geometry() %>%
    mutate(year = x) %>%
    dplyr::select(
      year, PMT_SITE, COMM, acres,
      m1, m2, m3, m4, m5,
      s1, s2, s3, s4, s5,
      ent, condent, joinent, mutinf, division, mesh, pladj
    )

  saveRDS(df_out, file = paste0("../Data/Train/SpatialMetrics/Kern/df_", x, ".rds"))
})



# clean commodities and reclassify commodities ----------------------------

# spatial metrics
df_rf <- list.files("../Data/Train/SpatialMetrics/Kern/", full.names = T) %>%
  lapply(readRDS) %>% 
  rbindlist() %>%
  mutate(
    COMM =
      str_remove_all(
        COMM,
        ", WINE| - |SEED|DRIED|SUC SEED|SUCCULENT|, RED|PROCESS|PROCESS-|,SEED|HEAD|HEAD SD| LEAF.*| ROMAINE|SDLS|-ORG.*|- ORG.*|FOR/.*|, GRAIN|, HUMAN CON|, SWEET|, RAISIN|, WINE"
      ) %>% str_trim()
  ) %>%
  mutate_if(is.list, as.numeric) %>% 
  drop_na()

# calculate acreage by crop
kern_acre <- df_rf %>%
  group_by(COMM) %>%
  summarise(acr = sum(acres)) %>%
  arrange(-acr)

# pick top 40
top_40 <- kern_acre[1:40, ] %>% pull(COMM)

# data out
df_out <- df_rf %>% mutate(COMM = ifelse(COMM %in% top_40, COMM, "others")) 

# save --------------------------------------------------------------------
saveRDS(df_out, file = "../Data/Train/MergedMetrics/Kern/df_rf_kern.Rds")
