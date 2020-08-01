/* graph_subgroup_mob.do: - Graph subgroup mobility changes over time
                          - Create a table with all bounds and midpoints [not used, 2019-12] */
import delimited using $mobility/bounds/ihds_mob_mus.csv, clear

/* recode X axis to show middle of birth cohort for each group */
get_bc_mid

/* drop women in 1950 -- no data */
drop if sex == "daughter" & bc < 1960

/* only focus on fathers here */
drop if parent == "mother"

/* expected son education rank vs. birth cohort for p25 for each of the four subgroups */
twoway ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p25" & group == 1 & sex == "son", color("32 32 32") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p25" & group == 2 & sex == "son", color("150 150 255") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p25" & group == 3 & sex == "son", color("252 46 24") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p25" & group == 4 & sex == "son", color("190 210 160") ) ///
    (line  lb    bc_mid if y == "rank" & mu == "p25" & group == 2 & sex == "son", color("75 75 125") ) ///
    (line  ub    bc_mid if y == "rank" & mu == "p25" & group == 2 & sex == "son", color("75 75 125") ) ///
    , legend(off) ytitle("Expected Son Rank", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) ///
    text(40.5 1963.5 "Forward / Others", size(medium) color(black)) ///
    text(28.5 1977 "Muslims"           , size(medium) color(black)) ///
    text(36.5 1968.3 "Scheduled Castes", size(medium) color(black)) ///
    text(33 1975 "Scheduled Tribes"    , size(medium) color(black)) ///
    ylabel(25(5)45,labsize(medlarge)) xscale(range(1950 1990)) xlabel(1960(10)1990,labsize(medlarge))
graphout ihds_mob_group_time_p25_m, pdf

/* graph output: expected son education rank vs. birth cohort for p75 for each of the four subgroups */
twoway ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p75" & group == 1 & sex == "son", color("32 32 32") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p75" & group == 2 & sex == "son", color("150 150 255") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p75" & group == 3 & sex == "son", color("252 46 24") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p75" & group == 4 & sex == "son", color("190 210 160") ) ///
    (pcarrowi 52.9 1975 55.8 1975) ///
    (line  lb    bc_mid if y == "rank" & mu == "p75" & group == 2 & sex == "son", color("75 75 125") ) ///
    (line ub     bc_mid if y == "rank" & mu == "p75" & group == 2 & sex == "son", color("75 75 125") ) ///
    , legend(off) ytitle("Expected Son Rank", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) ///
    text(67.5 1963.5 "Forward / Others"  , size(medium) color(black)) ///
    text(55 1983 "Muslims"             , size(medium) color(black)) ///
    text(58.5 1965 "Scheduled Castes", size(medium) color(black)) ///
    text(52.5 1975 "Scheduled Tribes"    , size(medium) color(black)) ///
    xlabel(1960(10)1990,labsize(medlarge)) ylabel(50(5)75,labsize(medlarge))
graphout ihds_mob_group_time_p75_m, pdf

twoway ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p25" & group == 1 & sex == "daughter", color("32 32 32") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p25" & group == 2 & sex == "daughter", color("150 150 255") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p25" & group == 3 & sex == "daughter", color("252 46 24") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p25" & group == 4 & sex == "daughter", color("190 210 160") ) ///
    (line  lb    bc_mid if y == "rank" & mu == "p25" & group == 2 & sex == "daughter", color("75 75 125") ) ///
    (line  ub    bc_mid if y == "rank" & mu == "p25" & group == 2 & sex == "daughter", color("75 75 125") ) ///
    , legend(off) ytitle("Expected Daughter Rank", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) ///
    text(42 1980 "Forward / Others", size(medium) color(black)) ///
    text(37 1977 "Muslims"           , size(medium) color(black)) ///
    text(35.25 1986.5 "Scheduled Castes", size(medium) color(black)) ///
    text(29 1980 "Scheduled Tribes"    , size(medium) color(black)) ///
    ylabel(25(5)45,labsize(medlarge)) xscale(range(1950 1990)) xlabel(1960(10)1990,labsize(medlarge))
