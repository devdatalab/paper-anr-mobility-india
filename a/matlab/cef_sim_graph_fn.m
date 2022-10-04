%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % internal function plot_cef  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_cef(cef,moment,spline,graph_fn,expand); 

        clf 
        % get CEF data 
        if expand == 1
            cef_data = csvread(cef,1)
            rank = 2*cef_data(:,2)-1
            lb = 100000-cef_data(:,4)
            ub = 100000-cef_data(:,3)
        else 
            cef_data = csvread(cef,1)
            rank = cef_data(:,1)
            lb = 100000-cef_data(:,2)
            ub = 100000-cef_data(:,3)
        end

        % get moments 
        moment_data = csvread(moment,1)
        scatter_rank = moment_data(:,1)
        moment = 100000-moment_data(:,2) 

        % plot splines 
        spline_data = csvread(spline,1)
        spline_rank = spline_data(:,1)
        spline_y = 100000-spline_data(:,2)

        % plot 
        hold on
        plot(rank,ub,'Color','k','DisplayName','Implied Bounds')
        plot(spline_rank, spline_y,'--','Color','b','DisplayName','True Spline')
        scatter(scatter_rank,moment,'filled','k','DisplayName','Censored Data') 

        ylim([0 2000])
        axis([0 100 0 2000])
        xlabel('Education Rank')
        ylabel('Deaths/100,000')

        % only plot the legend if analytical 
        if expand ~= 1 
            legend('show') 
            legend boxoff
        end 

        plot(rank,lb,'Color','k')
        hold off 

        set(gca,'fontsize',25) 



        write_pdf(graph_fn) 




