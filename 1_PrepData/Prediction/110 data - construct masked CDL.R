############## Documentation ##################
# ==========[       Purpose         ]==========#
# construct masked cdl for all prediction years 2007 to 2020 except for 2014,2016, and 2018
# ==========[       Inputs          ]==========#
# CDL and LandIQ 2018
# ==========[       Process         ]==========#
# work by crop and county and year
# ==========[       Outputs         ]==========#
# "../../Data/Prediction/MaskedCDL/BeforeMerge/df_maskedCDL_LandIQ2018_", year, "_", crop, "_", county, ".Rds"
# ==========[        Notes          ]==========#
# Field boundaries are defined by landIQ 2018


# ....Land IQ....#
LandIQ2018 <- st_read(file$LandIQ2018) %>%
  st_as_sf() %>%
  st_transform(par$projCDL)

# ....select crop-county pairs to work on....#
pair_crop.county <- unique(st_drop_geometry(LandIQ2018[, c("CROPTYP2", "COUNTY")]))
pair_year.crop.county <- expand.grid(year = par$cdl_years, cc = paste0(pair_crop.county$CROPTYP2, "_", pair_crop.county$COUNTY)) %>%
  separate("cc", sep = "_", into = c("crop", "county")) %>%
  filter(county != "****") %>%
  #  filter(!year %in% c(2018)) %>%
  data.table()

folder <- "../Data/Prediction/MaskedCDL/BeforeMerge/"
dir.create(folder, recursive = T)
pair_to_skip <- grep("\\d{4}", gsub(
  "df_maskedCDL_LandIQ2018_|.Rds", "",
  list.files(folder)
), value = T) %>%
  data.frame() %>%
  separate(".", sep = "_", into = c("year", "crop", "county")) %>%
  data.table() %>%
  .[, year := as.integer(year)]

pair_to_work <- setdiff(pair_year.crop.county, pair_to_skip)



# ....loop....#
options("future.globals.maxSize" = 60000 * 1042^2)
plan(multisession, workers = 15)
future_pmap(
  .progress = T,
  list(
    pair_to_work$year,
    pair_to_work$crop,
    pair_to_work$county
  ),
  function(year, crop, county) {
    df <- LandIQ2018 %>%
      filter(CROPTYP2 == crop & COUNTY == county) %>%
      mutate(cdl = future_map(
        UniqueID,
        function(x) {
          library(raster)
          cdl_ca_r <- raster(file[[paste0("cdl", year)]])
          p <- LandIQ2018[LandIQ2018$UniqueID == x, "geometry"] %>% st_transform(crs(cdl_ca_r))
          mask(crop(cdl_ca_r, p), st_zm(p))
        }
      ))

    saveRDS(df, paste0("../Data/Prediction/MaskedCDL/BeforeMerge/df_maskedCDL_LandIQ2018_", year, "_", crop, "_", county, ".Rds"))
    rm(df)
  }
)
