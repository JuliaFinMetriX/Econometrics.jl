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

################################
## return / price conversions ##
################################

function price2ret(prices::AbstractTimenum; log = true)
    ## get discrete net returns from historic prices as Timenum

    ## create price series without NAs
    pricesNoNA = Timenum(deepcopy(prices.vals), idx(prices))
    imputePreviousObs!(pricesNoNA)


    ## get returns through method of Timematr
    logRet = convert(Timematr, pricesNoNA) |>
    x -> price2ret(x, log = log) |>
    x -> convert(Timenum, x)
    
    for ii=1:size(logRet, 1)
        for jj=1:size(logRet, 2)
            if isna(prices.vals[ii + 1, jj])
                setNA!(logRet, ii, jj)
            end
        end
    end
    return logRet                       # Timenum
end

function price2ret(tm::AbstractTimematr; log = true)
    ## get discrete net returns from historic prices
    if log
        rets = tm[2:end, :] .- tm[1:(end-1), :]
    else
        rets = (tm[2:end, :] .- tm[1:(end-1), :]) ./ tm[1:(end-1), :]
    end
    return rets
end

function ret2price(tm::AbstractTimematr; log = true)
    ## get normed prices from returns
    if log
        prices = cumsum(tm, 1)
    else
        prices = cumprod(tm .+ 1, 1)
    end
    return prices
end

function ret2price(tn::AbstractTimenum; log = true)
    ## get normed prices from returns
    tm = Timematr(deepcopy(tn.vals), tn.idx)
    
    (nObs, nVars) = size(tm)
    rowInd = Array(Int, 0)
    colInd = Array(Int, 0)
    for ii=1:nVars
        for jj=1:nObs
            if isna(tm2.vals[jj, ii])
                tm.vals[jj, ii] = 0
                push!(rowInd, jj)
                push!(colInd, ii)
            end
        end
    end
        
    if log
        prices = cumsum(tm, 1)
    else
        prices = cumprod(tm .+ 1, 1)
    end

    pricesTn = convert(Timenum, prices) # convert to Timenum

    for eachna=1:length(rowInd)
        setNA!(pricesTn, rowInd(eachna), colInd(eachna))
    end
    return pricesTn
end


function ret2price(tm::AbstractTimematr,
                   initPrices::AbstractTimenum; log = true)
    ## get discrete net returns from historic prices
    if isa(Timenum, initPrices)
        initPrices = convert(Timematr, initPrices)
    end
    
    if log
        prices = cumsum(tm, 1)
    else
        prices = cumprod(tm .+ 1, 1)
    end
    return prices
end

function ret2price(tm)
## get returns
logRet = Econometrics.price2ret(prices)

## manipulate copy of returns
logRet2 = deepcopy(logRet)
TimeData.impute!(logRet2, "zero")
logRetTm = convert(TimeData.Timematr, logRet2)

## get prices
cumPrices = TimeData.cumsum(logRetTm, 1)
cumPrices = convert(TimeData.Timenum, cumPrices)

## insert NAs again
(rowInds, colInds) = TimeData.find2sub(isna, logRet)
nNAs = length(rowInds)
for ii=1:nNAs
    TimeData.setNA!(cumPrices, rowInds[ii], colInds[ii])
end

## add initial value
initPrices = convert(TimeData.Timematr, prices[1, :])
initPricesMatr = TimeData.asTn(TimeData.core(initPrices), cumPrices)

cumPrices .+ initPricesMatr

end

###########################
## imputing missing data ##
###########################

function imputePreviousObs!(td::AbstractTimedata)
    ## replace NA by previous observation
    error("not working for NAs at first day")
    nObs = size(td, 1)
    for singleCol in eachcol(td.vals)
        for jj=1:nObs
            if isna(singleCol[2][jj])
                singleCol[2][jj] = singleCol[2][jj-1]
            end
        end
    end
    return td
end

#####################################
## low-level aggregation functions ##
#####################################

function aggrLog(rets::Array{Float64, 2})
    return sum(rets, 1)
end

function aggrLogPercent(rets::Array{Float64, 2})
    return aggrLog(rets)
end

function aggrDiscr(rets::Array{Float64, 2})
    return prod(rets+1, 1) - 1
end

function aggrDiscrPercent(rets::Array{Float64, 2})
    return (prod(rets/100 + 1, 1) - 1)*100
end

#################
## aggregation ##
#################

function getLastPeriodIndices(n, by)
    ## get start index
    startInd = mod(n, by) + 1
    return [(startInd+by-1):by:n]
end

function aggregate(tm::Timematr, by::Integer = 20,
                   aggrFunc::Function = aggrLog)
    ## aggregate by using most recent observations
    
    (nObs, nAss) = size(tm)
    vals = core(tm)
    
    ## how many aggregations
    nAggrRets = div(nObs, by)
    
    ## get aggregation intervals and last interval dates
    aggrIndices = getLastPeriodIndices(nObs, by)
    aggrDates = idx(tm)[aggrIndices]
    
    aggrRets = ones(nAggrRets, nAss)
    for ii=1:nAggrRets
        startInd = aggrIndices[ii]-by+1
        aggrRets[ii, :] = aggrFunc(vals[startInd:aggrIndices[ii], :])
    end
    
    return Timematr(aggrRets, aggrDates)
end

######################################
## get correlations for frequencies ##
######################################

## select pair of assets
## for each frequency
## - get number of possible starting points: remain + by
## - aggregate according to frequency in multiple ways
## - for each aggregation, get correlation
##


function frequCorrPlot(tm::Timematr, ind1::Integer = 1,
                       ind2::Integer = 2,
                       maxFreq::Integer = 50)
    ## select data
    data = tm[:, [ind1, ind2]]
    nObs = size(data, 1)
    
    corrs = Float64[]
    frequencies = Float64[]
    for frequ=1:maxFreq
        ## get number of possible phases
        nPhases = mod(nObs, frequ) + frequ
        nObsPerPhase = (div(nObs, frequ) - 1)*frequ
        ## corrsCurrentFrequ = ones(nPhases)
        
        for ii=1:nPhases
            ## get current data
            corrData = aggregate(data[ii:(ii + nObsPerPhase - 1), :],
                                 frequ)
            ## corrsCurrentFrequ[ii] = cor(corrData)[1, 2]
            corr = cor(corrData)[1, 2]
            push!(frequencies, frequ)
            push!(corrs, corr)
        end
        
        ## push!(a, [frequ*ones(nPhases) corrsCurrentFrequ])
    end
    
    return [frequencies corrs]
end
