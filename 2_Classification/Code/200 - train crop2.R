#---------------[   Purpose    ]--------------------
# Train classifier for crop2

df <- readRDS("../Data/Train/RandomForest/LandIQ/df_train.Rds")
df <- df[is_GT==T, !c("UniqueID",  "County","is_GT"), with = F]
df <- na.omit(df)

y <- "Crop"
x <- names(df)[!names(df) %in% c("year","Crop")] %>% paste(collapse = " + ")
fml <- paste(y, "~", x) %>% formula()

rf_crop2 <- ranger(fml,
                   data = df,
                   num.trees = 300,
                   seed = 123,
                   mtry = 18,
                   num.threads = 15, 
                   importance = 'impurity',
                   probability = T)

save(rf_crop2, file = "RF Result/rf_crop2.Rdata")

