module TestNChisq

using Base.Test
using Econometrics

expOut = 0.1441868
actOut = Econometrics.dnchisq(1.2, 3.2, 1.4)
@test_approx_eq_eps expOut actOut 1e-6

expOut = 0.1244554
actOut = Econometrics.pnchisq(1.2, 3.2, 1.4)
@test_approx_eq_eps expOut actOut 1e-6

expOut = 3.039873
actOut = Econometrics.qnchisq(0.4, 3.2, 1.4)
@test_approx_eq_eps expOut actOut 1e-6

p = 0.2
q = Econometrics.qnchisq(p, 3.2, 1.4)
p2 = Econometrics.pnchisq(q, 3.2, 1.4)
@test_approx_eq p p2

simVals = Econometrics.rnchisq(1000, 3.2, 1.4)
uVals = Econometrics.pnchisq(simVals, 3.2, 1.4)
simVals2 = Econometrics.qnchisq(uVals, 3.2, 1.4)
@test all(abs(simVals - simVals2) .< 1e-10)

end
