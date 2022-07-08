############## Documentation ##################
#==========[       Purpose         ]==========# 
# merge masked CDL by year
#==========[       Inputs          ]==========#                   
files.all.years <- list.files("../Data/Prediction/MaskedCDL/BeforeMerge",full.names = T)
years <- gsub("../Data/Prediction/MaskedCDL/BeforeMerge/df_maskedCDL_LandIQ2018_","",files.all.years) %>% str_sub(1,4) %>% unique()
files.by.year <- map(paste0(2018,"_",years),function(x)grep(x,files.all.years,value=T))

names(files.by.year) <- years

#==========[       Process         ]==========#
options('future.globals.maxSize' = 60000*1042^2)
plan(multisession, workers=12)
lapply(names(years), function(yr){
df <- lapply(files.by.year[[yr]],
                   readRDS) %>% bind_rows() %>% 
    dplyr::select(UniqueID, COUNTY,ACRES,cdl)
 
  saveRDS(df, file=paste0("../Data/Prediction/MaskedCDL/AfterMerge/","df_maskedCDL_",yr,".Rds"))
  rm(df)
})


#==========[       Outputs         ]==========#
#
#==========[        Notes          ]==========#


  
