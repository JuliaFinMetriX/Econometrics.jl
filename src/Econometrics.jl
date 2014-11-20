module Econometrics

## list packages whos namespace is used
using TimeData
using DataFrames
using Dates
using GLM
## using Winston
## using NLopt

## required for testing
## using EconDatasets
## using matlabdataloading

export                                  # important functions
cirOls,
cirNllh,
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
include("cir.jl")
include("copula.jl")
include("returns.jl")
include("nchisq.jl")
include("utils.jl")

end # module
