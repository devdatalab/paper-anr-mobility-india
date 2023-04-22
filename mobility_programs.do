qui {

  /* set mobility globals */
  global bc_list 1950 1960 1970 1975 1980 1985

  /* set subgroup graph colors */
  global muscolor 150 150 255
  global sccolor  252 46 24
  global gencolor 32 32 32
  global stcolor  190 210 160
  
  /**********************************************************************************/
  /* program rerank : rerank fathers and sons in current sample */
  /***********************************************************************************/
  cap prog drop rerank
  prog def rerank
    syntax, [by(passthru)]
  
    capdrop child_ed_rank father_ed_rank_c mother_ed_rank_c son_ed_rank father_ed_rank_s father_ed_rank_d daughter_ed_rank mother_ed_rank_s mother_ed_rank_d
  
    /* generate son education ranking */
    gen_wt_ranks son_ed, gen(son_ed_rank) weight(wt) `by'
    
    /* generate father education ranking for father - son links */
    gen_wt_ranks father_ed if !mi(son_ed), gen(father_ed_rank_s) weight(wt) `by'
    
    /* generate father education ranking for father - daughter links */
    cap gen_wt_ranks father_ed if !mi(daughter_ed), gen(father_ed_rank_d) weight(wt) `by'
    
    /* generate daughter education ranking */
    cap gen_wt_ranks daughter_ed, gen(daughter_ed_rank) weight(wt) `by'
    
    /* generate mother education ranking for mother - son links */
    cap gen_wt_ranks mother_ed if !mi(son_ed), gen(mother_ed_rank_s) weight(wt) `by'
    
    /* generate mother education ranking for mother - daughter links */
    cap gen_wt_ranks mother_ed if !mi(daughter_ed), gen(mother_ed_rank_d) weight(wt) `by'

    /* generate joint son/daughter (i.e. child ranks) */
    gen_wt_ranks child_ed, gen(child_ed_rank) weight(wt) `by'
    gen_wt_ranks father_ed if !mi(child_ed), gen(father_ed_rank_c) weight(wt) `by'
    gen_wt_ranks mother_ed if !mi(child_ed), gen(mother_ed_rank_c) weight(wt) `by'
  end
  /* *********** END program rerank ***************************************** */
  
  /********************************************************************************/
  /* program gen_bc_ranks : Standardized birth cohort groups across all analyses */
  /********************************************************************************/
  cap prog drop gen_bc_ranks
  prog def gen_bc_ranks
  {
    /* manually create birth cohort groups -- 5 years for recent period, ten for way back */
    cap drop bc
    gen bc = .
    replace bc = 1950 if inrange(birth_year, 1950, 1959)
    replace bc = 1960 if inrange(birth_year, 1960, 1969)
    replace bc = 1970 if inrange(birth_year, 1970, 1974)
    replace bc = 1975 if inrange(birth_year, 1975, 1979)
    replace bc = 1980 if inrange(birth_year, 1980, 1984)
    replace bc = 1985 if inrange(birth_year, 1985, 1989)
  
    rerank, by(bc)
  }
  end
  /* *********** END program gen_bc_ranks ***************************************** */
  
  /*************************************************************************************/
  /* program get_bc_mid : Create bc_mid, which is midpoint of multi-year birth cohorts */
  /*************************************************************************************/
  cap prog drop get_bc_mid
  prog def get_bc_mid
  {
    gen     bc_mid = bc + 4.5 if inlist(bc, 1950, 1960)
    replace bc_mid = bc + 2 if bc >= 1970 & !mi(bc)
  }
  end
  /* *********** END program get_bc_mid ***************************************** */

  /*******************************************************************************/
  /* program downcode_ed: Downcode granular education to 7 NSS/SECC categories   */
  /*******************************************************************************/
  cap prog drop downcode_ed
  prog def downcode_ed
  {
    syntax varname, [GENerate(name) REPLace]

    /* handle generate / replace */
    tokenize `varlist'
    local name = "`1'"
    
    /* if no generate specified, assume user intends to replace */
    if mi("`generate'") {
      local name = "`1'"
    }
    
    /* if generate specified, copy the variable right away */
    else {
      gen `generate' = `1'
      local name = "`generate'"
    }
    
    replace `name' = 0  if inrange(`1', 0, 1.9)
    replace `name' = 2  if inrange(`1', 2, 4.9) 
    replace `name' = 5  if inrange(`1', 5, 7.9) 
    replace `name' = 8  if inrange(`1', 8, 9.9) 
    replace `name' = 10 if inrange(`1', 10, 11.9) 
    replace `name' = 12 if inrange(`1', 12, 13.9) 
    replace `name' = 14 if inrange(`1', 14, 20) 
  }
  end
  /** END program downcode_ed ****************************************************/

  /*****************************************************************************/
  /* program mob_label_vars: Labels variables for generating mobility tables   */
  /*****************************************************************************/
  cap prog drop mob_label_vars
  prog def mob_label_vars
  {
      cap label var age "Age"
      cap label var ed "Child years of education"
      cap label var ln_hh_income "Log household income"
      cap label var hh_income "Household income"
      cap label var son_ed "Child years of education"
      cap label var daughter_ed "Child years of education"
  }
  end
  /** END program mob_label_vars ***********************************************/

  /************************************************************************/
  /* program bound_mobility : generate analytical bounds on mobility CEFs */ 
  /* s: low end of parent rank interval (defaults to 0 for bottom half mobility) */
  /* t: high end of parent rank interval (defaults to 50 for bottom half mobility) */
  /* if s = t, then this returns the bounds on p_s = p_t  */

  /* sample use:
  // calculate p25
  bound_mobility [aw pw] [if], xvar(father_ed_rank) yvar(son_ed_rank_decade) s(25) t(25) [by(birth_cohort)]
  
  // calculate mu50
  bound_mobility [aw pw] [if], xvar(father_ed_rank) yvar(son_ed_rank_decade) s(0) t(50) [by(birth_cohort)]
  */
  
  /***********************************************************************************/
  capture prog drop bound_mobility 
  prog def bound_mobility, rclass
    
    syntax [aweight pweight] [if], xvar(string) yvar(string) [s(real 0) t(real 50) append(string) str(string) forcemono QUIet verbose] 

    preserve

    qui {

      /* keep if if */
      if !mi("`if'") {
        keep `if'
        local ifstring "`if'"
      }

      /* only use "noi" if verbose is specified */
      if !mi("`verbose'") {
        local noi noisily
      }
      
      /* require non-missing xvar and yvar */
      count if mi(`xvar') | mi(`yvar')
      if `r(N)' > 0  & ("`verbose'" != "") {
        `noi' disp "Warning: ignoring `r(N)' rows that are missing `xvar' or `yvar'."
      }
      keep if !mi(`xvar') & !mi(`yvar')

      /* fail with an error message if there's no data left */
      qui count
      if `r(N)' < 2 {
        disp as error "bound_mobility: Only `r(N)' observations left in sample; cannot bound anything."
        error 456
      }
      
      // Create convenient weight local
      if ("`weight'" != "") {
        local wt [`weight'`exp']
        local longweight = "weight(" + substr("`exp'", 2, .) + ")"
      }

      /* if not monotonic */
      is_monotonic, x(`xvar') y(`yvar') `longweight'
      if `r(is_monotonic)' == 0 {

        /* combine bins to force monotonicity if requested */
        if !mi("`forcemono'") {
          `noi' make_monotonic, x(`xvar') y(`yvar') `longweight' preserve_ranks
          make_monotonic, x(`xvar') y(`yvar') `longweight' preserve_ranks
        }

        /* otherwise fail */
        else {
          display as error "ERROR: bound_mobility cannot estimate mu with non-monotonic moments"
          local FAILED 1
        }
      }
      
      /* sort by the x variable */
      sort `xvar'
      
      /* collapse on xvar [does nothing if data is already collapsed] */
      collapse (mean) `yvar' `wt' , by(`xvar')
      
      /* rename variables for convenience */
      ren `yvar' y_moment
      ren `xvar' x_moment

      /************************************************/
      /* STEP 1: get moments/cuts  */
      /************************************************/

      /* obtain the cuts from the midpoints */
      sort x_moment
      gen xcuts = x_moment[1] * 2 if _n == 1
      local n = _N
      
      forv i = 2/`n' {
        replace xcuts = (x_moment - xcuts[_n-1]) * 2 + xcuts[_n-1] if _n == `i' 
      }
      replace xcuts = 100 if _n == _N 
      
      /**************************************************/
      /* STEP 2: CONVERT PARAMETERS TO LOCALS */
      /**************************************************/
      /* obtain important parameters and put into locals */
      forv i = 1/`n' {
        
        local y_moment_next_`i' = y_moment[`i'+1]
        local y_moment_prior_`i' = y_moment[`i'-1]
        local y_moment_`i' = y_moment[`i']
        local x_moment_`i' = x_moment[`i']
        local min_bin_`i' = xcuts[`i'-1]
        local max_bin_`i' = xcuts[`i']
        
        local min_bin_1 = 0 
        local max_bin_`n' = 100 
        local y_moment_prior_1 = 0
        local y_moment_next_`n' = 1
        
        /* get the star for each bin */
        local star_bin_`i' = (`y_moment_next_`i'' * `max_bin_`i'' - (`max_bin_`i'' - `min_bin_`i'') * `y_moment_`i'' - `min_bin_`i'' * `y_moment_prior_`i'' ) / ( `y_moment_next_`i'' - `y_moment_prior_`i'' )
        
        /* close loop over bins */
        
      }
      
      /* determine the bin that s and t are in */
      forv i = 1/`n' {
        
        if `min_bin_`i'' <= `t' & `max_bin_`i'' >= `t' { 
          local bin_t = `i'
        }
        
        if `min_bin_`i'' <= `s' & `max_bin_`i'' >= `s' { 
          local bin_s = `i'
        }
        
      }    
      
      /* make everything easier to reference by dropping the end index */
      foreach variable in min_bin max_bin y_moment_prior y_moment_next y_moment x_moment star_bin {
        local `variable'_t = ``variable'_`bin_t''
        local `variable'_s = ``variable'_`bin_s''
      }
      
      /***************************/
      /* STEP 3: GET THE BOUNDS  */
      /***************************/
      
      /* get the analytical lower bound */
      if (`t' < `star_bin_t') local analytical_lower_bound_t = `y_moment_prior_t' 
      if (`t' >= `star_bin_t') local analytical_lower_bound_t = 1/(`t' - `min_bin_t') * ( (`max_bin_t' - `min_bin_t') * `y_moment_t' - (`max_bin_t' - `t') * `y_moment_next_t' )
      
      /* get the analytical upper bound */
      if (`s' < `star_bin_s') local analytical_upper_bound_s = 1/(`max_bin_s' - `s') * ((`max_bin_s' - `min_bin_s' )* `y_moment_s' - (`s' - `min_bin_s') * `y_moment_prior_s' )
      if (`s' >= `star_bin_s') local analytical_upper_bound_s = `y_moment_next_s'
      
      /* if the t value is not in the same bin as s, average the determined value of the moments in prior bins, plus the analytical
      lower bound times the proportion of mu_0^t it constitutes */
      if `bin_t' != `bin_s' {
        
        local bin_t_minus_1 = `bin_t' - 1
        local bin_s_plus_1 = `bin_s' + 1
        
        /* add the determined portion, mu_prime, only if there is a full bin in between s and t  */      
        if `bin_t' - `bin_s' >= 2 {
          local mu_prime = 0 
          /* obtain the weighted value of the moments between s and t  */  
          forv i = `bin_s_plus_1'/`bin_t_minus_1' {
            local bin_size_`i' = `max_bin_`i'' - `min_bin_`i''         
            local wt =  `bin_size_`i'' / (`t' - `s') * `y_moment_`i'' 
            local mu_prime = `mu_prime' + `wt'
          }
        }      
        else {
          local mu_prime = 0
        }
        di "`mu_prime'" 
        /* put this together with the determined portion of the parameter */  
        local lb_mu_s_t = `mu_prime' + (`t' - max(`max_bin_`bin_t_minus_1'',`s') ) / (`t' - `s') * `analytical_lower_bound_t' + (`max_bin_s' - `s') / (`t' - `s') * `y_moment_s' * (`bin_s' != `bin_t') 
        local ub_mu_s_t = `mu_prime' + (`t' - `max_bin_`bin_t_minus_1'' ) / (`t' - `s') * `y_moment_t' * (`bin_s' != `bin_t') + (min(`max_bin_s',`t') - `s') / (`t' - `s') * `analytical_upper_bound_s' 
      }
      
      /* if the t IS in the same interval as s, the bounds are simpler to compute: just take the analytical lower bound of t, or the analytical upper bound of s */
      if `bin_t' == `bin_s' {
        local lb_mu_s_t = `analytical_lower_bound_t'
        local ub_mu_s_t = `analytical_upper_bound_s'
      }
      
      /* return the locals that are desired */
      if "`FAILED'" != "1" {
        return local t = `t'
        return local s = `s'
        return local mu_lower_bound = `lb_mu_s_t'
        return local mu_upper_bound = `ub_mu_s_t'                     
        return local mu_lb = `lb_mu_s_t'
        return local mu_ub = `ub_mu_s_t'                     
        return local star_bin_s = `star_bin_s'
        return local star_bin_t = `star_bin_t'    
        return local num_moms = _N
      }
    }

    if "`FAILED'" != "1" {
      local rd_lb_mu_s_t: di %6.3f `lb_mu_s_t'
      local rd_ub_mu_s_t: di %6.3f `ub_mu_s_t'

      if mi("`quiet'") {      
        di `" Mean `yvar' in(`s', `t') is in [`rd_lb_mu_s_t', `rd_ub_mu_s_t'] "'   
      }
      
      if !mi("`append'") {
        append_to_file using `append', s(`str',`rd_lb_mu_s_t', `rd_ub_mu_s_t')
      }
    }
    else {
      return local t = `t'
      return local s = `s'
      return local mu_lower_bound = .
      return local mu_upper_bound = .
      return local mu_lb = .
      return local mu_ub = .
      return local star_bin_s = .
      return local star_bin_t = .
      return local num_moms = _N
    }
    /* close program */
    restore
  end
  /* *********** END program bound_mobility ***************************************** */
  
  /**********************************************************************************/
  /* program bound_t_clean : report transition matrix bounds                        */
  /*   "clean" because this assumes clean monotonic data, whereas calc_t does son interpolation and monotonicity checking */
  // sample use:
  //   use $tmp/trans_1960, clear
  //   bound_t_clean [aw pw] [if], xvar(father_ed_rank_decade) yvar(son_ed_rank_decade) 
  
  /**********************************************************************************/
  cap prog drop bound_t_clean
  prog def bound_t_clean, rclass
  {
    syntax [aweight pweight] [if], xvar(string) yvar(string) 

    // Create convenient weight local
    if ("`weight'"!="") local wt [`weight'`exp']
      
    preserve
    /* create reverse cumulative values for child ranks */
    gen cumul_25_100 = inrange(`yvar', 24.999, 100)
    gen cumul_50_100 = inrange(`yvar', 49.999, 100)
    gen cumul_75_100 = inrange(`yvar', 74.999, 100)

    /* create target matrices */
    matrix define T_min = (-1, -1, -1, -1 \ -1, -1, -1, -1 \ -1, -1, -1, -1 \ -1, -1, -1, -1)
    matrix define T_max = (-1, -1, -1, -1 \ -1, -1, -1, -1 \ -1, -1, -1, -1 \ -1, -1, -1, -1)
    matrix define T_mid = (-1, -1, -1, -1 \ -1, -1, -1, -1 \ -1, -1, -1, -1 \ -1, -1, -1, -1)
    
    /* save a temporary file */
    qui save $tmp/__trans_data, replace
  
    /* loop over each row of transition matrix (in quartiles) */
    forval quartile = 1/4 {
  
      /* set boundaries for this parent row */
      local lb = (`quartile' - 1) * 25
      local ub = (`quartile' - 1) * 25 + 24.999
  
      /* calculate bounds on share of children in 25, 100 */
      qui bound_mobility `wt' `if', xvar(`xvar') yvar(cumul_25_100) s(`lb') t(`ub') 
      local c_25_100_min = `r(mu_lower_bound)'
      local c_25_100_max = `r(mu_upper_bound)'
    
      qui bound_mobility `wt' `if', xvar(`xvar') yvar(cumul_50_100) s(`lb') t(`ub') 
      local c_50_100_min = `r(mu_lower_bound)'
      local c_50_100_max = `r(mu_upper_bound)'
      
      qui bound_mobility `wt' `if', xvar(`xvar') yvar(cumul_75_100) s(`lb') t(`ub') 
      local c_75_100_min = `r(mu_lower_bound)'
      local c_75_100_max = `r(mu_upper_bound)'
      
      /* calculate positive cumulative transitions from these */
      local c_0_25_min = 1 - `c_25_100_max'
      local c_0_25_max = 1 - `c_25_100_min'
      
      local c_0_50_min = 1 - `c_50_100_max'
      local c_0_50_max = 1 - `c_50_100_min'
      
      local c_0_75_min = 1 - `c_75_100_max'
      local c_0_75_max = 1 - `c_75_100_min'
  
      /* we already have first and last cells of transition matrix. calculate intermediate cells.  */
      local c_25_50_min = min(1, max(0, (`c_0_50_min' - `c_0_25_max')))
      local c_25_50_max = min(1, max(0, (`c_0_50_max' - `c_0_25_min')))
      
      local c_50_75_min = min(1, max(0, (`c_0_75_min' - `c_0_50_max')))
      local c_50_75_max = min(1, max(0, (`c_0_75_max' - `c_0_50_min')))
  
      /* store cells in locals that will live longer */
      local t`quartile'1_min = `c_0_25_min'
      local t`quartile'1_max = `c_0_25_max'
  
      local t`quartile'2_min = `c_25_50_min'
      local t`quartile'2_max = `c_25_50_max'
  
      local t`quartile'3_min = `c_50_75_min'
      local t`quartile'3_max = `c_50_75_max'
      
      local t`quartile'4_min = `c_75_100_min'
      local t`quartile'4_max = `c_75_100_max'

      /* calculate cumulative midpoints */
      local c_0_25_mid = (`c_0_25_min' + `c_0_25_max') / 2
      local c_0_50_mid = (`c_0_50_min' + `c_0_50_max') / 2
      local c_0_75_mid = (`c_0_75_min' + `c_0_75_max') / 2
  
      /* store cells for midpoint transition matrix */
      local t`quartile'1_mid = `c_0_25_mid'
      local t`quartile'2_mid = `c_0_50_mid' - `c_0_25_mid'
      local t`quartile'3_mid = `c_0_75_mid' - `c_0_50_mid'
      local t`quartile'4_mid = 1 - `c_0_75_mid'

      /* store as matrices */
      matrix T_min[`quartile', 1] = `c_0_25_min'
      matrix T_max[`quartile', 1] = `c_0_25_max'
      matrix T_min[`quartile', 2] = `c_25_50_min'
      matrix T_max[`quartile', 2] = `c_25_50_max'
      matrix T_min[`quartile', 3] = `c_50_75_min'
      matrix T_max[`quartile', 3] = `c_50_75_max'
      matrix T_min[`quartile', 4] = `c_75_100_min'
      matrix T_max[`quartile', 4] = `c_75_100_max'

      matrix T_mid[`quartile', 1] = `c_0_25_mid'
      matrix T_mid[`quartile', 2] = `c_0_50_mid' - `c_0_25_mid'
      matrix T_mid[`quartile', 3] = `c_0_75_mid' - `c_0_50_mid'
      matrix T_mid[`quartile', 4] = 1 - `c_0_75_mid'
    }
  
    /**********************************************************/
    /* store transition matrix bounds and midpoints to a file */
    /**********************************************************/
  
    /* prepare bounds and midpoint transition matrix files for writing */
    cap file erase $tmp/trans_bounds.txt
    cap file close fh_bounds
    file open fh_bounds using $tmp/trans_bounds.txt, write replace
    
    cap file erase $tmp/trans_mid.txt
    cap file close fh_mid
    file open fh_mid using $tmp/trans_mid.txt, write replace
  
    /* loop over father and son quartiles */
    forval f = 1/4 {
      forval s = 1/4 {
  
        /* write bounds to output file */
        local lb: di %5.2f `t`f'`s'_min'
        local ub: di %5.2f `t`f'`s'_max'
        file write fh_bounds "[" %5.2f (`lb') ", " %5.2f (`ub') "]     "
  
        /* write midpoints to output file  */
        local midpoint: di %5.2f `t`f'`s'_mid'
        file write fh_mid %5.2f (`midpoint') "               "
      }
  
      /* close this row of transition matrices */
      file write fh_bounds _n
      file write fh_mid _n
    }
  
    /* close file handle */
    cap file close fh_bounds
    cap file close fh_mid
  
    disp_nice "Transition Matrix Bounds"
    cat $tmp/trans_bounds.txt
  
    disp_nice "Midpoint Transition Matrix"
    cat $tmp/trans_mid.txt

    /* set return values */
    return matrix T_min = T_min
    return matrix T_max = T_max
    return matrix T_mid = T_mid
    
    restore
  }
  end
  /* *********** END program bound_t_clean ***************************************** */
  
  /************************************************************************************/
  /* program bound_20_to_80_clean : bound 20->80 (top right cell in quintile transition matrix */
  /* note: could be easily to modified to make general for bound_A_to_B */
  /*   "clean" because this assumes clean monotonic data, whereas calc_t does son interpolation and monotonicity checking */
  // sample use:
  //   use $tmp/trans_1960, clear
  //   bound_20_to_80_clean [aw pw] [if], xvar(father_ed_rank_decade) yvar(son_ed_rank_decade) 
  
  /**********************************************************************************/
  cap prog drop bound_20_to_80_clean
  prog def bound_20_to_80_clean, rclass
  {
    syntax [aweight pweight] [if], xvar(string) yvar(string) 
    preserve
    
    // Create convenient weight local
    if ("`weight'"!="") local wt [`weight'`exp']
    
    /* calculate indicator for child in top 20% */
    gen cumul_80_100 = inrange(`yvar', 79.999, 100)

    /* save a temporary file b/c bound_mobility requires it */
    qui save $tmp/__trans_data, replace
  
    /* calculate mu_0_20, where CEF = p(top 20%) */
    qui bound_mobility `wt' `if' , xvar(`xvar') yvar(cumul_80_100) s(0) t(20) 

    /* set return values */
    return local lb_p_20_to_80 = `r(mu_lower_bound)'
    return local ub_p_20_to_80 = `r(mu_upper_bound)'

    /* display output */
    di _n "Probability of child in top 20% conditional on parent in bottom 20%: [" ///
      %4.2f `r(mu_lower_bound)' ", " %4.2f `r(mu_upper_bound)' "]"
    restore
  }
  end
  /* *********** END program bound_20_to_80_clean ***************************************** */

  
  /***********************************************************************************/
  /* program join_x_bins : Combine X groups indicated by `1' and `2', and rerank X's */
  // [used only by make_monotonic() ]
  /***********************************************************************************/
  cap prog drop join_x_bins
  prog def join_x_bins
  {
    /* FIX: PRESERVE_RANKS PART NEEDS TO WORK WITH IF */
    syntax anything [if], group(varname) xvar(varname) yvar(varname) [weight(passthru) preserve_ranks]
    tokenize `anything'

    capdrop __xcut __xsize
    
    /* preserve_ranks: x variable is already in ranks, but can't use gen_wt_ranks because don't have national sample for rank generation */
    if !mi("`preserve_ranks'") {

      /* generate rank boundaries from rank means */
      get_rank_cuts_from_rank_means `xvar', gen_xcut(__xcut) gen_xsize(__xsize)

      /* store outcome variable for each bin of interest, and bin size */
      sum __xcut if `group' == `1'
      local cut1 = `r(mean)'
      sum __xcut if `group' == `2'
      local cut2 = `r(mean)'
      
      sum `yvar' if `group' == `1'
      local y1 = `r(mean)'
      sum `yvar' if `group' == `2'
      local y2 = `r(mean)'
      
      sum __xsize if `group' == `1'
      local size1 = `r(mean)'
      sum __xsize if `group' == `2'
      local size2 = `r(mean)'

      /* store weighted mean of outcome variable */
      local weighted_mean = (`y1' * `size1' + `y2' * `size2') / (`size1' + `size2')
      
      /* group 1 endpoint becomes same as group 2 endpoint */
      sum __xcut if `group' == `2'
      replace __xcut = `r(mean)' if `group' == `1'

      /* replace group identifer 1 with group identifer 1 */
      replace `group' = `2' if `group' == `1'

      /* assign mean y to weighted average of first two groups */
      replace `yvar' = `weighted_mean' if inlist(`group', `1', `2')

      /* assign midpoint of new group 1 to xvar */
      replace `xvar' = `cut2' - (`size1' + `size2') / 2 if inlist(`group', `1', `2')
    }

    /* else, combine groups and regenerate full sample ranks */
    else {
      /* combine the groups -- doesn't matter which way since we're in rank space */
      replace `group' = `1' if `group' == `2'
      
      /* recalculate father midpoint ranks */
      drop `xvar'
      gen_wt_ranks `group' `if', gen(`xvar') `weight'
    }
    
    /* regroup `group's */
    drop `group'
    sort `xvar'
    egen `group' = group(`xvar') `if'
  }
  end
  /* *********** END program join_x_bins ***************************************** */
  
  /**********************************************************************************/
  /* program is_monotonic : reports whether parent/child distribution is monotonic   */
  // sample usage: is_monotonic, x(father_ed_rank) y(son_ed_rank) weight(weight)
  // return value: `r(is_monotonic)' is 1 if monotonic, 0 if not
  /**********************************************************************************/
  cap prog drop is_monotonic
  prog def is_monotonic, rclass
  {
    syntax [if], x(varname) y(varname) [weight(varname) preserve_ranks]
    
    /* manage weights */
    if !mi("`weight'") {
      local wt_string [aw=`weight']
      local wt_passthru weight(`weight')
    }
    else {
      local wt_string
      local wt_passthru
    }
  
    /* create integer groups for X variable */
    sort `x'
    qui egen __xgroup  = group(`x') `if'
  
    sum __xgroup, meanonly
    local n = `r(max)' - 1
    local is_mono 1

    forval x_current = 1/`n' {
    
      local x_next = `x_current' + 1
      
      /* calculate diff from this point to next */
      qui sum `y' `wt_string' if __xgroup == `x_current'
      local y_current = `r(mean)'
      
      qui sum `y' `wt_string' if __xgroup == `x_next'
      local y_next = `r(mean)'
      
      local diff = `y_next' - `y_current'

      /* report whether monotonic or not */
      if `diff' < 0 {
        return local is_monotonic 0
        continue, break 
      }
      else {
        return local is_monotonic 1
      }
    }
    cap drop __xgroup
  }
  end
  /* *********** END program is_monotonic ***************************************** */
  
  /**********************************************************************************/
  /* program make_monotonic : combine X variable bins until CEF(Y|X) is monotonic    */
  // sample usage: make_monotonic, x(father_ed_rank) y(son_ed_rank) weight(weight)
  // - will then combine bins of father_ed_rank until son_ed is monotonic in father_ed
  // - if using grouped data, need to specify GROUP_DATA option [NOT DEVELOPED YET]
  /**********************************************************************************/
  cap prog drop make_monotonic
  prog def make_monotonic
  {
    syntax [if], x(varname) y(varname) [weight(varname) group_data preserve_ranks]
    qui {
      /* manage weights */
      if !mi("`weight'") {
        local wt_string [aw=`weight']
        local wt_passthru weight(`weight')
      }
      else {
        local wt_string
        local wt_passthru
      }
      
      /* create integer groups for X variable */
      sort `x'
      qui egen __xgroup  = group(`x') `if'
      
      qui sum __xgroup
      local x_max = `r(max)'
      local x_max_orig = `r(max)'
      local flag_changed = 0
      local x_current = 1
      
      /* loop until there are no X bins left */
      /* strict inequality since we compare x_current to (x_current + 1) */
      while `x_current' < `x_max' {

        di "Loop start: `x_current' / `x_max'"
        
        local x_next = `x_current' + 1
        
        /* calculate diff from this point to next */
        qui sum `y' `wt_string' if __xgroup == `x_current'
        local y_current = `r(mean)'
      
        qui sum `y' `wt_string' if __xgroup == `x_next'
        local y_next = `r(mean)'
      
        local diff = `y_next' - `y_current'
        di "`x_current', `x_next', `y_current', `y_next', `diff'"
        
        /* if we're nonmonotonic, join the two bins */
        if `diff' < 0 {

          /* join X bins -- different programs depending on whether data are grouped or not */
          if mi("`grouped_data'") {
            join_x_bins `x_current' `x_next' `if', group(__xgroup) yvar(`y') xvar(`x') `wt_passthru' `preserve_ranks'
          }
          else {
            join_x_bins_group `x_current' `x_next', group(__xgroup) yvar(`y') xvar(`x') `wt_passthru' `preserve_ranks'
          }
          
          /* reset loop counter (i.e. go back to first group) and repeat */
          local x_current = 1
      
          /* reset x_max since we joined some groups together */
          sum __xgroup
          local x_max = `r(max)'
      
          /* set "changed" flag so we can report what happened */
          local flag_changed = 1
          
          continue
        }
        else {
          
          /* this step was monotonic, so raise x_current and check the next one */
          local x_current = `x_current' + 1
        }
      }
    }
    if `flag_changed' == 1 {
      di "make_monotonic: Collapsing from `x_max_orig' X groups to `x_max' X groups to obtain monotonic CEF."
    }
    capdrop __xgroup
  }
  end
  /* *********** END program make_monotonic ***************************************** */

  /**************************************************************************************/
  /* program gen_wt_ranks : Generates midpoint ranks for a given variable               */
  /* - sample use: gen_ed_ranks, gen(ed_rank) .... or gen(ed_rank_agecut)               */
  /* - sample use: gen_ed_ranks son_ed [if], gen(son_ed_rank) weight(weight) by(decade) */
  /**************************************************************************************/
  cap prog drop gen_wt_ranks
  prog def gen_wt_ranks
  {
    syntax varname [if], [GENerate(name) by(varname)] Weight(varname)
    capdrop __rank __min_rank __max_rank __by __number_of_people
  
    if mi("`weight'") {
      tempvar weight
      gen `weight' = 1
    }
    
    if mi("`by'") {
      gen __by = 1
      local by __by
    }
    sort `by'

    tokenize `varlist'
    
    /* add an if clause when varname is missing */
    if !mi("`if'") {
      local if `if' & !mi(`1')
    }
    else {
      local if if !mi(`1')
    }

    /* generate the total number of weights == size of total population */
    by `by': egen __number_of_people = total(`weight') `if'
  
    /* sort according to variable of interest (e.g. education) */
    sort `by' `1' `weight'
    
    /* obtain a rolling sum of weights,  */
    by `by': gen __rank = sum(`weight') `if'
    
    /* within each variable group, obtain the minimum and maximum ranks */
    by `by' `1': egen __min_rank = min(__rank) `if'
    by `by' `1': egen __max_rank = max(__rank) `if'
    
    /* replace the rank as the mean of those rolling sums, and divide by the number of people */
    gen `generate' = 100 * (__min_rank + __max_rank) / (2 * __number_of_people) `if'
    
    /* drop clutter */        
    capdrop __rank __min_rank __max_rank __number_of_people __by 
  
  }
  end
  /* *********** END program gen_wt_ranks ***************************************** */

  /**********************************************************************************/
  /* program calc_transition_matrix : Insert description here */
  /***********************************************************************************/
  cap prog drop calc_transition_matrix
  prog def calc_transition_matrix, rclass
  {
    syntax, PARENTvar(varname) CHILDvar(varname) [Weight(varname) subgroup(string) graphname(string)]
  
    /* preserve -- since we do lots of reshapes/collapses */
    preserve

    /* create a short "if subgroup" string */
    if !mi("`subgroup'") {
      local ifsubgroup `"if `subgroup'"'
    }
    
    /* manage weights -- create a weight if one doesn't already exist */
    if mi("`weight'") {
      gen __weight = 1
    }
    else {
      ren `weight' __weight
    }

    /* generate father and son midpoint ranks in the national distribution */
    qui gen_wt_ranks `parentvar', gen(__parent_rank) weight(__weight)
    qui gen_wt_ranks `childvar', gen(__child_rank) weight(__weight)

    /* keep only the variables we use -- this lets us create arbitrary variables */
    keep __parent_rank __child_rank __weight `subgroup'
    
    /* rename vars to clean names since nothing else now exists */
    rename __* *

    if !mi("`graphname'") {
      binscatter child_rank parent_rank `ifsubgroup', linetype(none) ylabel(0(20)100, grid)
      graphout `graphname'
    }
    
    /********************************/
    /* check and force monotonicity */
    /********************************/
    
    /* if not monotonic, combine X groups until monotonic */
    di "Checking distribution for monotonicity..."
    is_monotonic `ifsubgroup', x(parent_rank) y(child_rank) weight(weight)
    if `r(is_monotonic)' == 0 {
      make_monotonic `ifsubgroup', x(parent_rank) y(child_rank) weight(weight)
    }
    else {
      di "Already monotonic, no changes made."
    }
    
    /**********************************/
    /* interpolate child distribution */
    /**********************************/
    qui {
      /* generate cumulative son transition probabilities IN NATIONAL DISTRIBUTION -- not in subgroup */
      cumul child_rank [aw=weight], gen(son_ed_cumul) equal

      /* restrict to subgroup here, now that all ranks are referenced in national distribution */
      if !mi("`subgroup'") keep if `subgroup'
      
      /* collapse to one obs per parent-child rank -- i.e. raw transition matrix */
      collapse (sum) weight, by(parent_rank son_ed_cumul)
      
      /* fill in the data with zeroes */
      fillin parent_rank son_ed_cumul
      replace weight = 0 if mi(weight)
      
      /* create a weight within each row */
      bys parent_rank: egen father_total_weight = total(weight)
      gen row_weight = weight / father_total_weight
      
      /* show all transition probabilities */
      table parent_rank son_ed_cumul, c(mean row_weight)
      
      /* generate cumulative transition matrix values */
      /* note this is cumulative sum, not egen */
      sort parent_rank son_ed_cumul
      bys parent_rank: gen t = sum(row_weight)
      // table parent_rank son_ed_cumul, c(mean t)
      
      /* create integer father and son groups */
      sort parent_rank
      group parent_rank
      
      sort son_ed_cumul
      group son_ed_cumul
        
      /* we already have datapoints at 100, 100 for each group, create one at 0,0 */
      expand 2 if sgroup == 1, gen(new)
      replace sgroup = 0 if new
      replace t = 0 if new
      replace son_ed_cumul = 0 if new
      replace weight = . if new
      replace row_weight = . if new
      drop new
        
      /* create x values for linear interpolation */
      /* add 100 rows, with indicator "new" for interpolated values */
      count
      local n = `r(N)'
      local new_n = `r(N)' + 100
      set obs `new_n'
      gen new = _n > `n'
      gen row = _n - `n' if _n > `n'
      replace son_ed_cumul = row / 100 if new == 1
      
      /* get sum of father weight, so we know how many fathers in each group */
      sum parent_rank [aw=weight]
      local sum_weight = `r(sum_w)'
      
      sum pgroup
      forval i = 1/`r(max)' {
      
        /* store wide father education variable */
        sum parent_rank [aw=weight] if pgroup == `i'
        gen parent_rank_`i' = `r(mean)' if new == 1
      
        /* store wide father weight */
        gen father_weight_`i' = `r(sum_w)' / `sum_weight' if new == 1
        
        /* linearly interpolate son data so we have one obs per year */
        replace pgroup = `i' if new == 1
        ipolate t son_ed_cumul if pgroup == `i', gen(son_inter_`i')
      
        /* restore pgroup to missing for new obs -- was just temporary for interpolation */
        replace pgroup = . if new == 1
      }
      
      /* keep only interpolated data */
      drop if !mi(t)

      /* reshape to get father-son rank data with exact son ranks  */
      keep parent_rank_* father_weight_* son_inter_* son_ed_cumul 
      
      reshape long parent_rank_ father_weight_ son_inter_, j(pgroup) i(son_ed_cumul)
      label var pgroup ""
      label values pgroup
      
      sort son_ed_cumul pgroup
      group son_ed_cumul
      
      /* clean up names */
      rename *_ *

      /* GENERATE CHILD PDF FROM CDF */
        
      /* flip time series so we can compare son CDF at next point in son distribution */
      sort pgroup sgroup
      xtset pgroup sgroup
      
      /* interpolated son PDF is just diff in interpolated son cdf */
      gen son_ed_pdf = son_inter - L.son_inter
      replace son_ed_pdf = son_inter if float(son_ed_cumul) == float(.01)
      
      /* adjust so x value is each midpoint of each percentile bin (instead of the boundaries as in the CDF) */
      gen child_rank = son_ed_cumul - .005
      
      /* create joint father-son weight -- since son data are uniform, need these weights to show where sons end up */
      gen combined_weight = son_ed_pdf * father_weight
      
      /* rescale ranks to go from 0 to 100 */
      replace child_rank = child_rank * 100

      /* keep only the joint rank data and weights */
      keep parent_rank child_rank combined_weight
    }  
    qui save $tmp/parent_child_clean, replace
    
    /*******************/
    /* get some bounds */
    /*******************/
    use $tmp/parent_child_clean, clear
    
    /* calculate mu50 */
    bound_mobility [aw=combined_weight], xvar(parent_rank) yvar(child_rank)

    return local lb_mu_0_50 = `r(mu_lower_bound)'
    return local ub_mu_0_50 = `r(mu_upper_bound)'
    
    /* loop over decade cohorts and generate all transition matrices */
    bound_t_clean [aw=combined_weight], xvar(parent_rank) yvar(child_rank)

    /* store return values */
    matrix T_min = r(T_min)
    matrix T_mid = r(T_mid)
    matrix T_max = r(T_max)
    
    // /* TEMPORARY: calculate probability of going from bottom 20% to top 80% */
    // bound_20_to_80_clean [aw=combined_weight], xvar(parent_rank) yvar(child_rank) 
    // 
    // /* store return values */
    // return local lb_p_20_to_80 = `r(lb_p_20_to_80)'
    // return local ub_p_20_to_80 = `r(ub_p_20_to_80)'
    
    /* set stored return values */
    return matrix T_min = T_min
    return matrix T_mid = T_mid
    return matrix T_max = T_max
    
    restore
  }
  end
  /* *********** END program calc_transition_matrix ***************************************** */

  /*******************************************************************************************/
  /* program get_rank_cuts_from_rank_means : Obtain rank cuts (upper bounds) from rank means */
  /*******************************************************************************************/
  cap prog drop get_rank_cuts_from_rank_means
  prog def get_rank_cuts_from_rank_means
  {
    syntax varlist(min=1 max=1), gen_xcut(string) [gen_xsize(string) ]

    capdrop __xtag __xsize
    tempvar xcut xsize
    
    /* obtain the cuts from the midpoints */
    tokenize `varlist'

    /* sort so that first n observations are ordered ranks */
    egen __xtag = tag(`1')
    gsort -__xtag `1'
    count if __xtag == 1
    local count = `r(N)'
    
    /* get top boundary of bin #1 */
    gen `xcut' = `1'[1] * 2 if _n == 1
    gen `xsize' = `xcut' if _n == 1
    
    forval i = 2/`count' {
      replace `xsize' = (`1' - `xcut'[_n-1]) * 2 if _n == `i'
      replace `xcut' = `xsize' + `xcut'[_n-1] if _n == `i'
    }
    replace `xcut' = 100 if _n == `count'

    /* apply these boundary values to all observations */
    bys `1': egen `gen_xcut' = max(`xcut')

    if !mi("`gen_xsize'") {
      bys `1': egen `gen_xsize' = max(`xsize')
    }
    
    capdrop __xtag `xcut' `xsize'
  }
  end
  /* *********** END program get_rank_cuts_from_rank_means ***************************************** */
  

/***********************************************/
/* GENERIC FUNCTIONS USED BY MOBILITY PROGRAMS */
/***********************************************/
  /**********************************************************************************/
  /* program disp_nice : Insert a nice title in stata window */
  /***********************************************************************************/
  cap prog drop disp_nice
  prog def disp_nice
  {
    di _n "+--------------------------------------------------------------------------------------" _n "| `1'" _n  "+--------------------------------------------------------------------------------------"
  }
  end
  /* *********** END program disp_nice ***************************************** */
  
  /**********************************************************************************/
  /* program capdrop : Drop a bunch of variables without errors if they don't exist */
  /**********************************************************************************/
  cap prog drop capdrop
  prog def capdrop
  {
    syntax anything
    foreach v in `anything' {
      cap drop `v'
    }
  }
  end
  /* *********** END program capdrop ***************************************** */
  
  /**********************************************************************************/
  /* program group : Fast way to use egen group()                  */
  /**********************************************************************************/
  cap prog drop regroup
  prog def regroup
    syntax anything [if]
    group `anything' `if', drop
  end
  
  cap prog drop group
  prog def group
  {
    syntax anything [if], [drop]
  
    tokenize "`anything'"
  
    local x = ""
    while !mi("`1'") {
  
      if regexm("`1'", "pc[0-9][0-9][ru]?_") {
        local x = "`x'" + substr("`1'", strpos("`1'", "_") + 1, 1)
      }
      else {
        local x = "`x'" + substr("`1'", 1, 1)
      }
      mac shift
    }
  
    if ~mi("`drop'") cap drop `x'group
    
    display `"RUNNING: egen int `x'group = group(`anything')" `if''
    egen int `x'group = group(`anything') `if'
  }
  end
  /* *********** END program group ***************************************** */

/* NOTE: bound_param is nearly identical to bound_mobility; it is better to use bound_mobility,
         but bound_param is used by some of our older code. */
  /**********************************************************************************/
  /* program bound_param : generate analytical bounds on mu or p */ 
  /* s: lower bound */
  /* t: upper bound */
  /* if s = t, then this returns the bounds on p_s = p_t  */

  /* sample use:
  // calculate p25
  bound_param [aw pw] [if], xvar(father_ed_rank) yvar(son_ed_rank_decade) s(25) t(25) [by(birth_cohort)]
  
  // calculate mu50
  bound_param [aw pw] [if], xvar(father_ed_rank) yvar(son_ed_rank_decade) s(0) t(50) [by(birth_cohort)]
  */
  
  /***********************************************************************************/
  capture prog drop bound_param 
  prog def bound_param, rclass
    
    syntax [aweight pweight] [if], xvar(string) yvar(string) [s(real 0) t(real 50) maxmom(real 100) minmom(real 0) append(string) str(string) forcemono QUIet verbose] 

    preserve

    qui {

      /* keep if if */
      if !mi("`if'") {
        keep `if'
        local ifstring "`if'"
      }

      /* only use "noi" if verbose is specified */
      if !mi("`verbose'") {
        local noi noisily
      }
      
      /* require non-missing xvar and yvar */
      count if mi(`xvar') | mi(`yvar')
      if `r(N)' > 0  & ("`verbose'" != "") {
        `noi' disp "Warning: ignoring `r(N)' rows that are missing `xvar' or `yvar'."
      }
      keep if !mi(`xvar') & !mi(`yvar')

      /* fail with an error message if there's no data left */
      qui count
      if `r(N)' < 2 {
        disp as error "bound_param: Only `r(N)' observations left in sample; cannot bound anything."
        error 456
      }
      
      // Create convenient weight local
      if ("`weight'" != "") {
        local wt [`weight'`exp']
        local longweight = "weight(" + substr("`exp'", 2, .) + ")"
      }

      /* if not monotonic */
      is_monotonic, x(`xvar') y(`yvar') `longweight'
      if `r(is_monotonic)' == 0 {

        /* combine bins to force monotonicity if requested */
        if !mi("`forcemono'") {
          `noi' make_monotonic, x(`xvar') y(`yvar') `longweight' preserve_ranks
          make_monotonic, x(`xvar') y(`yvar') `longweight' preserve_ranks
        }

        /* otherwise fail */
        else {
          display as error "ERROR: bound_param cannot estimate mu with non-monotonic moments"
          local FAILED 1
        }
      }
      
      /* sort by the x variable */
      sort `xvar'
      
      /* collapse on xvar [does nothing if data is already collapsed] */
      collapse (mean) `yvar' `wt' , by(`xvar')
      
      /* rename variables for convenience */
      ren `yvar' y_moment
      ren `xvar' x_moment

      /************************************************/
      /* STEP 1: get moments/cuts  */
      /************************************************/

      /* obtain the cuts from the midpoints */
      sort x_moment
      gen xcuts = x_moment[1] * 2 if _n == 1
      local n = _N
      
      forv i = 2/`n' {
        replace xcuts = (x_moment - xcuts[_n-1]) * 2 + xcuts[_n-1] if _n == `i' 
      }
      replace xcuts = 100 if _n == _N 
      
      /**************************************************/
      /* STEP 2: CONVERT PARAMETERS TO LOCALS */
      /**************************************************/
      /* obtain important parameters and put into locals */
      forv i = 1/`n' {
        
        local y_moment_next_`i' = y_moment[`i'+1]
        local y_moment_prior_`i' = y_moment[`i'-1]
        local y_moment_`i' = y_moment[`i']
        local x_moment_`i' = x_moment[`i']
        local min_bin_`i' = xcuts[`i'-1]
        local max_bin_`i' = xcuts[`i']
        
        local min_bin_1 = 0 
        local max_bin_`n' = 100 
        local y_moment_prior_1 = `minmom' 
        local y_moment_next_`n' = `maxmom' 
        
        /* get the star for each bin */
        local star_bin_`i' = (`y_moment_next_`i'' * `max_bin_`i'' - (`max_bin_`i'' - `min_bin_`i'') * `y_moment_`i'' - `min_bin_`i'' * `y_moment_prior_`i'' ) / ( `y_moment_next_`i'' - `y_moment_prior_`i'' )
        
        /* close loop over bins */
        
      }
      
      /* determine the bin that s and t are in */
      forv i = 1/`n' {
        
        if `min_bin_`i'' <= `t' & `max_bin_`i'' >= `t' { 
          local bin_t = `i'
        }
        
        if `min_bin_`i'' <= `s' & `max_bin_`i'' >= `s' { 
          local bin_s = `i'
        }
        
      }    
      
      /* make everything easier to reference by dropping the end index */
      foreach variable in min_bin max_bin y_moment_prior y_moment_next y_moment x_moment star_bin {
        local `variable'_t = ``variable'_`bin_t''
        local `variable'_s = ``variable'_`bin_s''
      }
      
      /***************************/
      /* STEP 3: GET THE BOUNDS  */
      /***************************/
      
      /* get the analytical lower bound */
      if (`t' < `star_bin_t') local analytical_lower_bound_t = `y_moment_prior_t' 
      if (`t' >= `star_bin_t') local analytical_lower_bound_t = 1/(`t' - `min_bin_t') * ( (`max_bin_t' - `min_bin_t') * `y_moment_t' - (`max_bin_t' - `t') * `y_moment_next_t' )
      
      /* get the analytical upper bound */
      if (`s' < `star_bin_s') local analytical_upper_bound_s = 1/(`max_bin_s' - `s') * ((`max_bin_s' - `min_bin_s' )* `y_moment_s' - (`s' - `min_bin_s') * `y_moment_prior_s' )
      if (`s' >= `star_bin_s') local analytical_upper_bound_s = `y_moment_next_s'
      
      /* if the t value is not in the same bin as s, average the determined value of the moments in prior bins, plus the analytical
      lower bound times the proportion of mu_0^t it constitutes */
      if `bin_t' != `bin_s' {
        
        local bin_t_minus_1 = `bin_t' - 1
        local bin_s_plus_1 = `bin_s' + 1
        
        /* add the determined portion, mu_prime, only if there is a full bin in between s and t  */      
        if `bin_t' - `bin_s' >= 2 {
          local mu_prime = 0 
          /* obtain the weighted value of the moments between s and t  */  
          forv i = `bin_s_plus_1'/`bin_t_minus_1' {
            local bin_size_`i' = `max_bin_`i'' - `min_bin_`i''         
            local wt =  `bin_size_`i'' / (`t' - `s') * `y_moment_`i'' 
            local mu_prime = `mu_prime' + `wt'
          }
        }      
        else {
          local mu_prime = 0
        }
        di "`mu_prime'" 
        /* put this together with the determined portion of the parameter */  
        local lb_mu_s_t = `mu_prime' + (`t' - max(`max_bin_`bin_t_minus_1'',`s') ) / (`t' - `s') * `analytical_lower_bound_t' + (`max_bin_s' - `s') / (`t' - `s') * `y_moment_s' * (`bin_s' != `bin_t') 
        local ub_mu_s_t = `mu_prime' + (`t' - `max_bin_`bin_t_minus_1'' ) / (`t' - `s') * `y_moment_t' * (`bin_s' != `bin_t') + (min(`max_bin_s',`t') - `s') / (`t' - `s') * `analytical_upper_bound_s' 
      }
      
      /* if the t IS in the same interval as s, the bounds are simpler to compute: just take the analytical lower bound of t, or the analytical upper bound of s */
      if `bin_t' == `bin_s' {
        local lb_mu_s_t = `analytical_lower_bound_t'
        local ub_mu_s_t = `analytical_upper_bound_s'
      }
      
      /* return the locals that are desired */
      if "`FAILED'" != "1" {
        return local t = `t'
        return local s = `s'
        return local mu_lower_bound = `lb_mu_s_t'
        return local mu_upper_bound = `ub_mu_s_t'                     
        return local mu_lb = `lb_mu_s_t'
        return local mu_ub = `ub_mu_s_t'                     
        return local star_bin_s = `star_bin_s'
        return local star_bin_t = `star_bin_t'    
        return local num_moms = _N
      }
    }

    if "`FAILED'" != "1" {
      local rd_lb_mu_s_t: di %6.3f `lb_mu_s_t'
      local rd_ub_mu_s_t: di %6.3f `ub_mu_s_t'

      if mi("`quiet'") {      
        di `" Mean `yvar' in(`s', `t') is in [`rd_lb_mu_s_t', `rd_ub_mu_s_t'] "'   
      }
      
      if !mi("`append'") {
        append_to_file using `append', s(`str',`rd_lb_mu_s_t', `rd_ub_mu_s_t')
      }
    }
    else {
      return local t = `t'
      return local s = `s'
      return local mu_lower_bound = .
      return local mu_upper_bound = .
      return local mu_lb = .
      return local mu_ub = .
      return local star_bin_s = .
      return local star_bin_t = .
      return local num_moms = _N
    }
    /* close program */
    restore
  end
  /* *********** END program bound_param ***************************************** */

}
