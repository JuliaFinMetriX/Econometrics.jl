using Distributions
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

bsPrices = [bsCall(sigmas[ii], daxVals[ii], strikes[ii], r[ii], T[ii])
            for ii=1:3]


sigma0 = 0.1
prec = 0.000001

volas =[implVolaCall(sigma0, callPrices[ii], daxVals[ii],
                     strikes[ii], r[ii],
                     T[ii], prec) for ii=1:3]

