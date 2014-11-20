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
    return cirNllh(da, [getParams(cirMod)...], Δt = Δt)
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
    return cirNllhx(da, [getParams(cirMod)...], Δt = Δt)
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

####################
## simulating CIR ##
####################

function condcdf(cirMod::CIR, x::Float64, r::Float64,  Δt::Float64=1)
    # conditional cdf given r


end
function getC(cir::CIR)


end

##############################
## conditional distribution ##
##############################
