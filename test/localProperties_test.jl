module TestLocalProperties

using Econometrics
using Base.Test

## include("/home/chris/research/julia/Econometrics/src/localProperties.jl")

## test getInd2RangeFunc
##----------------------

edges = [5:1:12.]
ind2RangeFunc = Econometrics.getInd2RangeFunc(edges)

@test ind2RangeFunc(0) == edges[1]
@test ind2RangeFunc(6) == edges[end-1]


end
