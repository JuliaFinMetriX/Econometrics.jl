function garchLLH(params, data)
    ## negative log-likelihood of GARCH(1,1)
    µ, ĸ, beta, alpha, sigma0 = params
    
    nObs = length(data)
    
    ## normalize data
    centered = data - µ
    
    ## get sigma series
    sigmas = Array(Float64, nObs)
    sigmas[1] = sigma0
    for ii=2:nObs
        sigmas[ii] = sqrt(ĸ + beta*sigmas[ii-1]^2 + alpha*centered[ii-1]^2)
    end
    
    nllh = sum(0.5*log(sigmas.^2*2*pi) + 0.5*(centered.^2./sigmas.^2))
end


function garchFit(tm::Timematr)
    nObs, nAss = size(tm)
    if nAss > 1
        error("garch momentarily is only allowed for single asset")
    end
    
    opt = Opt(:LN_COBYLA, 5)
    
    function objFun(x::Vector, grad::Vector)
        ## objective function calculating portfolio variance
        if length(grad) > 0
            ## no partial derivative given
        end
        
        ## calculate portfolio variance
        nllh = Econometrics.garchLLH(x, core(tm))
        return nllh
    end
    
    min_objective!(opt, objFun)
    xtol_rel!(opt, 1e-6)
    
    ## inequality constraints
    ineqConstraint(params, g) = params[3] + params[4] - 1
    inequality_constraint!(opt, ineqConstraint, 1e-9)
    
    lower_bounds!(opt, [-Inf, -Inf, 0, 0, 0])
    upper_bounds!(opt, [Inf, Inf, Inf, Inf, Inf])
    
    sigma = sqrt(var(core(tm)))
    initVal = [0, sigma, 0, 0, sigma]
    (minf, minx, ret) = optimize(opt, initVal)
    
    ## get associated sigma series
    µ, ĸ, beta, alpha, sigma0 = minx
    
    ## normalize data
    centered = core(tm) - µ
    
    ## get sigma series
    sigmas = Array(Float64, nObs)
    sigmas[1] = sigma0
    for ii=2:nObs
        sigmas[ii] = sqrt(ĸ + beta*sigmas[ii-1]^2 + alpha*centered[ii]^2)
    end
    
    return (sigmas, minx)
end

