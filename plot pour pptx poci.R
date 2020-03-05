library(gridExtra)
"hil_amp_low"
"diff_ibi"
"order"



new_dtf= filter(dtf, var.tri == "order", electrodes=="OpPC_2_OpPC_3")
plot1 <- ggplot(new_dtf, aes(x=bin, y=p2p.amp))+
  geom_line() +
  ylab("amplitude in µV")+
  ggtitle('OpPC_2_3 - amplitude p2p')


plot2 <-  ggplot(new_dtf, aes(x=bin, y=p2p.lat))+
  geom_line() +
  ylab("latence in s")+
  ggtitle('OpPC_2_3 -latence p2p')


plot3 <- ggplot(new_dtf, aes(x=bin, y=amplitude))+
  geom_line() +
  ylab("amplitude in µV")+
  ggtitle('OpPC_2_3 -amplitude')

plot4 <-  ggplot(new_dtf, aes(x=bin, y=latence))+
  geom_line() +
  ylab("latence in s")+
  ggtitle('OpPC_2_3 -latence')


grid.arrange(plot1, plot2,plot3, plot4, ncol=2)

###
new_dtf= filter(dtf, var.tri == "order", electrodes=="OpPC_2_OpPC_3")
plot1 <- ggplot(new_dtf, aes(x=bin, y=p2p.amp))+
  geom_line() +
  ylab("amplitude in µV")+
  ggtitle('OpPC_2_3 - amplitude p2p')


plot2 <-  ggplot(new_dtf, aes(x=bin, y=p2p.lat))+
  geom_line() +
  ylab("latence in s")+
  ggtitle('OpPC_2_3 -latence p2p')


plot3 <- ggplot(new_dtf, aes(x=bin, y=amplitude))+
  geom_line() +
  ylab("amplitude in µV")+
  ggtitle('OpPC_2_3 -amplitude')

plot4 <-  ggplot(new_dtf, aes(x=bin, y=latence))+
  geom_line() +
  ylab("latence in s")+
  ggtitle('OpPC_2_3 -latence')


grid.arrange(plot1, plot2,plot3, plot4, ncol=2)


save(dtf, file='peak_stat_OPPtttttttttC.Rdata')
