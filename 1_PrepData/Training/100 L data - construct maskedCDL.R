############## Documentation ###################
# ==========[       Purpose         ]==========#
# construct masked CDL for each field in LandIQ 2014, 2016 and 2018
# ==========[       Inputs          ]==========#
# CDL and LandIQ for 2014, 2016 and 2018
# ==========[       Process         ]==========#
# extract raster for each field
# since raster::mask is slow and the number of fields are too many,
# loop over county-crop pairs using parallel processing
# ==========[       Outputs         ]==========#

# ==========[        Notes          ]==========#
# LandIQ for 2018 is different than that of 2014 and 2016
# Process 2014 and 2016 first




#--- 2014 and 2016 ---#
# ....text is for Land IQ 2014....#
text2014 <- '
 
# ....create subfolder for year....#

path_data_out <- "../Data/Train/MaskedCDL/LandIQ/2014"
dir.create(path_data_out, recursive=T)


# ....cdl....#

cdl_ca_r <- raster(file$cdl2014)
crs(cdl_ca_r) <- par$projCDL


# ....Land IQ....#

LandIQ_p <- st_read(file$LandIQ2014) %>%
  st_as_sf() %>%
  st_set_crs(crs(par$projLandIQ)) %>%
  # st_set_crs(6414) %>%
  st_transform(crs(cdl_ca_r)) %>%
  mutate(
    ID = 1:n(),
    Crop2014 = gsub("/|,", "", Crop2014)
  ) %>%
  filter(Crop2014 != "<NA>" & County != "<NA>")


# ....select crop-county pairs to work on....#

pairs_M <- unique(st_drop_geometry(LandIQ_p[, c("Crop2014", "County")]))
pairs_S <- paste0(pairs_M$Crop2014, "_", pairs_M$County)

pairs_to_skip <- c("", gsub(".*LandIQ2014_|*.Rds", "", list.files(path_data_out)))
pairs_to_work <- pairs_S[!pairs_S %in% pairs_to_skip] %>%
  data.frame(stringsAsFactors = F) %>%
  separate(".", sep = "_", into = c("crop", "county"))


# ....loop....#

plan(multisession, workers = 5)

future_pmap(
  .progress = T,
  list(
    pairs_to_work$crop,
    pairs_to_work$county
  ),
  function(crop, county) {
    df <- LandIQ_p %>%
      filter(Crop2014 == crop & County == county) %>%
      mutate(cdl = future_map(
        ID,
        function(x) {
          library(raster)
          p <- LandIQ_p[LandIQ_p$ID == x, "geometry"]
          mask(crop(cdl_ca_r, p), st_zm(p))
        }
      ))

    saveRDS(df, paste0(path_data_out, "/df_maskedCDL_LandIQ2014_", crop, "_", county, ".Rds"))
  }
)             
'


# ....execute....#
eval(parse(text = text2014))
eval(parse(text = gsub("2014", "2016", text2014)))




#--- 2018 ---#

path_data_out <- "../Data/Train/MaskedCDL/LandIQ/2018"

dir.create(path_data_out, recursive = T)


# ....cdl....#
cdl_ca_r <- raster(file$cdl2018)
crs(cdl_ca_r) <- par$projCDL


# ....Land IQ....#
LandIQ_p <- st_read(file$LandIQ2018) %>%
  st_as_sf() %>%
  st_transform(crs(cdl_ca_r))


# ....select crop-county pairs to work on....#
pairs_M <- unique(st_drop_geometry(LandIQ_p[, c("CROPTYP2", "COUNTY")]))
pairs_S <- paste0(pairs_M$CROPTYP2, "_", pairs_M$COUNTY)

pairs_to_skip <- c("", gsub(".*LandIQ2018_|*.Rds", "", list.files(path_data_out)))
pairs_to_work <- pairs_S[!pairs_S %in% pairs_to_skip] %>%
  data.frame(stringsAsFactors = F) %>%
  separate(".", sep = "_", into = c("crop", "county")) %>%
  filter(county != "****")


# ....loop....#

options("future.globals.maxSize" = 6072 * 6072^2)
plan(multisession, workers = 10)
future_pmap(
  .progress = T,
  list(
    pairs_to_work$crop,
    pairs_to_work$county
  ),
  function(crop, county) {
    df <- LandIQ_p %>%
      filter(CROPTYP2 == crop & COUNTY == county) %>%
      mutate(cdl = future_map(
        UniqueID,
        function(x) {
          library(raster)
          p <- LandIQ_p[LandIQ_p$UniqueID == x, "geometry"]
          mask(crop(cdl_ca_r, p), st_zm(p))
        }
      ))

    saveRDS(df, paste0(path_data_out, "/df_maskedCDL_LandIQ2018_", crop, "_", county, ".Rds"))
  }
)
