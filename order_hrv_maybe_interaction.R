setwd("Z:/modulation_HER_florian_2019/Data/2nd ana bis")


####
#load dtf of R param first
dtf_bis = na.omit(dtf[5:10])
p.mat <- cor.mtest(dtf_bis)
head(p.mat)
corrplot(cor(dtf_bis), 
         method="color", type="upper", addCoef.col = "black",
         tl.col="black", tl.srt=45, diag=FALSE,
         p.mat = p.mat$p, sig.level = 0.05, insig = "blank",
         title='Correlation between cardiac time series parameters \n at R peak (2757)',
         mar=c(0,0,2,0))



##
# models
load('peak_stat_Poci.Rdata')
#%%
new_dtf= filter(dtf, var.tri == "order", electrodes=="PoCi_2_PoCi_3", peak=="N300")
#mod = lm(amplitude ~ mean.diff + mean.post + mean.pre + bin + mean.HF + mean.LF, new_dtf)
mod = lm(amplitude ~ mean.HF + mean.diff, new_dtf)
summary(mod)



##
# hmm?
library(depmixS4)
mod <- depmix(response = hilbert.amp.high ~ 1, data = dtf, nstates = 2)
summary(mod)
m <- fit(mod, emc=em.control(rand=FALSE))
summary(m)



#hmm
library(RHmm) #Load HMM package
#Code based upon http://systematicinvestor.wordpress.com/2012/11/01/regime-detection/
# bullMarketOne = rnorm( 100, 0.1/365, 0.05/sqrt(365) )
# bearMarket  = rnorm( 100, -0.2/365, 0.15/sqrt(365))
# bullMarketTwo = rnorm( 100, 0.15/365, 0.07/sqrt(365) )
# true.states = c(rep(1,100),rep(2,100),rep(1,100))
# returns = c( bullMarketOne, bearMarket, bullMarketTwo )
# 
# y=returns

ResFit = HMMFit(dtf[9:10], nStates=2) #Fit a HMM with 2 states to the data
VitPath = viterbi(ResFit, dtf[,9:10]) #Use the viterbi algorithm to find the most likely state path (of the training data)
fb = forwardBackward(ResFit, dtf[,10]) #Forward-backward procedure, compute probabilities


# Plot probabilities and implied states
layout(1)
plot(dtf[,9])
plot(dtf[,10])
plot(VitPath$states, type='s', main='Implied States', xlab='', ylab='State')
matplot(fb$Gamma, type='l', main='Smoothed Probabilities', ylab='Probability')
legend(x='topright', c('Bear Market - State 2','Bull Market - State 1'),  fill=1:2, bty='n')

x=1:994
ggplot()+
  geom_line(aes(x=x,y=dtf[,9]*15), color = 'blue')+
  geom_line(aes(x=x,y=dtf[,10]*20), color = 'green')+
  geom_line(aes(x=x,y=VitPath$states-1), size=1, color = 'red')

####

ResFit = HMMFit(dtf[10], nStates=2) #Fit a HMM with 2 states to the data
VitPath = viterbi(ResFit, dtf[10]) #Use the viterbi algorithm to find the most likely state path (of the training data)
fb = forwardBackward(ResFit, dtf[10]) #Forward-backward procedure, compute probabilities


# Plot probabilities and implied states
x=1:994
ggplot()+
  geom_line(aes(x=x,y=dtf[,10]*20), color = 'green')+
  geom_line(aes(x=x,y=VitPath$states-1), size=1, color = 'red')
  

