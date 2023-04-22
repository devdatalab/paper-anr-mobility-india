/***************************************************/
/* CORRELATES OF RURAL SUBDISTRICT UPWARD MOBILITY */
/***************************************************/
use $mobility/secc/secc_mobility_subdist_rural, clear

gen p25_width = p25_ub - p25_lb
keep if p25_width < 1.5
drop p25_width group_id is_mon

foreach p in 25 {
  egen p`p' = rowmean(p`p'_lb p`p'_ub)
  drop p`p'_lb p`p'_ub
}

/* drop places with very few obs */
drop if n_obs < 1000

/* merge rural subdistrict data */
merge 1:1 pc11_state_id pc11_district_id pc11_subdistrict_id using $mobility/covars/subdistrict_mobility_covariates
keep if _merge == 3
drop _merge

/* create additional useful vars */
gen sc_share = pc11_pca_p_sc / pc11_pca_tot_p
gen st_share = pc11_pca_p_st / pc11_pca_tot_p
gen ln_cons = ln(secc_ave_pc_cons)
gen ln_dist = ln(pc11_dist_km_town)
gen ln_remote = -ln_dist

/* clean covariates */
winsorize ec13_man_job_pc 0 0.1, replace
winsorize secc_ave_ed_growth 1 6, replace
winsorize pc_pop_growth_rate 0 .4, replace

global varlist sc_share st_share secc_dissim_scst secc_num_eb ln_remote secc_land_gini secc_cons_gini ec13_man_job_pc ln_cons secc_ave_year_ed pc11_p_sch_pc pc11_h_sch_pc pc11_vill_pop_road_share pc11_vill_pop_power_share pc_pop_growth_rate

/* normalize all X vars */
foreach v in $varlist {
  normalize `v', gen(`v'_norm)
}

/* create district groups */
group pc11_state_id
group pc11_state_id pc11_district_id

/* label variables */
label var sc_share "Share Scheduled Caste"
label var st_share "Share Scheduled Tribe"
label var secc_dissim_scst "SC/ST Segregation"
label var secc_land_gini "Land Inequality"
label var secc_cons_gini "Consumption Inequality"
label var secc_ave_year_ed "Average Years Education"
label var ec13_man_job_pc "Manufacturing Jobs Per Capita"
label var ln_cons "Log Rural Consumption"
label var ln_remote "Average Remoteness"
label var pc11_p_sch_pc "Primary Schools per Capita"
label var pc11_h_sch_pc "High Schools per Capita"
label var pc11_vill_pop_road_share "Share Villages with Paved Roads"
label var pc11_vill_pop_power_share "Share Villages with Power"
label var sc_share_norm "Share Scheduled Caste"
label var st_share_norm "Share Scheduled Tribe"
label var secc_dissim_scst_norm "SC/ST Segregation"
label var secc_land_gini_norm "Land Inequality"
label var secc_cons_gini_norm "Consumption Inequality"
label var secc_ave_year_ed_norm "Average Years Education"
label var ec13_man_job_pc_norm "Manufacturing Jobs Per Capita"
label var ln_cons_norm "Log Rural Consumption"
label var ln_remote_norm "Average Remoteness"
label var pc11_p_sch_pc_norm "Primary Schools per Capita"
label var pc11_h_sch_pc_norm "High Schools per Capita"
label var pc11_vill_pop_road_share_norm "Share Villages with Paved Roads"
label var pc11_vill_pop_power_share_norm "Share Villages with Power"

save $tmp/rural_mob_covars, replace

/* presentation varlist */
global pres_list sc_share secc_dissim_scst ln_remote secc_land_gini secc_cons_gini ec13_man_job_pc ln_cons secc_ave_year_ed pc11_p_sch_pc pc11_h_sch_pc pc11_vill_pop_road_share pc11_vill_pop_power_share

/* BIVARIATE COEFPLOT */
eststo clear
foreach v in $pres_list {
  eststo `v': reg p25 `v'_norm, robust cluster(sdgroup)
}

coefplot (sc_share \ secc_dissim_scst \ secc_land_gini \ secc_cons_gini \ ec13_man_job_pc \ ln_cons \ secc_ave_year_ed \ ln_remote \ pc11_p_sch_pc \ pc11_h_sch_pc \ pc11_vill_pop_road_share \ pc11_vill_pop_power_share, pstyle(p7)), ///
drop(_cons) xline(0) xtitle("") title("Expected Upward Mobility Rank Gain from 1 SD Change")
graphout rural_mobility_coefplot, pdf

