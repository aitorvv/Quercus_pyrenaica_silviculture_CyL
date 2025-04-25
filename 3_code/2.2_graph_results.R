#-----------------------------------------------------------------------------------------#
####                          Group and graph SIMANFOR results                         ####
#                                                                                         #
#                            Aitor Vázquez Veloso, 31/03/2022                             #
#                              Last modification: 22/08/2024                              #
#-----------------------------------------------------------------------------------------#


#### Summary ####

# Extended explanation here: 
# https://github.com/simanfor/resultados/blob/main/analisis_resultados/analisis_resultados_SIMANFOR.R


#### Basic steps ####

# libraries
library(readxl)
library(ggplot2)
library(ggpubr)
library(plyr)
library(tidyverse)

# set directory
setwd("/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture")

# list of different inventories to graph
my_list <- list('SG', 'SO', 'SG_irregular', 'SO_irregular')
main_path <- "/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/2_simanfor/output_ES/"
my_inventoires <- list('LR_SG02', 'LR_SO02', 'LR_irregular')
main_fig_path <- '/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/4_figures/resized/'

# get functions
source('3_code/2.0_group_simanfor_data.R') # get data
source('3_code/2.1_graph_templates-resized.R') # get graphs functions

# get accumulated values for all inventories
df_accum <- get_accumated_values(main_path)
write.csv(df_accum, '/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/4_figures/2.2_simulation_accumulated_values.csv', 
            row.names = FALSE)
df_accum_LR <- accumulated_simanfor_data_final_values(main_path, "LR")
write.csv(df_accum_LR, '/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/4_figures/2.2_simulation_accumulated_values_LifeRebollo.csv',
          row.names = FALSE)
df_deadwood <- deadwood_index_on_simulation(main_path)
write.csv(df_deadwood, '/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/4_figures/2.2_simulation_deadwood_index.csv',
          row.names = FALSE)
df_diversity <- shannon_cv_index_on_simulation(main_path)
write.csv(df_diversity, '/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/4_figures/2.2_simulation_diversity_index.csv',
          row.names = FALSE)

# declare list of graphs
graphs_list <- list()
graphs_list_diversity <- list()  # added later; just in another list to avoid changes in the code

