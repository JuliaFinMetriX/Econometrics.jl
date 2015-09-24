module TestModel

using Econometrics
using Distributions
using TimeData
using Base.Test

include(joinpath(Pkg.dir(), "Econometrics/src/Model.jl"))

## NormIID
##--------

@test_throws Exception NormIID(0.3, -0.2)

mod = NormIID(0.3, 1.2)
description(mod)

## fit to data
data = randn(100)*3.2 + 10
normIID_fit = fit(NormIID, data)

## TlsIID
##-------



end
