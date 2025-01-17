#------------------------------------------------------------------------------------------#
####                      SIMANFOR outputs management by inventory                      ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 15/01/2024                              #
#                              Last modification: 15/01/2024                               #
#------------------------------------------------------------------------------------------#


# function to group SIMANFOR outputs by inventory
group_simanfor_data <- function(path, inventory){
  
  # set new directory
  old_wd <- getwd()
  setwd(path)
  
  
  #### Read SIMANFOR outputs (just plot information) ####
  
  plots <- tibble()  # will contain plot data
  directory <- list.dirs(path = ".")  # will contain folder names
  
  # for each subfolder...
  for (folder in directory){ 
    
    # each subfolder is stablished as main one
    specific_dir <- paste(path, "substract", folder, sep = "")
    specific_dir <- gsub("substract.", "", specific_dir)
    setwd(specific_dir)
    
    # extract .xlsx files names
    files_list <- list.files(specific_dir, pattern="xlsx")
    
    # for each file...
    for (doc in files_list){
      
      # read plot data
      plot_data <- read_excel(doc, sheet = "Parcelas")
      
      # create a new column with its name                
      plot_data$File_name <- doc  
      
      # add information to plot df
      ifelse(length(plots) == 0, plots <- rbind(plot_data), plots <- rbind(plots, plot_data))
    }
  }
  
  
  #### Data management - stand evolution ####
  
  # make a copy of the data
  df <- plots  
  
  # function to round on ages on 5 years step
  redondeo <- function(x, base){  
    base * round(x/base)
  }                                 
  
  # remove initial load
  df <- df[!df$Accion == "Carga Inicial", ]
  
  # round ages
  df$T <- redondeo(df$T, 5) 
  
  # get scenario code
  #df$n_scnr <- substr(df$Scenario_file_name, 17, 19)
  df$n_scnr <- sub(paste(inventory, "_|\\.json", sep = ''), "", df$Nombre_archivo_escenario)
  df$n_scnr <- sub(".json", "", df$n_scnr)
  
  # delete empty rows
  df <- df[!is.na(df$n_scnr), ]
  
  # fill empty values
  df$V_extraido <- ifelse(df$V_extraido == '', 0, df$V_extraido)
  df$V_extraido <- (df$V_extraido * df$V_con_corteza) / 100
  
  # calculate extracted volume in consecutive harvests
  df_extraido <- df %>% group_by(Nombre_archivo_escenario, Edad_de_escenario, Accion, T, n_scnr) %>% summarize(V_extraido = sum(V_extraido))
  
  # rename scenarios
  df$n_scnr <- gsub('QP2', 'gal', df$n_scnr)
  df$n_scnr <- gsub('expertos', 'cyl', df$n_scnr)
  
  # clean data
  rm(plot_data, directory, doc, files_list, folder, specific_dir)
  
  # set old directory
  setwd(old_wd)
  
  # return data
  return(df)
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#


# function to group SIMANFOR outputs by inventory including data of extracted wood by thinning
accumulated_simanfor_data <- function(path, inventory){
  
  # set directory
  old_wd <- getwd()
  setwd(path)
  
  
  #### Read SIMANFOR outputs (just plot information) ####
  
  plots <- tibble()  # will contain plot data
  directory <- list.dirs(path = ".")  # will contain folder names
  
  # for each subfolder...
  for (folder in directory){ 
    
    # each subfolder is stablished as main one
    specific_dir <- paste(path, "substract", folder, sep = "")
    specific_dir <- gsub("substract.", "", specific_dir)
    setwd(specific_dir)
    
    # extract .xlsx files names
    files_list <- list.files(specific_dir, pattern="xlsx")
    
    # for each file...
    for (doc in files_list){
      
      # read plot data
      plot_data <- read_excel(doc, sheet = "Parcelas")
      
      # create a new column with its name                
      plot_data$File_name <- doc  
      
      # add information to plot df
      ifelse(length(plots) == 0, plots <- rbind(plot_data), plots <- rbind(plots, plot_data))
    }
  }
  
  #### Data management - stand and accumulated wood evolution ####
  
  # make a copy of the data
  df <- plots
  
  # function to round on ages on 5 years step
  redondeo <- function(x, base){
    base * round(x/base)
  }
  
  # remove initial load
  df <- df[!df$Accion == "Carga Inicial", ]
  
  # changes in SIMANFOR labels
  df$CARBON <- df$Carbono_total
  
  # calculate differences per scenario step on the desired variables
  # that is the first step to record losses and gains due to thinning
  df <- df %>%
    group_by(File_name, Nombre_archivo_escenario) %>%
    mutate(V_diff = V_con_corteza - lag(V_con_corteza),
           SIERRA_GRUESA_LR_diff = `SIERRA_GRUESA-LIFEREBOLLO` - lag(`SIERRA_GRUESA-LIFEREBOLLO`),
           SIERRA_LR_diff = `SIERRA-LIFEREBOLLO` - lag(`SIERRA-LIFEREBOLLO`),
           DUELAS_INTONA_diff = `DUELAS_INTONA-LIFEREBOLLO` - lag(`DUELAS_INTONA-LIFEREBOLLO`),
           DUELAS_FONDO_INTONA_diff = `DUELAS_FONDO_INTONA-LIFEREBOLLO` - lag(`DUELAS_FONDO_INTONA-LIFEREBOLLO`),
           MADERA_LAMINADA_GAMIZ_diff = `MADERA_LAMINADA_GAMIZ-LIFEREBOLLO` - lag(`MADERA_LAMINADA_GAMIZ-LIFEREBOLLO`),
           VARIOS_GARCIA_VARONA_diff = `VARIOS_GARCIA_VARONA-LIFEREBOLLO` - lag(`VARIOS_GARCIA_VARONA-LIFEREBOLLO`),
           CARBON_diff = CARBON - lag(CARBON),
           WT_diff = WT - lag(WT),
    )
  
  # create a new df with accumulated values
  new_df <- tibble()
  
  # for each scenario...
  for(scnr in unique(df$Nombre_archivo_escenario)){
    
    # get data
    scnr <- df[df$Nombre_archivo_escenario == scnr, ]
    
    # for each plot in the scenario...
    for(plot in unique(scnr$File_name)){
      
      # get data
      plot <- scnr[scnr$File_name == plot, ]
      
      # stablish initial values for accumulated variables as 0
      all_V <- all_SIERRA_GRUESA_LR <- all_SIERRA_LR <- all_DUELAS_INTONA <- all_DUELAS_FONDO_INTONA <-
        all_MADERA_LAMINADA_GAMIZ <- all_VARIOS_GARCIA_VARONA <- all_CARBON <- all_WT <- 0
      
      # for each row...
      for(row in 1:nrow(plot)){
        
        # select data
        new_row <- plot[row, ]
        
        # if it is row 1, then initial values must be taken
        if(row == 1){
          
          # get initial value
          all_V <- new_row$V_con_corteza
          all_SIERRA_GRUESA_LR <- new_row$`SIERRA_GRUESA-LIFEREBOLLO`
          all_SIERRA_LR <- new_row$`SIERRA-LIFEREBOLLO`
          all_DUELAS_INTONA <- new_row$`DUELAS_INTONA-LIFEREBOLLO`
          all_DUELAS_FONDO_INTONA <- new_row$`DUELAS_FONDO_INTONA-LIFEREBOLLO`
          all_MADERA_LAMINADA_GAMIZ <- new_row$`MADERA_LAMINADA_GAMIZ-LIFEREBOLLO`
          all_VARIOS_GARCIA_VARONA <- new_row$`VARIOS_GARCIA_VARONA-LIFEREBOLLO`
          all_CARBON <- new_row$CARBON
          all_WT <- new_row$WT
          
          # add value to the row
          new_row$V_all <- all_V
          new_row$SIERRA_GRUESA_LR_all <- all_SIERRA_GRUESA_LR
          new_row$SIERRA_LR_all <- all_SIERRA_LR
          new_row$DUELAS_INTONA_all <- all_DUELAS_INTONA
          new_row$DUELAS_FONDO_INTONA_all <- all_DUELAS_FONDO_INTONA
          new_row$MADERA_LAMINADA_GAMIZ_all <- all_MADERA_LAMINADA_GAMIZ
          new_row$VARIOS_GARCIA_VARONA_all <- all_VARIOS_GARCIA_VARONA
          new_row$CARBON_all <- all_CARBON
          new_row$WT_all <- all_WT
          
          # if it is another row, then difference between rows is added in abs()
        } else {
          
          # add increment to the previous value
          all_V <- all_V + abs(new_row$V_diff)
          all_SIERRA_GRUESA_LR <- all_SIERRA_GRUESA_LR + abs(new_row$SIERRA_GRUESA_LR_diff)
          all_SIERRA_LR <- all_SIERRA_LR + abs(new_row$SIERRA_LR_diff)
          all_DUELAS_INTONA <- all_DUELAS_INTONA + abs(new_row$DUELAS_INTONA_diff)
          all_DUELAS_FONDO_INTONA <- all_DUELAS_FONDO_INTONA + abs(new_row$DUELAS_FONDO_INTONA_diff)
          all_MADERA_LAMINADA_GAMIZ <- all_MADERA_LAMINADA_GAMIZ + abs(new_row$MADERA_LAMINADA_GAMIZ_diff)
          all_VARIOS_GARCIA_VARONA <- all_VARIOS_GARCIA_VARONA + abs(new_row$VARIOS_GARCIA_VARONA_diff)
          all_CARBON <- all_CARBON + abs(new_row$CARBON_diff)
          all_WT <- all_WT + abs(new_row$WT_diff)
          
          # add value to the row
          new_row$V_all <- all_V
          new_row$SIERRA_GRUESA_LR_all <- all_SIERRA_GRUESA_LR
          new_row$SIERRA_LR_all <- all_SIERRA_LR
          new_row$DUELAS_INTONA_all <- all_DUELAS_INTONA
          new_row$DUELAS_FONDO_INTONA_all <- all_DUELAS_FONDO_INTONA
          new_row$MADERA_LAMINADA_GAMIZ_all <- all_MADERA_LAMINADA_GAMIZ
          new_row$VARIOS_GARCIA_VARONA_all <- all_VARIOS_GARCIA_VARONA
          new_row$CARBON_all <- all_CARBON
          new_row$WT_all <- all_WT
        }
        
        # add new row to a new df
        new_df <- rbind(new_df, new_row)
        
      } # row
    } # plot
  } # scenario
  
  # round ages
  new_df$T <- redondeo(new_df$T, 5)
  
  # get scenario code
  new_df$n_scnr <- sub(paste(inventory, "_|\\.json", sep = ''), "", new_df$Nombre_archivo_escenario)
  new_df$n_scnr <- sub(".json", "", new_df$n_scnr)
  
  # rename scenarios
  new_df$n_scnr <- gsub('QP2', 'gal', new_df$n_scnr)
  new_df$n_scnr <- gsub('expertos', 'cyl', new_df$n_scnr)
  
  # change labels to a better understanding
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'gal_QP2_modificado_2', 'QP2_modificado_2', new_df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'gal_QP2_modificado_3', 'QP2_modificado_3', new_df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'gal_QP2_modificado_4', 'QP2_modificado_4', new_df$n_scnr)
  # df$n_scnr <- ifelse(df$n_scnr == 'guia_calidad', 'calidad', df$n_scnr)
  # df$n_scnr <- ifelse(df$n_scnr == 'guia_multiple', 'obj_multiple', df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'comite_expertos_2', 'c_expertos_2', new_df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'comite_expertos_3', 'c_expertos_3', new_df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'comite_expertos_4', 'c_expertos_4', new_df$n_scnr)
  
  # delete empty rows
  new_df <- new_df[!is.na(new_df$n_scnr), ]
  
  rm(df, new_row, plot, plots, scnr, all_V, all_DUELAS_INTONA, all_CARBON, all_SIERRA_GRUESA_LR,
     all_WT, all_MADERA_LAMINADA_GAMIZ, all_SIERRA_LR, all_DUELAS_FONDO_INTONA, all_VARIOS_GARCIA_VARONA,
     row, redondeo)

  # set old directory
  setwd(old_wd)
  
  # return data
  return(new_df)
}


