module TestReturns

using Base.Test
using TimeData
using EconDatasets
using DataFrames
using Dates
using DataArrays
using GLM

include(joinpath(Pkg.dir("Econometrics"), "src/Econometrics.jl"))

###################
## get test data ##
###################

fname = joinpath(Pkg.dir("Econometrics"), "test/data/intRates.csv")
intData = readTimedata(fname)

#########################
## test type interface ##
#########################

# constructor using tuple
origParams = (0.4, 3.2, 0.2)
cirMod = Econometrics.CIR(origParams...)
params = Econometrics.getParams(cirMod)
@test params == origParams

origParams = (0.4, 3.2, 0.2)
cirMod = Econometrics.CIR(origParams..., Dates.Day(1))
params = Econometrics.getParams(cirMod)
@test params == origParams
@test cirMod.scale == Dates.Day(1)

# constructor using array
origParamsArr = [origParams...]
cirMod = Econometrics.CIR(origParamsArr)
params = Econometrics.getParams(cirMod)
@test params == origParams

##############################
## test likelihood function ##
##############################

## load matlab results
res_llh_fname = joinpath(Pkg.dir("Econometrics"), "test/data/matlab_llhs.csv")
llhs = readcsv(res_llh_fname)

## reproduce values in Julia
##--------------------------

data = intData.vals[1] |>
         x -> x[!isna(x)]

## testcase 1
params = (0.4, 3.2, 0.2)
cirMod = Econometrics.CIR([params...])

jl_llh = Econometrics.cirNllhx(data, cirMod, 1/250)
@test_approx_eq_eps jl_llh llhs[1] 0.08

jl_llh = Econometrics.cirNllhx(data, [params...], 1/250)
@test_approx_eq_eps jl_llh llhs[1] 0.08

## testcase 2
params = (0.8, 3.0, 0.8)
cirMod = Econometrics.CIR([params...])

jl_llh = Econometrics.cirNllhx(data, cirMod, 1/250)
@test_approx_eq_eps jl_llh llhs[2] 0.08

jl_llh = Econometrics.cirNllhx(data, [params...], 1/250)
@test_approx_eq_eps jl_llh llhs[2] 0.08

## testcase 3
params = (1.2, 2.0, 0.4)
cirMod = Econometrics.CIR([params...])

jl_llh = Econometrics.cirNllhx(data, cirMod, 1/250)
@test_approx_eq_eps jl_llh llhs[3] 0.08

## test with missing data - not reproducible in matlab
##----------------------------------------------------

# with missing data - no values for comparison available
Econometrics.cirNllhx(intData.vals[1], cirMod, 1/250)
Econometrics.cirNllhx(intData.vals[1], [params...], 1/250)


####################################
## test conditional distributions ##
####################################



##############
## test OLS ##
##############

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

