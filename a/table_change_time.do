/**************************************/
/* Makes a table of changes over time */
/**************************************/

/***************************************/
/* part 0: prep datafiles for easy i/o */
/***************************************/
global childlist son daughter
global grouplist 0/4
global bs 1000

/* load bootstrap program */
qui do $mobcode/b/bootstrap_from_bounds.do
cap !rm -f $out/interm/change_time_son.csv
cap !rm -f $out/interm/change_time_daughter.csv

import delimited using $mobility/bootstrap_bounds/decadal_ihds_mob_bootstrap_mus_$bs.csv, clear 

save $tmp/bootstrap_mus, replace

/* load ihds and expand to include group 0 */ 
use $mobility/ihds/ihds_mobility, clear

replace bc = 1980 if bc == 1985
rerank, by(bc)

assert !mi(group)
expand 2, gen(new)
replace group = 0 if new == 1

drop new
save $tmp/ihds_data_expanded, replace

/****** construct table for sons and daughters separately *******/ 
foreach child in $childlist {
  
  local shortstr = substr("`child'", 1, 1) 

  /****************************/
  /* part 1: levels  */
  /****************************/
  
  foreach bc in 1960 1980 { 
    forv group = $grouplist { 

      /* first get the "true" set */
      qui {
        use $tmp/ihds_data_expanded, clear 
        bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(50) xvar(father_ed_rank_`shortstr') yvar(`child'_ed_rank) forcemono qui
        local lb = `r(mu_lb)'
        local ub = `r(mu_ub)'

        insert_into_file using $out/interm/change_time_`child'.csv, key(est_group_`group'_`bc'_lb) value(`lb') format(%9.1f)
        insert_into_file using $out/interm/change_time_`child'.csv, key(est_group_`group'_`bc'_ub) value(`ub') format(%9.1f) 
        
        /* then load the bootstraps */
        use $tmp/bootstrap_mus, clear 
        keep if parent == "father" & sex == "`child'" & bc == `bc' & group == `group' & mu == "p25" 
        assert _N == $bs 

        /* implement with a 95% ci */ 
        bootstrap_ci, lbtrue(`lb') ubtrue(`ub') lbvar(lb) ubvar(ub) width(90) bootstraps($bs)
      }
      di "`child'-`bc'-`group', original: (" %5.2f `lb' " , " %5.2f `ub' "), bootstrap ci: (" %5.2f `r(bs_lb)' "," %5.2f `r(bs_ub)' ")"
      local bs_lb = `r(bs_lb)'
      local bs_ub = `r(bs_ub)'    
      
      insert_into_file using $out/interm/change_time_`child'.csv, key(group_`group'_`bc'_lb) value(`bs_lb') format(%9.1f)
      insert_into_file using $out/interm/change_time_`child'.csv, key(group_`group'_`bc'_ub) value(`bs_ub') format(%9.1f) 
    }
  }

  /*************************/
  /* part 2:  differences  */
  /*************************/
  forv group = $grouplist { 

    /* first get the "true" set */
    qui {
      use $tmp/ihds_data_expanded, clear 
      bound_param [aw=wt] if bc == 1960 & group == `group', s(0) t(50) xvar(father_ed_rank_`shortstr') yvar(`child'_ed_rank) forcemono qui
      local lb_1960 = `r(mu_lb)'
      local ub_1960 = `r(mu_ub)'
      
      bound_param [aw=wt] if bc == 1980 & group == `group', s(0) t(50) xvar(father_ed_rank_`shortstr') yvar(`child'_ed_rank) forcemono qui
      local lb_1980 = `r(mu_lb)'
      local ub_1980 = `r(mu_ub)'
      
      local lb_diff = `lb_1980'-`ub_1960' 
      local ub_diff = `ub_1980'-`lb_1960' 
      
      insert_into_file using $out/interm/change_time_`child'.csv, key(est_change_`group'_lb) value(`lb_diff') format(%9.1f)
      insert_into_file using $out/interm/change_time_`child'.csv, key(est_change_`group'_ub) value(`ub_diff') format(%9.1f) 
      
      /* then load the bootstraps */
      use $tmp/bootstrap_mus, clear 
      keep if parent == "father" & sex == "`child'" & inlist(bc, 1960, 1980) & group == `group' & mu == "p25"
      reshape wide lb ub, i(bootstrap) j(bc)
      
      assert _N == $bs 
      gen lb_diff = lb1980 - ub1960
      gen ub_diff = ub1980 - lb1960
      
      /* count fraction overlapping bounds */ 
      count if inrange(ub1980, lb1960, ub1960) | inrange(ub1960, lb1980, ub1980) 
      local frac = `r(N)' / $bs
      insert_into_file using $out/interm/change_time_`child'.csv, key(frac_ol_`group') value(`frac') format(%9.3f)
      
      /* implement with a 95% ci */ 
      bootstrap_ci, lbtrue(`lb_diff') ubtrue(`ub_diff') lbvar(lb_diff) ubvar(ub_diff) width(90) bootstraps($bs)
    }
    di "`child'-`bc'-`group', original: (" %5.2f `lb_diff' " , " %5.2f `ub_diff' "), bootstrap ci: (" %5.2f `r(bs_lb)' "," %5.2f `r(bs_ub)' ")"
    local bs_lb = `r(bs_lb)'
    local bs_ub = `r(bs_ub)'

    insert_into_file using $out/interm/change_time_`child'.csv, key(change_`group'_lb) value(`bs_lb') format(%9.1f)
    insert_into_file using $out/interm/change_time_`child'.csv, key(change_`group'_ub) value(`bs_ub') format(%9.1f) 
    
  }
}

foreach child in $childlist {
  table_from_tpl, t($mobcode/a/table_change_time_tpl.tex) r($out/interm/change_time_`child'.csv) o($out/table_change_time_`child'.tex)
}
