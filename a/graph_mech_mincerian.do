/*****************************************************************/
/* Show that Muslim Mincerian returns are not lower than others  */
/*****************************************************************/

/***********************************************************/
/* IHDS Mincerian Returns -- income from head of household */
/***********************************************************/
use $mobility/ihds/ihds_mobility, clear

/* keep household heads only */
keep if relation == 1 

/* create age-squared and log income vars for Mincer regs */
gen age2 = age^2
gen ln_income = ln(incomepc + 100)

/* lump SCs and STs together */
gen collapsed_group = group
replace collapsed_group = 3 if group == 4 

/* initialize .csv */
global l $tmp/mincer_ihds_xsection.csv
cap erase $l
append_to_file using $l, s(group, estimate, se, dataset, outcome)

/* keep people ages 18 to 64 for Mincer regs */
keep if inrange(age, 18, 64)

/* loop over collapsed groups */
forv group = 1/3 { 
  quireg ln_income ed_granular age age2 if collapsed_group == `group' [pw = wt] , robust title(`group')
}

/* repeat for non-collapsed groups */
forv group = 1/4 { 
  quireg ln_income ed_granular age age2 if group == `group' [pw = wt] , robust title(`group')
  local est = _b[ed_granular]
  local se = _se[ed_granular] 
  append_to_file using $l, s(`group',`est', `se', ihds, ln_income) 
}

/***************************************************/
/* NSS Mincerian returns to wages, all individuals */
/***************************************************/
use $nss/clean/nss-68-10-members, clear
keep if sex == 1

/* get variables for Mincer regressions */
gen age2 = age^2
gen birth_year = 2011 - age 
egen decade = cut(birth_year), at(1910(10)2000)

/* collapse group: OBC -> Forward/Other */
replace group = 1 if group == 5
// replace group = 3 if group == 4

/* prime age population */
keep if inrange(age, 18, 64)

/* initialize csv */
global j $tmp/mincer_nss_xsection.csv
cap erase $j
append_to_file using $j, s(group, estimate, se, dataset, outcome)

/* loop over groups */
forv group = 1/4 { 
  quireg ln_wage ed_years age age2 if group == `group'  [pw = wt], robust title(`group')
  local est = _b[ed]
  local se = _se[ed] 
  append_to_file using $j, s(`group',`est', `se', nss, ln_wage) 
}

/*****************************************/
/* NSS Mincerian returns to consumption  */
/*****************************************/
use $nss/clean/nss-68-10-members, clear
keep if sex == 1

/* collapse group: OBC -> Forward/Other */
replace group = 1 if group == 5
// replace group = 3 if group == 4

/* this regression is 1 obs x household, since we only see household consumption */
bys hhid: keep if _n == 1
gen age_head2 = age_head^2

/* initialize csv */
global k $tmp/mincer_nss_consumption.csv
cap erase $k
append_to_file using $k, s(group, estimate, se, dataset, outcome)
keep if inrange(age_head, 18, 64)

/* loop over groups */
forv group = 1/4 { 
  quireg ln_mpce ed_years_head age_head age_head2 if group == `group'  [pw = wt], robust title(`group')
  local est = _b[ed]
  local se = _se[ed] 
  append_to_file using $k, s(`group',`est', `se', nss, ln_consumption) 
}


/***************************************/
/* create a graph of all these results */
/***************************************/

/* store the three files in tempfiles named j, k, and l for easy looping */
foreach global in j k l {
  import delimited using ${`global'}, clear
  tempfile `global'
  save ``global''
}

/* combine all the results into a single file */
clear
foreach global in j k l {
  append using ``global'' 
}

replace outcome = trim(outcome)
replace dataset = trim(dataset)

capture gen group_perturbed = group 
replace group_perturbed = group + .1 if dataset == "nss" & outcome == "ln_consumption"
replace group_perturbed = group - .1 if dataset == "ihds" & outcome == "ln_income"

capture gen ub = est + 1.96 * se
capture gen lb = est - 1.96 * se

/* four way graph: */
local xlab_1 .9 "IHDS, ln(inc.)" 1 "NSS, ln(wage)" 1.1 "NSS, ln(cons.)" 
local xlab_2 1.9 "IHDS, ln(inc.)" 2 "NSS, ln(wage)" 2.1 "NSS, ln(cons.)" 
local xlab_3 2.9 "IHDS, ln(inc.)" 3 "NSS, ln(wage)" 3.1 "NSS, ln(cons.)" 
local xlab_4 3.9 "IHDS, ln(inc.)" 4 "NSS, ln(wage)" 4.1 "NSS, ln(cons.)" 

twoway ///
    (rcap ub lb group_perturbed if inrange(group_perturbed,.5,1.5),    lwidth(medthick) color(black) ) ///
    (rcap ub lb group_perturbed if inrange(group_perturbed, 1.5,2.5),  lwidth(medthick) color(blue) ) /// 
    (rcap ub lb group_perturbed if inrange(group_perturbed, 2.5,3.5) , lwidth(medthick) color(red) ) ///
    (rcap ub lb group_perturbed if inrange(group_perturbed, 3.5,4.5) , lwidth(medthick) color(dkgreen) ///
    xtitle("") ytitle("Mincerian return") ///
    xlab(`xlab_1' `xlab_2' `xlab_3' `xlab_4',  angle(45)  gextend )  ///
    text(.08 1.2 "Forward/Others", color(black) )  ///
    text(.073 1.9 "Muslims", color(blue) )        ///
    text(.062 2.95 "SCs", color(red) )  ///
    text(.056 3.95 "STs", color(dkgreen) ) legend(off) ///
    )

graphout mincerian_returns_pooled_4, pdf

