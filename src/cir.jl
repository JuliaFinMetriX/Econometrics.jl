function cirOls(x::DataArray, delta::Float64)
    y = (x[2:end] .- x[1:(end-1)])./sqrt(x[1:(end-1)])
    x1 = 1 ./ sqrt(x[1:(end-1)])
    x2 = sqrt(x[1:(end-1)])
    
    # conduct regression
    df = DataFrame(y = y, x1 = x1, x2 = x2)
    olsFit = lm(y ~ 0 + x1 + x2, df)
    
    a1, a2 = coef(olsFit)
    
    # get associated parameters
    alpha = -a2 / delta
    mu = a1 / (delta * alpha)
    sigma = sqrt(var(residuals(olsFit)) /delta)
    return (alpha, mu, sigma)
end

function cirNllh(da::DataArray, params; dt = 1)
    # calculate negative log-likelihood for given parameter values
    alpha, mu, sigma = params
    
    # get constant values
    c = 2*alpha/(sigma^2*(1-exp(-alpha*dt)))
    q = 2*alpha*mu/sigma^2 - 1
    
    # get changing values u and v
    uWithNA = c*da[1:(end-1)]*exp(-alpha*dt)
    vWithNA = c*da[2:end]
    
    # eliminate observations with missing value for either u or v
    notElim = (!isna(uWithNA)) & (!isna(vWithNA))
    u = uWithNA[notElim]
    v = vWithNA[notElim]
    
    nObs = size(u, 1)
    
    return (nObs-1)*log(c) + sum(-u -v + 0.5*q*log(v./u) + log(besselix(q, 2*sqrt(u.*v))))
end




    
