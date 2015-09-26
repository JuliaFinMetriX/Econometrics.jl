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
using NLopt
using JuMP

## required for testing
## using MAT

export                                  # important functions
AbstrModel,
AbstrMultivarModel,
AbstrUnivarModel,
CIR,
GARCH_1_1,
GARCH_1_1_Fit,
NChiSq,
NormIID,
TLSDist,
TlsIID,
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
fit,
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

## distributions
include("distributions/t_loc_scale.jl")
include("distributions/nchisq.jl")

## models
include("models/Model.jl")
include("models/normiid.jl")
include("models/tlsiid.jl")
include("models/garch_types.jl")
include("models/garch.jl")
include("models/cir.jl")

## miscellaneous
include("bsOptions.jl")
include("localProperties.jl")
include("copula.jl")
include("returns.jl")
include("utils.jl")
include("autocorr.jl")

end # module
