use $mobility/ihds/ihds_mobility, clear

global f $tmp/parametric_moments.csv

global simsize 100000

cap erase $f
append_to_file using $f, s("bc, group, distribution, mu, sigma, pop")

/* add 1 to father ed so we can use lognormal */
replace father_ed = father_ed + 1

/* require all data to be present */
drop if mi(father_ed) | mi(son_ed)

/* generate log of father education */
gen ln_father_ed = ln(father_ed)

/* loop over all birth cohorts */
foreach bc in $bc_list {
  
  /* loop over all groups */
  forval group = 1/4 {

    /* count the number of people in the group  */
    qui sum wt if group == `group' & bc == `bc' 
    local sumwt = `r(mean)' * `r(N)'

    /* get the normal parameters */
    qui sum father_ed if group == `group' & bc == `bc' [aw=wt]
    append_to_file using $f, s("`bc',`group',normal,`r(mean)',`r(sd)',`sumwt'")

    /* get the lognormal parameters */
    qui sum ln_father_ed if group == `group' & bc == `bc' [aw=wt]
    append_to_file using $f, s("`bc',`group',lognormal,`r(mean)',`r(sd)',`sumwt'")

    /* get a normal dist version with constant variance across groups */
    qui sum father_ed if group == `group' & bc == `bc' [aw=wt]
    local m `r(mean)'
    qui sum father_ed if bc == `bc' [aw=wt]    
    append_to_file using $f, s("`bc',`group',normcv,`m',`r(sd)',`sumwt'")
    
    /* lognormal dist version with constant variance across groups */
    qui sum ln_father_ed if group == `group' & bc == `bc' [aw=wt]
    local m `r(mean)'
    qui sum ln_father_ed if bc == `bc' [aw=wt]    
    append_to_file using $f, s("`bc',`group',lognormcv,`m',`r(sd)',`sumwt'")
  }
}

/* NOW, GENERATE NEW DATA FROM THESE MOMENTS */
foreach bc in 1960 1985 {
  foreach distro in normal lognormal normcv lognormcv {
    import delimited $f, clear
    
    /* limit sample to one birth cohort */
    keep if bc == `bc' & inlist(distribution, "`distro'")

    /* calculate the total population for this group (simulating total population of 10,000) */
    assert _N == 4
    /* only 4 rows, so don't need a "by" for this total population calculation */
    egen total_pop = total(pop)
    gen group_share = pop / total_pop * $simsize
    
    /* reshape everything to wide. Now this is a one-row data set and all these can be used as parameters */
    reshape wide mu sigma pop total_pop group_share, j(group) i(bc) 
    drop pop* total_pop*

    /* define cuts between each group */
    gen cut1 = 1
    gen cut2 = round(group_share1)
    gen cut3 = round(group_share1 + group_share2)
    gen cut4 = round(group_share1 + group_share2 + group_share3)
    
    /* use 10,000 observations */
    expand $simsize
    gen row = _n
    
    /* set group indicators for simulated data */
    gen     group = 1 if inrange(row, cut1, cut2)
    replace group = 2 if inrange(row, cut2 + 1, cut3)
    replace group = 3 if inrange(row, cut3 + 1, cut4)
    replace group = 4 if inrange(row, cut4 + 1, $simsize)

    /* draw data for each from a normal distribution with that group's parameters */
    if inlist("`distro'", "normal", "normcv") {
      gen     ed = rnormal(mu1, sigma1) if group == 1
      replace ed = rnormal(mu2, sigma2) if group == 2
      replace ed = rnormal(mu3, sigma3) if group == 3
      replace ed = rnormal(mu4, sigma4) if group == 4
    }
    else if inlist("`distro'", "lognormal", "lognormcv") {
      
      /* repeat for the lognormal draw */
      gen     ln_ed = rnormal(mu1, sigma1) if group == 1
      replace ln_ed = rnormal(mu2, sigma2) if group == 2
      replace ln_ed = rnormal(mu3, sigma3) if group == 3
      replace ln_ed = rnormal(mu4, sigma4) if group == 4
      gen ed = exp(ln_ed)
    }
  
    /* rank everyone */
    egen ed_rank = rank(ed)
    replace ed_rank = ed_rank * (100 / $simsize)

    /* save simulated distribution */
    save $tmp/mob_sim_`distro'_`bc', replace
  }
}

