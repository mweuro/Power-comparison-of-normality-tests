library(nortest)

#Finds critical value of test based on
#50 000 samples of 100 independent observations
normal_crit <- function(test_fun, alpha, N = 50000, n = 100){
  X <- replicate(N, rnorm(n, mean = 0, sd = 1))
  dim(X) <- c(n, N)
  T <- apply(X, 2, test_fun)
  
  if(test_fun == 'sw'){
    crit = quantile(T, alpha)
  }
  else{
    crit = quantile(T, 1 - alpha)
  }
  
  return(crit)
}

#Kolmogorov_Smirnov test statistic
ks <- function(x){
  return(ks.test(x, 'pnorm', mean(x), sd(x))$statistic)
}

#Shapiro-Wilk test statistic
sw <- function(x){
  return(shapiro.test(x)$statistic)
}

#Lilliefors test statistic
lillie <- function(x){
  return(lillie.test(x)$statistic)
}

#Anderson-Darling test statistic
ad <- function(x){
  return(ad.test(x)$statistic)
}

