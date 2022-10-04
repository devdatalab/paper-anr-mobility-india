function plot_cef_bounds(moment_fn, bounds_fn, graph_fn)

% load raw data 
raw_data = csvread(moment_fn, 1, 0);

% get bin boundaries 
[cuts] = read_bins(moment_fn);

% load bounds from data file
bounds = csvread(bounds_fn);

% plot CEF bounds
clf 
hold on 

% note subtracting 0.5 since bound(1) -> mean value in [0,1] interval
plot(bounds(1:100,2) - 0.5, bounds(1:100, 3),'Color', 'k','DisplayName','Implied bounds')
plot(bounds(1:100,2) - 0.5, bounds(1:100, 4),'Color', 'k','DisplayName','Implied bounds')

% plot bin means
scatter(raw_data(:,1),raw_data(:,2), 'filled', 'k')

% plot bin boundaries
for i = 1:length(cuts)
    plot([cuts(i) cuts(i)], [0 100], 'k')
end

% axis label
xlabel('Parent Rank');
ylabel('Child Rank');

% write graph
write_pdf(graph_fn);

hold off 
