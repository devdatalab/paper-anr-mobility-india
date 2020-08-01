/*************************************************************************/
/* Mortality-style scatter plot showing changing rank and E(Y) over time */
/*************************************************************************/

/* open IHDS mobility */
use $mobility/ihds/ihds_mobility.dta, clear

collapse (mean) son_ed_rank (firstnm) father_ed [aw=wt], by(father_ed_rank_s bc)
sort bc father_ed_rank_s

twoway ///
    (line son_ed_rank father_ed_rank_s if father_ed == 0, lcolor("100 100 100")) ///
    (line son_ed_rank father_ed_rank_s if father_ed == 2, lcolor("100 100 100")) ///
    (line son_ed_rank father_ed_rank_s if father_ed == 5, lcolor("100 100 100")) ///
    (line son_ed_rank father_ed_rank_s if father_ed == 8, lcolor("100 100 100")) ///
    (line son_ed_rank father_ed_rank_s if father_ed == 10, lcolor("100 100 100")) ///
    (line son_ed_rank father_ed_rank_s if father_ed == 12, lcolor("100 100 100")) ///
    (line son_ed_rank father_ed_rank_s if father_ed == 14, lcolor("100 100 100")) ///
    (scatter son_ed_rank father_ed_rank_s if bc == 1950, msize(medlarge) mcolor("   0 0 0") msymbol(Th)) ///
    (scatter son_ed_rank father_ed_rank_s if bc == 1960, msize(small)    mcolor("  60 0 0") msymbol(+)) ///
    (scatter son_ed_rank father_ed_rank_s if bc == 1970, msize(small)    mcolor(" 120 0 0") msymbol(+)) ///
    (scatter son_ed_rank father_ed_rank_s if bc == 1975, msize(small)    mcolor(" 170 0 0") msymbol(+)) ///
    (scatter son_ed_rank father_ed_rank_s if bc == 1980, msize(small)    mcolor(" 210 0 0") msymbol(+)) ///
    (scatter son_ed_rank father_ed_rank_s if bc == 1985, msize(medlarge) mcolor(" 255 0 0") msymbol(s)) ///
    , legend(order(8 9 10 11 12 13) lab(8 "1950") lab(9 "1960") lab(10 "1970") lab(11 "1975") lab(12 "1980") lab(13 "1985") ring(-1) pos(3)) xlabel(0(20)100) ylabel(20(10)80) ///
    xtitle("Father Ed Rank") ytitle("E(Son Ed Rank)")

graphout mob_moments_scatter, pdf


