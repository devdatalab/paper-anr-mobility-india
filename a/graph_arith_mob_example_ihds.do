
/*********************************/
/* get first 3 moments from IHDS */
/*********************************/
use $mobility/ihds/ihds_mobility, clear
keep if male == 1 & bc == 1960 & !mi(father_ed_rank_s)
bound_mobility [aw=wt], s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank)

collapse (mean) son_ed_rank [aw=wt], by(father_ed_rank_s)
get_rank_cuts_from_rank_means father_ed_rank_s, gen_xcut(bin) gen_xsize(binsize) 
list
global xline1 = bin[1]
global xline2 = bin[2]
global xline3 = bin[3]
global xmean1 = father_ed_rank_s[1]
global xmean2 = father_ed_rank_s[2]
global xmean3 = father_ed_rank_s[3]
global ymean1 = son_ed_rank[1]
global ymean2 = son_ed_rank[2]
global ymean3 = son_ed_rank[3]

/* rounded moments for text boxes */
global xline1r = round($xline1)
global xline2r = round($xline2)
global xmean2r = round($xmean2)
global ymean1r = round($ymean1)
global ymean2r = round($ymean2)

/*************************************************/
/* use these values to seed a new sample dataset */
/*************************************************/

/* create an empty 1000 row dataset, each point is 0.1% */
clear
set obs 1000
gen row_number = _n
gen x = row_number / 10

/* create points / moments from stored locals */
gen     py = $ymean1 if row_number == round($xmean1 * 10)
replace py = $ymean2 if row_number == round($xmean2 * 10)
replace py = $ymean3 if row_number == round($xmean3 * 10)

/* create CEF with mu-0-50 that is ruled out for being too high */
gen     c1 = 41 if inrange(x, 0, 50)
replace c1 = 27 if inrange(x, 50, $xline1)

/* create CEF with mu-0-50 that is ruled out for being too low */
gen     c2 = 36 if inrange(x, 0, 50)
replace c2 = 59 if inrange(x, 50, $xline1)

/* create actual mu upper and lower bounds */
gen mu_lb = 36.57
gen mu_ub = 39

/* make sure X axis is sorted for lines */
sort x

/* create globals for bin boundary locations and labels */
global colorcef  `""80 170 75""'
global colorbox `""40 90 34""'
global colorblue `""80 75 170""'
global colorltgray `""230 230 230""'
global colormedgray `""180 180 180""'
global xlines xline($xline1 $xline2 $xline3, lwidth(medthick) lpattern(solid) lcolor(black))
global labels xlabel(0(20)$xline3) xscale(range(0 $xline3)) ylabel(0(20)100) 
global line50 xline(50, lcolor($colorcef) lwidth(medthick) lpattern(-))
global scatteropts color(black) msize(large) legend(off)
global textboxsize size(medsmall)
global textboxoptions box $textboxsize width(42) tstyle(smbody) margin(t+1) justification(left) fcolor(white) lwidth(medium) lcolor($colorbox)
global textboxslim    box $textboxsize width(29) tstyle(smbody) margin(t+1) justification(left) fcolor(white) lwidth(medium) lcolor($colorblue)
global textboxblue    box $textboxsize width(42) tstyle(smbody) margin(t+1) justification(left) fcolor(white) lwidth(medium) lcolor($colorblue)

/* this text box is just for the numbers 1->4 */
global textboxnums    box width(3) tstyle(heading) height(3) size(large) margin(medium) justification(center) alignment(middle) fcolor($colorltgray) lwidth(thick) lcolor($colormedgray)

/* store marked up mu-0-50 SMCL text in a global */
global smcl_mu {&mu}{subscript:0}{superscript:50}

/* restrict graph to the ranks in the sample */
keep if x < $xline3

/* store graph annotations in globals */
global box1 `" "In this bin, the data tell us" "only that the expected child" "rank is $ymean1r, given a parent" "between ranks 0 and $xline1r.""'
global box2 `" "We want to calculate $smcl_mu," "which is the mean value" "of the CEF when parent" "rank is between 0 and 50." "'
global box3 `" "In the 2nd bin, we" "know only that" "E(child rank) = $ymean2r," "given a parent" "between ranks $xline1r " "and $xline2r. " "'

