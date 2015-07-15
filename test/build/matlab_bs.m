%% specify option parameters

callPrices = [26.7; 824.9; 1166.7];

daxVals = [6175.05; 6816.12; 8455.83];
       
strikes = [6700; 6000; 7300];

r = [0.006; 0.008; 0.001];

T = [0.188; 0.074; 0.172];

sigmas = [0.4; 0.2; 0.2];
   
%% calculate associated Black-Scholes call prices
testResults = zeros(2, 3);

for ii=1:3
   [c, p] = blsprice(daxVals(ii), strikes(ii), r(ii), T(ii), sigmas(ii));
   testResults(1, ii) = c;
   testResults(2, ii) = p;
end

%% implied volatilities

for ii=1:3
    testResults(3, ii) = blsimpv(daxVals(ii), strikes(ii), r(ii), T(ii), callPrices(ii));
end

