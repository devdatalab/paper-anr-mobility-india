/*****************************************/
/* short program to prep mobility files  */
/*****************************************/
capture pr drop prep_mob
pr define prep_mob

  /* set cohort groups for rank generation */
  egen decade = cut(birth_year), at(1910(10)2000)
  replace decade = 1985 if inrange(birth_year,1985,1989)
  
  /* drop if missing father data or birth year */
  drop if mi(father_ed) | mi(birth_year)

  /* rank sons and fathers within decade groups */
  capdrop son_ed_rank father_ed_rank_s father_ed_rank_d
  gen_wt_ranks son_ed,    gen(son_ed_rank)    weight(wt) by(decade)
  gen_wt_ranks father_ed if !mi(son_ed)     , gen(father_ed_rank_s) weight(wt) by(decade)
  gen_wt_ranks father_ed if !mi(daughter_ed), gen(father_ed_rank_d) weight(wt) by(decade)
  gen_wt_ranks father_ed                    , gen(father_ed_rank) weight(wt) by(decade)

end


/************************************************/
/* load merged jati data and prep for analysis  */
/************************************************/
use "$mobility/ihds_2011_jati_aa.dta", clear

/* drop muslims and STs */
drop if inlist(group, 2, 4)

/* merge with our mobility dataset */
merge 1:1 idperson using $mobility/ihds/ihds_mobility, assert(match using) nogen  keep(match)

prep_mob  

/* create fixed effects */
/* create 3-year cohorts and drop years outside sample */
egen cohort = cut(birth_year), at(1951(3)1990)

/* limit sample to 1950-1992 */
drop if mi(cohort)
drop if birth_year <= 1950 

/* drop if we don't have jati info */
drop if mi(jati)

/* create fixed effects from cassan spec */
egen jati_region = group(jati reg)
egen region_cohort = group(reg cohort)
egen jati_cohort = group(jati cohort)

/* create regression indicators */
gen late = sc76 == 0
gen post = decade >= 1970
gen post_late = late * post

/* generate separate indicators for every decade that is post for flexible regs */
gen late_1960  = late * (decade == 1960)
gen late_1970  = late * (decade == 1970 | decade == 1975)
gen late_1980  = late * (decade == 1980 | decade == 1985)
label var post_late "Post * Late SC"
label var late_1960 "1960-69 * Late SC"
label var late_1970 "1970-79 * Late SC"
label var late_1980 "1980-89 * Late SC"

/* review father ranks to find a consistent rank definition across years */ 
/* suggests rank 60 is a good threshold */
table decade father_ed [pw=wt], c(mean father_ed_rank_s)

/*********************************************************************************/
/* Main cassan spec, condition on being in bottom 50% of cohort (or near to it)  */
/*********************************************************************************/
save $tmp/jati, replace

/********** generate main regressors and fixed effects *********/ 

/* focus first on men */
keep if male == 1

/* with full Cassan FEs, upward defined based on father ed rank < 50 */
eststo clear
eststo: reghdfe son_ed_rank sc63 post_late if sc == 1 & sc77 == 1 & father_ed_rank_s <= 60 & decade >= 1950 [pw=wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) cluster(jati reg)

/* define based on father ed == 0 */ 
eststo: reghdfe son_ed_rank sc63 post_late if sc == 1 & sc77 == 1 & father_ed == 0 & decade >= 1950 [pw=wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) cluster(jati reg)

/* FEs + post x year interactions */ 
eststo: reghdfe son_ed_rank sc63 late_1970 late_1980 if sc == 1 & sc77 == 1 & ///
    father_ed_rank_s <= 60 & decade >= 1950 [pw =wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) ///
    cluster(jati reg)


estout_default using $out/mech_cassan, order(post_late late_1970 late_1980) 

/*************************************/
/* repeat these same specs for women */
/*************************************/
use $tmp/jati, clear
eststo clear

/* focus on women */
keep if male == 0

