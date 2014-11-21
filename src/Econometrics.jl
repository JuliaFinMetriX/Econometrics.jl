module Econometrics

## list packages whos namespace is used
using TimeData
using DataFrames
using Dates
using GLM
using EconDatasets
## using Winston
## using NLopt

## required for testing
## using MAT

export                                  # important functions
CIR,
cirOls,
cirNllh,
cirNllhx,
disc2log,
getParams,
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
