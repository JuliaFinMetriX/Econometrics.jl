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

function ranks(tm::Timematr)
    y = ranks(core(tm))
    return Timecop(y, dates(tm))
end
    
import Winston.plot
function plot(tc::Timecop)
    ## plot bi-variate copula data
    if size(tc, 2) != 2
        error("copula plot is defined for bivariate data only")
    end

    vals = core(tc)
    ## aspect ratio
    p = FramedPlot(
                   aspect_ratio=1,
                   xrange=(0,1),
                   yrange=(0,1))
    plot(vals[:, 1], vals[:, 2], ".b")
end
