module TestReturns

using Base.Test
using TimeData
using Econometrics
using DataFrames
using Dates

## println("\n Running return function tests\n")

#########################
## disc2log / log2disc ##
#########################

## percentage returns
##-------------------

ret = Timematr(DataFrame(returns = [2, 3]))

## log2disc(disc2log(x)) = x
ret2 = Econometrics.log2disc(Econometrics.disc2log(ret, percent=true),
                             percent=true)

@test_approx_eq TimeData.core(ret) TimeData.core(ret2)

## no percentage returns
##----------------------

ret = Timematr(DataFrame(returns = [0.2, 0.3]))
ret2 = Econometrics.log2disc(Econometrics.disc2log(ret, percent=false),
                             percent=false)

@test_approx_eq TimeData.core(ret) TimeData.core(ret2)


###############
## price2ret ##
###############

prices = testcase(TimeData.Timenum, 2)
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

prices = testcase(TimeData.Timematr, 1)
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

##################################
## 1. example: NAs at beginning ##
##################################

prices = @data([NA, NA, 3, 4, 6])

## using log returns
##------------------

logRet = Econometrics.price2ret(prices, log = true)
expRets = @data([NA, NA, 1, 2])
@test isequal(logRet, expRets)

normedPrices = Econometrics.ret2price(logRet, log = true)
expNormed = @data([NA, NA, 0, 1, 3])
@test isequal(normedPrices, expNormed)

## using dicrete returns
##----------------------

discRet = Econometrics.price2ret(prices, log = false)
expRets = @data([NA, NA, 1/3, 0.5])
@test isequal(discRet, expRets)

normedPrices = Econometrics.ret2price(discRet, log = false)
expNormed = @data([NA, NA, 1, 1+1/3, 2])
@test isequal(normedPrices, expNormed)

################################
## 2. example: NAs in between ##
################################

prices = @data([110, 120, NA, 130, NA])

## using log returns
##------------------

logRet = Econometrics.price2ret(prices, log = true)
expRets = @data([10, NA, 10, NA])
@test isequal(logRet, expRets)

normedPrices = Econometrics.ret2price(logRet, log = true)
expNormed = @data([0, 10, NA, 20, NA])
@test isequal(normedPrices, expNormed)

## using dicrete returns
##----------------------

discRet = Econometrics.price2ret(prices, log = false)
expRets = @data([10/110, NA, 10/120, NA])
@test isequal(discRet, expRets)

normedPrices = Econometrics.ret2price(discRet, log = false)
expNormed = @data([1, 1+10/110, NA, 1+20/110, NA])
@test_approx_eq normedPrices[[1,2,4]] expNormed[[1,2,4]]

########################
## 3. example: no NAs ##
########################

prices = @data([100, 120, 110, 170, 160])

## using log returns
##------------------

logRet = Econometrics.price2ret(prices, log = true)
expRets = @data([20, -10, 60, -10])
@test isequal(logRet, expRets)

normedPrices = Econometrics.ret2price(logRet, log = true)
expNormed = @data([0, 20, 10, 70, 60])
@test isequal(normedPrices, expNormed)

## using dicrete returns
##----------------------

discRet = Econometrics.price2ret(prices, log = false)
expRets = @data([0.2, -10/120, 60/110, -10/170])
@test isequal(discRet, expRets)

normedPrices = Econometrics.ret2price(discRet, log = false)
expNormed = @data([1, 1.2, 1.1, 1.7, 1.6])
@test_approx_eq normedPrices[[1,2,4]] expNormed[[1,2,4]]



############################
## same tests for Timenum ##
############################

df = DataFrame()
df[:prices1] = @data([100, 120, 110, 170, 160])
df[:prices2] = @data([110, 120, NA, 130, NA])
df[:prices3] = @data([NA, NA, 3, 4, 6])

dats = [Date(2010,1,1):Date(2010,1,5)]
prices = Timenum(df, dats)

## using log returns
##------------------

logRet = Econometrics.price2ret(prices, log = true)
normedPrices = Econometrics.ret2price(logRet, log = true)
originalPrices = Econometrics.ret2price(logRet, prices, log = true)
@test isequal(prices, originalPrices)

## using dicrete returns
##----------------------

discRet = Econometrics.price2ret(prices, log = false)
normedPrices = Econometrics.ret2price(discRet, log = false)
originalPrices = Econometrics.ret2price(discRet, prices, log = false)
@test isapprox(prices, originalPrices)


########################
## tests for Timematr ##
########################

df = DataFrame()
df[:prices1] = @data([100, 120, 110, 170, 160])
dats = [Date(2010,1,1):Date(2010,1,5)]
prices = Timenum(df, dats)

## using log returns
##------------------

logRet = Econometrics.price2ret(prices, log = true)
normedPrices = Econometrics.ret2price(logRet, log = true)
originalPrices = Econometrics.ret2price(logRet, prices, log = true)
@test isequal(prices, originalPrices)

## using dicrete returns
##----------------------

discRet = Econometrics.price2ret(prices, log = false)
normedPrices = Econometrics.ret2price(discRet, log = false)
originalPrices = Econometrics.ret2price(discRet, prices, log = false)
@test isapprox(prices, originalPrices)

end
