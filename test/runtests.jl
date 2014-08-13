module runtests

using Dates
using DataFrames
using DataArrays
using TimeData

tests = ["returns.jl"]


for t in tests
    include(string(Pkg.dir("Econometrics"), "/test/", t))
end

end
