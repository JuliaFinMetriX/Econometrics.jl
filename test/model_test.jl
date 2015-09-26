module TestModel

using Distributions
using TimeData
using DataArrays
using DataFrames
using Dates
using Base.Test

import Econometrics

## reload(joinpath(Pkg.dir(), "Econometrics", "src", "Econometrics.jl"))

## create dummy Timenum data with missing values
mod = Econometrics.TlsIID(3.4, -0.8, 1.2)
nSim = 100
da = DataArray(Float64, nSim + 10)
da[11:end] = Econometrics.simulate(mod, nSim)
df = DataFrame(OrigData = da)
dats = Date[Date(2001,1,1)+Dates.Day(ii) for ii=1:nSim+10]
tn = Timenum(df, dats)

## test resimulate with given model
##---------------------------------

dataSim = Econometrics.resimulate(tn, mod)

## test equal missing values
@test all(isna(tn.vals[1]) .== isna(dataSim.vals[1]))

## values should come from similar distribution
mod_fit = Econometrics.estimate(Econometrics.TlsIID,
                                dropna(dataSim.vals[1]))

## compare
[[Econometrics.getParams(mod)...]'
[Econometrics.getParams(mod_fit)...]']

## test resimulate with model fitting
##-----------------------------------

dataSim = Econometrics.resimulate(tn, Econometrics.TlsIID)
dataSim = Econometrics.resimulate(tn, Econometrics.NormIID)

end