/* graph with no target line */
twoway ///
    (scatter py x , $scatteropts ///
    xtitle("Parent Rank") ytitle("Child Rank") ///
    $labels $xlines   ///
    text(50 29   $box1, $textboxblue) ///
    text(75 64.4 $box3, $textboxslim)) ///
    (pcarrowi 40 0 40 $xline1r, lwidth(medthick) color($colorblue)) ///
    (pcarrowi 40 $xline1r 40 0, lwidth(medthick) color($colorblue))
    
graphout example_ihds1, pdf

/* add target line and explanation to graph */
twoway ///
    (scatter py x , $scatteropts  ///
    xtitle("Parent Rank") ytitle("Child Rank") ///
    $line50 ///
    $labels $xlines ///
    text(90 5  "{bf:1}", $textboxnums) ///
    text(60 29   $box1,  $textboxblue) ///
    text(20 25   $box2,  $textboxoptions) ///
    text(80 64.4 $box3,  $textboxslim)) ///
    (pcarrowi 60 0 60 $xline1r, lwidth(medthick) color($colorblue)) ///
    (pcarrowi 60 $xline1r 60 0, lwidth(medthick) color($colorblue)) ///
    (pcarrowi 20 0 20 50,       lwidth(medthick) color($colorbox)) ///
    (pcarrowi 20 50 20 0,       lwidth(medthick) color($colorbox)) ///
    (pcarrowi 50 29 42 29,       lwidth(medthick) color($colorblue)) ///
    (pcarrowi 67 64.4 58 64.4,       lwidth(medthick) color($colorblue)) 

graphout example_ihds2, pdf

/* candidate function 1 */
twoway ///
    (line c1 x if inrange(x, 0, 49.5), color($colorcef) lwidth(medthick)) ///
    (line c1 x if inrange(x, 50.5, 59.5), color($colorcef) lwidth(medthick) lpattern(dash_dot)) ///
    (pcarrowi 20 30 25.5 53,       lwidth(medthick) color($colorbox)) ///
    (pcarrowi 28 20 40 20,       lwidth(medthick) color($colorbox)) ///
    (scatter py x , $scatteropts  ///
    text(90 5  "{bf:2}", $textboxnums) ///
    text(70 25 "We reject $smcl_mu {&gt} 39, as" ///
    "it would require a mean"          ///
    "value in ranks [50, $xline1r]"       ///
    "of less than 39, violating"              ///
    "monotonicity.", $textboxoptions) ///
    text(20 20 "In this example, a $smcl_mu of 41" ///
    "necessitates a mean value" ///
    "in [50, $xline1r] of 28, which is" ///
    "a violation of monotonicity.", $textboxoptions) ///
  xtitle("Parent Rank") ytitle("Child Rank") ///
    $line50 ///
    $labels $xlines) ///

graphout example_ihds3, pdf

/* candidate function 2 */
twoway ///
    (line c2 x if inrange(x, 0, 49.5), color($colorcef) lwidth(medthick)) ///
    (line c2 x if inrange(x, 50.5, 59.5), color($colorcef) lwidth(medthick) lpattern(dash_dot)) ///
    (scatter py x , $scatteropts  ///
    text(90 5  "{bf:3}", $textboxnums) ///
    text(70 25 "We reject $smcl_mu {&le} 36, as " ///
    "it would require a mean Y"          ///
    "in ranks [50, $xline1r] of {&ge} $ymean2r"       ///
    "violating monotonicity with"              ///
    "the next bin.", $textboxoptions) ///
    xtitle("Parent Rank") ytitle("Child Rank") ///
    $line50 ///
    $labels $xlines) ///
    (pcarrowi 69 54 61 54,       lwidth(medthick) color($colorbox)) ///
    (pcarrowi 66 64.4 58 64.4,       lwidth(medthick) color($colorbox)) 

graphout example_ihds4, pdf

/* mu-0-50 bounds are 37-40 */
twoway ///
    (rcap mu_lb mu_ub x if inrange(x, 0, 50), color($colorcef) ) ///
    (scatter py x , $scatteropts  ///
    xtitle("Parent Rank") ytitle("Child Rank") ///
    text(90 5  "{bf:4}", $textboxnums) ///
    text(70 25 "We can therefore bound" ///
    "$smcl_mu between 36 and 39,"              ///
    "using only the monotonicity"               ///
    "of the CEF. Given a parent"         ///
    "in the bottom half, a child"        ///
    "can expect to attain a rank"       ///
    "between 36 and 39.", $textboxoptions)       ///
    $line50 ///
    $labels $xlines)
    
graphout example_ihds5, pdf


