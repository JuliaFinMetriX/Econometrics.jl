###################################################
## logarithmic / discrete return transformations ##
###################################################

function disc2log(tn::AbstractTimenum; percent = false)
    ## discrete net return to logarithmic return
    if percent
        rets = log(tn./100 .+ 1).*100
    else
        rets = log(tn .+ 1)
    end
    return rets
end

function log2disc(tn::AbstractTimenum; percent = false)
    ## logarithmic return to discrete net return
    if percent
        rets = (exp(tn./100) .- 1).*100
    else
        rets = exp(tn) .- 1
    end
    return rets
end

###############
## price2ret ##
###############

## price2ret for DataArrays
##-------------------------

function price2ret(prices::DataArray; log = true)
    ## find NAs
    naInds = find(isna, prices)
    nNAs = length(naInds)

    ## create price series with NAs replaced by last value
    pricesNoNA = deepcopy(prices)
    for ii=1:nNAs
        if naInds[ii] > 1
            pricesNoNA[naInds[ii]] = pricesNoNA[naInds[ii] - 1]
        end
    end

    ## calculate returns
    if log
        rets = pricesNoNA[2:end] .- pricesNoNA[1:(end-1)]
    else
        rets = (pricesNoNA[2:end] .- pricesNoNA[1:(end-1)]) ./
        pricesNoNA[1:(end-1)] 
    end

    ## fill in NAs again
    for ii=1:nNAs
        if naInds[ii] > 1
            rets[naInds[ii] - 1] = NA
        end
    end
    return rets
end

## price2ret for TimeData types
##-----------------------------

function price2ret(tn::AbstractTimenum; log = true)
    ## dealing with NAs through ret2price for DataArrays

    rets = DataFrame()
    for (nam, col) in eachcol(tn.vals)
        rets[nam] = price2ret(col, log = log)
    end

    return TimeData.Timenum(rets, tn.idx[2:end])
end

function price2ret(tm::AbstractTimematr; log = true)
    ## get discrete net returns from historic prices
    if log
        rets = tm[2:end, :] .- tm[1:(end-1), :] # time index of first
                                        # part is automatically taken! 
    else
        rets = (tm[2:end, :] .- tm[1:(end-1), :]) ./ tm[1:(end-1), :]
    end
    return rets
end

###############
## ret2price ##
###############

## ret2price for DataArrays
##-------------------------

function ret2price(da::DataArray; log = true)
    ## append 0 or NA and transform returns to prices
    nObs = size(da, 1)
    prices = DataArray(eltype(da), nObs+1)

    if isna(da[1])
        ## find first element
        indFirstRet = find(x -> !isna(x), da)[1]
        prices[1:(indFirstRet-1)] = NA
    else
        indFirstRet = 1
    end

    ## different initial value for log / normal prices
    if log
        prices[indFirstRet] = 0
    else
        prices[indFirstRet] = 1
    end

    for ii=(indFirstRet+1):(nObs+1)
        if isna(da[ii-1])
            prices[ii] = prices[ii-1]
        else
            ## different aggregation formulas
            if log
                prices[ii] = prices[ii-1] + da[ii-1]
            else
                prices[ii] = prices[ii-1] .* (1 .+ da[ii-1])
            end
        end
    end

    ## insert NAs again
    inds = find(isna(da))
    for eachNA in inds
        prices[eachNA + 1] = NA
    end

    ## again insert initial price in case it was overwritten
    if log
        prices[indFirstRet] = 0
    else
        prices[indFirstRet] = 1
    end
    return prices
end

## ret2price for TimeData types
##-----------------------------


## ret2price for Timenum
##----------------------

function ret2price(tn::AbstractTimenum; log = true)
    ## dealing with NAs through ret2price for DataArrays

    prices = DataFrame()
    for (nam, col) in eachcol(tn.vals)
        prices[nam] = ret2price(col, log = log)
    end

    ## get previous day / could be not a business day
    initDate = TimeData.idx(tn)[1] - Dates.Day(1)

    ## get indices
    idxs = [initDate; tn.idx]

    return TimeData.Timenum(prices, idxs)
end

## ret2price for Timematr
##-----------------------

function ret2price(tm::AbstractTimematr; log = true)
    ## get normed prices from returns
    (nObs, nVars) = size(tm)

    if log
        prices = cumsum(tm, 1)

        ## get values of first day
        initPrices = zeros(1, nVars)
    else
        prices = cumprod(tm .+ 1, 1)

        ## get values of first day
        initPrices = ones(1, nVars)
    end
    
    ## get previous day / could be not a business day
    initDate = TimeData.idx(tm)[1] - Dates.Day(1)

    ## get first day as Timematr
    initPricesDf = TimeData.composeDataFrame(initPrices, names(tm)) 
    initPricesTm = TimeData.Timematr(initPricesDf,
                                     [initDate])
    
    return [initPricesTm; prices]
    
end

#########################################
## ret2price with given price metadata ##
#########################################

