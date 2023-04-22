/* ************************************************************ */ 
/* Clean and save all IHDS variables from the members survey.   */
/* ************************************************************ */

/* This file is intended to cover all basic data cleaning of the
members data file from the IHDS survey.  All data cleaning,
variable renaming, and generation of simple new variables can be
done here.  If the members data is needed downstream in the analysis,
use the data file output by this file ($ihds/ihds_2011_members)
as opposed to the raw  data to ensure consistency. */

/* open up IHDS 2011 members file */
use $ihds/raw/2011/36151-0001-Data, clear
rename *, lower

/* rename the unique household identifier to be hhid to match the household data */
ren hhid ihds_hhid_part
ren idhh hhid

/* rename variables so that they are interpretable */
ren ro4 relation
ren ro5 age
ren ro6 marital
ren ed2 lit_ihds
ren ed3 ed_english_ability
ren ed4 ed_attended_school
ren ed5 ed_enrolled_now
ren ed6 ed
ren ed7 ed_ever_repeated
ren ed8 ed_secondary_class
ren ed9 ed_post_sec
ren ed10 ed_post_2nd_subject
ren ed11 ed_college
ren ed12 ed_highest_degree
ren ed13 ed_degree_class
ren urban2011 urban
ren income hh_income
ren groups ihds_religion
ren id13 ihds_caste
ren wsearn earnings
ren wsearnhourly wage

/* merge some household vars into the individual data */
local varlist hhid indwt indfwt id12anm id12bnm nf1a nf1b head_father_ed head_father_occupation head_father_industry
merge m:1 hhid using $ihds/ihds_2011_hh, keep(match) keepusing(`varlist') nogen

/* generate a male/female dummy */
gen male = (ro3 == 1) 

/* calculate household size */
bys hhid: egen num_members = count(personid)

/* calculate number under 14 */
drop if mi(age)
bys hhid: egen num_kids = total(age < 14)
gen num_adults = num_members - num_kids

/* generate the birth cohort */
gen birth_year = 2011 - age 

/* sort by household and sex */
sort hhid age male

/* ******************************************************** */
/* create granular education and binned education variables */
/* ******************************************************** */

/* create granular and binned versions of all ed variables */
foreach var in ed head_father_ed {

  /* rename education variables to be granular */
  ren `var' `var'_granular
  
  /* bin eduction variables at specific benchmarks */
  gen `var' = 0  if inrange(`var'_granular, 0, 0)
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
/* reassign "Other" designation to be "Forward/Other" */
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

/******************************/
/* create some wage variables */
/******************************/
/* restrict earnings and wages to people with positive values */
replace earnings = . if earnings == 0
replace wage = . if wage == 0

/* generate and winsorize household per capita consumption */
gen mpce = cototal / num_members
tag hhid
sum mpce  [aw=wt] if htag, d
winsorize mpce 6000 121000, replace
gen ln_mpce = ln(mpce)

/************************************************/
/* identify individuals with coresident fathers */
/************************************************/
/* ways to have a father in the house:
- you are head (1), father (6-m) is present
- you are son/daughter (3), head(1) or husband(2) is present
- you are grandchild (5), son(3-m) is present
*/

/* first, identify which of these potential fathers are in the house */
/* indicator: father of hh head is present */
bys hhid: egen hh_has_head_f = max((relation == 6) & (male == 1))

/* indicator: head or husband of head is present */
bys hhid: egen hh_has_head = max((male == 1) & inlist(relation, 1, 2))

/* indicator: son is present */
bys hhid: egen hh_has_son = max((male == 1) & (relation == 3))

/* indicator: sibling of hh head is present */
bys hhid: egen hh_has_sibling = max((male == 1) & (relation == 7))

/* create a placeholder for having a father in the house */
/* leave missing for relations for whom we can't tell if father is present */
gen has_father_in_hh = 0 if inlist(relation, 1, 2, 3, 5, 6, 7)
replace has_father_in_hh = 0 if relation == 9 & hh_has_sibling == 0

/* mark heads with fathers in house */
replace has_father_in_hh = 1 if hh_has_head_f == 1 & relation == 1

/* mark children of head with head in house */
replace has_father_in_hh = 1 if hh_has_head == 1 & relation == 3

/* mark grandchildren with a son of head in the house */
replace has_father_in_hh = 1 if hh_has_son == 1 & relation == 5

/* drop intermediate variables used to generate father_in_hh */
drop hh_has_son hh_has_head hh_has_head_f hh_has_sibling

/*******************/
/* save clean IHDS */
/*******************/
save $ihds/ihds_2011_members, replace

