## functions to indentify lowest and highest values by boolean
##
## useful together with TimeData.getVars

function islowest(x::Array{Float64, 1}, n::Integer = 1)
    nVals = length(x)
    inds = sortperm(x)
    logics = falses(nVals)
    logics[inds[1:n]] = true
    return logics
end

function ishighest(x::Array{Float64, 1}, n::Integer = 1)
    nVals = length(x)
    inds = sortperm(x, rev=true)
    logics = falses(nVals)
    logics[inds[1:n]] = true
    return logics
end

function createTestData()
    # create test data

    # get test data from EconDatasets
    intRates = []
    try
        intRates = dataset("Treasuries")
    catch
        getDataset("Treasuries")
        intRates = dataset("Treasuries")
    end

    # create subset
    dats = Date(1991, 1, 2):Date(2013, 12, 31)
    intData = intRates[dats, 4]
    names!(intData.vals, [:Y1])

    # save subset as test data to make it available to R
    fname = joinpath(Pkg.dir("Econometrics"), "test/data/intRates.csv")
    writeTimedata(fname, intData)
end
