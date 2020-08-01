

/* set this global to 1 in order to skip the slow parts (matlab f2 calcs, plus local mobility rebuilds) */
global fast 0

/***************************************************/
/* Build the core and ancillary mobility data sets */
/***************************************************/

/* rebuild IHDS in the IHDS folder, include parent-child link files */
do $ihdscode/make_ihds.do

/* build 2005 IHDS */
do $ihdscode/clean_ihds_2005.do

/* create mobility dataset: select best parent child links and create all ed variables */
do $mobcode/b/create_ihds_mobility.do

/* export father-son mobility moments for Matlab */
do $mobcode/b/create_matlab_moments.do

/*  prepare U.S. / Europe mobility datasets */
// do $mobcode/b/prep_mob_us_europe.do

/* prepare Jati code based on Cassan 2019 */
if ("$fast") != "1" {
  do $mobcode/b/clean_jati_2011
}
do $mobcode/b/build_aa_2011

/* prepare u.s. ed transition matrices */
do $mobcode/b/prep_us_mobility.do

/************************************/
/* CALCULATE BOUNDS ON MOBILITY MUS */
/************************************/

/* Use stata to calculate f2=0 mus */
do $mobcode/b/calc_ihds_mus.do

if ("$fast") != "1" {
  /* Use matlab to calculate curvature-constrained mus and gradients */
  shell matlab -nosplash -nodesktop -r '$mobcode/a/matlab/calc_all_mob_stats; exit;'
}

/************************************/
/* prepare SECC local mobility data */
/************************************/

if ("$fast") != "1" {
  
  /* create SECC urban, rural and combined mobility datasets, with young people only */
  do $mobcode/b/prep_secc_parent_child_links
  
  /* create aggregate mobility for subdistricts, towns, villages, etc.. */
  do $mobcode/b/calc_secc_local_mobility
}

/***********************************/
/* PREP DATA FOR ROBUSTNESS CHECKS */
/***********************************/


/************/
/* ANALYSIS */
/************/

/* mob_ihds_vs_usa_den: non-parametric ed rank-rank vs. US and Denmark */
do $mobcode/a/graph_non_param.do

/* ihds_mob_time: Combined groups mobility over time */
do $mobcode/a/graph_mob_time.do

/* ihds_mob_group_time: Mobility changes by group */
do $mobcode/a/graph_subgroup_mob.do

/* plot mu vs. p25 vs. gradient */
do $mobcode/a/graph_other_stats.do

/* mob_urban_rural_groups: Static current subgroup results by urban/rural */
do $mobcode/a/graph_mob_urban_rural.do

/* high-res geographic correlates of mobility */
do $mobcode/a/graph_mob_geo_correlates.do

/* benchmark geographic variation in U.S. vs India */
do $mobcode/a/benchmark_mob_geog.do

/* matlab example CEFs */
if ("$fast") != "1" {
  shell matlab $mobcode/a/matlab/make_all_figures
}
/************************************/
/* MECHANISMS FOR CHANGING MOBILITY */
/************************************/
do $mobcode/a/graph_mech_geo.do
do $mobcode/a/table_mech_fertility.do
do $mobcode/a/graph_mech_mincerian.do
do $mobcode/a/graph_mech_occupation.do
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
do $mobcode/a/table_change_time.do
do $mobcode/a/table_group_diff.do

/******************/
/* ROBUSTNESS/ETC */
/******************/

/* calculate one-off statistics used in the paper */
do $mobcode/a/calc_mob_stats.do

/* generate graphs of poterba-style arithmetic examples */
do $mobcode/a/graph_arith_mob_example_ihds.do

/* report on internal inconsistencies in IHDS parent-child links */
do $mobcode/a/appendix_table_ihds_pc_link_quality.do

/* store validity stats (in IHDS) showing SECC parnet guesses are ok. */
do $mobcode/a/stat_ihds_secc_predicted_parents.do

/**************/
/* APPENDICES */
/**************/

/* survivorship bias -- estimates from IHDS 2005 */
do $mobcode/a/graph_mob_ihds_2005_2011.do

/* mortality-style scatterplots */
do $mobcode/a/graph_scatter.do

/* generate coresidence and cores bias plots */
do $mobcode/a/graph_coresidence.do

/* within-bin latent rank estimations */
do $mobcode/a/app_within_bin.do
do $mobcode/a/graph_subgroup_withinrank_mob.do

/* Appendix: group mobilities using granular education data */
do $mobcode/a/appendix_table_gran.do