# iterate to graph all inventories
for(k in 1:length(my_list)){

  # select inventory
  path <- my_list[k]
  path <- paste(main_path, path, '/', sep = '')
  inventory <- my_inventoires[k]
  fig_path <- paste(main_fig_path, my_list[k], '/', sep = '')
  
  # get data
  df <- group_simanfor_data(path, inventory)
  
  if(k == 4){
    df$n_scnr <- sub("LR_irregular_", "", df$n_scnr)
  }
  
  #### Graph results ####
  
  
  #### Density ####
  n <- graph_data(df = df, x = df$T, y = df$N, class = df$n_scnr,
                     x_lab = "Stand age (years)", y_lab = "Density (trees/ha)",
                     path = paste(fig_path, 'N.png', sep = ''))

  
  #### Mortality ####
  
  dead <- graph_data(df = df, x = df$T, y = df$N_muerto, class = df$n_scnr,
                        x_lab = "Stand age (years)", y_lab = "Natural mortality (trees/ha)",
                        path = paste(fig_path, 'mortality.png', sep = ''))
  
  
  #### Ingrowth ####
  
  ing <- graph_data(df = df, x = df$T, y = df$N_incorporado, class = df$n_scnr,
                       x_lab = "Stand age (years)", y_lab = "Ingrowth (trees/ha)",
                       path = paste(fig_path, 'ingrowth.png', sep = ''))
  
  
  #### G stand ####
  
  g <- graph_data_g(df = df, x = df$T, y = df$G, class = df$n_scnr,
                       x_lab = "Stand age (years)", y_lab = "Basal area (m²/ha)",
                       path = paste(fig_path, 'G.png', sep = ''))
  
  
  #### Hart-Becking ####
  
  hart <- graph_data_hart(df = df, x = df$T, y = df$HartBecking__marco_real, class = df$n_scnr,
                          x_lab = "Stand age (years)", y_lab = "Hart-Becking index",
                          path = paste(fig_path, 'Hart.png', sep = ''))
  
  
  #### Data management - stand and accumulated wood evolution ####
  
  new_df <- accumulated_simanfor_data(path, inventory)
  
  if(k == 4){
    new_df$n_scnr <- sub("LR_irregular_", "", new_df$n_scnr)
  }
  
  
  #### Graph results ####
  
  
  #### WT and C ####
  
  c <- graph_data_2vars(df = new_df, x = new_df$T, y = new_df$CARBON_all, y2 = new_df$WT_all, class = new_df$n_scnr, 
                       x_lab = "Stand age (years)", y_lab = "Biomass - Carbon (t/ha)", 
                       path = paste(fig_path, 'W_and_C_all.png', sep = ''))
  
  #### Wood uses ####
  
  v <- graph_data_2vars(df = new_df, x = new_df$T, y = new_df$V_all, y2 = new_df$V_con_corteza, class = new_df$n_scnr, 
                         x_lab = "Stand age (years)", y_lab = "Wood volume (m³/ha)", 
                         path = paste(fig_path, 'V_all.png', sep = ''))
  
  saw <- graph_data(df = new_df, x = new_df$T, y = new_df$SIERRA_LR_all, class = new_df$n_scnr, 
                       x_lab = "Stand age (years)", y_lab = "Wood volume (m³/ha)", 
                       path = paste(fig_path, 'saw_all.png', sep = ''))
  
  saw_big <- graph_data(df = new_df, x = new_df$T, y = new_df$SIERRA_GRUESA_LR_all, class = new_df$n_scnr, 
                           x_lab = "Stand age (years)", y_lab = "Wood volume (m³/ha)", 
                           path = paste(fig_path, 'saw_big_all.png', sep = ''))
  
  staves <- graph_data(df = new_df, x = new_df$T, y = new_df$DUELAS_INTONA_all, class = new_df$n_scnr, 
                          x_lab = "Stand age (years)", y_lab = "Wood volume (m³/ha)", 
                          path = paste(fig_path, 'staves_all.png', sep = ''))
  
  staves_bottom <- graph_data(df = new_df, x = new_df$T, y = new_df$DUELAS_FONDO_INTONA_all, class = new_df$n_scnr, 
                                 x_lab = "Stand age (years)", y_lab = "Wood volume (m³/ha)", 
                                 path = paste(fig_path, 'staves_bottom_all.png', sep = ''))
  
  veneer <- graph_data(df = new_df, x = new_df$T, y = new_df$MADERA_LAMINADA_GAMIZ_all, class = new_df$n_scnr, 
                          x_lab = "Stand age (years)", y_lab = "Wood volume (m³/ha)", 
                          path = paste(fig_path, 'veneer_all.png', sep = ''))
  
  
  various <- graph_data(df = new_df, x = new_df$T, y = new_df$VARIOS_GARCIA_VARONA_all, class = new_df$n_scnr,  
                           x_lab = "Stand age (years)", y_lab = "Wood volume (m³/ha)", 
                           path = paste(fig_path, 'various_all.png', sep = ''))
  
  #### Size diversity indexes ####
  shannon_dbh <- graph_data(df = new_df, x = new_df$T, y = new_df$Shannon_dbh, class = new_df$n_scnr,  
                        x_lab = "Stand age (years)", y_lab = "Shannon index on diametric classes", 
                        path = paste(fig_path, 'shannon_dbh.png', sep = ''))
  
  shannon_height <- graph_data(df = new_df, x = new_df$T, y = new_df$Shannon_altura, class = new_df$n_scnr,  
                            x_lab = "Stand age (years)", y_lab = "Shannon index on height classes", 
                            path = paste(fig_path, 'shannon_height.png', sep = ''))
  
  # variation coefficient
  cv_dbh <- graph_data(df = new_df, x = new_df$T, y = new_df$CV_dbh, class = new_df$n_scnr,  
                            x_lab = "Stand age (years)", y_lab = "CV on diametric classes", 
                            path = paste(fig_path, 'cv_dbh.png', sep = ''))
  
  cv_height <- graph_data(df = new_df, x = new_df$T, y = new_df$CV_altura, class = new_df$n_scnr,  
                       x_lab = "Stand age (years)", y_lab = "CV on height classes", 
                       path = paste(fig_path, 'cv_height.png', sep = ''))
  
  #### Deadwood diversity indexes ####
  bid_g <- graph_data(df = new_df, x = new_df$T, y = new_df$Indice_biodiversidad_madera_muerta_G_CESEFOR, class = new_df$n_scnr,  
                       x_lab = "Stand age (years)", y_lab = "BID based on G", 
                       path = paste(fig_path, 'bid_g.png', sep = ''))
  
  bid_v <- graph_data(df = new_df, x = new_df$T, y = new_df$Indice_biodiversidad_madera_muerta_V_CESEFOR, class = new_df$n_scnr,  
                       x_lab = "Stand age (years)", y_lab = "BID based on V", 
                       path = paste(fig_path, 'bid_v.png', sep = ''))
  
  # group all the graphs in the same list
  graphs_list <- append(graphs_list, list(n, dead, ing, g, hart, c, v, saw, saw_big, staves, staves_bottom, veneer, various))
  graphs_list_diversity <- append(graphs_list_diversity, list(shannon_dbh, shannon_height, cv_dbh, cv_height, bid_g, bid_v))
  
  # print the name of the inventory
  print(paste('printed all the graphs of ', my_list[k], sep = ''))
}


