module Econometrics

## list packages whos namespace is used
using TimeData
using Winston
using NLopt

include("autocorr.jl")
include("garch.jl")
include("returns.jl")

end # module
