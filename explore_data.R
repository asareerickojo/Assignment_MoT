




clean1 <- clean %>% select(-c(weather_strongwind, weather_windyrain, snow_strongwind, collision_transit))
res <- cor(clean1, method = "pearson", use = "complete.obs")
cor_plot <- function(data) {
  res <- cor(data, method = "pearson", use = "complete.obs")
  plt <- melted_res <- melt(res) %>%
    ggplot(aes(x = Var1, y = Var2, fill = value)) +
    geom_tile() +
    scale_fill_gradientn(colors = hcl.colors(20, "RdYlGn")) +
    theme_bw()
  return(plt)
}
cor_plot(clean)
