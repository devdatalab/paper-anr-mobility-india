/* load replication config [this calls an empty file in the project repo]  */
do $mobcode/config_mobility.do

/* set this global to 1 in order to skip the Matlab parts
   (only Figure 1 and the rank-rank gradient calculation) */
global fast 0

/* load mobility programs */
do $mobcode/mobility_programs.do

/***************************************************/
/* Build the core and ancillary mobility data sets */
/***************************************************/

/* rebuild IHDS in the IHDS folder, include parent-child link files */
do $ihdscode/make_ihds.do

/* create mobility dataset: select best parent child links and create all ed variables */
do $mobcode/b/create_ihds_mobility.do

/*  prepare U.S. / Europe mobility datasets */
// do $mobcode/b/prep_mob_us_europe.do

/* prepare Jati code based on Cassan 2019 */
if ("$fast") != "1" {
  do $mobcode/b/clean_jati_2011.do
}
do $mobcode/b/build_aa_2011.do

/* prepare u.s. ed transition matrices */
do $mobcode/b/prep_us_mobility.do

/* Calculate bounds on all mobility stats  */
do $mobcode/b/calc_ihds_mus.do

/************/
/* ANALYSIS */
/************/

/* calculate transition matrices */
do $mobcode/a/calc_trans_matrices.do

/* scatter plot of education levels over time (Figure 3) */
do $mobcode/a/graph_levels_time.do

/* mob_ihds_vs_usa_den: non-parametric ed rank-rank vs. US and Denmark */
do $mobcode/a/graph_non_param.do

/* ihds_mob_time: Combined groups mobility over time (Figure 5, A5) */
do $mobcode/a/graph_mob_time.do

/* ihds_mob_group_time: Mobility changes by group (Figure 6, A6) */
do $mobcode/a/graph_subgroup_mob.do

/* plot mu vs. p25 vs. gradient (Figure 4) */
do $mobcode/a/graph_other_stats.do 

/* mob_urban_rural_groups: Static current subgroup results by urban/rural */
// do $mobcode/a/graph_mob_urban_rural.do

/* high-res geographic correlates of mobility */
// do $mobcode/a/graph_mob_geo_correlates.do

/* benchmark geographic variation in U.S. vs India */
// do $mobcode/a/benchmark_mob_geog.do

/************************************/
/* MECHANISMS FOR CHANGING MOBILITY */
/************************************/

/* Figure A8A */
do $mobcode/a/graph_mech_geo.do

/* Table A5 */
do $mobcode/a/table_mech_fertility.do


/* Figure A8b */
do $mobcode/a/graph_mech_mincerian.do

/* Figure A8c */
do $mobcode/a/graph_mech_occupation.do

/* Table 3, Figure 7, Figure A7 */
do $mobcode/a/graph_mech_aa.do

/*************************************************************/
/* CALCULATE BOOTSTRAP MOBILITY NUMBERS WITH CONFIDENCE SETS */
/*************************************************************/

/* calculate bootstrap samples */
if ("$fast") != "1" {

  /* create B different versions of the IHDS and store in $mobility/ihds/bootstrap/ */
  do $mobcode/b/bootstrap_samples.do
  
  /* calculate mus of interest from each of the B IHDS bootstraps */
  /* maybe not needed? */
  do $mobcode/b/bootstrap_mus.do

  /* this program seems to calculate the smart confidence intervals */
  // do $mobcode/b/bootstrap_from_bounds.do

}

/* generate bootstrap tables with mu bounds and confidence sets */
/* Table 1 */
do $mobcode/a/table_change_time.do

/* table 2 */
do $mobcode/a/table_group_diff.do

/******************/
/* ROBUSTNESS/ETC */
/******************/

/* calculate one-off statistics used in the paper */
do $mobcode/a/calc_mob_stats.do

/* generate graphs of poterba-style arithmetic examples (Figure 2) */
do $mobcode/a/graph_arith_mob_example_ihds.do

/* report on internal inconsistencies in IHDS parent-child links (Table A2) */
do $mobcode/a/appendix_table_ihds_pc_link_quality.do

/**************/
/* APPENDICES */
/**************/

/* survivorship bias -- estimates from IHDS 2005 (Figure A4) */
do $mobcode/a/graph_mob_ihds_2005_2011.do

/* mortality-style scatterplots (Figure A3) */
do $mobcode/a/graph_scatter.do

/* generate coresidence and cores bias plots (Figures A1 and A2) */
do $mobcode/a/graph_coresidence.do

/* within-bin latent rank estimations (Appendix Tables C1 and C2) */
do $mobcode/a/app_within_bin.do

/* Appendix Figure C2 --- mobility with within-group ranking */
do $mobcode/a/graph_subgroup_withinrank_mob.do

/* Appendix: group mobilities using granular education data (Table A4) */
do $mobcode/a/appendix_table_gran.do

/* analysis of churn --- testing SC vs. Muslim outcomes at bottom of the SES distribution */
/* Figure C1 */
do $mobcode/a/stats_churn.do

/* mean descriptive characteristics of people in the bottom half */
/* Table A3 */
do $mobcode/a/stats_bottom_half.do

/* MISSING: Table A1 */


/*******************/
/* Matlab analyses */
/*******************/
if "$fast" == "1" exit

/* export father-son mobility moments for Matlab */
do $mobcode/b/create_matlab_moments.do

/* Use matlab to calculate curvature-constrained mus and gradients */
shell matlab -nosplash -nodesktop -r '$mobcode/a/matlab/calc_all_mob_stats; exit;'

/* make other matlab figures */
shell matlab $mobcode/a/matlab/make_all_figures

