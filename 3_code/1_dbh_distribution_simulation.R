#------------------------------------------------------------------------------------------#
####                      Diametric distribution - Life Rebollo                         ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 19/09/2023                              #
#                              Last modification: 15/01/2024                               #
#------------------------------------------------------------------------------------------#

library(openxlsx)
library(ggplot2)
library(dplyr)
library(plyr)


#### Even to uneven-aged stands ####

setwd('/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/')

# data
sg_control <- read.xlsx('2_simanfor/output_EN/SG/LR_SG02_control__Output_Plot_sg02.xlsx', sheet = 'Node 15 - Inventoried trees')
sg_expertos <- read.xlsx('2_simanfor/output_EN/SG/LR_SG02_expertos__Output_Plot_sg02.xlsx', sheet = 'Node 30 - Inventoried trees')
sg_qp2 <- read.xlsx('2_simanfor/output_EN/SG/LR_SG02_QP2__Output_Plot_sg02.xlsx', sheet = 'Node 25 - Inventoried trees')
sg_mix <- read.xlsx('2_simanfor/output_EN/SG/LR_SG02_mix__Output_Plot_sg02.xlsx', sheet = 'Node 23 - Inventoried trees')

so_control <- read.xlsx('2_simanfor/output_EN/SO/LR_SO02_control__Output_Plot_so02.xlsx', sheet = 'Node 15 - Inventoried trees')
so_expertos <- read.xlsx('2_simanfor/output_EN/SO/LR_SO02_expertos__Output_Plot_so02.xlsx', sheet = 'Node 30 - Inventoried trees')
so_qp2 <- read.xlsx('2_simanfor/output_EN/SO/LR_SO02_QP2__Output_Plot_so02.xlsx', sheet = 'Node 25 - Inventoried trees')
so_mix <- read.xlsx('2_simanfor/output_EN/SO/LR_SO02_mix__Output_Plot_so02.xlsx', sheet = 'Node 25 - Inventoried trees')

# assign scnr code
sg_control$id_scnr <- 'control'
sg_expertos$id_scnr <- 'expertos'
sg_qp2$id_scnr <- 'qp2'
sg_mix$id_scnr <- 'mix'

so_control$id_scnr <- 'control'
so_expertos$id_scnr <- 'expertos'
so_qp2$id_scnr <- 'qp2'
so_mix$id_scnr <- 'mix'

# make a list of dfs
list_of_dfs <- list(sg_control, sg_expertos, sg_qp2, sg_mix, so_control, so_expertos, so_qp2, so_mix)

# manage all dfs
all_plots <- data.frame()

for (k in list_of_dfs){
  
  # delete I and M trees
  k <- k[is.na(k$status), ]
  
  # create dbh classes
  plot <- plyr::ddply(k, c('Plot_ID', 'id_scnr'), summarise,      
                      CD_0_75 = sum(ifelse(dbh <= 7.5, expan, 0), na.rm = TRUE),
                      CD_75_125 = sum(ifelse(dbh > 7.5 & dbh <= 12.5, expan, 0), na.rm = TRUE),
                      CD_125_175 = sum(ifelse(dbh > 12.5 & dbh <= 17.5, expan, 0), na.rm = TRUE),
                      CD_175_225 = sum(ifelse(dbh > 17.5 & dbh <= 22.5, expan, 0), na.rm = TRUE),
                      CD_225_275 = sum(ifelse(dbh > 22.5 & dbh <= 27.5, expan, 0), na.rm = TRUE),
                      CD_275_325 = sum(ifelse(dbh > 27.5 & dbh <= 32.5, expan, 0), na.rm = TRUE),
                      CD_325_375 = sum(ifelse(dbh > 32.5 & dbh <= 37.5, expan, 0), na.rm = TRUE),
                      CD_375_425 = sum(ifelse(dbh > 37.5 & dbh <= 42.5, expan, 0), na.rm = TRUE),
                      CD_425_ = sum(ifelse(dbh > 42.5, expan, 0), na.rm = TRUE)
  )
  
  # organize data
  plot <- select(plot, -c(Plot_ID, id_scnr))
  plot <- data.frame(t(plot))
  plot <- dplyr::rename(plot, N = t.plot.)
  
  plot$CD <- c(5, 10, 15, 20, 25, 30, 35, 40, 45)
  plot$Inventory_ID <- paste(unique(toupper(k$Plot_ID)), unique(k$id_scnr), sep = '_')
  plot$Plot_ID <- unique(toupper(k$Plot_ID))
  plot$Scenario <- unique(k$id_scnr)
  
  # round to units
  plot$N <- round(plot$N, digits = 0)
  
  # add plot to the main df
  all_plots <- rbind(all_plots, plot)
}

