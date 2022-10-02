/* program to generate a bootstrap from a bound file */

/*****************************************************************************************/
/* need to feed it a given dataset. given that dataset, it will generate upper and lower */
/* bounds. need also to feed it the true and observed moments                                                                                 */
/*****************************************************************************************/
capture pr drop bootstrap_ci
capture pr define bootstrap_ci, rclass 
syntax, lbtrue(real) ubtrue(real) [bootstraps(int 100) bootstrapvar(string) lbvar(string) ubvar(string) width(int 95)]

qui {
  
  /* initialize optional strings */ 
  if mi("`bootstrapvar'") local bootstrapvar = "bootstrap"
  if mi("`lbvar'") local lbvar = "lb"
  if mi("`ubvar'") local lbvar = "ub"

  /* convert ci into an integer quantile */
  local ci_number = ceil( (`width' / 100 ) * `bootstraps' ) // ceiling -> conservative         

  preserve
  keep if `bootstrapvar' <= `bootstraps'

  tempvar max_diff

  /* get difference from lower and upper bound.
  but only count them if they are OUTSIDE
  the true set, per Newey's notes */ 
  gen `max_diff' = ///
      max( (`lbtrue' - `lbvar')^2 * ( (`lbtrue' - `lbvar') > 0), ///
      (`ubtrue' - `ubvar')^2 * ( (`ubtrue' - `ubvar') < 0) )        

  /* get appropriate quantile */
  sort `max_diff' 
  local distance = `max_diff'[`ci_number'] 


  /* take the indicated distance and then add and/or subtract from lower bound */
  return local bs_ub = `ubtrue'+sqrt(`distance')
  return local bs_lb = `lbtrue'-sqrt(`distance')

  restore
}
end

/* 
/* example code for implementation of bootstrap bounds */
use $mobility/ihds/ihds_mobility, clear

/* first get the "true" set */ 
bound_param [aw=wt] if bc == 1985 & group == 1, s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono qui
local lb = `r(mu_lb)'
local ub = `r(mu_ub)'

/* then load the bootstraps */ 
import delimited using $mobility/bootstrap_bounds/ihds_mob_bootstrap_mus_100.csv, clear 
keep if parent == "father" & sex == "son" & bc == 1985 & group == 1 & mu == "p25" 

/* implement with a 95% ci */ 
bootstrap_ci, lbtrue(`lb') ubtrue(`ub') lbvar(lb) ubvar(ub) width(95) bootstraps(100)
di "original: (`lb', `ub'), bootstrap ci: (`r(bs_lb)',`r(bs_ub)')"

/* implement with a 90% ci */ 
bootstrap_ci, lbtrue(`lb') ubtrue(`ub') lbvar(lb) ubvar(ub) width(90) bootstraps(100)
di "original: (`lb', `ub'), bootstrap ci: (`r(bs_lb)',`r(bs_ub)')"