/* summarize ed distribution in each simulated dataset */
qui foreach bc in 1960 1985 {
  foreach distro in normal normcv lognormal lognormcv {
    use $tmp/mob_sim_`distro'_`bc', clear

    /* show average rank for each group */
    noi disp_nice "TABLE 1: Simulated, `distro' simulation (`bc')"
    noi tabstat ed_rank, by(group) s(mean sd)
  }

  /* now calculate the same distribution from the IHDS */
  use $mobility/ihds/ihds_mobility, clear
  keep if !mi(son_ed) & !mi(father_ed_rank_s) & bc == `bc'
  
  /* save the real data in the same file naming syntax as the simulated data 
     NOTE: MUST RUN THIS LINE TO SAVE THE DATA FILE USED TO CREATE LATEX TABLE*/
  save $tmp/mob_sim_data_`bc', replace

  noi disp_nice "TABLE 1: Binned data (IHDS) (`bc')"
  noi tabstat father_ed_rank_s [aw=wt], by(group) s(mean sd)
}

/* review where the bottom 50% lies in the IHDS */
// use $mobility/ihds/ihds_mobility, clear
// keep if !mi(son_ed) & !mi(father_ed_rank_s)
// tab father_ed_rank_s [aw=wt] if bc == 1960
// tab father_ed_rank_s [aw=wt] if bc == 1985
/* bottom bin in 1960: 56% */
/* bottom 2 bins in 1985: 46.8% */

foreach bc in 1960 1985 {
  foreach distro in normal lognormal normcv lognormcv {
    disp_nice "`distro'-`bc'"
    // local bin1_1985 35.66
    // local bin2_1985 46.88
    // local bin1_1960 57.83
    // local bin2_1960 70.97
    use $tmp/mob_sim_`distro'_`bc', clear

    /* show ed rank by group */
    di "Mean ed rank in bin 1 (`distro'-`bc')"
    tabstat ed_rank if ed_rank <= 50, by(group) s(mean sd)
  }
}


/****** construct table for real and simulated ed_rank values for the four groups ******/
cap !rm -f $out/sim_moments.csv

/* get values for the 1960 and 1985 birth cohorts */
foreach bc in 1960 1985 {

  /* only get values from the normal and lognormal distributions */
  foreach distro in data normal lognormal {

    disp_nice "Running for Birth Cohort `bc', `distro'"
    
    /* open the data for this birth cohort and this distribution */
    qui use $tmp/mob_sim_`distro'_`bc', clear
    
    /* get the list of groups */
    qui levelsof group, local(group_list)

    /* cycle through the four groups */
    foreach grp in `group_list' {
    
      /* get mean and standard deviation of ed_rank for this group from real  data */
      if "`distro'" == "data" {
        sum father_ed_rank_s if group == `grp' [aw=wt]
      }
      /* get mean and standard deviation of ed_rank for this group from simulated data */
      else {
        sum ed_rank if group == `grp'
      }

      /* store the mean and standard deviation */
      local mu = `r(mean)'
      local sd = `r(sd)'

      /* add the mean and standard deviation to the csv that will feed the latex table values */
      insert_into_file using $out/sim_moments.csv, key(mean_`bc'_`distro'_`grp') value(`mu') format(%9.1f)
      insert_into_file using $out/sim_moments.csv, key(sd_`bc'_`distro'_`grp') value(`sd') format(%9.1f)
    }
  }
}

table_from_tpl, t($mobcode/a/sim_moments_tpl.tex) r($out/sim_moments.csv) o($out/sim_moments.tex)

/****** construct table for simulated ed_rank values for the bottom half of the distribution for the four group ******/
cap !rm -f $out/sim_param_ranks.csv

/* get values for the 1960 and 1985 birth cohorts */
foreach bc in 1960 1985 {

  /* only get values from the normal and lognormal distributions */
  foreach distro in normal lognormal normcv lognormcv {

    disp_nice "Running for Birth Cohort `bc', `distro'"
    
    /* open the data for this birth cohort and this distribution */
    qui use $tmp/mob_sim_`distro'_`bc', clear
    
    /* get the list of groups */
    qui levelsof group, local(group_list)

    /* cycle through the four groups */
    foreach grp in `group_list' {

    /* get the mean and standard deviation of this group from this distribution of simulated data */
    sum ed_rank if ed_rank <= 50 & group == `grp'

      /* store the mean and standard deviation */
      local mu = `r(mean)'
      
      /* add the mean and standard deviation to the csv that will feed the latex table values */
      insert_into_file using $out/sim_param_ranks.csv, key(mean_`bc'_`distro'_`grp') value(`mu') format(%9.1f)
    }
  }
}

table_from_tpl, t($mobcode/a/sim_param_ranks_tpl.tex) r($out/sim_param_ranks.csv) o($out/sim_param_ranks.tex)
