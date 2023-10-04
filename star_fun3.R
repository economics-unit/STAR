
library(ggplot2)
library(readxl)
library(writexl)
library(reshape2)
library(dplyr)

# STAR function that allows you to compare two different efficeincy frontiers 

star_fun_comp <- function(data_spec, data_spec_1, title = "", legend_change = "", filter = c("Management of exacerbations" ,  "Tertiary Prevention","Primary Prevention","Secondary prevention / diagnosis","Stable Management")) {
  

  my_theme2 <- function() {
    theme_minimal() +
      theme(legend.position = "right",legend.justification='right',
            legend.text = element_text(size = 9), legend.title = element_blank(),
            legend.key.size = unit(0.3, "cm"),
            axis.title = element_text(size = 12), axis.text = element_text(size = 11),
            axis.title.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 5)),
            axis.title.x = element_text(margin = margin(t = 5, r = 5, b = 0, l = 5)),
            strip.background = element_rect(color="white", fill="#EAEAEA", size=1.5))
  }


HEU_palette <- c("#330000", "#CC0000", "#FF9999", "#FF8000", "#FFFF00", "#99FF33",
                 "99FF33", "#009999", "#33FFFF", "#004C99", "#006600", "#66B2FF", "#000099"
                 ,"#9999FF", "#9933FF", "#99004C",  "#FF3399", "#808080", "#ADE6BF",
                 "#2E3B39", "#485B5B", "#62777B", "#7C929B", "#FFCCCC",   
                 "#C5D9DA")


# convert data into STAR metrics (total costs for x axis and population health benefit for y axis)
# also order graph by value for money


df2_vfm <- dcast(data_spec, pathway_component + intervention_code + intervention ~ metric_type
                  , value.var = "metric_total")  %>%
  mutate(tot_cost = round((Cost*n_treated/1000),0), ## Thousands
         pop_health_ben = round((NWB * benefit)/1000,0), 
         vfm = pop_health_ben/tot_cost) %>% 
  mutate(alpha = atan(pop_health_ben/tot_cost)*180/pi) %>%
  filter(pathway_component %in% filter) %>%
  arrange(desc(alpha))

df3_vfm <- dcast(data_spec_1, pathway_component + intervention_code + intervention ~ metric_type
                 , value.var = "metric_total")  %>%
  mutate(tot_cost = round((Cost*n_treated/1000),0), ## Thousands
         pop_health_ben = round((NWB * benefit)/1000,0), 
         vfm = pop_health_ben/tot_cost) %>% 
  mutate(alpha = atan(pop_health_ben/tot_cost)*180/pi) %>%
  filter(pathway_component %in% filter) %>%
  arrange(desc(alpha))



## INPUTS ####
## function that creates the efficiency frontier from data input ##

efficiency_frontier <- function(dataframe) { 
  cost <- dataframe[,"Cost"]
  nwb <- dataframe[, "NWB"]
  benefit <- dataframe[, "benefit"]
  n_treated <- dataframe[,"n_treated"]
  intervention <- dataframe[,"intervention"]
  alpha <- dataframe[,"alpha"]
  pathway_component <- dataframe[,"pathway_component"]

  

  
  ########### Total Cost   
  ### x_vec function that will outline the x-axis values for the geom_polygon
  
  ### x_vec function that will outline the x-axes values for the geom_polygon
  x_vec <- function(cost,n_treated) {
    m <- c()
    c <- round((cost[1] * n_treated[1])/1000,0) #  000s
    m <- c(0,c,c)
    a <- 2
    d <- 0
    for (i in 2:length(n_treated)) {
      b <- a-1
      d <- round((cost[b] * n_treated[b])/1000,0) + d ## thousands
      c <- round((cost[a] * n_treated[a])/1000,0) + c ## thousands
      m <- c(m,d,c,c)
      a <- a+1
    }
    return(unlist(m))
  }
  
 # x_vec(cost,n_treated)
  
  ####### population health benefit 
  ### y_vec function that makes the data points on the y axis ###
  
  # the product of the number (Nj) of patients who benefit from the intervention 
  # and the potential benefit (Bj) in quality (and length) of life

  y_vec <- function(nwb,benefit) {
    m <- c()
    c <- round((nwb[1] * benefit[1])/1000,0)
    m <- c(m,0,0,c)
    a <- 2
    for (i in 2:length(nwb)) {
      b <- a-1
      d <- c
      c <- round(((nwb[a] * benefit[a]))/1000,0) + d 
      m <- c(m,d,d,c)
      a <- a+1
    }
    return(unlist(m))
  }
  
  
  ###t_vec to group the vectors by intervention. ##### 
  
  
  t_vec <- function(intervention){
    a <- 1
    m <- c()
    for (i in 1:length(intervention)){
      c <-  
        m <- c(m,intervention[a],intervention[a],intervention[a]) 
      a <- a+1
    }
    return(m)
  }
 # t_vec(intervention)
  

  
  ###### the graph ######
  
  
  d <- data.frame(
    x = c(x_vec(cost, n_treated)),
    y =c(y_vec(nwb, benefit)), 
    t=c(t_vec(intervention)))
  

}


vfm <-  efficiency_frontier(df2_vfm) 

vfm_2 <- efficiency_frontier(df3_vfm) 

a<-  ggplot(vfm) +
  geom_polygon(aes(x=x, y=y, group=t, fill = "No change", alpha = 0.5)) + 
  geom_polygon(data = vfm_2, aes(x=x, y=y, group=t,fill = legend_change , alpha = 0.5)) +
  labs(title =  title, x = "\nTotal cost £000s", 
       y = "Population health benefit per 1,000 population\n") + my_theme2() +
  theme(plot.title = element_text(hjust = 0.5)
        , legend.title = element_blank()) 

return(a)

}


star_fun_comp(data_spec, data_spec_1, title = "Value of COPD care pathway in Coventry")



