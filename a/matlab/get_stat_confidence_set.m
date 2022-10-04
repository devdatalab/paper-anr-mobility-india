function cs = get_stat_confidence_set(stat, group, birth_cohort, f2_limit);

    % get full set of bootstrap stats from stored estimate file
    bs_folder = '~/iec/output/mobility/bootstrap_stats';
    input_csv = sprintf('%s/%s_%s_%d_%d.csv', bs_folder, stat, group, birth_cohort, round(f2_limit * 100));

    % if file doesn't exist, this bootstrap hasn't been done -- return missing data
    if ~exist(input_csv, 'file')
        cs = [-999 -999];
        return
    end

    % read confidence set from CSV
    data = csvread(input_csv);

    % get upper and lower confidence interval for each bound
    %   (redundant under current spec since 2.5% lower corresponds to 2.5% upper, but 
    %    not obvious that this always has to be the case)
    lb_low  = prctile(data(:, 1), 2.5);
    lb_high = prctile(data(:, 1), 97.5);
    ub_low  = prctile(data(:, 2), 2.5);
    ub_high = prctile(data(:, 2), 97.5);

    % we only care about the lower limit of the low bound, and upper limit of the upper bound
    cs = [lb_low ub_high];
