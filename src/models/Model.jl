abstract AbstrModel
abstract AbstrUnivarModel <: AbstrModel
abstract AbstrMultivarModel <: AbstrModel

################
## resimulate ##
################

@doc doc"""
Resimulate data from given model.
"""->
function resimulate(data::AbstractTimenum,
                    mod::AbstrUnivarModel,
                    nPaths::Int = 1)
    ## resimulate data from given model

    ## data must be univariate for univariate models
    nObs, nAss = size(data)
    if nAss != 1
        error("Original data must be univariate for univariate models.")
    end

    ## get returns without NAs
    pureRets = dropna(data.vals[1])
    nRets = size(pureRets, 1)
    
    simRetsDf = DataFrame()
    noNAInds = !isna(data.vals[1])
    for ii=1:nPaths
        # simulate values
        simVals = simulate(mod, nRets)
        
        ## fill values into DataArray
        simRetsDa = DataArray(Float64, nObs)
        simRetsDa[noNAInds] = simVals
        
        ## copy values to DataFrame
        simRetsDf[ii] = simRetsDa
    end
    
    ## fix names
    modName = string(typeof(mod))
    if nPaths == 1
        colName = symbol(string(names(data.vals)[1],
                                "_sim_",
                                modName))
        rename!(simRetsDf, :x1, colName)
    else
        nams = [symbol(string(names(data.vals)[1],
                              "_sim_",
                              modName,
                              "_",
                              "$ii")) for ii=1:nPaths]
        names!(simRetsDf, nams)
    end
    simRets = Timenum(simRetsDf, idx(data))
    return simRets
end



## function resimulateLogPrices(logPricesTn::Timenum,
##                              mod::AbstrUnivarModel,
##                              nPaths::Int = 1)
##     ## simulate historic log price path again

##     nObs, nAss = size(logPricesTn)
    
##     # logPricesTn should be only one asset for univariate models
##     if nAss != 1
##         error("Original data must be exactly one asset for univariate models.")
##     end
    
##     # get logRets
##     logRets = price2ret(logPricesTn, log=true)
    
##     ## get returns without NAs
##     pureRets = dropna(logRets.vals[1])
##     nRets = size(pureRets, 1)
    
##     ## fit model to pure returns
##     modFit = estimate(mod, pureRets)
    
##     simRetsDf = DataFrame()
##     noNAInds = !isna(logRets.vals[1])
##     for ii=1:nPaths
##         # simulate values
##         simVals = simulate(modFit, nRets)
        
##         ## fill values into DataArray
##         simRetsDa = DataArray(Float64, nObs-1)
##         simRetsDa[noNAInds] = simVals
        
##         ## copy values to DataFrame
##         simRetsDf[ii] = simRetsDa
##     end
    
##     ## fix names
##     modName = string(typeof(modFit))
##     if nPaths == 1
##         colName = symbol(string(names(logPricesTn.vals)[1],
##                                 "_sim_",
##                                 modName))
##         rename!(simRetsDf, :x1, colName)
##     else
##         nams = [symbol(string(names(logPricesTn.vals)[1],
##                               "_sim_",
##                               modName,
##                               "_",
##                               "$ii")) for ii=1:nPaths]
##         names!(simRetsDf, nams)
##     end
    
##     simRets = Timenum(simRetsDf, idx(logRets))
##     simPrices = ret2price(simRets)
##     idx(simPrices)[1] = idx(logPricesTn)[1]
    
##     return (simRets, simPrices)
## end

