library(R.matlab)
library(tidyverse)

setwd("C:/Users/Etudiant/Documents/DATA/Patient_2476/iEEG_Data/02476_2017-04-07_14-45")
dtf=readMat("data_2476_OpPC_peaks.mat")
dtf=as.data.frame(dtf)
dtf=t(dtf)
dtf=as.data.frame(dtf)


dtf$electrodes=unlist(dtf$electrodes)
dtf$bin=unlist(dtf$bin)
dtf$var.tri=unlist(dtf$var.tri)
dtf$amplitude=unlist(dtf$amplitude)
dtf$latence=unlist(dtf$latence)
dtf$prev.amp=unlist(dtf$prev.amp)
dtf$prev.lat=unlist(dtf$prev.lat)
dtf$p2p.amp=unlist(dtf$p2p.amp)
dtf$p2p.lat=unlist(dtf$p2p.lat)

oppc12

ggplot(dtf, aes(x=bin, y=amplitude))+
  geom_line() +
  facet_grid(electrodes ~ var.tri, scales="free")+
  ylab("amplitude in µV") +
  ggtitle('amplitude of peak')
ggsave("amplitude_peak.jpg")

ggplot(dtf, aes(x=bin, y=p2p.amp))+
  geom_line() +
  facet_grid(electrodes ~ var.tri,scales="free")+
  ylab("amplitude in µV")+
  ggtitle('amplitude of peak - compared to previous')
ggsave("amplitude_peak.jpg")

ggplot(dtf, aes(x=bin, y=latence))+
  geom_line() +
  facet_grid(electrodes ~ var.tri,scales="free")+
  ylab("latence in s")+
  ggtitle('latence of peak')
ggsave("latence_peak.jpg")

ggplot(dtf, aes(x=bin, y=p2p.lat))+
  geom_line() +
  facet_grid(electrodes ~ var.tri,scales="free")+
  ylab("latence in s")+
  ggtitle('latence of peak - compared to previous')
ggsave("p2p_latence_peak.jpg")

