library(gridExtra)
library(ggplot2)
library(tidyverse)
#var_tri = c("hil_amp_low","hil_amp_high","diff_ibi","order")
var_tri = c("prev_ibi", "next_ibi")
setwd("Z:/modulation_HER_florian_2019/Data/2nd ana bis")
load('peak_stat_OPPC.Rdata')
#%%

for (i in var_tri){

  new_dtf= filter(dtf, var.tri == i, electrodes=="OpPC_2_OpPC_3")
  plot1 <- ggplot(new_dtf, aes(x=bin, y=p2p.amp))+
    geom_line() +
    ylab("amplitude in µV")+
    ggtitle('amplitude p2p')
  
  
  plot2 <-  ggplot(new_dtf, aes(x=bin, y=p2p.lat))+
    geom_line() +
    ylab("latence in s")+
    ggtitle('latence p2p')
  
  
  plot3 <- ggplot(new_dtf, aes(x=bin, y=amplitude))+
    geom_line() +
    ylab("amplitude in µV")+
    ggtitle('amplitude')
  
  plot4 <-  ggplot(new_dtf, aes(x=bin, y=latence))+
    geom_line() +
    ylab("latence in s")+
    ggtitle('latence')
  
  new_dtf= filter(dtf, var.tri == i, electrodes=="OpPC_3_OpPC_4")
  plot5 <- ggplot(new_dtf, aes(x=bin, y=p2p.amp))+
    geom_line() +
    ylab("amplitude in µV")+
    ggtitle('amplitude p2p')
  
  
  plot6 <-  ggplot(new_dtf, aes(x=bin, y=p2p.lat))+
    geom_line() +
    ylab("latence in s")+
    ggtitle('latence p2p')
  
  
  plot7 <- ggplot(new_dtf, aes(x=bin, y=amplitude))+
    geom_line() +
    ylab("amplitude in µV")+
    ggtitle('amplitude')
  
  plot8 <-  ggplot(new_dtf, aes(x=bin, y=latence))+
    geom_line() +
    ylab("latence in s")+
    ggtitle('latence')
  
  #8
  name = c("plot", i, ".jpeg")
  name = paste(name, collapse="")
  jpeg(name, width = 5, height = 8,units = 'in',res=300)
  grid.arrange(arrangeGrob(plot1, plot2, plot3, plot4, top = 'OpPC 2-3'), 
               arrangeGrob(plot5, plot6, plot7, plot8, top = 'OpPC 3-4'), 
               ncol=1)
  dev.off()
}



#save(dtf, file='peak_stat_OPPC.Rdata')
