## using TimeData

## include("/home/chris/research/julia/TimeData/src/TimeData.jl")
include("/home/chris/research/julia/Econometrics/src/Econometrics.jl")
using TimeData
using Winston
using Distributions

tm = readTimedata("/home/chris/research/asset_mgmt/data/datesLogRet.csv")

## get 5 lowest minima stocks
mapFunc(x) = minimum(x)
critFunc(x) = islowest(x, 5)
mostNegativeReturns = TimeData.getVars(tm, mapFunc, critFunc)


#########################
## get moving averages ##
#########################

import Winston.plot
function plot(tm::Timematr)
    plot(core(tm))
end

movAvgs = movAvg(tm, 150)
plot(movAvgs)

marketMeans = rowmeans(tm)
plot(marketMeans)
var(core(marketMeans))

marketMovAvg = movAvg(marketMeans, 400)
plot(marketMovAvg)
Winston.ylim(-0.6, 0.6)

######################################
## mean-shifting induced dependency ##
######################################

marketMovAvg = movAvg(marketMeans, 20)
plot(marketMovAvg)
Winston.ylim(-0.6, 0.6)

## for each day, simulate independent normally distributed values
nDays = size(marketMovAvg, 1)

using Distributions
d = Normal(0, 1.6)
simInnov = rand(d, nDays, 2)
simVals = simInnov + repmat(core(marketMovAvg), 1, 2)
cor(simVals[:, 1], simVals[:,2])

## plot autocor
p = []
for ii=1:20
    if(ii==1)
        p = autocorr(core(tm[1])[:])
    else
        p = autocorr!(core(tm[ii])[:])
    end
end
p
autocorr_red!(simVals[:, 1])

## look at ranks!!

######################################
## correlations for all frequencies ##
######################################

maxAggregation = 50

## include("/home/chris/research/julia/TimeData/src/TimeData.jl")
## tm = readTimedata("/home/chris/research/asset_mgmt/data/datesLogRet.csv")
nObs = size(tm, 2)

frequ = 50
for ii=1:20
    eqVal = true
    x = 0
    y = 0
    while(eqVal)
        (x, y) = [rand(1:nObs) rand(1:nObs)]
        if x !== y
            eqVal = false
        end
    end
    println("first: ", x, " , second: ", y)
    a = Econometrics.frequCorrPlot(tm, x, y, frequ)
    plot(a[:, 1], a[:, 2], "+b")
    ylim(-0.2, 1)
    ## p = FramedPlot(
    ##                xrange=(0,frequ),
    ##                yrange=(-0.3,1))
    ## ## pts = Points(a[:, 1], a[:, 2], kind="filled circle")
    ## pts = Points(a[:, 1], a[:, 2], kind="plus")
    ## add(p, pts)
    fname = string("./pics/corrFrequ", ii, ".png")
    file(fname)
end
    
    
    ## create simulated data with no autocorrelation

nSim = 15000
using Distributions
## create two-dimensional normal distribution
rho = 0.5
sigma1 = 1.4
sigma2 = 1.4
covMatr = [sigma1^2 sigma1*sigma2*rho; sigma1*sigma2*rho sigma2^2]
d = MvNormal(covMatr)

simInnov = rand(d, nSim)
tmSim = Timematr(simInnov')
a = TimeData.frequCorrPlot(tmSim, 1, 2, frequ)
plot(a[:, 1], a[:, 2], "+b")
ylim(-0.2, 1)

###########
## GARCH ##
###########

testData = tm[1]

## load econometrics library
include("/home/chris/research/julia/Econometrics/src/Econometrics.jl")

(sigmaHat, paramsHat) = Econometrics.garchFit(testData)

plot(sigmaHat)

sigma = sqrt(var(core(testData)))
initVal = [0, sigma^2, 0, 0, sigma]

params1 =  [0.0338456,
            0.463194,
            0.616413,
            0.193743,
            1.39494]

params2 = [ 0.056642,
           0.0467392,
           0.932111,
           0.0485675,
           1.01403]

Econometrics.garchLLH(paramsHat, core(testData))
Econometrics.garchLLH(params2, core(testData))

d = Normal(0, sigma)
nllh2 = -sum(log(pdf(d, core(testData))))

kk = x -> Econometrics.garchLLH(x, core(testData))
kk(initVal)

garchObj = garchFit(core(tm[1])[:])
sigs = garchObj.sigma
plot(sigs)

