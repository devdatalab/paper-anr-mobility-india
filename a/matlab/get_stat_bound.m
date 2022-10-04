function bound = get_stat_bound(stat, group, birth_cohort, f2_limit);

    % get full set of bootstrap stats from stored estimate file
    bound_folder = '~/iec/output/mobility/bounds';
    input_csv = sprintf('%s/%s_%s.csv', bound_folder, stat, group);

    % if file doesn't exist, this bootstrap hasn't been done -- return missing data
    if ~exist(input_csv, 'file')
        fprintf('missing\n')
        bound = [-999 -999];
        return
    end

    % read bound statistics from CSV
    data = csvread(input_csv, 1, 0);

    % round f2 limits so no floating point equality problems
    data(:, 1) = round(data(:, 1) * 100);

    % restrict data matrix to rows of interest: 
    % f2 limit
    data = data(data(:, 1) == round(f2_limit*100), :);

    % birth cohort
    data = data(data(:, 2) == birth_cohort, 3:4);

    % if data is empty, return missing (since need to return a 1x2 matrix)
    if isempty(data)
        bound = [-999 -999];
    else
        bound = data;
    end
