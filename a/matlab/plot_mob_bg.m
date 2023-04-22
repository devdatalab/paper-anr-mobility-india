% sets the background for the mobility plot -- vertical bin boundaries and moments
function plot_mob_bg(fn, cuts, values)
    hold off

    % calculate the mean value in each cut
    c(1) = cuts(1) / 2;
    for i = 2:length(cuts)
        c(i) = cuts(i-1) + (cuts(i) - cuts(i-1)) / 2;
    end

    % plot the original data
    scatter(c, values, [], 'filled','k');
    hold on

    % plot bin dividers
    for i = 1:length(cuts)
        plot([cuts(i) cuts(i)], [0 100], 'k')
    end

    % set x axis length
    xlim([1 100])
    ylim([0 100])

    % label axes
    xlabel('Parent Rank', 'FontSize', 14) 
    ylabel('Child Rank', 'FontSize', 14)

    % write PNG and PDF files
    write_pdf(fn);
