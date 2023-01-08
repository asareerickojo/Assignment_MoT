


ko <- fread("data/clean/cleaned_df.csv")
print(ko)
ko$serious_fatal <- as.factor(ko$serious_fatal)
class(ko$serious_fatal)
str(ko)
head(ko)
ko$ole <- as.factor(ko$dark)
str(ko)
res <- cor(clean, method = "pearson", use = "complete.obs")
print(res)
cor_plot <- function(data){
  res <- cor(data, method = "pearson", use = "complete.obs")
  plt <- melted_res <- melt(res) %>%
    ggplot(aes(x=Var1, y=Var2, fill=value)) + 
    geom_tile() + 
    scale_fill_gradientn(colors = hcl.colors(20, "RdYlGn")) +
    theme_bw()
  return(plt)
}
cor_plot(clean)


df = data.frame("LOC_ID" = c(1,2,3,4),
                "STRS" = c("a","b","c","d"),
                "UPC_CDE" = c(813,814,815,816))

df$LOC_ID = as.factor(df$LOC_ID)
df$UPC_CDE = as.factor(df$UPC_CDE)

str(df)
print(df)

library(DMwR)
clean_smote <- SMOTE(serious_fatal ~ ., clean, perc.over = 800, perc.under = 200)
table(clean_smote$serious_fatal) # highly imbalance

