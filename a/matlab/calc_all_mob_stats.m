clear all

%% Get global paths
set_basepath

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL: CALCULATE ALL MOBILITY STATS OF INTEREST, FOR ALL GROUPS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% measures: gradient, p25, mu50

% c-bars: 250, 0.20, 0.10, 0

% cohorts: 1950, 60, 70, 80

% groups: all, gen, sc

% varname: [measure]_cbar --> 4 row vector for cohorts 55, 45, 35, 25.
bc_set = [1950 1960 1970 1975 1980 1985];
f2_set = [250 0.2 0.1 0];    % not used -- hard-coded below for coding/reading ease
group_set = {'0' '1' '2' '3' '4'};
output_path = strcat(base_path, '/bounds');
moment_path = strcat(base_path, '/moments');

% MOBILITY STATISTIC FUNCTIONS -- THESE GET SENT TO bound_generic_fun()
X = [ones(100, 1) (1:100)'];
fun_reg_coef = @(p) ((inv(X'*X))*X'*p);
fun_p25 = @(x) mean(x(25:26));
fun_mu50 = @(x) mean(x(1:50));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loop over all groups
for g = 1:length(group_set)

    % set group string
    group = group_set{g};

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % regression coefficients
    fprintf('Calculating regression coefficients (group %s)...\n', group);
    tic
    for i = 1:length(bc_set)
        input_csv = sprintf('%s/ed_ranks_%s_%d.csv', moment_path, group, bc_set(i));
        fprintf('250...');
        coef_inf(i, :) = bound_reg_coef(input_csv, 250);
        fprintf('0.20...');
        coef_20(i, :) = bound_reg_coef(input_csv, 0.20);
        fprintf('0.10...');
        coef_10(i, :) = bound_reg_coef(input_csv, 0.10);
        fprintf('0.01...\n');
        coef_00(i, :) = bound_reg_coef(input_csv, 0.01);

        % get c-bar = 0 value from stored data
        % cef = csvread(sprintf('~/iec/output/mobility/bounds/bounds_%s_%d_0.csv', group, bc_set(bc)));
        % c = fun_reg_coef(cef(:, 3));
        % coef_00(i, :) = [c(2) c(2)];
        toc
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % p25
    fprintf('Calculating p25 (%s)...\n', group);
    
    for i = 1:length(bc_set)
        input_csv = sprintf('%s/ed_ranks_%s_%d.csv', moment_path, group, bc_set(i));
        fprintf('250...');
        p25_inf(i, :) = bound_generic_fun(input_csv, 250 , fun_p25);
        fprintf('0.20...');
        p25_20(i, :)  = bound_generic_fun(input_csv, 0.20, fun_p25);
        fprintf('0.10...');
        p25_10(i, :)  = bound_generic_fun(input_csv, 0.10, fun_p25);
        fprintf('0.01...');
        p25_00(i, :)  = bound_generic_fun(input_csv, 0.01, fun_p25);
    
        % get c-bar = 0 value from stored data
        % cef = csvread(sprintf('~/iec/output/mobility/bounds/bounds_%s_%d_0.csv', group, bc_set(i)));
        % c = fun_p25(cef(:, 3));
        % p25_00(i, :) = [c c];
        toc
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % mu50
    fprintf('Calculating mu50 (%s)...\n', group);
    
    for i = 1:length(bc_set)
        input_csv = sprintf('%s/ed_ranks_%s_%d.csv', moment_path, group, bc_set(i));
        fprintf('250...');
        mu50_inf(i, :) = bound_generic_fun(input_csv, 250 , fun_mu50);
        fprintf('0.20...');
        mu50_20(i, :)  = bound_generic_fun(input_csv, 0.20, fun_mu50);
        fprintf('0.10...');
        mu50_10(i, :) = bound_generic_fun(input_csv, 0.10, fun_mu50);
        fprintf('0.01...');
        mu50_00(i, :) = bound_generic_fun(input_csv, 0.01, fun_mu50);
    
        %% % get c-bar = 0 value from stored data
        %% cef = csvread(sprintf('~/iec/output/mobility/bounds/bounds_%s_%d_0.csv', group, bc_set(i)));
        %% c = fun_mu50(cef(:, 3));
        %% mu50_00(i, :) = [c c];
        toc
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % write all mobility estimates to a CSV
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % set target filename
    output_csv_coef = sprintf('%s/coef_%s.csv', output_path, group);
    output_csv_p25 = sprintf('%s/p25_%s.csv', output_path, group);
    output_csv_mu50 = sprintf('%s/mu50_%s.csv', output_path, group);
    
    % open all three output files
    f_coef = fopen(output_csv_coef, 'w');
    f_p25  = fopen(output_csv_p25, 'w');
    f_mu50 = fopen(output_csv_mu50, 'w');

    % write headers
    fprintf(f_coef, 'f2_limit,cohort,lb,ub\n');
    fprintf(f_p25, 'f2_limit,cohort,lb,ub\n');
    fprintf(f_mu50, 'f2_limit,cohort,lb,ub\n');
    
    % loop over birth cohorts
    for i = 1:length(bc_set)
        bc = bc_set(i);

        % write all stats
        fprintf(f_coef, '%6.2f, %d, %10.5f, %10.5f\n', 250, bc, coef_inf(i, 1), coef_inf(i, 2));
        fprintf(f_coef, '%6.2f, %d, %10.5f, %10.5f\n', 0.2, bc, coef_20(i, 1),  coef_20(i, 2));
        fprintf(f_coef, '%6.2f, %d, %10.5f, %10.5f\n', 0.1, bc, coef_10(i, 1),  coef_10(i, 2));
        fprintf(f_coef, '%6.2f, %d, %10.5f, %10.5f\n',   0, bc, coef_00(i, 1),  coef_00(i, 2));
        
        fprintf(f_p25, '%6.2f, %d, %10.5f, %10.5f\n', 250, bc, p25_inf(i, 1), p25_inf(i, 2));
        fprintf(f_p25, '%6.2f, %d, %10.5f, %10.5f\n', 0.2, bc, p25_20(i, 1),  p25_20(i, 2));
        fprintf(f_p25, '%6.2f, %d, %10.5f, %10.5f\n', 0.1, bc, p25_10(i, 1),  p25_10(i, 2));
        fprintf(f_p25, '%6.2f, %d, %10.5f, %10.5f\n',   0, bc, p25_00(i, 1),  p25_00(i, 2));
    
        fprintf(f_mu50, '%6.2f, %d, %10.5f, %10.5f\n', 250, bc, mu50_inf(i, 1), mu50_inf(i, 2));
        fprintf(f_mu50, '%6.2f, %d, %10.5f, %10.5f\n', 0.2, bc, mu50_20(i, 1),  mu50_20(i, 2));
        fprintf(f_mu50, '%6.2f, %d, %10.5f, %10.5f\n', 0.1, bc, mu50_10(i, 1),  mu50_10(i, 2));
        fprintf(f_mu50, '%6.2f, %d, %10.5f, %10.5f\n',   0, bc, mu50_00(i, 1),  mu50_00(i, 2));
    end
    
    % close output files
    fclose(f_coef);
    fclose(f_p25);
    fclose(f_mu50);
end


