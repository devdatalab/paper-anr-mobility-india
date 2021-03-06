/*****************************************/
/* short program to prep mobility files  */
/*****************************************/
capture pr drop prep_mob
pr define prep_mob

  /* code age group */
  egen decade = cut(birth_year), at(1910(10)2000)
  replace decade = 1985 if inrange(birth_year,1985,1989)
  
  /* drop if missing son or father data */
  drop if mi(father_ed) | mi(son_ed) | mi(birth_year)

  /* rank sons and fathers within decade groups */
  capdrop son_ed_rank father_ed_rank
  gen_wt_ranks son_ed,    gen(son_ed_rank)    weight(wt) by(decade)
  gen_wt_ranks father_ed, gen(father_ed_rank) weight(wt) by(decade)
  
  /******************************************************/
end


/************************************************/
/* load merged jati data and prep for analysis  */
/************************************************/
use "$mobility/ihds_2011_jati_aa.dta", clear

/* drop muslims and STs */
drop if inlist(group,2,4)

/* focus on men */
keep if male == 1

/* merge with our mobility dataset */
merge 1:1 idperson using $mobility/ihds/ihds_mobility, assert(match using) nogen  keep(match)

prep_mob  

/*********************************************************************************/
/* Main cassan spec, condition on being in bottom 50% of cohort (or near to it)  */
/*********************************************************************************/
save $tmp/jati, replace

/********** generate main regressors and fixed effects *********/ 

/* create 3-year cohorts and drop years outside sample */
egen cohort = cut(birth_year), at(1951(3)1990)
drop if mi(cohort)
drop if birth_year <= 1950 

/* drop if we don't have jati info */
drop if mi(jati)

/* create guilhem spec fixed effects */
egen jati_region = group(jati reg)
egen region_cohort = group(reg cohort)
egen jati_cohort = group(jati cohort)

gen late = sc76 == 0
gen post = decade >= 1970
gen post_late = late * post

/* assign people to approximate bottom 50% */ 
table decade father_ed [pw=wt], c(mean father_ed_rank)

/* generate separate indicators for every decade that is post for flexible regs */
gen late_1960  = late * (decade == 1960)
gen late_1970  = late * (decade == 1970)
gen late_1980  = late * (decade == 1980 | decade == 1985)

/* full Cassan FEs, upward defined based on father ed rank < 50 */
eststo clear
eststo: reghdfe son_ed_rank sc63 post_late if sc == 1 & sc77 == 1 & father_ed_rank <= 60 & decade >= 1950 [pw =wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) cluster(jati reg)

/* define based on father ed == 0 */ 
eststo: reghdfe son_ed_rank sc63 post_late if sc == 1 & sc77 == 1 & father_ed == 0 & decade >= 1950 [pw=wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) cluster(jati reg)

/* FEs + post x year interactions */ 
eststo: reghdfe son_ed_rank sc63 late_1970 late_1980 if sc == 1 & sc77 == 1 & ///
    father_ed_rank <= 60 & decade >= 1950 [pw =wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) ///
    cluster(jati reg)

label var post_late "Post * Late SC"
label var late_1960 "1960-69 * Late SC"
label var late_1970 "1970-79 * Late SC"
label var late_1980 "1980-89 * Late SC"

estout_default using $out/mech_cassan, order(post_late late_1970 late_1980) 


/******************************************************/
/* /\* get mob by cohort figure   *\/ */
/******************************************************/
use $tmp/jati, clear

/********* prep .csv ********/
global g $tmp/jati_mob.csv
cap erase $g
append_to_file using $g, s(lb, ub, sc_group, param, cohort)

/* keep sample period of interest */
keep if decade >= 1950 & decade < 1990

/* calculate mu50s and store in a csv file */
levelsof decade, local(decades)
foreach decade in  `decades' { 
  
  bound_mobility [aw=wt] if decade == `decade' & sc63 == 1 & sc77 == 1 & sc == 1, s(0) t(50) xvar(father_ed_rank) yvar(son_ed_rank) forcemono
  append_to_file using $g, s(`r(mu_lb)',`r(mu_ub)',early,mu,`decade')

  bound_mobility [aw=wt] if decade == `decade' & sc63 == 0 & sc77 == 1 & sc == 1, s(0) t(50) xvar(father_ed_rank) yvar(son_ed_rank) forcemono
  append_to_file using $g, s(`r(mu_lb)',`r(mu_ub)',late,mu,`decade')
}

/* plot cohorts over time  */
import delimited using $g, clear
local N = _N + 1 
set obs `N'
gen year = cohort
replace year = 1970 if cohort == . 
gen low_area = 25
gen high_area = 40

/* slide everything forward to graph BCs at their median */
replace cohort = cohort + 5 if cohort < 1980
replace cohort = cohort + 2.5 if cohort >= 1980

twoway ///
    (rarea low_area high_area year if year <= 1970.5, color(gs13) lcolor(black) ///
    text(37.5 1960 "Early cohorts (1950-1970)" "(only Early SCs get AA)" ) ///
    text(37.5 1980  "Late cohorts (1971-1989)" "(all SCs get AA)" )  ) ///
    (rcap ub lb cohort if sc_group == "early", lwidth(thick)             color("190 35 20") legend(lab(2 "Member of Early SC Group")) ) ///
    (rcap ub lb cohort if sc_group == "late",  lwidth(thick) lpattern(-) color("190 190 255") lcolor(black) legend(lab(3 "Member of Late SC Group")))  ///
     (pcarrowi 30.5 1962 32.5 1964.5, color("190 35 20") lwidth(medthick)) ///
     (pcarrowi 26.6 1962 28 1964.5, color(black) lwidth(medthick)) ///
    , legend(off)   ///
    xtitle("Birth cohort") ytitle("Upward Mobility")  ///
    xlab(1950(5)1985) ///
text(30 1960 "Early SC Groups", color("190 35 20")) ///
text(26 1960 "Late SC Groups", color(black))

graphout jati_cohort_mob,  pdf 

