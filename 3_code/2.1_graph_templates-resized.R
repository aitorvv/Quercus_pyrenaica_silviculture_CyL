#------------------------------------------------------------------------------------------#
####                        Graphs template for SIMANFOR outputs                        ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 15/01/2024                              #
#                              Last modification: 25/04/2025                               #
#------------------------------------------------------------------------------------------#


#### General ####

# function used as a template for most of the graphs
graph_data <- function(df, x, y, class, x_lab, y_lab, path){

  graph <-
    ggplot(df, aes(x = x, y = y, group = class, colour = class)) +  # group by scnr
      
      # text
      labs(# title = "SG02 plot saw volume",  
        # subtitle = "including harvested wood,  
        x = x_lab,  
        y = y_lab   
      ) +
    # plot data
    geom_point() +  # points
    geom_line()+  # lines      
      # text position and size
      theme_minimal() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            plot.title = element_text(size = 20, hjust = 0.5), # title
            plot.subtitle = element_text(size = 15, hjust = 0.5, face = "italic"),
            axis.title = element_text(size = 15, face = 'bold'),  # axis
            axis.text = element_text(size = 14),  # axis text
            legend.title = element_text(size = 15),  # legend title
            legend.position = 'bottom',  # legend position
            legend.text = element_text(size = 14),  # legend content
            panel.background = element_rect(fill = 'white')) +  # legend content
      scale_color_manual(name = 'Scenarios:', values = c('#708090', '#228B22', '#FF7F50', '#DAA520')) 

  # view graph 
  graph
  
  # save graph
  ggsave(filename = path, 
         device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 
  
  # return graph
  return(graph)
}


#### Basal area ####

# function used as a template for basal area graphs
graph_data_g <- function(df, x, y, class, x_lab, y_lab, path){
  
  graph <-
    ggplot(df, aes(x = x, y = y, group = class, colour = class)) +  # group by scnr
    
    # text
    labs(# title = "SG02 plot saw volume",  
      # subtitle = "including harvested wood,  
      x = x_lab,  
      y = y_lab   
    ) +
    
    # text position and size
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          plot.title = element_text(size = 20, hjust = 0.5), # title
          plot.subtitle = element_text(size = 15, hjust = 0.5, face = "italic"),
          axis.title = element_text(size = 15, face = 'bold'),  # axis
          axis.text = element_text(size = 14),  # axis text
          legend.title = element_text(size = 15),  # legend title
          legend.position = 'bottom',  # legend position
          legend.text = element_text(size = 14),  # legend content
          panel.background = element_rect(fill = 'white')) +  # legend content
    scale_color_manual(name = 'Scenarios:', values = c('#708090', '#228B22', '#FF7F50', '#DAA520')) + 
    
    # plot data
    geom_point() +  # points
    geom_line() +  # lines
    
    geom_abline(slope = 0, intercept = 17.5, col = 'red')
  
  
  # view graph 
  graph
  
  # save graph
  ggsave(filename = path, 
         device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 
  
  # return graph
  return(graph)
}


#### Hart-Becking ####

# function used as a template for hart-becking graphs
graph_data_hart <- function(df, x, y, class, x_lab, y_lab, path){
  
  graph <-
    ggplot(df, aes(x = x, y = y, group = class, colour = class)) +  # group by scnr
    
    # text
    labs(# title = "SG02 plot saw volume",  
      # subtitle = "including harvested wood,  
      x = x_lab,  
      y = y_lab   
    ) +
    
    # text position and size
    theme_minimal() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          plot.title = element_text(size = 20, hjust = 0.5), # title
          plot.subtitle = element_text(size = 15, hjust = 0.5, face = "italic"),
          axis.title = element_text(size = 15, face = 'bold'),  # axis
          axis.text = element_text(size = 14),  # axis text
          legend.title = element_text(size = 15),  # legend title
          legend.position = 'bottom',  # legend position
          legend.text = element_text(size = 14),  # legend content
          panel.background = element_rect(fill = 'white')) +  # legend content
    scale_color_manual(name = 'Scenarios:', values = c('#708090', '#228B22', '#FF7F50', '#DAA520')) + 
    
    # plot data
    geom_point() +  # points
    geom_line() +  # lines
    
    geom_abline(slope = 0, intercept = 24, col = 'red') +
    geom_abline(slope = 0, intercept = 28, col = 'red4')
  
  # view graph 
  graph
  
  # save graph
  ggsave(filename = path, 
         device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 
  
  # return graph
  return(graph)
}


#### Graph 2 variables ####

# function used as a template for most of the graphs
graph_data_2vars <- function(df, x, y, y2, class, x_lab, y_lab, path){
  
  graph <-
    ggplot(df, aes(x = x, y = y, group = class, colour = class)) +  # group by scnr
    
    # text
    labs(# title = "SG02 plot saw volume",  
      # subtitle = "including harvested wood,  
      x = x_lab,  
      y = y_lab   
    ) +
    
    # text position and size
    theme_minimal() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          plot.title = element_text(size = 20, hjust = 0.5), # title
          plot.subtitle = element_text(size = 15, hjust = 0.5, face = "italic"),
          axis.title = element_text(size = 15, face = 'bold'),  # axis
          axis.text = element_text(size = 14),  # axis text
          legend.title = element_text(size = 15),  # legend title
          legend.position = 'bottom',  # legend position
          legend.text = element_text(size = 14),  # legend content
          panel.background = element_rect(fill = 'white')) +  # legend content
    scale_color_manual(name = 'Scenarios:', values = c('#708090', '#228B22', '#FF7F50', '#DAA520')) + 
    
    # plot data
    geom_point() +  # points
    geom_line() +  # lines
  
    # plot extra data
    geom_point(shape = 0, aes(x = x, y = y2,
                              group = class, colour = class)) +  # points
    geom_line(aes(x = x, y = y2,
                    group = class, colour = class))   # lines
  
  # view graph 
  graph
  
  # save graph
  ggsave(filename = path, 
         device = 'png', units = 'mm', dpi = 300, width = 300, height = 300) 
  
  # return graph
  return(graph)
}