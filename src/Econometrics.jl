module Econometrics

## list packages whos namespace is used
using TimeData
using Winston
using NLopt

export                                  # important functions
ishighest,
islowest,
ranks,
plot

include("autocorr.jl")
include("copula.jl")
include("garch.jl")
include("returns.jl")



end # module
