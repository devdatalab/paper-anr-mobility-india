/*************************************/
/* IHDS NATIONAL MOBILITY OVER TIME  */
/*************************************/

/* a program to generate a standard aggregate mobility over time graph */
cap prog drop graph_mob
prog def graph_mob
  syntax, name(string) mu(string) sex(string) parent(string) ylabel(string) [text(string) ytitle(string) title(string) y(string)]

  if mi("`y'") local y rank
  
  twoway (rarea lb ub bc_mid if mu == "`mu'" & sex == "`sex'" & parent == "`parent'" & y == "`y'", ///
      lwidth(medthick) color("32 32 32")),  ///
      `text' ///
      ytitle("`ytitle'", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) ///
      legend(off) ///
      ylabel("`ylabel'",labsize(medlarge)) xlabel(1950(10)1990,labsize(medlarge)) ///
      title("`title'", size(medlarge)) ///
      name(`name', replace) xsize(4.6)
end

/********/
/* MAIN */
/********/

/* open mobility estimates file */
import delimited using $mobility/bounds/ihds_mob_mus.csv, clear

/* keep only the pooled group results */
keep if group == 0

/* get midpoint of each birth cohort */
get_bc_mid

/* drop 1950s girls for which there is no data */
drop if bc < 1960 & sex == "daughter"

/***************************/
/* ALL-INDIA RANK MOBILITY */
/***************************/

/* Father-Son and Father-Daughter in a two panel graph */
graph_mob, name(ihds_mob_time_fs) mu(p25) sex(son) parent(father) ///
        ylabel(30(5)50) ytitle("E(Son Rank)")
graphout ihds_mob_time_fs, pdf

graph_mob, name(ihds_mob_time_fd) mu(p25) sex(daughter) parent(father) ///
        ylabel(30(5)50) ytitle("E(Daughter Rank)")
graphout ihds_mob_time_fd, pdf

/* Mother-Son and Mother-Daughter -- uninformative graph for appendix  */
graph_mob, name(ihds_mob_time_ms) mu(p25) sex(son) parent(mother) ///
        ylabel(30(5)50) ytitle("E(Son Rank)")
graphout ihds_mob_time_ms, pdf

graph_mob, name(ihds_mob_time_md) mu(p25) sex(daughter) parent(mother) ///
        ylabel(30(5)50) ytitle("E(Daughter Rank)")
graphout ihds_mob_time_md, pdf

/* 4-panel graph with ms, md, fs, fd, for mu-0-80 (also likely appendix) */
graph_mob, name(ihds_mob_time_fs80) mu(p40) sex(son) parent(father) ///
    ylabel(30(5)50)
graphout ihds_mob_time_fs80, pdf

graph_mob, name(ihds_mob_time_fd80) mu(p40) sex(daughter) parent(father) ///
    ylabel(30(5)50)
graphout ihds_mob_time_fd80, pdf

graph_mob, name(ihds_mob_time_ms80) mu(p40) sex(son) parent(mother) ///
    ylabel(30(5)50)
graphout ihds_mob_time_ms80, pdf

graph_mob, name(ihds_mob_time_md80) mu(p40) sex(daughter) parent(mother) ///
    ylabel(30(5)50)
graphout ihds_mob_time_md80, pdf




/* graph output: expected son education vs. birth cohort, upward mobility (only) with Denmark / USA ylines */
twoway (rarea lb ub bc_mid if y == "rank" & mu == "p25" & sex == "son" & parent == "father", lwidth(thick) color("150 150 255")),  ///
  text(35 1972.5 "{stSerif:Upward Mobility (India)}", size(medsmall) color(black))  ///
ytitle("Average Son Rank") xtitle("Birth Cohort") legend(off) ylabel(20(5)60,) xlabel(1950(10)1990,) ///
yline(41.8 46, lcolor(gs8) lwidth(medthick)) title("Average Education Rank for Sons with Father in Bottom Half of Distribution", size(medsmall)) ///
text(46.5 1985 "{stSerif:Denmark}", size(medsmall)) text(42.5 1988 "{stSerif:USA}", size(medsmall)) 
graphout ihds_upward_mob_time_new_s, pdf

twoway (rarea lb ub bc_mid if y == "rank" & mu == "p25" & sex == "daughter" & parent == "father", lwidth(thick) color("150 150 255")),  ///
  text(35 1972.5 "{stSerif:Upward Mobility (India)}", size(medsmall) color(black))  ///
ytitle("Average Daughter Rank") xtitle("Birth Cohort") legend(off) ylabel(20(5)60,) xlabel(1950(10)1990,) ///
yline(41.8 46, lcolor(gs8) lwidth(medthick)) title("Average Education Rank for Daughters with Father in Bottom Half of Distribution", size(medsmall)) ///
text(46.5 1985 "{stSerif:Denmark}", size(medsmall)) text(42.5 1988 "{stSerif:USA}", size(medsmall)) 
graphout ihds_upward_mob_time_new_d, pdf


/* BELOW: aggregate with levels as outputs */

/* graph output: expected son completion of primary+, middle+, hs+ vs. birth cohort, upward and downward mobility */
foreach ed in prim mid hs uni {

  /* set locals to describe where on the graph to print labels
  for the upward and downward mobility plots. */
  local xed1 1975
  local xed2 1975
  if "`ed'" == "mid" {
    local sed = "Middle School"
    local yed1 .36
    local yed2 .73
  }
  if "`ed'" == "uni" {
    local sed = "Any College"
    local yed1 .02
    local yed2 .18
  }
  if "`ed'" == "hs" {
    local sed = "High School"
    local yed1 .06
    local yed2 .31
  }
  if "`ed'" == "prim" {
    local sed = "Primary"
    local yed1 .54
    local yed2 .85
  }
  
  /* graph boys */
  local s = "Son E(`sed'+)"
  twoway (rarea lb ub bc_mid if y == "`ed'" & mu == "p25" & sex == "son" & parent == "father", lwidth(medthick) color("32 32 32")) ///
         (rarea lb ub bc_mid if y == "`ed'" & mu == "p75" & sex == "son" & parent == "father", lwidth(medthick) color("150 150 255")),  ///
         text(`yed1' `xed1' "{&mu}{sub:0}{sup:50}", size(medium) color(black)) text(`yed2' `xed2' "{&mu}{sub:50}{sup:100}", size(medium) color(black))  ///
         ytitle("`s'", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) legend(off) ///
         xlab(1950(10)1990 ,labsize(medlarge)) ylab(,labsize(medlarge)) name(ihds_mob_time_`ed'_m, replace) xsize(4.6)
  graphout ihds_mob_time_`ed'_m, pdf

  /* graph girls */
  local s = "Daughter E(`sed'+)"
  twoway (rarea lb ub bc_mid if y == "`ed'" & mu == "p25" & sex == "daughter" & parent == "father", lwidth(medthick) color("32 32 32")) ///
         (rarea lb ub bc_mid if y == "`ed'" & mu == "p75" & sex == "daughter" & parent == "father", lwidth(medthick) color("150 150 255")),  ///
         text(`yed1' `xed1' "{&mu}{sub:0}{sup:50}", size(medium) color(black)) text(`yed2' `xed2' "{&mu}{sub:50}{sup:100}", size(medium) color(black))  ///
         ytitle("`s'", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) legend(off) ///
         xlab(1950(10)1990 ,labsize(medlarge)) ylab(,labsize(medlarge)) name(ihds_mob_time_`ed'_f, replace) xsize(4.6)
  graphout ihds_mob_time_`ed'_f, pdf

  /* combine boys and girls */
  graph combine ihds_mob_time_`ed'_m ihds_mob_time_`ed'_f, rows(1) ycommon
  graphout ihds_mob_time_`ed'_both, pdf
}



/*****************************/
/* stats referenced in paper */
/*****************************/

gen mid = (lb + ub) / 2
sum mid if parent == "father" & sex == "son" & bc == 1985 & mu == "p25" & y == "rank"
store_tex_constant, file($out/mob_constants) idshort(mob_m_now) idlong(mobility_male_1985) value(`r(mean)') desc("Father-son mobility at present")

sum mid if parent == "father" & sex == "daughter" & bc == 1985 & mu == "p25" & y == "rank"
store_tex_constant, file($out/mob_constants) idshort(mob_f_now) idlong(mobility_female_1985) value(`r(mean)') desc("Father-daughter mobility at present")

