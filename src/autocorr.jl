function autocorr(x::Vector, lag::Integer = 30)
    ## plot autocorrelation using Winston
    acVals = ones(lag)
    for ii=1:lag
        acVals[ii] = cor(x[1:(end-ii)], x[(1+ii):end])
    end
    Winston.plot(acVals, "-b")
    Winston.oplot(acVals, ".b")    
    Winston.ylim(-0.1, 1)
    ## return acVals
end

function autocorr!(x::Vector, lag::Integer = 30)
    ## add autocorrelation plot to existing plot in blue
    acVals = ones(lag)
    for ii=1:lag
        acVals[ii] = cor(x[1:(end-ii)], x[(1+ii):end])
    end
    Winston.oplot(acVals, "-b")
    Winston.oplot(acVals, ".b")    
end

function autocorr_red!(x::Vector, lag::Integer = 30)
    ## add autocorrelation plot to existing plot in red
    acVals = ones(lag)
    for ii=1:lag
        acVals[ii] = cor(x[1:(end-ii)], x[(1+ii):end])
    end
    Winston.oplot(acVals, "-r")
    Winston.oplot(acVals, ".r")    
end
