%% function to calculate bounds on intergenerational mobility, based on set of rank bin means and sons' outcomes.

%% inputs: 
%% - maximum magnitude of 2nd derivative (f2_limit)
%%   
%% - name of CSV file that takes following format. Column 1: mean father fank in each bin; Column 2: expected
%%   son outcome in each bin.
%%      .18243258,.35063016
%%      .42220008,.41685656
%%      .56392562,.51044887
%%      .71468472,.58845616
%%      .83880115,.69198436
%%      .92134458,.74009257
%%      .97306955,.80539866
%%
%%
function [p_min p_max] = get_mob_bounds(input_csv, f2_limit);

  %% return value: matrix with p value, lower bound, upper bound
  global A_moments b_moments f_min_mse

  %% if f2_limit is zero, just exit -- takes forever and produces not great solution---just use analytical numbers from
  %% stata.
  if f2_limit == 0
    fprintf('get_mob_bounds() called with f2_limit == 0.  Use Stata gradient predictions instead.\n')
    return
  end

  %% possibly unnecessary definition of global MSE minimum
  f_min_mse = 0;

  %% expand function evaluations for solver to give it a better chance to find the solution
  options = optimoptions(@fmincon,'MaxFunEvals',1000000,'Display','none','TolCon',1e-3,'TolFun',1e-3,'TolX',1e-10);

  %% read bin means and values and convert to a set of bin cuts and values
  %% e.g. CSV file                     cuts,    vals
  %% 18.243258,35.063016               1-36:   35.06  
  %% 42.220008,41.685656               37-47:  41.69 
  %% 56.392562,51.044887               48-62:  51.04 
  %% 71.468472,58.845616     --------> 63-79:  58.84 
  %% 83.880115,69.198436               80-88:  69.20 
  %% 92.134458,74.009257               89-94:  74.01 
  %% 97.306955,80.539866               95-100: 80.54
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

  %% set b_f2 limit -- stack twice since needs to line up with both positive and negative A_f2 matrix
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

  %% define starting points for optimizer as perfect mobility 
  x0_perfect = 50 * ones(1, num_ps);

  %% set upper and lower bound vectors
  lb = zeros(1, num_ps);
  ub = 100 * ones(1, num_ps);

  %% create arrays to hold max and minimum values of p. start at extreme values, so we can tell if the solver failed
  clear p_min p_max
  p_min = zeros(num_ps, 1);
  p_max = 100 * ones(num_ps, 1);

  p_min = -100000 * ones(1,num_ps); 
  p_max = zeros(1,num_ps);

  %% STEP 1: CALCULATE MINIMUM MSE UNDER THIS f2 CONSTRAINT
  [x_start, f_min_mse, exit_flag, output] = fmincon(@fun_mse, x0_perfect, [A_pos_slope; A_f2_sym], [b_pos_slope; b_f2_sym], [], [], lb, ub, [], options);
  assert(exit_flag == 1 | exit_flag == 2);
  
  %% STEP 2: MAXIMIZE/MINIMIZE EACH p-BOUND, S.T. TO MEETING THIS MSE

  %% create inequality constraint vector: positive slope, f2 below threshold, MSE below threshold
  A_ineq = [A_pos_slope; A_f2_sym];
  b_ineq = [b_pos_slope; b_f2_sym];

  %% preload x_min and x_max
  x_min = x_start;
  x_max = x_start;

  %% loop over all p-levels
  fprintf('Finding bounds on requested p-levels...');

  for j = 1:1:100

    if mod(j, 10) == 1
      fprintf('\nCalculating p-levels %d to %d.', j, j + 9);
    else
      fprintf('.');
    end

    %% calculate max feasible p-level
    [x_min, f_min, exit_flag, output] = fmincon(@(x) (x(j)), x_min, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    if (exit_flag == 1 | exit_flag == 2)
      p_min(j, 1) = x_min(j);
    end
    
    %% calculate minimum feasible p-level
    [x_max, f_min, exit_flag, output] = fmincon(@(x) (-x(j)), x_max, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    if (exit_flag == 1 | exit_flag == 2)
      p_max(j, 1) = x_max(j);
    end
  end
  fprintf('\n');
