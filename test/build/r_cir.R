## read in data
##-------------

fname <- "data/no_git_intRates.csv"
timeData <- read.csv(fname, header = TRUE)

library(sde)

####################################
## test conditional distributions ##
####################################

r0 = 4.5
params <- c(0.4, 3.2, 0.2)

## different parametrization in R
theta <- c(params[1]*params[2], params[1], params[3])

## cdf
cdf1 <- pcCIR(4.5, 1/250, r0, theta)
cdf2 <- pcCIR(5.2, 1, r0, theta)

## inverse cdf
icdf1 <- qcCIR(0.5, 1/250, 4.5, theta)
icdf2 <- qcCIR(0.5, 1, 4.5, theta)

results <- data.frame(cdf1 = cdf1, cdf2 = cdf2,
                      icdf1 = icdf1, icdf2 = icdf2)

write.table(results, "data/r_cir_results.csv", row.names = FALSE,
            sep = ",")
