
/****************************************************************************************/
/* calculate various numbers used in the paper and store them in $out/mob_constants.csv */
/****************************************************************************************/

/* SHARE OF BOTTOM-CODED PARENTS IN 1960-69 and 1985-89 */
use $mobility/ihds/ihds_mobility, clear

foreach y in 1960 1985 {
  sum wt if !mi(father_ed_rank_s) & !mi(son_ed_rank) & bc == `y'
  local wt_all = `r(mean)' * `r(N)'
  sum wt if !mi(father_ed_rank_s) & !mi(son_ed_rank) & father_ed == 0 & bc == `y'
  local wt_0 = `r(mean)' * `r(N)'
  
  local fedb`y' = `wt_0' / `wt_all'
  store_tex_constant, file($out/mob_constants) idshort(fedb`y') idlong(zero_father_share_`y') value(`fedb`y'') ///
                      desc("Share of fathers in `y's with bottom-coded education")
}

/**************************************************/
/* MUSLIM / SC MOBILITY BOUNDS IN 1960S AND 1985S */
/**************************************************/
/* open mobility estimates file */
import delimited using $mobility/bounds/ihds_mob_mus.csv, clear

/* keep the Muslim / SC results */
keep if inlist(group, 1, 2, 3, 4) & inlist(bc, 1960, 1985) & sex == "son" & parent == "father" & y == "rank" & mu == "p25"
sort group
list

/****************************************************/
/* U.S. BLACK / WHITE / POPULATION MOBILITY NUMBERS */
/****************************************************/
use $mobility/us/us_ed_mobility_clean, replace

/* calculate mu-0-50 for men/women, for all races, whites, blacks */
foreach race in all white black {
  foreach gender in f m {
    bound_param if gender == "`gender'" & race == "`race'", xvar(par_rank) yvar(kid_rank) s(0) t(50)
    local mid = (`r(mu_ub)' + `r(mu_lb)') / 2
    stc, file($out/mob_constants) idshort(us_mu_`gender'_`race') idlong(us_mu_0_50_`gender'_`race') value(`mid') ///
        desc("Upward mobility U.S. `gender' `race'")
  }
}

/* calculate p25 -- for CRIW presentation */
bound_param if gender == "f" & race == "all", xvar(par_rank) yvar(kid_rank) s(25) t(25)
bound_param if gender == "m" & race == "all", xvar(par_rank) yvar(kid_rank) s(25) t(25)

