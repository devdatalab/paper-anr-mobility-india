% create the common parameters used in all optimizations so can change everything in one place
function [options, cuts, vals, num_ps, A_moments, b_moments, A_ineq, b_ineq, x0_perfect, lb, ub] = get_solver_params(input_csv, f2_limit);

    % return value: matrix with p value, lower bound, upper bound
    global A_moments b_moments f_min_mse
    
    % possibly unnecessary definition of global MSE minimum
    f_min_mse = 0;
    
    % set parameters calibrated for most efficient solution
    options = optimoptions(@fmincon,'MaxFunEvals',1000000,'Display','none','TolCon',1e-3,'TolFun',1e-3,'TolX',1e-8);
    
    % read bin means and values and convert to a set of bin cuts and values
    [cuts, vals] = read_bins(input_csv);
    
    % define number of p-values (i.e. p1 -> p100)
    num_ps = 100;
    
    % generate matrix -- used internally by inequality constraint function
    [A_moments, b_moments] = get_moment_constraints(cuts, vals);
    
    num_bounds = size(cuts, 2);
    
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
    
    % define starting point for optimizer -- perfect mobility
    x0_perfect = 50 * ones(1, num_ps);
    
    % create inequality constraint vector: positive slope, f2 below threshold, MSE below threshold
    A_ineq = [A_pos_slope; A_f2_sym];
    b_ineq = [b_pos_slope; b_f2_sym];
    
    % set upper and lower bound vectors
    lb = zeros(1, num_ps);
    ub = 100 * ones(1, num_ps);    
