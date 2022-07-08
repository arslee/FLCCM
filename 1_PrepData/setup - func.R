
func <- list()

#--- county and state map ---#
func$cb <- tigris::counties(cb = T) %>%
  filter(STATEFP == "06") %>%
  mutate(FIPS = as.numeric(GEOID))
func$sb <- tigris::states(cb = T) %>%
  filter(STATEFP == "06")


#--- extract CDLs for fields in one county ---#
# This is for parallel possessing
func$extract_cdl_for_county <- function(county) {
  df <- LandIQ_p[LandIQ_p$County == county, ] %>%
    mutate(
      cdl =
        map(ID, function(x) {
          p <- LandIQ_p[LandIQ_p$ID == x, "geometry"]
          r <- crop(cdl_ca_r, p) # first crop then mask
          r <- mask(r, st_zm(p))
        })
    )
}

# ....crop and mask....#
func$cm <- function(r, p) {
  # usage
  # func$cmf(cdl_ca_r,LandIQ_p[i,])
  r <- crop(r, p)
  r <- mask(r, st_zm(p))
  r
}

# ....plot raster with field....#
func$plot_rf <- function(r, p) {
  # usage
  # func$plot_rf(cdl_ca_r,LandIQ_p[i,])
  
  r <- crop(r, p)
  r <- mask(r, st_zm(p))
  raster::plot(r)
  plot(p[, "geometry"], add = T)
}


#--- landscapemetrics ---#


func$landscape <- list(
  # ....area share by class....#
  lsm_c_pland = function(x) data.table(lsm_c_pland(x))[order(-value)][, value := value / sum(value, na.rm = T)], # Because NAs outside boundary are counted, adjust denominator
  # ....marginal entropy....#
  lsm_l_ent = function(x) lsm_l_ent(x)$value,
  # ....conditional entropy....#
  lsm_l_condent = function(x) lsm_l_condent(x)$value,
  # ....joint entropy....#
  lsm_l_joinent = function(x) lsm_l_joinent(x)$value,
  # ....mutual entropy....#
  lsm_l_mutinf = function(x) lsm_l_mutinf(x)$value,
  # ....division....#
  lsm_l_division = function(x) lsm_l_division(x)$value,
  # ....effective mesh size....#
  lsm_l_mesh = function(x) lsm_l_mesh(x)$value,
  # ....interspersion and juxtaposition index....#
  lsm_l_iji = function(x) lsm_l_iji(x)$value,
  # ....percentage of like adjacencies....#
  lsm_l_pladj = function(x) lsm_l_pladj(x)$value
)
