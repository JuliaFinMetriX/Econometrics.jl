module TestBsOptions

using Distributions
using Base.Test

results = readcsv("/home/chris/research/julia/Econometrics/test/data/matlab_bsvals.csv")

include("/home/chris/research/julia/Econometrics/src/bsOptions.jl")

callPrices = [26.7, 824.9, 1166.7]
daxVals = [6175.05,
           6816.12,
           8455.83]
strikes = [6700, 6000, 7300]
r = [0.006,
     0.008,
     0.001]
T = [0.188,
     0.074,
     0.172]
sigmas = [0.4,
          0.2,
          0.2]

############
## prices ##
############

actOut = [bsCall(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
            for ii=1:3]

@test_approx_eq_eps actOut' results[1, :] 0.01

actOut = [bsPut(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
            for ii=1:3]

@test_approx_eq_eps actOut' results[2, :] 0.01

###########
## Delta ##
###########

actOut = [bsDeltaCall(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
          for ii=1:3]

@test_approx_eq_eps actOut' results[3, :] 0.01

actOut = [bsDeltaPut(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
          for ii=1:3]

@test_approx_eq_eps actOut' results[4, :] 0.01

###########
## Gamma ##
###########

actOut = [bsGamma(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
          for ii=1:3]

@test_approx_eq_eps actOut' results[5, :] 0.01

##########
## Vega ##
##########

actOut = [bsVega(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
          for ii=1:3]

@test_approx_eq_eps actOut' results[6, :] 0.01

###########
## Theta ##
###########

actOut = [bsThetaCall(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
          for ii=1:3]

@test_approx_eq_eps actOut' results[7, :] 0.1

actOut = [bsThetaPut(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
          for ii=1:3]

@test_approx_eq_eps actOut' results[8, :] 0.1

#########
## Rho ##
#########

actOut = [bsRhoCall(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
          for ii=1:3]

@test_approx_eq_eps actOut' results[9, :] 0.1

actOut = [bsRhoPut(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
          for ii=1:3]

@test_approx_eq_eps actOut' results[10, :] 0.01

##################
## Implied vola ##
##################

sigma0 = 0.18
prec = 0.000001

volas = [implVolaCall(sigma0, callPrices[kk], daxVals[kk],
                     strikes[kk], r[kk], T[kk], prec)[1] for kk=1:3]

@test_approx_eq_eps volas' results[11, :] 0.01

end
