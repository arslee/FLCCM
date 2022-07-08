#---------------[   Purpose    ]--------------------
#
# Calculate accuracy using kern county crop maps
#


# merge df_train and df_rf_kern -------------------------------------------
#--- this is for making categorical variables consistent between datasets---#

# ....df_train....#
df <- readRDS("../Data/Train/RandomForest/LandIQ/df_train.Rds")
df <- df[is_GT == T, !c("UniqueID", "County", "is_GT"), with = F]
df <- na.omit(df)
setnames(df, "Acres", "acres")

# ....df_kern....#
df_kern <- readRDS("../Data/Train/MergedMetrics/Kern/df_rf_kern.Rds")
df_kern[COMM == "TANGERINE/", COMM := "TANGERINE"]
df_kern <- na.omit(df_kern)
df_kern[, !c("PMT_SITE", "COMM"), with = F]

# ....merge data....#
df_kern_LandIQ <- rbind(df, df_kern, fill = T)
df_kern_LandIQ <- df_kern_LandIQ %>% mutate_if(is.character, as.factor)
df_kern_LandIQ


# run random forests ------------------------------------------------------
names(df_kern_LandIQ)
y <- "Crop"
x <- names(df_kern_LandIQ)[!names(df_kern_LandIQ) %in% c("Crop", "year", "PMT_SITE", "COMM")] %>% paste(collapse = " + ")
fml <- paste(y, "~", x) %>% formula()

df_train <- df_kern_LandIQ[is.na(COMM)]
df_pred <- df_kern_LandIQ[!is.na(COMM)]

rf_crop2_kern <- ranger(fml,
  data = df_train,
  num.trees = 300,
  seed = 123,
  mtry = 18,
  num.threads = 15,
  importance = "impurity",
  probability = T
)
save(rf_crop2_kern, file = "RF Result/rf_crop2_kern.Rdata")




# prediction --------------------------------------------------------------


load("RF Result/rf_crop2_kern.Rdata")
prob2 <- predictions(predict(rf_crop2_kern, data = df_pred))
df_pred$crop2 <- apply(prob2, 1, function(x) colnames(prob2)[which.max(x)])
df_pred$prob2 <- apply(prob2, 1, function(x) max(x))


crop_landIQ.kern <- c(
  "ALMOND" = "Almonds",
  "GRAPE" = "Grapes",
  "ALFALFA" = "Alfalfa and Alfalfa Mixtures",
  "PISTACHIO" = "Pistachios",
  # "UNCULTIVATED AG" = "Idle",
  "COTTON" = "Cotton",
  # "WHEAT" = "Wheat",
  # "WALNUT"="Walnuts",
  # "BEAN"="Beans (Dry)",
  # "LETTUCE"="LettuceLeafy Greens",
  # "CORN"="Corn Sorghum and Sudan",
  # "SUDANGRASS"="Sudan",
  # "APPLE"="Apple",
  "PEACH" = "Citrus",
  "TANGERINE" = "Citrus",
  "ORANGE" = "Citrus",
  "LEMON" = "Citrus"
  # "TOMATO"="Tomatoes",
  # "GARLIC"="Onions and Garlic",
  # "CHERRY"="Cherries",
  # "PASTURELAND"="Mixed Pasture",
  # "RANGELAND"="Mixed Pasture"
)


