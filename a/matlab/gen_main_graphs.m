% set up parameters to match 
f2_set = [250 0.10 0.05 0];
bc_set = [1980 1970 1960 1950];

for f2_limit = 1:length(f2_set) 

    for bc = 1:length(bc_set)

        for group = {'_sc' '_gen' 'all'}

            % set parameters for call to plot_cef_bounds()
            
            % load data 
            moment_fn = sprintf('~/iec/output/mobility/moments/main_%s_%d.csv', group{1}, bc_set(bc));
            bounds_fn = sprintf('~/iec/output/mobility/bounds/bounds_%s_%d_%d.csv', group{1}, bc_set(bc), f2_limit);   
            graph_fn  = sprintf('~/iec1/output/pn/bounds_%s_%d_%d', group{1}, bc_set(bc), f2_limit);
            
            % generate graph and write to a file
            plot_cef_bounds(moment_fn, bounds_fn, graph_fn)
        end 
    end
end 
