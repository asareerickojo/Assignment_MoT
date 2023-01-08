
library(tidymodels)

clean <- read_data(address = "data/clean/cleaned_df.csv")
clean$serious_fatal <- as_factor(clean$serious_fatal)
table(clean$serious_fatal) # highly imbalance

31584 / 120320


library(DMwR)
clean_smote <- SMOTE(serious_fatal ~ ., clean, perc.over = 800, perc.under = 200)
table(clean_smote$serious_fatal) # highly imbalance

# data splitting
set.seed(2000)
clean_split <- initial_split(clean, prop = 0.8)

# Create data frames for the two sets:
train_data <- training(clean_split)
test_data <- testing(clean_split)

# create recipe
clean_recipe <-
  recipe(serious_fatal ~ ., data = train_data) %>%
  step_normalize(latitude, longitude) %>%
  step_zv(all_predictors())

# fit a model specification
lr_mod <-
  logistic_reg() %>%
  set_engine("glm")

# create workflow
model_wflow <-
  workflow() %>%
  add_model(lr_mod) %>%
  add_recipe(clean_recipe)

# run model
model_fit <-
  model_wflow %>%
  fit(data = train_data)

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
