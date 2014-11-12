module TestReturns

using Base.Test
using TimeData
using Econometrics
using DataFrames
using Dates
using DataArrays


###########
## ranks ##
###########

x = [0.4, 0.8, 0.2, 0.1]
@test Econometrics.ranks(x) == [0.6, 0.8, 0.4, 0.2]

xx = [x x]
@test Econometrics.ranks(xx) == [Econometrics.ranks(x)
                                 Econometrics.ranks(x)]

## DataArrays
##-----------

da = @data([3, 4, NA, 2.3, 1 ])
expOut = @data([0.6, 0.8, NA, 0.4, 0.2])
@test isequal(ranks(da), daOut)

## Timenum
##--------

xIn = testcase(Timenum, 4)
da1 = @data([1:5]/6)
da2 = @data([0.2, 0.4, NA, 0.6, 0.8])
expOutDf = DataFrame(prices1 = da1, prices2 = da2)

actOut = ranks(xIn)
@test isequal(actOut.vals, expOutDf)
@test isequal(names(actOut), names(xIn))
@test idx(actOut) == idx(xIn)


## Timematr
##---------

xIn = testcase(Timematr, 1)
da1 = @data([0.2, 0.6, 0.4, 0.8])
da2 = @data([0.4, 0.6, 0.2, 0.8])
expOutDf = DataFrame(prices1 = da1, prices2 = da2)

actOut = ranks(xIn)
@test isequal(actOut.vals, expOutDf)
@test isequal(names(actOut), names(xIn))
@test idx(actOut) == idx(xIn)

end
