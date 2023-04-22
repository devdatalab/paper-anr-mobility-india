/*******************************************************************/ 
/* Create parent child links from the IHDS eligible women's survey */
/*******************************************************************/

/* This file uses the cleaned eligible women data ($ihds/ihds_2011_ew.dta)
   file to create parent-child links among coresident members.

This is a complex head-spinning process -- prepare yourself!

1. We merge the full household roster to the women's survey.
   Many of these links will be missing but we may fill them in later.

2. The women's survey gives us the female respondent's parents and her
   husband's parents. We use her relationship with the household head
   to assign any parent information we can to the head.

3. Finally, we go through the roster and assign any other pairs that
   we can using the above information.

*/

/* load the clean eligible women's survey */
use $ihds/ihds_2011_ew, clear

/* drop any ineligible women from the survey */
keep if ewqelig == 1
drop ewqelig

/* rename variables to specify that they are from the women's survey */
ren ed_granular ed_granular_ew
ren mother_ed_granular mother_ed_granular_ew
ren father_ed_granular father_ed_granular_ew
ren mother_in_law_ed_granular mother_in_law_ed_granular_ew
ren father_in_law_ed_granular father_in_law_ed_granular_ew

/********************************************/
/* Merge in data from full household roster */
/********************************************/
keep idperson hhid ed_granular_ew mother_ed_granular_ew father_ed_granular_ew mother_in_law_ed_granular_ew father_in_law_ed_granular_ew wtew fwtew
label drop RO4
merge 1:m idperson using $ihds/ihds_2011_members
assert _merge != 1
drop _merge

/* only keep those between 15-100 years old */
keep if inrange(age, 15, 100)

/************************************************************************/
/* Generate education variables based on relationship to household head */
/************************************************************************/

/* IDENTIFY THE EDUCATION OF THE PARENTS OF THE HOUSEHOLD HEAD */
/* If respondent is head or head's sister, respondent's mom is head's mom */
gen tmp_mother = mother_ed_granular_ew if relation == 1 | relation == 7
gen tmp_father = father_ed_granular_ew if relation == 1 | relation == 7

/* If respondent is wife of household head, respondent's husband's mom is head's mom */
replace tmp_mother = mother_in_law_ed_granular_ew if relation == 2
replace tmp_father = father_in_law_ed_granular_ew if relation == 2
/* Note: contrary to some memos, we don't try to match sister-in-laws, because
         we don't know if they are head's wife's sister, or head's brother's wife. */

/* assign values to household head, and use mean if there is a contradiction */
bys hhid: egen head_mother_ed_ew = mean(tmp_mother)
bys hhid: egen head_father_ed_ew = mean(tmp_father)
label var head_mother_ed_ew "Mother of household head ed (from women's survey)"
label var head_father_ed_ew "Father of household head ed (from women's survey)"
drop tmp_mother tmp_father

/* IDENTIFY THE EDUCATION OF THE PARENTS OF THE HOUSEHOLD HEAD'S PARTNER */
/* if respondent is head, then mother in law is head's mother in law */
gen tmp_mother = mother_in_law_ed_granular_ew if relation == 1
gen tmp_father = father_in_law_ed_granular_ew if relation == 1

/* if respondent is wife of household head, then respondent's mother is head's mother-in-law */
replace tmp_mother = mother_ed_granular_ew if relation == 2
replace tmp_father = father_ed_granular_ew if relation == 2

/* assign values to household head, and use mean if there is a contradiction */
bys hhid: egen head_mother_in_law_ed_ew = mean(tmp_mother)
bys hhid: egen head_father_in_law_ed_ew = mean(tmp_father)
label var head_mother_in_law_ed_ew "Mother in law of household head education from ew survey"
label var head_father_in_law_ed_ew "Father in law of household head education from ew survey"
drop tmp_father tmp_mother


/*************************************************************/
/* Now create the father_ed and mother_ed variables, which   */
/*   assign a parent from the women's survey to every person */
/*   that we can.                                            */
/*************************************************************/

/* Respondent's father gets directly assigned. */
gen father_ed_ew = father_ed_granular_ew if ewqelig == 1
gen father_ed_ew_link = "father of respondent -> respondent (ew)" if !mi(father_ed_granular_ew) & ewqelig == 1
label var father_ed_ew "Father education from EW survey"
label var father_ed_ew_link "Source of father-child link from EW survey"

/* Respondent's mother gets directly assigned. */
gen mother_ed_ew = mother_ed_granular_ew if ewqelig == 1
gen mother_ed_ew_link = "mother of respondent -> respondent (ew)" if !mi(mother_ed_granular_ew) & ewqelig == 1
label var mother_ed_ew "Mother education from the ew survey"
label var mother_ed_ew_link "How the mother - child link was created from the ew survey"

/* father of household head gets assigned to household head */
replace father_ed_ew = head_father_ed_ew if relation == 1 & mi(father_ed_ew)
replace father_ed_ew_link = "father of household head -> household head (ew)" if !mi(head_father_ed_ew) & relation == 1 & mi(father_ed_ew_link)

/* mother of household head --> household head */
replace mother_ed_ew = head_mother_ed_ew if relation == 1 & mi(mother_ed_ew)
replace mother_ed_ew_link = "mother of household head -> household head (ew)" if !mi(head_mother_ed_ew) & relation == 1 & mi(mother_ed_ew_link)

/* father of household head also gets assigned to all siblings of household head */
replace father_ed_ew = head_father_ed_ew if relation == 7 & mi(father_ed_ew)
replace father_ed_ew_link = "father of household head -> sibling of household head (ew)" if !mi(head_father_ed_ew) & relation == 7 & mi(father_ed_ew_link)

/* repeat for mother */
replace mother_ed_ew = head_mother_ed_ew if relation == 7 & mi(mother_ed_ew)
replace mother_ed_ew_link = "mother of household head - sibling household head: ew" if !mi(head_mother_ed_ew) & relation == 7 & mi(mother_ed_ew_link)

/* NOTE: don't assign any parents of brother/sister-in-law, because we don't know if these are e.g. head's wife's brother, or head's brother's wife */

/* store granular and NSS/SECC binned versions of each variable */
foreach var in father mother {
  
  /* rename education variables to be granular */
  ren `var'_ed_ew `var'_ed_ew_granular
  
  /* bin eduction variables at specific benchmarks */
  gen `var'_ed_ew = 0  if inrange(`var'_ed_ew_granular, 0, 0)
  replace `var'_ed_ew = 2  if inrange(`var'_ed_ew_granular, 1, 4) 
  replace `var'_ed_ew = 5  if inrange(`var'_ed_ew_granular, 5, 7) 
  replace `var'_ed_ew = 8  if inrange(`var'_ed_ew_granular, 8, 9) 
  replace `var'_ed_ew = 10 if inrange(`var'_ed_ew_granular, 10, 11) 
  replace `var'_ed_ew = 12 if inrange(`var'_ed_ew_granular, 12, 13) 
  replace `var'_ed_ew = 14 if inrange(`var'_ed_ew_granular, 14, 16) 

  label var `var'_ed_ew "`var' education in rounded years from the eligible women's survey"
}

/* keep only the matched education variables */
keep hhid idperson father_ed_ew* mother_ed_ew*

/* save the data */
save $tmp/ihds/ihds_pc_links_ew_2011, replace
