%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRADIENT IHDS 2005 VS 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = '~/iec/output/mobility/figures/gradient_all_ihds_2005';
clf
hold on
hplot_cohorts(0.30, 'coef', 'all_ihds_2011', [0 0 0 ], 0, [1950 1960 1970]);
hplot_cohorts(0.29, 'coef', 'all_ihds_2005', [0 0 1], 1);

hplot_add_refs(0.300, 0.460, 0.05);
ylim([0 0.35])
xlim([0 1])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 2.5];

% manual legend
text(.04, .10, 'IHDS 2011-12', 'FontUnits', 'points', 'FontSize', 8);
text(.04, .07, 'IHDS 2004-05', 'FontUnits', 'points', 'FontSize', 8);
plot([.0075 .0325], [.10 .10], 'color', [0 0 0] )
plot([.0075 .0325], [.07 .07], 'color', [0 0 1])
rectangle('Position', [0 .045 .18 .075], 'LineWidth', 0.2)
write_pdf(fn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p25, mu50 IHDS 2005 VS 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = '~/iec/output/mobility/figures/p25_mu50_all_ihds_2005';
clf
hold on
hplot_add_refs(46, 42, 0.05);
hplot_cohorts(0.60, 'p25' , 'all_ihds_2011', [0 0 0 ], 1, [1950 1960 1970]);
hplot_cohorts(0.30, 'mu50', 'all_ihds_2011', [0 0 0 ], 1, [1950 1960 1970]);

hplot_cohorts(0.59, 'p25' , 'all_ihds_2005', [0 0 1], 0, [1950 1960 1970]);
hplot_cohorts(0.29, 'mu50', 'all_ihds_2005', [0 0 1], 0, [1950 1960 1970]);

ylim([0 0.65])
xlim([0 50])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 4];

