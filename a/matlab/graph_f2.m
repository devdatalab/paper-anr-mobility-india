function graph_f2(age,max_f2) ; 

% for testing

    % set up an empty matrix 
    data_father_ed = zeros(100,3,0) ; 

    % append the bootstraps 
    for num = 1:max_f2

        % import graph 
        graph = sprintf('~/iec/output/mobility/bounds/f2_bounds_%s_%d_%s.csv',age,num) ; 

        data_append = csvread(graph); 

        % collapse 
        % diff_in_bounds = [data_append(:,4) - data_append(:,3)] ; 
        f2_bound = [data_append(:,1)] ;
        bound_matrix = [f2_bound data_append(:,3) data_append(:,4)] ;
        
        % append the row in the appropriate index 
        data_father_ed = cat(3,data_father_ed,bound_matrix) ;

    end 

    % set up a mean and 95% CI matrices to plot later 
    diff = zeros(max_f2,4,0) 

    p_vals =   [10 25 75 90] 

    % loop over all f2s 
    for x = 1:length(p_vals)

        % obtain all the values of this percentile 
        all_values = permute(data_father_ed(p_vals(1,x),:,:), [2 3 1])' 
        col_of_x = p_vals(1,x) * ones(max_f2,1)

        % add x's to the matrix
        all_values = cat(2,col_of_x,all_values) 

        % create the array 
        diff = cat(3,diff,all_values) ; 

    end 

    % plot bounds 
    clf 

    % plot 4 series 
    plot(diff(:,2,2),100 * diff(:,3,2),'LineStyle','--','Color','k'); hold on;
    plot(diff(:,2,1),100 * diff(:,3,1),'LineStyle','-','Color','k'); hold on;

    plot(diff(:,2,2),100 * diff(:,4,2),'LineStyle','--','Color','k'); hold on;
    plot(diff(:,2,1),100 * diff(:,4,1),'LineStyle','-','Color','k'); hold on;

    % set axes 
    axis([0 .005 0 100]) 

    % set legend
    legend('p25 - bounds','p10 - bounds')
    legend boxoff

    % export 
    graphname = sprintf('~/public_html/png/f2_bound_%d.png',age)
    print(graphname, '-dpng');

