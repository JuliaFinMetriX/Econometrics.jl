module TestNormiid

using Distributions
using TimeData
using Base.Test

import Econometrics

## reload(joinpath(Pkg.dir(), "Econometrics", "src", "Econometrics.jl"))

#############
## NormIID ##
#############

## constructors / display
##-----------------------

issubtype(Econometrics.NormIID, Econometrics.AbstrUnivarModel)

@test_throws Exception Econometrics.NormIID(0.3, -0.2)

mod = Econometrics.NormIID(0.3, 1.2)
mod = Econometrics.NormIID([0.3, 1.2])

println("\nTesting display output:")
display(mod)
Econometrics.description(mod)

## getParams
##----------

mod = Econometrics.NormIID(0.3, 1.2)
@test Econometrics.getParams(mod) == (0.3, 1.2)

## simulate
##---------

nSim = 5000
simVals = Econometrics.simulate(mod, nSim)

## estimate
##---------

normIID_fit = Econometrics.estimate(Econometrics.NormIID, simVals)

## compare parameters
[[Econometrics.getParams(mod)...]'
[Econometrics.getParams(normIID_fit)...]']

end
