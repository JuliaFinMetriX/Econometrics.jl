_jl_libRmath = dlopen("libRmath-julia")

## c function signatures:
## double dnchisq(double x, double df, double ncp, int give_log)
## double pnchisq(double x, double df, double ncp, int lower_tail, int log_p)
## double qnchisq(double p, double df, double ncp, int lower_tail, int log_p)
## double rnchisq(double df, double lambda)

immutable NChiSq <: ContinuousUnivariateDistribution
    ν::Float64
    λ::Float64
    function NChiSq(ν::Float64, λ::Float64)
        if ν <= 0
            error("ν of NChiSq must be larger than zero.")
        end
        if λ <= 0
            error("λ of NChiSq must be larger than zero.")
        end

        return new(ν, λ)
    end
end

function NChiSq(params::Array{Float64, 1})
    return NChiSq(params...)
end

import Base.Multimedia.display
function display(ncs::NChiSq)
    nDigits = 3
    println("\nUnivariate noncentral chi-squared distribution:")
    println("    ν: $(round(ncs.ν, nDigits))")
    println("    λ: $(round(ncs.λ, nDigits))")
end

## access parameters
##------------------

import Distributions.dof
function dof(ncs::NChiSq)
    return ncs.ν
end

## getParams
##----------

function getParams(ncs::NChiSq)
    return (ncs.ν, ncs.λ)
end

## rand
##-----

import Distributions.rand
function rand(ncs::NChiSq)
    return ccall(dlsym(_jl_libRmath,:rnchisq), Float64,
                 (Float64,Float64),
                 ncs.ν, ncs.λ)
end

function rand(ncs::NChiSq, nObs::Int)
    simVals = Array(Float64, nObs)
    for ii=1:nObs
        simVals[ii] = rand(ncs)
    end
    return simVals
end

## pdf
##----

import Distributions.pdf
function pdf(d::NChiSq, x::Float64)
    return ccall(dlsym(_jl_libRmath,:dnchisq), Float64,
                 (Float64,Float64,Float64,Int32),
                 x, d.ν, d.λ, false)
end

function pdf(d::NChiSq, x::Array{Float64, 1})
    nVals = length(x)
    pdfVals = Array(Float64, nVals)
    for ii=1:nVals
        pdfVals[ii] = pdf(d, x[ii])
    end
    return pdfVals
end

## cdf
##----

import Distributions.cdf
function cdf(d::NChiSq, x::Float64)
    return ccall(dlsym(_jl_libRmath,:pnchisq), Float64,
                 (Float64,Float64,Float64,Int32,Int32),
                 x, d.ν, d.λ, true, false)
end

function cdf(d::NChiSq, x::Array{Float64, 1})
    nVals = length(x)
    cdfVals = Array(Float64, nVals)
    for ii=1:nVals
        cdfVals[ii] = cdf(d, x[ii])
    end
    return cdfVals
end

## quantile
##---------

import Distributions.quantile
function quantile(d::NChiSq, x::Float64)
    return ccall(dlsym(_jl_libRmath,:qnchisq), Float64,
                 (Float64,Float64,Float64,Int32,Int32),
                 x, d.ν, d.λ, true, false)
end

function quantile(d::NChiSq, x::Array{Float64, 1})
    nVals = length(x)
    pVals = Array(Float64, nVals)
    for ii=1:nVals
        pVals[ii] = quantile(d, x[ii])
    end
    return pVals
end

## nllh
##-----

function nllh(d::NChiSq, data::Array{Float64, 1})
    return -sum(log(pdf(d, data)))
end

function nllh_nchis(params::Array{Float64, 1}, data::Array{Float64, 1})
    d = NChiSq(params...)
    return -sum(log(pdf(d, data)))
end

## fit
##----

import Distributions.fit
function fit(dt::Type{NChiSq}, data::Array{Float64, 1})

    opt = Opt(:LN_BOBYQA, 2)
    function objFun(parameters::Vector, grad::Vector)
        ## objective function calculating portfolio variance
        if length(grad) > 0
            ## no partial derivative given
        end
        
        ## calculate portfolio variance
        nllhVal = nllh_nchis(parameters, data)
        return nllhVal
    end

    min_objective!(opt, objFun)
    xtol_rel!(opt, 1e-4)

    lower_bounds!(opt, [0.1, 0.1])
    upper_bounds!(opt, [Inf, Inf])

    initNu = 3.0
    initMu = mean(data)
    initParams = [initNu, initMu]

    (minf, minx, ret) = optimize(opt, initParams)
    return NChiSq(minx)
end
