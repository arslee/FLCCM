
#---------------[   Purpose    ]--------------------
#
# plot example grape fields
#
#---------------[   Process    ]--------------------

#--- prep data ---#
load("../Data/Train/MaskedCDL/LandIQ/df_cdl_LandIQ_combined_2016.RData")

temp <- df_2016 %>% 
  filter(Crop2016=="Grapes" & Acres>100)

#--- plot ---#

png("../Figure/grape1.png")
plot(temp[1,]$cdl[[1]])
dev.off()
png("../Figure/grape2.png")
plot(temp[2,]$cdl[[1]])
dev.off()
png("../Figure/grape3.png")
plot(temp[5,]$cdl[[1]])
dev.off()
png("../Figure/grape4.png")
plot(temp[10,]$cdl[[1]])
dev.off()
