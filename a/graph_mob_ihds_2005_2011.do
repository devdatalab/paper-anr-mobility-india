/*******************************************************************************************/
/* SHOW MOBILITY CHANGE OVER TIME USING SAME COHORTS IN IHDS-2005 AS WE HAVE IN IHDS-2011  */
/* This is a test of survivorship bias. These should be the same individuals, so we should */
/* get the same results.                                                                   */
/*******************************************************************************************/

/* generate mu-0-50 from IHDS 2005, the same as we did in calc_ihds_mus.do */
use $mobility/ihds/ihds_mobility_2005, clear

/* We want to loop over groups, and do all groups. To do this,
   duplicate the dataset and set group to 0 for the duplicates. */
assert !mi(group)
expand 2, gen(new)
replace group = 0 if new == 1
drop new

/* limit to father-son pairs with no missing data */
keep if male == 1 & !mi(father_ed) & !mi(son_ed)

global f $tmp/test-2005.csv
cap erase $f
append_to_file using $f, s(lb, ub, bc, mu, y, parent, sex, group)

/* loop over birth cohorts */
forval group = 0/4 {
  foreach bc in $bc_list {
    di "`bc'-`group'"
    count if group == `group' & bc == `bc'
    bound_param [aw=wt] if bc == `bc' & group == `group', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono qui
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',mu50-2005,rank,father,son,`group')
  }
}

/* save in Stata format */
insheet using $tmp/test-2005.csv, clear names
save $tmp/test-2005, replace

/* append to 2011 results */
insheet using $mobility/bounds/ihds_mob_mus.csv, clear names
append using $tmp/test-2005

/* keep only the 2011 results that are interesting to compare */
keep if parent == "father" & sex == "son" & y == "rank" & inlist(mu, "p25", "mu50-2005")

/* drop 1985 group since they weren't old enough in 2005 IHDS */
drop if bc == 1985

/* focus on the combined mobility estimate */
keep if group == 0

/* recode X axis to show middle of birth cohort for each group */
get_bc_mid

/* nudge the lines a bit so we can see both */
replace bc_mid = bc_mid + 0.5 if mu == "p25"
replace bc_mid = bc_mid - 0.5 if mu == "mu50-2005"

/* graph the change in mobility bounds over time */
twoway ///
    (rcap lb ub bc_mid if mu == "p25"      , lwidth(medthick) ) ///
    (rcap lb ub bc_mid if mu == "mu50-2005", lwidth(medthick) lpattern(-)) ///
    , legend(rows(2) region(lcolor(gs3)) ring(0) pos(2) lab(1 "IHDS (2012)") lab(2 "IHDS (2005)")) ///
    xtitle("Birth Cohort") ytitle("Bottom Half Mobility")
graphout mob_survivor, pdf

