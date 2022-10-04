function plot_file(fn, x)

    % calculate p_skip
    p_skip = 100 / length(x);

    % shift all points left by 0.5, e.g. because x(1) is the mean bound for all data points in [0,1] interval
    plot((0.5*p_skip):p_skip:(100-0.5*p_skip), x, 'k');
    
    % print in PDF and PNG
    write_pdf(fn);
