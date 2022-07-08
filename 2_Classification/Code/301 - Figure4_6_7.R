
#----@ output: acc_crop123.png @----
df_plot <- rbind(
  df_rf[is_test == T, .N, .(is_correct = ref == crop1, ref)][, .(is_correct, prediction = "crop1", type = "PA", acc = N / sum(N)), .(crop = ref)][is_correct == T],
  df_rf[is_test == T, .N, .(is_correct = ref == crop1, crop1)][, .(is_correct, prediction = "crop1", type = "UA", acc = N / sum(N)), .(crop = crop1)][is_correct == T],
  df_rf[is_test == T, .N, .(is_correct = ref == crop2, ref)][, .(is_correct, prediction = "crop2", type = "PA", acc = N / sum(N)), .(crop = ref)][is_correct == T],
  df_rf[is_test == T, .N, .(is_correct = ref == crop2, crop2)][, .(is_correct, prediction = "crop2", type = "UA", acc = N / sum(N)), .(crop = crop2)][is_correct == T],
  df_rf[is_test == T, .N, .(is_correct = ref == crop3, ref)][, .(is_correct, prediction = "crop3", type = "PA", acc = N / sum(N)), .(crop = ref)][is_correct == T],
  df_rf[is_test == T, .N, .(is_correct = ref == crop3, crop3)][, .(is_correct, prediction = "crop3", type = "UA", acc = N / sum(N)), .(crop = crop3)][is_correct == T]
)[, -"is_correct"]

df_plot[, n := .N, crop] %>%
  ggplot(aes(x = type, y = acc, fill = prediction)) +
  geom_bar(aes(), position = "dodge", stat = "identity") +
  geom_text(aes(label = round(acc, 2), y = acc),
    position = position_dodge(width = 1),
    vjust = .5,
    color = "black",
    size = 5
  ) +
  facet_wrap(~crop, ncol = 3) +
  theme_classic() +
  labs(x = "accuracy type", y = "accuracy") +
  theme(
    axis.text.x = element_text(size = 15),
    axis.text.y = element_text(size = 15),
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20),
    strip.text.x = element_text(size = 15)
  )


ggsave("../Figure/acc_crop123.png", width = 15, height = 18)



#----@ output: acc_year_acre.png @----
crops_in <- c("Almonds", "Pistachios", "Walnuts", "Idle", "Grapes", "Citrus", "Alfalfa and Alfalfa Mixtures")
df_plot <- rbind(
  df_acc1[crop %in% crops_in] %>%
    pivot_longer(-c(crop, acr_gr_15, before_2018)),
  df_acc2[crop %in% crops_in] %>%
    pivot_longer(-c(crop, acr_gr_15, before_2018)),
  df_acc3[crop %in% crops_in] %>%
    pivot_longer(-c(crop, acr_gr_15, before_2018))
)

df_plot %>%
  mutate(
    acr_gr_15 = factor(acr_gr_15, levels = c(F, T), labels = c("acres<15", "acres>=15")),
    before_2018 = factor(before_2018, levels = c(T, F), labels = c("yr < 2017", "yr > 2017"))
  ) %>%
  mutate(
    type = str_sub(name, 1, 2), prediction = paste0("crop", str_sub(name, 3, 3)),
    facet = paste0(crop, " / ", toupper(type), " / ", before_2018)
  ) %>%
  ggplot(aes(x = prediction, y = value, group = acr_gr_15)) +
  geom_bar(aes(fill = acr_gr_15), stat = "identity", position = position_dodge(width = 1)) +
  geom_text(aes(label = round(value, digits = 2)), position = position_dodge(width = 1)) +
  facet_wrap(~facet, ncol = 4) +
  theme_classic() +
  theme(legend.title = element_blank()) +
  labs(y = "accuracy")
ggsave("../Figure/acc_year_acre.png", width = 12, height = 8)




#----@ output: persistence.png @----
#--- For crop2 ---#
df_plot <- df[mode %in% c("Almonds", "Grapes", "Walnuts", "Pistachios", "Idle")][, .(UniqueID, mode, N_mode)] %>%
  unique() %>%
  drop_na()
df_plot[, share := .N, .(N_mode, mode)]
df_plot <- df_plot[, .(UniqueID, mode, N_mode, share)] %>%
  unique() %>%
  drop_na()
df_plot$PostProcessing <- F
#--- For crop3 ---#
df_plot1 <- df_rf[mode %in% c("Almonds", "Grapes", "Walnuts", "Pistachios", "Idle")]
df_plot1[, N_mode := sum(mode == crop3), UniqueID]
df_plot1 <- df_plot1[, .(UniqueID, mode, N_mode)] %>%
  unique() %>%
  drop_na()
df_plot1[, share := .N, .(N_mode, mode)]
df_plot1$PostProcessing <- T

df_plot <- rbind(df_plot, df_plot1)[, share := share / 1000]

plot1 <- df_plot %>%
  mutate(mode = paste0("(field-level) Mode: ", mode)) %>%
  ggplot(aes(
    x = N_mode,
    y = share, fill = factor(PostProcessing, levels = c(F, T), labels = c(
      "crop2",
      "crop3"
    ))
  )) +
  geom_bar(stat = "identity", position = position_dodge(width = 1)) +
  theme_classic() +
  facet_wrap(~mode, scale = "free_y") +
  labs(y = "Number of (1,000) Fields", x = "Number of Years (modal crop = prediction)", fill = "Prediction")

ggsave(plot1, filename = "../Figure/persistence_rv.png", width = 10, height = 5)