# function to group SIMANFOR outputs by inventory including data of extracted wood by thinning
accumulated_simanfor_data_final_values <- function(path, inventory){
  
  # set directory
  old_wd <- getwd()
  setwd(path)
  
  
  #### Read SIMANFOR outputs (just plot information) ####
  
  plots <- tibble()  # will contain plot data
  directory <- list.dirs(path = ".")  # will contain folder names
  
  # for each subfolder...
  for (folder in directory){ 
    
    # each subfolder is stablished as main one
    specific_dir <- paste(path, "substract", folder, sep = "")
    specific_dir <- gsub("substract.", "", specific_dir)
    setwd(specific_dir)
    
    # extract .xlsx files names
    files_list <- list.files(specific_dir, pattern="xlsx")
    
    # for each file...
    for (doc in files_list){
      
      # read plot data
      plot_data <- read_excel(doc, sheet = "Parcelas")
      
      # create a new column with its name                
      plot_data$File_name <- doc  
      
      # add information to plot df
      ifelse(length(plots) == 0, plots <- rbind(plot_data), plots <- rbind(plots, plot_data))
    }
  }
  
  #### Data management - stand and accumulated wood evolution ####
  
  # make a copy of the data
  df <- plots
  
  # function to round on ages on 5 years step
  redondeo <- function(x, base){
    base * round(x/base)
  }
  
  # remove initial load
  df <- df[!df$Accion == "Carga Inicial", ]
  
  # changes in SIMANFOR labels
  df$CARBON <- df$Carbono_total
  
  # calculate differences per scenario step on the desired variables
  # that is the first step to record losses and gains due to thinning
  df <- df %>%
    group_by(File_name, Nombre_archivo_escenario) %>%
    mutate(V_diff = V_con_corteza - lag(V_con_corteza),
           SIERRA_GRUESA_LR_diff = `SIERRA_GRUESA-LIFEREBOLLO` - lag(`SIERRA_GRUESA-LIFEREBOLLO`),
           SIERRA_LR_diff = `SIERRA-LIFEREBOLLO` - lag(`SIERRA-LIFEREBOLLO`),
           DUELAS_INTONA_diff = `DUELAS_INTONA-LIFEREBOLLO` - lag(`DUELAS_INTONA-LIFEREBOLLO`),
           DUELAS_FONDO_INTONA_diff = `DUELAS_FONDO_INTONA-LIFEREBOLLO` - lag(`DUELAS_FONDO_INTONA-LIFEREBOLLO`),
           MADERA_LAMINADA_GAMIZ_diff = `MADERA_LAMINADA_GAMIZ-LIFEREBOLLO` - lag(`MADERA_LAMINADA_GAMIZ-LIFEREBOLLO`),
           VARIOS_GARCIA_VARONA_diff = `VARIOS_GARCIA_VARONA-LIFEREBOLLO` - lag(`VARIOS_GARCIA_VARONA-LIFEREBOLLO`),
           CARBON_diff = CARBON - lag(CARBON),
           WT_diff = WT - lag(WT),
    )
  
  # create a new df with accumulated values
  new_df <- tibble()
  
  # for each scenario...
  for(scnr in unique(df$Nombre_archivo_escenario)){
    
    # get data
    scnr <- df[df$Nombre_archivo_escenario == scnr, ]
    
    # for each plot in the scenario...
    for(plot in unique(scnr$File_name)){
      
      # get data
      plot <- scnr[scnr$File_name == plot, ]
      
      # stablish initial values for accumulated variables as 0
      all_V <- all_SIERRA_GRUESA_LR <- all_SIERRA_LR <- all_DUELAS_INTONA <- all_DUELAS_FONDO_INTONA <-
        all_MADERA_LAMINADA_GAMIZ <- all_VARIOS_GARCIA_VARONA <- all_CARBON <- all_WT <- 0
      
      # for each row...
      for(row in 1:nrow(plot)){
        
        # select data
        new_row <- plot[row, ]
        
        # if it is row 1, then initial values must be taken
        if(row == 1){
          
          # get initial value
          all_V <- new_row$V_con_corteza
          all_SIERRA_GRUESA_LR <- new_row$`SIERRA_GRUESA-LIFEREBOLLO`
          all_SIERRA_LR <- new_row$`SIERRA-LIFEREBOLLO`
          all_DUELAS_INTONA <- new_row$`DUELAS_INTONA-LIFEREBOLLO`
          all_DUELAS_FONDO_INTONA <- new_row$`DUELAS_FONDO_INTONA-LIFEREBOLLO`
          all_MADERA_LAMINADA_GAMIZ <- new_row$`MADERA_LAMINADA_GAMIZ-LIFEREBOLLO`
          all_VARIOS_GARCIA_VARONA <- new_row$`VARIOS_GARCIA_VARONA-LIFEREBOLLO`
          all_CARBON <- new_row$CARBON
          all_WT <- new_row$WT
          
          # add value to the row
          new_row$V_all <- all_V
          new_row$SIERRA_GRUESA_LR_all <- all_SIERRA_GRUESA_LR
          new_row$SIERRA_LR_all <- all_SIERRA_LR
          new_row$DUELAS_INTONA_all <- all_DUELAS_INTONA
          new_row$DUELAS_FONDO_INTONA_all <- all_DUELAS_FONDO_INTONA
          new_row$MADERA_LAMINADA_GAMIZ_all <- all_MADERA_LAMINADA_GAMIZ
          new_row$VARIOS_GARCIA_VARONA_all <- all_VARIOS_GARCIA_VARONA
          new_row$CARBON_all <- all_CARBON
          new_row$WT_all <- all_WT
          
          # if it is another row, then difference between rows is added in abs()
        } else {
          
          # add increment to the previous value
          all_V <- all_V + abs(new_row$V_diff)
          all_SIERRA_GRUESA_LR <- all_SIERRA_GRUESA_LR + abs(new_row$SIERRA_GRUESA_LR_diff)
          all_SIERRA_LR <- all_SIERRA_LR + abs(new_row$SIERRA_LR_diff)
          all_DUELAS_INTONA <- all_DUELAS_INTONA + abs(new_row$DUELAS_INTONA_diff)
          all_DUELAS_FONDO_INTONA <- all_DUELAS_FONDO_INTONA + abs(new_row$DUELAS_FONDO_INTONA_diff)
          all_MADERA_LAMINADA_GAMIZ <- all_MADERA_LAMINADA_GAMIZ + abs(new_row$MADERA_LAMINADA_GAMIZ_diff)
          all_VARIOS_GARCIA_VARONA <- all_VARIOS_GARCIA_VARONA + abs(new_row$VARIOS_GARCIA_VARONA_diff)
          all_CARBON <- all_CARBON + abs(new_row$CARBON_diff)
          all_WT <- all_WT + abs(new_row$WT_diff)
          
          # add value to the row
          new_row$V_all <- all_V
          new_row$SIERRA_GRUESA_LR_all <- all_SIERRA_GRUESA_LR
          new_row$SIERRA_LR_all <- all_SIERRA_LR
          new_row$DUELAS_INTONA_all <- all_DUELAS_INTONA
          new_row$DUELAS_FONDO_INTONA_all <- all_DUELAS_FONDO_INTONA
          new_row$MADERA_LAMINADA_GAMIZ_all <- all_MADERA_LAMINADA_GAMIZ
          new_row$VARIOS_GARCIA_VARONA_all <- all_VARIOS_GARCIA_VARONA
          new_row$CARBON_all <- all_CARBON
          new_row$WT_all <- all_WT
        }
        
        # add new row to a new df
        new_df <- rbind(new_df, new_row)
        
      } # row
    } # plot
  } # scenario
  
  # round ages
  new_df$T <- redondeo(new_df$T, 5)
  
  # get scenario code
  new_df$n_scnr <- sub(paste(inventory, "_|\\.json", sep = ''), "", new_df$Nombre_archivo_escenario)
  new_df$n_scnr <- sub(".json", "", new_df$n_scnr)
  
  # rename scenarios
  new_df$n_scnr <- gsub('QP2', 'gal', new_df$n_scnr)
  new_df$n_scnr <- gsub('expertos', 'cyl', new_df$n_scnr)
  
  # change labels to a better understanding
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'gal_QP2_modificado_2', 'QP2_modificado_2', new_df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'gal_QP2_modificado_3', 'QP2_modificado_3', new_df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'gal_QP2_modificado_4', 'QP2_modificado_4', new_df$n_scnr)
  # df$n_scnr <- ifelse(df$n_scnr == 'guia_calidad', 'calidad', df$n_scnr)
  # df$n_scnr <- ifelse(df$n_scnr == 'guia_multiple', 'obj_multiple', df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'comite_expertos_2', 'c_expertos_2', new_df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'comite_expertos_3', 'c_expertos_3', new_df$n_scnr)
  #new_df$n_scnr <- ifelse(new_df$n_scnr == 'comite_expertos_4', 'c_expertos_4', new_df$n_scnr)
  
  # delete empty rows
  new_df <- new_df[!is.na(new_df$n_scnr), ]
  
  # select data in the output
  new_df <- dplyr::select(new_df, c("Nombre_archivo_escenario", "File_name", "n_scnr", "T",
                                    "WT", "WT_all",
                                    "CARBON", "CARBON_all",
                                    "V_con_corteza", "V_all",
                                    "SIERRA_GRUESA-LIFEREBOLLO", "SIERRA_GRUESA_LR_all",
                                    "SIERRA-LIFEREBOLLO", "SIERRA_LR_all",
                                    "DUELAS_INTONA-LIFEREBOLLO", "DUELAS_INTONA_all",
                                    "DUELAS_FONDO_INTONA-LIFEREBOLLO", "DUELAS_FONDO_INTONA_all",
                                    "MADERA_LAMINADA_GAMIZ-LIFEREBOLLO", "MADERA_LAMINADA_GAMIZ_all",
                                    "VARIOS_GARCIA_VARONA-LIFEREBOLLO", "VARIOS_GARCIA_VARONA_all",
                                    "Indice_biodiversidad_madera_muerta_G_CESEFOR", "Indice_biodiversidad_madera_muerta_V_CESEFOR",
                                    "Shannon_dbh", "Shannon_altura", "CV_dbh", "CV_altura"
  ))
  
  # I use only the value of the last growth period per simulation
  final_value <- data.frame()
  for(file in unique(df$File_name)){
    tmp_plot <- new_df[new_df$File_name == file, ]
    final_value_file <- tmp_plot[tmp_plot$T == max(tmp_plot$T),]
    final_value <- rbind(final_value, final_value_file)
  }
  new_df <- final_value
  
  rm(df, new_row, plot, plots, scnr, all_V, all_DUELAS_INTONA, all_CARBON, all_SIERRA_GRUESA_LR,
     all_WT, all_MADERA_LAMINADA_GAMIZ, all_SIERRA_LR, all_DUELAS_FONDO_INTONA, all_VARIOS_GARCIA_VARONA,
     row, redondeo)
  
  # set old directory
  setwd(old_wd)
  
  # return data
  return(new_df)
}

