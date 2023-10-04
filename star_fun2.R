
library(ggplot2)
library(readxl)
library(writexl)
library(reshape2)
library(dplyr)
library(ggrepel)


star_fun <- function(data_spec, title, filter = c("Management of exacerbations" ,  "Tertiary Prevention","Primary Prevention","Secondary prevention / diagnosis","Stable Management")) {
  

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


## arrange by vfm


df2_vfm <- dcast(data_spec, pathway_component + intervention_code + intervention ~ metric_type
                 , value.var = "metric_total")  %>%
  mutate(tot_cost = round((Cost*n_treated/1000),0), ## Thousands
         pop_health_ben = round((NWB * benefit)/1000,0), 
         vfm = pop_health_ben/tot_cost) %>% 
  mutate(alpha = atan(pop_health_ben/tot_cost)*180/pi) %>%
  arrange(desc(alpha))


### Checking main calcs for plots
#calcs <- df2_vfm %>%
# mutate(tot_cost = round((Cost*n_treated)/1000,0), ## Thousands
#         pop_health_ben = NWB * benefit/1000, 
#         benefit_pp = benefit, #??? 
#         vfm = pop_health_ben/tot_cost,
#         percent_spend = tot_cost/sum(tot_cost) * 100,
#         percent_ben = pop_health_ben / sum(pop_health_ben) * 100) %>% 
#  arrange(vfm) %>%
#  mutate(additional_vfm = lag(lead(vfm) - vfm),
#         additional_vfm = ifelse(is.na(additional_vfm), vfm, additional_vfm),
#                                 alpha = atan(pop_health_ben/tot_cost)*180/pi# for the angle of the triangles
#  ) %>%
#  select(intervention,n_treated, NWB, benefit,tot_cost, pop_health_ben, benefit_pp, vfm, additional_vfm,percent_spend, percent_ben,alpha)


## INPUTS ####
efficiency_frontier <- function(dataframe) { 
  cost <- dataframe[,"Cost"]
  nwb <- dataframe[, "NWB"]
  benefit <- dataframe[, "benefit"]
  n_treated <- dataframe[,"n_treated"]
  intervention <- dataframe[,"intervention"]
  alpha <- dataframe[,"alpha"]
  pathway_component <- dataframe[,"pathway_component"]

  

  
  ########### Cost (cj)
  # Total cost of treating all
  
  ### x_vec function that will outline the x-axes values for the geom_polygon
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
  
  ####### population health benefit (Nj*Bj) 
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
  
  
  ###t_vec to group the vectors. ##### 
  
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
  
  # f_wrap_vec for facet wrappig by pathway component ##
  

  
  ###### the graph ######
  
  
  d <- data.frame(
    x = c(x_vec(cost, n_treated)),
    y =c(y_vec(nwb, benefit)), 
    t=c(t_vec(intervention)))
  

}


vfm <-  efficiency_frontier(df2_vfm) 



a<- vfm  %>% ggplot() +
  geom_polygon(aes(x=x, y=y, group=t,fill = t)) + 
  labs(title =  title, x = "\nTotal cost £000s", 
       y = "Population health benefit per 1,000 population\n")+ geom_text_repel(aes(x=x,y=y, label = t, hjust = -1,vjust = 0.5), 
data = . %>% 
  filter(row_number() %% 3 == 2 | row_number() == 0), size = 2) + my_theme2() +
  theme(plot.title = element_text(hjust = 0.5)
        , legend.position = "none") + 
  scale_fill_manual(values = HEU_palette) 


return(a)

}

#star_fun




