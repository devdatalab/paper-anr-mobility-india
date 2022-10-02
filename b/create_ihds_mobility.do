/*****************************************/
/* CREATE IHDS MOBILITY ANALYSIS DATASET */
/*****************************************/

/* open the clean IHDS member data */
use $ihds/ihds_2011_members, clear

/* merge in the best parent-child variables */
merge 1:1 idperson using $ihds/ihds_pc_links, keepusing(father_ed father_ed_link mother_ed mother_ed_link mom_num_kids father_ed_granular) keep(using match) assert(master match) nogen

/* create separate variables for son and daughter educaiton */
gen son_ed = ed if male == 1
gen daughter_ed = ed if male == 0

/* rename ed to child_ed to avoid confusion. This var will exist for sons and daughters */
ren ed child_ed
ren ed_granular child_ed_granular

/*********************************************************/
/* create binary educational attainments for each person */
/*********************************************************/

/* bin education variables */
foreach person in father mother daughter son child {

  /* create primary school completion indicators */
  gen `person'_prim = (`person'_ed >= 5) if !mi(`person'_ed) 
  label var `person'_prim "`person' achieved primary level education"

  /* create primary school completion indicators */
  gen `person'_mid = (`person'_ed >= 8) if !mi(`person'_ed) 
  label var `person'_mid "`person' achieved middle level education"

  /* create high school completion indicators */
  gen `person'_hs  = (`person'_ed >= 12) if !mi(`person'_ed)
  label var `person'_hs "`person' achieved high school level education"

  /* create university completion indicators */
  gen `person'_uni = (`person'_ed >= 14) if !mi(`person'_ed)
  label var `person'_uni "`person' achieved universtiy level education"
}


/**********************************/
/* generate education rankings    */
/**********************************/

/* limit sample to 1950-1999 */
keep if inrange(birth_year, 1950, 1999)

/* generate 5- and 10-year birth cohort groups and ed ranks. */
gen_bc_ranks

/* save working mobility file */
compress
cap mkdir $mobility/ihds
save $mobility/ihds/ihds_mobility, replace
