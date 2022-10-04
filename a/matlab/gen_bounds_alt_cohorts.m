% generates mobility graphs using alternate year birth cohorts -- robustness checking

% denmark: limit from 0.0006 to 0.00028
% US: .00034, 0.00017

f2_set = [0.10];

bc_set = [1981 1971 1961 1951 1982 1972 1962 1952];

tic

%for group = {'all' 'sc' 'gen' } 
for group = {'sc' 'gen'}

    for f2 = 1:length(f2_set)

        % create f2 file suffix and f2 limit
        f2_limit = f2_set(f2);
        f2_suffix = num2str(f2_limit * 100);
        
        for bc = 1:length(bc_set)

            % set input file with moments, output bounds csv filename, graph filename
            moment_fn = sprintf('~/iec/output/mobility/moments/%s_%d.csv', group{1}, bc_set(bc));
            graph_fn = sprintf('~/iec1/output/pn/bounds_%s_%d_%s', group{1}, bc_set(bc), f2_suffix);
            bounds_fn = sprintf('~/iec/output/mobility/bounds/bounds_%s_%d_%s.csv', group{1}, bc_set(bc), f2_suffix);

            % Calculate the bounds
            fprintf('\nCalculating p-bounds for mob_%s_%d_%s...\n', group{1}, bc_set(bc), f2_suffix);
            toc
            [p_min p_max] = get_mob_bounds(moment_fn, f2_limit);

            % write bounds to a CSV file
            fprintf('Writing output file %s...\n', bounds_fn)
            f = fopen(bounds_fn, 'w');
            for p = 1:100
                fprintf(f, '%10.8f,%d,%5.4f,%5.4f\n', f2_limit, p, p_min(p), p_max(p));
            end

            % Generate a graph
            plot_cef_bounds(moment_fn, bounds_fn, graph_fn)
        end
    end
end
