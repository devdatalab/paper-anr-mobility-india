% Take a CSV file with mean ranks and output values, and convert it to a cut and value vector
function [cuts, vals] = read_bins(fn)

% example source file:
% 18.243258,35.063016
% 42.220008,41.685656
% 56.392562,51.044887
% 71.468472,58.845616
% 83.880115,69.198436
% 92.134458,74.009257
% 97.306955,80.539866

% produces the following discrete integer bins
% 1-36:   35.06
% 37-47:  41.69
% 48-62:  51.04
% 63-79:  58.84
% 80-88:  69.20
% 89-94:  74.01
% 95-100: 80.54

%     fn = sprintf('~/iecmerge/paul/mobility/data/age_25.csv') 
%     fn = sprintf('~/iec1/mobility/denmark_censored.csv') 

    data = csvread(fn, 1, 0);

    % store Y values -- this part is easy
    vals = data(:, 2)';
    bin_means = data(:, 1);

    bin_width(1) = bin_means(1) * 2;
    cuts(1) = bin_width(1);

    for i = 2:length(bin_means)

        width(i) = (bin_means(i) - cuts(i-1)) * 2;

        cuts(i) = cuts(i-1) + width(i);
    end

    cuts = round(cuts);
    %    vals = round (vals * 100); 


