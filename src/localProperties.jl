@doc doc"""
The function returns a function that maps each index value to the
domain of the edge values. Note that index 0 will be mapped to the
first entry of the edge values in order to allow smoother graphics
with Gadfly.
"""->
function getInd2RangeFunc(edges::Array{Float64, 1})
    ## calculate slope
    m = (edges[end] - edges[1])./(length(edges) - 1)

    ## intercept
    c = edges[1]

    mapFunc = x -> c + m*x
    return mapFunc
end

@doc doc"""
Group observations by two-dimensional grid and apply function to
grouped observations. Internally, this makes use of function `by` from
the `DataFrames` package.
Observations in the first interval will get a location index of 0.
This will allow better plotting with Gadfly.
Edges must be monotonically increasing, and no point may lie outside
of edge range.
Observations with `NA` for either x or y value will be removed.
"""->
function localAppl(df::DataFrame, xCol::Symbol, yCol::Symbol,
                   xE::Array{Float64, 1}, yE::Array{Float64, 1},
                   aggrFunc::Function)

    ## remove NAs
    validObsInds = !isna(df[xCol]) & !isna(df[yCol])
    dfShort = df[validObsInds, :]
    
    if any(dfShort[xCol] .< xE[1])
        error("observations lower than smallest edge: adapt x range")
    end
    if any(dfShort[xCol] .> xE[end])
        error("observations larger than highest edge: adapt x range")
    end
    if any(dfShort[yCol] .< yE[1])
        error("observations lower than smallest edge: adapt y range")
    end
    if any(dfShort[yCol] .> yE[end])
        error("observations larger than highest edge: adapt y range")
    end
    
    nObs = size(dfShort, 1)

    ## preallocation
    xInds = zeros(Int64, nObs)
    yInds = zeros(Int64, nObs)
    
    # find respective grid interval
    for ii = 1:nObs
        ## values in first interval get mapped to index 0 
        x = searchsortedfirst(xE, dfShort[ii, xCol]) - 2
        y = searchsortedfirst(yE, dfShort[ii, yCol]) - 2

        xInds[ii] = x
        yInds[ii] = y
    end
    extDf = [dfShort DataFrame(xInds = xInds, yInds = yInds)]

    # group by grid interval, apply function
    res = by(extDf, [:xInds, :yInds], aggrFunc)
    
    names!(res, [xCol, yCol, :value])
    return res
end

function plotLocalProperties(df::DataFrame, xCol::Symbol,
                             yCol::Symbol,
                             xEdges::Array{Float64, 1},
                             yEdges::Array{Float64, 1},
                             aggrFunc::Function;
                             xlab = string(xCol),
                             ylab = string(yCol),
                             ttl = "")

    res = localAppl(df, xCol, yCol, xEdges, yEdges, aggrFunc)

    ## get maximum indices
    xMax = maximum(res[xCol])
    yMax = maximum(res[yCol])

    ## get functions to transform inds to values
    xInd2Range = getInd2RangeFunc(xEdges)
    yInd2Range = getInd2RangeFunc(yEdges)

    currPlot = Gadfly.plot(res, x=xCol, y=yCol, color=:value, Geom.rectbin,
                           Scale.x_continuous(labels=x ->
                           @sprintf("%2.2f", xInd2Range(x)),
                                              minvalue=0, maxvalue=xMax),
                           Scale.y_continuous(labels=x ->
                           @sprintf("%2.2f", yInd2Range(x)),
                                              minvalue=0, maxvalue=yMax),
                           Guide.xlabel(xlab),
                           Guide.ylabel(ylab),
                           Guide.title(ttl))
    return currPlot
end
