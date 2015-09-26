module TestEconometrics

using Dates
using DataFrames
using DataArrays
using TimeData
using Base.Test
using EconDatasets
using TimeData
using Econometrics

#######################################
## create input and output test data ##
#######################################

## create test data
##-----------------

## Econometrics.createTestData()

## build R results
##----------------

## rscriptPath = joinpath(Pkg.dir("Econometrics"), "test/data/")

## comment the following line if you don't have docker
#run(`docker run -t --rm -v $rscriptPath:/home/docker/ juliafinmetrix/rfinm_deb bash R CMD BATCH --no-save --no-restore r_results.R`)

## build MATLAB results
##---------------------

# add MATLAB BATCH job

###############
## run tests ##
###############

my_tests = [
            ## distributions
            "t_loc_scale_test.jl",
            "nchisq_test.jl",

            ## models
            "model_test.jl",
            "normiid_test.jl",
            "tlsiid_test.jl",
            "garch_test.jl"
            ## "cir.jl",

            ## miscellaneous
            ## "bsOptions_test.jl",
            ## "returns.jl"
            ]

println("Running tests:")

for my_test in my_tests
    println("\n * $(my_test)")
    println("---------------------------------------")
    println("---------------------------------------")
    include(my_test)
end

end
