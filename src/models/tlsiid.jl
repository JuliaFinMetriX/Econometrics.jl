############
## TlsIID ##
############

type TlsIID <: AbstrUnivarModel
    ν::Float64
    μ::Float64
    a::Float64
    function TlsIID(ν::Float64, μ::Float64, a::Float64)
        if a <= 0
            error("scaling parameter a must be larger than 0")
        end
        if ν <= 0
            error("ν parameter must be larger than 0")
        end
        if ν <= 2
            warn("ν parameter is smaller than 2")
        end
        return new(ν, μ, a)
    end
end

function TlsIID(params::Array{Float64, 1})
    return TlsIID(params...)
end

import Base.Multimedia.display
function display(mod::TlsIID)
    nDigits = 3
    println("\nIID, constant univariate t-location scale distribution:")
    println("    ν: $(round(mod.ν, nDigits))")
    println("    μ: $(round(mod.μ, nDigits))")
    println("    a: $(round(mod.a, nDigits))")
end

function description(mod::TlsIID)
    return "IID, Student's t location scale distributed"
end

## getParams
##----------

function getParams(mod::TlsIID)
    return (mod.ν, mod.μ, mod.a)
end

## simulate
##---------

function simulate(mod::TlsIID, nObs::Int)
    ## simulate from TlsIID model
    t = TDist(mod.ν)
    return rand(t, nObs)*mod.a + mod.μ
end

## estimate
##---------

function estimate(dt::Type{TlsIID}, data::Array{Float64, 1})
    tlsFit = fit(TLSDist, data)
    return TlsIID(getParams(tlsFit)...)
end

## resimulate
##-----------

@doc doc"""
Fit model and resimulate data from it.
"""->
function resimulate(data::AbstractTimenum,
                    dt::Type{Econometrics.TlsIID},
                    nPaths::Int = 1)
    ## get returns without NAs
    pureRets = dropna(data.vals[1])
    nRets = size(pureRets, 1)
    
    ## fit model to pure returns
    modFit = estimate(dt, pureRets)

    return resimulate(data, modFit, nPaths)
end

