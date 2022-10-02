/***************************/
/* Clean all raw IHDS data */
/***************************/

/* create a temporary folder for this makefile */
cap mkdir $tmp/ihds

/*******************/
/* CLEAN RAW FILES */
/*******************/

/* create clean 2005 IHDS */
do $ihdscode/clean_ihds_2005.do

/* clean the household file */
do $ihdscode/clean_ihds_2011_hh.do

/* clean the members file */
do $ihdscode/clean_ihds_2011_members.do

/* clean the women's survey */
do $ihdscode/clean_ihds_2011_women.do

/******************************************/
/* CREATE ALL POSSIBLE PARENT-CHILD LINKS */
/******************************************/

/* create parent-child links from eligible women's survey */
do $ihdscode/gen_pc_ew_links.do

/* create parent-child links from household roster */
do $ihdscode/gen_pc_roster_links.do

/* calculate mother's fertility (i.e. # siblings) */
do $ihdscode/gen_mother_fertility.do

/* create combined file with all links and the one link we think is best */
do $ihdscode/combine_pc_links.do
