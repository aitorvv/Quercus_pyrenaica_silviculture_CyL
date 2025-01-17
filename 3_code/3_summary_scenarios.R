#------------------------------------------------------------------------------------------#
####                            Summarize SIMANFOR scenarios                            ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 16/08/2023                              #
#                              Last modification: 15/01/2024                               #
#------------------------------------------------------------------------------------------#



#### Summary ####

# Code developed to summarize a group of scenarios in a single df to compare them easily


#### Basic steps ####

# libraries
library(readxl)
library(plyr)
library(dplyr)
library(tidyverse)

# set directory
general_dir <- '/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/2_simanfor/output_EN/'
setwd(general_dir)


#### Read SIMANFOR outputs (just plot information) ####

plots <- tibble()  # will contain plot data
directory <- list.dirs(path = ".")  # will contain folder names

# for each subfolder...
for (folder in directory){ 
  
  # each subfolder is stablished as main one
  specific_dir <- paste(general_dir, "substract", folder, sep = "")
  specific_dir <- gsub("substract.", "", specific_dir)
  setwd(specific_dir)
  
  # extract .xlsx files names
  files_list <- list.files(specific_dir, pattern="xlsx")
  
  # for each file...
  for (doc in files_list){
    
    # read plot data
    plot_data <- read_excel(doc, sheet = "Plots")
    
    # create a new column with its name                
    plot_data$File_name <- doc  
    
    # add information to plot df
    ifelse(length(plots) == 0, plots <- rbind(plot_data), plots <- rbind(plots, plot_data))
  }
}


#### Data management - stand evolution ####

# make a copy of the data
df <- plots  

# get scenario code
#df$n_scnr <- substr(df$Scenario_file_name, 17, 19)
df$n_scnr <- sub("LR_|\\.json", "", df$Scenario_file_name)
df$n_scnr <- sub(".json", "", df$n_scnr)

# change labels to a better understanding
#df$n_scnr <- ifelse(df$n_scnr == 'gal_QP2_modificado', 'QP2_modificado', df$n_scnr)
#df$n_scnr <- ifelse(df$n_scnr == 'guia_calidad', 'calidad', df$n_scnr)
#df$n_scnr <- ifelse(df$n_scnr == 'guia_multiple', 'obj_multiple', df$n_scnr)
#df$n_scnr <- ifelse(df$n_scnr == 'comite_expertos', 'c_expertos', df$n_scnr)

# skip QP2 (it has the same data as QP2_modificado) and control
#df <- df[df$n_scnr != 'gal_QP2',]
#df <- df[df$n_scnr != 'control',]

# select useful information about scenarios
df <- select(df, n_scnr, Scenario_age, Action, Harvest_type, Harvest_criteria, Harvest_severity, Trees_to_preserve)
df <- df[!duplicated(df), ]

# filter management not applied to our stands due to age restriction
df <- df[df$Scenario_age >= 50,]
df <- df[!(df$Scenario_age == 50 & df$Action == 'Execution'), ]

# extract part of character string after "_"
df$Scenario_name <- sub(".*_", "", df$n_scnr)
df$Inventory_name <- sub("_.*", "", df$n_scnr)

# new labels to scenarios
df$Scenario_name <- gsub('QP2', 'gal', df$Scenario_name)
df$Scenario_name <- gsub('expertos', 'cyl', df$Scenario_name)

# ver resultados
view(df)

# exportar
write_csv(df, '../../../4_figures/3_summary_scenarios.csv')
