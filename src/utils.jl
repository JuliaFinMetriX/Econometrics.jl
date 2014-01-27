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
