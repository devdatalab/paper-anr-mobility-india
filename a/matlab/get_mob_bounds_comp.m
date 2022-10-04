% function to calculate bounds on intergenerational mobility, based on set of rank bin means and sons' outcomes.

% inputs: 
% - name of graph file -- stored in /scratch/pn and ~/public_html/png/
% 
% - name of output CSV file, which lists each p value, f2 limit, lower bound, upper bound
%
% - maximum magnitude of 2nd derivative
%   
% - name of CSV file that takes following format. Column 1: mean father fank in each bin; Column 2: expected
%   son outcome in each bin.
%      .18243258,.35063016
%      .42220008,.41685656
%      .56392562,.51044887
%      .71468472,.58845616
%      .83880115,.69198436
%      .92134458,.74009257
%      .97306955,.80539866
%
%
function [p_levels] = get_mob_bounds_comp(input_csv, graph_fn, output_csv, f2_limit);
% function [stuff] = get_mob_bounds();

% TEMP FOR FUNCTION TESTING
% input_csv = '~/iecmerge/paul/mobility/age_25.csv';
% output_csv = '/scratch/pn/mout.csv';
% graph_fn = 'foo';
% f2_limit = 0.004;
% END TEMP

% return value: matrix with p value, lower bound, upper bound
global A_moments b_moments f_min_mse

% possibly unnecessary definition of global MSE minimum
f_min_mse = 0;

% expand function evaluations for solver to give it a better chance to find the solution
options = optimoptions(@fmincon,'MaxFunEvals',10000000,'Display','none','TolCon',1e-5,'TolFun',1e-5,'TolX',1e-15);

% read bin means and values and convert to a set of bin cuts and values
% e.g. CSV file                     cuts,   vals
% .18243258,.35063016               1-36: 0.3506  
% .42220008,.41685656               37-47: 0.4169 
% .56392562,.51044887               48-62: 0.5104 
% .71468472,.58845616     --------> 63-79: 0.5884 
% .83880115,.69198436               80-88: 0.6920 
% .92134458,.74009257               89-94: 0.7401 
% .97306955,.80539866               95-100: 0.8054
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

% stack the inequality constraints that we want to use
A_ineq = [A_pos_slope; A_f2_sym];
b_ineq = [b_pos_slope; b_f2_sym];

% define starting points for optimizer -- perfect mobility and zero mobility
x0_perfect = 0.5 * ones(1, num_ps);
% x0_zero = (1:num_ps) / num_ps;

% set upper and lower bound vectors
lb = zeros(1, num_ps);
ub = ones(1, num_ps);

% create arrays to hold max and minimum values of p. start at extreme values, so we can tell if the solver failed
clear p_min p_max
p_min = zeros(1, num_ps);
p_max = ones(1, num_ps);
    
% STEP 1: CALCULATE MINIMUM MSE UNDER THIS f2 CONSTRAINT
[x_start, f_min_mse, exit_flag, output] = fmincon(@fun_mse, x0_perfect, [A_pos_slope; A_f2_sym], [b_pos_slope; b_f2_sym], [], [], lb, ub, [], options);
assert(exit_flag == 1 | exit_flag == 2);
    
% STEP 2: MAXIMIZE/MINIMIZE EACH p-BOUND, S.T. TO MEETING THIS MSE

% create inequality constraint vector: positive slope, f2 below threshold, MSE below threshold
A_ineq = [A_pos_slope; A_f2_sym];
b_ineq = [b_pos_slope; b_f2_sym];

% preload x_min and x_max
x_min = x_start;
x_max = x_start;

% loop over all p-levels
fprintf('Finding bounds on requested p-levels...\n');
for j = 1:1:100

    fprintf('%d\n', j)

    % previous version: started each round at x_start -- now we're trying to start each round at previous solution
    % [x_min, f_min, exit_flag, output] = fmincon(@(x) (x(j)), x_start, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);

    % calculate max feasible p-level
    [x_min, f_min, exit_flag, output] = fmincon(@(x) (x(j)), x_min, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    if (exit_flag == 1 | exit_flag == 2)
        p_min(1, j) = x_min(j);
    end
    
    % calculate minimum feasible p-level
    [x_max, f_min, exit_flag, output] = fmincon(@(x) (-x(j)), x_max, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    if (exit_flag == 1 | exit_flag == 2)
        p_max(1, j) = x_max(j);
    end
end

% plot result
% fprintf('Printing f2 graph %s: f2 limit=%8.5f \n', graph_fn, f2_limit)
% plot_mob_bg(graph_fn, cuts, vals);

% get subset of p's that were selected by p-skip
% p_min_plot = p_min(1:1:100);
% p_max_plot = p_max(1:1:100);

% plot them
% plot_file(graph_fn, p_min_plot);
% plot_file(graph_fn, p_max_plot);

% export 
fprintf('Writing output file %s...\n', output_csv)
f = fopen(output_csv, 'w');
% fprintf(f, 'f2_limit,p_level,p_min,p_max\n');
for p = 1:1:100
    fprintf(f, '%10.8f,%d,%5.9f,%5.9f\n', f2_limit, p, p_min(p), p_max(p));
end

% return the p matrix
p_levels = [p_min' p_max'];
