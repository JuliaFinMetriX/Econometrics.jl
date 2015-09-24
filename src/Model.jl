abstract AbstrModel
abstract AbstrUnivarModel
abstract AbstrMultivarModel

type ModelFit
    model::AbstrModel
    data
    nllh::Float64
    addInfo
end

## all models should have the following methods in common:
## - simulate
## - resimulate (simulate with given dates)
## - fit / estimate

#############
## NormIID ##
#############

type NormIID <: AbstrUnivarModel
    mu::Float64
    sigma::Float64

    function NormIID(mu::Float64, sigma::Float64)
        if sigma <= 0
            error("sigma parameter must be larger than 0")
        end
        return new(mu, sigma)
    end
end

function description(mod::NormIID)
    return "IID, normally distributed"
end

function fit(dt::Type{NormIID}, data::Array{Float64, 1})
    normFit = fit_mle(Normal, data)
    muHat, sigmaHat = params(normFit)
    return NormIID(muHat, sigmaHat)
end


############
## TlsIID ##
############

type TlsIID <: AbstrUnivarModel
    nu::Float64
    mu::Float64
    scale::Float64
    function TlsIID(nu::Float64, mu::Float64, scale::Float64)
        if scale <= 0
            error("scaling parameter must be larger than 0")
        end
        if nu <= 0
            error("nu parameter must be larger than 0")
        end
        if nu <= 2
            warning("nu parameter is smaller than 2")
        end
        return new(nu, mu, scale)
    end
end

function description(mod::TlsIID)
    return "IID, Student's t location scale distributed"
end

function fit(dt::Type{TlsIID}, data::Array{Float64, 1})
    nuHat, muHat, scaleHat = fit(TLSDist, data)
    return TlsIID(nuHat, muHat, scaleHat)
end


## type GARCH <: AbstrUnivarModel
## - how to deal with different lag lengths?!
## end


function resimulateLogPrices(logPricesTn::Timenum,
                             mod::AbstrUnivarModel,
                             nPaths::Int = 1)
    ## simulate historic log price path again

    nObs, nAss = size(logPricesTn)
    
    # logPricesTn should be only one asset for univariate models
    if nAss != 1
        error("Original data must be exactly one asset for univariate models.")
    end
    
    # get logRets
    logRets = price2ret(logPricesTn, log=true)
    
    ## get returns without NAs
    pureRets = dropna(logRets.vals[1])
    nRets = size(pureRets, 1)
    
    ## fit model to pure returns
    modFit = fit(mod, pureRets)
    
    simRetsDf = DataFrame()
    noNAInds = !isna(logRets.vals[1])
    for ii=1:nPaths
        # simulate values
        simVals = simNormRets(nRets, muHat, sigmaHat)
        
        ## fill values into DataArray
        simRetsDa = DataArray(Float64, nObs-1)
        simRetsDa[noNAInds] = simVals
        
        ## copy values to DataFrame
        simRetsDf[ii] = simRetsDa
    end
    
    ## fix names
    if nPaths == 1
        colName = symbol(string(names(logPricesTn.vals)[1], "_sim_norm"))
        rename!(simRetsDf, :x1, colName)
    else
        nams = [symbol(string(names(logPricesTn.vals)[1], "_sim_norm$ii")) for ii=1:nPaths]
        names!(simRetsDf, nams)
    end
    
    simRets = Timenum(simRetsDf, idx(logRets))
    simPrices = ret2price(simRets)
    idx(simPrices)[1] = idx(logPricesTn)[1]
    
    return (simRets, simPrices)


end

