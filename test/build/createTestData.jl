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
