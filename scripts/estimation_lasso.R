source("R/functions.R")
library(tidymodels)
library(tidyverse)
library(data.table)
library(glmnet)

clean <- fread("data/clean/cleaned_df.csv") %>% na.omit()
clean$serious_fatal <- as.factor(clean$serious_fatal)
colnames(clean)
clean$serious_fatal <- as_factor(clean$serious_fatal)
table(clean$serious_fatal) # highly imbalance

#___________________Data splitting
set.seed(2000)
clean_split <- initial_split(clean, prop = 0.8)
train_data <- training(clean_split)
test_data <- testing(clean_split)

#___________________Validation set
set.seed(1000)
val_set <- validation_split(train_data, 
                            strata = serious_fatal, 
                            prop = 0.80)

#___________________fit a model specification
#lr_mod <-
  #logistic_reg() %>%
  #set_engine("glm")

lr_mod <- 
  logistic_reg(penalty = tune(), mixture = 1) %>%     # 1 means irrelevant predictors removed for a simplier model
  set_engine("glmnet")


# __________________Create recipe
clean_recipe <-
  recipe(serious_fatal ~ ., data = train_data) %>%
  step_normalize(latitude, longitude) %>%
  step_zv(all_predictors())

# __________________create workflow
model_wflow <-
  workflow() %>%
  add_model(lr_mod) %>%
  add_recipe(clean_recipe)

#create grid for tuning: could have used dials::grid_regular based on two hyperparam. for just one use one column tibble with 30 candidate values
lr_reg_grid <- tibble(penalty = 10^seq(-4, -1, length.out = 30))

#tune and train model
lr_res <- 
  model_wflow%>% 
  tune_grid(val_set,                                          #tune grid to train 30 penalised models
            grid = lr_reg_grid,
            control = control_grid(save_pred = TRUE),         #predictions on validation set saved via control grid so diagnostic info can be avilabke
            metrics = metric_set(roc_auc))                    #use roc_auc

#vizualise
lr_plot <- 
  lr_res %>% 
  collect_metrics() %>% 
  ggplot(aes(x = penalty, y = mean)) + 
  geom_point() + 
  geom_line() + 
  ylab("Area under the ROC Curve") +
  scale_x_log10(labels = scales::label_number())
lr_plot


#top models
top_models <-
  lr_res %>% 
  show_best("roc_auc", n = 15) %>% 
  arrange(penalty) 
top_models

lr_best <- 
  lr_res %>% 
  collect_metrics() %>% 
  arrange(penalty) %>% 
  slice(12)
lr_best

lr_auc <- 
  lr_res %>% 
  collect_predictions(parameters = lr_best) %>% 
  roc_curve(serious_fatal, .pred_1) %>% 
  mutate(model = "Logistic Regression")

autoplot(lr_auc)

lr_res %>% 
  collect_predictions(parameters = lr_best) %>% 
  roc_auc(truth = serious_fatal, .pred_1)
