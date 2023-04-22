/* ************************************************************ */ 
/* Create parent child links from the IHDS roster               */
/* ************************************************************ */

/* This file uses the cleaned member data ($ihds/ihds_2011_members.dta)
   file to create parent-child links among coresident members.

1. Generate vars describing education of each member relative to
   household head, and apply these vars to everyone in the
   household. e.g. head_husband_ed.

2. Use the above vars to generate education variables for all
   coresident parent-child relationships present in a household based
   on the roster.  We use ed_granular, and break down the categories
   later in the process.

*/

/* load the clean IHDS members data */
use $ihds/ihds_2011_members, clear

/* keep members only if between the ages 15-100 */
keep if inrange(age, 15, 100)

/**********************************************************************************/
/* Generate education variables for all family members relative to household head */
/**********************************************************************************/

/* generate education of the household head */
gen tmp = ed_granular if relation == 1
bys hhid: egen head_ed_roster = mean(tmp)
label var head_ed_roster "Household head education from the roster"
drop tmp 

/* generate gender of the household head */
gen tmp = male if relation == 1
bys hhid: egen head_male = mean(tmp)
label var head_male "Indicator for male household head (from roster)"
label define gender 1 "Male" 2 "Female"
label values head_male gender
drop tmp

/* generate education of the husband of the female household head */
gen tmp = ed_granular if relation == 2 & head_male == 0
bys hhid: egen head_husband_ed_roster = mean(tmp)
label var head_husband_ed_roster "Husband of household head from the roster"
drop tmp

/* generate education of the wife of the male household head */
gen tmp = ed_granular if relation == 2 & head_male == 1
bys hhid: egen head_wife_ed_roster = mean(tmp)
label var head_wife_ed_roster "Wife of household head from the roster"
drop tmp

/* generate education of househould head's son. This is used only to match son->grandchild of household head.  */
gen tmp = ed_granular if relation == 3 & male == 1
bys hhid: egen head_son_ed_roster = mean(tmp)
bys hhid: egen head_son_ed_sd = sd(tmp)
label var head_son_ed_roster "Son of household head education from the roster"
drop tmp

/* generate education of household head's daughter. Only used to match daughter->grandchild */
gen tmp = ed_granular if relation == 3 & male == 0
bys hhid: egen head_daughter_ed_roster = mean(tmp)
bys hhid: egen head_daughter_ed_sd = sd(tmp)
label var head_daughter_ed_roster "Daughter of household head education from the roster"
drop tmp

/* generate education of househould head's son in law */
gen tmp = ed_granular if relation == 4 & male == 1
bys hhid: egen head_son_in_law_ed_roster = mean(tmp)
label var head_son_in_law_ed_roster "Son in law of household head education from the roster"
drop tmp

/* generate education of household head's daughter in law [not used] */
gen tmp = ed_granular if relation == 4 & male == 0
bys hhid: egen head_daughter_in_law_ed_roster = mean(tmp)
label var head_daughter_in_law_ed_roster "Daughter in law of household head education from the roster"
drop tmp

/* generate education of household head's father */
gen tmp = ed_granular if relation == 6 & male == 1
bys hhid: egen head_father_ed_roster = mean(tmp)
label var head_father_ed_roster "Father of household head education from the roster"
drop tmp

/* generate education of household head's mother */
gen tmp = ed_granular if relation == 6 & male == 0
bys hhid: egen head_mother_ed_roster = mean(tmp)
label var head_mother_ed_roster "Mother of household head education from the roster"
drop tmp

/* generate education of household head's brother */
gen tmp = ed_granular if relation == 7 & male == 1
bys hhid: egen head_brother_ed_roster = mean(tmp)
bys hhid: egen head_brother_ed_sd = sd(tmp)
label var head_brother_ed_roster "Brother of household head education from the roster"
drop tmp

/* generate education of household head's sister */
gen tmp = ed_granular if relation == 7 & male == 0
bys hhid: egen head_sister_ed_roster = mean(tmp)
bys hhid: egen head_sister_ed_sd = sd(tmp)
label var head_sister_ed_roster "Sister of household head education from the roster"
drop tmp

/* generate education of household head's father in law */
gen tmp = ed_granular if relation == 8 & male == 1
bys hhid: egen head_father_in_law_ed_roster = mean(tmp)
label var head_father_in_law_ed_roster "Father in law of household head education from roster"
drop tmp

/* generate education of household head's mother in law */
gen tmp = ed_granular if relation == 8 & male == 0
bys hhid: egen head_mother_in_law_ed_roster = mean(tmp)
label var head_mother_in_law_ed_roster "Mother in law of household head education from roster"
drop tmp

