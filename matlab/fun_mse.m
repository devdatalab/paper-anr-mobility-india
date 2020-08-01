function mse = fun_mse(x);

global A_moments b_moments

% run weighted mean squared error test
% calculate squared errors
errors2 = (A_moments*x' - b_moments) .^ 2;

% generate the weight vector from A_moments
% (basic idea: if there are 36 ranks in the first bin, want to give it weight=36)
weights = sum((A_moments ~= 0)');

% mse = weight vector * squared error vector
mse = weights * errors2;