get_accumated_values <- function(path){
  
  
  # set directory
  old_wd <- getwd()
  setwd(path)
  
  
  #### Read SIMANFOR outputs (just plot information) ####
  
  plots <- tibble()  # will contain plot data
  directory <- list.dirs(path = ".")  # will contain folder names
  
  # for each subfolder...
  for (folder in directory){ 
    
    # each subfolder is stablished as main one
    specific_dir <- paste(path, "substract", folder, sep = "")
    specific_dir <- gsub("substract.", "", specific_dir)
    setwd(specific_dir)
    
    # extract .xlsx files names
    files_list <- list.files(specific_dir, pattern="xlsx")
    
    # for each file...
    for (doc in files_list){
      
      # read plot data
      plot_data <- read_excel(doc, sheet = "Parcelas")
      
      # create a new column with its name                
      plot_data$File_name <- doc  
      
      # add information to plot df
      ifelse(length(plots) == 0, plots <- rbind(plot_data), plots <- rbind(plots, plot_data))
    }
  }
  
  #### Data management - stand and accumulated wood evolution ####
  
  # make a copy of the data
  df <- plots
  
  # extract harvest and growth data
  harvest <- filter(df, Accion == "Corta")
  growth <- filter(df, Accion == "Ejecución")
  
  # I use only the value of the last growth period per simulation
  files <- data.frame()
  final_value <- data.frame()
  for(file in unique(df$File_name)){
    files <- rbind(files, file)
    tmp_plot <- df[df$File_name == file, ]
    final_value_file <- tmp_plot[tmp_plot$Edad_de_escenario == max(tmp_plot$Edad_de_escenario),]
    final_value <- rbind(final_value, final_value_file)
  }
  
  # I delete processess with nothing harvested to avoid errors
  harvest <- filter(harvest, !is.na(V_extraido))
  harvest <- filter(harvest, V_extraido != 0)
  
  # sumo los datos de las harvest
  harvest <- ddply(harvest, c('File_name'), summarise,  # agrupo filas por código de escenario
                  v_harvest_sum = sum(V_extraido, na.rm = TRUE),  # sumo el volumen cortado en cada parcela
                  g_harvest_sum = sum(G_extraida, na.rm = TRUE)  # sumo el Área basimétrica cortada en cada parcela
                  #wt_harvest_sum = sum(WT_extraida, na.rm = TRUE)
  )
  
  # join dfs
  final_plots <- merge(final_value, harvest, by = 'File_name', all = TRUE)

  # NAs to 0 to avoid errors
  final_plots[is.na(final_plots)] <- 0
  
  # final values (field + harvested)
  final_plots$Vfinal <- final_plots$V_con_corteza + final_plots$v_harvest_sum
  final_plots$Gfinal <- final_plots$G + final_plots$g_harvest_sum
  #final_plots$WTfinal <- final_plots$WT + final_plots$wt_harvest_sum
  
  # delete temp values
  #rm(harvest, crecimientos, crecimiento_final, df)
  
  # set old directory
  setwd(old_wd)
  
  # clean data
  final_plots <- dplyr::select(final_plots, c("File_name", "V_con_corteza", "G", 
                                 "v_harvest_sum",  "g_harvest_sum",  "Vfinal", "Gfinal"))
  
  # return data
  return(final_plots)
}



