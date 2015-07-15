%% specify option parameters

callPrices = [26.7; 824.9; 1166.7];

daxVals = [6175.05; 6816.12; 8455.83];
       
strikes = [6700; 6000; 7300];

r = [0.006; 0.008; 0.001];

T = [0.188; 0.074; 0.172];

sigmas = [0.4; 0.2; 0.2];
   
%% calculate associated Black-Scholes call prices
testResults = zeros(2, 3);

testInd = 1;

for ii=1:3
   [c, p] = blsprice(daxVals(ii), strikes(ii), r(ii), T(ii), sigmas(ii));
   testResults(testInd, ii) = c;
   testResults((testInd+1), ii) = p;
end

%% Greeks: 

testInd = testInd + 2;

% Delta
for ii=1:3
    [cVal, pVal] =  blsdelta(daxVals(ii), strikes(ii), r(ii), T(ii), sigmas(ii));
    testResults(testInd, ii) = cVal;
    testResults(testInd+1, ii) = pVal;
end

testInd = testInd + 2;

% Gamma
for ii=1:3
    val =  blsgamma(daxVals(ii), strikes(ii), r(ii), T(ii), sigmas(ii));
    testResults(testInd, ii) = val;
end

testInd = testInd + 1;

% Vega
for ii=1:3
    val =  blsvega(daxVals(ii), strikes(ii), r(ii), T(ii), sigmas(ii));
    testResults(testInd, ii) = val;
end

testInd = testInd + 1;

% Theta
for ii=1:3
    [cVal, pVal] =  blstheta(daxVals(ii), strikes(ii), r(ii), T(ii), sigmas(ii));
    testResults(testInd, ii) = cVal;
    testResults(testInd+1, ii) = pVal;
end

testInd = testInd + 2;

% Rho
for ii=1:3
    [cVal, pVal] =  blsrho(daxVals(ii), strikes(ii), r(ii), T(ii), sigmas(ii));
    testResults(testInd, ii) = cVal;
    testResults(testInd+1, ii) = pVal;
end


%% implied volatilities

testInd = testInd + 2;

% call, real data
for ii=1:3
    testResults(testInd, ii) = blsimpv(daxVals(ii), strikes(ii), r(ii), T(ii), callPrices(ii));
end


%% save to disk

datName = '/home/chris/research/julia/Econometrics/test/data/matlab_bsvals.csv';
csvwrite(datName, testResults);