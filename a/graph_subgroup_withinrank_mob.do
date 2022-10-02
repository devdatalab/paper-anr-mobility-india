/************************************************************/
/* Calculate mu-0-50 for within and across rank definitions */
/************************************************************/
use $mobility/ihds/ihds_mobility.dta, clear

/* set up csv file to write data to */
cap mkdir $mobility/bounds
global f $mobility/bounds/ihds_mob_mus_within.csv

cap erase $f
append_to_file using $f, s(lb, ub, bc, mu, sex, group)

/* calculate father education rank within group-birth cohort */
group bc group
gen_wt_ranks father_ed if !mi(son_ed), gen(father_ed_rank_within) weight(wt) by(bggroup)

/* show ranks of forwards, Muslims, SCs in 1960 and 1985 */
twoway ///
    (scatter father_ed_rank_s father_ed_rank_within if group == 1 & bc == 1960) ///
    (scatter father_ed_rank_s father_ed_rank_within if group == 2 & bc == 1960) ///
    (scatter father_ed_rank_s father_ed_rank_within if group == 3 & bc == 1960) ///
    , legend(lab(1 "1960-Forward") lab(2 "1960-Muslim") lab(3 "1960-SC")) ///
    xlabel(0(20)100) ylabel(0(20)100)
graphout rank_within_1960
twoway ///
    (scatter father_ed_rank_s father_ed_rank_within if group == 1 & bc == 1985) ///
    (scatter father_ed_rank_s father_ed_rank_within if group == 2 & bc == 1985) ///
    (scatter father_ed_rank_s father_ed_rank_within if group == 3 & bc == 1985) ///
    , legend(lab(1 "1985-Forward") lab(2 "1985-Muslim") lab(3 "1985-SC")) ///
    xlabel(0(20)100) ylabel(0(20)100)
graphout rank_within_1985

/* list comparison of two measures in bottom 2 bins */
table group father_ed if bc == 1960, c(mean father_ed_rank_s mean father_ed_rank_within) format(%5.0f)
table group father_ed if bc == 1985, c(mean father_ed_rank_s mean father_ed_rank_within) format(%5.0f)

/* cycle through all subgroups for mobility calculation */
/* loop over birth cohorts */
foreach bc in $bc_list {

  /* loop over all subgroups of interest */
  forval group = 1/4 {

    /* calculate mobility, y = ed_rank, entire birth cohort ranks */
    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono qui
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',mu50-across,son,`group')
  
    /* calculate mobility, y = ed_rank, within-bc-subgroup ranks */
    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(50) xvar(father_ed_rank_within) yvar(son_ed_rank) forcemono qui
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',mu50-within,son,`group')

    /* repeat for mu-0-60 */
    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(60) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono qui
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',mu60-across,son,`group')
  
    /* calculate mobility, y = ed_rank, within-bc-subgroup ranks */
    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(60) xvar(father_ed_rank_within) yvar(son_ed_rank) forcemono qui
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',mu60-within,son,`group')
    
    /* repeat for mu-0-70 */
    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(70) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono qui
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',mu70-across,son,`group')
  
    /* calculate mobility, y = ed_rank, within-bc-subgroup ranks */
    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(70) xvar(father_ed_rank_within) yvar(son_ed_rank) forcemono qui
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',mu70-within,son,`group')
  }
}

/********************/
/* plot the results */
/********************/
import delimited using $mobility/bounds/ihds_mob_mus_within.csv, clear

/* recode X axis to show middle of birth cohort for each group */
get_bc_mid

/* drop women in 1950 -- no data */
drop if sex == "daughter" & bc < 1960

/* plot graphs with across- and within-ranks for mu-60 and mu-70 */
foreach mu in 50 60 70 {
  twoway ///
      (rarea lb ub bc_mid if mu == "mu`mu'-across" & group == 1 & sex == "son", color("32 32 32") ) ///
      (rarea lb ub bc_mid if mu == "mu`mu'-across" & group == 2 & sex == "son", color("150 150 255") ) ///
      (rarea lb ub bc_mid if mu == "mu`mu'-across" & group == 3 & sex == "son", color("252 46 24") ) ///
      (line  lb    bc_mid if mu == "mu`mu'-across" & group == 2 & sex == "son", color("75 75 125") ) ///
      (line  ub    bc_mid if mu == "mu`mu'-across" & group == 2 & sex == "son", color("75 75 125") ) ///
      , legend(size(medlarge) color(black) order(1 2 3) lab(1 "Forward") lab(2 "Muslim") lab(3 "SC")) ytitle("Expected Son Rank", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) ///
      ylabel(25(5)45,labsize(medlarge)) xscale(range(1950 1990)) xlabel(1960(10)1990,labsize(medlarge))
  graphout ihds_mob_group_across_mu`mu', pdf
  twoway ///
      (rarea lb ub bc_mid if mu == "mu`mu'-within" & group == 1 & sex == "son", color("32 32 32") ) ///
      (rarea lb ub bc_mid if mu == "mu`mu'-within" & group == 2 & sex == "son", color("150 150 255") ) ///
      (rarea lb ub bc_mid if mu == "mu`mu'-within" & group == 3 & sex == "son", color("252 46 24") ) ///
      (line  lb    bc_mid if mu == "mu`mu'-within" & group == 2 & sex == "son", color("75 75 125") ) ///
      (line  ub    bc_mid if mu == "mu`mu'-within" & group == 2 & sex == "son", color("75 75 125") ) ///
      , legend(color(black) size(medlarge) order(1 2 3) lab(1 "Forward") lab(2 "Muslim") lab(3 "SC")) ytitle("Expected Son Rank", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) ///
      ylabel(25(5)45,labsize(medlarge)) xscale(range(1950 1990)) xlabel(1960(10)1990,labsize(medlarge))
  graphout ihds_mob_group_within_mu`mu', pdf
}
