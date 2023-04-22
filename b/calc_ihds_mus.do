/**************************************************************/
/* Calculate mu-0-50 and mu-50-100 for all groups of interest */
/**************************************************************/
use $mobility/ihds/ihds_mobility.dta, clear

/* We want to loop over groups, and do all groups. To do this,
   duplicate the dataset and set group to 0 for the duplicates. */
assert !mi(group)
expand 2, gen(new)
replace group = 0 if new == 1
drop new

/* set up csv file to write data to */
cap mkdir $mobility/bounds
global f $mobility/bounds/ihds_mob_mus.csv

cap erase $f
append_to_file using $f, s(lb, ub, bc, mu, y, parent, sex, group)

/* cycle through all subgroups for mobility calculation */
/* loop over birth cohorts */
foreach bc in $bc_list {

  /* loop over upward/downward mob.
     p notation is shorthand -- these aren't chetty's ps.
     p25->mu-0-50. p75->mu-50-100. p40->mu-0-80 */
  foreach p in 25 40 75 {
    local s = `p' - 25
    local t = `p' + 25
    if `p' == 40 {
      local s = 0
      local t = 80
    }

    /* loop over child gender */
    foreach csex in s d {
      local csexs son
      local csexd daughter

      /* loop over mother / father */
      foreach parent in mother father {
        
        di "`bc'-`s'-`parent'-`csex`csex''..."
        
        /* loop over all subgroups (where 0 = everyone) */
        forval group = 0/4 {

          /* do group 0 only for moms */
          if "`parent'" == "mother" & `group' > 0 continue
          
          /* calculate mobility, y = ed_rank */
          bound_param [aw=wt] if bc == `bc' & group == `group', s(`s') t(`t') xvar(`parent'_ed_rank_`csex') yvar(`csex`csex''_ed_rank) forcemono qui
          append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p`p',rank,`parent',`csex`csex'',`group')
  
          /* calculate mobility, y = ed level ( Prim+, Mid+, HS+, Uni+)  */
          if "`parent'" == "mother" continue
          foreach ed in prim mid hs uni {
  
            bound_param [aw=wt] if bc == `bc' & group == `group', s(`s') t(`t') xvar(`parent'_ed_rank_`csex') yvar(`csex`csex''_`ed') forcemono qui
            append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p`p',`ed',`parent',`csex`csex'',`group')
          }
        }
      }
    }
  }
}


