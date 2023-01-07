
library(tidymodels)

#data splitting
set.seed(2000)

clean <- read_csv("data/clean/cleaned_df.csv") 
clean$serious_fatal <- as.factor(clean$serious_fatal)

split_data <- initial_split(clean, prop = 0.8)

# Create data frames for the two sets:
train_df <- training(split_data)
test_df  <- testing(split_data)

#create recipe and roles
pedestrian_recipe <- 
  recipe(serious_fatal ~ ., data = train_df) %>%
  step_normalize(latitude, longitude) %>%
  step_zv(all_predictors())

#build model with parsnip package
lr_mod <- 
  logistic_reg() %>% 
  set_engine("glm")

#use workflow from tidymodel to bundle parsnip model with recipe
pedestrian_workflow <- 
  workflow() %>% 
  add_model(lr_mod) %>% 
  add_recipe(pedestrian_recipe)

#pedestrian_workflow

#function to prepare recipe and train model
model_fit <- 
  pedestrian_workflow %>% 
  fit(data = train_df)

#pullout estimated model and recipe with pull_workflow_fit() and pull_workflow_prepped_recipe()
model_fit %>%
  extract_fit_parsnip() %>% 
  tidy()

#predictions
model_pred <- predict(model_fit, test_df, type = "prob") %>%
  bind_cols(test_df %>% select(serious_fatal))

model_pred

#area under curve (ROC) with yardstick package
model_pred %>% 
  roc_curve(truth = serious_fatal, .pred_1) %>% 
  autoplot()

#or estimate area under curve
model_pred %>% 
  roc_auc(truth = serious_fatal , .pred_1)
