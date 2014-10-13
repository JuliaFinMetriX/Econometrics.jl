## high level function dealing with NAs and formulas
##--------------------------------------------------

function reduceReturns(da::DataVector, allowedNAs::Float64 = 0.1;
                   log::Bool = true, pct::Bool = false)
    ## reduce series of returns to single number
    ## if more than allowedNAs NAs, return NA
    nObs = size(da, 1)
    nNAs = sum(isna(da))

    if nNAs/nObs > allowedNAs
        return NA
    else # apply reduction to values only
        vals = da[!isna(da)]
        if log
            reduce = reduceLog(vals)
        elseif !log & pct
            reduce = reduceDiscrPercent(vals)
        else
            reduce = reduceDiscr(vals)
        end        
    end
    return reduce[1]
end

## different reduction formulas
##-----------------------------

function reduceLog(da::DataVector)
    return sum(da, 1)
end

function reduceDiscr(da::DataVector)
    return prod(da .+ 1, 1) .- 1
end

function reduceDiscrPercent(da::DataVector)
    return (prod(da./100 .+ 1, 1) .- 1).*100
end

##################
## partitioning ##
##################

function aggregate(da::DataVector, freq::Int;
          allowedNAs::Float64 = 0.1,
          log::Bool = true, pct::Bool = false)
    ## aggregate most recent observations, skipping start
    nObs = size(da, 1)
    nAggrRets = div(nObs, freq)
    firstObs = mod(nObs, freq)
    aggrRets = DataArray(eltype(da), nAggrRets)
    for ii=1:nAggrRets
        startSubInterval = (ii - 1)*freq + 1 + firstObs
        endSubInterval = ii*freq + firstObs

        aggrRets[ii] =
            reduceReturns(da[startSubInterval:endSubInterval], 
                          allowedNAs; 
                          log = log, pct = pct)
    end
    return aggrRets
end

function aggregate(tn::Timenum, freq::Int;
          allowedNAs::Float64 = 0.1,
          log::Bool = true, pct::Bool = false)
    ## apply aggregation to each column and attach reduced time index
    
    
end

function sampleAggregationSubsamples(nObs::Int, freq::Int, nSample::Int)
    ## number of aggregates that observations will be reduced to 
    nAggrRets = div(nObs, freq) - 1
    if nAggrRets < 1
        error("to less observations to aggregate at this frequency")
    end

    subsampleSize = nAggrRets*freq
    nPossibleStarts = freq + mod(nObs, freq) + 1

    if nPossibleStarts < nSample
        # take each possible start
        startIndices = [1:nPossibleStarts]
    else
        # draw random starting points without replacement
        startIndices = randperm(nPossibleStarts)[1:nSample]
    end
    endIndices = startIndices .+ subsampleSize - 1
    return (startIndices, endIndices)
end

