%%%%%%%%%%%%%%%%%% FIGURE: SCST vs non_SCST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Panel A: show the data
% Panels B->D: non-parametric bounds for various f2 restrictions

bc_set = [1980 1970 1960 1950];
cohort_set = {'1980-1989' '1970-1979' '1960-1969' '1950-1959'};

%%%%%%%%%%%%%%%
% OVERRIDES
%%%%%%%%%%%%%%%
bc_set = [1980 1950];
cohort_set = {'1980-1989' '1950-1959'};

%%%%%%%%%%
% PANEL A
%%%%%%%%%%

% loop over all bc groups
for i = 1:length(bc_set)
    bc = bc_set(i);
    cohort_str_gen = sprintf('%s cohort, Non-SC/ST', cohort_set{i});
    cohort_str_sc =  sprintf('%s cohort, SC/ST', cohort_set{i});

    moment_csv_gen = sprintf('~/iec/output/mobility/moments/gen_%d.csv', bc);
    moment_csv_sc  = sprintf('~/iec/output/mobility/moments/sc_%d.csv' , bc);
    
    [cuts_gen, vals_gen] = read_bins(moment_csv_gen);
    [cuts_sc, vals_sc] = read_bins(moment_csv_sc);
    
    % show the 25 plots (copy/paste from plot_mob_bg.m)
    hold off
    
    % calculate the mean value in each cut
    c(1) = cuts_gen(1) / 2;
    for i = 2:length(cuts_gen)
        c(i) = cuts_gen(i-1) + (cuts_gen(i) - cuts_gen(i-1)) / 2;
    end
    
    % plot the original data
    c_gen = scatter(c, vals_gen, 'k');
    hold on
    
    % set x axis length
    xlim([1 100])
    ylim([0 100])
    
    % plot the bin dividers
    for i = 1:length(cuts_gen)
        plot([cuts_gen(i) cuts_gen(i)], [0 100], 'k')
    end
    
    % repeat for the 25_scs, but with different line styles
    
    % calculate the mean value in each cut
    c(1) = cuts_sc(1) / 2;
    for i = 2:length(cuts_sc)
        c(i) = cuts_sc(i-1) + (cuts_sc(i) - cuts_sc(i-1)) / 2;
    end
    
    % plot the data
    c_sc = scatter(c, vals_sc, [], 'x', 'MarkerEdgeColor', [.25 .25 .25]);
    
    % same bin dividers, so no need to replot
    % plot([cuts_sc(1) cuts_sc(1)], [0 1], '--', 'Color', 'k')
    
    % add a legend
    h_legend = legend([c_gen c_sc], cohort_str_gen, cohort_str_sc, 'Location', 'southeast');
    set(h_legend, 'FontSize', 14);
    
    % send to a file
    fn = sprintf('~/iec/output/mobility/figures/%s_%d', 'fig_sc_panel_a', bc);
    write_pdf(fn);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create SC vs. General graph for this bc, one for each f2 limit
    % for i = [10 5 0]
    for i = [10]
        fn1 = sprintf('~/iec/output/mobility/bounds/bounds_gen_%d_%d.csv', bc, i);
        fn2 = sprintf('~/iec/output/mobility/bounds/bounds_sc_%d_%d.csv',  bc, i);
        overlay_p_bounds({fn1 fn2}, {cohort_str_gen cohort_str_sc});
        fn = sprintf('~/iec/output/mobility/figures/fig_sc_%d_%d', bc, i);
        write_pdf(fn);
    end
end

%%%%%%%%%%%%%%
% PANELS B-D %
%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now create 25 vs. 55 separately for SC/STs and generals, one for each f2 limit
% for i = [10 5 0]
for i = [10]
    fn1 = sprintf('~/iec/output/mobility/bounds/bounds_gen_1981_%d.csv', i);
    fn2 = sprintf('~/iec/output/mobility/bounds/bounds_gen_1951_%d.csv', i);
    overlay_p_bounds({fn1 fn2}, {'1980-1989 cohort, Non-SC/ST' '1950-1959 cohort, Non-SC/ST'});
    fn = sprintf('~/iec/output/mobility/bounds/fig_time_gen_%d', i);
    write_pdf(fn)

    fn1 = sprintf('~/iec/output/mobility/bounds/bounds_sc_1981_%d.csv', i);
    fn2 = sprintf('~/iec/output/mobility/bounds/bounds_sc_1951_%d.csv', i);
    overlay_p_bounds([fn1 fn2], ['1980-1989 cohort, SC/ST' '1950-1959 cohort, SC/ST']);
    fn = sprintf('~/iec/output/mobility/figures/fig_time_sc_%d', i);
    write_pdf(fn)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% repeat for 45 vs. 25 and 35 vs. 25 in case they are more precise
for a = [2 3]
    bc = bc_set(a);
    old_cohort_str_gen = sprintf('%s cohort, Non-SC/ST', cohort_set{a});
    old_cohort_str_sc = sprintf('%s cohort, SC/ST', cohort_set{a});

    % for i = [10 5 0]
    for i = [10]
        fn1 = sprintf('~/iec/output/mobility/bounds/bounds_gen_1981_%d.csv', i);
        fn2 = sprintf('~/iec/output/mobility/bounds/bounds_gen_%d_%d.csv', bc, i);
        overlay_p_bounds([fn1 fn2], ['1980-1989 cohort, Non-SC/ST' old_cohort_str_gen]);
        fn = sprintf('~/iec/output/mobility/figures/fig_time_%d_gen_%d', bc, i);
        write_pdf(fn);
    
        fn1 = sprintf('~/iec/output/mobility/bounds/bounds_sc_1981_%d.csv', i);
        fn2 = sprintf('~/iec/output/mobility/bounds/bounds_sc_%d_%d.csv', bc, i);
        overlay_p_bounds([fn1 fn2], ['1980-1989 cohort, SC/ST' old_cohort_str_sc]);
        fn = sprintf('~/iec/output/mobility/figures/fig_time_%d_sc_%d', bc, i);
        write_pdf(fn);
    end
end
