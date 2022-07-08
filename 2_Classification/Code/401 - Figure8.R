
# plot accuracy --------------------------------------------------------------------
library(plyr)
df_pred[, ref := mapvalues(COMM, names(crop_landIQ.kern), crop_landIQ.kern)]

crop_order <- df_pred[ref %in% crop_landIQ.kern, .N, ref][order(-N)]
crop_order <- as.character(crop_order$ref)

df_plot <- rbind(
  df_pred[crop2 %in% crop_landIQ.kern, .N, .(crop = crop2, is_correct = crop2 == ref, year)][, .(type = "ua", is_correct, value = N / sum(N)), .(crop, year)][is_correct == T],
  df_pred[ref %in% crop_landIQ.kern, .N, .(crop = ref, is_correct = crop2 == ref, year)][, .(type = "pa", is_correct, value = N / sum(N)), .(crop, year)][is_correct == T]
) %>% unique()
df_plot$year <- as.character(df_plot$year) %>% as.numeric()
df_plot[, crop := factor(crop, levels = crop_order)]


df_plot %>%
  ggplot() +
  geom_line(aes(x = year, y = value, color = type)) +
  scale_x_continuous(breaks = seq(2007, 2020, 3)) +
  facet_wrap(~crop) +
  labs(x = "Year", y = "Accuracy") +
  theme_classic()

ggsave("../Figure/kern_acc.png", width = 8, height = 6)
