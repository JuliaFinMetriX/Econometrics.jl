module TestEconometrics

using Dates
using DataFrames
using DataArrays
using TimeData
using Base.Test

my_tests = ["returns.jl",
         "nchisq.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end

end
