% generates all mbility graphs, looping over: (i) age groups; (ii) caste groups; (iii) f2 limits

% denmark: limit from 0.0006 to 0.00028
% US: .00034, 0.00017

% note: .12, .06, .03, .015 all work for age 35 if you set the tol_set as 3 and the tol_x as 13 
% note: 250 works if you set the tol_set as 2 and the tol_x as 6 

f2_set = [1000 0];


f2_set = [0];
age_set = [35] 
tol_set = [10 11 12 13 14 15 ]
tol_x_set = [8 9 10 11 12 ] 

number_of_functions = [100000] 

tic 


for f2_limit = 1:length(f2_set) 

    for numfuns = 1:length(number_of_functions) 
    
        for tol_fun_i = 1:length(tol_set) 

                for tol_x_i = 1:length(tol_x_set) 

                    for age = 1:length(age_set)

                        for f = {''}
    toc

                            % build input file
                            input_fn = sprintf('~/iecmerge/paul/mobility/data/age_%d%s.csv', age_set(age), f{1});

                            % build graph name
                            graph_fn = sprintf('mob_%d%s_%d_num_%d_con_%d_fun_%d_x_%d', age_set(age), f{1}, f2_limit,numfuns,tol_set(tol_fun_i),tol_set(tol_fun_i), tol_x_set(tol_x_i));

                            % build csv output file name
                            output_fn = sprintf('~/iec1/output/crafkin/mob/mob_%d%s_%d_num_%d_con_%d_fun_%d_x_%d.csv', age_set(age), f{1}, f2_limit,numfuns,tol_set(tol_fun_i),tol_set(tol_fun_i), tol_x_set(tol_x_i));

                            % get_mob_bounds
                            fprintf('Calculating p-bounds for mob_%d%s_%d_num_%d_con_%d_fun_%d_x_%d...\n', age_set(age), f{1}, f2_limit,numfuns,tol_set(tol_fun_i),tol_set(tol_fun_i), tol_x_set(tol_x_i));
                            fprintf('%s\n', datestr(now));

                            get_mob_bounds_opts(input_fn, graph_fn, output_fn, f2_set(f2_limit), number_of_functions(numfuns),tol_set(tol_fun_i),tol_set(tol_fun_i),tol_x_set(tol_x_i));

                        end
                    end
                end
            end 
       end 
end




