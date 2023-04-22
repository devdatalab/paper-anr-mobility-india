% calculate mobility bounds on best, worst and wage case for each mobility measure

input_low = '/scratch/pn/moment_child_low_mob.csv';
input_high = '/scratch/pn/moment_child_high_mob.csv';
input_hat = '/scratch/pn/moment_child_hat.csv';

% MOBILITY STATISTIC FUNCTIONS
X = [ones(100, 1) (1:100)'];
fun_reg_coef = @(p) ((inv(X'*X))*X'*p);
fun_p25 = @(x) mean(x(25:26));
fun_mu50 = @(x) mean(x(1:50));

coef_low = bound_reg_coef(input_low, 0.10);
p25_low  = bound_generic_fun(input_low, 0.10, fun_p25);
mu50_low = bound_generic_fun(input_low, 0.10, fun_mu50);

coef_high = bound_reg_coef(input_high, 0.10);
p25_high  = bound_generic_fun(input_high, 0.10, fun_p25);
mu50_high = bound_generic_fun(input_high, 0.10, fun_mu50);

coef_hat = bound_reg_coef(input_hat, 0.10);
p25_hat  = bound_generic_fun(input_hat, 0.10, fun_p25);
mu50_hat = bound_generic_fun(input_hat, 0.10, fun_mu50);

% write results to an output data file for use with table_tpl
stat_set = {'coef','p25','mu50'};
var_set = {'low','high','hat'};

output_fn = '~/iec/output/mobility/son_censor_stats.csv';
fh = fopen(output_fn, 'w');
for s = 1:length(stat_set)
    stat = stat_set{s};
    for v = 1:length(var_set)
        var = var_set{v};
        stat_lb = eval(sprintf('%s_%s(1)', stat, var));
        stat_ub = eval(sprintf('%s_%s(2)', stat, var));
        fprintf(fh, '%s_%s_lb,%1.2f\n', stat, var, stat_lb);
        fprintf(fh, '%s_%s_ub,%1.2f\n', stat, var, stat_ub);
    end
end
fclose(fh);

% fill data into latex template
system('python ~/iecmerge/include/stata-tex/table_from_tpl.py -t ~/iecmerge/bounds/tex/tpl_son_censor.tex -r ~/iec/output/mobility/son_censor_stats.csv -o ~/iec/output/mobility/son_censor.tex -v')
