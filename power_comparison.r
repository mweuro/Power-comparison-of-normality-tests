library(nortest)
library(ggplot2)
library(purrr)


#TESTS' STATISTICS

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
  stat <- ad.test(x)$statistic
  n <- length(x)
  return(stat*(1 + 0.75*n + 2.25*n^2))
}


# #DISTRIBUTIONS' SAMPLES
# 
# #Uniform
# u_sample <- function(n, a, b){
#   return(runif(n, a, b))
# }
# 
# #Beta
# beta_sample <- function(n, a, b){
#   return(rbeta(n, a, b))
# }
# 
# #t
# t_sample <- function(n, df){
#   return(rt(n, df))
# }
# 
# #Laplace
# laplace_sample <- function(n){
#   return(rlaplace(n))
# }
# 
# #Chi2
# chi2_sample <- function(n, df){
#   return(rchisq(n, df))
# }
# 
# #Gamma
# gamma_sample <- function(n, shape, scale){
#   return(rgamma(n, shape = shape, scale = scale))
# }


#Finds critical value of test based on
#50 000 samples of 100 independent observations
test_power <- function(test_fun, alpha, N = 5000, M = 500){
  test_name <- as.character(substitute(test_fun))
  p <- c()
  n <- c(10, 20, 30, 50, 100, 200, 300, 400, 500, 1000, 2000)
  crits <- c()
  for(i in n){
    X <- replicate(N, rnorm(i, mean = 0, sd = 1))
    dim(X) <- c(i, N)
    T <- apply(X, 2, test_fun)
    
    if(test_name == 'sw'){
      crit <- quantile(sort(T), alpha)
    }
    else if(test_name == 'ks'){
      crit <- quantile(sort(T), 1 - alpha/2)
    }
    else{
      crit <- quantile(sort(T), 1 - alpha)
    }
    crits <- append(crits, crit)
  }

  for(i in 1:length(n)){
    Y <- replicate(M, rgamma(n[i], 1, 5))
    dim(Y) <- c(n[i], M)
    D <- apply(Y, 2, test_fun)
    if(test_name == 'sw'){
      d <- length(which(D < crits[i]))
    }
    else{
      d <- length(which(D > crits[i]))
    }
    p <- append(p, d/M)
  }
  return(p)
}

plot_powers <- function(alpha){
  n <- c(10, 20, 30, 50, 100, 200, 300, 400, 500, 1000, 2000)
  p_sw <- test_power(sw, alpha)
  p_ks <- test_power(ks, alpha)
  p_lillie <- test_power(lillie, alpha)
  p_ad <- test_power(ad, alpha)
  df <- data.frame(n, p_sw, p_ks, p_lillie, p_ad)
  
  ggplot(df, aes(x = n)) + 
    geom_line(y = p_sw, color = 'blue') +
    geom_point(y = p_sw, shape = 18, color = 'blue') +
    geom_line(y = p_ks, color = 'red') +
    geom_point(y = p_ks, shape = 15, color = 'red') +
    geom_line(y = p_lillie, color = 'green') +
    geom_point(y = p_lillie, shape = 17, color = 'green') +
    geom_line(y = p_ad, color = 'purple') +
    geom_point(y = p_ad, shape = 4, color = 'purple') +
    scale_x_continuous(breaks = c(10, 30, 100, 300, 1000, 2000),
                       trans = 'log2') +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
    theme_classic() + 
    labs(x = 'Sample size, n', y = 'Simulated Power')
}
plot_powers(0.05)

