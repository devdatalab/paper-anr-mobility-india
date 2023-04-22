function graph_bootstrap(decade,f2_arg,maxboot,f) ; 

    % set up an empty matrix 
    data_father_ed = zeros(100,2,0) ; 

    % append the bootstraps 
    for num = 1:maxboot

        % import graph 
        %        graph = sprintf('~/iec/output/mobility/bootstrap_bounds/bounds_%s_%d_%s_%d.csv',f,decade,f2_arg,num) ; 
        graph = sprintf('~/iec/output/mobility/bootstrap_bounds/bounds_%s_%d_%s_%d.csv',f,decade,f2_arg,num) ; 

        data_append = csvread(graph); 
        data_append = data_append(:,3:4)

        % append the row in the appropriate index 
        data_father_ed = cat(3,data_father_ed,data_append) ;

    end 


    % set up a mean and 95% CI matrices to plot later 
    mean_lb_plot = zeros(0,2) ; 
    low_lb_plot = zeros(0,2) ;
    high_lb_plot = zeros(0,2) ;

    mean_ub_plot = zeros(0,2) ; 
    low_ub_plot = zeros(0,2) ;
    high_ub_plot = zeros(0,2) ;


    % loop over all percentiles 
    for x = 1:100

        % obtain all the values of this percentile 
        all_values = permute(data_father_ed(x,:,:), [2 3 1])' ; 

        % obtain mean 
        mean_lb = mean(all_values(:,1));  
        mean_ub = mean(all_values(:,2));  

        % get percentiles 
        low_lb = prctile(all_values(:,1),2.5);  
        low_ub = prctile(all_values(:,2),2.5);  

        high_lb = prctile(all_values(:,1),97.5);  
        high_ub = prctile(all_values(:,2),97.5);  

        % put into vectors 
        mean_lb_vector = cat(2,x,mean_lb) ;
        mean_ub_vector = cat(2,x,mean_ub) ;

        low_lb_vector = cat(2,x,low_lb) ;
        low_ub_vector = cat(2,x,low_ub) ;

        high_lb_vector = cat(2,x,high_lb) ;
        high_ub_vector = cat(2,x,high_ub) ;

        % obtain the mean of all the values in that percentile for each row 
        mean_lb_plot = cat(1,mean_lb_plot,mean_lb_vector)  ;
        mean_ub_plot = cat(1,mean_ub_plot,mean_ub_vector) ;

        % get the percentiles
        low_lb_plot = cat(1,low_lb_plot,low_lb_vector) ;
        low_ub_plot = cat(1,low_ub_plot,low_ub_vector) ;

        % get the percentiles
        high_lb_plot = cat(1,high_lb_plot,high_lb_vector) ;
        high_ub_plot = cat(1,high_ub_plot,high_ub_vector) ;

    end 


   % plot bounds 
    clf 
    plot(low_lb_plot(:,1),low_lb_plot(:,2),'LineStyle','--','Color','k'); hold on;
%    plot(high_lb_plot(:,1),high_lb_plot(:,2),'LineStyle','--','Color','k'); hold on;
    plot(mean_lb_plot(:,1),mean_lb_plot(:,2),'Color','k'); hold on;

    % plot(low_ub_plot(:,1),low_ub_plot(:,2),'LineStyle','--','Color','k'); hold on;
        plot(high_ub_plot(:,1),high_ub_plot(:,2),'LineStyle','--','Color','k'); hold on;
    plot(mean_ub_plot(:,1),mean_ub_plot(:,2),'Color','k'); hold off;

    % 
    xlabel('Parent Rank')
    ylabel('Child Rank') 

    % export 
    graphname = sprintf('~/public_html/png/bstrap_%s_%d_%s.png',f,decade,f2_arg)
    print(graphname, '-dpng');


% count the number of intervals that are covered by the bounds you obtain and then store in a matrix 
matrices_not_covered = zeros(0) 

for percentile = 1:100 

    % set up a counter 
    number_not_contained = 0 

    for bootstrap = 1:50 

        % if either side not contained, replace the counter 
        if (data_father_ed(percentile,1,bootstrap) < low_lb_plot(percentile,2)) && (data_father_ed(percentile,2,bootstrap) < high_ub_plot(percentile,2))
            number_not_contained = number_not_contained + 1 ; 
        elseif (data_father_ed(percentile,2,bootstrap) > high_ub_plot(percentile,2)) && (data_father_ed(percentile,1,bootstrap) > low_lb_plot(percentile,2))
            number_not_contained = number_not_contained + 1 ;
        elseif (data_father_ed(percentile,2,bootstrap) > high_ub_plot(percentile,2)) && (data_father_ed(percentile,1,bootstrap) ...
                < low_lb_plot(percentile,2))
            number_not_contained = number_not_contained + 1 ;
        end 

    end
matrices_not_covered = vertcat(matrices_not_covered,number_not_contained)


end 

matrices_not_covered

