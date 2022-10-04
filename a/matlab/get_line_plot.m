%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop over all ages, years  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

age_set = [35];

for age = 1:(length(age_set)) 

    for f = {'_sc'  '_gen' ''} 
            
        % load in the data 
        inputname = sprintf('~/iecmerge/paul/mobility/data/age_%d%s.csv',age_set(age), f{1})
        data = csvread(inputname) 

        % get boundaries 
        cuts = read_bins(inputname) 

    % get cuts 
        vals = data(:, 2)';
        bin_means = data(:, 1);

        bin_width(1) = bin_means(1) * 2;
        cuts(1) = bin_width(1);

        for i = 2:length(bin_means)

            start(i) = cuts(i-1);

            width(i) = (bin_means(i) - cuts(i-1)) * 2;

            cuts(i) = cuts(i-1) + width(i);
        end

        cuts = round(cuts)

        % obtain weights from cuts 
        firstelt = cuts(1)'
        differences = diff(cuts)'
        wt = vertcat(firstelt,differences)

        p = polyfitweighted(data(:,1),data(:,2),1,wt)

        % plot and get best fit line 
        clf
        scatter(data(:,1),data(:,2),'filled','k') ; hold on        
        % p = polyfit(data(:,1),data(:,2),1) ;          %

        x1 = linspace(0,100) 
        y1 = polyval(p,x1)

        line(x1,y1,'Color','k') 
        % print 
        axis([0 100 0 100]) 

        % boundaries 
             for i = 1:length(cuts)
                 plot([cuts(i) cuts(i)], [0 100], 'k')
             end



        graphname = sprintf('~/public_html/png/mob_%d%s_6.png',age_set(age),f{1})
        print(graphname, '-dpng');



    end 

end 

command = 'cp ~/public_html/png/mob*_6.png ~/iec1/output/pn/ '
status = dos(command) 


