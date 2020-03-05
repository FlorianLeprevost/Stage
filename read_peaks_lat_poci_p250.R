library(R.matlab)
library(tidyverse)
library(ggplot2)

setwd("Z:/modulation_HER_florian_2019/Data/2nd ana .5-30 and .05-.12 .3-.4")
dtf=readMat("data_2757_PoCi_peaks.mat")
dtf=as.data.frame(dtf)
dtf=t(dtf)
dtf=as.data.frame(dtf)


dtf$electrodes=as.factor(unlist(dtf$electrodes))
dtf$bin=unlist(dtf$bin)
dtf$peak=as.factor(unlist(dtf$peak))
dtf$var.tri=as.factor(unlist(dtf$var.tri))
dtf$amplitude=unlist(dtf$amplitude)
dtf$latence=unlist(dtf$latence)
dtf$prev.amp=unlist(dtf$prev.amp)
dtf$prev.lat=unlist(dtf$prev.lat)
dtf$p2p.amp=unlist(dtf$p2p.amp)
dtf$p2p.lat=unlist(dtf$p2p.lat)


dtf_full=dtf

dtf=filter(dtf_full, peak=='P250')

ggplot(dtf, aes(x=bin, y=amplitude))+
  geom_line() +
  facet_grid(electrodes ~ var.tri, scales="free")+
  ylab("amplitude in µV") +
  ggtitle('amplitude of peak')
ggsave("amplitude_peak250.jpg")

ggplot(dtf, aes(x=bin, y=p2p.amp))+
  geom_line() +
  facet_grid(electrodes ~ var.tri,scales="free")+
  ylab("amplitude in µV")+
  ggtitle('amplitude of peak - compared to previous')
ggsave("p2p_amplitude_peak250.jpg")

ggplot(dtf, aes(x=bin, y=latence))+
  geom_line() +
  facet_grid(electrodes ~ var.tri,scales="free")+
  ylab("latence in s")+
  ggtitle('latence of peak')
ggsave("latence_peak250.jpg")

ggplot(dtf, aes(x=bin, y=p2p.lat))+
  geom_line() +
  facet_grid(electrodes ~ var.tri,scales="free")+
  ylab("latence in s")+
  ggtitle('latence of peak - compared to previous')
ggsave("p2p_latence_peak250.jpg")

