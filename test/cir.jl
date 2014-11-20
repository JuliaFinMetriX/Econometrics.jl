module TestReturns

using Base.Test
using TimeData
using EconDatasets
using DataFrames
using Dates
using DataArrays
using GLM

include(joinpath(Pkg.dir("Econometrics"), "src/Econometrics.jl"))

## get test data
##--------------

fname = joinpath(Pkg.dir("Econometrics"), "test/data/intRates.csv")
intData = readTimedata(fname)

# get R results and compare them to actual Julia test values
resultsFname = joinpath(Pkg.dir("Econometrics"), "test/data/r_results.RData")
rRes = read_rda(resultsFname)

## test ols
##---------

expParams = Float64[rRes["olsParams"].data[ii].data[1] for ii=1:3]
actParams = Econometrics.cirOls(intData.vals[:, 1], 1/250)

@test_approx_eq expParams[1] actParams[1]
@test_approx_eq expParams[2] actParams[2]
@test_approx_eq expParams[3] actParams[3]

## test log-likelihood
##--------------------

expNLLH = rRes["nllh"].data[1]
actNLLH = Econometrics.cirNllh(intData.vals[:, 1], actParams)

da = intData.vals[:, 1]
params = actParams