/**************************************/
/* CORRELATES OF TOWN UPWARD MOBILITY */
/**************************************/
use $mobility/secc/secc_mobility_town, clear

gen p25_width = p25_ub - p25_lb
keep if p25_width < 1.6
drop p25_width group_id is_mon

foreach p in 25 {
  egen p`p' = rowmean(p`p'_lb p`p'_ub)
  drop p`p'_lb p`p'_ub
}

/* drop places with very few obs */
drop if n_obs < 300

/* merge town data */
merge 1:1 pc11_state_id pc11_district_id pc11_subdistrict_id pc11_town_id using $mobility/covars/town_mobility_covariates
keep if _merge == 3
drop _merge

/* drop places with town population < 10,000 */
drop if pc11_pca_tot_p < 10000

/* drop extreme outliers */
drop if p25 < 18 | p25 > 58

/* fix ed growth */
replace secc_ave_ed_growth = secc_ave_year_ed_2025 - secc_ave_year_ed_4050 

/* winsorize some covariates */
winsorize secc_cons_gini .1 .36, replace
winsorize ec13_man_job_pc 0 0.2, replace
winsorize secc_ave_pc_cons 1500 55000, replace
winsorize secc_ave_year_ed 4 10, replace
winsorize secc_ave_ed_growth 0.1 4, replace
winsorize pc_pop_growth_rate 0 .5, replace

/* create additional useful vars */
gen sc_share = pc11_pca_p_sc / pc11_pca_tot_p
gen st_share = pc11_pca_p_st / pc11_pca_tot_p
gen ln_cons = ln(secc_ave_pc_cons)
gen ln_pop = ln(pc11_pca_tot_p)

global varlist ln_pop pc_pop_growth_rate sc_share secc_dissim_scst secc_cons_gini ec13_man_job_pc ln_cons secc_ave_year_ed pc11_p_sch_pc pc11_h_sch_pc 

/* normalize all X vars of interest */
foreach v in $varlist {
  normalize `v', gen(`v'_norm)
}

/* create state, district groups */
group pc11_state_id
group pc11_state_id pc11_district_id

/* label variables */
label var ln_pop "Log Population"
label var pc_pop_growth_rate "Population Growth 2001-2011"
label var sc_share "Share Scheduled Caste"
label var secc_dissim_scst "SC/ST Segregation"
label var secc_cons_gini "Consumption Inequality"
label var ec13_man_job_pc "Manufacturing Jobs Per Capita"
label var ln_cons "Log Urban Consumption"
label var pc11_p_sch_pc "Primary Schools per Capita"
label var pc11_h_sch_pc "High Schools per Capita"
label var secc_ave_year_ed "Average Years Education"

label var ln_pop_norm "Log Population"
label var pc_pop_growth_rate_norm "Population Growth 2001-2011"
label var sc_share_norm "Share Scheduled Caste"
label var secc_dissim_scst_norm "SC/ST Segregation"
label var secc_cons_gini_norm "Consumption Inequality"
label var ec13_man_job_pc_norm "Manufacturing Jobs Per Capita"
label var ln_cons_norm "Log Urban Consumption"
label var pc11_p_sch_pc_norm "Primary Schools per Capita"
label var pc11_h_sch_pc_norm "High Schools per Capita"
label var secc_ave_year_ed_norm "Average Years Education"

save $tmp/urban_mob_covars, replace

use $tmp/urban_mob_covars, clear

/* presentation varlist */
global pres_list $varlist

/* build coefplot list */
global coef_list
foreach v in $pres_list {
  global coef_list $coef_list \ `v'
}
global coef_list = substr("$coef_list", 3, .)

/* BIVARIATE COEFPLOT */
eststo clear
foreach v in $pres_list {
  disp_nice "`v'"
  eststo `v': reg p25 `v'_norm, robust cluster(sdgroup)
}

coefplot ($coef_list, pstyle(p7)), ///
drop(_cons) xline(0) xtitle("") ///
title("Expected Upward Mobility Rank Gain from 1 SD Change")
graphout urban_mobility_coefplot,  pdf 





