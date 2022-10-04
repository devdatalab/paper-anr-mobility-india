clear all

% GOAL: GENERATE ROLLING BIRTH COHORT MOBILITY FIGURES
age_set = [1950:1983];
data_folder = '~/iec/output/mobility/moments';
fn_prefix = 'mu50';
group = 'all';

%%%%%%%%%%%%%%%%%%%%%%%%%%
% mu50
fprintf('Calculating mu50...\n');
fun_mu50 = @(x) mean(x(1:50));

for i = 1:length(age_set)
    i
    input_csv = sprintf('%s/%s_%d.csv', data_folder, group, age_set(i));
    pop_mu50_10(i, :) = bound_generic_fun(input_csv, 0.10, fun_mu50);
end

clf
hold on
plot(age_set', pop_mu50_10(:, 1));
plot(age_set', pop_mu50_10(:, 2));
write_pdf('/scratch/pn/mu50_all')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% repeat for p25
fprintf('Calculating p25...\n');
fun_p25 = @(x) mean(x(25:26));

for i = 1:length(age_set)
    i
    input_csv = sprintf('%s/%s_%d.csv', data_folder, group, age_set(i));
    pop_p25_10(i, :) = bound_generic_fun(input_csv, 0.10, fun_p25);
end

clf
hold on
plot(age_set', pop_p25_10(:, 1));
plot(age_set', pop_p25_10(:, 2));
write_pdf('/scratch/pn/p25_all')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% repeat for gradient
fprintf('Calculating reg coef...\n');

for i = 1:length(age_set)
    i
    input_csv = sprintf('%s/%s_%d.csv', data_folder, group, age_set(i));
    pop_grad_10(i, :) = bound_reg_coef(input_csv, 0.10);
end

clf
hold on
plot(age_set', pop_grad_10(:, 1));
plot(age_set', pop_grad_10(:, 2));
write_pdf('/scratch/pn/gradient_all')
