# Power comparison of normality tests
 
The goal of this code is to compare the power of different tests for normality. These are:
- Kolmogorov-Smirnov test
- Shapiro-Wilk test
- Lilliefors test
- Anderson-Darling test

Standard normal distribution samples of different sizes were simulated ( $N = 50000$ samples for each sample size $n$). They were used to calculate values of tests' statistics (for example KS test). Those statistics were sorted, and basing on significance level $\alpha$, critical values of statistics' distributions were found.

Next step was to generate samples from tested distribution (for example Gamma) and to calculate their test statistics (for each sample size like before). Procedure was repeated $M = 10000$ times in Monte Carlo simulation. Then, the amount of statistics was found, which values are in critical values set. Finally power of test was calculated, which is an amount of statistics contained in critical set divided by an amount of all statistics.

Function ```test_power``` calculates power of test ```test_fun``` on significance level ```alpha``` for distribution samples ```sample```. Distribution takes parameters ```param1```, ```param2```, where the second one is optional.

Function ```plot_powers``` generates a plot of power change for analysed tests. It uses the previous function, so parameters are similar.

The last line of code is an example of its usage. It analyses four tests' powers for Gamma distribution $\Gamma (1, 5)$ on significance level $\alpha = 0.05$.  
