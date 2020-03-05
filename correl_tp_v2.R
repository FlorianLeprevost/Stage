library(ggplot2)
library(GGally)
library(corrplot)
library(R.matlab)
library(tidyverse)
library(plotly)
library(gridExtra)
library(cowplot)
library(scales)

setwd("Z:/modulation_HER_florian_2019/Data/2nd ana bis")
# dtf=readMat("matrice_correl_tp.mat")
# dtf_coeur=as.data.frame(dtf[1])
# dtf_oppc23=as.data.frame(dtf[2])
# dtf_oppc34=as.data.frame(dtf[3])

dtf=readMat("matrice_correl_tp_poci.mat")
dtf_coeur=as.data.frame(dtf[1])
dtf_poci12=as.data.frame(dtf[2])
dtf_poci23=as.data.frame(dtf[3])

# ## correl diag significativity

correl_vec = vector()
correl_signif = vector()
for (i in 1:800){
  cor_res = cor.test(dtf_coeur[,i], dtf_poci23[,i])
  correl_vec = append(correl_vec, cor_res$estimate)
  correl_signif = append(correl_signif, cor_res$p.value)
}

#### plots
index = 1:length(correl_signif)
index = index/1096 *1000

mean_elec = colMeans(dtf_poci23)
mean_elec =mean_elec[1:800]


mean_coeur = colMeans(dtf_coeur, na.rm = T)
mean_coeur = mean_coeur[1:800]

signif_vec = correl_signif<.05
x_vec = which(signif_vec)/1096 *1000


#plot correl
y_max1 = rep(max(correl_vec), length(x_vec))
y_min1 = rep(min(correl_vec), length(x_vec))

  
dtf_plot = data.frame(index, correl_vec, signif_vec, mean_elec, mean_coeur)

p1 = ggplot()+
  geom_line(data = dtf_plot, aes(x=index, y= correl_vec), size=1)+
  geom_rect(aes(xmin=x_vec, xmax =x_vec +2,
           ymin=y_min1 , ymax=y_max1),
           alpha=.2)+
  ylab("Correlation coefficient")+
  ggtitle("Correlation ECG & PoCi 2-3")+
  ylim(min(y_min1), max(y_max1))+
  scale_y_continuous(labels= label_number(accuracy=.01))+
  theme(axis.title.x = element_blank(), axis.text.x = element_blank())+
  theme(axis.text=element_text(size=rel(2)),
        axis.title=element_text(size=rel(2)),
        plot.title = element_text(size=rel(2)))


p1

#plot HER
y_max2 = rep(max(mean_elec), length(x_vec))
y_min2 = rep(min(mean_elec), length(x_vec))

p2 = ggplot()+
  geom_line(data = dtf_plot, aes(x=index, y= mean_elec), size=1)+
  geom_rect(aes(xmin=x_vec, xmax =x_vec +2,
                ymin=y_min2 , ymax=y_max2),
            alpha=.2)+
  ylab("Mean HER")+
  ylim(min(y_min2), max(y_max2))+
  theme(axis.title.x = element_blank(), axis.text.x = element_blank())+
  scale_y_continuous(labels= label_number(accuracy=.1))+
  theme(axis.text=element_text(size=rel(2)),
        axis.title=element_text(size=rel(2)),
        plot.title = element_text(size=rel(2)))

p2
#plot heart
y_max3 = rep(max(mean_coeur), length(x_vec))
y_min3 = rep(min(mean_coeur), length(x_vec))

p3 = ggplot()+
  geom_line(data = dtf_plot, aes(x=index, y= mean_coeur), size=1)+
  geom_rect(aes(xmin=x_vec, xmax =x_vec +2,
                ymin=y_min3 , ymax=y_max3),
            alpha=.2)+
  ylab("Mean ECG")+
  xlab("Time in ms")+
  ylim(min(y_min3), max(y_max3))+
  scale_x_continuous(breaks = round(seq(min(index)-1, max(index), by = 100),0))+
  theme(axis.text=element_text(size=rel(2)),
        axis.title=element_text(size=rel(2)),
        plot.title = element_text(size=rel(2)))

p3

jpeg("poci23.jpg", width = 12, height = 10,units = 'in',res=300)
grid.arrange(p1, p2, p3,
             ncol=1, nrow=3,
             heights=c(4, 3,3))
dev.off()
  




