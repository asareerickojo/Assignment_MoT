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
library(data.table)

#checking for duplicated rows
check_duplicates <- function(data){
  df <- data %>% get_dupes(collision_no, accdate) %>% filter(dupe_count > 1)  # Are there are duplicate?
  if(nrow(df) > 1){
    setDT(data)[!duplicated(rleid(data$collision_no))]      #keep only 1 duplicate
  }else{
    data
  }
}


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

#Table of missing and NA values
missing_empty_information <- function(data){
  df1 <- data %>%
    summarise_all(~sum(.=="")) %>% 
    t() %>%
    as.data.frame() %>% 
    rownames_to_column() %>%
    rename(variable = rowname, sum_empty = V1) 
  
  df2 <- data %>%
    summarise_all(~sum(is.na(.))) %>% 
    t() %>%
    as.data.frame() %>% 
    rownames_to_column() %>%
    rename(variable = rowname, sum_missing = V1) %>%
    inner_join(df1, by = "variable")
  return(df2)
}
  
#plot missing and empty
missing_empty_plot <- function(data){
  df <- missing_empty_information(data) 
  p1 <- df %>% ggplot(aes(variable, sum_empty, fill = variable)) +
    geom_bar(stat = "identity") +
    labs(title = "Number of missing information among variables",
         x = "Variable",
         y = "Number of Empty Values") +
    theme(axis.text.x = element_text(size = 10, angle = 90, hjust = 1),
          axis.text = element_text(size = 10),
          axis.title = element_text(size = 10), 
          legend.title = element_text(size = 10)) +
    theme_bw()
  
  p2 <- df %>% ggplot(aes(variable, sum_missing, fill = variable)) +
    geom_bar(stat = "identity") +
    labs(title = "Number of missing information among variables",
         x = "Variable",
         y = "Number of Missing Values") +
    theme(axis.text.x = element_text(size = 10, angle = 90, hjust = 1),
          axis.text = element_text(size = 10),
          axis.title = element_text(size = 10), 
          legend.title = element_text(size = 10)) +
    theme_bw()
  
  return(grid.arrange(p1, p2, nrow = 1))
}

#_____filter NA and ""
preprocessing <- function(){
  
  #Collision data
  df1 <- check_duplicates(collisions)
  df1 <- df1 %>% 
    dplyr::select(-c(district, location_class, road_class)) %>% 
    mutate(accdate = as.Date(accdate)) %>%
    mutate_all(na_if,"") %>%
    na.omit() %>%
    fwrite("data/intermediate/preprocessed_collision.csv")
  
  #Involved_persons data
  df2 <- check_duplicates(involved_persons)
  df2 <- df2 %>% 
    dplyr::select(-c(actual_speed, driver_condition, posted_speed, impact_location, manoeuver, vehicle_class)) %>% 
    mutate(accdate = as.Date(accdate)) %>%
    mutate_all(na_if,"") %>%
    na.omit() %>%
    mutate(serious_fatal = if_else(involved_injury_class == "MAJOR" | involved_injury_class == "FATAL", 1, 0),
           serious_fatal =  as.factor(serious_fatal)) %>%
    fwrite("data/intermediate/preprocessed_involved_persons.csv")
}


