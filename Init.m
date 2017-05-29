addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

global alphaPower maxB rou superOverride;

maxB = 12; % the maximum length of a block race. Note that the program becomes slow if maxB>12.
superOverride = 3; % k in the paper. The attacker can override if he is k blocks ahead even with a lighter chain.
alphaPower = 0.45; % the mining power share controlled by the attacker.
SolveStrategy;