/* column 1 */
eststo: reghdfe daughter_ed_rank sc63 post_late if sc == 1 & sc77 == 1 & father_ed_rank_d <= 60 & decade >= 1950 [pw=wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) cluster(jati reg)

/* column 2 */ 
eststo: reghdfe daughter_ed_rank sc63 post_late if sc == 1 & sc77 == 1 & father_ed == 0 & decade >= 1950 [pw=wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) cluster(jati reg)

/* column 3 */ 
eststo: reghdfe daughter_ed_rank sc63 late_1970 late_1980 if sc == 1 & sc77 == 1 & ///
    father_ed_rank_d <= 50 & decade >= 1960 [pw=wt], ///
    absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) ///
    cluster(jati reg)

estout_default using $out/mech_cassan_women, order(post_late late_1970 late_1980) 

/******************************************************/
/* ------------------ cell: mob by cohort figure ------------------ */
/******************************************************/
use $tmp/jati, clear

keep if male == 1

/********* prep .csv ********/
global g $tmp/jati_mob.csv
cap erase $g
append_to_file using $g, s(lb, ub, sc_group, param, cohort)

/* keep sample period of interest */
keep if decade >= 1950 & decade < 1990

/* calculate mu50s and store in a csv file */
levelsof decade, local(decades)
foreach decade in  `decades' { 
  
  bound_param [aw=wt] if decade == `decade' & sc63 == 1 & sc77 == 1 & sc == 1, s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
  append_to_file using $g, s(`r(mu_lb)',`r(mu_ub)',early,mu,`decade')

  bound_param [aw=wt] if decade == `decade' & sc63 == 0 & sc77 == 1 & sc == 1, s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
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
replace cohort = cohort + 5 if cohort < 1970
replace cohort = cohort + 2.5 if cohort >= 1970

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

/* outsheet CSV to reproduce graph */
export delimited ub lb cohort sc_group using $tmp/mob/aa.csv, replace

/***************************************************************/
/* robustness of AA regression results by different post years */
/***************************************************************/
foreach group in boy girl {

  use $tmp/jati, clear
  
  if "`group'" == "boy" {
    keep if male == 1
    local father_ed father_ed_rank_s
    local child_rank son_ed_rank
    local start_year 1956
  }
  if "`group'" == "girl" {
    keep if male == 0
    local father_ed father_ed_rank_d
    local child_rank daughter_ed_rank
    local start_year 1966
  }
  
  cap erase $tmp/aa_coefs.csv
  append_to_file using $tmp/aa_coefs.csv, s("b, se, p, n, year")
  
  /* run the regression using different definitions of which birth cohort is the first treated  */
  qui forval late_year = `start_year'/1986 {
    noi di "`late_year'"
    
    /* replace definition of `post` for post*late */
    capdrop post post_late
    gen post = birth_year >= `late_year'
    gen post_late = late * post
  
    /* run the regression of interest */
    reghdfe `child_rank' sc63 post_late if sc == 1 & sc77 == 1 & `father_ed' <= 60 & decade >= 1950 [pw=wt], absorb(region_cohort jati_region jati_cohort birth_year ihds_religion) cluster(jati reg)
  
    /* store the coefficient */
    append_est_to_file using $tmp/aa_coefs.csv, b(post_late) suffix(`late_year')
  }
  tab sc76 sc63 if e(sample)
  
  import delimited using $tmp/aa_coefs.csv, clear varnames(1)
  
  gen b_high = b + 1.96 * se
  gen b_low  = b - 1.96 * se
  winsorize b_high -20 20, replace
  winsorize b_low -20 20, replace

  gen age_at_change = 1976 - year 

  twoway ///
      (rcap b_low b_high age, lwidth(medthick)) ///
      (scatter b age), xscale(rev) ylabel(-20(5)20, labsize(medlarge)) xtitle("Age at Policy Change", size(large)) ytitle("Coefficient on" "Post * Late SC Designation", size(large)) yline(0) xline(0) legend(off) xlabel(20(-10)-10, labsize(medlarge))
  graphout aa_time_series_`group', pdf
}
