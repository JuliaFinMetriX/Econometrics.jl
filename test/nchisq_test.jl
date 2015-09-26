module TestNChisq

using Base.Test
using Distributions
using TimeData
using NLopt
using JuMP

import Econometrics

## reload(joinpath(Pkg.dir(), "Econometrics", "src", "Econometrics.jl"))

## constructors / display
##-----------------------

ncs = Econometrics.NChiSq([3.2, 0.2])
ncs = Econometrics.NChiSq(3.2, 0.2)

println("\nTesting display output:")
display(ncs)

@test_throws Exception Econometrics.NChiSq(-0.2, 0.2)
@test_throws Exception Econometrics.NChiSq(0.2, -1.2)

## dof
##----

ncs = Econometrics.NChiSq([3.2, 0.2])
@test Econometrics.dof(ncs) == 3.2

## getParams
##----------

@test Econometrics.getParams(ncs) == (3.2, 0.2)

## rand
##-----

nSim = 5000
ncs = Econometrics.NChiSq([3.2, 0.2])
simVals = rand(ncs, nSim)

## pdf
##----

d = Econometrics.NChiSq([3.2, 0.2])
pdfVal = Econometrics.pdf(d, 0.2)

@test isa(pdfVal, Float64)

pdfVals = Econometrics.pdf(d, simVals)

@test isa(pdfVals, Array{Float64, 1})
@test all(pdfVals .>= 0)

## cdf
##----

d = Econometrics.NChiSq([3.2, 0.2])
cdfVal = Econometrics.cdf(d, 0.2)

@test isa(cdfVal, Float64)

cdfVals = Econometrics.cdf(d, simVals)

@test isa(cdfVals, Array{Float64, 1})
@test all(cdfVals .>= 0)
@test all(cdfVals .<= 1)

## quantile
##---------

d = Econometrics.NChiSq([3.2, 0.2])
pVal = Econometrics.quantile(d, 0.2)

@test isa(pVal, Float64)

## test cdf(quantile(x)) and quantile(cdf(x))
##-------------------------------------------

nSim = 5000
d = Econometrics.NChiSq([3.2, 0.2])
simVals = rand(d, nSim)
cdfVals = Econometrics.cdf(d, simVals)
pVals = Econometrics.quantile(d, cdfVals)
@test_approx_eq pVals simVals

grid = [0.01:0.01:0.99]
pVals = Econometrics.quantile(d, grid)
cdfVals = Econometrics.cdf(d, pVals)
@test_approx_eq cdfVals grid

## nllh
##-----

nSim = 5000
d = Econometrics.NChiSq([3.2, 0.2])
simVals = rand(d, nSim)

nllhVal1 = Econometrics.nllh(d, simVals)
nllhVal2 = Econometrics.nllh_nchis([Econometrics.getParams(d)...], simVals)

@test_approx_eq nllhVal1 nllhVal2

@test_throws Exception Econometrics.nllh_nchis([3.2, 0.2, 1.2, 4.2], simVals)

## fit
##----

nSim = 1000
params = [3.2, 0.2]
d = Econometrics.NChiSq(params)

@time dHat = Econometrics.fit(Econometrics.NChiSq, simVals)

@test isa(dHat, Econometrics.NChiSq)

## compare parameters
[params'
[Econometrics.getParams(dHat)...]']

end