#### Grouped graphs ####

# set the path to save the grouped graphs
group_path <- '/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/4_figures/resized/grouped_figures/'


# Grouped graphs - resized ====

# customize labels
graphs_list[[1]] <- graphs_list[[1]] + theme(axis.title.x = element_blank())
graphs_list[[14]] <- graphs_list[[14]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[27]] <- graphs_list[[27]] 
graphs_list[[40]] <- graphs_list[[40]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[1]], graphs_list[[14]], graphs_list[[27]], graphs_list[[40]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'N.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[2]] <- graphs_list[[2]] + theme(axis.title.x = element_blank())
graphs_list[[15]] <- graphs_list[[15]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[28]] <- graphs_list[[28]] 
graphs_list[[41]] <- graphs_list[[41]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[2]], graphs_list[[15]], graphs_list[[28]], graphs_list[[41]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'dead.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[3]] <- graphs_list[[3]] + theme(axis.title.x = element_blank())
graphs_list[[16]] <- graphs_list[[16]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[29]] <- graphs_list[[29]] 
graphs_list[[42]] <- graphs_list[[42]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[3]], graphs_list[[16]], graphs_list[[29]], graphs_list[[42]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'ing.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[4]] <- graphs_list[[4]] + theme(axis.title.x = element_blank())
graphs_list[[17]] <- graphs_list[[17]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[30]] <- graphs_list[[30]] 
graphs_list[[43]] <- graphs_list[[43]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[4]], graphs_list[[17]], graphs_list[[30]], graphs_list[[43]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'G.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[5]] <- graphs_list[[5]] + theme(axis.title.x = element_blank())
graphs_list[[18]] <- graphs_list[[18]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[31]] <- graphs_list[[31]] 
graphs_list[[44]] <- graphs_list[[44]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[5]], graphs_list[[18]], graphs_list[[31]], graphs_list[[44]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'Hart.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[6]] <- graphs_list[[6]] + theme(axis.title.x = element_blank())
graphs_list[[19]] <- graphs_list[[19]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[32]] <- graphs_list[[32]] 
graphs_list[[45]] <- graphs_list[[45]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[6]], graphs_list[[19]], graphs_list[[32]], graphs_list[[45]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'W_and_C_all.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[7]] <- graphs_list[[7]] + theme(axis.title.x = element_blank())
graphs_list[[20]] <- graphs_list[[20]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[33]] <- graphs_list[[33]] 
graphs_list[[46]] <- graphs_list[[46]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[7]], graphs_list[[20]], graphs_list[[33]], graphs_list[[46]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'V_all.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[8]] <- graphs_list[[8]] + theme(axis.title.x = element_blank())
graphs_list[[21]] <- graphs_list[[21]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[34]] <- graphs_list[[34]] 
graphs_list[[47]] <- graphs_list[[47]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[8]], graphs_list[[21]], graphs_list[[34]], graphs_list[[47]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'saw_all.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[9]] <- graphs_list[[9]] + theme(axis.title.x = element_blank())
graphs_list[[22]] <- graphs_list[[22]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[35]] <- graphs_list[[35]] 
graphs_list[[48]] <- graphs_list[[48]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[9]], graphs_list[[22]], graphs_list[[35]], graphs_list[[48]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'saw_big_all.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[10]] <- graphs_list[[10]] + theme(axis.title.x = element_blank())
graphs_list[[23]] <- graphs_list[[23]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[36]] <- graphs_list[[36]] 
graphs_list[[49]] <- graphs_list[[49]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[10]], graphs_list[[23]], graphs_list[[36]], graphs_list[[49]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'staves_all.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[11]] <- graphs_list[[11]] + theme(axis.title.x = element_blank())
graphs_list[[24]] <- graphs_list[[24]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[37]] <- graphs_list[[37]] 
graphs_list[[50]] <- graphs_list[[50]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[11]], graphs_list[[24]], graphs_list[[37]], graphs_list[[50]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'staves_bottom_all.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[12]] <- graphs_list[[12]] + theme(axis.title.x = element_blank())
graphs_list[[25]] <- graphs_list[[25]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[38]] <- graphs_list[[38]] 
graphs_list[[51]] <- graphs_list[[51]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[12]], graphs_list[[25]], graphs_list[[38]], graphs_list[[51]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'veneer_all.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list[[13]] <- graphs_list[[13]] + theme(axis.title.x = element_blank())
graphs_list[[26]] <- graphs_list[[26]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list[[39]] <- graphs_list[[39]] 
graphs_list[[52]] <- graphs_list[[52]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list[[13]], graphs_list[[26]], graphs_list[[39]], graphs_list[[52]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'various_all.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list_diversity[[1]] <- graphs_list_diversity[[1]] + theme(axis.title.x = element_blank())
graphs_list_diversity[[7]] <- graphs_list_diversity[[7]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list_diversity[[13]] <- graphs_list_diversity[[13]] 
graphs_list_diversity[[19]] <- graphs_list_diversity[[19]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list_diversity[[1]], graphs_list_diversity[[7]], graphs_list_diversity[[13]], graphs_list_diversity[[19]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'shannon_dbh.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list_diversity[[2]] <- graphs_list_diversity[[2]] + theme(axis.title.x = element_blank())
graphs_list_diversity[[8]] <- graphs_list_diversity[[8]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list_diversity[[14]] <- graphs_list_diversity[[14]] 
graphs_list_diversity[[20]] <- graphs_list_diversity[[20]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list_diversity[[2]], graphs_list_diversity[[8]], graphs_list_diversity[[14]], graphs_list_diversity[[20]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'shannon_height.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list_diversity[[3]] <- graphs_list_diversity[[3]] + theme(axis.title.x = element_blank())
graphs_list_diversity[[9]] <- graphs_list_diversity[[9]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list_diversity[[15]] <- graphs_list_diversity[[15]] 
graphs_list_diversity[[20]] <- graphs_list_diversity[[20]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list_diversity[[3]], graphs_list_diversity[[9]], graphs_list_diversity[[15]], graphs_list_diversity[[21]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'cv_dbh.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list_diversity[[4]] <- graphs_list_diversity[[4]] + theme(axis.title.x = element_blank())
graphs_list_diversity[[10]] <- graphs_list_diversity[[10]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list_diversity[[16]] <- graphs_list_diversity[[16]] 
graphs_list_diversity[[22]] <- graphs_list_diversity[[22]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list_diversity[[4]], graphs_list_diversity[[10]], graphs_list_diversity[[16]], graphs_list_diversity[[22]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'cv_height.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list_diversity[[5]] <- graphs_list_diversity[[5]] + theme(axis.title.x = element_blank())
graphs_list_diversity[[11]] <- graphs_list_diversity[[11]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list_diversity[[17]] <- graphs_list_diversity[[17]] 
graphs_list_diversity[[23]] <- graphs_list_diversity[[23]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list_diversity[[5]], graphs_list_diversity[[11]], graphs_list_diversity[[17]], graphs_list_diversity[[23]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'bid_g.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 

graphs_list_diversity[[6]] <- graphs_list_diversity[[6]] + theme(axis.title.x = element_blank())
graphs_list_diversity[[12]] <- graphs_list_diversity[[12]] + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
graphs_list_diversity[[18]] <- graphs_list_diversity[[18]] 
graphs_list_diversity[[24]] <- graphs_list_diversity[[24]] + theme(axis.title.y = element_blank())
ggarrange(graphs_list_diversity[[6]], graphs_list_diversity[[12]], graphs_list_diversity[[18]], graphs_list_diversity[[24]], ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom", 
          widths = c(1, 1), hjust = -1, labels = c('A', 'B', 'C', 'D'), align = 'hv', font.label = list(size = 12, face = 'bold')) 
ggsave(filename = paste(group_path, 'bid_v.png', sep = ''), device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 