# rename scenarios
all_plots$Scenario <- gsub('qp2', 'gal', all_plots$Scenario)
all_plots$Scenario <- gsub('expertos', 'cyl', all_plots$Scenario)


#### Graph results ####

# graph joined
ggplot(all_plots, aes(x = CD, y = N, fill = Scenario)) +
  
  # data and labels
  geom_bar(stat = 'identity', position = position_dodge()) +
  # geom_text(aes(label = N), hjust = 0, vjust = -1.5, size = 5, color = 'darkred') +
  
  # titles
  labs(# title = 'Diametric distribution obtained after simulate different scenarios',
       x = 'Diametric class (cm)',
       y = 'Density (trees/ha)') +
  
  # theme
  theme_minimal() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        plot.title = element_text(size = 20, hjust = 0.5), # title
        plot.subtitle = element_text(size = 15, hjust = 0.5, face = "italic"),
        axis.title = element_text(size = 15, face = 'bold'),  # axis
        axis.text = element_text(size = 14),  # axis text
        legend.title = element_text(size = 15),  # legend title
        legend.position = 'bottom',  # legend position
        legend.text = element_text(size = 14)) +  # legend content
  scale_fill_manual(name = 'Scenarios', values = c('#708090', '#228B22', '#FF7F50', '#DAA520')) + 
  
  # split by plot
  facet_wrap(~ Plot_ID) +  #, scales = 'free')
  theme(strip.text.x = element_text(size = 15, face = 'bold'))

# ggsave(filename = '4_figures/1_dbh_distribution_simulation_1.png', device = 'png', units = 'mm', dpi = 600,
#        width = 450, height = 300)  
ggsave(filename = '4_figures/resized/1_dbh_distribution_simulation_1.png', device = 'png', units = 'mm', dpi = 300,
       width = 450, height = 300)  

rm(list = ls())


#### Uneven-aged stands management ####

# data
sg_control <- read.xlsx('2_simanfor/output_EN/SG_irregular/LR_irregular_control__Output_Plot_sg02_mix.xlsx', sheet = 'Node 15 - Inventoried trees')
sg_expertos <- read.xlsx('2_simanfor/output_EN/SG_irregular/LR_irregular_expertos__Output_Plot_sg02_mix.xlsx', sheet = 'Node 24 - Inventoried trees')
sg_mix <- read.xlsx('2_simanfor/output_EN/SG_irregular/LR_irregular_mix__Output_Plot_sg02_mix.xlsx', sheet = 'Node 28 - Inventoried trees')
sg_qp2 <- read.xlsx('2_simanfor/output_EN/SG_irregular/LR_irregular_QP2__Output_Plot_sg02_mix.xlsx', sheet = 'Node 24 - Inventoried trees')

so_control <- read.xlsx('2_simanfor/output_EN/SO_irregular/LR_irregular_control__Output_Plot_so02_mix.xlsx', sheet = 'Node 15 - Inventoried trees')
so_expertos <- read.xlsx('2_simanfor/output_EN/SO_irregular/LR_irregular_expertos__Output_Plot_so02_mix.xlsx', sheet = 'Node 24 - Inventoried trees')
so_mix <- read.xlsx('2_simanfor/output_EN/SO_irregular/LR_irregular_mix__Output_Plot_so02_mix.xlsx', sheet = 'Node 28 - Inventoried trees')
so_qp2 <- read.xlsx('2_simanfor/output_EN/SO_irregular/LR_irregular_QP2__Output_Plot_so02_mix.xlsx', sheet = 'Node 24 - Inventoried trees')

# assign scnr code
sg_control$id_scnr <- 'control'
sg_expertos$id_scnr <- 'expertos'
sg_qp2$id_scnr <- 'qp2'
sg_mix$id_scnr <- 'mix'

so_control$id_scnr <- 'control'
so_expertos$id_scnr <- 'expertos'
so_qp2$id_scnr <- 'qp2'
so_mix$id_scnr <- 'mix'

# make a list of dfs
list_of_dfs <- list(sg_control, sg_expertos, sg_qp2, sg_mix, so_control, so_expertos, so_qp2, so_mix)

