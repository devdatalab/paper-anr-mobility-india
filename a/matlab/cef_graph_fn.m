%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % internal function plot_cef  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_cef(cef,moment,graph_fn,expand); 

        clf 
        % get CEF data 

        if isequal(expand,1) == 1 
            mutype = 2
        else 
            mutype = 1 
        end 

        cef_data = csvread(cef,1)
        rank = mutype*cef_data(:,2)-1
        lb = 100000-cef_data(:,4)
        ub = 100000-cef_data(:,3)

        % get moments 
        moment_data = csvread(moment,1)
        scatter_rank = moment_data(:,1)
        moment = 100000-moment_data(:,2) 

        % plot 
        hold on
        plot(rank,lb,'Color','k')
        plot(rank,ub,'Color','k')
        scatter(scatter_rank,moment,'filled','k') 
        hold off 

        ylim([0 2000])
        axis([0 100 0 2000])
        xlabel('Education Rank')
        ylabel('Deaths/100,000')

        set(gca,'fontsize',25) 

        write_pdf(graph_fn) 




