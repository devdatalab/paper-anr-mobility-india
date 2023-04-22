% find in a cell array:
% C = {1,5,3,4,2,3,4,5,2,1};
% index = find([C{:}] == 5);

clear all
% GOAL: GENERATE A FIGURE WITH ALL MOBILITY STAT CHANGES OVER TIME
%  - each plot shows four coefficient bounds for four decades
%  - 3 plots horizontally for three measures: (i) p25; (ii) mu50; and (iii) beta (rank-rank coef)
%  - 3 plots vertically for three f2 constraints 0, 0.05, 0.10

% calculate analytical solution when C = 0

num_bootstraps = 1000;
starting_point = 1;

% varname: pop_[measure]_cbar --> 4 row vector for cohorts 55, 45, 35, 25.
tmp_folder = '/scratch/pn';
output_folder = '~/iec/output/mobility/bootstrap_stats';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters for main tables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bc_set = [1980 1970 1960 1950];
f2_set = [250 0.20 0.10 0.05 0];
moment_folder = '~/iec/output/mobility/bootstrap_moments';
group_set = {'hindu_ihds_2011' 'sc_ihds_2011' 'muslim_ihds_2011' 'all' 'sc' 'gen'};
stat_set =  {'coef' 'p25' 'mu50'};

%%%%%%%%%%%
% OVERRIDES
%%%%%%%%%%%
f2_set = [0.10];
group_set = {'hindu_ihds_2011' 'sc_ihds_2011' 'muslim_ihds_2011'};
bc_set = [1950 1960 1970 1980];
num_bootstraps = 100;
stat_set =  {'p75' 'mu100'};

% erase all output files (in scratch folder)
for f = 1:length(f2_set)
    f2_fn = round(f2_set(f) * 100);
    for bc = 1:length(bc_set)
        for g = 1:length(group_set)
            group = group_set{g};
            for s = 1:length(stat_set)
                stat = stat_set{s};
                fn = sprintf('%s/%s_%s_%d_%d.csv', tmp_folder, stat, group, bc_set(bc), f2_fn);

                if exist(fn, 'file') == 2
                    delete(fn)
                end
            end
        end
    end
end

% define all mobility functions
% regression coefficients
X = [ones(100, 1) (1:100)'];
fun_reg_coef = @(p) ((inv(X'*X))*X'*p);

%% p's and mu's
fun_p25 = @(x) mean(x(25:26));
fun_p75 = @(x) mean(x(75:76));
fun_mu50 = @(x) mean(x(1:50));
fun_mu100 = @(x) mean(x(51:100));

%% start timer
tic

% loop over each bootstrap iteration
for bootstrap = 1:num_bootstraps

    % loop over the groups
    for g = 1:length(group_set)
        group = group_set{g};
        
        % loop over the cohorts
        for b = 1:length(bc_set)
            bc = bc_set(b);
            
            % loop over f2 limits
            for f = 1:length(f2_set)
                f2_fn = round(f2_set(f) * 100);
                f2_limit = f2_set(f);
                fprintf('Bootstrap %d: %s-%d-%d (%1.2fs)\n', bootstrap, group, bc, f2_limit, toc');

                % for SC and Generals, we only care about f2 = 0.10.
                if (strcmp(group, 'sc') | strcmp(group, 'gen')) & (f2_fn ~= 10)
                    fprintf('Skipped.\n');
                    continue
                end

                % if f2_limit == 0, calculate statistics from stored CEF
                if f2_limit == 0
                    fn = sprintf('~/iec/output/mobility/bootstrap_bounds/bounds_%s_%d_10000_%d_0.csv', group, bc, bootstrap);
                    cef = csvread(fn);
                    cef = cef(:, 3);

                    % fun_reg_coef returns two values, we only want the second
                    ret = fun_reg_coef(cef);
                    coef = [ret(2) ret(2)];

                    ret = fun_p25(cef);
                    p25 = [ret ret];
                    
                    ret = fun_mu50(cef);
                    mu50 = [ret ret];
                    
                % f2_limit > 0, so calculate bounds using the optimizer
                else

                    % read moments from this bootstrap iteration
                    % (note: 10,000 is number of individuals drawn)
                    input_csv = sprintf('%s/%s_%d_10000_%d.csv', moment_folder, group, bc, bootstrap);
                    
                    % calculate bounds on regression coefficient under this constraint
                    if strfind([stat_set{:}], 'coef')
                        coef = bound_reg_coef(input_csv, f2_limit);
                    end
                    if strfind([stat_set{:}], 'p25')
                        p25 = bound_generic_fun(input_csv, f2_limit, fun_p25);
                    end
                    if strfind([stat_set{:}], 'p75')
                        p75 = bound_generic_fun(input_csv, f2_limit, fun_p75);
                    end
                    if strfind([stat_set{:}], 'mu100')
                        mu100 = bound_generic_fun(input_csv, f2_limit, fun_mu100);
                    end
                    if strfind([stat_set{:}], 'mu50')
                        mu50 = bound_generic_fun(input_csv, f2_limit, fun_mu50);
                    end
                end

                % append bounded statistics to stat-specific output files matching these parameters
                if strfind([stat_set{:}], 'coef')
                    output_fn = sprintf('%s/coef_%s_%d_%d.csv', tmp_folder, group, bc, f2_fn);
                    f = fopen(output_fn, 'a');
                    fprintf(f, '%10.5f,%10.5f\n', coef(1), coef(2));
                    fclose(f);
                end
                if strfind([stat_set{:}], 'p25')
                    output_fn = sprintf('%s/p25_%s_%d_%d.csv', tmp_folder, group, bc, f2_fn);
                    f = fopen(output_fn, 'a');
                    fprintf(f, '%10.5f,%10.5f\n', p25(1), p25(2));
                    fclose(f);
                end
                if strfind([stat_set{:}], 'p75')
                    output_fn = sprintf('%s/p75_%s_%d_%d.csv', tmp_folder, group, bc, f2_fn);
                    f = fopen(output_fn, 'a');
                    fprintf(f, '%10.5f,%10.5f\n', p75(1), p75(2));
                    fclose(f);
                end
                if strfind([stat_set{:}], 'mu100')
                    output_fn = sprintf('%s/mu100_%s_%d_%d.csv', tmp_folder, group, bc, f2_fn);
                    f = fopen(output_fn, 'a');
                    fprintf(f, '%10.5f,%10.5f\n', mu100(1), mu100(2));
                    fclose(f);
                end
                if strfind([stat_set{:}], 'mu50')
                    output_fn = sprintf('%s/mu50_%s_%d_%d.csv', tmp_folder, group, bc, f2_fn);
                    f = fopen(output_fn, 'a');
                    fprintf(f, '%10.5f,%10.5f\n', mu50(1), mu50(2));
                    fclose(f);
                end
            end
        end
    end
end

% Once bootstrap is done, copy all files from tmp folder into output folder
% [we use this two step process so the existing bootstrap files don't get wiped as soon
%  as we start this 8-hour process.
for f = 1:length(f2_set)
    f2_fn = round(f2_set(f) * 100);
    for bc = 1:length(bc_set)
        for g = 1:length(group_set)
            group = group_set{g};
            for s = 1:length(stat_set)
                stat = stat_set{s};
                fn_src    = sprintf('%s/%s_%s_%d_%d.csv', tmp_folder,    stat, group, bc_set(bc), f2_fn);
                fn_target = sprintf('%s/%s_%s_%d_%d.csv', output_folder, stat, group, bc_set(bc), f2_fn);

                if exist(fn_src, 'file') == 2
                    copyfile(fn_src, fn_target)
                end
            end
        end
    end
end

