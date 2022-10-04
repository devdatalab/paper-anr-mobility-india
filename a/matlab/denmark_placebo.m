% generates all mobility graphs, looping over: (i) age groups; (ii) caste groups; (iii) f2 limits

% denmark: limit from 0.0006 to 0.00028
% US: .00034, 0.00017

f2_set = [250 0.20 0.10 0.05];
% f2_set = [0.20];

% temporary fix since trying to update paper
tic

for f2 = 1:length(f2_set)

   % create f2 file suffix and f2 limit
   f2_limit = f2_set(f2);
   f2_suffix = num2str(f2_limit * 100);
        
       % set input file with moments, output bounds csv filename, graph filename
       moment_fn = sprintf('~/iec1/mobility/denmark_censored.csv') 
       graph_fn = sprintf('~/iec/output/mobility/figures/denmark_bounds_%s', f2_suffix);
       bounds_fn = sprintf('~/iec/output/mobility/bounds/bounds_%s.csv',f2_suffix);

       % get_mob_bounds
       toc

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % % skip if f2 == 0 -- these bounds are generated in Stata.                     %
       % if f2_limit ~= 0                                                              %
       %     [p_min p_max] = get_mob_bounds(moment_fn, f2_limit);              %
       %                                                                               %
       %     % write bounds to a CSV file                                              %
       %     fprintf('Writing output file %s...\n\n\n', bounds_fn)                     %
       %     f = fopen(bounds_fn, 'w');                                                %
       %                                                                               %
       %     % write header line                                                       %
       %     % fprintf(f, 'f2_limit,p,p_min,p_max\n');                                 %
       %                                                                               %
       %     for p = 1:100                                                             %
       %       fprintf(f, '%10.8f,%d,%5.4f,%5.4f\n', f2_limit, p, p_min(p), p_max(p)); %
       %      end                                                                      %
       % end                                                                           %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



       % Plot the CEF bounds
       graph_denmark(moment_fn, bounds_fn, graph_fn)
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % fix the line plot for denmark  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
censored_data = csvread('~/iec1/mobility/denmark_censored.csv',1)

% load spline
true_spline = csvread('~/iec1/mobility/den_5knots.csv')

clf 
% ,18,[.5 .5 .5],
% plot true spline 
hold on 
plot(true_spline(1:99,1),true_spline(1:99,2),'--','DisplayName','True spline (5 knots)','Color','b')

% plot censored data 
scatter(censored_data(:,1),censored_data(:,2),'filled','k','DisplayName','Censored data')

% load in the data 
data = csvread('~/iec1/mobility/denmark_censored.csv',1) 

% plot and get best fit line 
p = polyfit(data(:,1),data(:,2),1) ;         
x1 = linspace(0,100) 
y1 = polyval(p,x1)

line(x1,y1,'Color','k','DisplayName','Implied bounds') 

% print 
axis([0 100 15 75]) 
legend('show') 
legend boxoff
hold off 
xlabel('Parent Rank')
ylabel('Child Rank') 

set(gca,'fontsize',25) 

write_pdf('denmark_bounds_0') 
command = 'cp ~/public_html/png/denmark_bounds* ~/iec/output/mobility/figures/ '
status = dos(command) 
