module TestTlsiid

using Distributions
using TimeData
using Base.Test

import Econometrics

## reload(joinpath(Pkg.dir(), "Econometrics", "src", "Econometrics.jl"))

############
## TlsIID ##
############

## constructors / display
##-----------------------

issubtype(Econometrics.TlsIID, Econometrics.AbstrUnivarModel)

@test_throws Exception Econometrics.TlsIID(-0.3, -0.2, 0.1)
@test_throws Exception Econometrics.TlsIID(0.3, -0.2, -0.1)

mod = Econometrics.TlsIID(0.3, -0.2, 0.1)

println("\nTesting display output:")
display(mod)
Econometrics.description(mod)

## getParams
##----------

mod = Econometrics.TlsIID(2.3, 0.2, 1.4)
@test Econometrics.getParams(mod) == (2.3, 0.2, 1.4)

## simulate
##---------

nSim = 5000
mod = Econometrics.TlsIID(2.3, 0.2, 1.4)
simVals = Econometrics.simulate(mod, nSim)

## estimate
##---------

mod_fit = Econometrics.estimate(Econometrics.TlsIID, simVals)

## compare parameters
[[Econometrics.getParams(mod)...]'
[Econometrics.getParams(mod_fit)...]']

end
