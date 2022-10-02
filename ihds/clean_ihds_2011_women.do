/* ******************************************************************* */ 
/* Clean and save all IHDS variables from the eligible women's survey. */
/* ******************************************************************* */                                                            */

/* This file is intended to cover all basic data cleaning of the eligible
women's data file from the IHDS survey.  All data cleaning, variable
renaming, and generation of simple new variables can be done here.  If
the eligible women's data is needed downstream in the analysis, use the
data file output by this file ($ihds/ihds_2011_ew) as opposed to the
raw data to ensure consistency. */

/* open up the IHDS 2011 eligible women's file */
use $ihds/raw/2011/36151-0003-Data, clear
ren *, lower

/* rename the unique household identifier to be hhid to match the household data */
ren hhid ihds_hhid_part
ren idhh hhid

/* create district identifier */
ren district ihds_district_name
gen district = stateid + distid

/* rename variables to be interpretable */
ren ro6 marital
ren ew5 relation
ren ew6 age
ren ew8 ed
ren ew15a mother_ed
ren ew15b father_ed
ren ew15c mother_in_law_ed
ren ew15d father_in_law_ed
ren ew18a brother_highest_ed
ren ew18b sister_highest_ed
ren ew18c brother_in_law_highest_ed
ren ew18d sister_in_law_highest_ed
ren income hh_income
ren groups ihds_religion
ren id13 ihds_caste
ren fh5ck number_children
ren fh6 number_still_births 
ren fh7 number_miscarriages
ren fp1 is_pregnant

/* get "household head father ed" and weight fields from clean household file */
local varlist hhid head_father_ed wt indwt fwt indfwt
merge m:1 hhid using $ihds/ihds_2011_hh, keepusing(`varlist')

/* keep if the hhid is present in both the eligible women's and household survey */
keep if _merge == 3 
drop _merge

/* sort by household and age */
sort hhid age 

/* loop over sister and brother's highest ed */
foreach var in brother_highest_ed sister_highest_ed brother_in_law_highest_ed sister_in_law_highest_ed {

  /* replace 55 with missing */
  replace `var' = . if `var' == 55
  tab `var'
}

/* generate the birth cohort */
gen birth_year = 2011 - age 

/* ******************************************************** */
/* create granular education and binned education variables */
/* ******************************************************** */

/* create binned and granular ed vars for all members */
foreach var in ed mother_ed father_ed mother_in_law_ed father_in_law_ed {
  
  /* rename education variables to be granular */
  ren `var' `var'_granular
  
  /* bin eduction variables at specific benchmarks */
  gen     `var' = 0  if inrange(`var'_granular, 0, 0)
  replace `var' = 2  if inrange(`var'_granular, 1, 4) 
  replace `var' = 5  if inrange(`var'_granular, 5, 7) 
  replace `var' = 8  if inrange(`var'_granular, 8, 9) 
  replace `var' = 10 if inrange(`var'_granular, 10, 11) 
  replace `var' = 12 if inrange(`var'_granular, 12, 13) 
  replace `var' = 14 if inrange(`var'_granular, 14, 16) 

  label var `var' "Completed years of education, coded to SECC/NSS categories"
}

/* create school completion indicators */
gen prim = (ed >= 5) if !mi(ed) 
gen hs  = (ed >= 12) if !mi(ed)
gen uni = (ed >= 14) if !mi(ed)
label variable prim "achieved primary level education or higher"
label variable hs "achieved high school level education or higher"
label variable uni "achieved university level education or higher"

/* **************************************************** */
/* recode caste for consistency across two IHDS surveys */
/* **************************************************** */
/* reassign "Other" designation to be "Forward" */
recode ihds_caste 6 = 2
capture label define ihds_caste 1 "Brahmin" 2 "Forward / Other" 3 "OBC" 4 "SC" 5 "ST"
label values ihds_caste ihds_caste

/* define caste and religion variables */
gen sc_st = inlist(ihds_caste, 4, 5)
gen sc = ihds_caste == 4
gen st = ihds_caste == 5
gen muslim = ihds_religion == 6

/* create social group / religion variable */
gen group = 1 if sc_st == 0
replace group = 2 if muslim == 1
replace group = 3 if sc == 1
replace group = 4 if st == 1
capture label define group 1 "Forward / Other" 2 "Muslim" 3 "SC" 4 "ST"
label values group group 

save $ihds/ihds_2011_ew, replace
