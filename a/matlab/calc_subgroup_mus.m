%%%%%%%%%%%%%%%% Calculate Mu-0-50 and Mu-0-75 etc. for all India subgroups %%%%%%%%%%%%%%%%%%
moment_fn = '~/iec/output/mobility/moments/ihds_all_moments.csv';

% flag to recalculate keys already in file
recalc_if_exist = 0;

% load moment data
moments = readtable(moment_fn);

% set birth cohort years to loop through
bc_list = [1950 1960 1970 1975 1980 1985];

% set f2 list
f2_list = [1 5 10];
group_list = 0:4;

% override for testing
f2_list = [1 5 10 25000];
group_list = 0:4;
bc_list = [1950 1960 1970 1980];

% set output file
mu_output_fn = '/scratch/pn/mob_matlab_mus.csv';
insert_line(mu_output_fn, 'bc,group,f2,mu_s,mu_t', 'mu_lb,mu_ub');

% create master loop
for bc = bc_list
  for group = group_list

    % identify the rows of interest in the table
    rows = (moments.group == group) & (moments.bc == bc);

    % get the father ranks and mean son ranks
    father_ranks = moments.father_ed_rank(rows);
    son_ranks = moments.son_ed_rank(rows);

    % convert father ranks into bin cuts
    father_cuts = get_cuts_from_means(father_ranks);
    
    for f2 = f2_list

      % set key
      key = sprintf('%d,%d,%d,%d,%d', bc, group, f2, 0, 50);

      % skip if already exists and no recalc flag it set
      if recalc_if_exist | (key_exists(mu_output_fn, key) == 0)
      
        % calculate the mu
        fprintf('calculating %d-%d-%d...\n', bc, group, f2);
        mu = bound_mob('', father_cuts, son_ranks, 1, 50, f2, 'mon');
        
        % insert it into the output file
        val = sprintf('%1.2f,%1.2f', mu(1), mu(2));
        insert_line(mu_output_fn, key, val);
      else
        fprintf('Skipping %s.\n', key);
      end
    end
  end
end

