#---------------[   Purpose    ]--------------------
#
# plot landIQ 2016 & CDL2016
#
#---------------[   Process    ]--------------------

# LandIQ ------------------------------------------------------------------
#--- prep data ---#
landIQ <- st_read("../Data/Raw/LandIQ/2016/i15_Crop_Mapping_2016.shp")

cb <- tigris::counties(cb = T) %>%
  filter(STATE_NAME == "California") %>%
  st_transform(crs(landIQ))

landIQ$Crop2016 %>%
  unique() %>%
  length()

#--- plot ---#
tmap_options(max.categories = 47)
tm <- tm_shape(cb) +
  tm_borders() +
  tm_shape(landIQ) +
  tm_polygons("Crop2016", palette = brewer.accent(47), lwd = 0) +
  tm_layout(legend.outside = T)
tmap_save(tm, "../Figure/landIQ2016.png", height = 9, width = 9)


# CDL ---------------------------------------------------------------------
r <- raster("../Data/Raw/CDL/CDL_2016_06/CDL_2016_06.tif")
png(file="../Figure/cdl2016.png")
plot(r)
dev.off()
