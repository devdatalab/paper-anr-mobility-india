/************************************************************************************/
/* Objective: study whether mobility is worse among Muslim small enterprise owners  */
/************************************************************************************/

/* open mobility IHDS */ 
use $mobility/ihds/ihds_mobility, clear

/* rename variable of people with a business (probably not needed anymore)  */
cap ren nf1 has_business

/* set sample and define birth cohort groups */
keep if inrange(bc, 1950, 1980)

* pool SCs and STs because so few STs are biz owners */
gen combined_group = group
replace combined_group = 3 if group == 4

lab define combined_group  1 "Forward/Others" 2 "Muslims" 3 "SC/STs" 
lab values combined_group combined_group

/***********************************************************************/
/* First get descriptive statistics about business ownership over time */
/***********************************************************************/

/* show four groups here as this justifies combining STs and SCs */
preserve 
collapse (mean) has_business [aw = wt], by(group bc)
keep if bc >= 1950 
twoway ///
    (connected has_business bc if group == 1, color("32 32 32")    lwidth(medthick) ) ///
    (connected has_business bc if group == 2, color("150 150 255") lwidth(medthick) ) ///
    (connected has_business bc if group == 3, color("252 46 24")   lwidth(medthick) ) ///
    (connected has_business bc if group == 4, color("190 210 160") lwidth(medthick)  ///
    text(.26 1955 "Forwards"        , color("32 32 32")     size(medsmall)) ///
    text(.33 1955 "Muslims"         , color("75 75 255")    size(medsmall)) ///
    text(.15 1955 "Scheduled Castes", color("200 39 24")    size(medsmall)) ///
    text(.10 1955 "Scheduled Tribes", color("70 100 50")    size(medsmall)) ///
legend(off) xtitle("Birth Cohort") ytitle("Proportion with business") ylab(0(.05).35,format(%5.2f)) )

graphout has_business_ts, pdf

restore 

/* now combine SCs and STs */
replace group = combined_group

/**********************************/
/* write mobility stats to a csv  */
/**********************************/
global f $tmp/has_business.csv
cap erase $f
append_to_file using $f, s(x, has_business, group, lb, ub, bc, mu, y)

foreach bc in 1950 1960 1970 1980 {
  foreach has_business in 0 1 {
    foreach group in 1 2 3 {
      bound_param [aw=wt] if bc == `bc' & has_business == `has_business' & group == `group', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
      if _rc == 0 { 
        append_to_file using $f, s(father,`has_business',`group',`r(mu_lb)',`r(mu_ub)',`bc',mu0-50,rank)
      }
    }
  }
}

/*****************/
/* graph         */
/*****************/
import delimited using $f, clear

local t0 "No household business"
local t1 "Has household business"

local loc0f  42 1970
local loc1f  47 1955
local loc0m  28 1970
local loc1m  31 1965
local loc0s  34 1970
local loc1s  40 1963

foreach has_business in 0 1 { 

  twoway ///
      (rarea lb ub bc if has_business == `has_business' & mu == "mu0-50" & group == 1, color("32 32 32")    ) ///
      (rarea lb ub bc if has_business == `has_business' & mu == "mu0-50" & group == 2, color("150 150 255") ) ///
      (rarea lb ub bc if has_business == `has_business' & mu == "mu0-50" & group == 3, color("70 100 50")   ) ///
   , ytitle("Child rank", size(medlarge)) xtitle("Birth cohort", size(medlarge)) ///
      text(`loc`has_business'f' "Forward/Other", size(medsmall) color("32 32 32")) ///
      text(`loc`has_business'm' "Muslim"       , size(medsmall) color("75 75 255"))        ///
      text(`loc`has_business's' "SC/ST"        , size(medsmall) color("70 100 50"))         ///
  legend(off) ylabel(,labsize(medlarge)) xlabel(,labsize(medlarge)) name(has_business_`has_business', replace) title(`t`has_business'', size(large))
  
}

graph combine has_business_0 has_business_1, xcommon ycommon 
graphout mob_by_own_business, pdf 
