% Get a Mu
% - Takes input csv OR cuts / values.
% - pass blank string to input_csv if providing cuts and values
function mu_bound = bound_mu(input_csv, cuts, vals, mu_s, mu_t, f2, spec)

% turn off warnings when setting seeds -- we don't care
warning('off', 'MATLAB:nearlySingularMatrix')

% seed the solver at p_x, x = mu midpoint
[p_bound, next_min_seed, next_max_seed] = bound_generic_fun2(input_csv, cuts, vals, @(x) x(round((0.5)*(mu_s+mu_t))), f2, spec);

% restore warnings for main run
warning('on', 'MATLAB:nearlySingularMatrix')

% calculate mu from starting seed
[mu_bound, next_min_seed, next_max_seed] = bound_generic_fun2(input_csv, cuts, vals, @(x) mean(x(mu_s:mu_t)), f2, spec, next_min_seed, next_max_seed);







