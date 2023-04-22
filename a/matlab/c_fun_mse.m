function [c,ceq] = c_fun_mse(x);

global A_moments b_moments f_min_mse

% calculate moment MSE
mse = fun_mse(x);

% require MSE below threshold
c = mse - (f_min_mse);

% no non-linear equality constraints so set this to empty
ceq = [];