graphout ihds_mob_group_time_p25_f, pdf

/* graph output: expected son education rank vs. birth cohort for p75 for each of the four subgroups */
twoway ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p75" & group == 1 & sex == "daughter", color("32 32 32") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p75" & group == 2 & sex == "daughter", color("150 150 255") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p75" & group == 3 & sex == "daughter", color("252 46 24") ) ///
    (rarea lb ub bc_mid if y == "rank" & mu == "p75" & group == 4 & sex == "daughter", color("190 210 160") ) ///
    (line  lb    bc_mid if y == "rank" & mu == "p75" & group == 2 & sex == "daughter", color("75 75 125") ) ///
    (line ub     bc_mid if y == "rank" & mu == "p75" & group == 2 & sex == "daughter", color("75 75 125") ) ///
    (pcarrowi 63 1965 61 1970) /// // ST arrow
    (pcarrowi 56 1985 57 1986) /// // Muslims arrow
    (pcarrowi 63 1985 62 1986.5, color(black)) /// // SC arrow
    , legend(off) ytitle("Expected Daughter Rank", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) ///
    text(68 1978 "Forward / Others", size(medium) color(black)) ///
    text(55 1985 "Muslims", size(medium) color(black)) ///
    text(64 1985 "Scheduled Castes"           , size(medium) color(black)) ///
    text(63 1960 "Scheduled Tribes"    , size(medium) color(black)) ///
    xlabel(1960(10)1990,labsize(medlarge)) xscale(range(1950 1990)) ylabel(50(5)75,labsize(medlarge))
graphout ihds_mob_group_time_p75_f, pdf

/* graph output: p25/p75 for each level of son educational attainment and education rank vs birth cohort, by group */
// foreach level in prim hs uni {
foreach level in prim hs uni {
  
  /* set local macros for labeling figures */
  local prim_name "Primary+"
  local hs_name "High School+"
  local uni_name "College+"

  local prim_m_text_fo .7 1972.5
  local prim_m_text_mu .5 1984
  local prim_m_text_sc .42 1959
  local prim_m_text_st .25 1965
  local prim_m_arrow (pcarrowi .26 1965 .34 1965, color(black)) (pcarrowi .39 1958 .33 1958, color(black))
  
  local hs_m_text_fo .15 1975
  local hs_m_text_mu .07 1985
  local hs_m_text_sc .045 1981
  local hs_m_text_st .00 1964
  local hs_m_arrow (pcarrowi .01 1965 .05 1965, color(black)) (pcarrowi .05 1980 .09 1980, color(black))

  local uni_m_text_fo .15 1975
  local uni_m_text_mu .07 1985
  local uni_m_text_sc .045 1981
  local uni_m_text_st .00 1964
  local uni_m_arrow

  local prim_f_text_fo .36 1965
  local prim_f_text_mu .45 1972
  local prim_f_text_sc .07 1972
  local prim_f_text_st .27 1983
  local prim_f_arrow (pcarrowi .43 1972 .23 1972, color(black)) (pcarrowi .08 1972 .18 1972, color(black))
  
  local hs_f_text_fo .10 1978
  local hs_f_text_mu .08 1985
  local hs_f_text_sc .002 1978
  local hs_f_text_st .055 1964
  // arrow order: FO, MU, SC, ST    
  local hs_f_arrow (pcarrowi .095 1980 .062 1980, color(black)) (pcarrowi .075 1985 .065 1985, color(black)) (pcarrowi .005 1978 .027 1978, color(black)) (pcarrowi .05 1965 .01 1965, color(black)) 

  local uni_f_text_fo .15 1975
  local uni_f_text_mu .07 1985
  local uni_f_text_sc .045 1981
  local uni_f_text_st .00 1964
  local uni_f_arrow

  /* create the plot for p25 and p75 */
  foreach p in 25 75 {

      /* show level mobility estimates for men */
      twoway ///
          (rarea lb ub bc_mid if y == "`level'" & mu == "p`p'" & group == 1 & sex == "son", color("32 32 32") ) ///
          (rarea lb ub bc_mid if y == "`level'" & mu == "p`p'" & group == 2 & sex == "son", color("150 150 255") ) ///
          (rarea lb ub bc_mid if y == "`level'" & mu == "p`p'" & group == 3 & sex == "son", color("252 46 24") ) ///
          (rarea lb ub bc_mid if y == "`level'" & mu == "p`p'" & group == 4 & sex == "son", color("190 210 160") ) ///
          ``level'_m_arrow', legend(off)  ///
          text(``level'_m_text_fo' "Forward / Others"  , size(medium) color(black)) ///
          text(``level'_m_text_mu'  "Muslims"          , size(medium) color(black)) ///
          text(``level'_m_text_sc'  "Scheduled Castes" , size(medium) color(black)) ///
          text(``level'_m_text_st'  "Scheduled Tribes" , size(medium) color(black)) ///
          ylabel(,labsize(medlarge)) xlabel(1960(10)1980, labsize(medlarge)) ytitle("Share Sons with ``level'_name'", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) 
      graphout ihds_mob_group_time_p`p'_`level'_m, pdf
      
      /* repeat for women, without labels */
      twoway ///
          (rarea lb ub bc_mid if y == "`level'" & mu == "p`p'" & group == 1 & sex == "daughter", color("32 32 32") ) ///
          (rarea lb ub bc_mid if y == "`level'" & mu == "p`p'" & group == 2 & sex == "daughter", color("150 150 255") ) ///
          (rarea lb ub bc_mid if y == "`level'" & mu == "p`p'" & group == 3 & sex == "daughter", color("252 46 24") ) ///
          (rarea lb ub bc_mid if y == "`level'" & mu == "p`p'" & group == 4 & sex == "daughter", color("190 210 160") ) ///
          ``level'_f_arrow', legend(off)  ///
          text(``level'_f_text_fo' "Forward / Others"  , size(medium) color(black)) ///
          text(``level'_f_text_mu'  "Muslims"          , size(medium) color(black)) ///
          text(``level'_f_text_sc'  "Scheduled Castes" , size(medium) color(black)) ///
          text(``level'_f_text_st'  "Scheduled Tribes" , size(medium) color(black)) ///
          ylabel(,labsize(medlarge)) xlabel(1960(10)1980, labsize(medlarge)) ytitle("Share Daughters with ``level'_name'", size(medlarge)) xtitle("Birth Cohort", size(medlarge)) 
      graphout ihds_mob_group_time_p`p'_`level'_f, pdf
  }
}

