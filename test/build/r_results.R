## read in data
##-------------

fname <- "intRates.csv"
timeData <- read.csv(fname, header = TRUE)

######################
## load source file ##
######################

CIR.OLS <- function(x, delta = 1/250){
  
  # Input:
  # S: timeseries which can be used to calibrate the CIR model
  # delta: timestep; (use 1/250 for daily data, 1/12 for monthly data, etc)
  
  # Output:
  # Parameters alpha, mu and sigma for the CIR model
  
  # The code is based on Kladivko (2007).
  
  # calculate regression parameters
  y <- (x[-1] - x[1:(length(x)-1)]) / sqrt(x[1:(length(x)-1)])
  x1 <- 1 / sqrt(x[1:(length(x)-1)])
  x2 <- sqrt(x[1:(length(x)-1)])
  
  # perform regression
  reg <- lm(y ~ 0 + x1 + x2)
  
  # calculate parameters
  alpha <- -reg$coefficients[2] / delta
  mu <- reg$coefficients[1] / (alpha * delta)
  sigma <- sqrt(var(reg$residuals) / delta)
  
  # return estimated parameters
  return(c(alpha, mu, sigma))
}

CIR.lik = function(x, alpha, mu, sigma, delta = 1/250) {
  
  # Input:
  # alpha: mean-reversion parameter of the CIR model
  # mu: mean parameter of the CIR model
  # sigma: volatility parameters of the CIR model
  # delta: distance between time steps; 
  #        1 by default since no other value is required in this context
  
  # Output:
  # The function calculates the negative log-likelihood of a CIR model with parameters
  # alpha, mu and sigma and timestep delta. A dataset x has to be specified prior to 
  # running the function.
  
  # The code is based on Kladivko (2007).
  
  n = length(x)
  c = 2 * alpha / (sigma^2 * (1 - exp(-alpha * delta)))
  q = 2 * alpha * mu / sigma^2 - 1
  u = c * x[1:(n - 1)] *  exp(-alpha * delta)
  v = c * x[2:n]

  notElim = !is.na(u) & !is.na(v)
  u <- u[notElim]
  v <- v[notElim]
  n = length(u)
  
  loglik = (n - 1) * log(c) + sum(-u - v + 0.5 * q * log(v / u) + 2 * sqrt (u * v) +
                                  log(besselI(x = 2 * sqrt(u * v), nu = q, expon.scaled = TRUE)))
                                  
  
  cat("Parameters: ", alpha, " ", mu, " ", sigma, "  \n") 
  cat("Log Likelihood: ", loglik, "  \n", "  \n")
  
  return(-loglik)
}


#######################
## get values with R ##
#######################

intRates <- timeData[, 2]
paramsHat = CIR.OLS(intRates)
olsParams = data.frame(alpha = paramsHat[1], mu = paramsHat[2],
                sigma = paramsHat[3])


nllh <- CIR.lik(intRates, olsParams[1, 1],
                olsParams[1, 2],
                olsParams[1, 3])

save(olsParams, nllh, file="r_results.RData")


