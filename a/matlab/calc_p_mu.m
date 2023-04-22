clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL: CALCULATE p10->p25, mu10->mu50 under C= 0.10, bc=1960
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% measures: gradient, p25, mu50

% c-bars: 250, 0.20, 0.10, 0

% cohorts: 1950, 60, 70, 80

% varname: pop_[measure]_cbar --> 4 row vector for cohorts 55, 45, 35, 25.
bc_set = [ 1950 1960 1970 1980 ];
f2_set = [ 0.1];    % not used -- hard-coded below for coding/reading ease
output_csv = '~/iec/output/mobility/bounds/all_p_mu.csv';
moment_folder = '~/iec/output/mobility/moments';
group = 'all';

%%%%%%%%%%%%%%%%%%%%%%%%%%
% p10 --> p25
fprintf('Calculating p10-p25...\n');
fun_p10 = @(x) mean(x(10:11));
fun_p15 = @(x) mean(x(15:16));
fun_p20 = @(x) mean(x(20:21));
fun_p25 = @(x) mean(x(25:26));

tic
for i = 1:4
    input_csv = sprintf('%s/%s_%d.csv', moment_folder, group, bc_set(i));

    pop_p10_10(i, :)  = bound_generic_fun(input_csv, 0.10, fun_p10);
    pop_p15_10(i, :)  = bound_generic_fun(input_csv, 0.10, fun_p15);
    pop_p20_10(i, :)  = bound_generic_fun(input_csv, 0.10, fun_p20);
    pop_p25_10(i, :)  = bound_generic_fun(input_csv, 0.10, fun_p25);

    toc
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% mu20 --> mu50
fprintf('Calculating mu20-mu50...\n');
fun_mu20 = @(x) mean(x(1:20));
fun_mu30 = @(x) mean(x(1:30));
fun_mu40 = @(x) mean(x(1:40));
fun_mu50 = @(x) mean(x(1:50));

for i = 1:4
    input_csv = sprintf('%s/%s_%d.csv', moment_folder, group, bc_set(i));
    pop_mu20_10(i, :) = bound_generic_fun(input_csv, 0.10, fun_mu20);
    pop_mu30_10(i, :) = bound_generic_fun(input_csv, 0.10, fun_mu30);
    pop_mu40_10(i, :) = bound_generic_fun(input_csv, 0.10, fun_mu40);
    pop_mu50_10(i, :) = bound_generic_fun(input_csv, 0.10, fun_mu50);

    toc
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write all mobility estimates to a CSV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f = fopen(output_csv, 'w');
fprintf(f, 'f2_limit,p,level,cohort,lb,ub\n');

% loop over birth cohorts
for i = 1:4
    bc = bc_set(i);

    % write all stats
    % p == 1 --> absolute mobility.  p == 0 --> absolute mean mobility (mu)
    % level --> 25 == p25.
    fprintf(f, '%6.2f, 1, 10, %d, %7.2f, %7.2f\n', 0.1, bc, pop_p10_10(i, 1), pop_p10_10(i, 2));
    fprintf(f, '%6.2f, 1, 15, %d, %7.2f, %7.2f\n', 0.1, bc, pop_p15_10(i, 1), pop_p15_10(i, 2));
    fprintf(f, '%6.2f, 1, 20, %d, %7.2f, %7.2f\n', 0.1, bc, pop_p20_10(i, 1), pop_p20_10(i, 2));
    fprintf(f, '%6.2f, 1, 25, %d, %7.2f, %7.2f\n', 0.1, bc, pop_p25_10(i, 1), pop_p25_10(i, 2));

    fprintf(f, '%6.2f, 1, 20, %d, %7.2f, %7.2f\n', 0.1, bc, pop_mu20_10(i, 1), pop_mu20_10(i, 2));
    fprintf(f, '%6.2f, 1, 30, %d, %7.2f, %7.2f\n', 0.1, bc, pop_mu30_10(i, 1), pop_mu30_10(i, 2));
    fprintf(f, '%6.2f, 1, 40, %d, %7.2f, %7.2f\n', 0.1, bc, pop_mu40_10(i, 1), pop_mu40_10(i, 2));
    fprintf(f, '%6.2f, 1, 50, %d, %7.2f, %7.2f\n', 0.1, bc, pop_mu50_10(i, 1), pop_mu50_10(i, 2));
