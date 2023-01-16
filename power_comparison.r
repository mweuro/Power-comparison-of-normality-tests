library(nortest)
library(ggplot2)
library(purrr)


#TESTS' STATISTICS

#Kolmogorov_Smirnov test statistic
ks <- function(x, x_mean = 0, x_sd = 1){
  return(ks.test(x, 'pnorm', mean = x_mean, sd = x_sd)$statistic)
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


#Finds power (p) of test (test_fun), according to sample size and confidence level
test_power <- function(test_fun, alpha, sample, param1, param2, N = 50, M = 100){
  test_name <- as.character(substitute(test_fun))
  p <- c()
  n <- c(10, 20, 30, 50, 100, 200, 300, 400, 500, 1000, 2000)
  crits <- c()
  for(i in 1:length(n)){
    #Tests' statistics vector - T
    X <- replicate(N, rnorm(n[i], mean = 0, sd = 1))
    dim(X) <- c(n[i], N)
    T <- apply(X, 2, test_fun)
    #Finding critical value for each sample length 
    if(test_name == 'sw'){
      crit <- quantile(sort(T), alpha)
    }
    else{
      crit <- quantile(sort(T), 1 - alpha)
    }
    crits <- append(crits, crit)
    #Finding test's statistic for tested distribution - D
    if(missing(param2)){
      Y <- replicate(M, sample(n[i], param1))
    }
    else{
      Y <- replicate(M, sample(n[i], param1, param2))
    }
    dim(Y) <- c(n[i], M)
    if(test_name == 'ks'){
      mean_i <- apply(Y, 2, mean)
      x_mean <- mean(mean_i)
      sd_i <- apply(Y, 2, sd)
      x_sd <- mean(sd_i)
      D <- apply(Y, 2, test_fun, x_mean, x_sd)
    }
    else{
      D <- apply(Y, 2, test_fun)
    }
    #Check if D is in critical values set (Monte Carlo simulation)
    #Calculate power - p
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


plot_powers <- function(alpha, sample, param1, param2){
  dist_name <- deparse(substitute(sample))
  left <- toupper(substr(dist_name, start = 2, stop = 2))
  right <- substr(dist_name, start = 3, nchar(dist_name))
  dist_name <- paste(left, right, sep = '')
  arg1_name <- deparse(substitute(param1))
  arg2_name <- deparse(substitute(param2))
  n <- c(10, 20, 30, 50, 100, 200, 300, 400, 500, 1000, 2000)
  if(missing(param2)){
    p_sw <- test_power(sw, alpha, sample, param1)
    p_ks <- test_power(ks, alpha, sample, param1)
    p_lillie <- test_power(lillie, alpha, sample, param1)
    p_ad <- test_power(ad, alpha, sample, param1)
  }
  else{
    p_sw <- test_power(sw, alpha, sample, param1, param2)
    p_ks <- test_power(ks, alpha, sample, param1, param2)
    p_lillie <- test_power(lillie, alpha, sample, param1, param2)
    p_ad <- test_power(ad, alpha, sample, param1, param2)
  }
  
  df <- data.frame(n, p_sw, p_ks, p_lillie, p_ad)
  
  fig <- ggplot(df, aes(x = n)) + 
    geom_line(aes(y = p_sw, color = 'SW')) +
    geom_point(y = p_sw, shape = 18, color = 'blue') +
    geom_line(aes(y = p_ks, color = 'KS')) +
    geom_point(y = p_ks, shape = 15, color = 'red') +
    geom_line(aes(y = p_lillie, color = 'LF')) +
    geom_point(y = p_lillie, shape = 17, color = 'green') +
    geom_line(aes(y = p_ad, color = 'AD')) +
    geom_point(y = p_ad, shape = 4, color = 'purple') +
    scale_x_continuous(breaks = c(10, 30, 100, 300, 1000, 2000),
                       trans = 'log2') +
    scale_y_continuous(limits = c(0, 1)) +
    scale_color_manual('', 
      breaks = c('SW',
                 'KS',
                 'LF',
                 'AD'),
      values = c('blue', 'red', 'green', 'purple')) +
    xlab(' ')
    # theme_classic()
  
    if(missing(param2)){
      fig + labs(title = paste(dist_name, '(', arg1_name, ')', sep = ''),
           x = 'Sample size, n', y = 'Simulated Power')
    }
    else{
      fig + labs(title = paste(dist_name, '(', arg1_name, ', ', arg2_name, ')', sep = ''),
                 x = 'Sample size, n', y = 'Simulated Power')
    }

}
plot_powers(0.05, rgamma, 1, 5)

