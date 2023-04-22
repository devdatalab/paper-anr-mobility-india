%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to bound reg coefficient %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bound the regression coefficient, under some level of allowed curvature of the underyling function
function [bounds] = bound_mort_reg_coef(input_csv, f2_limit);

    % return value: lower bound and upper bound for reg coef

    % set globals
    global A_moments b_moments f_min_mse

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % nested reg coefficient calculation optimization functions %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function slope = fun_reg_coef(p);
    
        % create X matrix
        % X = [ones(100, 1) (1:100)'];
        X = [ones(100, 1) (.01:.01:1)'];
        
        % calculate regression solution
        coefs = ((inv(X'*X))*X'*p');
        
        slope = coefs(2);
    end
    function slope = fun_reg_coef_max(p);
    
        slope = -fun_reg_coef(p);
    end

    % TEMP FOR FUNCTION TESTING
    % input_csv = '~/iecmerge/paul/mobility/data/age_35.csv';
    % f2_limit = .0001;
    % END TEMP

    % get standard solver parameters
    [options, cuts, vals, num_ps, A_moments, b_moments, A_ineq, b_ineq, x0_perfect, lb, ub] = get_mort_solver_params(input_csv, f2_limit);

    % create arrays to hold max and minimum values of p. start at extreme values, so we can tell if the solver failed
    clear p_min p_max
    p_min = zeros(1, num_ps);
    p_max = 100 * ones(1, num_ps);
        
    % STEP 1: CALCULATE MINIMUM MSE UNDER THIS f2 CONSTRAINT
    [x_start, f_min_mse, exit_flag, output] = fmincon(@fun_mse, x0_perfect, A_ineq, b_ineq, [], [], lb, ub, [], options);
    assert(exit_flag == 1 | exit_flag == 2);
        
    % STEP 2: MAXIMIZE/MINIMIZE EACH p-BOUND, S.T. TO MEETING THIS MSE
    
    % now find lowest possible value of regression coefficient
    [x_min, f_min, exit_flag, output] = fmincon(@fun_reg_coef,     x_start, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    
    % now find highest possible value of the regression coefficient
    [x_max, f_max, exit_flag, output] = fmincon(@fun_reg_coef_max, x_start, A_ineq, b_ineq, [], [], lb, ub, @c_fun_mse, options);
    
    bounds = [f_min, -f_max] ./ 100;
    
end
