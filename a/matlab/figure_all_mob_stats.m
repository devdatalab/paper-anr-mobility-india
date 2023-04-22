% GOAL: GENERATE A FIGURE WITH ALL MOBILITY STAT CHANGES OVER TIME
%  - each plot shows four coefficient bounds for four decades
%  - 3 plots horizontally for three measures: (i) p25; (ii) mu50; and (iii) beta (rank-rank coef)

%%%%%%%%%%%%%%%%%%%%%%%%
% create gradient graph
%%%%%%%%%%%%%%%%%%%%%%%%

fn = '~/iec/output/mobility/figures/gradient_all';
clf
hold on
hplot_add_refs(0.300, 0.460, 0.05);
hplot_cohorts(0.30, 'coef', 'all', [0 0 0], 0);

ylim([0 0.35])
xlim([0 1])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 2.5];
write_pdf(fn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create p25 and mu50 graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = '~/iec/output/mobility/figures/p25_mu50_all';
clf
hold on

hplot_add_refs(46, 42, 0.05);

hplot_cohorts(0.60, 'p25',  'all', [0 0 0], 0);
hplot_cohorts(0.30, 'mu50', 'all', [0 0 0], 0);

ylim([0 0.65])
xlim([0 50])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 4];

% add p25, mu50 labels
text(25, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
text(25, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);
write_pdf(fn)


