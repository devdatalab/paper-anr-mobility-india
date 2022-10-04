%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create full sample mobility statistics graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% stat_csv = '~/iec/output/mobility/bounds/all_bounds.csv';
output_fn = '~/iec/output/mobility/all_stats2.tex';

% split output table
output_fn1 = '~/iec/output/mobility/all_stats_part1.tex';
output_fn2 = '~/iec/output/mobility/all_stats_part2.tex';

bc_set = [1950 1960 1970 1980];
cohort_str = {'1950-59' '1960-69' '1970-79' '1980-89'};

% round f2 sets to avoid floating point problems
f2_set = [250 0.2 0.1 0];

%%%%%%%%%%%%%%%%%%%%%%
% GET BOUND ESTIMATES

% loop over birth cohorts and request bounds for each
for i = 1:4
    bc = bc_set(i);

    % loop over f2 limits
    for f = 1:length(f2_set)
        f2_limit = f2_set(f);

        % bound_coef(i, f, k); i = bc_index; f = f2_index, k = bounds
        bound_coef(i, f, 1:2) = get_stat_bound('coef', 'all', bc, f2_limit);
        bound_p25 (i, f, 1:2)  = get_stat_bound('p25',  'all', bc, f2_limit);
        bound_mu50(i, f, 1:2) = get_stat_bound('mu50', 'all', bc, f2_limit);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BOOTSTRAP CONFIDENCE SETS

% loop over birth cohorts
for i = 1:4
    bc = bc_set(i);

    % loop over f2 limits
    for f = 1:length(f2_set)
        f2_limit = f2_set(f);

        % cs_coef(i, f, k); i = bc_index; f = f2_index, k = bounds
        cs_coef(i, f, 1:2) = get_stat_confidence_set('coef', 'all', bc, f2_limit);
        cs_p25 (i, f, 1:2) = get_stat_confidence_set('p25',  'all', bc, f2_limit);
        cs_mu50(i, f, 1:2) = get_stat_confidence_set('mu50', 'all', bc, f2_limit);
    end
end

% create a second set of files where we store the table in two parts
fh1 = fopen(output_fn1, 'w');
fh2 = fopen(output_fn2, 'w');

% loop over birth cohorts
for i = 1:4
    bc = bc_set(i);
    cohort = cohort_str{i};

    % loop over f2 limits
    for f = 1:length(f2_set)
        f2_limit = f2_set(f);

        % create empty estimate strings for this f2 set
        beta_line = '';
        se_line = '';

        % get bounds on each stat in this group
        coef_limit = [bound_coef(i, f, 1) bound_coef(i, f, 2)];
        coef_cs    = [   cs_coef(i, f, 1)    cs_coef(i, f, 2)];

        p25_limit = [bound_p25(i, f, 1) bound_p25(i, f, 2)];
        p25_cs    = [   cs_p25(i, f, 1)    cs_p25(i, f, 2)];

        mu50_limit = [bound_mu50(i, f, 1) bound_mu50(i, f, 2)];
        mu50_cs    = [   cs_mu50(i, f, 1)    cs_mu50(i, f, 2)];

        % if f2_limit = 0, estimate is point identified
        if f2_limit == 0

            % store point estimate for each stat
            beta_line = sprintf('%s & %1.3f', beta_line, coef_limit(1));
            beta_line = sprintf('%s & %1.1f', beta_line, p25_limit(1));
            beta_line = sprintf('%s & %1.1f', beta_line, mu50_limit(1));

        % else, store bounds for each stat in latex format
        else
            % point estimates
            beta_line = sprintf('%s & [%1.3f, %6.3f]', beta_line, coef_limit(1), coef_limit(2));
            beta_line = sprintf('%s & [%1.1f, %5.1f]', beta_line, p25_limit(1), p25_limit(2));
            beta_line = sprintf('%s & [%1.1f, %5.1f]', beta_line, mu50_limit(1), mu50_limit(2));
        end

        % confidence sets have the same format for all f2_limits
        se_line = sprintf('%s & (%1.3f, %6.3f)', se_line, coef_cs(1), coef_cs(2));
        se_line = sprintf('%s & (%1.1f, %5.1f)', se_line, p25_cs(1), p25_cs(2));
        se_line = sprintf('%s & (%1.1f, %5.1f)', se_line, mu50_cs(1), mu50_cs(2));

        % save this result set
        beta_set{i, f} = beta_line;
        se_set{i, f} = se_line;
    end

    % write data to files
    fprintf(fh1, '%s %s %s \\\\ \n', cohort, beta_set{i, 1}, beta_set{i, 2});
    fprintf(fh1, '        %s %s \\\\ \n',  se_set{i, 1}, se_set{i, 2});
    fprintf(fh2, '%s %s %s \\\\ \n', cohort, beta_set{i, 3}, beta_set{i, 4});
    fprintf(fh2, '        %s %s \\\\ \n', se_set{i, 3}, se_set{i, 4});
end

% close all files
fclose(fh1);
fclose(fh2);

