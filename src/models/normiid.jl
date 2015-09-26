#############
## NormIID ##
#############

type NormIID <: AbstrUnivarModel
    μ::Float64
    σ::Float64

    function NormIID(μ::Float64, σ::Float64)
        if σ <= 0
            error("σ parameter must be larger than 0")
        end
        return new(μ, σ)
    end
end

function NormIID(params::Array{Float64, 1})
    return NormIID(params...)
end

import Base.Multimedia.display
function display(mod::NormIID)
    nDigits = 3
    println("\nIID, constant univariate normal distribution:")
    println("    μ: $(round(mod.μ, nDigits))")
    println("    σ: $(round(mod.σ, nDigits))")
end

function description(mod::NormIID)
    return "IID, normally distributed"
end

## getParams
##----------

function getParams(mod::NormIID)
    return (mod.μ, mod.σ)
end

## simulate
##---------

function simulate(mod::NormIID, nObs::Int)
    ## simulate from NormIID model
    return randn(nObs)*mod.σ + mod.μ
end

## estimate
##---------

function estimate(dt::Type{NormIID}, data::Array{Float64, 1})
    normFit = fit_mle(Normal, data)
    muHat, sigmaHat = params(normFit)
    return NormIID(muHat, sigmaHat)
end

## resimulate
##-----------

@doc doc"""
Fit model and resimulate data from it.
"""->
function resimulate(data::AbstractTimenum,
                    dt::Type{Econometrics.NormIID},
                    nPaths::Int = 1)
    ## get returns without NAs
    pureRets = dropna(data.vals[1])
    nRets = size(pureRets, 1)
    
    ## fit model to pure returns
    modFit = estimate(dt, pureRets)

    return resimulate(data, modFit, nPaths)
end

