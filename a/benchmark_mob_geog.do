/* compare geographic distribution of mobility in U.S. and India */

/*********************/
/* USA (Chetty 2014) */
/*********************/
import excel using $mobility/us/chetty_mob_geog_cz.xlsx, cellrange(a15:f755) clear

ren B cz
ren C state
ren D pop
ren E relmob
ren F p25

sum p25, d
di "Interquartile range is [`r(p25)', `r(p75)']."
/*****************/
/* India (towns) */
/*****************/
use $mobility/secc/secc_mobility_town.dta, clear
egen mid = rowmean(p25_lb p25_ub)
sum mid, d
di "Interquartile range is [`r(p25)', `r(p75)']."

use $mobility/secc/secc_mobility_subdist_rural.dta, clear
egen mid = rowmean(p25_lb p25_ub)
sum mid, d
di "Interquartile range is [`r(p25)', `r(p75)']."
