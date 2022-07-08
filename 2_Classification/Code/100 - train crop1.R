#---------------[   Purpose    ]--------------------
# Train classifier for crop1

df <- readRDS("../Data/Train/RandomForest/LandIQ/df_train.Rds")
df <- df[is_GT==T, !c("UniqueID",  "County","is_GT"), with = F]
df <- na.omit(df)

fml <- "Crop ~ m1"

rf_crop1 <- ranger(fml,
                   data = df,
                   num.trees = 300,
                   seed = 123,
                   num.threads = 15, 
                   importance = 'impurity',
                   probability = T)

save(rf_crop1, file = "RF Result/rf_crop1.Rdata")

