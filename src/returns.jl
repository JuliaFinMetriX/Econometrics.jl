###################################################
## logarithmic / discrete return transformations ##
###################################################

function disc2log(tn::AbstractTimenum; percent = F)
    ## discrete net return to logarithmic return
    if percent
        rets = log(tn./100 .+ 1).*100
    else
        rets = log(tn .+ 1)
    end
    return rets
end

function log2disc(tn::AbstractTimenum; percent = F)
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

function price2ret(tn::AbstractTimenum; log = T)
    ## get discrete net returns from historic prices

end

function price2ret(tm::AbstractTimematr; log = T)
    ## get discrete net returns from historic prices

    if log
        rets = tm[2:end, :] .- tm[1:(end-1), :]
    else
        rets = (tm[2:end, :] .- tm[1:(end-1), :]) ./ tm[1:(end-1), :]
    end
    return rets
end

function ret2price(tm::AbstractTimematr; log = T)
    ## get discrete net returns from historic prices
    if log
        prices = cumsum(tm, 1)
    else
        prices = cumprod(tm .+ 1, 1)
    end
    return prices
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