/* generate education of household head's brother in law */
gen tmp = ed_granular if relation == 10 & male == 1
bys hhid: egen head_brother_in_law_ed_roster = mean(tmp)
bys hhid: egen head_brother_in_law_ed_sd = sd(tmp)
label var head_brother_in_law_ed_roster "Brother in law of household head education from the roster"
drop tmp

/* generate education of household head's sister in law */
gen tmp = ed_granular if relation == 10 & male == 0
bys hhid: egen head_sister_in_law_ed_roster = mean(tmp)
bys hhid: egen head_sister_in_law_ed_sd = sd(tmp)
label var head_sister_in_law_ed_roster "Sister in law of household head education from the roster"
drop tmp

/* count the number of coresident brothers, sisters, sons, daughters of household head */
bys hhid: egen head_num_brothers   = total((relation == 7) & (male == 1))
bys hhid: egen head_num_sisters    = total((relation == 7) & (male == 0))
bys hhid: egen head_num_sons       = total((relation == 3) & (male == 1))
bys hhid: egen head_num_daughters  = total((relation == 3) & (male == 0))
bys hhid: egen head_num_brothers_in_law = total((relation == 10) & (male == 1))
bys hhid: egen head_num_sisters_in_law  = total((relation == 10) & (male == 0))

/****************************************************************/ 
/* Fill in each individual's parent education wherever possible */
/****************************************************************/

/* parent --> child */

/* father of household head --> household head */
gen father_ed_roster = head_father_ed_roster if relation == 1
gen father_ed_roster_link = "father of head -> head (roster)" if relation == 1 & !mi(head_father_ed_roster)
label var father_ed_roster "Father ed from household roster"
label var father_ed_roster_link "Describes how father-child link was created from roster"

/* mother of household head --> household head */
gen mother_ed_roster = head_mother_ed_roster if relation == 1 
gen mother_ed_roster_link = "mother of head -> head (roster)" if relation == 1 & !mi(head_mother_ed_roster)
label var mother_ed_roster "Mother ed from the roster"
label var mother_ed_roster_link "How the mother-child link was created from the roster"

/* male household head --> child */
replace father_ed_roster = head_ed_roster if relation == 3 & head_male == 1
replace father_ed_roster_link = "male head -> child of head (roster)" if !mi(head_ed_roster) & relation == 3 & head_male == 1

/* female household head --> child */
replace mother_ed_roster = head_ed_roster if relation == 3 & head_male == 0
replace mother_ed_roster_link = "female head -> child of head (roster)" if !mi(head_ed_roster) & relation == 3 & head_male == 0

/* husband of female household head --> child */
replace father_ed_roster = head_husband_ed_roster if relation == 3 & head_male == 0 & mi(father_ed_roster)
replace father_ed_roster_link = "husband of female head -> child of head (roster)" if !mi(head_husband_ed_roster) & relation == 3 & head_male == 0

/* wife of male household head --> child */
replace mother_ed_roster = head_wife_ed_roster if relation == 3 & head_male == 1 & mi(mother_ed_roster)
replace mother_ed_roster_link = "wife of male head -> child of head (roster)" if !mi(head_wife_ed_roster) & relation == 3 & head_male == 1

/* father of household head --> sibling of household head */
replace father_ed_roster = head_father_ed_roster if relation == 7 
replace father_ed_roster_link = "father of head -> sibling of head (roster)" if !mi(head_father_ed_roster) & relation == 7

/* mother of household head --> sibling of household head*/
replace mother_ed_roster = head_mother_ed_roster if relation == 7 
replace mother_ed_roster_link = "mother of head - sibling of head (roster)" if !mi(head_mother_ed_roster) & relation == 7

/* brother of household head --> niece/nephew of household head. If multiple brothers, ignore unless all ed levels are the same. */
replace father_ed_roster = head_brother_ed_roster if relation == 9 & ((head_num_brothers) == 1 | (head_brother_ed_sd == 0))
replace father_ed_roster_link = "brother of head - niece/nephew of head (roster)" if !mi(head_brother_ed_roster) & relation == 9 & ((head_num_brothers) == 1 | (head_brother_ed_sd == 0))

/* sister of household head --> niece/nephew of household head. If multiple sisters, ignore unless all ed levels are the same. */
replace mother_ed_roster = head_sister_ed_roster if relation == 9 & ((head_num_sisters) == 1 | (head_sister_ed_sd == 0))
replace mother_ed_roster_link = "sister of head - niece/nephew of head (roster)" if !mi(head_sister_ed_roster) & relation == 9 & ((head_num_sisters) == 1 | (head_sister_ed_sd == 0))

