/* Makes a graph of education LEVELS over time, by subgroup */

/* open the IHDS mobility dataset */
use $mobility/ihds/ihds_mobility.dta, clear
keep if birth_year < 1992
collapse (mean) son_ed daughter_ed [aw=wt], by(birth_year group)

twoway ///
( scatter son_ed birth_year if group == 1, msymbol(Oh) msize(small) mcolor("$gencolor")  )  ///
( scatter son_ed birth_year if group == 2, msymbol(Sh) msize(small) mcolor("$muscolor") )  ///
( scatter son_ed birth_year if group == 3, msymbol(X) msize(medium) mcolor("$sccolor") ) ///
( scatter son_ed birth_year if group == 4, msymbol(Th) msize(small) mcolor("$stcolor") ) ///
( lowess son_ed birth_year if group == 1, lwidth(medthick) lcolor("$gencolor")  )  ///
( lowess son_ed birth_year if group == 2, lwidth(medthick) lcolor("$muscolor") )  ///
( lowess son_ed birth_year if group == 3, lwidth(medthick) lcolor("$sccolor") ) ///
( lowess son_ed birth_year if group == 4, lwidth(medthick) lcolor("$stcolor") ///        
    legend(ring(0) pos(5) order(1 2 3 4) lab(1 "Forward/Other") lab(2 "Muslim") lab(3 "SC") lab(4 "ST") ) ///
ylab(0(2)10)    xtitle("Birth Year") ytitle("Average education of sons (years)") ) 

graphout son_ed_time, pdf  

twoway ///
( scatter daughter_ed birth_year if group == 1, msymbol(Oh) msize(small) mcolor("$gencolor")  )  ///
( scatter daughter_ed birth_year if group == 2, msymbol(Sh) msize(small) mcolor("$muscolor") )  ///
( scatter daughter_ed birth_year if group == 3, msymbol(X) msize(medium) mcolor("$sccolor") ) ///
( scatter daughter_ed birth_year if group == 4, msymbol(Th) msize(small) mcolor("$stcolor") ) ///
( lowess daughter_ed birth_year if group == 1, lwidth(medthick) lcolor("$gencolor")  )  ///
( lowess daughter_ed birth_year if group == 2, lwidth(medthick) lcolor("$muscolor") )  ///
( lowess daughter_ed birth_year if group == 3, lwidth(medthick) lcolor("$sccolor") ) ///
( lowess daughter_ed birth_year if group == 4, lwidth(medthick) lcolor("$stcolor") ///        
    legend(ring(0) pos(5) order(1 2 3 4) lab(1 "Forward/Other") lab(2 "Muslim") lab(3 "SC") lab(4 "ST") ) ///
ylab(0(2)10)    xtitle("Birth Year") ytitle("Average education of daughters (years)") ) 

graphout daughter_ed_time, pdf  

