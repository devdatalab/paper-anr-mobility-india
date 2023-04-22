%% Figure: raw moments plus two sample CEFs
%% targets: fig_example_cef_1960
fprintf('\nCalling figure_example_cef() to generate fig_example_cef_1960.pdf...\n')
figure_example_cef

%% Calculate 1960 and 1980 CEFs under Cbar=10 and Cbar=inf [VERY SLOW -- ~40 minutes]
%% This needs to be run before figure_mob_time.m
gen_all_mob_bounds

%% Figure: Moments over time with bin boundaries
%%         [commented in figure file: bounds on CEFs for full-sample changes (fig_time_1950_10)]
%% - fig_time_1960_1980
fprintf('\nCalling figure_mob_time() to generate fig_time_1960_1980.pdf...\n')
figure_mob_time

%% Calculate all mobility statistics (p25, mu50, coef) and store them in the bounds/ folder.
calc_all_mob_stats



quit
quit
quit

%% everything below here is from prior versions.











%% now bootstrap all those same stats. Takes 1000x longer...
%% bootstrap_all_mob_stats







%% Figure: All mobility statistics, all cohorts
%% targets:
%% - 1950_gradient.png
%% - 1950_p25_mu50.png
clear all
fprintf('\nCalling figure_all_mob_stats()...\n')
figure_all_mob_stats



%% Figure: 

%% Figure 2-B: 2 The jumpy CEFs that bound p25 when c-bar = infinity
%% targets: fig_example_bounds_1960_b
%% fprintf('\nCalling figure_example_bounds()...\n')
%% figure_example_bounds

%% Figure 2-A, Figure 3
%% very slow -- generate all mobility bounds
%% targets:
%% - bounds_%s_%d_%s, (all|sc|gen), [birth cohort], f2
%% - 2A: bounds_all_1960_25000
%% - 3A: bounds_all_1960_20
%% - 3B: bounds_all_1960_10
%% - 3C: bounds_all_1960_5
%% - 3D: bounds_all_1960_0
%% gen_all_mob_bounds

%% Figure 4 -- bootstrap graph -- update to 1960 cohort
%% ??

%% Figure 5 -- rank distributions for USA, Sweden, Denmark, Norway
%% ??

%% Figure 6 -- Danish bounding simulation
%% ??

%% Figure 9A,B -- SC/ST vs Generals -- FIX: Change from 1951 to 1950 when finishes running
%% targets:
%% - A: fig_sc_1950_10.png
%% - B: fig_sc_1980_10.png
clear all
fprintf('\nCalling figure_mob_scst()...\n')
figure_mob_scst

%% Figure 9C -- SC/ST p25 and mu50
%% - target: scst_p25_mu50_1951.png
clear all
fprintf('\nCalling figure_scst_stats()...\n')
figure_scst_stats


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% APPENDIX FIGURES
%% Figure ?? -- mu and p estimates at different levels of the distribution
%% - targets: all_p_mu.png
%%            output/mobility/bounds/all_p_mu.csv
%%            output/mobility/all_p_mu.tex
calc_p_mu

