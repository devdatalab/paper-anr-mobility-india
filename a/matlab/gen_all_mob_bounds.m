%% generates all mobility graphs, looping over: (i) age groups; (ii) caste groups; (iii) f2 limits

%% denmark: limit from 0.0006 to 0.00028
%% US: .00034, 0.00017

%% set output paths
graph_path = strcat(base_path, '/out');

%% set parameters
f2_set = [250 0.10 0.05 0];
bc_set = [1980 1970 1960 1950];
group_set = {'all' 'sc_ihds_2011' 'hindu_ihds_2011' 'muslim_ihds_2011'}; %% note obsolete file paths. Now: ed_ranks_[0]_[1950].csv
tic

%%%%%%%%%%%%%%%
%% OVERRIDES %%
%%%%%%%%%%%%%%%
f2_set = [250 0.10];
group_set = {'0'};
bc_set = [1985 1960];

for g = 1:length(group_set)

  %% set group string
  group = group_set{g};

  for f2 = 1:length(f2_set)

    %% create f2 file suffix and f2 limit
    f2_limit = f2_set(f2);
    f2_suffix = num2str(f2_limit * 100);
    
    for bc = 1:length(bc_set)

      %% set input file with moments, output bounds csv filename, graph filename
      moment_fn = sprintf('%s/moments/ed_ranks_%s_%d.csv', base_path,   group, bc_set(bc));
      graph_fn  = sprintf('%s/bounds_%s_%d_%s',            graph_path, group, bc_set(bc), f2_suffix);
      bounds_fn = sprintf('%s/bounds/bounds_%s_%d_%s.csv', base_path,   group, bc_set(bc), f2_suffix);

      %% get_mob_bounds
      fprintf('Calculating p-bounds for group %s, birth cohort %d, f2 limit %d...\n', group, bc_set(bc), f2_limit);
      toc

      %% skip if f2 == 0 -- these bounds are generated in Stata.
      if f2_limit ~= 0
        [p_min p_max] = get_mob_bounds(moment_fn, f2_limit);
        
        %% write bounds to a CSV file
        fprintf('Writing output file %s...\n\n\n', bounds_fn)
        f = fopen(bounds_fn, 'w');
        
        %% write header line
        %% fprintf(f, 'f2_limit,p,p_min,p_max\n');
        
        for p = 1:100
          fprintf(f, '%10.8f,%d,%5.4f,%5.4f\n', f2_limit, p, p_min(p), p_max(p));
        end
      end

      %% Plot the CEF bounds
      plot_cef_bounds(moment_fn, bounds_fn, graph_fn)
    end
  end
end
