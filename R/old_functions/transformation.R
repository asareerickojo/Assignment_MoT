# Title: Time series analysis of snouters

# Purpose : This script performs a time series analyses on 
#           snouter count data.
#           Data consists of counts of snouter species 
#           collected from 18 islands in the Hy-yi-yi 
#           archipelago between 1950 and 1957. 
#           For details of snouter biology see:
#           https://en.wikipedia.org/wiki/Rhinogradentia

# Project number: #007

# DataFile:'data/snouter_pop.txt'

# Date script created: Mon Dec 2 16:06:44 2019 -----------
# Date script last modified: Thu Dec 12 16:07:12 2019 ----

# package dependencies
#utils::install.packages("magrittr")
library(visdat)
library(tidyverse)
library(janitor)
library(fastDummies)
library(reshape2)

#' Sum of vector elements
#'
#' @description
#' `sum` returns the sum of all the values present in its arguments.
#' @details
#' This is a generic function: methods can be defined for it directly
#' or via the [Summary()] group generic. For this to work properly,
#' the arguments `...` should be unnamed, and dispatch is on the
#' first argument
#' @param
#' @return describes the output from the function. Briefly describe the type/shape of the output
#' @examples The description should provide a succinct summary of parameter type (e.g. a string, a numeric vector)

cleaned_data <- function(){
  join_df <- preprocessed_injured_persons %>% left_join(preprocessed_collisions, by = "collision_no")
  
  clean_df <- join_df  %>%
        mutate(
               age_65plus = if_else(involved_age >=65, 1,0),
               pedestrian_act_right = if_else(pedestrian_action == "CROSSING WITH RIGHT OF WAY" |pedestrian_action == "ON SIDEWALK OR SHOULDER" 
                                              | pedestrian_action == "PERSON GETTING ON/OFF SCHOOL BUS" |pedestrian_action == "CROSSING WITHOUT RIGHT OF WAY"
                                              | pedestrian_action == "PERSON GETTING ON/OFF SCHOOL BUS" |pedestrian_action == "CROSSING WITHOUT RIGHT OF WAY"
                                              | pedestrian_action == "CROSSING, PEDESTRIAN CROSSOVER", 1, 0),
               impaired_pedestrian_cond = if_else(pedestrian_condition == "ABILITY IMPAIRED, ALCOHOL OVER .80"
                                                  | pedestrian_condition == "HAD BEEN DRINKING"
                                                  | pedestrian_condition == "ABILITY IMPAIRED, DRUGS"
                                                  | pedestrian_condition == "ABILITY IMPAIRED, ALCOHOL", 1, 0),
               pedestrian_inattentive = if_else(pedestrian_condition == "INATTENTIVE", 1,0),
               collision_midblock = if_else(pedestrian_collision_type == "PEDESTRIAN HIT AT MID-BLOCK" , 1,0),
               collision_inter_wrow = if_else(pedestrian_collision_type == "VEHICLE IS GOING STRAIGHT THRU INTER.WHILE PED CROSS WITHOUT ROW"
                                              | pedestrian_collision_type == "VEHICLE TURNS LEFT WHILE PED CROSSES WITHOUT ROW AT INTER."
                                              | pedestrian_collision_type == "VEHICLE TURNS RIGHT WHILE PED CROSSES WITHOUT ROW AT INTER." ,1,0),
               collision_inter_row = if_else(pedestrian_collision_type == "VEHICLE IS GOING STRAIGHT THRU INTER.WHILE PED CROSS WITH ROW"
                                             | pedestrian_collision_type == "VEHICLE TURNS LEFT WHILE PED CROSSES WITH ROW AT INTER."
                                             | pedestrian_collision_type == "VEHICLE TURNS RIGHT WHILE PED CROSSES WITH ROW AT INTER."
                                             ,1,0),
               collision_transit = if_else(pedestrian_collision_type == "PEDESTRIAN INVOLVED IN A COLLISION WITH TRANSIT VEHICLE ANYWHERE ALONG ROADWAY", 1,0),
               weather_bad = if_else(visibility == "FOG, MIST, SMOKE, DUST" | visibility == "STRONG WIND" | visibility == "DRIFTING SNOW" | visibility == "FREEZING RAIN", 1,0),
               no_traffic_control = if_else(traffic_control == "NO CONTROL", 1,0),
               dark = if_else(light == "DARK, ARTIFICIAL" | light == "DARK" | light == "DUSK" | light == "DUSK, ARTIFICIAL" 
                                    |light == "DAWN, ARTIFICIAL" | light == "DAWN", 1,0)
        ) %>% 
        select(serious_fatal, latitude, longitude, age_65plus, pedestrian_act_right, impaired_pedestrian_cond,
               pedestrian_inattentive, collision_midblock, collision_inter_wrow,
               collision_inter_row, weather_bad,no_traffic_control, dark) %>%
        fwrite("data/clean/cleaned_df.csv")
}




