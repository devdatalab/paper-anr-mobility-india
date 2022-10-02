/**********************************************************************/
/* PLOT CORESIDENCE OVER TIME AND BIAS IN CORESIDENCE-BASED ESTIMATES */
/**********************************************************************/

/**************************************************************/
/* PART 1: SHOW PROBABILITY OF CORESIDENCE WITH PARENT BY AGE */
/**************************************************************/
/* open full IHDS */
use $ihds/ihds_2011_members, clear

/* keep everyone younger than 60 */
keep if age < 60

/* drop everyone for whom we can't tell if there is a father in the household */
drop if mi(has_father_in_hh)

/* plot present of father in household as function of age, for boys and girls */
collapse (mean) has_father_in_hh [aw=wt], by(male age)
twoway ///
    (scatter has_father_in_hh age if male == 0) ///
    (scatter has_father_in_hh age if male == 1, msymbol(X)) ///
    , legend(rows(2) region(lcolor(gs3)) ring(0) pos(2) lab(1 "Daughters") lab(2 "Sons")) ytitle("% Has Father in Household") xtitle("Age")

graphout cores_age, pdf

/* produce statistics for paper */
list if inlist(age, 20, 23, 50)
foreach age in 20 23 50 {
  sum has_father if age == `age' & male == 0
  store_tex_constant, file($out/mob_constants) idshort(cores`age'f) idlong(cores_`age'_f) value(`r(mean)') ///
      desc("Coresident rate for father-daughter links (daughter age `age')")
  sum has_father if age == `age' & male == 1
  store_tex_constant, file($out/mob_constants) idshort(cores`age'm) idlong(cores_`age'_m) value(`r(mean)') ///
      desc("Coresident rate for father-son links (son age `age')")
}


/****************************************************************/
/* PART 2: SHOW HOW MOBILITY BIAS CHANGES WITH CORES AGE SAMPLE */
/****************************************************************/

/* open the IHDS mobility dataset */
use $mobility/ihds/ihds_mobility.dta, clear

/* keep individuals aged 15-59 */
keep if inrange(age, 15, 59)

/* drop if we can't tell if father is present */
drop if mi(has_father_in_hh)

/* duplicate observations with coresident fathers so we can use "by" in the binscatter */
expand 2 if has_father_in_hh == 1, gen(cores_only)

/* create placeholder for upward mobility mu-0-50 */
foreach b in ub lb {
  capdrop mu_`b'
  gen     mu_`b' = .
}

/* calculate upward mobility in 2-year age bins from age 15-59 */
/* store both male and female, even though only printing men */
forval age = 15/58 {
  di "`age'"
  qui capdrop sample daughter_ed_rank son_ed_rank father_ed_rank
  qui gen sample = inrange(age, `age', `age' + 1)
  qui gen_wt_ranks daughter_ed    if sample == 1, weight(wt) gen(daughter_ed_rank)
  qui gen_wt_ranks son_ed         if sample == 1, weight(wt) gen(son_ed_rank)
  qui gen_wt_ranks father_ed      if sample == 1, weight(wt) gen(father_ed_rank)
  qui foreach cores in 0 1 {
    count if sample == 1 & cores_only == `cores' & !mi(daughter_ed_rank) & !mi(father_ed_rank)
    if `r(N)' > 20 {    
      qui bound_param [aw=wt] if sample == 1 & cores_only == `cores', s(0) t(50) xvar(father_ed_rank) yvar(daughter_ed_rank) forcemono
      replace mu_ub = `r(mu_ub)' if age == `age' & cores_only == `cores' & male == 0
      replace mu_lb = `r(mu_lb)' if age == `age' & cores_only == `cores' & male == 0
    }

    count if sample == 1 & cores_only == `cores' & !mi(son_ed_rank) & !mi(father_ed_rank)
    qui bound_param [aw=wt] if sample == 1 & cores_only == `cores', s(0) t(50) xvar(father_ed_rank) yvar(son_ed_rank) forcemono
    replace mu_ub = `r(mu_ub)' if age == `age' & cores_only == `cores' & male == 1
    replace mu_lb = `r(mu_lb)' if age == `age' & cores_only == `cores' & male == 1
  }
}
save $tmp/cores_bias_estimates_tmp, replace
use $tmp/cores_bias_estimates_tmp, clear

/* collapse to one row per age */
collapse (mean) mu_lb mu_ub, by(age cores_only male)

/* keep ages under 30-- errors on larger numbers get huge at higher ages */
drop if age >= 30

/* reshape to get coresident mus in separate rows */
reshape wide mu_lb mu_ub , j(cores_only) i(age male)

/* calculate upper and lower bounds on bias  */
gen bias_lb = min(mu_lb1, mu_ub1) - max(mu_lb0, mu_ub0)
gen bias_ub = max(mu_lb1, mu_ub1) - min(mu_lb0, mu_ub0)

twoway rarea bias_lb bias_ub age if male == 1, color(gs12) lcolor(black) /// 
    ytitle("Coresidence Bias on Upward Mobility (Ranks)", size(medlarge)) ///
    xtitle("Age at Time of Survey", size(medlarge))  ///
    ylabel(0(5)15, labsize(medium)) xlabel(15(5)30, labsize(medium)) yline(0)
graphout cores_bias_upward_m, pdf

twoway rarea bias_lb bias_ub age if male == 0, color(gs12) lcolor(black) /// 
    ytitle("Coresidence Bias on Upward Mobility (Ranks)", size(medlarge)) ///
    xtitle("Age at Time of Survey", size(medlarge))  ///
    ylabel(0(5)15, labsize(medium)) xlabel(15(5)30, labsize(medium)) yline(0)
graphout cores_bias_upward_f, pdf

/************************/
/* graph cores by group */
/************************/

/* follow same build steps as above */
use $ihds/ihds_2011_members, clear
keep if age < 60
drop if mi(has_father_in_hh)

/* collapse by age / group */
collapse (mean) has_father_in_hh [aw=wt], by(male age group)

/* first plot the men */
twoway ///
    (scatter has_father_in_hh age if male == 1 & group == 1) ///
    (scatter has_father_in_hh age if male == 1 & group == 2, msymbol(X)) ///
    (scatter has_father_in_hh age if male == 1 & group == 3, msymbol(T)) ///
    (scatter has_father_in_hh age if male == 1 & group == 4, msymbol(S)) ///
    , legend(region(lcolor(gs3)) ring(0) pos(2) lab(1 "Forward/Other") lab(2 "Muslim") lab(3 "SC") lab(4 "ST")) ytitle("% Has Father in Household") xtitle("Age")
graphout cores_by_group, pdf
