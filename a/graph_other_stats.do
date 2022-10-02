/*********************************************************/
/* SHOW BOUNDS ON P25, MU50, AND GRADIENT FOR 1960->1980 */
/*********************************************************/

/* possible values to use for the U.S.
- income rank-rank gradient from Chetty: 34.1 (p.2, described as 3.41), Denmark 18
- Hertz (2008): correlation: Denmark: 0.49 in Table 2, 0.3 in Table 7; USA: 0.46 in both.

We use: gradients from Hertz, p25/mu50 from Chetty.

*/


/* store values for USA/DEN in globals */
global gradient_usa 0.46
global gradient_den 0.30

global p25_usa 42
global p25_den 46

global mu50_usa 42
global mu50_den 46

foreach t in gradient p25 mu50 {
  foreach l in usa den {
    local y = ${`t'_`l'} * 1.03
    global `t'_`l'_xy `y' 1995
  }
}

/* create a tmp subpath since there will be a lot of these */
cap mkdir $tmp/mobs

/* convert all matlab bounds results files to stata format */
foreach type in coef mu50 p25 {
  forval group = 0/4 {
    insheet using $mobility/bounds/`type'_`group'.csv, clear names
    gen stat = "`type'"
    gen group = `group'

    /* reconcile varnames with stata varnames */
    ren cohort bc
    
    /* save in stata format for appending below */
    save $tmp/mobs/`type'_`group', replace
  }
}

/* open the IHDS f2=0 bounds */
/* FIX THESE PATHS, SHOULD BE SAME AS ABOVE */
insheet using $mobility/bounds/ihds_mob_mus.csv, clear

/* reconcile varnames */
ren mu stat

/* keep father-sons */
keep if parent == "father" & sex == "son" & y == "rank"
drop parent sex y

/* append all the matlab bounds */
foreach type in coef mu50 p25 {
  forval group = 0/4 {
    append using $tmp/mobs/`type'_`group'
  }
}

/* graph p25, mu50, gradient, for 1960 and 1980  */

/* graph gradient for 1960/85 */
global f2 250
twoway ///
    (rcap lb ub bc if group == 0 & stat == "coef" & inlist(bc, 1960, 1985) & float(f2) == float($f2), color(black) lwidth(medthick)),  ///
    xtitle("Birth Cohort", size(medlarge)) ytitle("") yline($gradient_usa, lcolor(blue)) yline($gradient_den, lcolor(red)) ///
    xlabel(1960 1985, labsize(medlarge)) xscale(r(1950 2000)) ylabel(0.20(0.10)0.70, labsize(medlarge)) ///
    text(.52 1972.5 "India", size(medlarge)) text($gradient_usa_xy "USA", color(blue)) text($gradient_den_xy "Denmark", color(red)) xsize(4.5)
graphout gradient_60_85, pdf

/* repeat for p25 */
twoway ///
    (rcap lb ub bc if group == 0 & stat == "p25" & inlist(bc, 1960, 1985) & float(f2) == float($f2), color(black) lwidth(medthick)),  ///
    xtitle("Birth Cohort", size(medlarge)) ytitle("") yline($p25_usa, lcolor(blue)) yline($p25_den, lcolor(red)) ///
    xlabel(1960 1985, labsize(medlarge)) xscale(r(1950 2000)) ylabel(25(5)55, labsize(medlarge)) ///
    text(37 1972.5 "India", size(medlarge)) text($p25_usa_xy "USA", color(blue)) text($p25_den_xy "Denmark", color(red)) xsize(4.5)
graphout p25_60_85, pdf

/* repeat for mu50 */
twoway ///
    (rcap lb ub bc if group == 0 & stat == "mu50" & inlist(bc, 1960, 1985) & float(f2) == float($f2), color(black) lwidth(medthick)),  ///
    xtitle("Birth Cohort", size(medlarge)) ytitle("") yline($mu50_usa, lcolor(blue)) yline($mu50_den, lcolor(red)) ///
    xlabel(1960 1985, labsize(medlarge)) xscale(r(1950 2000)) ylabel(25(5)55, labsize(medlarge)) ///
    text(37.5 1972.5 "India", size(medlarge)) text($mu50_usa_xy "USA", color(blue)) text($mu50_den_xy "Denmark", color(red)) xsize(4.5)
graphout mu50_60_85, pdf

