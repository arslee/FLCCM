
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

  # .... additional metrics ....#
  # ai = function(x) lsm_l_ai(x)$value,
  # area_cv = function(x) lsm_l_area_cv(x)$value,
  # area_mn = function(x) lsm_l_area_mn(x)$value,
  # area_sd = function(x) lsm_l_area_sd(x)$value,
  # cai_cv = function(x) lsm_l_cai_cv(x)$value,
  # cai_mn = function(x) lsm_l_cai_mn(x)$value,
  # cai_sd = function(x) lsm_l_cai_sd(x)$value,
  # circle_cv = function(x) lsm_l_circle_cv(x)$value,
  # circle_mn = function(x) lsm_l_circle_mn(x)$value,
  # circle_sd = function(x) lsm_l_circle_sd(x)$value,
  # cohesion = function(x) lsm_l_cohesion(x)$value,
  # condent = function(x) lsm_l_condent(x)$value,
  # contag = function(x) lsm_l_contag(x)$value,
  # contig_cv = function(x) lsm_l_contig_cv(x)$value,
  # contig_mn = function(x) lsm_l_contig_mn(x)$value,
  # contig_sd = function(x) lsm_l_contig_sd(x)$value,
  # core_cv = function(x) lsm_l_core_cv(x)$value,
  # core_mn = function(x) lsm_l_core_mn(x)$value,
  # core_sd = function(x) lsm_l_core_sd(x)$value,
  # dcad = function(x) lsm_l_dcad(x)$value,
  # dcore_cv = function(x) lsm_l_dcore_cv(x)$value,
  # dcore_mn = function(x) lsm_l_dcore_mn(x)$value,
  # dcore_sd = function(x) lsm_l_dcore_sd(x)$value,
  # division = function(x) lsm_l_division(x)$value,
  # ed = function(x) lsm_l_ed(x)$value,
  # enn_cv = function(x) lsm_l_enn_cv(x)$value,
  # enn_mn = function(x) lsm_l_enn_mn(x)$value,
  # enn_sd = function(x) lsm_l_enn_sd(x)$value,
  # ent = function(x) lsm_l_ent(x)$value,
  # frac_cv = function(x) lsm_l_frac_cv(x)$value,
  # frac_mn = function(x) lsm_l_frac_mn(x)$value,
  # frac_sd = function(x) lsm_l_frac_sd(x)$value,
  # gyrate_cv = function(x) lsm_l_gyrate_cv(x)$value,
  # gyrate_mn = function(x) lsm_l_gyrate_mn(x)$value,
  # gyrate_sd = function(x) lsm_l_gyrate_sd(x)$value,
  # iji = function(x) lsm_l_iji(x)$value,
  # joinent = function(x) lsm_l_joinent(x)$value,
  # lpi = function(x) lsm_l_lpi(x)$value,
  # lsi = function(x) lsm_l_lsi(x)$value,
  # mesh = function(x) lsm_l_mesh(x)$value,
  # msidi = function(x) lsm_l_msidi(x)$value,
  # msiei = function(x) lsm_l_msiei(x)$value,
  # mutinf = function(x) lsm_l_mutinf(x)$value,
  # ndca = function(x) lsm_l_ndca(x)$value,
  # np = function(x) lsm_l_np(x)$value,
  # pafrac = function(x) lsm_l_pafrac(x)$value,
  # para_cv = function(x) lsm_l_para_cv(x)$value,
  # para_mn = function(x) lsm_l_para_mn(x)$value,
  # para_sd = function(x) lsm_l_para_sd(x)$value,
  # pd = function(x) lsm_l_pd(x)$value,
  # pladj = function(x) lsm_l_pladj(x)$value,
  # pr = function(x) lsm_l_pr(x)$value,
  # prd = function(x) lsm_l_prd(x)$value,
  # relmutinf = function(x) lsm_l_relmutinf(x)$value,
  # rpr = function(x) lsm_l_rpr(x)$value,
  # shape_cv = function(x) lsm_l_shape_cv(x)$value,
  # shape_mn = function(x) lsm_l_shape_mn(x)$value,
  # shape_sd = function(x) lsm_l_shape_sd(x)$value,
  # shdi = function(x) lsm_l_shdi(x)$value,
  # shei = function(x) lsm_l_shei(x)$value,
  # sidi = function(x) lsm_l_sidi(x)$value,
  # siei = function(x) lsm_l_siei(x)$value,
  # split = function(x) lsm_l_split(x)$value,
  # ta = function(x) lsm_l_ta(x)$value,
  # tca = function(x) lsm_l_tca(x)$value,
  # te = function(x) lsm_l_te(x)$value
)
