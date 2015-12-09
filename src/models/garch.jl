###################
## general GARCH ##
###################

## type GARCH{T} <: AbstrUnivarModel
##     mu::Float64
##     kappa::Float64
##     alphas::Array{Float64, 1}
##     betas::Array{Float64, 1}
##     distr::T
## end

## type GARCH <: AbstrUnivarModel
## - how to deal with different lag lengths?!
## end

#############
## display ##
#############

## normal innovations
##-------------------

import Base.Multimedia.display
function display(gMod::GARCH_1_1{Normal})
    nDigits = 3
    typNam = string(typeof(gMod))
    println("\n$typNam :: Univariate GARCH(1,1), εₜ~N(0,1)")
    println("    μ: $(round(gMod.μ, nDigits))")
    println("    ĸ: $(round(gMod.κ, nDigits))")
    println("    α: $(round(gMod.α, nDigits))")
    println("    β: $(round(gMod.β, nDigits))")
end

## t innovations
##--------------

function display(gMod::GARCH_1_1{TDist})
    nDigits = 3
    typNam = string(typeof(gMod))
    nuVal = round(dof(gMod.distr), nDigits)
    println("\n$typNam :: Univariate GARCH(1,1), εₜ~t($nuVal)")
    println("    μ: $(round(gMod.μ, nDigits))")
    println("    ĸ: $(round(gMod.κ, nDigits))")
    println("    α: $(round(gMod.α, nDigits))")
    println("    β: $(round(gMod.β, nDigits))")
end

## GARCH_1_1_Fit
##--------------

function display(gModFit::GARCH_1_1_Fit)
    nDigits = 3
    typNam = string(typeof(gModFit))
    println("\n$typNam with model:")
    display(gModFit.model)
    println("    data: $(typeof(gModFit.data))")
    println("  sigmas: $(typeof(gModFit.sigmas))")
    println("    nllh: $(gModFit.nllh)")
end

#################
## description ##
#################

## normal innovations
##-------------------

function description(gMod::GARCH_1_1{Normal})
    nDigits = 3
    println("\nUnivariate GARCH(1,1) model, εₜ~N(0,1): ")
    println("    Xₜ = $(round(gMod.μ, nDigits)) + σₜ*εₜ, εₜ~N(0,1)")
    println("    σₜ² = $(round(gMod.κ, nDigits)) + $(round(gMod.α, nDigits))*(Xₜ₋₁ - μ)² + $(round(gMod.β, nDigits))*σₜ₋₁²")
end

## t innovations
##--------------

function description(gMod::GARCH_1_1{TDist})
    nDigits = 3
    nuVal = round(dof(gMod.distr), nDigits)
    println("\nUnivariate GARCH(1,1), εₜ~t($nuVal): ")
    println("    Xₜ = $(round(gMod.μ, nDigits)) + σₜ*εₜ, εₜ~N(0,1)")
    println("    σₜ² = $(round(gMod.κ, nDigits)) + $(round(gMod.α, nDigits))*(Xₜ₋₁ - μ)² + $(round(gMod.β, nDigits))*σₜ₋₁²")
end

##############
## simulate ##
##############

function simulate(gMod::GARCH_1_1, nObs::Int,
                  initSigma::Float64 = NaN)

    simVals = Array(Float64, nObs)
    innovs = simulateInnovations(gMod.distr, nObs)

    if isnan(initSigma)
        ## take long term variance as starting value
        initSigma = sqrt(gMod.κ/(1-gMod.α-gMod.β))
    end

    currSigma = initSigma
    simVals[1] = innovs[1]*initSigma
    for ii=2:nObs
        currSigma = sqrt(gMod.κ + gMod.α*simVals[ii-1]^2 +
                          gMod.β*currSigma^2)
        simVals[ii] = currSigma*innovs[ii]
    end
    return simVals
end

function simulateInnovations(d::Normal, nObs::Int)
    return rand(d, nObs)
end

function simulateInnovations(d::TDist, nObs::Int)
    nu = dof(d)
    tVariance = nu/(nu-2)
    return rand(d, nObs)/sqrt(tVariance)
end

###############
## getSigmas ##
###############

@doc doc"""
Retrieve hidden sigma series from given dataset with given parameters
and given initial sigma.
"""->
function getSigmas(params::Array{Float64, 1}, data::Array{Float64, 1})
    μ, κ, α, β, σ0 = params

    nObs = length(data)
    
    ## normalize data
    centered = data - μ
    
    ## get sigma series
    sigmas = Array(Float64, nObs)
    sigmas[1] = σ0
    for ii=2:nObs
        sigmas[ii] = sqrt(κ + α*centered[ii-1]^2 +
                          β*sigmas[ii-1]^2)
    end
    return sigmas
end

