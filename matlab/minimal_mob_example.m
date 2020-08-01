%% Minimal examples to demonstrate calculation of p25 and mu-0-50

%% Note: this takes grouped data with the parent median rank and the
%% average child rank in each parent bin. Top (header) row is
%% discarded; first column is assumed to be parent, second column
%% child.

%% a sample CSV input file moments.csv:
%%         parent_rank,child_rank
%%         28.9,39.2
%%         64.4,54.8
%%         77.6,60.9
%%         87.0,68.6
%%         92.5,75.5
%%         96.5,82.7
%%         98.8,89.8


%% USE CASE 1

%% Return a full CEF from a set parent-child rank pairs


%% set input file and curvature constraint (large = less constrained)
moment_fn = 'moments.csv'
f2_limit = 0.1

%% calculate full CEF
[p_min p_max] = get_mob_bounds(moment_fn, f2_limit);

%% The return values p_min and p_max are 100 length vectors showing
%% upper and lower bounds on the CEF at each parent rank.



%% USE CASE 2

%% Calculate a mobility statistic (like p25, mu50, or rank-rank gradient) from
%% a set of parent-child rank pairs

%% Define the mobility statistic functions
fun_p25 = @(x) mean(x(25:26));
fun_mu50 = @(x) mean(x(1:50));

%% set input file and curvature constraint (large = less constrained)
moment_fn = 'moments.csv'
f2_limit = 0.1

%% calculate rank-rank regression coefficient
coef = bound_reg_coef(moment_fn, f2_limit);

%% calculate p25
p25_10(i, :)  = bound_generic_fun(moment_fn, 0.10, fun_p25);

%% calculate mu-0-50
mu50_10(i, :) = bound_generic_fun(moment_fn, 0.10, fun_mu50);
