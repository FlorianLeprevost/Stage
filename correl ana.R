library(ggplot2)
library(GGally)

dtf %>%
  filter(peak=='N300', electrodes == "PoCi_1_PoCi_2") %>% 
  ggpairs(columns = c(1,5,6))

dtf_test <- dtf %>%
  filter(peak=='N300', electrodes == "PoCi_1_PoCi_2")

pairs(dtf_test[, c(1,2,5,6)] ,col =dtf$bin)
cor(dtf[,5:10])

dtf$bin = as.numeric(dtf$bin)


cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}
# Matrice de p-value de la corrélation
p.mat <- cor.mtest(dtf_only_num)
head(p.mat[, 1:5])




dtf_no_na = na.omit(dtf)
dtf_only_num = dtf_no_na[,c(4,5,8,9,10,11,12,13,14)]

library(corrplot)

corrplot(cor(dtf_only_num), 
         method="color", type="upper", addCoef.col = "black",
         tl.col="black", tl.srt=45, diag=FALSE,
         p.mat = p.mat, sig.level = 0.05, insig = "blank")





#########
dtf_23 = filter(dtf, electrodes=="OpPC_2_OpPC_3")
dtf_34 = filter(dtf, electrodes=="OpPC_3_OpPC_4")

dtf_23 <- dtf_23 %>% 
  mutate(lat_23 = latence, amp_23= amplitude, p2p_amp_23 = p2p.amp, p2p_lat_34 = p2p.lat)

dtf_34 <- dtf_34 %>% 
  mutate(lat_34 = latence, amp_34= amplitude, p2p_amp_34 = p2p.amp, p2p_lat_34 = p2p.lat)

dtf_double= dtf_23
dtf_double$lat_34 = dtf_34$lat_34
dtf_double$amp_34 = dtf_34$amp_34
dtf_double$p2p_amp_34 = dtf_34$p2p_amp_34
dtf_double$p2p_lat_34 = dtf_34$p2p_lat_34

dtf_double_ok = dtf_double[, 10:22]
dtf_double_ok = na.omit(dtf_double_ok)
p.mat <- cor.mtest(dtf_double_ok)
head(p.mat[, 1:5])


corrplot(cor(dtf_double_ok), 
         method="color", type="upper", addCoef.col = "black",
         tl.col="black", tl.srt=45, diag=FALSE,
         p.mat = p.mat, sig.level = 0.05, insig = "blank",
          order="FPC")





##############º
dtf_double_ok = dtf_double[, c(3,10,11,12,13,14,15,16,17,18,19,20,21,22),10:22]
dtf_double_ok = na.omit(dtf_double_ok)


x=hetcor(dtf_double_ok)
corrplot(x$correlations, 
         method="color", type="upper", addCoef.col = "black",
         tl.col="black", tl.srt=45, diag=FALSE,
         p.mat = x$tests, sig.level = 0.05, insig = "blank",
         order="FPC")