% given a set of X variable means (e.g. mean father ranks within father bins), 
%   return an integer vector of cuts, where the last cut is 100
function [cuts] = get_cuts_from_means(bin_means)

    bin_width(1) = bin_means(1) * 2;
    cuts(1) = bin_width(1);

    for i = 2:length(bin_means)
        width(i) = (bin_means(i) - cuts(i-1)) * 2;
        cuts(i) = cuts(i-1) + width(i);
    end

    cuts = round(cuts);
