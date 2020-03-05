library(gridExtra)
library(ggplot2)
library(tidyverse)
#var_tri = c("hil_amp_low","hil_amp_high","diff_ibi","order")
var_tri = c("prev_ibi", "next_ibi")

peaks2= c("P250", "N300")
setwd("Z:/modulation_HER_florian_2019/Data/2nd ana bis")
load('peak_stat_Poci.Rdata')
#%%
for (j in peaks2){
  for (i in var_tri){
    new_dtf= filter(dtf, var.tri == i, electrodes=="PoCi_1_PoCi_2", peak==j)
    plot1 <- ggplot(new_dtf, aes(x=bin, y=p2p.amp))+
      geom_line() +
      ylab("amplitude in µV")+
      ggtitle('amplitude p2p')+
      theme(plot.title = element_text(size = 10))
    
    
    plot2 <-  ggplot(new_dtf, aes(x=bin, y=p2p.lat))+
      geom_line() +
      ylab("latence in s")+
      ggtitle('latence p2p')+
      theme(plot.title = element_text(size = 10))
    
    
    plot3 <- ggplot(new_dtf, aes(x=bin, y=amplitude))+
      geom_line() +
      ylab("amplitude in µV")+
      ggtitle('amplitude')+
      theme(plot.title = element_text(size = 10))
    
    plot4 <-  ggplot(new_dtf, aes(x=bin, y=latence))+
      geom_line() +
      ylab("latence in s")+
      ggtitle('latence')+
      theme(plot.title = element_text(size = 10))
    
    #
    new_dtf= filter(dtf, var.tri == i, electrodes=="PoCi_2_PoCi_3", peak==j)
    plot5 <- ggplot(new_dtf, aes(x=bin, y=p2p.amp))+
      geom_line() +
      ylab("amplitude in µV")+
      ggtitle('amplitude p2p')+
      theme(plot.title = element_text(size = 10))
    
    
    plot6 <-  ggplot(new_dtf, aes(x=bin, y=p2p.lat))+
      geom_line() +
      ylab("latence in s")+
      ggtitle('latence p2p')+
      theme(plot.title = element_text(size = 10))
    
    
    plot7 <- ggplot(new_dtf, aes(x=bin, y=amplitude))+
      geom_line() +
      ylab("amplitude in µV")+
      ggtitle('amplitude')+
      theme(plot.title = element_text(size = 10))
    
    plot8 <-  ggplot(new_dtf, aes(x=bin, y=latence))+
      geom_line() +
      ylab("latence in s")+
      ggtitle('latence')+
      theme(plot.title = element_text(size = 10))
    
    #8
    name = c("plot_PoCi_", i,j, ".jpeg")
    name = paste(name, collapse="")
    
    jpeg(name, width = 3, height = 8,units = 'in',res=300)
    grid.arrange(arrangeGrob(plot1, plot2, plot3, plot4, top = paste(c('PoCi 1-2', j), collapse=" ")), 
                 arrangeGrob(plot5, plot6, plot7, plot8, top = paste(c('PoCi 2-3', j), collapse=" ")), 
                 ncol=1)
    dev.off()
  }
}

#save(dtf, file='peak_stat_Poci.Rdata')
