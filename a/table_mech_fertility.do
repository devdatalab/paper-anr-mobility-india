/***********************************************************/
/* Objective:                                              */
/* generate key figures to study muslim/SC fertlity/mob    */
/***********************************************************/

/***************************************************************/
/* Part 1: decomposition among illiterates of the quantitative */
/*         effects of fertility                                */
/***************************************************************/
/* get the IHDS */ 
use $mobility/ihds/ihds_mobility, clear

/* drop people too young to finish education */
drop if age <= 18

/* review father ed distribution in decades of interest */
tab father_ed [aw=wt] if bc == 1980
tab father_ed [aw=wt] if bc == 1985
tab father_ed [aw=wt] if inlist(bc, 1980, 1985)

/* aggregate relationship between child ed rank and fertility among fathers in bottom 50%: 3.5 ranks per sibling */
label var muslim "Muslim"
label var sc     "Scheduled Caste"
label var st     "Scheduled Tribe"
label var mom_num_kids "Number of Siblings"
label var urban  "Urban"

/* replace mom_num_kids with number of siblings by subtracting 1 */
replace mom_num_kids = mom_num_kids - 1

/* calculate number of kids by group for 1985-89 birth cohort */
tabstat mom_num_kids [aw=wt] if bc == 1985, by(group)

/* fertility explains about half of muslim disadvantage vis-a-vis forwards */

/* preferred approach: control for place as well as fertility, since we want partial effect
                       of fertility, not fertility and everything it's correlated with. */
eststo clear

/* 1. replicate basic result of muslim disadvantage in this sample */
eststo: reghdfe son_ed_rank              muslim sc st urban bc [aw=wt] if inlist(bc, 1980, 1985) & father_ed <= 2, absorb(stateid)

/* 2. show it holds up in the sample where mom TFR is known */
eststo: reghdfe son_ed_rank              muslim sc st urban bc [aw=wt] if inlist(bc, 1980, 1985) & father_ed <= 2 & !mi(mom_num_kids), absorb(stateid)
local base: di %2.0f _b["muslim"]

/* 3. add mom's fertility */
eststo: reghdfe son_ed_rank muslim sc st urban bc mom_num_kids [aw=wt] if inlist(bc, 1980, 1985) & father_ed <= 2, absorb(stateid)
local adjusted: di %2.0f _b["muslim"]

estout_default using $out/mech_fertility, order(muslim sc st urban mom_num_kids) 
/* takeaway: fertility explains about 30% of present-day muslim disadvantage */

/* store these coefficients */
store_tex_constant, file($out/mob_constants) idshort(tfrm1) idlong(muslim_mobility_gap_no_tfr) value(`base') ///
                                                 desc("Muslim mobility gap (IHDS) with adjustment for state f.e. and urban but not mom TFR")
store_tex_constant, file($out/mob_constants) idshort(tfrm2) idlong(muslim_mobility_gap_yes_tfr) value(`adjusted') ///
                                                 desc("Muslim mobility gap (IHDS) after adjustment for mom TFR")

/* store share of muslim mobility gap explained by high fertility */
local share: di %5.2f (1 - `adjusted' / `base')
store_tex_constant, file($out/mob_constants) idshort(tfrms) idlong(muslim_tfr_share) value(`share') ///
                                                 desc("Share of Muslim mobility gap (IHDS) explained by mom TFR")

/* For R3, show results with a younger cohort */
eststo clear

eststo: reghdfe son_ed_rank              muslim sc st urban [aw=wt] if inrange(birth_year, 1980, 1984) & father_ed <= 2 & !mi(mom_num_kids), absorb(stateid)
eststo: reghdfe son_ed_rank muslim sc st urban mom_num_kids [aw=wt] if inrange(birth_year, 1980, 1984) & father_ed <= 2, absorb(stateid)
eststo: reghdfe son_ed_rank              muslim sc st urban [aw=wt] if inrange(birth_year, 1985, 1989) & father_ed <= 2 & !mi(mom_num_kids), absorb(stateid)
eststo: reghdfe son_ed_rank muslim sc st urban mom_num_kids [aw=wt] if inrange(birth_year, 1985, 1989) & father_ed <= 2, absorb(stateid)
eststo: reghdfe son_ed_rank              muslim sc st urban [aw=wt] if inrange(birth_year, 1990, 1992) & father_ed <= 2 & !mi(mom_num_kids), absorb(stateid)
eststo: reghdfe son_ed_rank muslim sc st urban mom_num_kids [aw=wt] if inrange(birth_year, 1990, 1992) & father_ed <= 2, absorb(stateid)

estout_default using $out/mech_fertility_r3, order(muslim sc st urban mom_num_kids) 