/*******************/
/* STATS FOR PAPER */
/*******************/
use $mobility/ihds/ihds_mobility.dta, clear
  
/* Muslim male mobility in 1960s */
bound_mobility [aw=wt] if bc == 1960 & group == 2, s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
local mid = (`r(mu_ub)' + `r(mu_lb)') / 2
store_tex_constant, file($out/mob_constants) idshort(mob_muslim_1960) idlong(mobility_muslim_1960) value(`mid') desc("Father-son mobility in 1960 (Muslim)")

/* Muslim male mobility in 1985s */
bound_mobility [aw=wt] if bc == 1985 & group == 2, s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
local mid = (`r(mu_ub)' + `r(mu_lb)') / 2
store_tex_constant, file($out/mob_constants) idshort(mob_muslim_1985) idlong(mobility_muslim_1985) value(`mid') desc("Father-son mobility at present (Muslim)")

/* SC male mobility in 1985s */
bound_mobility [aw=wt] if bc == 1985 & group == 3, s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
local mid = (`r(mu_ub)' + `r(mu_lb)') / 2
store_tex_constant, file($out/mob_constants) idshort(mob_sc_1985) idlong(mobility_sc_1985) value(`mid') desc("Father-son mobility at present (SC)")

/* ST male mobility in 1985s */
bound_mobility [aw=wt] if bc == 1985 & group == 4, s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
local mid = (`r(mu_ub)' + `r(mu_lb)') / 2
store_tex_constant, file($out/mob_constants) idshort(mob_st_1985) idlong(mobility_st_1985) value(`mid') desc("Father-son mobility at present (ST)")
