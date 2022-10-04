% UPDATED get_mort_solver_params().  Takes input csv OR cuts / values. Parameter order has changed.
%  - pass blank string to input_csv if providing cuts and values
% NOTE: ONLY DIFFERENCE BETWEEN MOB PARAMS AND MORT PARAMS IS UB and max f2 = 100k vs 100
%       - WOULD BE NICE TO CONSOLIDATE THESE FILES AND SET THIS PARAMETER ELSEWHERE
%       - OR TAKE A 'mob' / 'mort' FLAG

% create the common parameters used in all optimizations so can change everything in one place
function [options, num_ps, A_moments, b_moments, A_ineq, b_ineq, x0_start, lb, ub] = get_mort_solver_params2(f2_limit, spec, input_csv, cuts, vals);

    % return value: matrix with p value, lower bound, upper bound
    global A_moments b_moments f_min_mse
    
    % possibly unnecessary definition of global MSE minimum
    f_min_mse = 0;

    % set parameters calibrated for most efficient solution (original params from CR on following line)
    %options = optimoptions(@fmincon,'MaxFunEvals',10000000,'Display','none','TolCon',1e-6,'TolFun',1e-11,'TolX',1e-8);

    % parameter settings that work better with get_mort_bounds_seeds.m (decrease step size tolerance for smoother curves)
    options = optimoptions(@fmincon,'MaxFunEvals',10000000,'Display','none','TolCon',1e-6,'TolFun',1e-11,'TolX',1e-16);

    % read bin means and values and convert to a set of bin cuts and values
    if length(input_csv) == 0

        % if no CSV passed in, assume that cuts and vals have been passed in
        if nargin < 5
            error('ERROR: get_mort_solver_params(): If input_csv is empty, need to pass cuts, vals.\n')
        end
        
    % otherwise, read them from the input file
    else
        [cuts, vals] = read_bins(input_csv);
    end
    
    % define number of p-values (i.e. p1 -> p100)
    num_ps = 100;
    
    % generate matrix -- used internally by inequality constraint function
    [A_moments, b_moments] = get_moment_constraints(cuts, vals);
    
    % create the numerical 2nd derivative matrix, which looks like this with 10 p-levels
    % A_f2    = [ 1 -2  1  0  0  0  0  0  0  0;
    %             0  1 -2  1  0  0  0  0  0  0;
    %             0  0  1 -2  1  0  0  0  0  0;
    %             0  0  0  1 -2  1  0  0  0  0;
    %             0  0  0  0  1 -2  1  0  0  0;
    %             0  0  0  0  0  1 -2  1  0  0;
    %             0  0  0  0  0  0  1 -2  1  0;
    %             0  0  0  0  0  0  0  1 -2  1;];
    e = eye(num_ps);
    A_f2 = e(1:(num_ps-2), :) + [zeros((num_ps - 2), 2) eye(num_ps - 2)] + [zeros((num_ps - 2), 1) -2*eye(num_ps - 2)  zeros((num_ps - 2),1)];
    
    % put positive and negative A_f2 in same matrix so we can use them with a single inequality constraint  
    A_f2_sym = [A_f2; -A_f2];
    
    % set b_f2 limit -- multiply by 2 since needs to line up with both positive and negative A_f2 matrix
    b_f2_sym = f2_limit * ones(2 * (num_ps - 2), 1);
    
    % define monotonicity inequality constraint (9 inequality constraints if p1->p10)
    % A_pos_slope = [1 -1  0  0  0  0  0  0  0  0;
    %                0 1 -1  0  0  0  0  0  0  0;
    %                0  0 1 -1  0  0  0  0  0  0;
    %                0  0  0 1 -1  0  0  0  0  0;
    %                0  0  0  0 1 -1  0  0  0  0;
    %                0  0  0  0  0 1 -1  0  0  0;
    %                0  0  0  0  0  0 1 -1  0  0;
    %                0  0  0  0  0  0  0 1 -1  0;
    %                0  0  0  0  0  0  0  0 1 -1 ];
    % b_pos_slope = zeros(9, 1);
    A_pos_slope = e(1:(num_ps - 1), :) + [zeros((num_ps - 1), 1) -eye(num_ps - 1)];
    b_pos_slope = zeros(num_ps - 1, 1);

    %%%%%%%%%%%%%%%%%%%%%%%
    % DEFINE SHEEPSKIN b_f2
    b_f2_step = f2_limit * ones(num_ps - 2, 1);

    % loop over all cuts and allow unlimited 2nd derivatives
    % don't use last cut, b/c it's at 100.
    for i = 1:(length(cuts) - 1)

        % set cuts for first half of b
        b_f2_step(cuts(i)-1) = 100;
        b_f2_step(cuts(i)) = 100;
    end
    % repeat b_f2_step for negative A_f2
    b_f2_step = [b_f2_step; b_f2_step];
    
    % define starting point for optimizer -- equal mortality in all bins
    x0_start = mean(vals) * ones(1, num_ps);
    
    % create inequality constraint vector: positive slope, f2 below threshold, MSE below threshold
    if strcmp(spec, 'mon')
        A_ineq = [A_pos_slope; A_f2_sym];
        b_ineq = [b_pos_slope; b_f2_sym];
    elseif strcmp(spec, 'nomon')
        A_ineq = A_f2_sym;
        b_ineq = b_f2_sym;
    elseif strcmp(spec, 'mon-step')
        A_ineq = [A_pos_slope; A_f2_sym];
        b_ineq = [b_pos_slope; b_f2_step];
    elseif strcmp(spec, 'nomon-step')
        A_ineq = A_f2_sym;
        b_ineq = b_f2_step;
    else
        error('"spec" was set to an unexpected value.')
    end
    
    % set upper and lower bound vectors
    lb = zeros(1, num_ps) ;
    ub = 100 * ones(1,num_ps); 
