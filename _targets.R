# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("tibble"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
  tar_target(address
    name = data,
    command = tibble(x = rnorm(100), y = rnorm(100))
    #   format = "feather" # efficient storage of large data frames # nolint
  ),
  tar_target(
    name = model,
    command = coefficients(lm(y ~ x, data = data))
  )
)

tar_pipeline(
  tar_target(   #Check it out…about some data stuff
                clean,
                tidytuesdayR::tt_load(2020, week = 28)$coffee,
                cue = tar_cue("never")
  ),
  tar_target(clean_split, initial_split(clean, prop = 0.8)),
  tar_target(clean_train, training(clean_split)),
  tar_target(clean_test, testing(clean_split)),
  tar_target(clean_recipe, 
             recipe(serious_fatal ~ ., data = train_data)  %>% step_normalize(latitude, longitude) %>% step_zv(all_predictors()
             ),    #define the function
             tar_target(
               clean_model,
               logistic_reg() %>% set_engine("glm")
             ),
             tar_target(
               clean_workflow,
               workflow() %>% add_model(lr_mod) %>% add_recipe(clean_recipe)
             ),
             tar_target(
               clean_model_fit,
               clean_workflow %>% fit(data = clean_train)
             ),
             tar_target(
               clean_model_predict,
               predict(clean_model_fit, clean_test, type = "prob") %>% bind_cols(clean_test %>% select(serious_fatal)) 
             ),
             tar_target(
               metrics,
               clean_model_pred %>% roc_auc(truth = serious_fatal, .pred_1) 
             )
  )
)






