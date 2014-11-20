%% Requirements
% Kladikov CIR functions

addpath('/home/chris/research/julia/Econometrics/test/build/')
addpath('/home/chris/research/julia/Econometrics/test/build/mat_help_funcs/')
addpath('/home/chris/research/matlab/kladivko_cir_ptc07/')

%% import data
fname = '/home/chris/research/julia/Econometrics/test/data/intRates.csv';
[idx1,Yraw] = importTestdata(fname);

% eliminate missing values
Y = Yraw(~isnan(Yraw));

%% calculate likelihoods
cirMod.Data = Y;
cirMod.TimeStep = 1/250;

% test 1
params1 = [0.4; 3.2; 0.2];
llh1 = CIRobjective1(params1, cirMod);

% test 2
params2 = [0.8; 3.0; 0.8];
llh2 = CIRobjective1(params2, cirMod);

% test 3
params3 = [1.2, 2.0, 0.4];
llh3 = CIRobjective1(params3, cirMod);

llhs = [llh1 llh2 llh3];

datName = '/home/chris/research/julia/Econometrics/test/data/matlab_llhs.csv';
csvwrite(datName, llhs);

%% maximum-likelihood estimation

Model.Data = Y2;
Model.TimeStep = 1/250;      % recommended: 1/250 for daily data, 1/12 for monthly data, etc
Model.Disp = 'y';           % 'y' | 'n' (default: y)
Model.MatlabDisp = 'iter';  % 'off'|'iter'|'notify'|'final'  (default: off)
Model.Method = 'besseli';   % 'besseli' | 'ncx2pdf' (default: besseli)

Results = CIRestimation(Model);

