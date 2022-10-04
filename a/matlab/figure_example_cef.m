%% loop over all possible birth cohorts to use
%% for i = [1950 1960 1970 1980]
for i = [1960]  
    %%%%%%%%%%%%%%%%%% PANEL A: TWO VALID CEFS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Shows age 35 moments, plus two functions that fit it at reasonably high and low p25 values
    %% input_csv = '~/iecmerge/paul/mobility/data/age_35.csv';
    input_csv =  sprintf(strcat(base_path, '/moments/ed_ranks_0_%d.csv'), i);
    graph_fn_bg = sprintf(strcat(base_path, '/out/fig_%d_bg'), i);
    graph_fn_a  = sprintf(strcat(base_path, '/out/fig_example_cef_%d'), i);
    graph_fn_b  = sprintf(strcat(base_path, '/out/fig_example_cef_%d_gradient'), i);
    graph_fn_c  = sprintf(strcat(base_path, '/out/fig_example_cef_%d_pres'), i);
    graph_mu    = sprintf(strcat(base_path, '/out/fig_example_cef_%d_mu'), i);
    f2_limit = 0.12;
    
    %% return value: matrix with p value, lower bound, upper bound
    global A_moments b_moments f_min_mse
    
    %% possibly unnecessary definition of global MSE minimum
    f_min_mse = 0;
    
    %% expand function evaluations for solver to give it a better chance to find the solution
    options = optimoptions(@fmincon,'MaxFunEvals',1000000,'Display','none','TolCon',1e-3,'TolFun',1e-3,'TolX',1e-8);
    
    %% read bin means and values and convert to a set of bin cuts and values
    [cuts, vals] = read_bins(input_csv);
    
    %% define number of p-values (i.e. p1 -> p100)
    num_ps = 100;
    
    %% generate matrix -- used internally by inequality constraint function
    [A_moments, b_moments] = get_moment_constraints(cuts, vals);
    
    num_bounds = size(cuts, 2);
    
    %% create the numerical 2nd derivative matrix, which looks like this with 10 p-levels
    %% A_f2    = [ 1 -2  1  0  0  0  0  0  0  0;
    %%             0  1 -2  1  0  0  0  0  0  0;
    %%             0  0  1 -2  1  0  0  0  0  0;
    %%             0  0  0  1 -2  1  0  0  0  0;
    %%             0  0  0  0  1 -2  1  0  0  0;
    %%             0  0  0  0  0  1 -2  1  0  0;
    %%             0  0  0  0  0  0  1 -2  1  0;
    %%             0  0  0  0  0  0  0  1 -2  1;];
    e = eye(num_ps);
    A_f2 = e(1:(num_ps-2), :) + [zeros((num_ps - 2), 2) eye(num_ps - 2)] + [zeros((num_ps - 2), 1) -2*eye(num_ps - 2)  zeros((num_ps - 2),1)];
    
    %% put positive and negative A_f2 in same matrix so we can use them with a single inequality constraint
    A_f2_sym = [A_f2; -A_f2];
    
    %% set b_f2 limit -- multiply by 2 since needs to line up with both positive and negative A_f2 matrix
    b_f2_sym = f2_limit * ones(2 * (num_ps - 2), 1);
    
    %% define monotonicity inequality constraint (9 inequality constraints if p1->p10)
    %% A_pos_slope = [1 -1  0  0  0  0  0  0  0  0;
    %%                0 1 -1  0  0  0  0  0  0  0;
    %%                0  0 1 -1  0  0  0  0  0  0;
    %%                0  0  0 1 -1  0  0  0  0  0;
    %%                0  0  0  0 1 -1  0  0  0  0;
    %%                0  0  0  0  0 1 -1  0  0  0;
    %%                0  0  0  0  0  0 1 -1  0  0;
    %%                0  0  0  0  0  0  0 1 -1  0;
    %%                0  0  0  0  0  0  0  0 1 -1 ];
    %% b_pos_slope = zeros(9, 1);
    A_pos_slope = e(1:(num_ps - 1), :) + [zeros((num_ps - 1), 1) -eye(num_ps - 1)];
    b_pos_slope = zeros(num_ps - 1, 1);
    
    %% stack the inequality constraints that we want to use
    A_ineq = [A_pos_slope; A_f2_sym];
    b_ineq = [b_pos_slope; b_f2_sym];
    
    %% define starting points for optimizer -- perfect mobility and zero mobility
    x0_perfect = 50 * ones(1, num_ps);
    %% x0_zero = (1:num_ps) / num_ps;
    
    %% set upper and lower bound vectors
    lb = zeros(1, num_ps);
    ub = 100 * ones(1, num_ps);
    
    %% TEST
    [options, cuts, vals, num_ps, A_moments, b_moments, A_ineq, b_ineq, x0_perfect, lb, ub] = get_solver_params(input_csv, f2_limit);
    
    %% create arrays to hold max and minimum values of p. start at extreme values, so we can tell if the solver failed
    clear p_min p_max
    p_min = zeros(1, num_ps);
    p_max = 100 * ones(1, num_ps);
        
    %% STEP 1: CALCULATE MINIMUM MSE UNDER THIS f2 CONSTRAINT
    fprintf('Calculating minimum MSE...\n');
    [x_start, f_min_mse, exit_flag, output] = fmincon(@fun_mse, x0_perfect, [A_pos_slope; A_f2_sym], [b_pos_slope; b_f2_sym], [], [], lb, ub, [], options);
    assert(exit_flag == 1 | exit_flag == 2);
        
    %% STEP 2: Generate two different solutions that get this MSE
    
    %% create inequality constraint vector: positive slope, f2 below threshold, MSE below threshold
    A_ineq = [A_pos_slope; A_f2_sym];
    b_ineq = [b_pos_slope; b_f2_sym];
    
    %% calculate max feasible p-level
    %% j = 25;
    %% fprintf('Calculating bounds on p25...\n');
    %% [x_min, f_min, exit_flag, output] = fmincon(@(x) (abs(x(j)-.45)), x_start, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    
    %% calculate minimum feasible p-level
    %% [x_max, f_min, exit_flag, output] = fmincon(@(x) (abs(x(j)-.35)), x_start, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    
    %% calculate min and max reg coef, what do those look like?
    fun_p25 = @(x) mean(x(25:26));
    fun_p25_max = @(x) -mean(x(25:26));
    [x_min_reg, f_min_low, exit_flag, output] = fmincon(fun_p25, x_start, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    [x_max_reg, f_min_high, exit_flag, output] = fmincon(fun_p25_max, x_start, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    
    %% plot upper and lower bounds 
    fprintf('Creating bounds graph...\n')
    plot_mob_bg(graph_fn_a, cuts, vals);
    
    %% plot them
    plot_file(graph_fn_a, x_min_reg);
    plot_file(graph_fn_a, x_max_reg);
    
    %% version of this with a vertical line for pres
    xline(25, '--r', 'DisplayName', 'p_{25}');
    write_pdf(graph_fn_c)
        
    %%%%%%%%%%%%%%%%%%% PANEL B: GRADIENT FITS TO CEFS ABOVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Shows linear regression, plus linear regressions for those two functions
    
    %% create X matrix for reg coef calculation
    X = [ones(100, 1) (1:100)'];
    
    %% calculate regression solution for x_min and x_max
    coefs_x_min = ((inv(X'*X))*X'*x_min_reg');
    coefs_x_max = ((inv(X'*X))*X'*x_max_reg');
    
    %% i calculated the reg coefs in Stata, doing just the predictions here
    %% calc_naive_elast.do
    %% b0 = 0.23; b1 = 0.54
    coefs_naive  = [ 23.00604 .5398783]';
    
    p_min_hat = X * coefs_x_min;
    p_max_hat = X * coefs_x_max;
    naive_hat = X * coefs_naive;
    
    plot_mob_bg(graph_fn_bg, cuts, vals);
    write_pdf(graph_fn_bg);
    
    hold on
    plot(1:100, p_min_hat, 'k--')
    plot(1:100, p_max_hat, 'k--')
    plot(1:100, naive_hat, 'k')
    
    %% write PNG and PDF files
    write_pdf(graph_fn_b);

    %% create another plot showing the moments and the mu-0-50 fit to 1960
    clf;
    plot_mob_bg(graph_fn_bg, cuts, vals);
    rectangle('Position', [0 36.6 50 2.4], 'FaceColor', [0 .6 0], 'EdgeColor', [0 .4 0]);
%%    txt = texlabel('mu_0^{50} = E(y|x \in [0, 50]) in [36.6, 39]');
    text(10, 33.5, 'Bottom Half Mobility');
    text(5, 29, '\mu_0^{50} = E(y|x \in [0, 50]) \in [36.6, 39]');
    write_pdf(graph_mu);
    hold on
    
end
