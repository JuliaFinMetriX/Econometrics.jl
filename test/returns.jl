module TestReturns

using Base.Test
using TimeData
using Econometrics

println("\n Running return function tests\n")

#########################
## disc2log / log2disc ##
#########################

## percentage returns
##-------------------

ret = TimeData.Timematr(DataFrame(returns = [2, 3]))
ret2 = Econometrics.log2disc(Econometrics.disc2log(ret, percent=true),
                             percent=true)

@test_approx_eq TimeData.core(ret) TimeData.core(ret2)

## no percentage returns
##----------------------

ret = TimeData.Timematr(DataFrame(returns = [0.2, 0.3]))
ret2 = Econometrics.log2disc(Econometrics.disc2log(ret, percent=false),
                             percent=false)

@test_approx_eq TimeData.core(ret) TimeData.core(ret2)


###############
## price2ret ##
###############

prices = TimeData.testcase(TimeData.Timenum, 2)
logRet = Econometrics.price2ret(prices, log = true)

## manually determine expected result
##-----------------------------------

idxs = prices.idx[2:end]
expTn = TimeData.Timenum(DataFrame(prices1 = @data([NA, 20, 30, 30]),
                                   prices2 = @data([10, NA, 10, NA])),
                         idxs)

## test
@test isequal(logRet, expTn)

## test Timematr
##--------------

prices = TimeData.testcase(TimeData.Timematr, 1)
logRet = Econometrics.price2ret(prices, log = true)

idxs = prices.idx[2:end]
expTn = TimeData.Timematr(DataFrame(prices1 = [20, -10, 60],
                                    prices2 = [10, -20, 30]),
                          idxs)

## test
@test isequal(logRet, expTn)


## same for discrete returns
##--------------------------

prices = TimeData.testcase(TimeData.Timenum, 2)
discRet = Econometrics.price2ret(prices, log = false)

@test_approx_eq ((140-120) / 120) TimeData.core(discRet[2, 1])
@test_approx_eq ((120-110) / 110) TimeData.core(discRet[1, 2])
@test isna(TimeData.core(discRet[2, 2])[1])


###############
## ret2price ##
###############

## for DataArrays
##---------------

## price2ret and ret2price must be inverse
##----------------------------------------

daRets = @data([NA, NA, NA, 3, 4, 6])
prices = Econometrics.ret2price(daRets, log = true)
pricesTn = TimeData.Timenum(DataFrame(prices1 = prices))
tnRets = Econometrics.price2ret(pricesTn)
@test isequal(daRets, tnRets.vals[1])


daRets = @data([NA, NA, NA, 3, 4, 6])./100
prices = Econometrics.ret2price(daRets, log = false)
pricesTn = TimeData.Timenum(DataFrame(prices1 = prices))
tnRets = Econometrics.price2ret(pricesTn, log = false)
@test_approx_eq array(daRets[4:end]) array(tnRets.vals[1][4:end])



end
