clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SC graph -- p25 and mu50
fn = sprintf('~/iec/output/mobility/figures/p25_mu50_scst');
clf
hold on
hplot_add_refs(46, 42, 0.05);

% plot general cohorts
hplot_cohorts(0.60, 'p25',  'gen', [1 0 0]);
hplot_cohorts(0.30, 'mu50', 'gen', [1 0 0]);

% plot SCST cohorts
hplot_cohorts(0.585, 'p25',  'sc',  [0 0 0], 1);
hplot_cohorts(0.285, 'mu50', 'sc',  [0 0 0], 1);

% title('Absolute Mobility (SC/ST vs General)')
ylim([0 0.65])
xlim([0 50])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 4];

% create a legend manually rather than trying to match it to individual lines here
text(4, .15, 'Non-SC/ST', 'FontUnits', 'points', 'FontSize', 8);
text(4, .12, 'SC/ST', 'FontUnits', 'points', 'FontSize', 8);
plot([.75 3.25], [.15 .15], 'r')
plot([.75 3.25], [.12 .12], 'k')
rectangle('Position', [0 .095 10 .075], 'LineWidth', 0.2)

% add p25, mu50 labels
text(20, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
text(20, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);
write_pdf(fn)