% add p25, mu50 labels
text(25, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
text(25, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);

% manual legend
text(4, .15, 'IHDS 2011-12', 'FontUnits', 'points', 'FontSize', 8);
text(4, .12, 'IHDS 2004-05', 'FontUnits', 'points', 'FontSize', 8);
plot([.75 3.25], [.15 .15], 'k')
plot([.75 3.25], [.12 .12], 'color', [0 0 1])
rectangle('Position', [0 .095 12 .075], 'LineWidth', 0.2)

write_pdf(fn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IHDS 2011: HINDU-ETC, MUSLIMS, SCS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = sprintf('~/iec/output/mobility/figures/p25_mu50_muslim_ihds_2011');
clf
hold on
hplot_add_refs(46, 42, 0.05);

% plot SC/ST cohorts
hplot_cohorts(0.6, 'p25', 'sc_ihds_2011', [0 0 0], 1, [1950 1960 1970 1980], 'o');
hplot_cohorts(0.3, 'mu50','sc_ihds_2011', [0 0 0], 1, [1950 1960 1970 1980], 'o');

% plot Muslim cohorts
hplot_cohorts(0.59, 'p25', 'muslim_ihds_2011', [0 0 1], 1, [1950 1960 1970 1980], '^');
hplot_cohorts(0.29, 'mu50','muslim_ihds_2011', [0 0 1], 1, [1950 1960 1970 1980], '^');

% plot non-SC/ST, non-Muslim cohorts
hplot_cohorts(0.58, 'p25', 'hindu_ihds_2011', [1 0 0], 0);
hplot_cohorts(0.28, 'mu50','hindu_ihds_2011', [1 0 0], 0);


ylim([0 0.65])
xlim([0 55])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 4];

% create legend
text(8, .18, 'SC/ST', 'FontUnits', 'points', 'FontSize', 8);
text(8, .15, 'Muslim', 'FontUnits', 'points', 'FontSize', 8);
text(8, .12, 'All Others', 'FontUnits', 'points', 'FontSize', 8);
plot([2 6], [.18 .18], 'k')
plot([2 6], [.15 .15], 'b')
plot([2 6], [.12 .12], 'r')
scatter([2 6], [.18 .18], 15, 'ko')
scatter([2 6], [.15 .15], 15, 'b^')
plot([2 2], [.12 - .0075 .12 + .0075], 'r');
plot([6 6], [.12 - .0075 .12 + .0075], 'r');


rectangle('Position', [0 .095 15 0.125], 'LineWidth', 0.2)

% add p25, mu50 labels
text(20, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
text(20, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);
write_pdf(fn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IHDS 2011: MUSLIMS/SCS/EVERYONE MU-50-100 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = sprintf('~/iec/output/mobility/figures/p75_muslim_ihds_2011');
clf
hold on

% plot non-SC/ST, non-Muslim cohorts
hplot_cohorts(0.60, 'p75', 'hindu_ihds_2011');
hplot_cohorts(0.30, 'mu100','hindu_ihds_2011');

% plot SC/ST cohorts
hplot_cohorts(0.585, 'p75', 'sc_ihds_2011', [1 0 0], 1, [1950 1960 1970 1980], 'o');
hplot_cohorts(0.285, 'mu100','sc_ihds_2011', [1 0 0], 1, [1950 1960 1970 1980], 'o');

% plot Muslim cohorts
hplot_cohorts(0.57, 'p75', 'muslim_ihds_2011', [0 0 1], 1, [1950 1960 1970 1980], '^');
hplot_cohorts(0.27, 'mu100','muslim_ihds_2011', [0 0 1], 1, [1950 1960 1970 1980], '^');

ylim([0 0.65])
xlim([45 100])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 4];

% create legend
text(91, .18, 'All Others', 'FontUnits', 'points', 'FontSize', 8);
text(91, .15, 'SC/ST', 'FontUnits', 'points', 'FontSize', 8);
text(91, .12, 'Muslim', 'FontUnits', 'points', 'FontSize', 8);
plot(   [85 89], [.18 .18], 'k')
plot(   [85 89], [.15 .15], 'r')
plot(   [85 89], [.12 .12], 'b')
scatter([85 89], [.15 .15], 15, 'ro')
scatter([85 89], [.12 .12], 15, 'b^')
plot(   [85 85], [.18 - .0075 .18 + .0075], 'k');
plot(   [89 89], [.18 - .0075 .18 + .0075], 'k');
rectangle('Position', [0 .095 15 0.125], 'LineWidth', 0.2)

% add p25, mu50 labels
text(45, .525, 'p_{75}', 'FontUnits', 'points', 'FontSize', 12);
text(45, .225, '\mu_{50}^{100}', 'FontUnits', 'points', 'FontSize', 12);

write_pdf(fn)

% %%%%%%%%%%%%%%%%%%%
% % EARNINGS, WAGES %
% %%%%%%%%%%%%%%%%%%%
% % p25, mu50
% fn = '~/iec/output/mobility/figures/all_p25_earnings';
% clf
% hold on
% hplot_add_refs(46, 42, 0.05);
% hplot_cohorts(0.60, 'p25', 'all_ihds_wages');
% hplot_cohorts(0.30, 'mu50','all_ihds_wages');
% hplot_cohorts(0.58, 'p25', 'all_ihds_earnings', 'r', 1);
% hplot_cohorts(0.28, 'mu50','all_ihds_earnings', 'r', 1);
% ylim([0 0.65])
% xlim([0 50])
% fig = gcf;
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 8 4];
% 
% % add stat labels: p25, mu50, coef
% text(25, .825, 'gradient', 'FontUnits', 'points', 'FontSize', 12);
% text(25, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
% text(25, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);
% 
% % manual legend
% text(4, .15, 'Wages', 'FontUnits', 'points', 'FontSize', 8);
% text(4, .12, 'Earnings', 'FontUnits', 'points', 'FontSize', 8);
% plot([.75 3.25], [.15 .15], 'k')
% plot([.75 3.25], [.12 .12], 'color', [1 0 0])
% rectangle('Position', [0 .095 12 .075], 'LineWidth', 0.2)
% write_pdf(fn)
% 
% % coef
% % p25, mu50
% fn = '~/iec/output/mobility/figures/all_gradient_earnings';
% clf
% hold on
% hplot_add_refs(0.300, 0.460, 0.05);
% hplot_cohorts(0.60, 'coef', 'all_ihds_wages');
% hplot_cohorts(0.58, 'coef', 'all_ihds_earnings', 'r', 1);
% ylim([0 0.65])
% xlim([0 1.0])
% fig = gcf;
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 8 4];
% 
% 
% % manual legend
% text(.04, .15, 'Wages', 'FontUnits', 'points', 'FontSize', 8);
% text(.04, .12, 'Earnings', 'FontUnits', 'points', 'FontSize', 8);
% plot([.0075 .0325], [.15 .15], 'k')
% plot([.0075 .0325], [.12 .12], 'color', [1 0 0])
% rectangle('Position', [0 .095 .12 .075], 'LineWidth', 0.2)
% write_pdf(fn)
% 
% return
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE GRADIENT GRAPH FOR IHDS 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = '~/iec/output/mobility/figures/gradient_all_ihds_2011';
clf
hold on
hplot_cohorts(0.30, 'coef', 'all_ihds_2011');
hplot_add_refs(0.300, 0.460, 0.05);
ylim([0 0.35])
xlim([0 1])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 2.5];
write_pdf(fn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE p25 AND mu50 GRAPH FOR IHDS 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = '~/iec/output/mobility/figures/p25_mu50_all_ihds_2011';
clf
hold on
hplot_add_refs(46, 42, 0.05);
hplot_cohorts(0.60, 'p25', 'all_ihds_2011');
hplot_cohorts(0.30, 'mu50','all_ihds_2011');
ylim([0 0.65])
xlim([0 50])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 4];

