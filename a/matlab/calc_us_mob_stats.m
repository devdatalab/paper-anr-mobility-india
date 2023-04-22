input_csv = '/scratch/pn/us_black_female_ranks.csv'

fun_p25 = @(x) mean(x(25:26));
fun_mu50 = @(x) mean(x(1:50));

bound_generic_fun(input_csv, 250, fun_p25)
bound_generic_fun(input_csv, 0.10, fun_p25)
bound_generic_fun(input_csv, 0.05, fun_p25)
bound_generic_fun(input_csv, 0, fun_p25)


bound_generic_fun(input_csv, 250, fun_mu50)
bound_generic_fun(input_csv, 0.10, fun_mu50)
bound_generic_fun(input_csv, 0.05, fun_mu50)
bound_generic_fun(input_csv, 0, fun_mu50)
