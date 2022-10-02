/* This dofile builds the US moments from Chetty et al. Census
   transition matrices */


/**********************************************/
/* program that generates rank from fraction  */
/* in these data                              */
/* options: fvar: fraction variable. rvar: new name of rank variable */
cap pr drop rfromf
pr define rfromf
  syntax, fvar(string) rvar(string) 

  /* error check that there are precisely 4 levels of the variable */ 
  forv i = 1/4    {
    d `fvar'`i'
  }

  /* create cumulative values of the fraction variable */
  gen `fvar'sum0 = 0  
  gen `fvar'sum1 = `fvar'1 
  gen `fvar'sum2 = `fvar'1 + `fvar'2
  gen `fvar'sum3 = `fvar'1 + `fvar'2 + `fvar'3
  
  forv i = 1/4 {
    local iminus1 = `i' - 1
    gen `rvar'`i' = `fvar'sum`iminus1' + .5 * `fvar'`i'
  }
  drop *sum? 
end

/* open the Hendren ed transition data */
use $mobility/us/us_ed_race_transitions, clear

/* clean some varnames for consistency */
ren kid_race race
replace race = lower(race)
replace gender = lower(gender)

/************************************************/
/* get pooled kid/parent ranks from these data  */
/************************************************/

/* generate the count in each bin, which we will use later */
forv i = 1/4 {
  gen count_kid`i' = kid_edu`i' * count
  gen count_par`i' = par_edu`i' * count
}

/* unit test: parent counts add up to kid counts */
assert inrange((count_kid1 + count_kid2 + count_kid3 + count_kid4) /    ///
    (count_par1 + count_par2 + count_par3 + count_par4), .999, 1.001)

/* calculate the count in each conditional bin */
forv k = 1/4 {
  forv p = 1/4 {
    gen count_kid`k'_par`p' = kid_edu`k'_cond_par_edu`p' * count_par`p'
  }
}

/* unit test: assert conditional counts add up to total kid counts and total parent counts */
forv k = 1/4 {

  /* total kid count */
  gen c`k' = count_kid`k'_par1 + count_kid`k'_par2 + count_kid`k'_par3 + count_kid`k'_par4
  gen diff = c`k'/count_kid`k'
  assert inrange(diff, .999, 1.001)
  drop c`k' diff

  /* total parent count */
  gen c`k' = count_kid1_par`k' + count_kid2_par`k' + count_kid3_par`k' + count_kid4_par`k'
  gen diff = c`k'/count_par`k'
  assert inrange(diff, .999, 1.001)
  drop c`k' diff
}

save $tmp/us_tmp, replace

/***********************************************************/
/* create a version of this that is collapsed across races */
/***********************************************************/

/* collapse across race to get 1 row for each gender */
drop count
collapse (sum) count*, by(gender)

/* calculate conditional probabilities using Hendren varnames */
forv k = 1/4 {
  forv p = 1/4 {
    gen kid_edu`k'_cond_par_edu`p' = count_kid`k'_par`p' / count_par`p'
  }
}

/* unit test: rows of transition matrix should sum to 1 */
forv i = 1/4 {
  gen c`i' = kid_edu1_cond_par_edu`i' + kid_edu2_cond_par_edu`i' + kid_edu3_cond_par_edu`i' + kid_edu4_cond_par_edu`i'
  assert inrange(c`i', 0.999, 1.001)
  drop c`i'
}

/* create unconditional probability to be consistent with Hendren dataset */
egen total_kid = rowtotal(count_kid?)
egen total_par = rowtotal(count_par?)

/* unit test: parent count should equal kid count */
assert inrange(total_kid / total_par, .999, 1.001)

/* generate share of kids in each bin */
forv i = 1/4 {
  gen kid_edu`i' = count_kid`i' / total_kid
  gen par_edu`i' = count_par`i' / total_par
}  

/********************************************************************************************************/
/* create the parent and child rank variables in the "all" dataset, because this is where we want ranks */
/********************************************************************************************************/

/* we have parent/kid counts in each ed group -- turn them into shares so we can get ranks */
forval i = 1/4 {
  gen share_kid`i' = count_kid`i' / total_kid
  gen share_par`i' = count_par`i' / total_par
}  

/* unit test: shares should add up to 1 */
assert abs(float(1 - (share_par1  + share_par2  + share_par3  + share_par4) )) < .001
assert abs(float(1 - (share_kid1  + share_kid2  + share_kid3  + share_kid4) )) < .001

/* obtain midpoint ranks from shares */ 
rfromf, fvar(share_par) rvar(par_rank) 
rfromf, fvar(share_kid) rvar(kid_rank) 

/* generate the total count across all education groups */
gen count = total_kid
drop total_kid total_par

/* set race to "all" for these rows */
gen race = "all"

/********************************************************************/
/* append and process the original dataset with the race categories */
/********************************************************************/

/* append original dataset, and now we have an "all" category */
append using $tmp/us_tmp

/* copy the all-races within-gender ranks to all the rows */
forval i = 1/4 {
  bys gender: egen tmp = max(par_rank`i')
  replace par_rank`i' = tmp if mi(par_rank`i')
  drop tmp
  
  bys gender: egen tmp = max(kid_rank`i')
  replace kid_rank`i' = tmp if mi(kid_rank`i')
  drop tmp
}

/* conditional on each parent level, obtain the average child rank */ 
forv i = 1/4 {  
  gen kid_rank_par`i' = kid_edu1_cond_par_edu`i' * kid_rank1 + ///
      kid_edu2_cond_par_edu`i' * kid_rank2 + ///
      kid_edu3_cond_par_edu`i' * kid_rank3 + ///
      kid_edu4_cond_par_edu`i' * kid_rank4
}

keep kid_rank_par* par_rank* *race *count *gender count_kid? count_par?

/* reshape into one row per parent ed (* race/gender) -- our standard mobility format */ 
reshape long kid_rank_par count_par par_rank, i(race gender ) j( par_ed )
ren kid_rank_par kid_rank

/* rescale so ranks run from 0-100 */
replace kid_rank = kid_rank * 100
replace par_rank = par_rank * 100

/* unit test: all-race mu-0-100 should be really close to 50  */ 
/* [though this could fail if the bounds are wide] */
foreach gender in f m p {
  bound_param if gender == "`gender'" & race == "all", xvar(par_rank) yvar(kid_rank) s(0) t(100) qui
  assert inrange( (`r(mu_ub)' + `r(mu_lb)') / 2, 49, 51)
}

/* save the processed U.S. mobility dataset */
save $mobility/us/us_ed_mobility_clean, replace


