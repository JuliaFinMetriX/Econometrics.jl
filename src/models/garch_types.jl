################
## GARCH(1,1) ##
################

## X_t = mu_t + z_t*e_t
## (z_t)^2 = kappa + alpha*(X_t-1 - mu_t-1)^2 + beta*(z_t-1)^2

type GARCH_1_1{T} <: AbstrUnivarModel
    μ::Float64
    κ::Float64
    α::Float64
    β::Float64
    distr::T

    function GARCH_1_1(μ::Float64, κ::Float64,
                       α::Float64, β::Float64,
                       d::T)
        if !isa(d, Union(Normal, Econometrics.TDist))
            error("The innovation distribution must be either Normal
                       or TDist.")
        end
        if κ <= 0
            error("κ parameter must be larger than 0")
        end
        if α < 0
            error("α parameter must be larger than 0")
        end
        if β < 0
            error("β parameter must be larger than 0")
        end
        if α + β >= 1
            error("α and β together must be smaller than 1 for stationarity")
        end
        return new(μ, κ, α, β, d)
    end
end

function GARCH_1_1{T}(μ::Float64, κ::Float64,
                      α::Float64, β::Float64,
                      d::T)
    return GARCH_1_1{T}(μ, κ, α, β, d)
end

function GARCH_1_1{T}(params::Array{Float64, 1}, d::T)
    return GARCH_1_1{T}(params..., d)
end


type GARCH_1_1_Fit{T, T2} <: AbstrUnivarModel
    model::GARCH_1_1{T}
    data::T2
    sigmas::T2
    nllh::Float64
    # data, sigmas either Array{Float64, 1} or Timematr / Timenum
end

function GARCH_1_1_Fit{T, T2}(mod::GARCH_1_1{T},
                              data::T2, sigmas::T2,
                              nllh::Float64)
    return GARCH_1_1_Fit{T, T2}(mod, data, sigmas, nllh)
end
