% read a set of p-level output files (from get_mob_bounds()), and plot them on the same graph
function overlay_p_bounds(input_fn_set, legend_set)

ds1 = csvread(input_fn_set{1});
ds2 = csvread(input_fn_set{2});

num_functions = length(input_fn_set);

% if there's a 3rd function
if num_functions >= 3
    ds3 = csvread(input_fn_set{3});
end


% HACK --= THIS ASSUMES THE DATA ARE INCORRECTLY SCALED FROM 0 TO 1. REMOVE 100* ONCE WE FIX THE DATA FILES.
if ds1(50, 3) <= 1
    p_min1 = 100 * ds1(:, 3);
    p_max1 = 100 * ds1(:, 4);
    p_min2 = 100 * ds2(:, 3);
    p_max2 = 100 * ds2(:, 4);
else
    p_min1 = ds1(:, 3);
    p_max1 = ds1(:, 4);
    p_min2 = ds2(:, 3);
    p_max2 = ds2(:, 4);

    if num_functions >= 3
        p_min3 = ds3(:, 3);
        p_max3 = ds3(:, 4);
    end
end

% draw the first graph
hold off
p(1) = plot((0.5*1):1:(100-0.5*1), p_min1, 'k');
hold on
plot((0.5*1):1:(100-0.5*1), p_max1, 'k');

% draw the 2nd graph
p(2) = plot((0.5*1):1:(100-0.5*1), p_min2, ':', 'Color', 'b');
plot((0.5*1):1:(100-0.5*1), p_max2, ':', 'Color', 'b');

% draw the 3rd graph, if requested
if num_functions >= 3
    p(3) = plot((0.5*1):1:(100-0.5*1), p_min3, '--', 'Color', 'r');
    plot((0.5*1):1:(100-0.5*1), p_max3, '--', 'Color', 'r');
end

% set the axes
xlim([1 100])
ylim([0 100])

% add axis labels
xlabel('Parent Rank', 'FontSize', 14);
ylabel('Child Rank', 'FontSize', 14);

% show legend
if num_functions == 2
    h_legend = legend(p, legend_set{1}, legend_set{2}, 'Location', 'southeast');
elseif num_functions == 3
    h_legend = legend(p, legend_set{1}, legend_set{2}, legend_set{3}, 'Location', 'southeast');
end

set(h_legend, 'FontSize', 14);
