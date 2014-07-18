###############
## bootstrap ##
###############

function resample(td::AbstractTimedata)
    # resample rows of Timedata object
    nRows = size(td, 1)
    inds = rand(1:nRows, nRows)
    
    return td[inds, :]
end

function resample(df::DataFrame)
    # resample rows of Timedata object
    nRows = size(df, 1)
    inds = rand(1:nRows, nRows)
    
    return df[inds, :]
end

function resample{T}(obj::Array{T, 1})
    # resample rows of Timedata object
    nRows = size(obj, 1)
    inds = rand(1:nRows, nRows)
    
    return obj[inds]
end

function resample{T}(obj::Array{T, 2})
    # resample rows of Timedata object
    nRows = size(obj, 1)
    inds = rand(1:nRows, nRows)
    
    return obj[inds, :]
end

macro bootstrap(nTimes, expr)
    # resample different types: Timematr, Arrays, DataFrames
    quote
        # evaluate real expression and stop time
        tt1 = time()
        $(esc(expr))
        tt2 = time() # in seconds

        # get type of real result
        typ = typeof($(esc(expr.args[1])))

        # estimate required resampling time
        t1 = time()
        expTime = round((tt2 - tt1) * $nTimes, 2)
        println("")
        println("Expected resampling time: $expTime seconds (rough guess)")
        
        # get quarters to print message
        intermediateSteps = [4 2 4/3]
        quarts = int(floor($nTimes ./ intermediateSteps))
        
        # get function to resample
        func = $(esc(expr.args[2].args[1]))

        # get data as first argument to function
        data = $(esc(expr.args[2].args[2]))

        bootstrVals = Array(typ, $nTimes)
        for ii=1:$nTimes
            # get sample
            samp = resample(data)
            
            # print message about remaining time
            if issubset(ii, quarts)
                nReps = $nTimes
                pct = floor(ii/nReps*100)
                ttSoFar = time() - t1
                
                remainPct = 100 - pct
                remainInUnitsOfDone = remainPct / pct
                remainTime = round(remainInUnitsOfDone*ttSoFar , 2)
                println("$pct percent done, $remainTime remaining")
            end
            
            # apply function to sample
            bootstrVals[ii] = func(samp)
        end
        
        # actually required time
        t2 = time();
        t = round(t2-t1, 2)
        println("Actual resampling time: $t seconds")
        println("")

        # try fast version of vcat(bootstrVals...) for optimized
        # output structure
        res = []
        try
            res = fastVcat(bootstrVals)
        catch
            res = bootstrVals
        end
    end
end

# fast version to convert Array{Array{Float64,2},1} to Array{Float64,
# 2} if individual entries have same length
#
# much faster than vcat(x...)
function fastVcat(x::Array{Array{Float64,2},1})
    # preallocation
    (nReps, nVals) = (size(x, 1), size(x[1], 2))
    res = Array(Float64, nReps, nVals)
    for ii=1:nReps
        res[ii, :] = x[ii]
    end
    return res
end

function fastVcat(x::Array{Array{Float64,1},1})
    # preallocation
    nReps = size(x, 1)
    nVals = 1
    res = Array(Float64, nReps, nVals)
    for ii=1:nReps
        res[ii, :] = x[ii]
    end
    return res
end

function fastVcat(x::Array{DataFrame, 1})
    # preallocation
    (nReps, nVals) = (size(x, 1), size(x[1], 2))
    res = Array(Float64, nReps, nVals)
    for ii=1:nReps
        res[ii, :] = array(x[ii])
    end
    return composeDataFrame(res, names(x[1]))
end

function fastVcat{T}(x::Array{Timematr{T}, 1})
    # preallocation
    (nReps, nVals) = (size(x, 1), size(x[1], 2))
    res = Array(Float64, nReps, nVals)
    indices = Array(T, nReps)
    for ii=1:nReps
        res[ii, :] = core(x[ii])
        indices[ii] = idx(x[ii])[1]
    end
    return Timematr(res, names(x[1]), indices)
end


######################################
## aggregating to lower frequencies ##
######################################

function aggrRets(tm::Timematr; freq = "monthly",
                  logRet = true,
                  percent = true)
    ## aggregate returns to lower frequency

    (nObs, nAss) = size(tm)
    valsArr = core(tm)

    ## define aggregation function
    aggrFun = x -> x
    if logRet == true
        if percent == true
            aggrFun = x -> sum(x, 1)
        end
    elseif logRet == false
        if percent == true
            aggrFun = x -> (prod(1 + x./100, 1) - 1)*100
        else
            aggrFun = x -> (prod(1 + x, 1) - 1)
        end
    end

    # assign equal aggregation ID for days within same period 
    aggrId = Array(Float64, nObs)
    nUnique = 1
    nAggrPeriods = 1 # current number of aggregation periods
    lastDayOfPeriod = []

    dayAsAggregationPeriod = []
    
    if freq == "monthly"
        ## get year and month for each day
        dayAsAggregationPeriod =
            [(year(dateEntry), month(dateEntry)) for dateEntry in
             idx(tm)] 
    elseif freq == "yearly"
        ## get year for each day
        dayAsAggregationPeriod =
            [year(dateEntry) for dateEntry in idx(tm)] 
    end
        
    for ii=1:nObs
        aggrId[ii] = nUnique
        if ii < nObs
            if dayAsAggregationPeriod[ii] != dayAsAggregationPeriod[ii+1] 
                # next day is of next aggregation period
                nUnique = nUnique + 1
                lastDayOfPeriod = [lastDayOfPeriod; ii]
            end
        end
    end
    lastDayOfPeriod = [0; lastDayOfPeriod; nObs]
    nPeriods = length(lastDayOfPeriod)-1

   # for each period, get aggregated values
    aggrVals = Array(Float64, nPeriods, nAss)
    origDates = idx(tm)
    newDates = origDates[lastDayOfPeriod[2:end]]

    for ii=1:nPeriods
        # get values
        currPeriod =
            valsArr[(lastDayOfPeriod[ii]+1):lastDayOfPeriod[ii+1], :]
        # apply aggregation function
        aggrVals[ii, :] = aggrFun(currPeriod)
    end

    # put everything together in timematr
    df = composeDataFrame(aggrVals, names(tm))
    tmNew = Timematr(df, newDates)
end
