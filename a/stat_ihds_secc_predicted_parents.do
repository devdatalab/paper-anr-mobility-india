/**********************************************************************************/
/* "GUESS" THE FATHER IN IHDS, AS WE ARE REQUIRED TO DO IN SECC.                  */
/* (not required in IHDS, but doing this to see if SECC-approach creates errors.  */
/* Stores data in a set of tex constants/input files.                             */
/**********************************************************************************/

/************************************************************/
/* OPEN IHDS AND GET PARENT-CHILD LINKS FROM RELATION FIELD */
/************************************************************/

/* open individual IHDS with roster links */
use $ihds/ihds_2011_members, clear
merge 1:1 idperson using $ihds/ihds_pc_links, keep(master match)

/* keep only above 15 years old for consistency */
keep if age >= 15

/* drop links we don't use */
drop *ew *hh *link *granular
drop mother_ed father_ed

/*****************************************************************/
/* CREATE PARENT-CHILD LINKS IGNORING RELATION, AS WE DO IN SECC */
/*****************************************************************/

/* create global variable for maximum number of members in a household */
global max_member 10

/* keep only men */
keep if male == 1

/* generate a dummy for if the person is a coresident son  */
gen ihds_cores = !mi(father_ed_roster)

/* generate father primary ed variable */
gen father_prim = (father_ed_roster >= 5) if !mi(father_ed_roster)

/* within each household, sort by age rank */
/* generate age_rank is 1 if the oldest male in a household */
sort hhid age
by hhid: gen age_rank = 1 if _n == _N

/* now, rank the ages within a household */
egen age_rank2 = rank(age), field by(hhid)

/* if not the oldest male, just give the age_rank is the regular rank */
replace age_rank = age_rank2 if age_rank != 1

/* reshape within household id */
sort hhid age_rank

by hhid: gen hh_member_id = _n

/* loop over each member in the household */
forval i = 1 / $max_member {

  /* generate education, age, primary ed of person with this member id */
  foreach v in ed age prim {
    gen `v'_tmp = `v' if hh_member_id == `i'
    by hhid: egen `v'`i' = max(`v'_tmp)
    drop `v'_tmp
  }
}

/* generate fathers */

/* create candidate ids of each individual's father */
/* set father1, father 2 as blank*/
gen father1 = .
gen father2 = . 
gen father3 = .

/* loop over all 3 potential fathers */
forval j = 1/$max_member {

  /* put this member into father1 if they fall in the age range and the id is blank so far */
  replace father1 = `j' if (age`j' - age >= 15) & (age`j' - age < 51) & father1 == .

  /* put this member into father2 if they fall in the age range, and father1 is taken by someone other than this */
  replace father2 = `j' if (age`j' - age >= 15) & (age`j' - age < 51) & father2 == . & father1 != `j'

  /* repeat for 3rd candidate father */
  replace father3 = `j' if (age`j' - age >= 15) & (age`j' - age < 51) & father3 == . & father1 != `j' & father2 != `j'
}

/* get age, ed, and primary education of fathers */
/* set variables at zero */
forval i = 1/3 { 
  gen father_age`i' = .
  gen father_ed`i' = . 
  gen father_prim`i' = . 
}

/* store age and education of the person we think is your coresident father */
/* loop over all 3 variables */
forval i = 1/3 { 
  forval j = 1/$max_member { 
    /* get this variable throughout the household */
    by hhid: replace father_age`i'  = age`j' if father`i' == `j'
    by hhid: replace father_ed`i'   = ed`j' if father`i' == `j'
    by hhid: replace father_prim`i' = prim`j' if father`i' == `j' 
  }
}

/* generate variable highlighting ambiguous father */
gen father_ambig = father2 != . 
gen father_ambig_high = father3 != . 
  
/* set father education to father_ed1 if father isn't ambiguous */
gen father_ed_predicted = father_ed1 if father_ambig == 0 
gen father_prim_predicted = father_prim1 if father_ambig == 0

/* create dummy variables for existence of either father ed variable */
gen in_roster    = !mi(father_ed_roster)
gen in_predicted = !mi(father_ed_predicted)

/**********************************************************/
/* GENERATE MATCH RATE STATS AND STORE TO LATEX CONSTANTS */
/**********************************************************/

/* Result 1: when we observe both, the correlation is 99.7% */
count if !mi(father_ed_predicted) & !mi(father_ed_roster)
corr    father_ed_predicted father_ed_roster
di `r(rho)'
local rho: di %6.3f `r(rho)'
di `rho'

/* store correlation in a latex input file */
store_tex_constant, file($out/mob_constants) idshort(ipfc) idlong(ihds_pred_father_corr) value(`rho') ///
                                                 desc("IHDS correlation between secc-style-predicted father ed and actual father ed")

/* Result 2: existence vs. non-existence results */
/* store observation counts in both datasets, and for each type of mismatch. */
count if in_roster == 1 & in_predicted == 1
store_tex_constant, file($out/mob_constants) idshort(ipn1) idlong(ihds_pred_father_n1) value(`r(N)') ///
                    desc("Number obs where roster father and SECC-predicted father both exist in IHDS")

count if in_roster == 1 & in_predicted == 0
store_tex_constant, file($out/mob_constants) idshort(ipn2) idlong(ihds_pred_father_n2) value(`r(N)') ///
desc("Number obs where roster father exists in IHDS but SECC-predicted father doesn't")

count if in_roster == 0 & in_predicted == 1
store_tex_constant, file($out/mob_constants) idshort(ipn3) idlong(ihds_pred_father_n3) value(`r(N)') ///
                    desc("Number obs where roster father does not exist in IHDS but SECC-predicted father does")

cat $out/mob_constants.csv
cat $out/mob_constants.tex
