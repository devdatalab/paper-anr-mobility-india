% this set of numbers to get maximum smoothness in areas with weirdest behavior
f2_set = [.1 .05 .01 .005 .003 .001 .0008 .0005 .0003 .0002 .00015 .0001 .000095 .00009 .00008 .00005 .00003 .00001 0];
f2_set = [1000 0.12 0.03 0.015 0];
    
for i = 1:length(f2_set)
    fprintf('Calculating bounds, f2=%d...\n', f2_set(i))
    bounds(i, :) = bound_reg_coef('~/iecmerge/paul/mobility/data/age_35.csv', f2_set(i));
end

% rescale f2 set limits so it prints better
f2_set(5) = 0.001;
f2_set(1) = 1;

hold off
plot(f2_set, bounds(:, 1))
hold on
plot(f2_set, bounds(:, 2))
set(gca, 'XScale', 'log')

% add axis labels and y limits
xlabel('Curvature Constraint') 
ylabel('Father-Son Rank Elasticity') % y-axis label
ylim([0.30 0.70])

write_pdf('~/iec1/output/pn/reg_bounds');

% calculate young and old bounds under optimal restriction
reg_bound_young = bound_reg_coef('~/iecmerge/paul/mobility/data/age_25.csv', 0.12);
reg_bound_old   = bound_reg_coef('~/iecmerge/paul/mobility/data/age_55.csv', 0.12);

reg_bound_young
reg_bound_old
