module TestTLS

using Base.Test
using Distributions
using TimeData
using NLopt
using JuMP

import Econometrics

## reload(joinpath(Pkg.dir(), "Econometrics", "src", "Econometrics.jl"))

## constructors / display
##-----------------------

tls = Econometrics.TLSDist([3.2, 0.2, 1.2])
tls = Econometrics.TLSDist(3.2, 0.2, 1.2)

println("\nTesting display output:")
display(tls)

@test_throws Exception Econometrics.TLSDist(-0.2, 0.2, 1.2)
@test_throws Exception Econometrics.TLSDist(0.2, 0.2, -1.2)

## dof
##----

tls = Econometrics.TLSDist([3.2, 0.2, 1.2])
@test Econometrics.dof(tls) == 3.2

## getParams
##----------

@test Econometrics.getParams(tls) == (3.2, 0.2, 1.2)

## rand
##-----

nSim = 5000
tls = Econometrics.TLSDist([3.2, 0.2, 1.2])
simVals = rand(tls, nSim)

## pdf
##----

tls = Econometrics.TLSDist([3.2, 0.2, 1.2])
pdfVal = Econometrics.pdf(tls, 0.2)

@test isa(pdfVal, Float64)

pdfVals = Econometrics.pdf(tls, simVals)

@test isa(pdfVals, Array{Float64, 1})
@test all(pdfVals .>= 0)

## cdf
##----

tls = Econometrics.TLSDist([3.2, 0.2, 1.2])
cdfVal = Econometrics.cdf(tls, 0.2)

@test isa(cdfVal, Float64)

cdfVals = Econometrics.cdf(tls, simVals)

@test isa(cdfVals, Array{Float64, 1})
@test all(cdfVals .>= 0)
@test all(cdfVals .<= 1)

## quantile
##---------

tls = Econometrics.TLSDist([3.2, 0.2, 1.2])
pVal = Econometrics.quantile(tls, 0.2)

@test isa(pVal, Float64)

## test cdf(quantile(x)) and quantile(cdf(x))
##-------------------------------------------

nSim = 5000
tls = Econometrics.TLSDist([3.2, 0.2, 1.2])
simVals = rand(tls, nSim)
cdfVals = Econometrics.cdf(tls, simVals)
pVals = Econometrics.quantile(tls, cdfVals)
@test_approx_eq pVals simVals

grid = [0.01:0.01:0.99]
pVals = Econometrics.quantile(tls, grid)
cdfVals = Econometrics.cdf(tls, pVals)
@test_approx_eq cdfVals grid

## nllh
##-----

nSim = 5000
tls = Econometrics.TLSDist([3.2, 0.2, 1.2])
simVals = rand(tls, nSim)

nllhVal1 = Econometrics.nllh(tls, simVals)
nllhVal2 = Econometrics.nllh_tls([Econometrics.getParams(tls)...], simVals)

@test_approx_eq nllhVal1 nllhVal2

@test_throws Exception Econometrics.nllh_tls([3.2, 0.2, 1.2, 4.2], simVals)

## fit
##----

nSim = 1000
params = [3.2, 0.2, 1.2]
tls = Econometrics.TLSDist(params)

@time tls1 = Econometrics.fit(Econometrics.TLSDist, simVals)
@time tls2 = Econometrics.fit_jump(Econometrics.TLSDist, simVals)

@test isa(tls1, Econometrics.TLSDist)
@test isa(tls2, Econometrics.TLSDist)

## compare parameters
[params'
[Econometrics.getParams(tls1)...]'
[Econometrics.getParams(tls2)...]']

## compare nllhs
Econometrics.nllh(tls1, simVals)
Econometrics.nllh(tls2, simVals)

end
