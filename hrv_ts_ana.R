library(ggplot2)
library(R.matlab)
library(tidyverse)
library(forecast)
library(HMM)
library(seqHMM)
library(MSwM)


setwd("Z:/modulation_HER_florian_2019/Data/2nd ana bis")
dtf=readMat("HRV_ts.mat")
dtf_LF=as.data.frame(dtf[1])
dtf_HF=as.data.frame(dtf[2])


##

ts_HF =ts(dtf$hilbert.amp.high)
plot(ts_HF)
forecast(ts_HF)
plot.forecast(ts_HF)
x= tbats(ts_HF)
plot(forecast(x))
y = auto.arima(ts_HF)

HMM()

x= lm(hilbert.amp.high~ number, dtf_test)
summary(x)
y = msmFit(x, k=2,sw=rep(TRUE,3))
plot(y)
