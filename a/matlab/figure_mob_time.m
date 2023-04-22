%%%%%%%%%%%%%%%%%%% FIGURE: MOBILITY OVER TIME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Panel A: point estimates for mob 1950, 1985
%% Panels B->D: non-parametric bounds for various f2 restrictions

%% PANEL A GRAPH SHOWING JUST POINT ESTIMATES AND ONE BIN BOUNDARY
%% - GENERATE SEPARATELY FOR STARTING POINTS 25, 35, 45
bc_set = [1985, 1970, 1960, 1950];
graph_path = strcat(base_path, '/out');
graph_fn   = '%s/moments_%d_1985';
input_path = base_path;
bounds_path = strcat(base_path, '/bounds');

%% define birth cohort sets for graph labels
cohort_set = {'1985-1989' '1970-1979' '1960-1969', '1950-1959'};

for i = 2:4
  clf
  hold on
  bc = bc_set(i);
  cohort_str_old = sprintf('%s cohort', cohort_set{i});

  moment_csv_start = sprintf('%s/moments/ed_ranks_0_%d.csv', input_path, bc);
  moment_csv_end   = sprintf('%s/moments/ed_ranks_0_%d.csv', input_path, 1985);
  
  [cuts_start, vals_start] = read_bins(moment_csv_start);
  [cuts_end, vals_end] =     read_bins(moment_csv_end);

  %% get standard errors for both sets of son estimates
  %% not used since standard errors are so tiny that they are irrelevant
  %% data_start = csvread(moment_csv_start, 1, 0);
  %% se_start = data_start(:, 3);
  %% data_end = csvread(moment_csv_end, 1, 0);
  %% se_end = data_end(:, 3);
  
  %% calculate the mean value in each cut
  c(1) = cuts_start(1) / 2;
  for j = 2:length(cuts_start)
    c(j) = cuts_start(j-1) + (cuts_start(j) - cuts_start(j-1)) / 2;
  end

  %% plot the original data
  c_start = scatter(c, vals_start, 'k');
  
  %% set x axis length
  xlim([1 100])
  ylim([0 100])
  
  %% plot only the first bin dividers
  plot([cuts_start(1) cuts_start(1)], [0 100], 'k')

% repeat for the old group (always 55s), but with different line styles
  
  %% calculate the mean value in each cut
  c(1) = cuts_end(1) / 2;
  for j = 2:length(cuts_end)
    c(j) = cuts_end(j-1) + (cuts_end(j) - cuts_end(j-1)) / 2;
  end
  
  %% plot the data
  c_end = scatter(c, vals_end, [], 'x', 'MarkerEdgeColor', [0 0 1]);
  
  %% plot bin dividers
  plot([cuts_end(1) cuts_end(1)], [0 100], '--', 'Color', [0 0 1])
  
  %% add a legend
  h_legend = legend([c_start c_end], cohort_str_old, '1985-1989 cohort', 'Location', 'southeast');
  set(h_legend, 'FontSize', 14);

  xlabel('Parent Rank', 'FontSize', 14);
  ylabel('Child Rank', 'FontSize', 14);
  
  %% send the graph to a file
  fn = sprintf(graph_fn, graph_path, bc);
  write_pdf(fn);
end


%% Generate the overlapping CEF graph for 1960-69 starting bc only
for i = 3:3

  %% set cohort_str for legend
  cohort_str_old = sprintf('%s cohort', cohort_set{i});
  bc = bc_set(i);

  %% only interested in f2=inf and f2=optimal
  for f2 = [25000 10]
    clf
    hold on
    fn_bounds1 = sprintf('%s/bounds_0_%d_%d.csv', bounds_path, bc, f2);
    fn_bounds2 = sprintf('%s/bounds_0_1985_%d.csv', bounds_path, f2);

    overlay_p_bounds({fn_bounds1 fn_bounds2}, {cohort_str_old '1985-1989 cohort'});
    fn = sprintf('%s/fig_time_%d_%d', graph_path, bc, f2);
    write_pdf(fn);
  end
end
