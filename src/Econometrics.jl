module Econometrics

## list packages whos namespace is used
using TimeData
using DataFrames
using Docile
using Dates
using GLM
using EconDatasets
using Distributions
using Gadfly
## using Winston
## using NLopt

## required for testing
## using MAT

export                                  # important functions
CIR,
bsDs,
bsCall,
bsPut,
bsDeltaCall,
bsDeltaPut,
bsGamma,
bsVega,
bsThetaCall,
bsThetaPut,
bsRhoCall,
bsRhoPut,
cirOls,
cirNllh,
cirNllhx,
disc2log,
getParams,
implVola,
implVolaCall,
implVolaPut,
imputePreviousObs!,
localAppl,
log2disc,
plotLocalProperties,
price2ret,
ranks,
ret2price
## ishighest,
## islowest,
## ranks,
## plot

## include("autocorr.jl")
## include("garch.jl")
include("bsOptions.jl")
include("localProperties.jl")
include("cir.jl")
include("copula.jl")
include("returns.jl")
include("nchisq.jl")
include("utils.jl")


end # module
