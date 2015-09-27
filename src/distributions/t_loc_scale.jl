immutable TLSDist <: ContinuousUnivariateDistribution
    ν::Float64
    μ::Float64
    a::Float64
    function TLSDist(ν::Float64, μ::Float64, a::Float64)
        if ν < 0
            error("ν of TLS must be larger than zero.")
        end
        if a < 0
            error("scaling a of TLS must be larger than zero.")
        end

        return new(ν, μ, a)
    end
end

function TLSDist(params::Array{Float64, 1})
    return TLSDist(params...)
end

import Base.Multimedia.display
function display(tls::TLSDist)
    nDigits = 3
    println("\nUnivariate t-location-scale distribution:")
    println("    ν: $(round(tls.ν, nDigits))")
    println("    μ: $(round(tls.μ, nDigits))")
    println("    a: $(round(tls.a, nDigits))")
end

## access parameters
##------------------

import Distributions.dof
function dof(tls::TLSDist)
    return tls.ν
end

## getParams
##----------

function getParams(tls::TLSDist)
    return (tls.ν, tls.μ, tls.a)
end

## rand
##-----

import Distributions.rand
function rand(tls::TLSDist, nRets::Int)
    t = TDist(dof(tls))
    return rand(t, nRets)*tls.a + tls.μ
end

## pdf
##----

import Distributions.pdf
function pdf(tls::TLSDist, x::Array{Float64, 1})
    ν, μ, a = getParams(tls)
    t = TDist(ν)
    return 1/a * pdf(t, (x .- μ)/a)
end

function pdf(tls::TLSDist, x::Float64)
    return pdf(tls, [x])[1]
end

## cdf
##----

import Distributions.cdf
function cdf(tls::TLSDist, x::Array{Float64, 1})
    t = TDist(dof(tls))
    return cdf(t, (x - tls.μ)/tls.a)
end

function cdf(tls::TLSDist, x::Float64)
    return cdf(tls, [x])[1]
end

## quantile
##---------

import Distributions.quantile
function quantile(tls::TLSDist, x::Array{Float64, 1})
    t = TDist(dof(tls))
    return quantile(t, x).*tls.a + tls.μ
end

function quantile(tls::TLSDist, x::Float64)
    return quantile(tls, [x])[1]
end

## nllh
##-----

function nllh(tls::TLSDist, data::Array{Float64, 1})
    return -sum(log(pdf(tls, data)))
end

function nllh_tls(params::Array{Float64, 1}, data::Array{Float64, 1})
    tls = TLSDist(params...)
    return -sum(log(pdf(tls, data)))
end


## fit
##----

import Distributions.fit
function fit(dt::Type{TLSDist}, data::Array{Float64, 1})

    opt = Opt(:LN_BOBYQA, 3)
    function objFun(parameters::Vector, grad::Vector)
        ## objective function calculating portfolio variance
        if length(grad) > 0
            ## no partial derivative given
        end
        
        ## calculate portfolio variance
        nllhVal = nllh_tls(parameters, data)
        return nllhVal
    end

    min_objective!(opt, objFun)
    xtol_rel!(opt, 1e-4)

    lower_bounds!(opt, [2.01, -Inf, 0.01])
    upper_bounds!(opt, [Inf, Inf, Inf])

    initNu = 3.0
    initMu = mean(data)
    initA = std(data)/sqrt(initNu/(initNu-2))
    initParams = [initNu, initMu, initA]

    (minf, minx, ret) = optimize(opt, initParams)
    return TLSDist(minx)
end

function fit_jump(dt::Type{TLSDist}, data::Array{Float64, 1})
    nSim = length(data)

    m = Model(solver=NLoptSolver(algorithm=:LN_BOBYQA))

    initNu = 8.0
    @defVar(m, nu >= 2, start=initNu)
    @defVar(m, mu, start=mean(data))
    @defVar(m, a >= 0, start=std(data)/sqrt(initNu/(initNu-2)))

    @setNLObjective(m,
                    :Min,
                    sum{-log(1/a*gamma((nu+1)/2)/(gamma(nu/2)*sqrt(nu*pi))*
                             (1+((data[ii]-mu)/a)^2/nu)^(-(nu+1)/2)),
                        ii=1:nSim})

    status = solve(m)
    nuHat, muHat, aHat = getValue(nu), getValue(mu), getValue(a)

    return TLSDist(nuHat, muHat, aHat)
end
