% generates all mobility graphs, looping over: (i) age groups; (ii) caste groups; (iii) f2 limits

% denmark: limit from 0.0006 to 0.00028
% US: .00034, 0.00017

% f2_set_denmark = [10 0.0012 0.0006 0.0003 0.00015 0];
%f2_set_orig = [10 0.01 0.001 0.0001 0];

f2_set_denmark = [0.10] 
f2_set = f2_set_denmark;

b2_set = [1970 1980 1950 1960];
b2_set = [1970];

p_skip = 1;

% set number of bootstraps 
maxnum = 50 ; 
tic 

types = {'all'}

for grp = 1:1 

    for b2 = 1:length(b2_set) 

        for f2 = 1:length(f2_set)
                
            for bootstrap = 1:100

               % create f2 file suffix and f2 limit
               f2_limit = f2_set(f2);
               f2_suffix = num2str(f2_limit * 100);

                   % set input file with moments, output bounds csv filename, graph filename
                   moment_fn = sprintf('~/iec/output/mobility/bootstrap_moments/%s_%d_10000_%d.csv',types{grp},b2_set(b2),bootstrap)
                   bounds_fn = sprintf('~/iec/output/mobility/bootstrap_bounds/bounds_%s_%d_%s_%d.csv',types{grp},b2_set(b2),f2_suffix,bootstrap);

                   % get_mob_bounds
                   toc

                   % skip if f2 == 0 -- these bounds are generated in Stata.
                   if f2_limit ~= 0
                       [p_min p_max] = get_mob_bounds(moment_fn, f2_limit, p_skip);

                       % write bounds to a CSV file
                       fprintf('Writing output file %s...\n\n\n', bounds_fn)
                       f = fopen(bounds_fn, 'w');

                       % write header line
                       % fprintf(f, 'f2_limit,p,p_min,p_max\n');

                       for p = 1:100
                           fprintf(f, '%10.8f,%d,%5.4f,%5.4f\n', f2_limit, p, p_min(p), p_max(p));
                        end
                   end

            end

        end 

    end

end 


% make pictures 
maxnum = 50 

for f = 1:1 
    for f2_limit = 1:length(f2_set) 
        f2_suffix = num2str(f2_set(f2_limit) * 100);

        for b2 = 1:length(b2_set) 

        graph_bootstrap(b2_set(b2),f2_suffix,maxnum,types{f}) 

        end 

    end

end 

command = 'cp ~/public_html/png/bstrap* ~/iec/output/mobility/figures/ '
status = dos(command) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % make pictures                                                          %
% maxnum = 50                                                              %
% types                                                                    %
% for f = 1:3                                                              %
%     for f2_limit = 1:length(f2_set)                                      %
%         f2_suffix = num2str(f2_set(f2_limit) * 100);                     %
%                                                                          %
%         for b2 = 1:length(b2_set)                                        %
%                                                                          %
%         graph_bootstrap(b2_set(b2),'',maxnum,types{f})                   %
%                                                                          %
%         end                                                              %
%                                                                          %
%     end                                                                  %
%                                                                          %
% end                                                                      %
%                                                                          %
% command = 'cp ~/public_html/png/bstrap* ~/iec/output/mobility/figures/ ' %
% status = dos(command)                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

