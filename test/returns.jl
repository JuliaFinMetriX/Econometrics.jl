module TestAbstractFuncs

using Base.Test
using TimeData
using Distributions

println("\n Running financial functions tests\n")

d = Normal(0.02, 1.6)
simRetsPercent = rand(d, 10, 2)
simRets = simRetsPercent / 100

@test_approx_eq aggrLogPercent(simRetsPercent) aggrLogPercent(simRets)*100
@test_approx_eq aggrDiscrPercent(simRetsPercent) aggrDiscr(simRetsPercent/100)*100


###################################################
## logarithmic / discrete return transformations ##
###################################################

@test_approx_eq log2disc(disc2log(0.04)) 0.04
@test_approx_eq disc2log(log2disc(0.04)) 0.04
@test_approx_eq log2discPercent(disc2logPercent(4)) 4
@test_approx_eq disc2logPercent(log2discPercent(4)) 4

## test aggregations
@test_approx_eq aggrLog(simRets) disc2log(aggrDiscr(log2disc(simRets)))

## test aggregations with percentage returns
@test_approx_eq aggrLog(simRetsPercent) disc2logPercent(aggrDiscrPercent(log2discPercent(simRetsPercent)))

end
