############## Documentation ###################
#==========[       Purpose         ]==========# 
# construct masked CDL for each field in Kern 2008 to 2019 
#==========[       Inputs          ]==========#                   
# CDL and Kern (poly) for 2008 to 2019
#==========[       Process         ]==========#
# extract raster for each field
# since raster::mask is slow and the number of fields are too many,
# loop over year using parallel processing
#==========[       Outputs         ]==========#
#
#==========[        Notes          ]==========#
# I dropped fields with multiple commodities in the ground truth polygon data. 


options(future.globals.maxSize = 80000 * 1024^2)
plan(multisession, workers=10)
dir.create("../Data/Train/MaskedCDL/Kern/")
future_map(
  .progress = T, par$kern_years,
  function(y) {

    # ....file name and path out....#
    file.name.out <- paste0("../Data/Train/MaskedCDL/Kern/df_maskedCDL_Kern", y, ".Rds")
    
    # ....CDL....#
    cdl_ca_r <- raster(file[[paste0("cdl", y)]])
    crs(cdl_ca_r) <- par$projCDL
    
    #--- Ground Truth ---#
    sf_kern <- st_read(paste0("../Data/Raw/Kern/kern", y, "/kern", y, ".shp")) %>%
      st_as_sf() %>%
      st_transform(crs(cdl_ca_r)) %>%
      mutate(geoID = as.integer(as.factor(as.character(st_centroid(geometry)))))
    
    
# Identify fields with one commodity --------------------------------------
    df_kern <- sf_kern %>%
      st_drop_geometry() %>%
      data.table()
    
        df_summary <- df_kern[,
                          .(
                            acre = unique(ACRES),
                            no.unique_comm = length(unique(COMM)),
                            no.pmt_site = length(unique(PMT_SITE))
                          ),
                          by = .(geoID)
    ]
    
    # df_summary[no.unique_comm>1]
    # df_summary[, .(.N), by=.(no.pmt_site)][, .(no.pmt_site, percent=round(N/sum(N),digits = 2))]
    # df_summary[, .(m.acre=mean(acre)), by=.(no.pmt_site)][order(no.pmt_site)]
    # df_summary[, .(m.acre=mean(acre)), by=.(no.unique_comm)]
    
    geoID_in <- df_summary[no.unique_comm == 1, geoID]
    sf_kern <- sf_kern %>% filter(geoID %in% geoID_in)
    
    
    
# mask --------------------------------------------------------------------
    
      df <- sf_kern %>%
      mutate(cdl = map(geoID, function(x) {
        print(x)
        library(raster)
        p <- sf_kern[sf_kern$geoID == x, "geometry"]
        mask(crop(cdl_ca_r, p), st_zm(p))
      }))
    
    saveRDS(df, file.name.out)
  }
)