deadwood_index_on_simulation <- function(path){
  
  
  # set directory
  old_wd <- getwd()
  setwd(path)
  
  
  #### Read SIMANFOR outputs (just plot information) ####
  
  plots <- tibble()  # will contain plot data
  directory <- list.dirs(path = ".")  # will contain folder names
  
  # for each subfolder...
  for (folder in directory){ 
    
    # each subfolder is stablished as main one
    specific_dir <- paste(path, "substract", folder, sep = "")
    specific_dir <- gsub("substract.", "", specific_dir)
    setwd(specific_dir)
    
    # extract .xlsx files names
    files_list <- list.files(specific_dir, pattern="xlsx")
    
    # for each file...
    for (doc in files_list){
      
      # read plot data
      plot_data <- read_excel(doc, sheet = "Parcelas")
      
      # create a new column with its name                
      plot_data$File_name <- doc  
      
      # add information to plot df
      ifelse(length(plots) == 0, plots <- rbind(plot_data), plots <- rbind(plots, plot_data))
    }
  }
  
  #### Data management - stand and accumulated wood evolution ####
  
  # make a copy of the data
  #df <- plots
 
  # filter executions
  df <- plots[plots$Accion == 'Ejecución', ]
  
  # count the number of times that the index is 1 (good biodiversity value)
  df_index <- df %>%
    dplyr::group_by(File_name) %>%
    dplyr::summarise(
      Numero_ejecuciones_escenario = n(),
      Numero_ejecuciones_con_G = sum(Indice_biodiversidad_madera_muerta_G_CESEFOR != '-', na.rm = TRUE),
      Numero_ejecuciones_con_V = sum(Indice_biodiversidad_madera_muerta_V_CESEFOR != '-', na.rm = TRUE),
      Indice_biodiversidad_madera_muerta_G_CESEFOR = sum(Indice_biodiversidad_madera_muerta_G_CESEFOR == 1, na.rm = TRUE),
      Indice_biodiversidad_madera_muerta_V_CESEFOR = sum(Indice_biodiversidad_madera_muerta_V_CESEFOR == 1, na.rm = TRUE))

  # calculate ratios
  df_index$Ratio_G <- df_index$Indice_biodiversidad_madera_muerta_G_CESEFOR / df_index$Numero_ejecuciones_con_G
  df_index$Ratio_V <- df_index$Indice_biodiversidad_madera_muerta_V_CESEFOR / df_index$Numero_ejecuciones_con_V
  
  return(df_index)
}