% add p25, mu50 labels
text(25, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
text(25, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);
write_pdf(fn)
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % CREATE SC/ST p25 / mu50 GRAPH FOR IHDS 2011
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fn = sprintf('~/iec/output/mobility/figures/p25_mu50_scst_ihds_2011');
% clf
% hold on
% hplot_add_refs(46, 42, 0.05);
% 
% % plot general cohorts
% hplot_cohorts(0.60, 'p25', 'gen_ihds_2011');
% hplot_cohorts(0.30, 'mu50','gen_ihds_2011');
% 
% % plot SC/ST cohorts
% hplot_cohorts(0.585, 'p25', 'sc_ihds_2011', 'r', 1);
% hplot_cohorts(0.285, 'mu50','sc_ihds_2011', 'r', 1);
% 
% ylim([0 0.65])
% xlim([0 50])
% fig = gcf;
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 8 4];
% 
% % create legend
% text(4, .15, 'Non-SC/ST', 'FontUnits', 'points', 'FontSize', 8);
% text(4, .12, 'SC/ST', 'FontUnits', 'points', 'FontSize', 8);
% plot([.75 3.25], [.15 .15], 'k')
% plot([.75 3.25], [.12 .12], 'r')
% rectangle('Position', [0 .095 10 .075], 'LineWidth', 0.2)
% 
% % add p25, mu50 labels
% text(20, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
% text(20, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);
% write_pdf(fn)



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % SCST vs NON-SCST vs MUSLIM, IHDS 2005 vs IHDS 2011 -- NOT USED ANYMORE NOW THAT WE HAVE THE MUSLIM GRAPH
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % SC graph -- p25 and mu50
% fn = sprintf('~/iec/output/mobility/figures/p25_mu50_scst_ihds_2005');
% clf
% hold on
% hplot_add_refs(46, 42, 0.05);
% 
% % plot IHDS 2011-12 cohorts in black and red
% hplot_cohorts(0.600,  'p25', 'gen_ihds_2011');
% hplot_cohorts(0.300,  'mu50','gen_ihds_2011');
% hplot_cohorts(0.595,  'p25', 'sc_ihds_2011', 'r', 1);
% hplot_cohorts(0.295,  'mu50','sc_ihds_2011', 'r', 1);
% 
% % plot IHDS 2004-05 cohorts in green and blue
% hplot_cohorts(0.59,  'p25', 'gen_ihds_2005', [0 .5 0], 1);
% hplot_cohorts(0.29,  'mu50', 'gen_ihds_2005',  [0 .5 0], 1);
% hplot_cohorts(0.585, 'p25', 'sc_ihds_2005', [0 0 1], 1);
% hplot_cohorts(0.285, 'mu50', 'sc_ihds_2005',  [0 0 1], 1);
% 
% ylim([0 0.65])
% xlim([0 50])
% fig = gcf;
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 8 4];
% 
% % create legend
% text(4, .21, 'Non-SC/ST, IHDS 2010-11', 'FontUnits', 'points', 'FontSize', 8);
% text(4, .18, 'SC/ST, IHDS 2010-11',     'FontUnits', 'points', 'FontSize', 8);
% text(4, .15, 'Non-SC/ST, IHDS 2004-05', 'FontUnits', 'points', 'FontSize', 8);
% text(4, .12, 'SC/ST, IHDS 2004-05',     'FontUnits', 'points', 'FontSize', 8);
% plot([.75 3.25], [.21 .21], 'k')
% plot([.75 3.25], [.18 .18], 'r')
% plot([.75 3.25], [.15 .15], 'color', [0 .5 0])
% plot([.75 3.25], [.12 .12], 'color', [0 0 1])
% rectangle('Position', [0 .095 17 .135], 'LineWidth', 0.2)
% 
% % add p25, mu50 labels
% text(20, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
% text(20, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);
% write_pdf(fn)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IHDS 2011: HINDU-ETC, MUSLIMS, SCS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = sprintf('~/iec/output/mobility/figures/p25_mu50_muslim_ihds_2005');
clf
hold on
hplot_add_refs(46, 42, 0.05);

% plot non-SC/ST, non-Muslim cohorts
hplot_cohorts(0.605, 'p25', 'hindu_ihds_2005', [.25 .25 .25], 1, [1950 1960 1970]);
hplot_cohorts(0.305, 'mu50','hindu_ihds_2005', [.25 .25 .25], 1, [1950 1960 1970]);

hplot_cohorts(0.60, 'p25', 'hindu_ihds_2011', [0 0 0], 1, [1950 1960 1970]);
hplot_cohorts(0.30, 'mu50','hindu_ihds_2011', [0 0 0], 1, [1950 1960 1970]);

% plot SC/ST cohorts
hplot_cohorts(0.590, 'p25', 'sc_ihds_2005', [1 0.25 0.25], 1, [1950 1960 1970], 'o');
hplot_cohorts(0.290, 'mu50','sc_ihds_2005', [1 0.25 0.25], 1, [1950 1960 1970], 'o');

hplot_cohorts(0.585, 'p25', 'sc_ihds_2011', [1 0 0], 1, [1950 1960 1970], 'o');
hplot_cohorts(0.285, 'mu50','sc_ihds_2011', [1 0 0], 1, [1950 1960 1970], 'o');

% plot Muslim cohorts
hplot_cohorts(0.575, 'p25', 'muslim_ihds_2005', [.25 .25 1], 1, [1950 1960 1970], '^');
hplot_cohorts(0.275, 'mu50','muslim_ihds_2005', [.25 .25 1], 1, [1950 1960 1970], '^');
hplot_cohorts(0.57, 'p25', 'muslim_ihds_2011', [0 0 1], 1, [1950 1960 1970], '^');
hplot_cohorts(0.27, 'mu50','muslim_ihds_2011', [0 0 1], 1, [1950 1960 1970], '^');

ylim([0 0.65])
xlim([0 55])
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 4];

% create legend
text(8, .18, 'All Others', 'FontUnits', 'points', 'FontSize', 8);
text(8, .15, 'SC/ST', 'FontUnits', 'points', 'FontSize', 8);
text(8, .12, 'Muslim', 'FontUnits', 'points', 'FontSize', 8);
plot([2 6], [.18 .18], 'k')
plot([2 6], [.15 .15], 'r')
plot([2 6], [.12 .12], 'b')
scatter([2 6], [.15 .15], 15, 'ro')
scatter([2 6], [.12 .12], 15, 'b^')
plot([2 2], [.18 - .0075 .18 + .0075], 'k');
plot([6 6], [.18 - .0075 .18 + .0075], 'k');

rectangle('Position', [0 .095 15 0.125], 'LineWidth', 0.2)

% add p25, mu50 labels
text(20, .525, 'p_{25}', 'FontUnits', 'points', 'FontSize', 12);
text(20, .225, '\mu_{0}^{50}', 'FontUnits', 'points', 'FontSize', 12);
write_pdf(fn)
