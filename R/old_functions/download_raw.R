# Data Wrangling functions

# Purpose : This script produces custom functions wrapped around existing R functions that are used for current project's
#           data wrangling steps.

# Date script created: Wednesday January 4 2023 
# Date script last modified: Saturday January 6 2023

# The functions are described below:

# package dependencies
library(reticulate)
py_install("gdown")
gd <- import("gdown")

#' @title 
#' Download data from Google Drive
#' @description
#' dataDownload is a wrapper on python's gdown package.
#' @details
#' The function downloads the contents of the gooogle drive folder
#' @param 
#' The parameter is the google drive folder identifier (id). It can be obtained from the shareable google folder link 
#' @return 
#' the output is the contents of the folder on google drive

id = "1Hnlicnek_4BEEsOMeEhSiRc0sEhiLsew"
dataDownload <- function(id){
  gd$download_folder(id=id, quiet=T, use_cookies=F)
}

#____________________________________________________________________________________________________________________
# package dependencies
library(dplyr)

#' @title 
#' Shows the number of missing information (NA) and empty information
#' @description
#' The missing_empty_information function produces a data frame of number of NA and empty cells columns in the data.
#' @details
#' It uses the dplyr library, including the is.na() function
#' @param 
#' The parameter is the data to be checked
#' @return 
#' The output is dataframe

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
#_________________________________________________________________________________________________________________

# package dependencies
library(dplyr)
library(ggplot2)
library(gridExtra)

#' @title 
#' Graphical display of number of missing information (NA) and empty information
#' @description
#' The missing_empty_plot function shows a grid plot of number of NA and empty cells column in the data.
#' @details
#' It uses the dplyr and the ggplot2 libraries
#' @param 
#' The parameter is the data to be checked
#' @return 
#' The output is grid plot

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

#_____________________________________________________________________________________________________

# package dependencies
library(dplyr)
library(janitor)
library(data.table)

#' @title 
#' Check for row duplicates
#' @description
#' The check_duplicate function checks if there are duplicates in the rows of the data and deletes them. 
#' @details
#' It uses the dplyr, DT and the janitor libraries
#' @param 
#' The parameter is the data to be checked
#' @return 
#' The output is data frame without row duplicates

check_duplicates <- function(data){
  df <- data %>% get_dupes(collision_no, accdate) %>% filter(dupe_count > 1)  # Are there are duplicate?
  if(nrow(df) > 1){
    setDT(data)[!duplicated(rleid(data$collision_no))]      #keep only 1 duplicate
  }else{
    data
  }
}

#_____________________________________________________________________________________________________________
# package dependencies
library(dplyr)
library(data.table)

#' @title 
#' Data pre-processing
#' @description
#' The pre-processing function drops columns with significant amount of missing and empty values. For the others, it 
#' replaces any empty cells with NA, and they are subsequently deleted. 
#' @details
#' It uses the dplyr library for data processing and the DT library for faster writing of csv files
#' @param 
#' The parameter is the data to be checked
#' @return 
#' The output data frame with are written to the intermediate folder in the data folder

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

#_______________________________________________________________________________________________________________

# package dependencies
#utils::install.packages("magrittr")
library(dplyr)
library(data.table)

#' @title 
#' Data pre-processing
#' @description
#' The cleaned_data function joins the collisions and injured_persons data. It also creates dummies based on information in the existing data. 
#' @details
#' It uses the dplyr library for o create dummies and the fwrite function in the DT library for faster writing of resulting csv files
#' @param 
#' The parameter is the data to be transformed
#' @return 
#' The output data frame with are written to the clean folder in the data folder
 
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