/**************************************/
/* ALL-INDIA NON-PARAMETRIC OVER TIME */
/**************************************/

/* PREPARE U.S. AND DENMARK AS REFERENCES */

/* Clean and store U.S. rank-rank CEF (N=100) */
use $mobility/us/chetty_rank_rank, clear 

/* keep and rename variables comparable to father_ed_rank and son_ed_rank from the ihds data */
keep par_bin kid_fam_bin
ren (par_bin kid_fam_bin) (father_ed_rank son_ed_rank)

/* set the birth cohort to 9999 for all US data */
gen bc = 9999
save $tmp/us_data, replace

/* CLEAN AND STORE DENMARK RANK-RANK CEF (n=100) */
import delimited using $mobility/europe/denmark.csv, clear

/* rename father and son education variables to match ihds data */
ren (father_ed son_ed) (father_ed_rank son_ed_rank)

/* set the birth cohort to 1111 for all Denmark data */
gen bc = 1111
save $tmp/denmark_data, replace

/* OPEN INDIA IHDS MOBILITY */
use $mobility/ihds/ihds_mobility.dta, clear

/* collapse son education variables to get mean value over father education rank levels and birth cohorts */
collapse (mean) son_ed_rank son_prim son_hs son_uni [aw=wt], by(father_ed_rank_s bc)

/* combine IHDS, US, and Denmark data */
append using $tmp/denmark_data
append using $tmp/us_data

/* graph output: son education rank vs. father education rank with denmark and usa */
twoway (scatter son_ed_rank father_ed_rank if bc == 1111, msize(small) msymbol(Sh) mcolor(gs8) )  ///
       (scatter son_ed_rank father_ed_rank if bc == 9999, mcolor(gs10) msymbol(X) msize(small) ///
       xtitle("Parent Rank") ytitle("Child Rank") legend(lab(1 "Denmark (Income)") lab(2 "US (Income)")))
graphout mob_usa_den

/* graph output: son education rank vs. father education rank with ihds 1980, usa, and denmark */
twoway (scatter son_ed_rank father_ed_rank_s if bc == 1980, msize(medlarge) msymbol(T) ///
         xlabel(0(20)100) ylabel(0(20)100) xtitle("Father Rank", size(medlarge)) ytitle("Son Rank", size(medlarge))) ///
        (scatter son_ed_rank father_ed_rank if bc == 1111, msize(small) msymbol(Sh) mcolor(gs8) )  ///
        (scatter son_ed_rank father_ed_rank if bc == 9999, mcolor(gs10) msymbol(X) msize(small)  ///
          legend(lab(1 "India 1980s Birth Cohort (Education)") lab(2 "Denmark (Income)") lab(3 "US (Income)")))  
graphout mob_ihds_vs_usa_den

/* graph output: son education rank vs. father education rank comparing 1960 vs. 1980 birth cohorts */
twoway (scatter son_ed_rank father_ed_rank_s if bc == 1980, msize(medlarge) msymbol(T) ) ///
       (scatter son_ed_rank father_ed_rank_s if bc == 1960, msize(medium) ///
         xlabel(0(20)100) ylabel(0(20)100) xtitle("Father Education Rank", size(medlarge)) ytitle("Son Education Rank", size(medlarge)) ///
         legend(lab(1 "1960s Birth Cohort") lab(2 "1980s Birth Cohort") size(medlarge)) )
graphout mob_ihds

/* graph output: son prim, hs, uni school completion vs. father education rank for 1960 and 1980 birth cohorts */
/* cycle through levels of school completion */
foreach v in prim hs uni {
  local prim_name "Primary+"
  local hs_name "High School+"
  local uni_name "College+"
  twoway (scatter son_`v' father_ed_rank_s if bc == 1960, msize(medium) ) ///
  (scatter son_`v' father_ed_rank_s if bc == 1980, msize(medlarge) msymbol(X)), ///
    xlabel(0(20)100) ylabel(0(.20)1) xtitle("Father Education Rank", size(medlarge)) ytitle("Son ``v'_name'", size(medlarge)) ///
    legend(lab(1 "1960s Birth Cohort") lab(2 "1980s Birth Cohort") size(medlarge))
  graphout mob_ihds_`v'
}

/************** version of graph that explains downward mob **********/
local n = _N+1
set obs `n'

/* create xvar that is missing for all values */
gen xvar = . if bc == .

/* set xvar to 0 if the birth cohort is missing */
replace xvar = 0 if bc == . 

/* set xvar to the father education rank if missing */
replace xvar = father_ed_rank if xvar == .
replace xvar = father_ed_rank_s if xvar == . 
replace bc = 1111 if bc == .

gen low = 0
gen high = 100
sort xvar

/* graph output: son education rank vs. father education rank for 1960 and 1980 birth cohorts, highlighting upward vs. downward mobility */
twoway (rarea high low xvar if xvar < 50 & bc == 1111, color(ltblue)) ///
       (scatter son_ed_rank father_ed_rank_s if bc == 1980, msize(medlarge) msymbol(T) msize(medium)  ) ///
       (scatter son_ed_rank father_ed_rank_s if bc == 1960, msize(medium) xlabel(0(20)100) ylabel(0(20)100) xtitle("Parent Rank", size(medlarge)) ///
          ytitle("Child Rank", size(medlarge)) ///
          text(80 25 "Upward Mobility" 20 75 "Downward Mobility") ylab(,nogrid) xlab(,nogrid) ///
          legend(order( 2 3 4 5 ) lab(2 "1960s Birth Cohort") lab(3 "1980s Birth Cohort") ))
graphout mob_ihds_shading

