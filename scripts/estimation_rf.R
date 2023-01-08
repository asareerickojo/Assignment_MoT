source("R/functions.R")
library(tidymodels)
library(tidyverse)
library(data.table)
library(ranger)

clean <- fread("data/clean/cleaned_df.csv")
colnames(clean)
clean$serious_fatal <- as_factor(clean$serious_fatal)
table(clean$serious_fatal) # highly imbalance

# data splitting
set.seed(2000)
clean_split <- initial_split(clean, prop = 0.8)
train_data <- training(clean_split)
test_data <- testing(clean_split)

#Cross Validation
set.seed(1000)
cv_folds <- vfold_cv(
  data = train_data, v = 4
)
print(cv_folds)

#parallel processing: here we using single validation set so not impt and ranger provides such stuff
cores <- parallel::detectCores()
cores

#________________________________________fit a model specification
rf_mod <- 
  rand_forest(mtry = tune(), min_n = tune(), trees = 1000) %>% 
  set_engine("ranger", num.threads = cores) %>% 
  set_mode("classification")

# ______________________________________create recipe
rf_recipe <-
  recipe(serious_fatal ~ ., data = train_data) %>%
  step_normalize(latitude, longitude) %>%
  step_zv(all_predictors())

# create workflow
rf_workflow <- 
  workflow() %>% 
  add_model(rf_mod) %>% 
  add_recipe(rf_recipe)

#train and tune
rf_mod
extract_parameter_set_dials(rf_mod)

set.seed(345)
rf_res <- 
  rf_workflow %>% 
  tune_grid(val_set,
            grid = 25,
            control = control_grid(save_pred = TRUE),
            metrics = metric_set(roc_auc))

rf_res %>% 
  show_best(metric = "roc_auc")

autoplot(rf_res)

#select best model
rf_best <- 
  rf_res %>% 
  select_best(metric = "roc_auc")
rf_best

rf_res %>% 
  collect_predictions()

rf_auc <- 
  rf_res %>% 
  collect_predictions(parameters = rf_best) %>% 
  roc_curve(serious_fatal, .pred_1) %>% 
  mutate(model = "Random Forest")


#____compare lasso and rf
bind_rows(rf_auc, lr_auc) %>% 
  ggplot(aes(x = 1 - specificity, y = sensitivity, col = model)) + 
  geom_path(linewidth = 1.5, alpha = 0.8) +
  geom_abline(lty = 3) + 
  coord_equal() + 
  scale_color_viridis_d(option = "plasma", end = .6)

#last model: rf cool
last_rf_mod <- 
  rand_forest(mtry = 8, min_n = 7, trees = 1000) %>% 
  set_engine("ranger", num.threads = cores, importance = "impurity") %>%    #import purity insight into var importance
  set_mode("classification")

# the last workflow
last_rf_workflow <- 
  rf_workflow %>% 
  update_model(last_rf_mod)      #we have to update this info into our workflow

# the last fit
set.seed(345)
last_rf_fit <- 
  last_rf_workflow %>% 
  last_fit(clean_split)

last_rf_fit

last_rf_fit %>% 
  collect_metrics()







# fit a model specification
lr_mod <-
  logistic_reg() %>%
  set_engine("glm")

rf_spec <- 
  rand_forest(
    mtry = tune()
  ) %>%
  set_mode("regression") %>%
  set_engine("randomForest", importance = TRUE)

# run model
model_fit <-
  model_wflow %>%
  fit(data = train_data)

#cv
model_fit <-
  model_wflow %>%
  fit_resamples(resamples = cv_folds)


#tune rf in wflow set to cv_fold
doParallel::registerDoParallel(cores = 4)
car_wfs <- 
  reg_wfs %>%  
  workflow_map(
    seed = 67, 
    fn = "tune_grid",
    grid = 10, # params to pass to tune grid
    resamples = cv_folds
  )
doParallel::stopImplicitCluster()
car_wfs

### If there was no tuning that needed to take plate remove the fn and grid arguments
# car_wfs <- workflow_map(
#     reg_wfs,
#     "fit_resamples",
#     resamples = cv_folds,
#     seed = 67
#   )

#evaluate model
#single model
collect_metrics(car_lm)

#wflow set
autoplot(car_wfs)
collect_metrics(car_wfs)
rank_results(car_wfs, rank_metric = "rmse", select_best = TRUE)

#prediction on test data
#single

# pull out results
model_fit %>%
  pull_workflow_fit() %>%
  tidy()

# predict---here the recipe is applied to the test data
predict(model_fit, test_data)

# if we want actual probabilities
model_pred <-
  predict(model_fit, test_data, type = "prob") %>%
  bind_cols(test_data %>% select(serious_fatal))

head(model_pred)

# roc
model_pred %>%
  roc_curve(truth = serious_fatal, .pred_1) %>%
  autoplot()

model_pred %>%
  roc_auc(truth = serious_fatal, .pred_1)
