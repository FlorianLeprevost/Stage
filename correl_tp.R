library(ggplot2)
library(GGally)
library(corrplot)
library(R.matlab)
library(tidyverse)
#library(devtools)
#install_github("jokergoo/ComplexHeatmap")
#library(ComplexHeatmap)
#library(plsgenomics)
library(plotly)
# library(CCA)

setwd("Z:/modulation_HER_florian_2019/Data/2nd ana bis")
dtf=readMat("matrice_correl_tp.mat")
dtf_coeur=as.data.frame(dtf[1])
dtf_oppc23=as.data.frame(dtf[2])
dtf_oppc34=as.data.frame(dtf[3])



x=cor(dtf_coeur[,1:800], dtf_oppc34[,1:800], use="complete.obs")



# diag_interest = diag(x)
# # index = 1:length(diag_interest)
# # mean_elec = colMeans(dtf_oppc23)
# # dtf_plot = data.frame(index, diag_interest)
# # 
# # 
# # ggplot(dtf_plot, aes(x=index, y= diag_interest))+
# #   geom_line()+
# #   ylab("correlation between ECG and OpPC2-3 trials")
# # ggsave("oppc23 diag.jpg")


p=plot_ly(z = x, type = "heatmap", zmin=-.05, zmax=.05 )%>%
  layout(xaxis = list(title="oppc34 time point"), 
         yaxis = list(title="ECG time point"))
p
orca(p, file = "oppc23 heat.png")


# ## correl diag significativity

correl_vec = vector()
correl_signif = vector()
for (i in 1:800){
  cor_res = cor.test(dtf_coeur[,i], dtf_oppc34[,i])
  correl_vec = append(correl_vec, cor_res$estimate)
  correl_signif = append(correl_signif, cor_res$p.value)
}

signif_vec = correl_signif<.05
signif_vec = as.numeric(signif_vec)/600
index = 1:length(correl_signif)
mean_elec = colMeans(dtf_oppc34)/100
mean_elec = mean_elec[1:800]

dtf_plot = data.frame(index, correl_vec, signif_vec, mean_elec)

ggplot(dtf_plot)+
  geom_line(aes(x=index, y= diag_interest), color="blue", size=1)+
  geom_area(aes(x=index, y= signif_vec))+
  geom_line(aes(x=index, y= mean_elec), color="grey",size=1)+
  ylab("correlation between ECG and OpPC3-4 trials")+
  ggtitle("Correlation ECG & OpPC 3-4")
ggsave("oppc34 diag.jpg")



##time series


# # 
# 
# dtf_plot = data.frame(index, correl_vec, signif_vec, mean_elec)
# 
# ggplot(dtf_plot)+
#   geom_line(aes(x=index, y= diag_interest, color="correlation coefficient"))+
#   geom_area(aes(x=index, y= signif_vec, color="significance of the correlation"))+
#   geom_line(aes(x=index, y= mean_elec, color="shape of the HER"))+
#   scale_color_manual(values = c(
#     "correlation coefficient" = 'darkblue',
#     "significance of the correlation" = 'grey',
#     "shape of the HER" = 'lightgrey')) +
#   labs(color = 'Y series')+
#   ylab("correlation between ECG and OpPC2-3 trials")+
#   theme(legend.position="bottom", legend.box = "horizontal")+
#   theme(legend.background = element_rect(fill = NULL, colour = NULL, size = NULL,
#                                          linetype = NULL, color = NULL, inherit.blank = FALSE))
# 
# ggsave("oppc23 diag.jpg")
# 


#
# beg_s_vec = vector()
# end_s_vec = vector()
# 
# for (i in 2:length(signif_vec)){
#   if (signif_vec[i] ==1 & signif_vec[i-1] != 1){
#     beg_s_vec = append(beg_s_vec, i)
#   }
#   if (signif_vec[i] ==1 & signif_vec[i+1] != 1){
#     end_s_vec = append(end_s_vec, i)
#   }
# }
#

# 



# ## cortest
# z=cancor(dtf_coeur[,1:800], dtf_oppc23[,1:800])
# 
# 
# 
# diag_interest = diag(x)
# index = 1:length(diag_interest)
# dtf_plot = data.frame(index, diag_interest)
# ggplot(dtf_plot, aes(x=index, y= diag_interest))+
#   geom_line()+
#   ylab("correlation between ECG and OpPC2-3 trials")
# ggsave("oppc23 diag.jpg")


