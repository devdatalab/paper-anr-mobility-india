/* ************************************************************ */ 
/* Clean and save all IHDS variables from the household survey. */
/* ************************************************************ */                                                            

/* This file is intended to cover all basic data cleaning of the
household data file from the IHDS survey.  All data cleaning,
variable renaming, and generation of simple new variables can be
done here.  If the household data is needed downstream in the
analysis, use the data file output by this file ($ihds/ihds_2011_hh)
as opposed to the raw data to ensure consistency. */

/* open up IHDS 2011 household file */
use $ihds/raw/2011/36151-0002-Data.dta, clear 

/* rename variables so that they are interpretable */
rename *, lower
ren district ihds_district_name
ren groups ihds_religion
ren income hh_income
ren id13 ihds_caste 
ren id18a head_father_occupation
ren id18b head_father_industry
ren id18c head_father_ed
ren nf1 has_business
label variable head_father_ed "education of the father of the household head / husband of the household head"

/* make hhid the unique identifier for each household in the dataset */
ren hhid ihds_hhid_part
ren idhh hhid

/* drop any households missing hhid */
drop if mi(hhid)

/* create district identifier */
gen district = stateid + distid

/* **************************************************** */
/* recode caste for consistency across two IHDS surveys */
/* **************************************************** */
/* reassign "Other" designation to "Forward/Other" */
recode ihds_caste 6 = 2
label define ihds_caste 1 "1 Brahmin" 2 "2 Forward / Other" 3 "3 OBC" 4 "4 SC" 5 "5 ST"
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
label define group 1 "Forward / Other" 2 "Muslim" 3 "SC" 4 "ST"
label values group group 

/* save clean IHDS before we do any dropping */
save $ihds/ihds_2011_hh, replace
