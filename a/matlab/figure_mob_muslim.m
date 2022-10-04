%%%%%%%%%%%%%%%%%% FIGURE: SCST vs MUSLIM vs OTHERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Panel A: show the data
% Panels B->D: non-parametric bounds for various f2 restrictions

bc_set = [1980 1970 1960 1950];
cohort_set = {'1980-1989' '1970-1979' '1960-1969' '1950-1959'};

%%%%%%%%%%%%%%%
% OVERRIDES
%%%%%%%%%%%%%%%
% bc_set = [1980 1950];
% cohort_set = {'1980-1989' '1950-1959'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALL 3 GROUPS ON SAME GRAPH
% FOR EACH COHORT:
% 1. POINTS ONLY
% 2. CEF BOUNDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loop over all bc groups
for i = 1:length(bc_set)
    bc = bc_set(i);
    cohort_str_hindu =     sprintf('%s cohort, All Others', cohort_set{i});
    cohort_str_sc =      sprintf('%s cohort, SC/STs', cohort_set{i});
    cohort_str_muslim =  sprintf('%s cohort, Muslims', cohort_set{i});

    moment_csv_hindu =    sprintf('~/iec/output/mobility/moments/hindu_ihds_2011_%d.csv', bc);
    moment_csv_sc  =    sprintf('~/iec/output/mobility/moments/sc_ihds_2011_%d.csv' , bc);
    moment_csv_muslim = sprintf('~/iec/output/mobility/moments/muslim_ihds_2011_%d.csv', bc);
    
    [cuts_hindu, vals_hindu] = read_bins(moment_csv_hindu);
    [cuts_sc, vals_sc] = read_bins(moment_csv_sc);
    [cuts_muslim, vals_muslim] = read_bins(moment_csv_muslim);
    
    % show the 25 plots (copy/paste from plot_mob_bg.m)
    clf
    
    % plot the bin dividers
    for i = 1:length(cuts_hindu)
        plot([cuts_hindu(i) cuts_hindu(i)], [0 100], 'k')
    end

    % set x axis length
    xlim([1 100])
    ylim([0 100])

    hold on

    % PLOT GENERALS
    % calculate the mean value in each cut
    c(1) = cuts_hindu(1) / 2;
    for i = 2:length(cuts_hindu)
        c(i) = cuts_hindu(i-1) + (cuts_hindu(i) - cuts_hindu(i-1)) / 2;
    end
    
    % plot the original data
    c_hindu = scatter(c, vals_hindu, 'r');
    
    % PLOT SCS (different marker style)
    c(1) = cuts_sc(1) / 2;
    for i = 2:length(cuts_sc)
        c(i) = cuts_sc(i-1) + (cuts_sc(i) - cuts_sc(i-1)) / 2;
    end
    c_sc = scatter(c, vals_sc, [], 'x', 'MarkerEdgeColor', [0 0 0]);
    
    % PLOT MUSLIMS (different marker style)
    c(1) = cuts_muslim(1) / 2;
    for i = 2:length(cuts_muslim)
        c(i) = cuts_muslim(i-1) + (cuts_muslim(i) - cuts_muslim(i-1)) / 2;
    end
    c_muslim = scatter(c, vals_muslim, [], '^', 'MarkerEdgeColor', [0 0 1]);
    
    % add a legend
    h_legend = legend([c_sc c_muslim c_hindu], cohort_str_sc, cohort_str_muslim, cohort_str_hindu, 'Location', 'southeast');
    set(h_legend, 'FontSize', 14);
    
    % send to a file
    fn = sprintf('~/iec/output/mobility/figures/%s_%d', 'fig_muslim_panel_a', bc);
    write_pdf(fn);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create SC vs. Muslim vs. Others graph for this bc, one for each f2 limit
    % for i = [10 5 0]
    for i = [10]
        fn1 = sprintf('~/iec/output/mobility/bounds/bounds_hindu_ihds_2011_%d_%d.csv', bc, i);
        fn2 = sprintf('~/iec/output/mobility/bounds/bounds_sc_ihds_2011_%d_%d.csv',  bc, i);
        fn3 = sprintf('~/iec/output/mobility/bounds/bounds_muslim_ihds_2011_%d_%d.csv',  bc, i);
        overlay_p_bounds({fn2 fn3 fn1}, {cohort_str_sc cohort_str_muslim cohort_str_hindu });
        fn = sprintf('~/iec/output/mobility/figures/fig_muslim_%d_%d', bc, i);
        write_pdf(fn);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now create 25 vs. 55 separately for SC/STs, Muslims, all others, one for each f2 limit
% for i = [10 5 0]
for f2 = [10]
    % ALL OTHERS
    fn1 = sprintf('~/iec/output/mobility/bounds/bounds_hindu_ihds_2011_1980_%d.csv', f2);
    fn2 = sprintf('~/iec/output/mobility/bounds/bounds_hindu_ihds_2011_1950_%d.csv', f2);
    overlay_p_bounds({fn1 fn2}, {'1980-1989 cohort, All Others' '1950-1959 cohort, All Others'});
    fn = sprintf('~/iec/output/mobility/bounds/fig_time_hindu_%d', f2);
    write_pdf(fn)

    % SCSTs
    fn1 = sprintf('~/iec/output/mobility/bounds/bounds_sc_ihds_2011_1980_%d.csv', f2);
    fn2 = sprintf('~/iec/output/mobility/bounds/bounds_sc_ihds_2011_1950_%d.csv', f2);
    overlay_p_bounds({fn1 fn2}, {'1980-1989 cohort, SC/STs' '1950-1959 cohort, SC/STs'});
    fn = sprintf('~/iec/output/mobility/figures/fig_time_sc_%d', f2);
    write_pdf(fn)

    % MUSLIMS
    fn1 = sprintf('~/iec/output/mobility/bounds/bounds_muslim_ihds_2011_1980_%d.csv', f2);
    fn2 = sprintf('~/iec/output/mobility/bounds/bounds_muslim_ihds_2011_1950_%d.csv', f2);
    overlay_p_bounds({fn1 fn2}, {'1980-1989 cohort, Muslims' '1950-1959 cohort, Muslims'});
    fn = sprintf('~/iec/output/mobility/figures/fig_time_muslim_%d', f2);
    write_pdf(fn)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% repeat for 45 vs. 25 and 35 vs. 25 in case they are more precise
for a = [2 3]
    bc = bc_set(a);
    old_cohort_str_hindu = sprintf('%s cohort, All Others', cohort_set{a});
    old_cohort_str_sc = sprintf('%s cohort, SC/STs', cohort_set{a});
    old_cohort_str_muslim = sprintf('%s cohort, Muslims', cohort_set{a});

    % for i = [10 5 0]
    for f2 = [10]
        fn1 = sprintf('~/iec/output/mobility/bounds/bounds_hindu_ihds_2011_1980_%d.csv', f2);
        fn2 = sprintf('~/iec/output/mobility/bounds/bounds_hindu_ihds_2011_%d_%d.csv', bc, f2);
        overlay_p_bounds({fn1 fn2}, {'1980-1989 cohort, All Others' old_cohort_str_hindu});
        fn = sprintf('~/iec/output/mobility/figures/fig_time_%d_hindu_ihds_2011_%d', bc, f2);
        write_pdf(fn);
    
        fn1 = sprintf('~/iec/output/mobility/bounds/bounds_sc_ihds_2011_1980_%d.csv', f2);
        fn2 = sprintf('~/iec/output/mobility/bounds/bounds_sc_ihds_2011_%d_%d.csv', bc, f2);
        overlay_p_bounds({fn1 fn2}, {'1980-1989 cohort, SC/STs' old_cohort_str_sc});
        fn = sprintf('~/iec/output/mobility/figures/fig_time_%d_sc_%d', bc, f2);
        write_pdf(fn);

        fn1 = sprintf('~/iec/output/mobility/bounds/bounds_muslim_ihds_2011_1980_%d.csv', f2);
        fn2 = sprintf('~/iec/output/mobility/bounds/bounds_muslim_ihds_2011_%d_%d.csv', bc, f2);
        overlay_p_bounds({fn1 fn2}, {'1980-1989 cohort, Muslims' old_cohort_str_muslim});
        fn = sprintf('~/iec/output/mobility/figures/fig_time_%d_muslim_%d', bc, f2);
        write_pdf(fn);
    end
end
