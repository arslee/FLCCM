
#---------------[   Purpose    ]--------------------
#
# plot average total acreage from land IQ 
#
#---------------[   Process    ]--------------------

df <- fread("Release/CropMap2007_2021.csv")[year %in% c(2014, 2016, 2018) & cropLIQ != ""]
crop_ins <- df[, sum(acres), crop3][order(-V1)][1:20]$crop3 %>% rev()
yrs <- df$year %>%
  unique() %>%
  length()
df_plot <- rbind(
  df[, .(type = "crop1", v = sum(acres / 1000) / 3), .(crop = crop1)],
  df[, .(type = "crop2", v = sum(acres / 1000) / 3), .(crop = crop2)],
  df[, .(type = "crop3", v = sum(acres / 1000) / 3), .(crop = crop3)],
  df[, .(type = "LandIQ", v = sum(acres / 1000) / 3), .(crop = cropLIQ)]
)
df_plot[!crop %in% crop_ins, crop := "Others"]
df_plot <- df_plot[, .(v = sum(v)), .(crop, type)]

df_plot[, crop := factor(crop, levels = c("Others", crop_ins))]
df_plot %>%
  ggplot() +
  geom_bar(aes(y = crop, x = v, fill = type), position = "dodge", stat = "identity") +
  theme_minimal() +
  labs(x = "Thousand Acres", y = "") +
  ggtitle("") +
  theme(legend.title = element_blank())


ggsave("../Figure/avg_tot_acr.png", width = 8, height = 5)
