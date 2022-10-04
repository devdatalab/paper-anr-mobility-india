% UPDATED bound_generic_fun().  Takes input csv OR cuts / values. Parameter order has changed.
%  - pass blank string to input_csv if providing cuts and values
% WARNING: get_mob_solver_params() sets some parameters specific to mobility -- otherwise this is identical to
%          mort-solver/bound_generic_fun2.m -- not ideal from organization standpoint
%          - and also 
% bound some function of the CEF, under some level of allowed curvature of the underyling function
function [bounds, min_seed, max_seed] = bound_generic_fun2(input_csv, cuts, vals, fun, f2_limit, spec, min_seed, max_seed);

    % set globals
    global f_min_mse

    % create negative function (so we can get a max value by minimizing negative function)
    function val = neg_fun(p)
        val = -fun(p);
    end

    % set defaults: monotonic, min_seed, max_seed == 0
    if nargin < 6
        spec = 'mon';
    end
    if nargin < 7
        min_seed = 0;
        max_seed = 0;
    end

    % require an input_csv or cuts/vals

    % get standard solver parameters
    [options, num_ps, A_moments, b_moments, A_ineq, b_ineq, x0_start, lb, ub] = get_mob_solver_params(f2_limit, spec, input_csv, cuts, vals);
    ub_scalar = max(ub);

    % create arrays to hold max and minimum values of p. start at extreme values, so we can tell if the solver failed
    clear p_min p_max
    p_min = zeros(1, num_ps);
    p_max = ub_scalar * ones(1, num_ps);
        
    % STEP 1: calculate any feasible CEF to set f_min_mse
    [seed, f_min_mse, exit_flag, output] = fmincon(@fun_mse, x0_start, A_ineq, b_ineq, [], [], lb, ub, [], options);
    
    % assert(exit_flag == 1 | exit_flag == 2);

    % if we didn't find a solution, return min and max bounds of ub
    if ~(exit_flag == 1 | exit_flag == 2)
        fprintf('Solution not found. Returning [0, 0].\n');
        bounds = [ub_scalar, ub_scalar];
        return
    end

    % if seed is initialized to zero, use starting seed above
    if max(max_seed) == 0
        min_seed = seed;
        max_seed = seed;
    end
        
    % STEP 2: MAXIMIZE/MINIMIZE EACH p-BOUND, S.T. TO MEETING THIS MSE
    
    % now find lowest possible value of the objective function
    [min_seed, f_min, exit_flag, output] = fmincon(fun,     min_seed, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);

    % now find highest possible value of the objective function
    [max_seed, f_max, exit_flag, output] = fmincon(@neg_fun, max_seed, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);

    bounds = [f_min, -f_max];
end
