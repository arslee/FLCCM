#---------------[   Purpose    ]--------------------
#
# plot acreage estimates from multiple sources
#
#---------------[   Process    ]--------------------
# prep data ---------------------------------------------------------------
#----@ input: "../Data/Misc/CDFA_vs_NASS.csv" @----
df_cdfa <- fread("../Data/Misc/CDFA_vs_NASS.csv") %>%
  .[CA_variable == "Harvested_Acres" & Year >= 2007, .(acre = value, year = Year, crop = CA_commodity, type = source)]

cdfa_to_lcm <- c(
  "Table Grapes" = "Grapes",
  "Wine Grapes" = "Grapes",
  "Lettuce" = "LettuceLeafy Greens",
  "Alfalfa Hay" = "Alfalfa and Alfalfa Mixtures",
  "Pr. Tomatoes" = "Tomatoes"
)
df_cdfa[, crop := mapvalues(crop, names(cdfa_to_lcm), cdfa_to_lcm)]
df_cdfa <- df_cdfa[, .(acre = sum(acre)), .(year, crop, type)]

#----@ input: "Release/CropMap2007_2021.csv" @----
df <- fread("Release/CropMap2007_2021.csv")
df_acr <- rbind(
  df[, .(acre = sum(acres, na.rm = T), type = "crop1"), .(year, crop = crop1)],
  df[, .(acre = sum(acres, na.rm = T), type = "crop2"), .(year, crop = crop2)],
  df[, .(acre = sum(acres, na.rm = T), type = "crop3"), .(year, crop = crop3)],
  df[, .(acre = sum(acres, na.rm = T), type = "LandIQ"), .(year, crop = cropLIQ)]
)


df_acr <- df_acr[str_detect(crop, "Alfalfa|Almonds|Grapes|Lettuce|Pistachios|^Rice|Strawberries|Tomatoes|Walnuts")]



# plot --------------------------------------------------------------------
df_plot <- rbind(df_acr, df_cdfa, fill = T) %>%
  .[crop != "Oranges"]
df_plot[, acre := acre / 1000]
df_plot$type %>% unique()
df_plot[, type := factor(type, levels = c("crop1", "crop2", "crop3", "LandIQ", "NASS", "CDFA", "Almond Board"))]
df_plot[type != "LandIQ"] %>%
  ggplot() +
  geom_line(aes(year, acre, color = type)) +
  geom_point(aes(year, acre, color = type)) +
  geom_point(data = df_plot[type == "LandIQ"], aes(year, acre, shape = type)) +
  scale_shape_manual(values = 2) +
  facet_wrap(~crop, scales = "free_y") +
  theme_classic() +
  labs(x = "Year", y = "Thousand Acres") +
  theme(legend.title = element_blank())

#----@ plot: ../Figure/acreage.png @----
ggsave("../Figure/acreage.png", width = 10, height = 5)
