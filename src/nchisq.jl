_jl_libRmath = dlopen("libRmath")

## r function signatures:
## dchisq(x, df, ncp = 0, log = FALSE)
## pchisq(q, df, ncp = 0, lower.tail = TRUE, log.p = FALSE)
## qchisq(p, df, ncp = 0, lower.tail = TRUE, log.p = FALSE)
## rchisq(n, df, ncp = 0)

## c function signatures:
## double dnchisq(double x, double df, double ncp, int give_log)
## double pnchisq(double x, double df, double ncp, int lower_tail, int log_p)
## double qnchisq(double p, double df, double ncp, int lower_tail, int log_p)
## double rnchisq(double df, double lambda)

function dnchisq(x::Float64, df::Int32, ncp::Float64,
                log::Bool = false)
    return ccall(dlsym(_jl_libRmath,:dnchisq), Float64,
                 (Float64,Float64,Float64,Int32),
                 x, df, ncp, log)
end

function dnchisq(x::Array{Float64, 1}, df::Int32, ncp::Float64,
                log::Bool = false)
    nVals = length(x)
    pdfVals = Array(Float64, nVals)
    for ii=1:nVals
        pdfVals[ii] = ccall(dlsym(_jl_libRmath,:dnchisq),
                            Float64,
                            (Float64,Float64,Float64,Int32),
                            x, df, ncp, log)
    end
    return pdfVals
end

function pnchisq(q::Float64, df::Int32, ncp::Float64,
                lowTail::Bool = true, log::Bool = false)
    return ccall(dlsym(_jl_libRmath,:pnchisq), Float64,
                 (Float64,Float64,Float64,Int32,Int32),
                 q, df, ncp, lowTail, log)
end

function pnchisq(q::Array{Float64, 1}, df::Int32, ncp::Float64,
                 lowTail::Bool = true, log::Bool = false)
    nVals = length(x)
    cdfVals = Array(Float64, nVals)
    for ii=1:nVals
        cdfVals[ii] = ccall(dlsym(_jl_libRmath,:pnchisq), Float64,
                            (Float64,Float64,Float64,Int32,Int32),
                            q, df, ncp, lowTail, log)
    end
    return cdfVals
end

function qnchisq(p::Float64, df::Int32, ncp::Float64,
                lowTail::Bool = true, log::Bool = false)
    return ccall(dlsym(_jl_libRmath,:qnchisq), Float64,
                 (Float64,Float64,Float64,Int32,Int32),
                 p, df, ncp, lowTail, log)
end

function qnchisq(p::Array{Float64, 1}, df::Int32, ncp::Float64,
                lowTail::Bool = true, log::Bool = false)
    nVals = length(x)
    quantiles = Array(Float64, nVals)
    for ii=1:nVals
        quantiles[ii] = ccall(dlsym(_jl_libRmath,:qnchisq),
                              Float64,
                              (Float64,Float64,Float64,Int32,Int32),
                              p, df, ncp, lowTail, log)
    end
    return quantiles
end

function rnchisq(df::Int32, ncp::Float64)
    return ccall(dlsym(_jl_libRmath,:rnchisq), Float64,
                 (Float64,Float64),
                 df, ncp)
end

function rnchisq(n::Int32, df::Int32, ncp::Float64)
    simVals = Array(Float64, n)
    for ii=1:n
        simVals[ii] = ccall(dlsym(_jl_libRmath,:rnchisq),
                            Float64,
                            (Float64,Float64),
                            df, ncp)
    end
    return simVals
end