# manage all dfs
all_plots <- data.frame()

for (k in list_of_dfs){
  
  # delete I and M trees
  k <- k[is.na(k$status), ]
  
  # create dbh classes
  plot <- plyr::ddply(k, c('Plot_ID', 'id_scnr'), summarise,      
                      CD_0_75 = sum(ifelse(dbh <= 7.5, expan, 0), na.rm = TRUE),
                      CD_75_125 = sum(ifelse(dbh > 7.5 & dbh <= 12.5, expan, 0), na.rm = TRUE),
                      CD_125_175 = sum(ifelse(dbh > 12.5 & dbh <= 17.5, expan, 0), na.rm = TRUE),
                      CD_175_225 = sum(ifelse(dbh > 17.5 & dbh <= 22.5, expan, 0), na.rm = TRUE),
                      CD_225_275 = sum(ifelse(dbh > 22.5 & dbh <= 27.5, expan, 0), na.rm = TRUE),
                      CD_275_325 = sum(ifelse(dbh > 27.5 & dbh <= 32.5, expan, 0), na.rm = TRUE),
                      CD_325_375 = sum(ifelse(dbh > 32.5 & dbh <= 37.5, expan, 0), na.rm = TRUE),
                      CD_375_425 = sum(ifelse(dbh > 37.5 & dbh <= 42.5, expan, 0), na.rm = TRUE),
                      CD_425_ = sum(ifelse(dbh > 42.5, expan, 0), na.rm = TRUE)
  )
  
  # organize data
  plot <- select(plot, -c(Plot_ID, id_scnr))
  plot <- data.frame(t(plot))
  plot <- dplyr::rename(plot, N = t.plot.)
  
  plot$CD <- c(5, 10, 15, 20, 25, 30, 35, 40, 45)
  plot$Inventory_ID <- paste(unique(toupper(k$Plot_ID)), unique(k$id_scnr), sep = '_')
  plot$Plot_ID <- unique(toupper(k$Plot_ID))
  plot$Scenario <- unique(k$id_scnr)
  
  # round to units
  plot$N <- round(plot$N, digits = 0)
  
  # add plot to the main df
  all_plots <- rbind(all_plots, plot)
}

# rename scenarios
all_plots$Escenario <- gsub('qp2', 'gal', all_plots$Scenario)
all_plots$Escenario <- gsub('expertos', 'cyl', all_plots$Scenario)

# and plots
all_plots$Plot_ID <- gsub('SG02_MIX', 'SG02 ', all_plots$Plot_ID)
all_plots$Plot_ID <- gsub('SO02_MIX', 'SO02 ', all_plots$Plot_ID)


#### Graph results ####

# graph joined
ggplot(all_plots, aes(x = CD, y = N, fill = Escenario)) +
  
  # data and labels
  geom_bar(stat = 'identity', position = position_dodge()) +
  # geom_text(aes(label = N), hjust = 0, vjust = -1.5, size = 5, color = 'darkred') +
  
  # titles
  labs(# title = 'Diametric distribution obtained after simulate different scenarios',
       x = 'Diametric class (cm)',
       y = 'Density (trees/ha)') +
  
  # theme
  theme_minimal() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        plot.title = element_text(size = 20, hjust = 0.5), # title
        plot.subtitle = element_text(size = 15, hjust = 0.5, face = "italic"),
        axis.title = element_text(size = 15, face = 'bold'),  # axis
        axis.text = element_text(size = 14),  # axis text
        legend.title = element_text(size = 15),  # legend title
        legend.position = 'bottom',  # legend position
        legend.text = element_text(size = 14)) +  # legend content
  scale_fill_manual(name = 'Scenarios', values = c('#708090', '#228B22', '#FF7F50', '#DAA520')) + 
  
  # split by plot
  facet_wrap(~ Plot_ID) +  #, scales = 'free')
  theme(strip.text.x = element_text(size = 15, face = 'bold'))

# ggsave(filename = '4_figures/1_dbh_distribution_simulation_2.png', device = 'png', units = 'mm', dpi = 600,
#        width = 450, height = 300)  
ggsave(filename = '4_figures/resized/1_dbh_distribution_simulation_2.png', device = 'png', units = 'mm', dpi = 300,
       width = 450, height = 300) 