shannon_cv_index_on_simulation <- function(path){
  
  
  # set directory
  old_wd <- getwd()
  setwd(path)
  
  
  #### Read SIMANFOR outputs (just plot information) ####
  
  plots <- tibble()  # will contain plot data
  directory <- list.dirs(path = ".")  # will contain folder names
  
  # for each subfolder...
  for (folder in directory){ 
    
    # each subfolder is stablished as main one
    specific_dir <- paste(path, "substract", folder, sep = "")
    specific_dir <- gsub("substract.", "", specific_dir)
    setwd(specific_dir)
    
    # extract .xlsx files names
    files_list <- list.files(specific_dir, pattern="xlsx")
    
    # for each file...
    for (doc in files_list){
      
      # read plot data
      plot_data <- read_excel(doc, sheet = "Parcelas")
      
      # create a new column with its name                
      plot_data$File_name <- doc  
      
      # add information to plot df
      ifelse(length(plots) == 0, plots <- rbind(plot_data), plots <- rbind(plots, plot_data))
    }
  }
  
  #### Data management - stand and accumulated wood evolution ####
  
  # make a copy of the data
  #df <- plots
  
  # filter executions
  df <- plots[plots$Accion == 'Ejecución', ]
  
  # count the number of times that the index is 1 (good biodiversity value)
  df_index <- df %>%
    dplyr::group_by(File_name) %>%
    dplyr::summarise(
      Numero_ejecuciones_escenario = n(),
      Shannon_dbh_min = min(Shannon_dbh, na.rm = TRUE),
      Shannon_dbh_max = max(Shannon_dbh, na.rm = TRUE),
      Shannon_dbh_mean = mean(Shannon_dbh, na.rm = TRUE),
      Shannon_altura_min = min(Shannon_altura, na.rm = TRUE),
      Shannon_altura_max = max(Shannon_altura, na.rm = TRUE),
      Shannon_altura_mean = mean(Shannon_altura, na.rm = TRUE),
      CV_dbh_min = min(CV_dbh, na.rm = TRUE),
      CV_dbh_max = max(CV_dbh, na.rm = TRUE),
      CV_dbh_mean = mean(CV_dbh, na.rm = TRUE),
      CV_altura_min = min(CV_altura, na.rm = TRUE),
      CV_altura_max = max(CV_altura, na.rm = TRUE),
      CV_altura_mean = mean(CV_altura, na.rm = TRUE))
      
  return(df_index)
}