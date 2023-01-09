rm(list=ls())
library(renv)
library(tidymodels)
library(tidyverse)
library(data.table)
library(ranger)
library(DMwR)
library(vip)
library(gt)
library("rmarkdown")


source("R/functions.R")
#snapshot()
#_____________________Data wrangling
combined_wrangling()

#load cleaned data
df <- fread("data/clean/cleaned_df.csv") %>% na.omit() 
df$serious_fatal <- as.factor(df$serious_fatal)

#___________Re balancing data with SMOTE
df_rebalanced <- SMOTE(serious_fatal ~ ., data=df, perc.over = 65, perc.under = 800) 
nrow(df_rebalanced)
nrow(df_rebalanced %>% filter(serious_fatal ==1))
sum(as.integer(df_rebalanced$serious_fatal))/nrow(df_rebalanced)
#estimate model
estimate_model(data=df_rebalanced)

#____________Rendering Rmd files
render("README.Rmd", "github_document")
render("exploration.Rmd", "github_document")
render("Assignment_Report.Rmd", "github_document")

#session information
sessionInfo()


