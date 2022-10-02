/*************************************************************************/
/* Mortality-style scatter plot showing changing rank and E(Y) over time */
/*************************************************************************/

/* define graph colors */
// global color0 332288
// global color1 88CCEE
// global color2 44AA99
// global color3 117733
// global color4 999933
// global color5 DDCC77
// global color6 CC6677
// global color7 882255
// global color8 AA4499

global color0 51 34 136
global color1 136 204 238
global color2 68 170 153
global color3 17 119 51
global color4 153 153 51
global color5 221 204 119
global color6 204 102 119
global color7 136 34 85
global color8 170 68 153

/*********************************************************************************************/
/* program prep_scatter: mortality-style scatterplot showing movement of parent/child ranks   */
/*********************************************************************************************/
cap prog drop prep_scatter
prog def prep_scatter

  syntax [if], child(string) parent(string)

  /* subset if needed and collapse to father rank bins */
  if !mi("`if'") keep `if'
  if "`child'" == "son" local suffix s
  if "`child'" == "daughter" {
    local suffix d
  }
  if "`child'" == "daughter" | "`parent'" == "mother" {
    drop if bc == 1950
  }
  collapse (mean) `child'_ed_rank (firstnm) `parent'_ed_rank_`suffix' [aw=wt], by(`parent'_ed bc)
  sort bc `parent'_ed
  
  drop if mi(`parent'_ed) | mi(`child'_ed_rank) | mi(bc)
end
/** END program prep_scatter ******************************************************************/

/********/
/* MAIN */
/********/
/* note no loops here because of too many small differences between father/mother son/daughter graphs  */

/*****************************/
/* FATHER - SON SCATTERPLOTS */
/*****************************/
use $mobility/ihds/ihds_mobility.dta, clear
prep_scatter, child(son) parent(father)

twoway ///
  (line son_ed_rank father_ed_rank_s if father_ed == 0,  lcolor("$color0")) ///
  (line son_ed_rank father_ed_rank_s if father_ed == 2,  lcolor("$color1")) ///
  (line son_ed_rank father_ed_rank_s if father_ed == 5,  lcolor("$color2")) ///
  (line son_ed_rank father_ed_rank_s if father_ed == 8,  lcolor("$color3")) ///
  (line son_ed_rank father_ed_rank_s if father_ed == 10, lcolor("$color4")) ///
  (line son_ed_rank father_ed_rank_s if father_ed == 12, lcolor("$color5")) ///
  (line son_ed_rank father_ed_rank_s if father_ed == 14, lcolor("$color6")) ///
  (scatter son_ed_rank father_ed_rank_s if bc == 1950, msize(medlarge) mcolor("   0 0 0") msymbol(Th)) ///
  (scatter son_ed_rank father_ed_rank_s if bc == 1960, msize(vsmall)    mcolor("  60 0 0") msymbol(+)) ///
  (scatter son_ed_rank father_ed_rank_s if bc == 1970, msize(vsmall)    mcolor(" 120 0 0") msymbol(+)) ///
  (scatter son_ed_rank father_ed_rank_s if bc == 1975, msize(vsmall)    mcolor(" 170 0 0") msymbol(+)) ///
  (scatter son_ed_rank father_ed_rank_s if bc == 1980, msize(vsmall)    mcolor(" 210 0 0") msymbol(+)) ///
  (scatter son_ed_rank father_ed_rank_s if bc == 1985, msize(medlarge) mcolor(" 210 0 0") msymbol(s)) ///
  , legend(order(8 9 10 11 12 13) lab(8 "1950") lab(9 "1960") lab(10 "1970") lab(11 "1975") lab(12 "1980") lab(13 "1985") ring(-1) pos(3)) xlabel(0(20)100) ylabel(20(10)90) ///
  text(35 29  "Father < Primary", color("$color0") size(vsmall)) ///
  text(45 50  "Primary",          color("$color1") size(vsmall)) ///
  text(55 73  "Middle",           color("$color2") size(vsmall)) ///
  text(65 85  "Lower Sec",        color("$color3") size(vsmall)) ///
  text(75 85  "Upper Sec",        color("$color4") size(vsmall)) ///
  text(83 90  "Post-Sec",         color("$color5") size(vsmall)) ///
  text(85 104 "Graduate",        color("$color6") size(vsmall)) ///
  xtitle("Father Ed Rank") ytitle("E(Son Ed Rank)")

graphout scatter_father_son, pdf

/**********************************/
/* FATHER - DAUGHTER SCATTERPLOTS */
/**********************************/
use $mobility/ihds/ihds_mobility.dta, clear
prep_scatter, child(daughter) parent(father)

twoway ///
  (line daughter_ed_rank father_ed_rank_d if father_ed == 0,  lcolor("$color0")) ///
  (line daughter_ed_rank father_ed_rank_d if father_ed == 2,  lcolor("$color1")) ///
  (line daughter_ed_rank father_ed_rank_d if father_ed == 5,  lcolor("$color2")) ///
  (line daughter_ed_rank father_ed_rank_d if father_ed == 8,  lcolor("$color3")) ///
  (line daughter_ed_rank father_ed_rank_d if father_ed == 10, lcolor("$color4")) ///
  (line daughter_ed_rank father_ed_rank_d if father_ed == 12, lcolor("$color5")) ///
  (line daughter_ed_rank father_ed_rank_d if father_ed == 14, lcolor("$color6")) ///
  (scatter daughter_ed_rank father_ed_rank_d if bc == 1960, msize(medlarge) mcolor("   0 0 0") msymbol(Th)) ///
  (scatter daughter_ed_rank father_ed_rank_d if bc == 1970, msize(vsmall)    mcolor(" 120 0 0") msymbol(+)) ///
  (scatter daughter_ed_rank father_ed_rank_d if bc == 1975, msize(vsmall)    mcolor(" 170 0 0") msymbol(+)) ///
  (scatter daughter_ed_rank father_ed_rank_d if bc == 1980, msize(vsmall)    mcolor(" 210 0 0") msymbol(+)) ///
  (scatter daughter_ed_rank father_ed_rank_d if bc == 1985, msize(medlarge) mcolor(" 210 0 0") msymbol(s)) ///
  , legend(order(8 9 10 11 12)    lab(8 "1960") lab(9 "1970") lab(10 "1975") lab(11 "1980") lab(12 "1985") ring(-1) pos(3)) xlabel(0(20)100) ylabel(20(10)90) ///
  text(35 29  "Father < Primary", color("$color0") size(vsmall)) ///
  text(55 50  "Primary",          color("$color1") size(vsmall)) ///
  text(55 73  "Middle",           color("$color2") size(vsmall)) ///
  text(65 85  "Lower Sec",        color("$color3") size(vsmall)) ///
  text(75 85  "Upper Sec",        color("$color4") size(vsmall)) ///
  text(83 90  "Post-Sec",         color("$color5") size(vsmall)) ///
  text(85 104 "Graduate",        color("$color6") size(vsmall)) ///
  xtitle("Father Ed Rank") ytitle("E(Daughter Ed Rank)")

graphout scatter_father_daughter, pdf

/*****************************/
/* MOTHER - SON SCATTERPLOTS */
/*****************************/
use $mobility/ihds/ihds_mobility.dta, clear
prep_scatter, child(son) parent(mother)

twoway ///
  (line son_ed_rank mother_ed_rank_s if mother_ed == 0,  lcolor("$color0")) ///
  (line son_ed_rank mother_ed_rank_s if mother_ed == 2,  lcolor("$color1")) ///
  (line son_ed_rank mother_ed_rank_s if mother_ed == 5,  lcolor("$color2")) ///
  (line son_ed_rank mother_ed_rank_s if mother_ed == 8,  lcolor("$color3")) ///
  (line son_ed_rank mother_ed_rank_s if mother_ed == 10, lcolor("$color4")) ///
  (line son_ed_rank mother_ed_rank_s if mother_ed == 12, lcolor("$color5")) ///
  (line son_ed_rank mother_ed_rank_s if mother_ed == 14, lcolor("$color6")) ///
  (scatter son_ed_rank mother_ed_rank_s if bc == 1960, msize(medlarge) mcolor("   0 0 0") msymbol(Th)) ///
  (scatter son_ed_rank mother_ed_rank_s if bc == 1970, msize(vsmall)    mcolor(" 120 0 0") msymbol(+)) ///
  (scatter son_ed_rank mother_ed_rank_s if bc == 1975, msize(vsmall)    mcolor(" 170 0 0") msymbol(+)) ///
  (scatter son_ed_rank mother_ed_rank_s if bc == 1980, msize(vsmall)    mcolor(" 210 0 0") msymbol(+)) ///
  (scatter son_ed_rank mother_ed_rank_s if bc == 1985, msize(medlarge) mcolor(" 210 0 0") msymbol(s)) ///
  , legend(order(8 9 10 11 12)    lab(8 "1960") lab(9 "1970") lab(10 "1975") lab(11 "1980") lab(12 "1985") ring(-1) pos(3)) xlabel(0(20)100) ylabel(20(10)90) ///
  text(35 40  "Mother < Primary", color("$color0") size(vsmall)) ///
  text(52 75  "Primary",          color("$color1") size(vsmall)) ///
  text(62 85  "Middle",           color("$color2") size(vsmall)) ///
  text(73 98  "Lower Sec",        color("$color3") size(vsmall)) ///
  text(75 85  "Upper Sec",        color("$color4") size(vsmall)) ///
  text(83 90  "Post-Sec",         color("$color5") size(vsmall)) ///
  text(85 104 "Graduate",        color("$color6") size(vsmall)) ///
  xtitle("Mother Ed Rank") ytitle("E(Son Ed Rank)")

graphout scatter_mother_son, pdf

/**********************************/
/* MOTHER - DAUGHTER SCATTERPLOTS */
/**********************************/
use $mobility/ihds/ihds_mobility.dta, clear
prep_scatter, child(daughter) parent(mother)

twoway ///
  (line daughter_ed_rank mother_ed_rank_d if mother_ed == 0,  lcolor("$color0")) ///
  (line daughter_ed_rank mother_ed_rank_d if mother_ed == 2,  lcolor("$color1")) ///
  (line daughter_ed_rank mother_ed_rank_d if mother_ed == 5,  lcolor("$color2")) ///
  (line daughter_ed_rank mother_ed_rank_d if mother_ed == 8,  lcolor("$color3")) ///
  (line daughter_ed_rank mother_ed_rank_d if mother_ed == 10, lcolor("$color4")) ///
  (line daughter_ed_rank mother_ed_rank_d if mother_ed == 12, lcolor("$color5")) ///
  (line daughter_ed_rank mother_ed_rank_d if mother_ed == 14, lcolor("$color6")) ///
  (scatter daughter_ed_rank mother_ed_rank_d if bc == 1960, msize(medlarge) mcolor("   0 0 0") msymbol(Th)) ///
  (scatter daughter_ed_rank mother_ed_rank_d if bc == 1970, msize(vsmall)    mcolor(" 120 0 0") msymbol(+)) ///
  (scatter daughter_ed_rank mother_ed_rank_d if bc == 1975, msize(vsmall)    mcolor(" 170 0 0") msymbol(+)) ///
  (scatter daughter_ed_rank mother_ed_rank_d if bc == 1980, msize(vsmall)    mcolor(" 210 0 0") msymbol(+)) ///
  (scatter daughter_ed_rank mother_ed_rank_d if bc == 1985, msize(medlarge) mcolor(" 210 0 0") msymbol(s)) ///
  , legend(order(8 9 10 11 12)    lab(8 "1960") lab(9 "1970") lab(10 "1975") lab(11 "1980") lab(12 "1985") ring(-1) pos(3)) xlabel(0(20)100) ylabel(20(10)90) ///
  text(35 40  "Mother < Primary", color("$color0") size(vsmall)) ///
  text(57 75  "Primary",          color("$color1") size(vsmall)) ///
  text(64 85  "Middle",           color("$color2") size(vsmall)) ///
  text(78 100  "Lower Sec",        color("$color3") size(vsmall)) ///
  text(80 85  "Upper Sec",        color("$color4") size(vsmall)) ///
  text(88 90  "Post-Sec",         color("$color5") size(vsmall)) ///
  text(90 104 "Graduate",        color("$color6") size(vsmall)) ///
  xtitle("Mother Ed Rank") ytitle("E(Daughter Ed Rank)")

graphout scatter_mother_daughter, pdf