/* son of household head --> grandchild of household head. Only if no variation in ed of sons (since we don't know whose it is) */
replace father_ed_roster = head_son_ed_roster if relation == 5 & ((head_num_sons == 1) | (head_son_ed_sd == 0))
replace father_ed_roster_link = "son of head - grandchild of head (roster)" if !mi(head_son_ed_roster) & relation == 5 & ((head_num_sons == 1) | (head_son_ed_sd == 0))

/* daughter of household head --> grandchild of household head. Only if no variation in ed of daughters (since we don't know whose it is) */
replace mother_ed_roster = head_daughter_ed_roster if relation == 5 & ((head_num_daughters == 1) | (head_daughter_ed_sd == 0))
replace mother_ed_roster_link = "daughter of head - gradchild of head (roster)" if !mi(head_daughter_ed_roster) & relation == 5 & ((head_num_daughters == 1) | (head_daughter_ed_sd == 0))

/* brother-in-law of household head --> child-in-law of household head */
replace father_ed_roster = head_brother_in_law_ed_roster if relation == 4 & ((head_num_brothers_in_law == 1) | (head_brother_in_law_ed_sd == 0))
replace father_ed_roster_link = "brother in law of head - child in law of head (roster)" if !mi(head_brother_in_law_ed_roster) & relation == 4 & ((head_num_brothers_in_law == 1) | (head_brother_in_law_ed_sd == 0))

/* sister in law of household head --> child of household head */
replace mother_ed_roster = head_sister_in_law_ed_roster if relation == 4 & ((head_num_sisters_in_law == 1) | (head_sister_in_law_ed_sd == 0))
replace mother_ed_roster_link = "sister in law of head - child in law of head (roster)" if !mi(head_sister_in_law_ed_roster) & relation == 4 & ((head_num_sisters_in_law == 1) | (head_sister_in_law_ed_sd == 0))

/* don't include these in-law relationships, because bro-in-law can be wife's brother or sister's husband and we don't know which. */
// /* father in law of household head --> sibling in law of household head */
// replace father_ed_roster = head_father_in_law_ed_roster if relation == 10
// replace father_ed_roster_link = "brother in law of head - sibling in law of head (roster)" if !mi(head_father_in_law_ed_roster) & relation == 10
// 
// /* mother in law of household head --> sibling in law of household head */
// replace mother_ed_roster = head_mother_in_law_ed_roster if relation == 10
// replace mother_ed_roster_link = "mother in law of head - sibling in law of head (roster)" if !mi(head_mother_in_law_ed_roster) & relation == 10
  
/* ************************************************* */
/* Get father education from household questionnaire */
/* ************************************************* */

/* The questionnaire states "what is the education of the household
head's father / household head's husband's father."  We assume that it
is the father of the head if the head is male, and it is the father in
law of the head if the head is female. */

/* father of male household head --> household head */
gen father_ed_hh = head_father_ed if relation == 1 & head_male == 1
gen father_ed_hh_link = "father of head -> head (hhq)" if !mi(head_father_ed) & relation == 1 & head_male == 1
label var father_ed_hh "Father education from household questionnaire"
label var father_ed_hh_link "How the father education was linked from the household questionnaire"

/* father of female household head --> husband of household head */
replace father_ed_hh = head_father_ed if relation == 2 &  head_male == 0 & male == 1
replace father_ed_hh_link = "father of head -> husband of female head (hhq)" if !mi(head_father_ed) & relation == 2 & head_male == 0 

/* father of male household head --> siblings of household head */
replace father_ed_hh = head_father_ed if relation == 7 & head_male == 1
replace father_ed_hh_link = "father of head- sibling of head (hhq)" if !mi(head_father_ed) & relation == 7 & head_male == 1

/* father of female household head --> siblings in law of household head */
/* note: sib-in-law could mean something else, but we assume female
households are most likely to arise from the head's death, which means
sib-in-laws of the new female head are the brotheres of the old male
head. */
replace father_ed_hh = head_father_ed if relation == 10 & head_male == 0
replace father_ed_hh_link = "father of head -> sibling of female head (hhq)" if !mi(head_father_ed) & relation == 10 & head_male == 0

/* cycle through the father and mother education variables and store the granular and binned versions */
foreach var in father_ed_roster mother_ed_roster father_ed_hh {

  /* rename education variables to be granular */
  ren `var' `var'_granular
  
  /* bin eduction variables at specific benchmarks */
  downcode_ed `var'_granular, gen(`var')
  label var `var' "Parent education (7 bins)"
}

/* save all data to temporary file used for SECC-comparable links below */
save $tmp/ihds/ihds_pc_links_roster_2011_temp, replace

/* keep only the link vars -- everything else is in the core IHDS */
keep hhid idperson father_ed_roster* father_ed_hh* mother_ed_roster*

/* save the data */
save $tmp/ihds/ihds_pc_links_roster_2011, replace

