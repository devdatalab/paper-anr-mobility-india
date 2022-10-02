/***********************************************/
/* /\* construct 1000 bootstraps from ihds *\/ */
/***********************************************/
set seed 193751

/****** set how many samples you want to take ******/ 
local N = 1000

cap mkdir $mobility/ihds/bootstrap

/*************************************/
/* first bootstrap the data ranking by decade */
/*************************************/
/* construct working dataset with only crucial variables */ 
use $mobility/ihds/ihds_mobility, clear
replace bc = 1980 if bc == 1985
rerank, by(bc)
keep son_ed_rank daughter_ed_rank *_prim *_mid *_hs *_uni father_ed_rank_s father_ed_rank_d mother_ed_rank_s mother_ed_rank_d wt group bc

save $tmp/decadal_bootstrap_working, replace

/***** sample with replacement from the data and save into separate dataset ********/ 
forv i = 1/`N'  {
  qui {
    noisily di "sample `i' of `N' at `c(current_time)' "
    use $tmp/decadal_bootstrap_working, clear   
    local numberobs = _N 
    bsample `numberobs' 
    save $mobility/ihds/bootstrap/decadal_sample_`i', replace
  }
}

/*************************************/
/* then bootstrap the regular data  */
/*************************************/
/* construct working dataset with only crucial variables */ 
use $mobility/ihds/ihds_mobility, clear
keep son_ed_rank daughter_ed_rank *_prim *_mid *_hs *_uni father_ed_rank_s father_ed_rank_d  mother_ed_rank_s mother_ed_rank_d wt group bc
save $tmp/bootstrap_working, replace

/***** sample with replacement from the data and save into separate dataset ********/ 
forv i = 1/`N'  {
  qui {
    noisily di "sample `i' of `N' at `c(current_time)' "

    use $tmp/bootstrap_working, clear   
    local numberobs = _N 
    bsample `numberobs' 
    save $mobility/ihds/bootstrap/sample_`i', replace
  }
}
