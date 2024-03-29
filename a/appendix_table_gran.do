/*******************************************************************/
/* Makes an appendix table comparing granular to non-granular mus  */
/*******************************************************************/

/*************************************************************/
/* Calculate mus using granular ed data instead of downcoded */
/* - focus is on content of Table 2                          */
/*************************************************************/

/* open IHDS dataset with matched parent/children  */
use $mobility/ihds/ihds_mobility.dta, clear

/* create granular son/daughter ed vars */
gen son_ed_granular = child_ed_granular if male == 1
gen daughter_ed_granular = child_ed_granular if male == 0

/* combine 80-84 and 85-89 birth cohorts for consistency with T2 & 3 (i.e. for power) */
recode bc 1985=1980

/* replace non-granular eds with granular eds and rerank */
drop *rank*
foreach v in father son daughter child {
  ren `v'_ed `v'_ed_downcoded
  ren `v'_ed_granular `v'_ed
}
rerank, by(bc)

/* We want to loop over groups, and do all groups. To do this,
   duplicate the dataset and set group to 0 for the duplicates. */
assert !mi(group)
expand 2, gen(new)
replace group = 0 if new == 1
drop new

/* set up csv file to write data to */
cap mkdir $mobility/bounds
global f $mobility/bounds/ihds_mob_granular_mus.csv

cap erase $f
append_to_file using $f, s(lb, ub, bc, mu, y, parent, sex, group)

/* cycle through all subgroups for mobility calculation */
/* loop over birth cohorts */
foreach bc in 1960 1980 {

  /* loop over upward/downward mob.
     p notation is shorthand -- these aren't chetty's ps.
     p25->mu-0-50. p75->mu-50-100. p40->mu-0-80 */
  foreach p in 25 {
    local s = `p' - 25
    local t = `p' + 25

    /* loop over child gender */
    foreach csex in s {
      local csexs son

      /* loop over mother / father */
      foreach parent in father {
        
        di "`bc'-`s'-`parent'-`csex`csex''..."
        
        /* loop over all subgroups (where 0 = everyone) */
        forval group = 0/4 {

          /* calculate mobility, y = ed_rank */
          bound_param [aw=wt] if bc == `bc' & group == `group', s(`s') t(`t') xvar(`parent'_ed_rank_`csex') yvar(`csex`csex''_ed_rank) forcemono qui
          append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p`p',rank,`parent',`csex`csex'',`group')
        }
      }
    }
  }
}

/***************/
/* MAKE TABLES */
/***************/

/********************/
/* PANEL: granular  */
/********************/
/* extract mus from calc mu bounds to put into template  */
cap mkdir $out/interm
import delimited using $f, clear
forv group = 0/4 {
  foreach bc in 1960 1980 {
    
    sum lb if group == `group' & bc == `bc'
    assert `r(N)' == 1 
    insert_into_file using $out/interm/gran_mob.csv, key(g`group'_`bc'_lb) value(`r(mean)') format(%9.1f)        

    sum ub if group == `group' & bc == `bc'
    assert `r(N)' == 1 
    insert_into_file using $out/interm/gran_mob.csv, key(g`group'_`bc'_ub) value(`r(mean)') format(%9.1f)        
    
  }
}

table_from_tpl, t($mobcode/a/gran_table_tpl.tex) r($out/interm/gran_mob.csv) o($out/table_gran.tex)

/******************/
/* PANEL: Binned  */
/******************/
/* extract mus from calc mu bounds to put into template  */
use $mobility/ihds/ihds_mobility, clear

/* combine 80-84 and 85-89 birth cohorts for consistency with T2 & 3 (i.e. for power) */
recode bc 1985=1980
rerank, by(bc)

/* We want to loop over groups, and do all groups. To do this,
   duplicate the dataset and set group to 0 for the duplicates. */
assert !mi(group)
expand 2, gen(new)
replace group = 0 if new == 1
drop new

forv group = 0/4 {
  foreach bc in 1960 1980 {

    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono qui
    insert_into_file using $out/interm/binned_mob.csv, key(g`group'_`bc'_lb) value(`r(mu_lb)') format(%9.1f)        

    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono qui
    insert_into_file using $out/interm/binned_mob.csv, key(g`group'_`bc'_ub) value(`r(mu_ub)') format(%9.1f)        
    
  }
}

table_from_tpl, t($mobcode/a/gran_table_tpl.tex) r($out/interm/binned_mob.csv) o($out/table_gran_binned.tex)