@doc doc"""
Retrieve hidden sigma series from given dataset and given GARCH model.
Initial sigma either can be manually specified or it will be set
automatically. 
"""->
function getSigmas(mod::GARCH_1_1, data::Array{Float64, 1},
                   initSigma::Float64 = NaN)
    μ, κ, α, β = mod.μ, mod.κ, mod.α, mod.β
    ## automatically get initial sigma if not specified
    if isnan(initSigma)
        ## alternative automatic setting:
        ## initSigma = std(data)
        initSigma = sqrt(κ/(1 - α - β))
    end
    params = [μ, κ, α, β, initSigma]
    return getSigmas(params, data)
end

    
##########
## nllh ##
##########

@doc doc"""
Negative log-likelihood of GARCH(1,1) with normally distributed
innovations.
"""->
function garch_norm_nllh(params::Array{Float64, 1},
                         data::Array{Float64, 1})
    ## get sigmas
    sigmas = getSigmas(params, data)
    
    ## normalize data
    centered = data - params[1]
    
    return sum(0.5*log(sigmas.^2*2*pi) + 0.5*(centered.^2./sigmas.^2))
end

@doc doc"""
Negative log-likelihood of GARCH(1,1) with t distributed innovations.
"""->
function garch_t_nllh(params::Array{Float64, 1},
                      data::Array{Float64, 1})
    μ, κ, α, β, ν, σ0 = params
    if isnan(ν)
        ## warn("\nν is NaN")
        return NaN
    end
    nObs = length(data)
    
    ## get sigmas
    sigmas = getSigmas([μ, κ, α, β, σ0], data)
    
    ## normalize data
    centered = data - μ
    
    ## get standard deviation of unscaled t innovations
    stdT = sqrt(ν/(ν-2))

    ## get scaling factor
    a = 1/stdT

    llhs = Float64[log(pdf(TLSDist(ν, 0.0, a*sigmas[ii]), centered[ii])) for ii=1:nObs]

    ## println(ν)
    return -sum(llhs)
end

##############
## estimate ##
##############

@doc doc"""
Estimate GARCH coefficients with normally distributed innovations. By
default, the estimation includes μ and the initial volatility σ0 but
it will not be returned.
"""->
function estimate(dt::Type{GARCH_1_1{Normal}}, data::Array{Float64, 1})
    μ, κ, α, β, σ0 = garchFit_norm(data)[1]
    return GARCH_1_1(μ, κ, α, β, Normal())
end

@doc doc"""
Estimate GARCH coefficients with t distributed innovations. By
default, the estimation includes μ and the initial volatility σ0 but
it will not be returned.
"""->
function estimate(dt::Type{GARCH_1_1{TDist}}, data::Array{Float64, 1})
    μ, κ, α, β, ν, σ0 = garchFit_t(data)[1]
    return GARCH_1_1(μ, κ, α, β, TDist(ν))
end

@doc doc"""
Estimate GARCH coefficients with normally distributed innovations. By
default, the estimation includes μ and the initial volatility σ0. σ0
also will be returned.
"""->
function garchFit_norm(data::Array{Float64, 1})
    opt = Opt(:LN_COBYLA, 5)
    
    function objFun(x::Vector, grad::Vector)
        if length(grad) > 0
            ## no partial derivative given
        end
        return garch_norm_nllh(x, data)
    end
    
    min_objective!(opt, objFun)
    xtol_rel!(opt, 1e-4)
    
    ## inequality constraints
    ineqConstraint(params, g) = params[3] + params[4] - 0.9999
    inequality_constraint!(opt, ineqConstraint, 1e-4)

    ## μ, κ, α, β, σ0
    lower_bounds!(opt, [-Inf, 0.00001, 0, 0, 0])
    upper_bounds!(opt, [Inf, Inf, Inf, Inf, Inf])

    ## come up with initial values
    initSigma = std(data)
    initVal = [mean(data), initSigma^2, 0.2, 0.8, initSigma]
    (minf, minx, ret) = optimize(opt, initVal)
    
    return (minx, minf)
end

@doc doc"""
Estimate GARCH coefficients with t distributed innovations. By
default, the estimation includes μ and the initial volatility σ0. σ0
also will be returned.
"""->
function garchFit_t(data::Array{Float64, 1})
    opt = Opt(:LN_COBYLA, 6)
    
    function objFun(x::Vector, grad::Vector)
        if length(grad) > 0
            ## no partial derivative given
        end
        return garch_t_nllh(x, data)
    end
    
    min_objective!(opt, objFun)
    xtol_rel!(opt, 1e-4)
    
    ## inequality constraints
    ineqConstraint(params, g) = params[3] + params[4] - 0.9999
    inequality_constraint!(opt, ineqConstraint, 1e-4)

    ## μ, κ, α, β, ν, σ0
    lower_bounds!(opt, [-Inf, 0.00001, 0, 0, 2.8, 0])
    upper_bounds!(opt, [Inf, Inf, Inf, Inf, Inf, Inf])

    ## come up with initial values
    initSigma = std(data)
    initVal = [mean(data), initSigma^2, 0.2, 0.8, 8.0, initSigma]
    (minf, minx, ret) = optimize(opt, initVal)
    
    return (minx, minf)
