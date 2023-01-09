
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Predicting the Severity of Pedestrian Collisions in the City of Toronto

## Description

The project investigates the drivers that explain the probability that a
pedestrian collision will result in major injury or fatality in the City
of Toronto. Understanding theses factors could help policy makers design
the appropriate road safety campaigns, road safety infrastructure and
similar activities that could contribute to the success of the City of
Toronto’s Vision Zero Road Safety Plan.

## Methods

Random Forest algorithm was implemented through the “Ranger package” in
R to solve this classification problem. The Random Forest model
parameters mtry (the number of variables randomly selected as candidates
in each split) and min_n (the minimum number of data points in each node
required for it to be split further) were hyper-tuned using the grid
search method in Ranger. The processed data had 1677 rows and 12
variables (excluding the binary outcome variable). The data was
imbalanced since the class pedestrian collision resulting in mojor
injury or fatality accounted for 11% of the rows in the outcome variable
(serious_fatality). The imbalanced problem was solved with the SMOTE
algorithm in the “DMwR” R package. This increased the representation of
the minoriy class to 24%.

## Results

Figure 1. below shows the factors that are key to explaining the
likelihood of a pedestrian collision resulting in a serious injury or
death.

<div class="figure">

<img src="results/plots/variable_importance.png" alt="Variable Importance Plot" width="80%" height="50%" />
<p class="caption">
Variable Importance Plot
</p>

</div>

## Installation

The project has been designed to ensure reproducibilty through the Renv
package in R. You can replicate the results through the following
options:

1.  In the root folder of this repository, you can run the run.R script
    to automatically implement the data wrangling, SMOTE analysis, and
    model estimation. You can also modify the custom functions in
    functions.R script (R/functions.R) to change the results of the
    study.  
2.  if you are using Mac you can run the run.R script: i) in the command
    line type cd working directory, ii). run the command “Rscript
    run.R”. If you do not have pandoc please install with “brew install
    pandoc”.  
3.  if you have Windows install pandoc through the command “winget
    install pandoc” and run the run.R script.

In the renv.lock file in the root folder, you will find important
information on all the packages I used for this project.

## Future Work

In the future, given more time and resources, I would collect more data
which will be a plausible best solution to the imbalance data problem
than using a second-best synthetic resampling procedure like SMOTE.
Also, I will investigate the poor model performance further. Some of the
actions I may consider undertaking are:

1.  comparing several classification machine learning algorithms.
2.  explore more hyper-parameter tuning of algorithms parameter space.
3.  conduct more feature engineering and maybe use principal component
    analysis to combine several variables.

## Credits

## License

This project was conducted for the Ministry of Transportation as part of
a job interviewing process. Access is retricted only to that institution
and the affiliations they will authorize to modify the project.