end

% close output file
fclose(f);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRODUCE OUTPUT TABLE (content only)
% order is p25, mu50, p20, mu40, etc..

% open table output file
output_fn = '~/iec/output/mobility/all_p_mu.tex';
fh = fopen(output_fn, 'w');

cohort_str = {'1950-59' '1960-69' '1970-79' '1980-89'};
for i = 1:4
    bc = bc_set(i);
    cohort = cohort_str{i};

    % write row header
    fprintf(fh, '%s', cohort);

    % write bounds for each stat
    fprintf(fh, ' & [%1.3f, %6.3f]', pop_p25_10(i, 1), pop_p25_10(i, 2));
    fprintf(fh, ' & [%1.3f, %6.3f]', pop_mu50_10(i, 1), pop_mu50_10(i, 2));

    fprintf(fh, ' & [%1.3f, %6.3f]', pop_p20_10(i, 1), pop_p20_10(i, 2));
    fprintf(fh, ' & [%1.3f, %6.3f]', pop_mu40_10(i, 1), pop_mu40_10(i, 2));

    fprintf(fh, ' & [%1.3f, %6.3f]', pop_p15_10(i, 1), pop_p15_10(i, 2));
    fprintf(fh, ' & [%1.3f, %6.3f]', pop_mu30_10(i, 1), pop_mu30_10(i, 2));

    fprintf(fh, ' & [%1.3f, %6.3f]', pop_p10_10(i, 1), pop_p10_10(i, 2));
    fprintf(fh, ' & [%1.3f, %6.3f]', pop_mu20_10(i, 1), pop_mu20_10(i, 2));

    % finish line
    fprintf(fh, '    \\\\ \n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRODUCE OUTPUT GRAPH COMPARING pXX to muXX for 1960 only
% create p25 and mu50 graph
fn = '~/iec/output/mobility/figures/all_p_mu';
clf
hold on

% p25 and mu50 lines and labels
y = 0.60;
hplot_line(y, pop_p25_10(2, :),  'k', '-');
hplot_line(y - 0.03, pop_mu50_10(2, :), 'k', '--');
text(pop_p25_10(2, 1) -2,  y,  'p_{25}',       'FontUnits', 'points', 'FontSize', 10);
text(pop_mu50_10(2, 1) -2, y - 0.03,  '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 10);

% p20 and mu40 lines and labels
y = y - 0.10;
hplot_line(y, pop_p20_10(2, :),  'k', '-');
hplot_line(y - 0.03, pop_mu40_10(2, :), 'k', '--');
text(pop_p20_10(2, 1) -2,  y,  'p_{20}',       'FontUnits', 'points', 'FontSize', 10);
text(pop_mu40_10(2, 1) -2, y - 0.03,  '\mu_{0}^{40}', 'FontUnits', 'points', 'FontSize', 10);

% p15 and mu30 lines and labels
y = y - 0.10;
hplot_line(y, pop_p15_10(2, :),  'k', '-');
hplot_line(y - 0.03, pop_mu30_10(2, :), 'k', '--');
text(pop_p15_10(2, 1) -2,  y,  'p_{15}',       'FontUnits', 'points', 'FontSize', 10);
text(pop_mu30_10(2, 1) -2, y - 0.03,  '\mu_{0}^{30}', 'FontUnits', 'points', 'FontSize', 10);

% p10 and mu20 lines and labels
y = y - 0.10;
hplot_line(y, pop_p10_10(2, :),  'k', '-');
hplot_line(y - 0.03, pop_mu20_10(2, :), 'k', '--');
text(pop_p10_10(2, 1) -2,  y,  'p_{10}',       'FontUnits', 'points', 'FontSize', 10);
text(pop_mu20_10(2, 1) -2, y - 0.03,  '\mu_{0}^{20}', 'FontUnits', 'points', 'FontSize', 10);



ylim([0.15 0.65])
xlim([0 50])

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 4];

write_pdf(fn)