end

#########
## fit ##
#########

function fit(dt::Type{GARCH_1_1{Normal}}, data::Array{Float64, 1})
    optOutput = garchFit_norm(data)
    μ, κ, α, β, σ0 = optOutput[1]
    nllh = optOutput[2]

    ## retrieve sigma series
    sigmas = getSigmas([μ, κ, α, β, σ0], data)

    ## construct garch model
    garchMod = GARCH_1_1(μ, κ, α, β, Normal())
    
    return GARCH_1_1_Fit(garchMod, data, sigmas, nllh)
end

function fit(dt::Type{GARCH_1_1{TDist}}, data::Array{Float64, 1})
    optOutput = garchFit_t(data)
    μ, κ, α, β, ν, σ0 = optOutput[1]
    nllh = optOutput[2]

    ## retrieve sigma series
    sigmas = getSigmas([μ, κ, α, β, σ0], data)

    ## construct garch model
    garchMod = GARCH_1_1(μ, κ, α, β, TDist(ν))
    
    return GARCH_1_1_Fit(garchMod, data, sigmas, nllh)
end

## fit with Timenum / Timematr
##----------------------------

function fit(dt::Type{GARCH_1_1{Normal}}, tn::AbstractTimematr)
    nObs, nAss = size(tn)

    if nAss != 1
        error("Original data must be univariate for univariate models.")
    end
    
    ## extract data
    data = asArr(tn[1], Float64)[:]

    gFit = fit(dt, data)

    ## determine name for sigma column
    colName = symbol(string(names(tn.vals)[1], "_sigmas"))
    
    sigmasTm = Timematr(gFit.sigmas, [colName], idx(tn))

    return GARCH_1_1_Fit(gFit.model, tn, sigmasTm, gFit.nllh)
end

function fit(dt::Type{GARCH_1_1{TDist}}, tn::AbstractTimematr)
    nObs, nAss = size(tn)

    if nAss != 1
        error("Original data must be univariate for univariate models.")
    end
    
    ## extract data
    data = asArr(tn[1], Float64)[:]

    gFit = fit(dt, data)

    ## determine name for sigma column
    colName = symbol(string(names(tn.vals)[1], "_sigmas"))
    
    sigmasTm = Timematr(gFit.sigmas, [colName], idx(tn))

    return GARCH_1_1_Fit(gFit.model, tn, sigmasTm, gFit.nllh)
end

function fit(dt::Type{GARCH_1_1{Normal}}, tn::AbstractTimenum)
    nObs, nAss = size(tn)

    if nAss != 1
        error("Original data must be univariate for univariate models.")
    end
    
    ## extract data
    data = asArr(tn[1], Float64, NaN)[:]

    gFit = fit(dt, data[!isnan(data), 1])

    ## fill sigmas
    noNAInds = !isna(tn.vals[1])
    sigmas = DataArray(Float64, nObs)
    sigmas[noNAInds] = gFit.sigmas

    sigmasDf = DataFrame()
    sigmasDf[1] = sigmas

    ## determine name for sigma column
    colName = symbol(string(names(tn.vals)[1], "_sigmas"))
    rename!(sigmasDf, :x1, colName)
    
    sigmasTn = Timenum(sigmasDf, idx(tn))

    return GARCH_1_1_Fit(gFit.model, tn, sigmasTn, gFit.nllh)
end

function fit(dt::Type{GARCH_1_1{TDist}}, tn::AbstractTimenum)
    nObs, nAss = size(tn)

    if nAss != 1
        error("Original data must be univariate for univariate models.")
    end
    
    ## extract data
    data = asArr(tn[1], Float64, NaN)[:]

    gFit = fit(dt, data[!isnan(data), 1])

    ## fill sigmas
    noNAInds = !isna(tn.vals[1])
    sigmas = DataArray(Float64, nObs)
    sigmas[noNAInds] = gFit.sigmas

    sigmasDf = DataFrame()
    sigmasDf[1] = sigmas

    ## determine name for sigma column
    colName = symbol(string(names(tn.vals)[1], "_sigmas"))
    rename!(sigmasDf, :x1, colName)
    
    sigmasTn = Timenum(sigmasDf, idx(tn))

    return GARCH_1_1_Fit(gFit.model, tn, sigmasTn, gFit.nllh)
end
