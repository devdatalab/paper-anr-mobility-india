%%%%%%%%%%%%%%%%%% FIGURE: MOMENTS, CUTS, CEFS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each figure shows the moments, the cuts, and the CEFs
% Panel A: 1950
% Panel B: 1980

% PANEL A GRAPH SHOWING JUST POINT ESTIMATES AND ONE BIN BOUNDARY
% - GENERATE SEPARATELY FOR STARTING POINTS 25, 35, 45
bc_set = [1980, 1950, 1960, 1970];
output_path = '~/iec/output/mobility';

% define birth cohort sets for graph labels
cohort_set = {'1980-1989' '1950-1959' '1960-1969' '1970-1979'};

for i = 1:length(bc_set)
    clf
    hold on
    bc = bc_set(i);
    cohort_str = sprintf('%s cohort', cohort_set{i});

    moment_csv = sprintf('~/iec/output/mobility/moments/all_%d.csv', bc);
    
    [cuts, vals] = read_bins(moment_csv);

    % calculate the mean value in each cut
    c(1) = cuts(1) / 2;
    for j = 2:length(cuts)
        c(j) = cuts(j-1) + (cuts(j) - cuts(j-1)) / 2;
    end

    % plot the original data
    h_scatter = scatter(c, vals, 'k');
    
    % set axis limits
    xlim([1 100])
    ylim([0 100])
    
    % plot the bin dividers
    for j = 1:length(cuts)
      plot([cuts(j) cuts(j)], [0 100], 'k')
    end

    % plot a dashed vertical line at p25
    plot([25 25], [0 100], 'color', [.5 .5 .5], 'linestyle', '--')
    
    % read the CEF data (f2=10)
    fn_bounds = sprintf('%s/bounds/bounds_all_%d_%d.csv', output_path, bc, 10);
    bounds = csvread(fn_bounds);
    lb = bounds(:, 3);
    ub = bounds(:, 4);

    % plot the CEF bounds
    plot(0.5:1:99.5, lb, 'k');
    plot(0.5:1:99.5, ub, 'k');
    
    % add a legend
    % h_legend = legend([h_scatter c_end], cohort_str, '1980-1989 cohort', 'Location', 'southeast');
    % set(h_legend, 'FontSize', 14);

    % label axes
    xlabel('Parent Rank');
    ylabel('Expected Child Rank');

    % grow the font size
    set(gca,'fontsize',16)
    
    % send to a file
    fn = sprintf('%s/figures/fig_mob_moments_cuts_%d', output_path, bc);
    write_pdf(fn);
end