## ret2price with prices - Timenum
##--------------------------------

function ret2price(rets::AbstractTimenum,
                   prices::AbstractTimenum; log = true)

    ## find first prices
    (nObs, nVars) = size(rets)

    initPrices = DataFrame()
    for (nam, col) in eachcol(prices.vals)
        if isna(col[1])
            ## find first element
            indFirstPrice = find(x -> !isna(x), col)[1]
            initPrice = col[indFirstPrice]
        else
            initPrice = col[1]
        end
        initPrices[nam] = initPrice*ones(nObs+1)
    end

    ## get normalized prices via DataArrays
    normedPrices = DataFrame()
    for (nam, col) in eachcol(rets.vals)
        normedPrices[nam] = ret2price(col, log = log)
    end
    normedPricesIdxs = [prices.idx[1]; rets.idx]
    normedPricesTn = TimeData.Timenum(normedPrices, normedPricesIdxs)

    ## add / multiply initPrices to each element
    initPricesTn = TimeData.Timenum(initPrices, normedPricesIdxs)
    
    if log
        newPricesTn = normedPricesTn .+ initPricesTn
    else
        newPricesTn = normedPricesTn .* initPricesTn
    end
    
    return newPricesTn
end

## ret2price with prices - Timematr
##---------------------------------

function ret2price(tm::AbstractTimematr,
                   prices::AbstractTimenum; log = true)

    normalizedPrices = ret2price(tm, log = log)
    (nObs, nVars) = size(normalizedPrices)

    ## add initial prices to each element
    initPricesTm = convert(Timematr, prices[1, :])
    initPrices = composeDataFrame(repmat(core(initPricesTm), nObs, 1),
                                  names(normalizedPrices))
    initPricesTm = Timematr(initPrices, normalizedPrices.idx)

    if log
        newPrices = normalizedPrices .+ initPricesTm
    else
        newPrices = normalizedPrices .* initPricesTm
    end
    
    ## fix first date
    newPrices.idx[1] = prices.idx[1]

    return newPrices
end


## #####################################
## ## low-level aggregation functions ##
## #####################################

## function aggrLog(rets::Array{Float64, 2})
##     return sum(rets, 1)
## end

## function aggrLogPercent(rets::Array{Float64, 2})
##     return aggrLog(rets)
## end

## function aggrDiscr(rets::Array{Float64, 2})
##     return prod(rets+1, 1) - 1
## end

## function aggrDiscrPercent(rets::Array{Float64, 2})
##     return (prod(rets/100 + 1, 1) - 1)*100
## end

## #################
## ## aggregation ##
## #################

## function getLastPeriodIndices(n, by)
##     ## get start index
##     startInd = mod(n, by) + 1
##     return [(startInd+by-1):by:n]
## end

## function aggregate(tm::Timematr, by::Integer = 20,
##                    aggrFunc::Function = aggrLog)
##     ## aggregate by using most recent observations

##     (nObs, nAss) = size(tm)
##     vals = core(tm)

##     ## how many aggregations
##     nAggrRets = div(nObs, by)

##     ## get aggregation intervals and last interval dates
##     aggrIndices = getLastPeriodIndices(nObs, by)
##     aggrDates = idx(tm)[aggrIndices]

##     aggrRets = ones(nAggrRets, nAss)
##     for ii=1:nAggrRets
##         startInd = aggrIndices[ii]-by+1
##         aggrRets[ii, :] = aggrFunc(vals[startInd:aggrIndices[ii], :])
##     end

##     return Timematr(aggrRets, aggrDates)
## end

## ######################################
## ## get correlations for frequencies ##
## ######################################

## ## select pair of assets
## ## for each frequency
## ## - get number of possible starting points: remain + by
## ## - aggregate according to frequency in multiple ways
## ## - for each aggregation, get correlation
## ##


## function frequCorrPlot(tm::Timematr, ind1::Integer = 1,
##                        ind2::Integer = 2,
##                        maxFreq::Integer = 50)
##     ## select data
##     data = tm[:, [ind1, ind2]]
##     nObs = size(data, 1)

##     corrs = Float64[]
##     frequencies = Float64[]
##     for frequ=1:maxFreq
##         ## get number of possible phases
##         nPhases = mod(nObs, frequ) + frequ
##         nObsPerPhase = (div(nObs, frequ) - 1)*frequ
##         ## corrsCurrentFrequ = ones(nPhases)

##         for ii=1:nPhases
##             ## get current data
##             corrData = aggregate(data[ii:(ii + nObsPerPhase - 1), :],
##                                  frequ)
##             ## corrsCurrentFrequ[ii] = cor(corrData)[1, 2]
##             corr = cor(corrData)[1, 2]
##             push!(frequencies, frequ)
##             push!(corrs, corr)
##         end

##         ## push!(a, [frequ*ones(nPhases) corrsCurrentFrequ])
##     end

##     return [frequencies corrs]
## end
