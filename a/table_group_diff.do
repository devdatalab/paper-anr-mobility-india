/***************************************************/
/* This generates the table of group differences.  */
/***************************************************/
/* load bootstrap program */
qui do $mobcode/b/bootstrap_from_bounds.do
cap !rm -f $out/interm/group_diff.csv

/* set parameters for loop below */
global childlist son daughter
global ylist p25 p75
global bs 1000

/* set group lists for:
    1. FWD - SC
    2. FWD - MUSLIM
    3. SC - MUSLIM
*/

global group1list 113
global group2list 322
global numgroups 3

/***************************************/
/* part 0: prep datafiles for easy i/o */
/***************************************/
import delimited using $mobility/bootstrap_bounds/decadal_ihds_mob_bootstrap_mus_$bs.csv, clear 

save $tmp/bootstrap_mus, replace

/****** construct differences *******/ 
foreach child in $childlist {
  
  local shortstr = substr("`child'", 1, 1) 
  
  foreach outcome in $ylist { 
    local p25low = 0
    local p25high = 50

    local p75low = 50
    local p75high = 100

    
    forv set = 1/$numgroups { 

      di "`child'-`outcome'-`set'"
      
      local group1 = substr("$group1list", `set', 1)
      local group2 = substr("$group2list", `set', 1)
      
      /* first get the "true" set */
      use $mobility/ihds/ihds_mobility, clear 
      bound_param [aw=wt] if bc == 1980 & group == `group1', s(``outcome'low') t(``outcome'high') xvar(father_ed_rank_`shortstr') yvar(`child'_ed_rank) forcemono qui
      local lb_group1 = `r(mu_lb)'
      local ub_group1 = `r(mu_ub)'

      bound_param [aw=wt] if bc == 1980 & group == `group2', s(``outcome'low') t(``outcome'high') xvar(father_ed_rank_`shortstr') yvar(`child'_ed_rank) forcemono qui
      local lb_group2 = `r(mu_lb)'
      local ub_group2 = `r(mu_ub)'
      
      local lb_diff = `lb_group1'-`ub_group2' 
      local ub_diff = `ub_group1'-`lb_group2' 

      insert_into_file using $out/interm/group_diff.csv, key(est_group_`group1'm`group2'_`outcome'_`child'_lb) value(`lb_diff') format(%9.1f)
      insert_into_file using $out/interm/group_diff.csv, key(est_group_`group1'm`group2'_`outcome'_`child'_ub) value(`ub_diff') format(%9.1f) 
      
      /* then load the bootstraps */
      use $tmp/bootstrap_mus, clear
      keep if parent == "father" & sex == "`child'" & inlist(bc, 1980) & inlist(group, `group1', `group2') & mu == "`outcome'"
      reshape wide lb ub, i(bootstrap) j(group)

      assert _N == $bs 
      gen lb_diff = lb`group1' - ub`group2'
      gen ub_diff = ub`group1' - lb`group2'

      /* implement with a 95% ci */ 
      bootstrap_ci, lbtrue(`lb_diff') ubtrue(`ub_diff') lbvar(lb_diff) ubvar(ub_diff) width(90) bootstraps($bs)
      di "original: (`lb_diff', `ub_diff'), bootstrap ci: (`r(bs_lb)', `r(bs_ub)')"
      local bs_lb = `r(bs_lb)'
      local bs_ub = `r(bs_ub)'    
      
      insert_into_file using $out/interm/group_diff.csv, key(group_`group1'm`group2'_`outcome'_`child'_lb) value(`bs_lb') format(%9.1f)
      insert_into_file using $out/interm/group_diff.csv, key(group_`group1'm`group2'_`outcome'_`child'_ub) value(`bs_ub') format(%9.1f) 

      /* get fraction of overlapping bounds */ 
      count if inrange(ub`group2',lb`group1',ub`group1') | inrange(ub`group1',lb`group2',ub`group2')
      local frac = `r(N)' / $bs 
      insert_into_file using $out/interm/group_diff.csv, key(frac_`group1'm`group2'_`outcome'_`child') value(`frac') format(%9.3f) 
    }
  }
}

table_from_tpl, t($mobcode/a/fo_diff_tpl.tex) r($out/interm/group_diff.csv) o($out/table_group_diff.tex)
