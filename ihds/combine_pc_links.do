/*****************************************************************/ 
/* Merge parent child links to create a working mobility dataset */
/*****************************************************************/

/* This file uses the parent-child links created from the roster data
   ($ihds/ihds-pc-links-roster-2011.dta) and the parent-child links
   created from the eligible women's survey ($ihds/ihds-pc-links-ew-2011.dta)
   to create one dataset for the mobility work that contains all known
   parent-child links.
*/

/* open the links from the roster data */
use $tmp/ihds/ihds_pc_links_roster_2011, clear

/* merge in the links from the eligible women's survey */
merge 1:1 idperson using $tmp/ihds/ihds_pc_links_ew_2011, nogen

/* get the household weights */
merge 1:1 idperson using $ihds/ihds_2011_members, assert(match using) keep(match) keepusing(wt) nogen

/* get the mom's fertility */
merge 1:1 idperson using $tmp/ihds/mother_tfr, keepusing(mom_num_kids) keep(master match) nogen

/*****************************************/
/* select which parent child link to use */
/*****************************************/

/* select best link for both downcoded and granular educations */
gen father_ed_link = ""
gen mother_ed_link = ""
foreach type in "" _granular {
  
  /* create variable for fathers' education */
  /* first take the father ed from the household questionnaire */
  gen father_ed`type' = father_ed_hh`type'
  replace father_ed_link = father_ed_hh_link
  
  /* second take the father ed from the roster */
  replace father_ed`type' = father_ed_roster`type' if mi(father_ed`type')
  replace father_ed_link = father_ed_roster_link if mi(father_ed_link)
  
  /* third take the father ed from the ew survey */
  replace father_ed`type' = father_ed_ew`type' if mi(father_ed`type')
  replace father_ed_link = father_ed_ew_link if mi(father_ed_link)
  
  /* create variable for mothers' education */
  /* first take the mother ed from the ew survey */
  gen mother_ed`type' = mother_ed_ew`type'
  replace mother_ed_link = mother_ed_ew_link
  
  /* second take the mother ed from the roster */
  replace mother_ed`type' = mother_ed_roster`type' if mi(mother_ed`type')
  replace mother_ed_link = mother_ed_roster_link if mi(mother_ed_link)
  
  /* drop the links that were inconsistent (see validate_ihds_pc_links.do) */
  replace mother_ed_link = ""  if mother_ed_roster_link == "sister in law of head - child in law of head (roster)"
  replace father_ed_link = ""  if father_ed_roster_link == "brother of head - niece/nephew of head (roster)"
  replace father_ed_link = ""  if father_ed_roster_link == "brother in law of head - child in law of head (roster)"
  replace mother_ed`type' = .  if mother_ed_roster_link == "sister in law of head - child in law of head (roster)"
  replace father_ed`type' = .  if father_ed_roster_link == "brother of head - niece/nephew of head (roster)"
  replace father_ed`type' = .  if father_ed_roster_link == "brother in law of head - child in law of head (roster)"
}

/* order and save the chosen link as well as its alternate values */
order hhid idperson wt father_ed mother_ed father_ed* mother_ed* mom_num_kids
order father_ed*gran* mother_ed*gran* father_ed*link mother_ed*link, last
save $ihds/ihds_pc_links, replace

