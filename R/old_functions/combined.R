source("R/download_raw.R")
source("R/preprocessing.R")
source("R/transformation.R")

collisions <- fread("data/raw/collision_events.csv")
involved_persons <- fread("data/raw/involved_persons.csv") %>% filter(involved_class =="PEDESTRIAN")
preprocessed_collisions <- fread("data/intermediate/preprocessed_collision.csv")
preprocessed_injured_persons <- fread("data/intermediate/preprocessed_involved_persons.csv")

combined_wrangling <- function(){
  
  dataDownload(id = "1Hnlicnek_4BEEsOMeEhSiRc0sEhiLsew")     #data download
  
  #data for preprocessing
  preprocessing() 
  
  # transformations
  
  cleaned_data()
}

combined_wrangling()
