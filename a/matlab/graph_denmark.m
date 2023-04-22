function graph_denmark(moment_fn,bounds_fn,graph_fn) ; 

% load bounds 
inputname = sprintf(bounds_fn)
bounds = csvread(inputname)

% load censored data 
censored_data = csvread(moment_fn,1) 

% append_missing_data = zeros(length(bounds) - length(censored_data),0)
% append_missing_data = [append_missing_data append_missing_data]
% censored_data = vertcat(censored_data 

% censored_data = padadd(censored_data,bounds)
% censored_data = censored_data(:,1:2)

% load spline
true_spline = csvread('~/iec1/mobility/den_5knots.csv')

clf 
% ,18,[.5 .5 .5],
% plot true spline 
hold on 
plot(true_spline(1:99,1) - 0.5,true_spline(1:99,2),'--','DisplayName','True spline (5 knots)','Color','b')

% plot censored data 
scatter(censored_data(:,1),censored_data(:,2),'filled','k','DisplayName','Censored data')

% plot bounds
plot(bounds(1:99,2) - 0.5, bounds(1:99,3),'Color', 'k','DisplayName','Implied bounds')
% legnd('show') 

plot(bounds(1:99,2) - 0.5, bounds(1:99,4),'Color', 'k')
hold off 

% legend('Fitted spline (5 knots)','Censored data','Implied bounds') 

% legends
legend boxoff

% axis 
axis([0 100 15 75]) 

xlabel('Parent Rank')
ylabel('Child Rank') 

set(gca,'fontsize',25) 

% export 
write_pdf(graph_fn);

