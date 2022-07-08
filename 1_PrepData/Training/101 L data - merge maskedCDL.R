############## Documentation ###################
#==========[       Purpose         ]==========# 
# Since raster CDL data were created through parallel computing by county-crop, merge all county-crop by year 
#==========[       Inputs          ]==========#                   
# Raster data for county-crop pairs in 2014, 2016, and 2018
#==========[       Process         ]==========#
# 
#==========[       Outputs         ]==========#

text2014 <- '
files <- list.files("../Data/Train/MaskedCDL/LandIQ/2014", full.names = T)
df_2014 <- future_map(.progress=T,files, readRDS) %>% bind_rows()
save(df_2014, file = "../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2014.RData")'

eval(parse(text=text2014))
eval(parse(text=gsub("2014","2016",text2014)))
eval(parse(text=gsub("2014","2018",text2014)))
