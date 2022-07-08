############## Documentation ##################
#==========[       Purpose         ]==========# 
# construct base metrics by county and year
#==========[       Inputs          ]==========#                   

#--- county and year list ---#
# county list
landIQ <- readRDS("../Data/Prediction/MaskedCDL/AfterMerge/df_maskedCDL_2007.Rds")
cty_list <- landIQ$COUNTY %>% unique()
rm(landIQ)

# year list
yrs <- parse_number(list.files("../Data/Prediction/MaskedCDL/AfterMerge/"))

#==========[       Process         ]==========#
# Use masked CDL for fields from  "../Data/Prediction/MaskedCDL/AfterMerge/df_maskedCDL_",yr,".Rds"



dir.create("../Data/Prediction/BaseMetrics/BeforeMerge",recursive = T)
for(yr in 2007:2021){
  
  print(yr)
  landIQ <- readRDS(paste0("../Data/Prediction/MaskedCDL/AfterMerge/df_maskedCDL_",yr,".Rds"))
  
  cty_exist <- gsub(".*_|.Rds" ,"",
                    grep(yr,gsub(".Rds" ,"",list.files(paste0("../Data/Prediction/BaseMetrics/BeforeMerge"))),value=T)
  )
  cty_to_work <- cty_list[!cty_list %in% cty_exist]
  
  options('future.globals.maxSize' = 40000*1042^2)
  plan(multisession, workers=10)
  
  year <- yr 
  
  future_map(cty_to_work, function(county){
    library(data.table)
    library(landscapemetrics)
    #....export data to the global folder....#
    
    path_data_out <- paste0("../Data/Prediction/BaseMetrics/BeforeMerge/df_base_",year,"_",county,".Rds")
    
    #....compute metrics....#
    
    df <- landIQ %>% dplyr::filter(COUNTY==county) %>%
      mutate(pland = map(cdl,func$landscape[["lsm_c_pland"]])) %>%
      mutate(m1    = map_chr(pland,                           ~ .x[1,class])) %>%
      mutate(m2    = map_chr(pland, function(x){ifelse(nrow(x)>1,x[2,class],0L)})) %>%
      mutate(m3    = map_chr(pland, function(x){ifelse(nrow(x)>2,x[3,class],0L)})) %>%
      mutate(m4    = map_chr(pland, function(x){ifelse(nrow(x)>3,x[4,class],0L)})) %>%
      mutate(m5    = map_chr(pland, function(x){ifelse(nrow(x)>4,x[5,class],0L)})) %>%
      mutate(s1    = map_dbl(pland, function(x){ifelse(!is.nan(x[1,value]),                 x[1,value],0)})) %>%
      mutate(s2    = map_dbl(pland, function(x){ifelse(!is.nan(x[1,value]) & nrow(x)>1,     x[2,value],0)})) %>%
      mutate(s3    = map_dbl(pland, function(x){ifelse(!is.nan(x[1,value]) & nrow(x)>2,     x[3,value],0)})) %>%
      mutate(s4    = map_dbl(pland, function(x){ifelse(!is.nan(x[1,value]) & nrow(x)>3,     x[4,value],0)})) %>%
      mutate(s5    = map_dbl(pland, function(x){ifelse(!is.nan(x[1,value]) & nrow(x)>4,     x[5,value],0)})) 
    
    #....select columns....#
    cols <-
      c("UniqueID",
        "ACRES",
        "m1",  "m2",  "m3",  "m4",  "m5",
        "s1" , "s2",  "s3",  "s4",  "s5"
      )
    
    #....drop geometry and convert column class....#
    df_rf <- st_drop_geometry(df)[,cols] %>%
      mutate_if(is.character,as.factor)
    
    
    #....export data....#
    saveRDS(df_rf, path_data_out)
  })
}


#==========[       Outputs         ]==========#
#
#==========[        Notes          ]==========#


