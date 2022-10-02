/* set some graph parameters */
global legend_params region(lwidth(medthick)) color(black) lcolor(black) ring(0) pos(5) lab(1 "Muslim") lab(2 "SC") 
global params lwidth(medthick)

/* churn question */
use $mobility/ihds/ihds_mobility.dta, clear

/* calculate birth cohort groups */
gen_bc_ranks

/* keep Muslims and SCs only, since that is what we are interested in */
collapse (mean) father_ed father_ed_rank_s [aw=wt], by(bc group)

/* show changes in mean father education over the birth cohorts */
twoway ///
    (line father_ed_rank_s bc if group == 2, lcolor("$muscolor") $params) ///
    (line father_ed_rank_s bc if group == 3, lcolor("$sccolor")  $params) ///
    , legend($legend_params) xtitle("Birth Cohort") ytitle("Mean Father Education Rank")

graphout sc_mus_father_ranks, pdf

/* repeat for years of education */
twoway ///
    (line father_ed bc if group == 2, lcolor("$muscolor") $params) ///
    (line father_ed bc if group == 3, lcolor("$sccolor")  $params) ///
    , legend($legend_params) xtitle("Birth Cohort") ytitle("Mean Father Years of Education")

graphout sc_mus_father_years, pdf



/* ---------------------------- cell: calculate SC / Muslim parent wage gaps over time using NSS ---------------------------- */


/*****************************************************************************/
/* program store_coefs: store muslim and SC coefs from the last regression   */
/*****************************************************************************/
cap prog drop store_group_coefs
prog def store_group_coefs
  syntax, s(string) y(int)
  local m = _b["muslim"]
  local ms = _se["muslim"]
  local sc = _b["sc"]
  local scs = _se["sc"]

  append_to_file using $tmp/churn.csv, s("`s',muslim,`y',`m',`ms'") 
  append_to_file using $tmp/churn.csv, s("`s',sc,    `y',`sc',`scs'") 
end
/** END program store_coefs **************************************************/

/* open NSS time series members data */
use $nss/clean/nss-joint-members.dta, clear

/* create output file */
append_to_file using $tmp/churn.csv, s("name,group,year,b,se")  erase

/* target parents of 1960--69 birth cohort = father born 1930-1950 == age 30-50 in 1983 */
keep if inrange(age, 30, 50)
drop if mi(group)

gen muslim = group == 2
gen sc = group == 3
gen st = group == 4

foreach y in 1987 1994 2000 2012 {
  reg ln_wage sc muslim st [aw=wt] if year == `y'
  store_group_coefs, s(wage) y(`y')
}


/* repeat for low education heads */
winsorize ln_wage 1 99, replace centile
foreach y in 1987 1994 2000 2012 {
  reg ln_wage sc muslim st [aw=wt] if year == `y' & ed == 0	
  store_group_coefs, s(wage_low_ed) y(`y')
}


/* repeat for MPCE */
use $nss/clean/nss-joint-hh.dta, clear
drop if mi(group)
gen muslim = group == 2
gen sc = group == 3
gen st = group == 4
keep if inrange(age_head, 40, 60) & sex_head == 1

gen bottom_half = .
replace bottom_half = inrange(ed_head, 0, 2) if year == 1983
replace bottom_half = inrange(ed_head, 0, 3) if year == 1994
replace bottom_half = inrange(ed_head, 0, 3) if year == 2000
replace bottom_half = inrange(ed_head, 0, 4) if year == 2012
replace bottom_half = . if mi(ed_head)

foreach y in 1983 1994 2000 2012 {
  reg ln_mpce sc muslim st [aw=wt] if year == `y'
  store_group_coefs, s(mpce) y(`y')
}

/* repeat for low ed heads */
foreach y in 1983 1994 2000 2012 {
  reg ln_mpce sc muslim st [aw=wt] if year == `y' & bottom_half == 1
  store_group_coefs, s(mpce_low_ed) y(`y')
}

/* how about consumption ranks */
gen ln_mpce_rank = .
foreach y in 1983 1994 2000 2012 {
  gen_wt_ranks ln_mpce if year == `y', gen(foo) weight(wt)
  replace ln_mpce_rank = foo if year == `y'
  drop foo
}

foreach y in 1983 1994 2000 2012 {
  reg ln_mpce_rank sc muslim st [aw=wt] if year == `y' & bottom_half == 1
  store_group_coefs, s(mpce_rank_low_ed) y(`y')
}

foreach y in 1983 1994 2000 2012 {
  reg ln_mpce_rank sc muslim st [aw=wt] if year == `y' & bottom_half == 0
  store_group_coefs, s(mpce_rank_high_ed) y(`y')
}

/* ---------------------------- cell: plot relative wage gaps over time ---------------------------- */

global legend_params region(lwidth(medthick)) color(black) lcolor(black) ring(0) pos(5) lab(1 "Muslim") lab(2 "SC") 
import delimited using $tmp/churn.csv, clear varnames(1)

twoway ///
    (line b year if name == "wage" & group == "muslim", $params lcolor("$muscolor")) ///
    (line b year if name == "wage" & group == "sc", $params lcolor("$sc")) ///
    , legend($legend_params) ytitle("Log Wage Gap Relative to Forwards/Others") ///
    ylabel(-.6(.1)0) xtitle("NSS Survey Year")
    graphout wage_line
    
twoway ///
    (line b year if name == "wage_low_ed" & group == "muslim", $params lcolor("$muscolor")) ///
    (line b year if name == "wage_low_ed" & group == "sc", $params lcolor("$sc")) ///
    , legend($legend_params) ytitle("Log Wage Gap Relative to Forwards/Others") ///
      ylabel(-.1(.1).2) xtitle("NSS Survey Year")
    graphout wage_low_line
    
twoway ///
    (line b year if name == "mpce" & group == "muslim", $params lcolor("$muscolor")) ///
    (line b year if name == "mpce" & group == "sc", $params lcolor("$sc")) ///
    , legend($legend_params) ytitle("Household Per Capita Consumption Gap" "Relative to Forwards/Others") ///
        ylabel(-.6(.1)0) xtitle("NSS Survey Year")
    graphout mpce_line, pdf
    
twoway ///
    (line b year if name == "mpce_low_ed" & group == "muslim", $params lcolor("$muscolor")) ///
    (line b year if name == "mpce_low_ed" & group == "sc", $params lcolor("$sc")) ///
    , legend($legend_params) ytitle("Household Per Capita Consumption Gap" "Relative to Forwards/Others") ///
          ylabel(-.3(.05)0) xtitle("NSS Survey Year")
    graphout mpce_low_line, pdf
    
twoway ///
    (line b year if name == "mpce_rank_low_ed" & group == "muslim", $params lcolor("$muscolor")) ///
    (line b year if name == "mpce_rank_low_ed" & group == "sc", $params lcolor("$sc")) ///
    , legend($legend_params) ytitle("Household Per Capita Consumption Rank Gap" "Relative to Forwards/Others") ///
          ylabel(-20(5)0) xtitle("NSS Survey Year")
    graphout mpce_rank_low_line, pdf
    
twoway ///
    (line b year if name == "mpce_rank_high_ed" & group == "muslim", $params lcolor("$muscolor")) ///
    (line b year if name == "mpce_rank_high_ed" & group == "sc", $params lcolor("$sc")) ///
    , legend($legend_params) ytitle("Household Per Capita Consumption Rank Gap" "Relative to Forwards/Others") ///
          ylabel(-20(5)0) xtitle("NSS Survey Year")
    graphout mpce_rank_high_line, pdf
    
