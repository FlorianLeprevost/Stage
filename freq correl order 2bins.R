library(R.matlab)
library(tidyverse)
library(ggplot2)
library(devtools)
library(nlcor)
library(mgcv)
library(reshape2)
library(corrplot)


setwd("Z:/modulation_HER_florian_2019/Data/2nd ana bis")
dtf=readMat("correl_heart_2476.mat")
dtf=as.data.frame(dtf)
dtf=t(dtf)
dtf=as.data.frame(dtf)

dtf$type=unlist(dtf$type)
dtf$value=unlist(dtf$value)
dtf$sample=unlist(dtf$sample)
dtf$timestamp=unlist(dtf$timestamp)
dtf$duration= NULL
dtf$offset=NULL
dtf$number=unlist(dtf$number)
dtf$interval.pre=unlist(dtf$interval.pre)
dtf$interval.post=unlist(dtf$interval.post)
dtf$interval.diff=unlist(dtf$interval.diff)
dtf$hilbert.amp.low=unlist(dtf$hilbert.amp.low)
dtf$hilbert.amp.high=unlist(dtf$hilbert.amp.high)

#########################
vlines = c(nrow(dtf)/2, nrow(dtf))
vlines = round(vlines)
means_low = c(mean(dtf$hilbert.amp.low[1:vlines[1]]), mean(dtf$hilbert.amp.low[vlines[1]:vlines[2]]))
means_low = round(means_low, 5)
x=data.frame(vlines,means_low)


dtf %>%
  ggplot(aes(x=number, y=hilbert.amp.low)) +
  geom_line()+
  geom_vline(xintercept = vlines, color="red")+
  geom_point(aes(x=vlines -400, y=means_low, color="red", size=4), data=x, show.legend= FALSE)+
  annotate("text", x = vlines -400,y = (means_low + 1)^3 -1, label = means_low)+
  ylab("power")+
  ggtitle("mean of power of HRV LF in bins sorted by order")


ggsave("2476mean_low_2bins.jpg")

#################################
means_high = c(mean(dtf$hilbert.amp.high[1:vlines[1]]), mean(dtf$hilbert.amp.high[vlines[1]:vlines[2]]))
means_high = round(means_high, 5)
x=data.frame(vlines,means_high)

dtf %>%
  ggplot(aes(x=number, y=hilbert.amp.high)) +
  geom_line()+
  geom_vline(xintercept = vlines, color="red")+
  geom_point(aes(x=vlines -400, y=means_high, color="red", size=4), data=x, show.legend= FALSE)+
  annotate("text", x = vlines -400,y = (means_high + 1)^3 -1, label = means_high)+
  ylab("power")+
  ggtitle("mean of power of HRV HF in bins sorted by order")


ggsave("2476mean_high_2bins.jpg")



