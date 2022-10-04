% generates all mobility graphs, looping over: (i) age groups; (ii) caste groups; (iii) f2 limits

% denmark: limit from 0.0006 to 0.00028
% US: .00034, 0.00017

f2_set = [250 0.20 0.10 0.05 0];
f2_set = [0.20];
f2_set = .025 * [0 .01 .02 .03 .04 .05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .16 .17 .18 .19 .2] 

bc_set = [1980 1970 1960 1950];
bc_set = [1960];

% temporary fix since trying to update paper
%age_set = [25] 
tic

% for group = {'all' 'sc' 'gen'} 
for group = {'all'} 

    for f2 = 1:length(f2_set)

        % create f2 file suffix and f2 limit
        f2_limit = f2_set(f2);
        
        for bc = 1:length(bc_set)

            % set input file with moments, output bounds csv filename, graph filename
            moment_fn = sprintf('~/iec/output/mobility/moments/%s_%d.csv', group{1}, bc_set(bc));
            bounds_fn = sprintf('~/iec/output/mobility/bounds/f2_bounds_%s_%d_%s.csv', group{1}, bc_set(bc), f2);

            % get_mob_bounds
            fprintf('Calculating p-bounds for group %s, birth cohort %d, f2 limit %d...\n', group{1}, bc_set(bc), f2_limit);
            toc

            % skip if f2 == 0 -- these bounds are generated in Stata.
            if f2_limit ~= 0
                [p_min p_max] = get_mob_bounds(moment_fn, f2_limit);
                
                % write bounds to a CSV file
                fprintf('Writing output file %s...\n\n\n', bounds_fn)
                f = fopen(bounds_fn, 'w');
                for p = 1:100
                    fprintf(f, '%10.8f,%d,%5.4f,%5.4f\n', f2_limit, p, p_min(p), p_max(p));
                end
            end

        end
    end
end


% plot the bounds 
graph_f2(1990,21)

