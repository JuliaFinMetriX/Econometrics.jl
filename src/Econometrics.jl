module Econometrics

## list packages whos namespace is used
using TimeData
using DataFrames
using Dates
using Winston
## using NLopt

export                                  # important functions
disc2log,
imputePreviousObs!,
log2disc,
price2ret,
ranks,
ret2price
## ishighest,
## islowest,
## ranks,
## plot

## include("autocorr.jl")
## include("garch.jl")
include("copula.jl")
include("returns.jl")
include("nchisq.jl")



end # module
