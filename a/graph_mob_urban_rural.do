/*************************************************************************/
/* PLOT YOUNGEST BIRTH COHORT BY URBAN/RURAL, BY GENDER, AND BY SUBGROUP */
/*************************************************************************/

/* FIRST, STORE ALL THE ESTIMATES */

/* Open core mobility file */
use $mobility/ihds/ihds_mobility.dta, clear

/* set output file for desired graph */
global f $tmp/ihds_mob_rural_urban_mf.csv
cap erase $f
append_to_file using $f, s(lb, ub, bc, mu, group, urban, male)

/* loop over birth cohorts */
foreach bc in 1985 {

  /* loop over urban */
  forval urb = 0/1 {

    /* loop over subgroups */
    forval g = 1/4 {

      di "`bc'-`g'-`urb'"

      /* group upward mobility for boys, then girls */
      bound_param [aw=wt] if urban == `urb' & bc == `bc' & male == 1 & group == `g', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
      append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p25,`g', `urb', 1)
      
      bound_param [aw=wt] if urban == `urb' & bc == `bc' & male == 0 & group == `g', s(0) t(50) xvar(father_ed_rank_d) yvar(daughter_ed_rank) forcemono
      append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p25,`g', `urb', 0)
    }

    /* repeat for pooled groups, boys then girls */
    bound_param [aw=wt] if urban == `urb' & bc == `bc' & male == 1 , s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p25,`g', `urb', 1)
      
    bound_param [aw=wt] if urban == `urb' & bc == `bc' & male == 0 , s(0) t(50) xvar(father_ed_rank_d) yvar(daughter_ed_rank) forcemono
    append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p25,`g', `urb', 0)
    
  }

  /* repeat for pooled groups and sector, boys then girls */
  bound_param [aw=wt] if bc == `bc' & male == 1 , s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
  append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p25,`g', `urb', 1)

  bound_param [aw=wt] if bc == `bc' & male == 0 , s(0) t(50) xvar(father_ed_rank_d) yvar(daughter_ed_rank) forcemono
  append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p25,`g', `urb', 0)

}

/* NOW LOAD THE BOUNDS DATA */
import delimited using $f, clear

/* drop the pooled sector lines */
drop if mi(urban)

/* set group to 0 for pooled groups */
replace group = 0 if mi(group)

/* drop unused vars */
drop bc mu

/* sort these in the order we want them on the graph */
sort group male urban

/* set all outcomes to the same Y value to make the graph 1-dimensional */
gen y = _n

keep if group == 0

/* make an rcap in separate colors for rural/urban */
twoway ///
    (rcapsym lb ub y, color(black) horizontal lwidth(medthick) msize(vlarge) msymbol(S)), ///
    text(1 25 "{stSerif:Rural Daughters}", justification(right) size(medsmall)) ///
    text(2 25 "{stSerif:Urban Daughters}", justification(right) size(medsmall)) ///
    text(3 25 "{stSerif:Rural Sons}",      justification(right) size(medsmall)) ///
    text(4 25 "{stSerif:Urban Sons}",      justification(right) size(medsmall)) ///
    legend(off) xscale(range(20 50)) xlabel(30 35 40 45 50) xtitle("Bottom Half Mobility", size(medium)) ytitle("") ylabel(0 5, nolabels)
  
graphout mob_urban_rural_mf, pdf

/******************************************************************************/
/* GRAPH MOBILITY GAPS TO FORWARD FOR EACH SUBGROUP, IN URBAN AND RURAL AREAS */
/******************************************************************************/

/* Open core mobility file */
use $mobility/ihds/ihds_mobility, clear

/* set output file for desired graph */
global f $tmp/ihds_mob_rural_urban_groups.csv
cap erase $f
append_to_file using $f, s(lb, ub, bc, mu, group, urban, male)

/* loop over birth cohorts */
foreach bc in 1985 {

  /* loop over urban */
  forval urb = 0/1 {
   
    /* loop over subgroups */
    forval g = 1/4 {

      di "`bc'-`g'-`urb'"
    
      /* group upward mobility for boys */
      bound_param [aw=wt] if urban == `urb' & group == `g' & bc == `bc', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
      append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p25,`g', `urb', 1)
    }
  }
}

/* load the data */
import delimited using $f, clear

/* take the mean of the lower and upper bound mobility */
egen mob = rowmean(lb ub)
drop lb ub

/* keep boys' mobility only */
keep if male == 1

/* select the 1980 bc, this is a somewhat arbitrary choice, can be changed to any bc */
keep if bc == 1985
drop bc

/* create gap with group 1 for each subgroup in rural and urban areas
make sure there is only one birth cohort in the data before running this step. */
bys mu urban: egen group1_mob = max(mob * (group == 1))
drop if group == 1
gen mob_gap = mob - group1_mob
drop mob group1_mob

/* rehape the data to be wide */
reshape wide mob_gap, j(group) i(urban mu)

/* add labels to the rural and urban data */
label define urban 0 "Rural" 1 "Urban"
label values urban urban

/* graph output: the p25 mobility gap for each group in rural and urban areas */
graph bar mob_gap2 mob_gap3 mob_gap4 if mu == "p25", over(urban) ///
blabel(total, format(%5.1f) color(black) size(small)) ///
legend(ring(0) pos(5) rows(3) lab(1 "Muslims") lab(2 "Scheduled Castes") lab(3 "Scheduled Tribes")) ytitle("Upward Mobility Gap with Forwards/Others") 
graphout mob_urban_rural_groups, pdf
