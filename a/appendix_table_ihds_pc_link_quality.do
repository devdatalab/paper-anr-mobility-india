/********************************************************************************/
/* check interval validity of parent education variables from different sources */
/********************************************************************************/

/* open the IHDS parent-child link data */
use $ihds/ihds_pc_links, clear

/* set source vars to missing if we didn't use them */
foreach v in hh ew roster {
  replace father_ed_`v' = . if mi(father_ed)
  noi cap replace mother_ed_`v' = . if mi(mother_ed)
}

/* get individual age, gender, ed from ihds-member */
merge 1:1 idperson using $ihds/ihds_2011_members, keepusing(age male ed) nogen keep(master match)

/* get household earnings from ihds-hh */
merge m:1 hhid using $ihds/ihds_2011_hh, keepusing(hh_income) nogen keep(master match)

gen bc = 2012 - age
keep if inrange(bc, 1960, 1989)

/* calculate log household income */
winsorize hh_income 1 1e10, replace
gen ln_hh_income = ln(hh_income)

/* focus only on binned vars which are the main use case */
drop *granular

/* creates measures of mismatch from roster vs. hh for men */
gen men_mismatch = father_ed_roster != father_ed_hh if !mi(father_ed_roster) & !mi(father_ed_hh) & male == 1
gen men_mismatch_quantity = father_ed_hh - father_ed_roster if male == 1
/* note we only do fathers, since mothers */

/* for women, key comparison is EW vs. roster */
gen wf_mismatch = father_ed_roster != father_ed_ew if !mi(father_ed_roster) & !mi(father_ed_ew) & male == 0
gen wf_mismatch_quantity = father_ed_ew - father_ed_roster if male == 0
gen wm_mismatch = mother_ed_roster != mother_ed_ew if !mi(mother_ed_roster) & !mi(mother_ed_ew) & male == 0
gen wm_mismatch_quantity = mother_ed_ew - mother_ed_roster if male == 0

/* output a table showing these results */
eststo clear
eststo: reg men_mismatch_quantity if male == 1
eststo: reg men_mismatch_quantity age ed ln_hh_income if male == 1
eststo: reg wf_mismatch_quantity  if male == 0
eststo: reg wf_mismatch_quantity  age ed ln_hh_income if male == 0
eststo: reg wm_mismatch_quantity  if male == 0
eststo: reg wm_mismatch_quantity  age ed ln_hh_income if male == 0

mob_label_vars
estouts

estout_default using $out/app_table_validate_eds, keep(age ed ln_hh_income _cons)
estmod_header  using $out/app_table_validate_eds.tex, cstring(" & \multicolumn{2}{c}{Father-Son} & \multicolumn{2}{c}{Father-Daughter} & \multicolumn{2}{c}{Mother-Daughter}")

/* calculate the share of observations where we have more than one obs */
count if !mi(father_ed_roster) | !mi(father_ed_hh) | !mi(father_ed_ew)
local hasdad = `r(N)'
count if (!mi(father_ed_roster) & !mi(father_ed_hh)) | (!mi(father_ed_roster) & !mi(father_ed_ew)) | (!mi(father_ed_ew) & !mi(father_ed_hh))
local hasboth = `r(N)'
local shareboth = `hasboth' / `hasdad'
sum men_mismatch

/* calculate mismatch rates for paper */
sum men_mismatch wf_mismatch wm_mismatch [aw=wt]

/* correlation versions */
corr father_ed_roster father_ed_ew [aw=wt] if male == 0
local x1 `r(rho)'
corr mother_ed_roster mother_ed_ew [aw=wt] if male == 0
local x2 `r(rho)'
corr father_ed_roster father_ed_hh [aw=wt] if male == 1
local x3 `r(rho)'
gen mean_corr = 1/3 * (`x1' + `x2' + `x3')
sum mean_corr
local mean_corr `r(mean)'
store_tex_constant, file($out/mob_constants) idshort(pcorr) idlong(parent_ed_recall_corr) value(`mean_corr') ///
                      desc("Correlation between multiple descriptions of parents' education")

