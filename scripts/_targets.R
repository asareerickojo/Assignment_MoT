# Data Wrangling functions

# Purpose : This script produces custom functions wrapped around existing R functions that are used for current project's
#           data wrangling steps.

# Date script created: Wednesday January 4 2023
# Date script last modified: Saturday January 6 2023


# Load packages required to define the pipeline:
library(targets)
#data
library(data.table)
clean <- fread("data/clean/cleaned_df.csv")

tar_script({
      # Set target options:
      tar_option_set(
        packages = c("tidyverse", "tidymodels", "data.table") # packages that your targets need to run
        #error = "null"
      )

  list(
      tar_target(clean_split, initial_split(clean, prop = 0.8)),
      tar_target(clean_train, training(clean_split)),
      tar_target(clean_test, testing(clean_split)),
      tar_target(clean_recipe, 
                 recipe(serious_fatal ~ ., data = train_data)  %>% 
                   step_normalize(latitude, longitude) %>% 
                   step_zv(all_predictors() 
                 ),    #define the function
      tar_target(clean_model,
                   logistic_reg() %>% set_engine("glm")),
      tar_target(clean_workflow,
                   workflow() %>% add_model(lr_mod) %>% add_recipe(clean_recipe)
                 ),
      tar_target(clean_model_fit,
                   clean_workflow %>% fit(data = clean_train)
                 ),
      tar_target(clean_model_predict,
                   predict(clean_model_fit, clean_test, type = "prob") %>% bind_cols(clean_test %>% select(serious_fatal))
                 ),
     tar_target(
                   metrics,
                   clean_model_pred %>% roc_auc(truth = serious_fatal, .pred_1) 
                 )
      )
    )

})




