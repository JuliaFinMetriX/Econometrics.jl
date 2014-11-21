####################
## CIR model type ##
####################

type CIR
    alpha::Float64
    mu::Float64
    sigma::Float64
    scale::DatePeriod # which period is Δt = 1
end

## convenient constructors
##------------------------

function CIR(x::Array)
    return CIR(x[1], x[2], x[3], Dates.Year(1))
end

function CIR(x1, x2, x3)
    return CIR(x1, x2, x3, Dates.Year(1))
end

## customized display
##-------------------

import Base.display
function display(cirMod::CIR)
    println("α:        $(cirMod.alpha)")
    println("μ:        $(cirMod.mu)")
    println("σ:        $(cirMod.sigma)")
    println("scaling:  Δt = $(cirMod.scale)")
end

## information retrieval
##----------------------

function getParams(cirMod::CIR)
    return (cirMod.alpha, cirMod.mu, cirMod.sigma)
end

#################
## likelihoods ##
#################

function cirNllh(da::DataArray, params::Array{Float64, 1},
                 Δt::Float64 = 1)
    # Δt means time step of data relativ to time step represented by
    # parameters 
    
    # calculate negative log-likelihood for given parameter values
    α, μ, σ = params
    
    # get constant values
    c = 2*α/(σ^2*(1-exp(-α*Δt)))
    q = 2*α*μ/σ^2 - 1
    
    # get changing values u and v
    uWithNA = c*da[1:(end-1)]*exp(-α*Δt)
    vWithNA = c*da[2:end]
    
    # eliminate observations with missing value for either u or v
    notElim = (!isna(uWithNA)) & (!isna(vWithNA))
    u = uWithNA[notElim]
    v = vWithNA[notElim]
    
    nObs = size(u, 1)
    
    return -(nObs)*log(c) +
    sum(u + v - 0.5*q*log(v./u) - log(besseli(q, 2*sqrt(u.*v))))
end

function cirNllh(da::DataArray, cirMod::CIR, Δt::Float64 = 1)
    return cirNllh(da, [getParams(cirMod)...], Δt)
end

function cirNllhx(da::DataArray, params::Array{Float64, 1},
                  Δt::Float64 = 1)
    # calculate negative log-likelihood for given parameter values
    # using scaled modified bessel function of first order
    α, μ, σ = params
    
    # get constant values
    c = 2*α/(σ^2*(1-exp(-α*Δt)))
    q = 2*α*μ/σ^2 - 1
    
    # get changing values u and v
    uWithNA = c*da[1:(end-1)]*exp(-α*Δt)
    vWithNA = c*da[2:end]
    
    # eliminate observations with missing value for either u or v
    notElim = (!isna(uWithNA)) & (!isna(vWithNA))
    u = uWithNA[notElim]
    v = vWithNA[notElim]
    
    nObs = size(u, 1)
    
    return -(nObs)*log(c) +
    sum(u + v - 0.5*q*log(v./u) -
        log(besselix(q, 2*sqrt(u.*v))) - 2*sqrt(u.*v))
end

function cirNllhx(da::DataArray, cirMod::CIR, Δt::Float64 = 1)
    return cirNllhx(da, [getParams(cirMod)...], Δt)
end

####################
## OLS estimation ##
####################

function cirOls(x::DataArray, Δt::Float64=1)
    y = (x[2:end] .- x[1:(end-1)])./sqrt(x[1:(end-1)])
    x1 = 1 ./ sqrt(x[1:(end-1)])
    x2 = sqrt(x[1:(end-1)])
    
    # conduct regression
    df = DataFrame(y = y, x1 = x1, x2 = x2)
    olsFit = lm(y ~ 0 + x1 + x2, df)
    
    a1, a2 = coef(olsFit)
    
    # get associated parameters
    α = -a2 / Δt
    μ = a1 / (Δt * α)
    σ = sqrt(var(residuals(olsFit)) /Δt)
    return (α, μ, σ)
end

##############################
## conditional distribution ##
##############################

function getCondDistr(cirMod::CIR, r0::Float64,  Δt::Float64=1.)
    # conditional cdf given r
    α, μ, σ = cirMod.alpha, cirMod.mu, cirMod.sigma

    df = 4*α*μ/σ^2
    c = 2*α/(σ^2*(1-exp(-α*Δt)))
    λ = 2*c*r0*exp(-α*Δt)
    return (df, λ, c)
end

function cdf(cirMod::CIR, x::Float64, r0::Float64, Δt::Float64=1.)
    df, λ, c = getCondDistr(cirMod, r0, Δt)

    return pnchisq(x*2*c, df, λ)
end

function cdf(cirMod::CIR, x::Array{Float64, 1}, Δt::Float64=1.)
    ## take first value as given input
    nObs = length(x)-1
    condDistrParams = [getCondDistr(cirMod, x[ii], Δt) for ii=1:nObs]

    u = zeros(nObs)
    for ii=1:nObs
        df, λ, c = condDistrParams[ii]
        u[ii] = pnchisq(x[ii+1]*2*c, df, λ)
    end

    return u
end

function quantile(cirMod::CIR, q::Float64, r0::Float64, Δt::Float64=1.)
    df, λ, c = getCondDistr(cirMod, r0, Δt)
    
    return qnchisq(q, df, λ)/(2*c)
end

####################
## simulating CIR ##
####################

function simulate(cirMod::CIR, r0::Float64, nObs::Int, Δt::Float64=1.)
    α, μ, σ = cirMod.alpha, cirMod.mu, cirMod.sigma

    df = 4*α*μ/σ^2 # constant 
    c = 2*α/(σ^2*(1-exp(-α*Δt))) # constant for given Δt

    vals = [r0; Array(Float64, nObs)]
    for ii=1:nObs
        # get conditional non-centrality
        λ = 2*c*vals[ii]*exp(-α*Δt)
        vals[ii+1] = rnchisq(df, λ)/(2*c)
    end
    return vals
end
