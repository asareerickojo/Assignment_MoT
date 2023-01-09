rm(list=ls())
library(tidymodels)
library(tidyverse)
library(data.table)
library(ranger)
library(DMwR)
library(vip)
library(gt)


source("R/functions.R")

#_____________________Data wrangling
combined_wrangling()

#load cleaned data
df <- fread("data/clean/cleaned_df.csv") %>% na.omit()
df$serious_fatal <- as.factor(df$serious_fatal)

#___________Re balancing data with SMOTE
df_rebalanced <- SMOTE(serious_fatal ~ ., data=df, perc.over = 65, perc.under = 800) 

#estimate model
estimate_model(data=df_rebalanced)

#session information
sessionInfo()