# #### Uneven-aged stands management - stand evolution ####
# 
# 
# ----- no funcionando de momento
# 
# 
# 
# setwd('/media/aitor/WDE/iuFOR_trabajo/Proyectos/Life_Rebollo/0_Entregable_C11/2_simanfor/4_septiembre_23/output/')
# 
# # data
# 
# # Segovia
# sg_control <- read.xlsx('irregular/LR_irregular_control__Output_Plot_sg02_mix.xlsx', sheet = 'Node 16 - Inventoried trees')
# 
# sg_expertos <- read.xlsx('irregular/LR_irregular_expertos__Output_Plot_sg02_mix.xlsx', sheet = 'Node 29 - Inventoried trees')
# sg_expertos_50 <- read.xlsx('irregular/LR_irregular_expertos__Output_Plot_sg02_mix.xlsx', sheet = 'Node 6 - Inventoried trees')
# sg_expertos_80 <- read.xlsx('irregular/LR_irregular_expertos__Output_Plot_sg02_mix.xlsx', sheet = 'Node 15 - Inventoried trees')
# sg_expertos_120 <- read.xlsx('irregular/LR_irregular_expertos__Output_Plot_sg02_mix.xlsx', sheet = 'Node 23 - Inventoried trees')
# 
# sg_mix <- read.xlsx('irregular/LR_irregular_mix__Output_Plot_sg02_mix.xlsx', sheet = 'Node 35 - Inventoried trees')
# sg_mix_50 <- read.xlsx('irregular/LR_irregular_mix__Output_Plot_sg02_mix.xlsx', sheet = 'Node 6 - Inventoried trees')
# sg_mix_80 <- read.xlsx('irregular/LR_irregular_mix__Output_Plot_sg02_mix.xlsx', sheet = 'Node 18 - Inventoried trees')
# sg_mix_120 <- read.xlsx('irregular/LR_irregular_mix__Output_Plot_sg02_mix.xlsx', sheet = 'Node 28 - Inventoried trees')
# 
# sg_qp2 <- read.xlsx('irregular/LR_irregular_QP2__Output_Plot_sg02_mix.xlsx', sheet = 'Node 29 - Inventoried trees')
# sg_qp2_50 <- read.xlsx('irregular/LR_irregular_QP2__Output_Plot_sg02_mix.xlsx', sheet = 'Node 6 - Inventoried trees')
# sg_qp2_80 <- read.xlsx('irregular/LR_irregular_QP2__Output_Plot_sg02_mix.xlsx', sheet = 'Node 15 - Inventoried trees')
# sg_qp2_120 <- read.xlsx('irregular/LR_irregular_QP2__Output_Plot_sg02_mix.xlsx', sheet = 'Node 23 - Inventoried trees')
# 
# # Soria
# so_control <- read.xlsx('irregular/LR_irregular_control__Output_Plot_so02_mix.xlsx', sheet = 'Node 16 - Inventoried trees')
# 
# so_expertos <- read.xlsx('irregular/LR_irregular_expertos__Output_Plot_so02_mix.xlsx', sheet = 'Node 29 - Inventoried trees')
# so_expertos_50 <- read.xlsx('irregular/LR_irregular_expertos__Output_Plot_so02_mix.xlsx', sheet = 'Node 6 - Inventoried trees')
# so_expertos_80 <- read.xlsx('irregular/LR_irregular_expertos__Output_Plot_so02_mix.xlsx', sheet = 'Node 15 - Inventoried trees')
# so_expertos_120 <- read.xlsx('irregular/LR_irregular_expertos__Output_Plot_so02_mix.xlsx', sheet = 'Node 23 - Inventoried trees')
# 
# so_mix <- read.xlsx('irregular/LR_irregular_mix__Output_Plot_so02_mix.xlsx', sheet = 'Node 35 - Inventoried trees')
# so_mix_50 <- read.xlsx('irregular/LR_irregular_mix__Output_Plot_so02_mix.xlsx', sheet = 'Node 6 - Inventoried trees')
# so_mix_80 <- read.xlsx('irregular/LR_irregular_mix__Output_Plot_so02_mix.xlsx', sheet = 'Node 18 - Inventoried trees')
# so_mix_120 <- read.xlsx('irregular/LR_irregular_mix__Output_Plot_so02_mix.xlsx', sheet = 'Node 28 - Inventoried trees')
# 
# so_qp2 <- read.xlsx('irregular/LR_irregular_QP2__Output_Plot_so02_mix.xlsx', sheet = 'Node 29 - Inventoried trees')
# so_qp2_50 <- read.xlsx('irregular/LR_irregular_QP2__Output_Plot_so02_mix.xlsx', sheet = 'Node 6 - Inventoried trees')
# so_qp2_80 <- read.xlsx('irregular/LR_irregular_QP2__Output_Plot_so02_mix.xlsx', sheet = 'Node 15 - Inventoried trees')
# so_qp2_120 <- read.xlsx('irregular/LR_irregular_QP2__Output_Plot_so02_mix.xlsx', sheet = 'Node 23 - Inventoried trees')
# 
# # assign scnr code
# sg_control$id_scnr <- 'control'
# sg_expertos$id_scnr <- 'expertos'
# sg_qp2$id_scnr <- 'qp2'
# sg_mix$id_scnr <- 'mix'
# sg_expertos_50$id_scnr <- 'expertos_50'
# sg_qp2_50$id_scnr <- 'qp2_50'
# sg_mix_50$id_scnr <- 'mix_50'
# sg_expertos_80$id_scnr <- 'expertos_80'
# sg_qp2_80$id_scnr <- 'qp2_80'
# sg_mix_80$id_scnr <- 'mix_80'
# sg_expertos_120$id_scnr <- 'expertos_120'
# sg_qp2_120$id_scnr <- 'qp2_120'
# sg_mix_120$id_scnr <- 'mix_120'
# 
# so_control$id_scnr <- 'control'
# so_expertos$id_scnr <- 'expertos'
# so_qp2$id_scnr <- 'qp2'
# so_mix$id_scnr <- 'mix'
# so_expertos_50$id_scnr <- 'expertos_50'
# so_qp2_50$id_scnr <- 'qp2_50'
# so_mix_50$id_scnr <- 'mix_50'
# so_expertos_80$id_scnr <- 'expertos_80'
# so_qp2_80$id_scnr <- 'qp2_80'
# so_mix_80$id_scnr <- 'mix_80'
# so_expertos_120$id_scnr <- 'expertos_120'
# so_qp2_120$id_scnr <- 'qp2_120'
# so_mix_120$id_scnr <- 'mix_120'
# 
# # assign main scnr code
# sg_control$id_main_scnr <- 'control'
# sg_expertos$id_main_scnr <- 'expertos'
# sg_qp2$id_main_scnr <- 'qp2'
# sg_mix$id_main_scnr <- 'mix'
# sg_expertos_50$id_main_scnr <- 'expertos'
# sg_qp2_50$id_main_scnr <- 'qp2'
# sg_mix_50$id_main_scnr <- 'mix'
# sg_expertos_80$id_main_scnr <- 'expertos'
# sg_qp2_80$id_main_scnr <- 'qp2'
# sg_mix_80$id_main_scnr <- 'mix'
# sg_expertos_120$id_main_scnr <- 'expertos'
# sg_qp2_120$id_main_scnr <- 'qp2'
# sg_mix_120$id_main_scnr <- 'mix'
# 
# so_control$id_main_scnr <- 'control'
# so_expertos$id_main_scnr <- 'expertos'
# so_qp2$id_main_scnr <- 'qp2'
# so_mix$id_main_scnr <- 'mix'
# so_expertos_50$id_main_scnr <- 'expertos'
# so_qp2_50$id_main_scnr <- 'qp2'
# so_mix_50$id_main_scnr <- 'mix'
# so_expertos_80$id_main_scnr <- 'expertos'
# so_qp2_80$id_main_scnr <- 'qp2'
# so_mix_80$id_main_scnr <- 'mix'
# so_expertos_120$id_main_scnr <- 'expertos'
# so_qp2_120$id_main_scnr <- 'qp2'
# so_mix_120$id_main_scnr <- 'mix'
# 
# # make a list of dfs
# list_of_dfs <- list(sg_control, sg_expertos, sg_qp2, sg_mix, so_control, so_expertos, so_qp2, so_mix,
#                     sg_expertos_50, sg_qp2_50, sg_mix_50, so_expertos_50, so_qp2_50, so_mix_50,
#                     sg_expertos_80, sg_qp2_80, sg_mix_80, so_expertos_80, so_qp2_80, so_mix_80,
#                     sg_expertos_120, sg_qp2_120, sg_mix_120, so_expertos_120, so_qp2_120, so_mix_120)
# 
# # manage all dfs
# all_plots <- data.frame()
# 
# for (k in list_of_dfs){
#   
#   # delete I and M trees
#   k <- k[is.na(k$estado), ]
#   
#   # create dbh classes
#   plot <- plyr::ddply(k, c('ID_parcela', 'id_scnr'), summarise,      
#                       CD_0_75 = sum(ifelse(dbh <= 7.5, factor_expansion, 0), na.rm = TRUE),
#                       CD_75_125 = sum(ifelse(dbh > 7.5 & dbh <= 12.5, factor_expansion, 0), na.rm = TRUE),
#                       CD_125_175 = sum(ifelse(dbh > 12.5 & dbh <= 17.5, factor_expansion, 0), na.rm = TRUE),
#                       CD_175_225 = sum(ifelse(dbh > 17.5 & dbh <= 22.5, factor_expansion, 0), na.rm = TRUE),
#                       CD_225_275 = sum(ifelse(dbh > 22.5 & dbh <= 27.5, factor_expansion, 0), na.rm = TRUE),
#                       CD_275_325 = sum(ifelse(dbh > 27.5 & dbh <= 32.5, factor_expansion, 0), na.rm = TRUE),
#                       CD_325_375 = sum(ifelse(dbh > 32.5 & dbh <= 37.5, factor_expansion, 0), na.rm = TRUE),
#                       CD_375_425 = sum(ifelse(dbh > 37.5 & dbh <= 42.5, factor_expansion, 0), na.rm = TRUE),
#                       CD_425_ = sum(ifelse(dbh > 42.5, factor_expansion, 0), na.rm = TRUE)
#   )
#   
#   # organize data
#   plot <- select(plot, -c(ID_parcela, id_scnr))
#   plot <- data.frame(t(plot))
#   plot <- dplyr::rename(plot, N = t.plot.)
#   
#   plot$CD <- c(5, 10, 15, 20, 25, 30, 35, 40, 45)
#   plot$ID_Inventario <- paste(unique(toupper(k$ID_parcela)), unique(k$id_scnr), sep = '_')
#   plot$ID_Parcela <- unique(toupper(k$ID_parcela))
#   plot$Escenario_especifico <- unique(k$id_scnr)
#   plot$Escenario <- unique(k$id_main_scnr)
#   
#   # round to units
#   plot$N <- round(plot$N, digits = 0)
#   
#   # code to split graphs
#   plot$code <- ifelse(plot$Escenario %in% c('control', 'expertos', 'qp2', 'mix'), 'general', '')
#   plot_copy <- plot
#   plot$code <- ifelse(plot$Escenario %in% c('expertos', 'expertos_50', 'expertos_80', 'expertos_120'), 'expertos', plot$code)
#   plot$code <- ifelse(plot$Escenario %in% c('mix', 'mix_50', 'mix_80', 'mix_120'), 'mix', plot$code)
#   plot$code <- ifelse(plot$Escenario %in% c('qp2', 'qp2_50', 'qp2_80', 'qp2_120'), 'qp2', plot$code)
#   
#   # duplicate just coincidence into 'general' and others
#   if(plot_copy$code[1] == 'general'){plot <- rbind(plot, plot_copy)}
#   
#   # add plot to the main df
#   all_plots <- rbind(all_plots, plot)
# }
# 
# 
# #### Graph results ####
# 
# all_plots_general <- all_plots[all_plots$code == 'general',]
# 
# # graph joined
# ggplot(all_plots, aes(x = CD, y = N, fill = Escenario)) +
#   
#   # data and labels
#   geom_bar(stat = 'identity', position = position_dodge()) +
#   geom_text(aes(label = N), hjust = 0, vjust = -1, size = 5, color = 'darkred') +
#   
#   # titles
#   labs(title = 'Distribución diamétrica resultante de la simulación',
#        x = 'Clase Diamétrica (cm)',
#        y = 'Densidad (pies/ha)') +
#   
#   # theme
#   theme_minimal() +
#   theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
#         plot.title = element_text(hjust = 0.5),
#         legend.title = element_text(hjust = 0.5)) +
#   scale_fill_manual(values = c('lightgrey', 'darkgray', '#6A84E0', 'black')) + 
#   
#   # split by plot
#   facet_wrap(~ ID_Parcela, scales = 'free')
# 
# ggsave(filename = '../graphs/dbh/dbh_resultados_irregulares.png', device = 'png', units = 'mm', dpi = 300,
#        width = 300, height = 300)  
