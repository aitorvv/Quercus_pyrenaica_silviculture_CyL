#------------------------------------------------------------------------------------------#
####                      Diametric distribution - Life Rebollo                         ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 19/09/2023                              #
#                              Last modification: 03/10/2024                               #
#------------------------------------------------------------------------------------------#

library(openxlsx)
library(ggplot2)
library(dplyr)

setwd('/media/aitor/WDE/PhD_UVa/1_Topics/1_LifeRebollo-silviculture/')

# data
so <- read.xlsx('1_data/SO02_regular.xlsx', sheet = 'Parcelas')
sg <- read.xlsx('1_data/SG02_irregular.xlsx', sheet = 'Parcelas')

# extract data
so <- select(so, c("CD_0_75", "CD_75_125", "CD_125_175", "CD_175_225", "CD_225_275", 
                   "CD_275_325", "CD_325_375", "CD_375_425", "CD_425_"))
sg <- select(sg, c("CD_0_75", "CD_75_125", "CD_125_175", "CD_175_225", "CD_225_275", 
                   "CD_275_325", "CD_325_375", "CD_375_425", "CD_425_"))
             
# organize data
so <- data.frame(t(so))
sg <- data.frame(t(sg))

so <- dplyr::rename(so, N = X1)
sg <- dplyr::rename(sg, N = X1)

so$CD <- c(5, 10, 15, 20, 25, 30, 35, 40, 45)
sg$CD <- c(5, 10, 15, 20, 25, 30, 35, 40, 45)

so$Inventario <- 'SO02'
sg$Inventario <- 'SG02'

# unir df
df <- rbind(so, sg)

# round to units
df$N <- round(df$N, digits = 0)

# graph joined
ggplot(df, aes(x = CD, y = N, fill = Inventario)) +
  
  # data and labels
  geom_bar(stat = 'identity', position = position_dodge()) +
  # geom_text(aes(label = N), hjust = 0, vjust = -1.5, size = 5, color = 'darkred') +
  
  # titles
  labs(#title = 'Diametric distribution of the inventory plots used on simulations',
       x = 'Diametric class (cm)',
       y = 'Density (trees/ha)') +
  
  # theme
  theme_minimal() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        plot.title = element_text(size = 20, hjust = 0.5), # title
        plot.subtitle = element_text(size = 15, hjust = 0.5, face = "italic"),
        axis.title = element_text(size = 20),  # axis
        axis.text = element_text(size = 17),  # axis text
        legend.title = element_text(size = 20),  # legend title
        legend.position = 'bottom',  # legend position
        legend.text = element_text(size = 17)) +  # legend content
  
  scale_fill_manual(name = 'Inventory', values = c('grey', 'black'))

# ggsave(filename = '4_figures/0_dbh_distribution_inventory.png', device = 'png', units = 'mm', dpi = 600,
# width = 450, height = 300)    
ggsave(filename = '4_figures/resized/0_dbh_distribution_inventory.png', device = 'png', units = 'mm', dpi = 300,
       width = 300, height = 300)    
