module GarchTest

using Distributions
using TimeData
using Base.Test
using NLopt

import Econometrics

## reload(joinpath(Pkg.dir(), "Econometrics", "src", "Econometrics.jl"))

############################
## constructors / display ##
############################

## GARCH(1,1), normal innovations
##-------------------------------

## test construction of GARCH(1,1) with normal
params = [0.02, 0.000004, 0.0906, 0.8959]

gMod = Econometrics.GARCH_1_1(params..., Normal())
gMod = Econometrics.GARCH_1_1(params, Normal())

@test isa(gMod, Econometrics.GARCH_1_1{Normal})

params = [0.02, -0.000004, 0.0906, 0.8959]
@test_throws Exception Econometrics.GARCH_1_1(params, Normal)

params = [0.02, -0.000004, 0.0906, 0.8959]
@test_throws Exception Econometrics.GARCH_1_1(params, Normal())

params = [0.02, 0.000004, -0.0906, 0.8959]
@test_throws Exception Econometrics.GARCH_1_1(params, Normal())

params = [0.02, 0.000004, 0.0906, -0.8959]
@test_throws Exception Econometrics.GARCH_1_1(params, Normal())

params = [0.02, 0.000004, 0.0906, 0.9959]
@test_throws Exception Econometrics.GARCH_1_1(params, Normal())

## GARCH(1,1), t innovations
##--------------------------

## test construction of GARCH(1,1) with Student's t
params = [0.02, 0.000004, 0.0906, 0.8959]

gMod = Econometrics.GARCH_1_1(0.02, 0.000004, 0.0906, 0.8959,
                              TDist(3.2))
@test isa(gMod, Econometrics.GARCH_1_1{TDist})

##############
## simulate ##
##############

## reload(joinpath(Pkg.dir(), "Econometrics", "src", "Econometrics.jl"))

nSim = 1000
params = [0.02, 0.000004, 0.0906, 0.8959]

## with normal innovations
gMod = Econometrics.GARCH_1_1(params, Normal())
simVals = Econometrics.simulate(gMod, nSim)

## with t innovations
gMod = Econometrics.GARCH_1_1(params, Econometrics.TDist(3.2))
simVals = Econometrics.simulate(gMod, nSim)

## with normal innovations and initial sigma
gMod = Econometrics.GARCH_1_1(params, Normal())
simVals = Econometrics.simulate(gMod, nSim, 0.01)

## with t innovations and initial sigma
gMod = Econometrics.GARCH_1_1(params, Econometrics.TDist(3.2))
simVals = Econometrics.simulate(gMod, nSim, 0.01)

###############
## getSigmas ##
###############

params = [0.02, 0.000004, 0.0906, 0.8959]
gMod = Econometrics.GARCH_1_1(params, Normal())

sigmas = Econometrics.getSigmas(gMod, simVals, 0.02)

##############
## estimate ##
##############

## GARCH(1,1), normal innovations
##-------------------------------

nSim = 1000
params = [0.02, 0.000004, 0.0906, 0.8959]
gMod = Econometrics.GARCH_1_1(params, Normal())
simVals = Econometrics.simulate(gMod, nSim)
gModHat = Econometrics.estimate(Econometrics.GARCH_1_1{Normal},
                           simVals)


## t innovations for normal data
gModHat = Econometrics.estimate(Econometrics.GARCH_1_1{TDist},
                           simVals)

## t innovations, t data
gMod = Econometrics.GARCH_1_1(params, TDist(4.3))
simVals = Econometrics.simulate(gMod, nSim)
gModHat = Econometrics.estimate(Econometrics.GARCH_1_1{TDist},
                           simVals)

gMod

#########
## fit ##
#########

gModFit = Econometrics.fit(Econometrics.GARCH_1_1{Normal},
                           simVals)

gModFit = Econometrics.fit(Econometrics.GARCH_1_1{TDist},
                           simVals)

end
