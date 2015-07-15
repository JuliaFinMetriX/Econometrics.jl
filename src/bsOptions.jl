function bsDs(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1 = log(S/(K*exp(-r*T)))/(sigma*sqrt(T)) + 0.5*sigma*sqrt(T)
    d2 = d1 - sigma*sqrt(T)
    
    return (d1, d2)
end

function bsCall(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    
    return S*cdf(Normal(), d1) - K*exp(-r*T)*cdf(Normal(), d2)
end

function bsPut(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    
    return K*exp(-r*T)*cdf(Normal(), -d2) - S*cdf(Normal(), -d1)
end

function bsDeltaCall(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return cdf(Normal(), d1)
end

function bsDeltaPut(sigma::Float64, S::Float64, K::Int, r::Float64, T::Float64)
    d1, d2 = bsDs(sigma, S, K, r, T)
    return -cdf(Normal(), -d1)
end


function implVolaCall(sigma0::Float64, P::Float64, S::Float64, K::Int, r::Float64, T::Float64, prec::Float64)
    # define maximum interation size
    maxIter = 1000
    
    # calculate deviation
    d1, d2 = bsDs(sigma0, S, K, r, T)
    currDelta = cdf(Normal(), d1)
    currPrice = S*currDelta - K*exp(-r*T)*cdf(Normal(), d2)
    dev = P - currPrice
    
    iterCounter = 0
    while (dev > prec) && (iterCounter < maxIter)
        # Newton Raphson
        sigma0 = sigma0 - currPrice/currDelta
        
        # new d1, d2, delta, price and deviation
        d1, d2 = bsDs(sigma0, S, K, r, T)
        currDelta = cdf(Normal(), d1)
        currPrice = S*currDelta - K*exp(-r*T)*cdf(Normal(), d2)
        dev = P - currPrice
        iterCounter += 1
    end
    return (sigma0, dev, iterCounter)
end
