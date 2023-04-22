function [] = plot_var(v, fn, ystr)

% plot u25, general population
cohorts = [1960 1970 1980 1990]';
hold off
plot(cohorts, v(:, 1), 'k')
hold on
plot(cohorts, v(:, 2), 'k')

% plot a light dashed line for 1990s cohort
line(cohorts, v(4, 1) * ones(1,4), 'Color',[0.7 0.7 0.7],'Marker','.','LineWidth', 0.15)
line(cohorts, v(4, 2) * ones(2,4), 'Color',[0.7 0.7 0.7],'Marker','.','LineWidth', 0.15)

xlabel('Birth Cohort') 
ylabel(ystr) % y-axis label
ylim([0 1])

f = strcat('~/iec1/output/pn/', fn);
print(f, '-dpng');
copyfile(strcat(f, '.png'), '~/public_html/png');
end
