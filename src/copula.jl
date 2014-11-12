###########
## ranks ##
###########

function ranks(x::Vector)
    ## transform observations to unit interval
    nObs = size(x, 1)

    y = ones(nObs)
    vals = ([1:nObs])/(nObs + 1)
    
    idx = sortperm(x)
    y[idx] = vals[:]
    return y
end

function ranks(x::Array)
    ## transform observations to unit interval
    nObs = size(x, 1)
    nVars = size(x, 2)

    y = ones(nObs, nVars)
    vals = ([1:nObs])/(nObs + 1)
    
    for ii=1:nVars
        idx = sortperm(x[:, ii])
        y[idx, ii] = vals[:]
    end
    return y
end

function ranks(da::DataVector)
    indNA = isna(da)
    vals = Econometrics.ranks(da[!indNA].data)
    daOut = DataArray(Float64, size(da, 1))
    daOut[!indNA] = vals
    return daOut
end

function ranks(tn::AbstractTimenum)
    df = DataFrame()
    for (nam, da) in eachcol(tn.vals)
        df[nam] = ranks(da)
    end
    return Timenum(df, idx(tn))
end

###############
## plotDistr ##
###############

function wstHist(x::Vector, nbins = 20; linewidth = 8)
    p = FramedPlot()
    setattr(p.y1, "draw_ticklabels", false)
    setattr(p.x1, "draw_ticklabels", false)
    ## setattr(p.x1, "ticks", 2)
    ## setattr(p.x1, "tickdir", -1)
    add(p, Histogram(hist(x, nbins)..., linewidth = linewidth))
    return p
end

function scatter2d(arr::Array{Float64, 2}; pointsize = 0.2)
    p = FramedPlot(aspect_ratio = 1)
    setattr(p.y1, "draw_ticklabels", false)
    setattr(p.x1, "draw_ticklabels", false)
    add(p, Points(arr[:, 1], arr[:, 2], kind="filled circle",
                  size=pointsize))
    return p
end

function plotVarName(smb::Symbol; textsize = 4)
    nam = string(smb)
    p = FramedPlot(aspect_ratio = 1,
                   xrange=(0,100),
                   yrange=(0,100))
    setattr(p.y1, "draw_ticklabels", false)
    setattr(p.x1, "draw_ticklabels", false)
    add(p, PlotLabel(.5, .5, nam, textangle = 45, size=textsize))
    return p
end

## function plotVarName(nam::String; textsize = 4)
##     p = FramedPlot(aspect_ratio = 1,
##                    xrange=(0,100),
##                    yrange=(0,100))
##     setattr(p.y1, "draw_ticklabels", false)
##     setattr(p.x1, "draw_ticklabels", false)
##     add(p, PlotLabel(.5, .5, nam, textangle = 45, size=textsize))
##     return p
## end
    
## function plotmatrix(arr::Array{Float64, 2},
##                     nams = [string(ii) for ii=1:size(arr,2)];
##                     textsize = 4, pointsize = 0.2, linewidth = 8)
##     nVars = size(arr, 2)
##     t = Table(nVars+1, nVars+1)
##     for ii=1:nVars
##         t[ii+1, ii+1] = wstHist(arr[!isnan(arr[:, ii]), ii],
##                                 linewidth = linewidth)
##     end
##     for ii=1:(nVars-1)
##         for jj=(ii+1):nVars
##             t[ii+1, jj+1] = scatter2d([arr[:, ii] arr[:, jj]],
##                                       pointsize = pointsize)
##             t[jj+1, ii+1] = scatter2d([arr[:, ii] arr[:, jj]],
##                                       pointsize = pointsize)
##         end
##     end
##     for ii=1:nVars
##         t[1, ii+1] = plotVarName(nams[ii], textsize = textsize)
##         t[ii+1, 1] = plotVarName(nams[ii], textsize = textsize)
##     end
##     setattr(t, "cellspacing", 0.1)
##     return t
## end

## lowlevel: data for both margins and dependency
##-----------------------------------------------

function plotDistr(arr::Array{Float64, 2}, U::Array{Float64, 2},
                   nams::Array{Symbol, 1};
                   pointsize = 0.2, textsize = 4, linewidth = 8)
    nVars = size(arr, 2)
    t = Table(nVars+1, nVars+1)
    for ii=1:nVars
        t[ii+1, ii+1] = wstHist(arr[!isnan(arr[:, ii]), ii],
                                linewidth = linewidth)
    end
    for ii=1:(nVars-1)
        for jj=(ii+1):nVars
            t[ii+1, jj+1] = scatter2d([U[:, ii] U[:, jj]],
                                      pointsize = pointsize)
            t[jj+1, ii+1] = scatter2d([U[:, ii] U[:, jj]],
                                      pointsize = pointsize)
        end
    end
    for ii=1:nVars
        t[1, ii+1] = plotVarName(nams[ii], textsize = textsize)
        t[ii+1, 1] = plotVarName(nams[ii], textsize = textsize)
    end
    setattr(t, "cellspacing", 0.1)
    return t
end

## functions with one data argument only
##--------------------------------------

## function plotDistr(arr::Array{Float64, 2},
##                    nams = [string(ii) for ii=1:size(arr,2)],
##                    args...)
##     ## calculate copula data within function
##     U = ranks(arr)
##     return plotDistr(arr, U, args...)
## end

## function plotDistr(tm::Timematr; args...)
##     ## calculate copula data within function
##     vals = asArr(tm, Float64)
##     U = ranks(vals)
##     return plotDistr(vals, U, names(tm), args...)
## end

function plotDistr(tn::Timenum; args...)
    ## calculate copula data within function
    Utmp = ranks(tn) # contains NAs
    U = asArr(Utmp, Float64, NaN)
    vals = asArr(tn, Float64, NaN)
    return plotDistr(vals, U, names(tn); args...)
end

## plotDistr(tn, textsize = 2, pointsize = 0.15, linewidth = 12)

## ## plotDistr(randn(1000, 20))
## plotmatrix(rand(100, 8), ["dklfskdfdkflshw", "sk", "sdk", "dskf",
##                           "sk", "sl", "lk", "kj"])
                          


## import Winston.plot
## function plot(tc::Timecop)
##     ## plot bi-variate copula data
##     if size(tc, 2) != 2
##         error("copula plot is defined for bivariate data only")
##     end

##     vals = core(tc)
##     ## aspect ratio
##     p = FramedPlot(
##                    aspect_ratio=1,
##                    xrange=(0,1),
##                    yrange=(0,1))
##     plot(vals[:, 1], vals[:, 2], ".b")
## end
