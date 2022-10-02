/********************************************************/
/* EXPORT NATIONAL AND SUBGROUP DATA FOR MATLAB RESULTS */
/********************************************************/

/* note: now that we know about Matlab tables, it probably doesn't
make sense to create all these separate .csv files. But nearly all the
matlab mobility files rely on these cut up CSVs, so it's easier to
stick to this process then refactor unnecessarily. */
use $mobility/ihds/ihds_mobility, clear 

/* drop if missing data */
drop if mi(father_ed_rank_s) | mi(son_ed_rank)

/* keep 1950-1989 */
keep if inrange(birth_year, 1950, 1989)

/* generate 5- and 10-year birth cohort groups */
cap drop bc 
gen_bc_ranks

/* collapse national father-son results */
preserve
collapse (mean) son_ed_rank son_prim son_hs son_uni [aw=wt], by(father_ed_rank_s bc)
save $tmp/national_moments, replace
restore

/* collapse subgroup father-son results */
collapse (mean) son_ed_rank son_prim son_hs son_uni [aw=wt], by(father_ed_rank_s bc group)
save $tmp/subgroup_moments, replace

/* append national moments to subgroup moments */
append using $tmp/national_moments

/* set group to 0 to flag national vs. subgroup moments */
replace group = 0 if mi(group)
label drop group

/* export a file for matlab */
order group bc father_ed_rank
sort group bc father_ed_rank
drep group bc father_ed_rank
outsheet using $mobility/moments/ed_ranks_all.csv, comma replace

/* store separate CSVs for the different 10-year birth cohorts and subgroups */
forval group = 0/4 {
  foreach bc in $bc_list {
    outsheet father_ed_rank_s son_ed_rank using $mobility/moments/ed_ranks_`group'_`bc'.csv if group == `group' & bc == `bc', comma replace
  }
}
