/***************************************************/
/* Minimal cleaning of IHDS 2005 for mobility work */
/***************************************************/
/*
Notes:

This build isn't up to DDL standard because it mixes mobility
  preparation with IHDS 2005 cleaning.  There's no clean version of
  the IHDS 2005 that gets saved as an intermediate file for use by
  other projects. We're leaving as is rather than refactoring, but if
  we come back to the IHDS 2005 for another project, this should be
  split into separate cleaning files for each component of the IHDS
  2005, and then a separate file to build the stuff that is only
  relevant for mobility.

To indicate the incompleteness, nothing here gets saved in $ihds, only
in $mobility.

*/

/* set up some macros  */
global max_member 5

/***********************************************************/
/* JOINT HOUSEHOLD, MEMBER AND JATI FILES INTO ONE DATASET */
/***********************************************************/

/* open household file */
use $ihds/raw/2005/22626-0002-Data.dta, clear 

/* drop if no hhid-- impossible to link to members data */
drop if HHID == 0 

/* merge in jati names from the public file provided by IHDS-I */
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "$ihds/raw/2005/jatiname_public.dta", nogen keep(match) 

/* rename sweight which appears in both files */
ren SWEIGHT WT

/* merge into household data  */
merge 1:m STATEID DISTID PSUID HHID HHSPLITID using $ihds/raw/2005/22626-0001-Data.dta

/* keep only the merged households */
keep if _merge == 3
drop _merge 

/*************************************/
/* CREATE MORE USABLE VARIABLE NAMES */
/*************************************/

/* make everything lowercase */
ren *, lower

/* rename some codebook variables */
ren ro4 relation
ren ro5 age
ren ro6 marital
ren ed2 lit_ihds
ren urban urban
ren id13 ihds_caste_2005
ren groups ihds_religion

/* recode christian with sikhs/jains for consistency with IHDS 2011 */
recode ihds_religion 8=7

/* create IHDS caste variable that is consistent across rounds */
gen ihds_caste = ihds_caste_2005
recode ihds_caste 1=1 5=2 2=3 3=4 4=5
label define ihds_caste 1 "Brahmin" 2 "Forward / Other" 3 "OBC" 4 "SC" 5 "ST"
label values ihds_caste ihds_caste
drop ihds_caste_2005

/* define caste and religion variables */
gen sc_st = inlist(ihds_caste, 4, 5)
gen sc = ihds_caste == 4
gen st = ihds_caste == 5
gen muslim = ihds_religion == 6

/* create social group / religion variable */
gen group = 1 if sc_st == 0
replace group = 2 if ihds_religion == 6
replace group = 3 if sc == 1
replace group = 4 if st == 1
label define group 1 "Forward / Other" 2 "Muslim" 3 "SC" 4 "ST"
label values group group 

/* clean earnings */
ren ws8annual earnings
replace earnings = . if earnings == 0

/*  clean wages (which is earnings divided by reported hours) */
ren ws8hourly wage
replace wage = . if wage == 0

/* create district identifier */
gen district = stateid + distid

/* generate a male/female dummy */
gen male = (ro3 == 1) 

/* clean hh_head_ed. valid blank -> 0. Other missings -> missing */
ren id20 hh_head_ed
replace hh_head_ed = 0 if hh_head_ed == -1
replace hh_head_ed = . if hh_head_ed <  0

/* unclear if 88 is missing or zero-- they have v.bad SES */
replace hh_head_ed = . if hh_head_ed == 88

/* repeat for own education */
ren ed5 ed
replace ed = 0 if ed == -1 
replace ed = . if ed < 0 

/* clean household id vars */
ren hhid ihds_hhid_part
ren idhh hhid

/* generate age_rank as the oldest man in the household */
/* sort by household and sex */
sort hhid age 

/* generate male head's education for coresiders */
gen head_ed_tmp = ed if relation == 1 & male == 1
bys hhid: egen head_ed = mean(head_ed_tmp)
drop *tmp 

/* calculate father's father's education if in household */
gen tmp = ed if relation == 6 & male == 1
bys hhid: egen cores_head_father_ed = mean(tmp)
drop tmp

/* set father's education to the head's education if this is a son or daughter */
gen father_ed = head_ed if relation == 3

/* replace it as the head's father's education if this is a household head or sibling of the household head */
replace father_ed = cores_head_father_ed if inlist(relation, 1, 7)

/* set grandchildrens' father's ed to the mean of the sons' educations */
gen father_of_grandson_ed_tmp = ed if relation == 3 & male == 1
bys hhid: egen father_of_grandson_ed = mean(father_of_grandson_ed_tmp)
drop *tmp
replace father_ed = father_of_grandson_ed if relation == 5

/* generate a dummy for if the person is a coresident son  */
gen cores = !mi(father_ed)

/* get education from household questionnaire if we don't have it already */
replace father_ed = hh_head_ed if inlist(relation, 1, 7) & mi(father_ed)

/*  set coresidence variable to missing if we didn't find a father at all */
replace cores = . if father_ed == . 

/* rescale education to match secc numbers (subtract 1 if ambiguous) */
replace father_ed = floor(father_ed) 

/* create granular and binned versions of all ed variables */
foreach var in ed father_ed {

  /* rename education variables to be granular */
  ren `var' `var'_granular
  
  /* bin eduction variables at specific benchmarks */
  gen `var' = 0      if inrange(`var'_granular, 0, 0)
  replace `var' = 2  if inrange(`var'_granular, 1, 4) 
  replace `var' = 5  if inrange(`var'_granular, 5, 7) 
  replace `var' = 8  if inrange(`var'_granular, 8, 9) 
  replace `var' = 10 if inrange(`var'_granular, 10, 11) 
  replace `var' = 12 if inrange(`var'_granular, 12, 13) 
  replace `var' = 14 if inrange(`var'_granular, 14, 16) 

  label var `var' "Completed years of education, coded to SECC/NSS categories"
}

/* split son and daughter education to prevent accidental pooling */
gen son_ed = ed      if male == 1
gen daughter_ed = ed if male == 0
ren ed child_ed

/* create placeholder for mother_ed so gen_bc_ranks still works */
gen mother_ed = .

/**********************************/
/* generate education rankings    */
/**********************************/

/* generate the birth cohort */
gen birth_year = 2005 - age 

/* limit sample to 1950-1999 */
keep if inrange(birth_year, 1950, 1999)

/* generate 5- and 10-year birth cohort groups and ed ranks. */
gen_bc_ranks

/* save the IHDS data, cleaned for mobility analysis */
compress
cap mkdir $mobility/ihds
save "$mobility/ihds/ihds_mobility_2005", replace 

